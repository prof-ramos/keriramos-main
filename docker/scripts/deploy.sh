#!/bin/bash

# Script de gerenciamento para ambiente de produção
# Uso: ./docker/scripts/deploy.sh [comando]

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
    if [ ! -f ".env.production" ]; then
        print_error ".env.production não encontrado"
        print_message "Por favor, crie um arquivo .env.production com as configurações de produção"
        exit 1
    fi
    
    if [ ! -f "docker-compose.prod.yml" ]; then
        print_error "docker-compose.prod.yml não encontrado"
        exit 1
    fi
}

# Função de ajuda
show_help() {
    echo "Script de gerenciamento para ambiente de produção"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  deploy      - Fazer deploy completo em produção"
    echo "  update      - Atualizar serviços em produção"
    echo "  rollback    - Fazer rollback para versão anterior"
    echo "  status      - Ver status dos serviços em produção"
    echo "  logs        - Ver logs (padrão: api, ou especificar serviço)"
    echo "  shell       - Acessar shell do container (padrão: api, ou especificar serviço)"
    echo "  test        - Executar testes de smoke em produção"
    echo "  backup      - Fazer backup do banco de dados"
    echo "  restore     - Restaurar banco de dados de backup"
    echo "  scale       - Escalar serviço (ex: $0 scale api 3)"
    echo "  health      - Verificar saúde da API"
    echo "  help        - Mostrar esta ajuda"
    echo ""
}

# Função para deploy em produção
deploy_prod() {
    print_message "Fazendo deploy em produção..."
    check_docker_compose
    check_files
    
    # Carregar variáveis de ambiente de produção
    export $(grep -v '^#' .env.production | xargs)
    
    # Verificar se os serviços já estão rodando
    if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        print_warning "Alguns serviços já estão rodando. Atualizando..."
        update_prod
    else
        print_message "Iniciando serviços em produção..."
        
        # Iniciar serviços em modo detached
        docker-compose -f docker-compose.prod.yml up -d --build
        
        # Aguardar alguns segundos para os serviços iniciarem
        print_message "Aguardando inicialização dos serviços..."
        sleep 20
        
        # Verificar status dos serviços
        docker-compose -f docker-compose.prod.yml ps
        
        # Verificar saúde da API
        check_health
        
        print_success "Deploy em produção realizado com sucesso!"
        print_message "API disponível em: https://${API_HOST:-api.astrologia.br}"
        print_message "Traefik Dashboard disponível em: https://${TRAEFIK_HOST:-traefik.astrologia.br}"
        print_message "Grafana disponível em: https://${GRAFANA_HOST:-grafana.astrologia.br}"
    fi
}

# Função para atualizar serviços em produção
update_prod() {
    print_message "Atualizando serviços em produção..."
    check_docker_compose
    check_files
    
    # Carregar variáveis de ambiente de produção
    export $(grep -v '^#' .env.production | xargs)
    
    # Fazer backup antes da atualização
    print_message "Fazendo backup antes da atualização..."
    backup_prod
    
    # Parar os serviços atuais
    docker-compose -f docker-compose.prod.yml down
    
    # Atualizar imagens
    print_message "Atualizando imagens Docker..."
    docker-compose -f docker-compose.prod.yml pull
    
    # Reconstruir imagem da API se necessário
    docker-compose -f docker-compose.prod.yml build --no-cache api
    
    # Iniciar serviços novamente
    docker-compose -f docker-compose.prod.yml up -d
    
    # Aguardar inicialização
    print_message "Aguardando inicialização dos serviços..."
    sleep 30
    
    # Verificar status dos serviços
    docker-compose -f docker-compose.prod.yml ps
    
    # Verificar saúde da API
    check_health
    
    print_success "Serviços em produção atualizados com sucesso!"
}

# Função para fazer rollback
rollback_prod() {
    print_warning "Fazendo rollback para versão anterior..."
    print_warning "Esta funcionalidade atualiza com a imagem mais recente no registry, que pode ou não ser a versão anterior."
    read -p "Continuar? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Carregar variáveis de ambiente de produção
        export $(grep -v '^#' .env.production | xargs)
        
        # Parar os serviços atuais
        docker-compose -f docker-compose.prod.yml down
        
        # Puxar a imagem mais recente (que pode ser a versão anterior)
        docker-compose -f docker-compose.prod.yml pull
        
        # Reiniciar serviços
        docker-compose -f docker-compose.prod.yml up -d
        
        # Aguardar inicialização
        print_message "Aguardando inicialização dos serviços..."
        sleep 30
        
        # Verificar status
        docker-compose -f docker-compose.prod.yml ps
        
        # Verificar saúde da API
        check_health
        
        print_success "Rollback realizado com sucesso!"
    else
        print_message "Operação cancelada."
    fi
}

# Função para verificar status
status_prod() {
    print_message "Status dos serviços em produção:"
    # Carregar variáveis de ambiente de produção
    export $(grep -v '^#' .env.production | xargs)
    docker-compose -f docker-compose.prod.yml ps
}

# Função para visualizar logs
view_logs() {
    # Carregar variáveis de ambiente de produção
    export $(grep -v '^#' .env.production | xargs)
    
    local service=${1:-api}
    
    if [ "$service" = "all" ]; then
        docker-compose -f docker-compose.prod.yml logs -f
    else
        # Verificar se o serviço existe
        if docker-compose -f docker-compose.prod.yml config --services | grep -q "^$service$"; then
            docker-compose -f docker-compose.prod.yml logs -f "$service"
        else
            print_error "Serviço '$service' não encontrado. Serviços disponíveis:"
            docker-compose -f docker-compose.prod.yml config --services
            exit 1
        fi
    fi
}

# Função para acessar shell
access_shell() {
    # Carregar variáveis de ambiente de produção
    export $(grep -v '^#' .env.production | xargs)
    
    local service=${1:-api}
    
    # Verificar se o serviço existe
    if docker-compose -f docker-compose.prod.yml config --services | grep -q "^$service$"; then
        docker-compose -f docker-compose.prod.yml exec "$service" /bin/bash
    else
        print_error "Serviço '$service' não encontrado. Serviços disponíveis:"
        docker-compose -f docker-compose.prod.yml config --services
        exit 1
    fi
}

# Função para testes de smoke em produção
run_smoke_test() {
    print_message "Executando testes de smoke em produção..."
    
    # Verificar saúde da API
    check_health
    
    # Verificar se outros serviços críticos estão acessíveis
    if [ -n "$API_HOST" ]; then
        print_message "Verificando disponibilidade da API em https://$API_HOST/health"
        if curl -f -s "https://$API_HOST/health" > /dev/null; then
            print_success "API disponível e saudável"
        else
            print_error "API não respondeu corretamente"
            exit 1
        fi
    else
        print_warning "API_HOST não definido, pulando teste de disponibilidade"
    fi
    
    print_success "Testes de smoke concluídos com sucesso!"
}

# Função para backup
backup_prod() {
    print_message "Fazendo backup do banco de dados de produção..."
    
    # Carregar variáveis de ambiente de produção
    export $(grep -v '^#' .env.production | xargs)
    
    # Criar diretório de backup se não existir
    mkdir -p backups
    
    # Gerar nome do backup com timestamp
    backup_file="backups/astrology_backup_$(date +%Y%m%d_%H%M%S).sql"
    
    print_message "Exportando dados para $backup_file"
    
    # Executar backup
    docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U astrology_user -d astrology_prod > "$backup_file"
    
    # Comprimir backup
    gzip "$backup_file"
    backup_file="${backup_file}.gz"
    
    print_success "Backup realizado com sucesso: $backup_file"
    print_message "Tamanho do backup: $(du -h "$backup_file" | cut -f1)"
}

# Função para restaurar backup
restore_prod() {
    if [ -z "$1" ]; then
        print_error "Por favor, especifique o arquivo de backup para restaurar"
        echo "Uso: $0 restore <arquivo_backup.sql.gz>"
        exit 1
    fi
    
    local backup_file="$1"
    
    if [ ! -f "$backup_file" ]; then
        print_error "Arquivo de backup não encontrado: $backup_file"
        exit 1
    fi
    
    print_warning "Esta ação irá sobrescrever o banco de dados de produção com os dados do backup."
    read -p "Continuar? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "Restaurando banco de dados de produção..."
        
        # Carregar variáveis de ambiente de produção
        export $(grep -v '^#' .env.production | xargs)
        
        # Descomprimir backup se estiver comprimido
        if [[ "$backup_file" == *.gz ]]; then
            print_message "Descomprimindo backup..."
            gunzip -k "$backup_file"
            backup_file=$(echo "$backup_file" | sed 's/\.gz$//')
        fi
        
        # Parar o serviço da API para evitar uso do banco durante a restauração
        print_message "Parando serviço da API..."
        docker-compose -f docker-compose.prod.yml stop api
        
        # Restaurar banco de dados
        print_message "Restaurando banco de dados..."
        cat "$backup_file" | docker-compose -f docker-compose.prod.yml exec -T postgres psql -U astrology_user -d astrology_prod
        
        # Reiniciar o serviço da API
        print_message "Reiniciando serviço da API..."
        docker-compose -f docker-compose.prod.yml start api
        
        print_success "Restauração concluída com sucesso!"
        
        # Limpar arquivo temporário se foi descomprimido
        if [[ "$1" == *.gz ]]; then
            rm "$backup_file"
        fi
    else
        print_message "Operação cancelada."
    fi
}

# Função para escalar serviços
scale_service() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        print_error "Por favor, especifique o serviço e o número de réplicas"
        echo "Uso: $0 scale <serviço> <replicas>"
        exit 1
    fi
    
    local service="$1"
    local replicas="$2"
    
    # Carregar variáveis de ambiente de produção
    export $(grep -v '^#' .env.production | xargs)
    
    print_message "Escalando serviço $service para $replicas réplicas..."
    
    # Escalar serviço
    docker-compose -f docker-compose.prod.yml up -d --scale "$service=$replicas"
    
    # Verificar status
    status_prod
    
    print_success "Serviço $service escalado para $replicas réplicas!"
}

# Função para verificar saúde da API
check_health() {
    print_message "Verificando saúde da API..."
    
    # Tentar obter o host da API do .env.production
    API_HOST=$(grep -E '^API_HOST=' .env.production | cut -d'=' -f2)
    if [ -z "$API_HOST" ]; then
        API_HOST="api.astrologia.br"
    fi
    
    # Fazer requisição para o endpoint de saúde
    for i in {1..5}; do
        if curl -f -s "https://$API_HOST/health" > /dev/null; then
            health_response=$(curl -s "https://$API_HOST/health")
            print_success "API saudável: $health_response"
            return 0
        else
            print_warning "Tentativa $i/5: API não saudável"
            sleep 5
        fi
    done
    
    print_error "API não está saudável após 5 tentativas"
    exit 1
}

# Verificar argumento
case "${1:-help}" in
    deploy)
        deploy_prod
        ;;
    update)
        update_prod
        ;;
    rollback)
        rollback_prod
        ;;
    status)
        status_prod
        ;;
    logs)
        view_logs "${2:-api}"
        ;;
    shell)
        access_shell "${2:-api}"
        ;;
    test)
        run_smoke_test
        ;;
    backup)
        backup_prod
        ;;
    restore)
        restore_prod "${2}"
        ;;
    scale)
        scale_service "${2}" "${3}"
        ;;
    health)
        check_health
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