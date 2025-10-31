#!/bin/bash

# Script de gerenciamento para ambiente de desenvolvimento
# Uso: ./docker/scripts/dev.sh [comando]

set -e

# Definir cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagem com cor
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para verificar se o docker-compose está disponível
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "docker-compose não está instalado ou não está no PATH"
        exit 1
    fi
}

# Função para verificar se os arquivos necessários existem
check_files() {
    if [ ! -f ".env" ]; then
        print_warning ".env não encontrado, copiando de .env.example"
        cp .env.example .env
        print_message "Por favor, configure as variáveis necessárias no arquivo .env"
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml não encontrado"
        exit 1
    fi
}

# Função de ajuda
show_help() {
    echo "Script de gerenciamento para ambiente de desenvolvimento"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start       - Iniciar ambiente de desenvolvimento"
    echo "  stop        - Parar ambiente de desenvolvimento"
    echo "  restart     - Reiniciar ambiente de desenvolvimento"
    echo "  rebuild     - Reconstruir imagens e reiniciar"
    echo "  logs        - Ver logs (padrão: api, ou especificar serviço)"
    echo "  shell       - Acessar shell do container (padrão: api, ou especificar serviço)"
    echo "  test        - Executar testes"
    echo "  lint        - Executar linting"
    echo "  format      - Formatar código"
    echo "  status      - Ver status dos serviços"
    echo "  clean       - Parar e remover containers, redes e volumes (NÃO VOLUMES NOMEADOS)"
    echo "  db-shell    - Acessar shell do PostgreSQL"
    echo "  redis-cli   - Acessar CLI do Redis"
    echo "  help        - Mostrar esta ajuda"
    echo ""
}

# Função para iniciar ambiente
start_dev() {
    print_message "Iniciando ambiente de desenvolvimento..."
    check_docker_compose
    check_files
    
    # Verificar se os serviços já estão rodando
    if docker-compose ps | grep -q "Up"; then
        print_warning "Alguns serviços já estão rodando. Parando primeiro..."
        docker-compose down
    fi
    
    # Iniciar serviços em modo detached
    docker-compose up -d --build
    
    # Aguardar alguns segundos para os serviços iniciarem
    print_message "Aguardando inicialização dos serviços..."
    sleep 10
    
    # Verificar status dos serviços
    docker-compose ps
    
    print_success "Ambiente de desenvolvimento iniciado com sucesso!"
    print_message "API disponível em: http://localhost:8000"
    print_message "Documentação disponível em: http://localhost:8000/docs"
    print_message "PgAdmin disponível em: http://localhost:5050"
    print_message "Redis Commander disponível em: http://localhost:8081"
}

# Função para parar ambiente
stop_dev() {
    print_message "Parando ambiente de desenvolvimento..."
    docker-compose down
    print_success "Ambiente de desenvolvimento parado com sucesso!"
}

# Função para reiniciar ambiente
restart_dev() {
    print_message "Reiniciando ambiente de desenvolvimento..."
    stop_dev
    start_dev
}

# Função para reconstruir ambiente
rebuild_dev() {
    print_message "Reconstruindo ambiente de desenvolvimento..."
    check_docker_compose
    check_files
    
    # Parar serviços existentes
    docker-compose down
    
    # Remover imagens antigas do serviço
    docker-compose build --no-cache
    
    # Iniciar novamente
    start_dev
}

# Função para visualizar logs
view_logs() {
    local service=${1:-api}
    
    if [ "$service" = "all" ]; then
        docker-compose logs -f
    else
        # Verificar se o serviço existe
        if docker-compose config --services | grep -q "^$service$"; then
            docker-compose logs -f "$service"
        else
            print_error "Serviço '$service' não encontrado. Serviços disponíveis:"
            docker-compose config --services
            exit 1
        fi
    fi
}

# Função para acessar shell
access_shell() {
    local service=${1:-api}
    
    # Verificar se o serviço existe
    if docker-compose config --services | grep -q "^$service$"; then
        docker-compose exec "$service" /bin/bash
    else
        print_error "Serviço '$service' não encontrado. Serviços disponíveis:"
        docker-compose config --services
        exit 1
    fi
}

# Função para executar testes
run_tests() {
    print_message "Executando testes..."
    docker-compose exec api python -m pytest -v
}

# Função para executar linting
run_lint() {
    print_message "Executando linting..."
    docker-compose exec api python -m flake8 .
    docker-compose exec api python -m mypy .
}

# Função para formatar código
run_format() {
    print_message "Formatando código..."
    docker-compose exec api python -m black .
    docker-compose exec api python -m isort .
}

# Função para visualizar status
show_status() {
    print_message "Status dos serviços:"
    docker-compose ps
}

# Função para limpar recursos
clean_dev() {
    print_warning "Esta ação irá parar e remover containers, redes e volumes (exceto volumes nomeados)."
    read -p "Continuar? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "Limpando recursos do ambiente de desenvolvimento..."
        docker-compose down -v
        print_success "Recursos limpos com sucesso!"
    else
        print_message "Operação cancelada."
    fi
}

# Função para acessar shell do PostgreSQL
db_shell() {
    print_message "Acessando shell do PostgreSQL..."
    docker-compose exec postgres psql -U astrology_user -d astrology_dev
}

# Função para acessar CLI do Redis
redis_cli() {
    print_message "Acessando CLI do Redis..."
    docker-compose exec redis redis-cli
}

# Verificar argumento
case "${1:-help}" in
    start)
        start_dev
        ;;
    stop)
        stop_dev
        ;;
    restart)
        restart_dev
        ;;
    rebuild)
        rebuild_dev
        ;;
    logs)
        view_logs "${2:-api}"
        ;;
    shell)
        access_shell "${2:-api}"
        ;;
    test)
        run_tests
        ;;
    lint)
        run_lint
        ;;
    format)
        run_format
        ;;
    status)
        show_status
        ;;
    clean)
        clean_dev
        ;;
    db-shell)
        db_shell
        ;;
    redis-cli)
        redis_cli
        ;;
    help|"")
        show_help
        ;;
    *)
        print_error "Comando desconhecido: $1"
        show_help
        exit 1
        ;;
esac