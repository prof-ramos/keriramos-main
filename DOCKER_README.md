# Docker Setup - API de Astrologia Brasileira

Este documento descreve como configurar e usar o ambiente Docker para desenvolvimento e produção da API de Astrologia Brasileira.

## 📋 Índice

- [Pré-requisitos](#-pré-requisitos)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Desenvolvimento Local](#-desenvolvimento-local)
- [Deploy em Produção](#-deploy-em-produção)
- [Monitoramento](#-monitoramento)
- [Troubleshooting](#-troubleshooting)
- [Scripts Disponíveis](#-scripts-disponíveis)

## 🔧 Pré-requisitos

- **Docker**: Versão 20.10 ou superior
- **Docker Compose**: Versão 2.0 ou superior
- **Portainer**: Para gerenciamento em produção
- **Git**: Para controle de versão

### Verificar Instalação

```bash
# Verificar Docker
docker --version
docker-compose --version

# Verificar se Docker está rodando
docker info
```

## 🏗️ Estrutura do Projeto

```
├── Dockerfile                    # Multi-stage build
├── docker-compose.yml           # Ambiente de desenvolvimento
├── docker-compose.prod.yml      # Ambiente de produção
├── .dockerignore               # Otimização do build context
├── .env.example                # Template de variáveis de ambiente
├── docker/
│   ├── redis/
│   │   ├── redis.conf          # Config Redis desenvolvimento
│   │   └── redis.prod.conf     # Config Redis produção
│   ├── postgres/
│   │   └── init.sql            # Inicialização do banco
│   ├── nginx/
│   │   └── nginx.conf          # Configuração Nginx (removido)
│   └── monitoring/
│       ├── prometheus.yml      # Configuração Prometheus
│       └── grafana/
│           ├── provisioning/
│           │   ├── datasources/
│           │   │   └── prometheus.yml
│           │   └── dashboards/
│           │       └── dashboard.yml
│           └── dashboards/
│               └── api-overview.json
└── docker/scripts/
    ├── dev.sh                  # Script de desenvolvimento
    └── deploy.sh               # Script de produção
```

## 🚀 Desenvolvimento Local

### 1. Clonagem e Configuração

```bash
# Clonar repositório
git clone <repository-url>
cd astrology-api

# Copiar arquivo de ambiente
cp .env.example .env

# Editar variáveis de ambiente
nano .env
```

### 2. Configuração das Variáveis de Ambiente

Edite o arquivo `.env` com suas configurações:

```bash
# API Keys necessárias
GEONAMES_USERNAME=your_geonames_username
SECRET_KEY=your_jwt_secret_key

# Database (padrão para desenvolvimento)
POSTGRES_DB=astrology_dev
POSTGRES_USER=astrology_user
POSTGRES_PASSWORD=astrology_pass
```

### 3. Iniciar Ambiente de Desenvolvimento

```bash
# Usando script de desenvolvimento
./docker/scripts/dev.sh start

# Ou diretamente com docker-compose
docker-compose up -d --build
```

### 4. Verificar Serviços

Após iniciar, os serviços estarão disponíveis em:

- **API**: http://localhost:8000
- **Documentação API**: http://localhost:8000/docs
- **PgAdmin**: http://localhost:5050
  - Email: admin@astrologia.br
  - Senha: admin123
- **Redis Commander**: http://localhost:8081

### 5. Executar Testes

```bash
# Usando script
./docker/scripts/dev.sh test

# Ou diretamente
docker-compose exec api pytest --cov=. --cov-report=term-missing
```

### 6. Comandos Úteis para Desenvolvimento

```bash
# Ver logs
./docker/scripts/dev.sh logs api

# Entrar no container
./docker/scripts/dev.sh shell api

# Parar serviços
./docker/scripts/dev.sh stop

# Limpar tudo
./docker/scripts/dev.sh clean
```

## 🏭 Deploy em Produção

### 1. Preparação

```bash
# Configurar variáveis de produção
cp .env.example .env.prod
nano .env.prod

# Variáveis críticas para produção:
GEONAMES_USERNAME=your_prod_geonames_username
SECRET_KEY=your_prod_jwt_secret_key
DATABASE_URL=postgresql://user:pass@prod-db-host:5432/astrology_prod
REDIS_URL=redis://prod-redis-host:6379
DEBUG=false
```

### 2. Deploy via Portainer

```bash
# Fazer build das imagens
docker-compose -f docker-compose.prod.yml build

# Deploy da stack no Portainer
# 1. Acesse o Portainer
# 2. Vá para "Stacks"
# 3. Clique em "Add stack"
# 4. Nome: astrology-api-prod
# 5. Upload do arquivo docker-compose.prod.yml
# 6. Configure as environment variables
# 7. Deploy
```

### 3. Verificar Deploy

```bash
# Verificar status dos serviços
docker stack ps astrology-api-prod

# Verificar logs
docker service logs astrology-api-prod_api
```

### 4. URLs de Produção

Após o deploy, a aplicação estará disponível em:

- **API**: https://api.astrologia.br
- **Documentação**: https://api.astrologia.br/docs
- **Grafana**: https://grafana.astrologia.br
- **Prometheus**: https://prometheus.astrologia.br

## 📊 Monitoramento

### Prometheus Metrics

A API expõe métricas em `/metrics` para monitoramento:

```bash
# Ver métricas da API
curl http://localhost:8000/metrics
```

### Grafana Dashboards

Acesse o Grafana em https://grafana.astrologia.br:

- **Usuário**: admin (ou configurado na env var)
- **Senha**: admin123 (ou configurado na env var)

Dashboard incluído:
- **Brazilian Astrology API Overview**: Métricas gerais da API

### Health Checks

```bash
# Health check da API
curl https://api.astrologia.br/health

# Health check detalhado
curl https://api.astrologia.br/api/v2/health
```

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Portas Já em Uso

```bash
# Verificar portas em uso
netstat -tulpn | grep :8000

# Mudar portas no docker-compose.yml
ports:
  - "8001:8000"  # Muda para porta 8001
```

#### 2. Erro de Conexão com Banco

```bash
# Verificar se PostgreSQL está rodando
docker-compose ps postgres

# Ver logs do PostgreSQL
docker-compose logs postgres

# Resetar banco de dados
docker-compose down -v
docker-compose up -d postgres
```

#### 3. Problemas de Memória

```bash
# Verificar uso de memória
docker stats

# Ajustar limites no docker-compose.yml
deploy:
  resources:
    limits:
      memory: 512M
```

#### 4. Cache do Docker

```bash
# Limpar cache do Docker
docker system prune -a

# Rebuild sem cache
docker-compose build --no-cache
```

### Logs e Debug

```bash
# Logs de todos os serviços
docker-compose logs

# Logs de um serviço específico
docker-compose logs api

# Logs com follow
docker-compose logs -f api

# Entrar no container para debug
docker-compose exec api /bin/bash
```

### Backup e Restore

```bash
# Backup do banco
docker exec astrology-postgres pg_dump -U astrology_user astrology_dev > backup.sql

# Restore do banco
docker exec -i astrology-postgres psql -U astrology_user astrology_dev < backup.sql
```

## 📜 Scripts Disponíveis

### Desenvolvimento (`docker/scripts/dev.sh`)

```bash
# Iniciar desenvolvimento
./docker/scripts/dev.sh start

# Parar desenvolvimento
./docker/scripts/dev.sh stop

# Executar testes
./docker/scripts/dev.sh test

# Ver logs
./docker/scripts/dev.sh logs api

# Entrar no shell
./docker/scripts/dev.sh shell api

# Limpar recursos
./docker/scripts/dev.sh clean
```

### Produção (`docker/scripts/deploy.sh`)

```bash
# Deploy para produção
./docker/scripts/deploy.sh deploy

# Atualizar serviços
./docker/scripts/deploy.sh update

# Ver status
./docker/scripts/deploy.sh status

# Fazer backup
./docker/scripts/deploy.sh backup

# Escalar serviços
./docker/scripts/deploy.sh scale api 3
```

## 🔒 Segurança

### Produção

- **Usuário não-root**: Containers rodam com usuário não privilegiado
- **Secrets**: Credenciais armazenadas em variáveis de ambiente
- **Network**: Serviços isolados na network AbduhNet
- **Updates**: Imagens atualizadas regularmente
- **Firewall**: Apenas portas necessárias expostas

### Desenvolvimento

- **Debug mode**: Ativado para desenvolvimento
- **CORS**: Configurado para origens locais
- **Secrets**: Valores padrão seguros para desenvolvimento

## 🚀 Otimizações

### Build

- **Multi-stage**: Imagens otimizadas para produção
- **Layer caching**: Build mais rápido com cache inteligente
- **Base images**: Imagens Alpine para tamanho reduzido

### Runtime

- **Health checks**: Monitoramento automático da saúde
- **Resource limits**: Controle de CPU e memória
- **Restart policies**: Recuperação automática de falhas

### Performance

- **Gzip compression**: Respostas comprimidas
- **Connection pooling**: Conexões otimizadas
- **Caching**: Redis para cache de dados

## 📞 Suporte

Para problemas com Docker:

1. **Verificar logs**: `docker-compose logs`
2. **Verificar status**: `docker-compose ps`
3. **Verificar recursos**: `docker stats`
4. **Limpar sistema**: `docker system prune`

### Recursos Úteis

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Portainer Documentation](https://docs.portainer.io/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

---

**Última atualização**: Janeiro 2024