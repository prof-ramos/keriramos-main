# Documentação de Deploy - API de Astrologia Brasileira

## Visão Geral

Este documento detalha os procedimentos necessários para deploy da API de Astrologia Brasileira em diferentes ambientes (desenvolvimento, staging, produção).

## Requisitos de Sistema

- Docker Engine (versão 20.10 ou superior)
- Docker Compose (versão 2.0 ou superior)
- Conta no GeoNames (necessária para geolocalização)
- Certificado SSL (para produção)

## Ambientes Disponíveis

### 1. Desenvolvimento

#### Setup Inicial
```bash
# 1. Clonar o repositório
git clone https://github.com/prof-ramos/keriramos-main.git
cd keriramos-main

# 2. Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas credenciais
```

#### Executar Ambiente de Desenvolvimento
```bash
# Iniciar todos os serviços
make up

# Alternativamente
docker-compose up -d

# Ver logs da API
make logs

# Executar em modo de desenvolvimento com hot-reload
docker-compose -f docker-compose.yml up api
```

### 2. Produção

#### Pré-requisitos de Produção

1. **Domínios Configurados**:
   - `api.astrologia.br` (ou domínio personalizado)
   - `grafana.astrologia.br`
   - `pgadmin.astrologia.br`
   - `portainer.astrologia.br`

2. **Credenciais Necessárias**:
   - Chave do GeoNames
   - Senhas fortes para todos os serviços
   - Endereço de e-mail para Let's Encrypt

#### Deploy em Produção

```bash
# 1. Configurar variáveis de ambiente para produção
cp .env.example .env.production
# Editar .env.production com credenciais de produção

# 2. Carregar variáveis de ambiente
export $(grep -v '^#' .env.production | xargs)

# 3. Fazer deploy completo
docker-compose -f docker-compose.prod.yml up -d

# 4. Verificar status dos serviços
docker-compose -f docker-compose.prod.yml ps

# 5. Ver logs da API em produção
docker-compose -f docker-compose.prod.yml logs api
```

#### Atualização de Produção

```bash
# 1. Backup do banco de dados
make backup

# 2. Parar serviços atuais
docker-compose -f docker-compose.prod.yml down

# 3. Atualizar imagens
docker-compose -f docker-compose.prod.yml pull

# 4. Iniciar novos serviços
docker-compose -f docker-compose.prod.yml up -d

# 5. Verificar saúde dos serviços
docker-compose -f docker-compose.prod.yml ps
```

#### Rollback de Produção

```bash
# 1. Parar serviços atuais
docker-compose -f docker-compose.prod.yml down

# 2. Iniciar versão anterior
docker-compose -f docker-compose.prod.yml up -d

# 3. Verificar status
docker-compose -f docker-compose.prod.yml ps
```

## Comandos de Gerenciamento

### Comandos Make (Recomendados)

```bash
# Iniciar ambiente de desenvolvimento
make up

# Parar ambiente de desenvolvimento
make down

# Reiniciar ambiente
make restart

# Ver logs do serviço API
make logs

# Ver logs de serviço específico
make logs-postgres

# Iniciar shell no container API
make shell

# Iniciar shell em serviço específico
make shell-postgres

# Executar testes
make test

# Fazer linting do código
make lint

# Formatador de código
make format

# Fazer deploy em produção
make deploy

# Ver status do deploy em produção
make deploy-status

# Fazer backup
make backup

# Limpar recursos Docker
make clean

# Informações do projeto
make info
```

### Comandos Docker Compose

```bash
# Listar serviços
docker-compose ps
docker-compose -f docker-compose.prod.yml ps

# Ver logs
docker-compose logs api
docker-compose -f docker-compose.prod.yml logs api

# Executar comando em container
docker-compose exec api bash
docker-compose -f docker-compose.prod.yml exec postgres pg_dump astrology_prod

# Ver uso de recursos
docker-compose top
docker-compose -f docker-compose.prod.yml top

# Redimensionar serviços
docker-compose up -d --scale api=3
docker-compose -f docker-compose.prod.yml up -d --scale api=3
```

### Comandos Docker

```bash
# Ver imagens
docker images

# Ver containers em execução
docker ps

# Ver todos os containers
docker ps -a

# Ver uso de recursos
docker stats

# Limpar sistema
docker system prune -a
```

## Monitoramento

### Endereços de Acesso

- **API**: `https://api.astrologia.br`
- **Traefik Dashboard**: `https://traefik.astrologia.br`
- **Grafana**: `https://grafana.astrologia.br`
- **Prometheus**: `https://prometheus.astrologia.br`
- **PgAdmin**: `https://pgadmin.astrologia.br`
- **Portainer**: `https://portainer.astrologia.br`

### Métricas Disponíveis

Os endpoints de métricas estão disponíveis em:

- API Health: `https://api.astrologia.br/health`
- API Metrics: `https://api.astrologia.br/metrics`
- Prometheus: `https://prometheus.astrologia.br`
- Grafana: `https://grafana.astrologia.br`

### Logs

- **API Logs**: Disponíveis via `docker-compose logs api`
- **PostgreSQL Logs**: Armazenados em `./logs/postgres/`
- **Sistema**: Monitorado via Portainer

## Segurança

### Práticas Recomendadas

1. **Segredos**:
   - Nunca armazene credenciais em código
   - Use variáveis de ambiente para senhas
   - Atualize regularmente as senhas

2. **Acesso**:
   - Use HTTPS em todos os serviços
   - Limite acesso a serviços de administração (PgAdmin, Portainer)
   - Configure firewalls apropriados

3. **Atualizações**:
   - Mantenha imagens Docker atualizadas
   - Aplique atualizações de segurança prontamente
   - Monitore vulnerabilidades

## Troubleshooting

### Problemas Comuns

#### 1. Erro de conexão com GeoNames
```bash
# Verificar variáveis de ambiente
docker-compose exec api env | grep GEONAMES

# Verificar logs da API
docker-compose logs api
```

#### 2. Erro de SSL/TLS
```bash
# Verificar certificados do Traefik
docker-compose exec traefik ls -la /etc/traefik/

# Verificar logs do Traefik
docker-compose logs traefik
```

#### 3. Problemas de performance
```bash
# Verificar uso de recursos
docker stats

# Verificar logs do Prometheus e Grafana
docker-compose logs prometheus
docker-compose logs grafana
```

### Comandos de Diagnóstico

```bash
# Verificar saúde da API
curl -X GET https://api.astrologia.br/health

# Verificar status do sistema
docker system df

# Verificar logs do Docker
docker info
docker version
```

## Backup e Restauração

### Backup

```bash
# Backup do banco de dados
docker-compose exec postgres pg_dump -U astrology_user astrology_prod > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup completo dos volumes
docker run --rm -v postgres_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/postgres_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .

# Backup com script Make
make backup
```

### Restauração

```bash
# Restaurar banco de dados
docker-compose exec -T postgres psql -U astrology_user astrology_prod < backup_file.sql
```

## Escalabilidade

### Escalando Serviços

```bash
# Escalar API para 3 réplicas
docker-compose -f docker-compose.prod.yml up -d --scale api=3

# Verificar réplicas
docker-compose -f docker-compose.prod.yml ps
```

### Configuração de Recursos

O arquivo `docker-compose.prod.yml` contém limites e reservas de recursos para cada serviço para garantir desempenho adequado e disponibilidade.

## Integração Contínua e Entrega Contínua (CI/CD)

### Comandos para CI
```bash
# Executar testes e linting
make ci
# Equivalente a:
make lint
make test
```

### Pipeline de Deploy

1. Código é enviado para o repositório
2. CI executa testes e verifica qualidade
3. Imagem Docker é construída e testada
4. Se aprovado, imagem é enviada para o registry
5. Serviço em produção é atualizado com zero downtime

## Variáveis de Ambiente

### Variáveis Obrigatórias

- `GEONAMES_USERNAME`: Usuário da API GeoNames
- `SECRET_KEY`: Chave secreta para JWT
- `POSTGRES_PASSWORD`: Senha do PostgreSQL
- `REDIS_PASSWORD`: Senha do Redis
- `ACME_EMAIL`: E-mail para certificados Let's Encrypt

### Variáveis Opcionais

- `API_HOST`: Host para a API (padrão: api.astrologia.br)
- `GRAFANA_HOST`: Host para Grafana (padrão: grafana.astrologia.br)
- `PROMETHEUS_HOST`: Host para Prometheus (padrão: prometheus.astrologia.br)
- `PGADMIN_HOST`: Host para PgAdmin (padrão: pgadmin.astrologia.br)
- `PORTAINER_HOST`: Host para Portainer (padrão: portainer.astrologia.br)

## Scripts de Gerenciamento

Os scripts estão localizados em `./docker/scripts/`:

- `dev.sh`: Gerenciamento do ambiente de desenvolvimento
- `deploy.sh`: Gerenciamento do ambiente de produção

## Suporte

Para suporte técnico, consulte:

- Documentação da API: `/docs` ou `/redoc`
- Issues no GitHub: https://github.com/prof-ramos/keriramos-main/issues
- Email: suporte@astrologia.br