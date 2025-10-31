# 🚀 Guia de Deploy - API de Astrologia Brasileira

Este guia ensina como fazer deploy da API de Astrologia Brasileira em diferentes plataformas: VPS, Railway e outras opções gratuitas.

## 📋 Pré-requisitos

Antes de começar, você precisa de:

### 🔑 Credenciais Necessárias
- **GeoNames API Key**: [Obter em https://www.geonames.org/login](https://www.geonames.org/login)
- **GitHub Account**: Para Railway e outras plataformas
- **Docker Hub Account**: Para VPS (opcional)

### 🛠️ Configurações Locais
```bash
# 1. Clonar o repositório
git clone https://github.com/prof-ramos/keriramos-main.git
cd keriramos-main

# 2. Configurar variáveis de ambiente
cp .env.example .env
nano .env

# 3. Testar localmente
make dev
```

### 📊 Variáveis de Ambiente Essenciais
```bash
# API Keys
GEONAMES_USERNAME=your_geonames_username

# Segurança
SECRET_KEY=your_256_bit_secret_key_here
DEBUG=false

# Database (para produção)
DATABASE_URL=postgresql://user:pass@host:5432/db

# Redis (para produção)
REDIS_URL=redis://host:6379
```

---

## 🖥️ Opção 1: Deploy em VPS (Recomendado)

### Pré-requisitos da VPS
- **Ubuntu 20.04+** ou **Debian 11+**
- **2GB RAM mínimo** (4GB recomendado)
- **1 vCPU mínimo** (2 vCPU recomendado)
- **20GB SSD mínimo**
- **Docker e Docker Compose** instalados

### Passos de Deploy

#### 1. Preparar a VPS
```bash
# Conectar via SSH
ssh user@your-vps-ip

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Reiniciar sessão
exit
ssh user@your-vps-ip
```

#### 2. Configurar o Projeto
```bash
# Clonar repositório
git clone https://github.com/prof-ramos/keriramos-main.git
cd keriramos-main

# Criar arquivo de produção
cp .env.example .env.prod
nano .env.prod
```

#### 3. Configurar Banco de Dados
```bash
# Instalar PostgreSQL (ou usar managed database)
sudo apt install postgresql postgresql-contrib -y

# Configurar PostgreSQL
sudo -u postgres psql
CREATE DATABASE astrology_prod;
CREATE USER astrology_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE astrology_prod TO astrology_user;
\q
```

#### 4. Configurar Redis
```bash
# Instalar Redis
sudo apt install redis-server -y

# Configurar Redis para produção
sudo nano /etc/redis/redis.conf
# Adicionar:
# requirepass your_redis_password
# maxmemory 256mb
# maxmemory-policy allkeys-lru

# Reiniciar Redis
sudo systemctl restart redis-server
```

#### 5. Configurar Nginx + SSL
```bash
# Instalar Nginx
sudo apt install nginx certbot python3-certbot-nginx -y

# Configurar Nginx
sudo nano /etc/nginx/sites-available/astrologia-br
```

Conteúdo do arquivo Nginx:
```nginx
server {
    listen 80;
    server_name api.astrologia.br www.astrologia.br;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name grafana.astrologia.br;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Ativar site
sudo ln -s /etc/nginx/sites-available/astrologia-br /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Configurar SSL (Let's Encrypt)
sudo certbot --nginx -d api.astrologia.br -d www.astrologia.br -d grafana.astrologia.br
```

#### 6. Deploy com Docker
```bash
# Configurar variáveis de ambiente
export GEONAMES_USERNAME=your_username
export SECRET_KEY=your_secret_key
export DATABASE_URL=postgresql://astrology_user:password@localhost:5432/astrology_prod
export REDIS_URL=redis://localhost:6379

# Deploy
docker-compose -f docker-compose.prod.yml up -d

# Verificar status
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs
```

#### 7. Configurar Firewall
```bash
# Configurar UFW
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Verificar status
sudo ufw status
```

#### 8. Configurar Backup Automático
```bash
# Criar script de backup
sudo nano /usr/local/bin/backup-astrologia.sh
```

Conteúdo do script:
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/astrologia"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup do banco
docker exec astrologia-postgres pg_dump -U astrology_user astrology_prod > $BACKUP_DIR/db_$DATE.sql

# Backup do Redis
docker exec astrologia-redis redis-cli SAVE
docker cp astrologia-redis:/data/dump.rdb $BACKUP_DIR/redis_$DATE.rdb

# Comprimir
tar -czf $BACKUP_DIR/backup_$DATE.tar.gz -C $BACKUP_DIR db_$DATE.sql redis_$DATE.rdb

# Limpar arquivos antigos (manter últimos 7 dias)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.rdb" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/backup_$DATE.tar.gz"
```

```bash
# Tornar executável e configurar cron
sudo chmod +x /usr/local/bin/backup-astrologia.sh
sudo crontab -e
# Adicionar: 0 2 * * * /usr/local/bin/backup-astrologia.sh
```

### URLs Após Deploy
- **API**: https://api.astrologia.br
- **Documentação**: https://api.astrologia.br/docs
- **Grafana**: https://grafana.astrologia.br

---

## 🚂 Opção 2: Deploy no Railway

Railway oferece deploy direto do GitHub com PostgreSQL e Redis incluídos.

### Passos de Deploy

#### 1. Preparar o Projeto
```bash
# Fork do repositório (opcional)
# Ou conectar repositório existente

# Criar railway.json na raiz do projeto
nano railway.json
```

Conteúdo do railway.json:
```json
{
  "build": {
    "builder": "dockerfile"
  },
  "deploy": {
    "startCommand": "uvicorn main:app --host 0.0.0.0 --port $PORT"
  }
}
```

#### 2. Configurar no Railway
1. **Acesse** [railway.app](https://railway.app)
2. **Login** com GitHub
3. **Clique** "New Project" → "Deploy from GitHub"
4. **Selecione** seu repositório
5. **Configure** variáveis de ambiente

#### 3. Adicionar Banco de Dados
```bash
# No Railway dashboard:
# 1. Add → Database → PostgreSQL
# 2. Add → Database → Redis
```

#### 4. Configurar Variáveis de Ambiente
```bash
# No Railway dashboard → Variables
GEONAMES_USERNAME=your_geonames_username
SECRET_KEY=your_secret_key
DEBUG=false
# DATABASE_URL será configurado automaticamente
# REDIS_URL será configurado automaticamente
```

#### 5. Deploy
```bash
# Railway faz deploy automático ao push
git add .
git commit -m "feat: Railway deployment configuration"
git push origin main
```

### URLs no Railway
- **API**: `https://your-project-name.up.railway.app`
- **Documentação**: `https://your-project-name.up.railway.app/docs`

### Limites do Plano Gratuito
- **512MB RAM**
- **1GB Disk**
- **512 horas/mês** (dorme após inatividade)
- **1GB bandwidth/mês**

---

## ☁️ Opção 3: Deploy no Render

Render oferece deploy direto do GitHub com PostgreSQL gratuito.

### Passos de Deploy

#### 1. Preparar Dockerfile para Render
```bash
# O Dockerfile existente já funciona no Render
# Verificar se está otimizado para produção
```

#### 2. Configurar no Render
1. **Acesse** [render.com](https://render.com)
2. **Login** com GitHub
3. **Clique** "New" → "Web Service"
4. **Conectar** repositório GitHub
5. **Configurar** serviço

#### 3. Configurações do Serviço
```yaml
# Service Settings:
Name: astrologia-br-api
Environment: Docker
Branch: main
Build Command: docker build -t astrologia-br .
Start Command: docker run -p $PORT:8000 astrologia-br
```

#### 4. Adicionar PostgreSQL
```yaml
# Add → PostgreSQL
Name: astrologia-br-db
Database: astrologia_prod
User: astrology_user
```

#### 5. Configurar Environment Variables
```bash
GEONAMES_USERNAME=your_geonames_username
SECRET_KEY=your_secret_key
DATABASE_URL=${DATABASE_URL}  # Render fornece automaticamente
DEBUG=false
```

### URLs no Render
- **API**: `https://astrologia-br-api.onrender.com`
- **Documentação**: `https://astrologia-br-api.onrender.com/docs`

### Limites do Plano Gratuito
- **750 horas/mês**
- **750GB outbound bandwidth**
- **Dorme após 15 minutos** de inatividade

---

## 🛩️ Opção 4: Deploy no Fly.io

Fly.io oferece deploy global com excelente performance.

### Passos de Deploy

#### 1. Instalar Fly CLI
```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh

# Login
fly auth login
```

#### 2. Inicializar Projeto
```bash
cd keriramos-main
fly launch

# Responda as perguntas:
# - App name: astrologia-br-api
# - Region: São Paulo (gru) ou Miami (mia)
# - PostgreSQL: Yes
# - Redis: Yes
```

#### 3. Configurar fly.toml
```toml
app = "astrologia-br-api"
primary_region = "gru"

[build]
  dockerfile = "Dockerfile"

[env]
  DEBUG = "false"

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 1024
```

#### 4. Configurar Secrets
```bash
fly secrets set GEONAMES_USERNAME=your_username
fly secrets set SECRET_KEY=your_secret_key
```

#### 5. Deploy
```bash
fly deploy
```

### URLs no Fly.io
- **API**: `https://astrologia-br-api.fly.dev`
- **Documentação**: `https://astrologia-br-api.fly.dev/docs`

### Limites do Plano Gratuito
- **3 apps**
- **160GB outbound bandwidth/mês**
- **Dorme após inatividade**

---

## 🔧 Opção 5: Deploy no Heroku

Heroku é uma opção clássica, embora tenha mudado seu modelo gratuito.

### Passos de Deploy

#### 1. Instalar Heroku CLI
```bash
# macOS
brew install heroku/brew/heroku

# Login
heroku login
```

#### 2. Preparar para Heroku
```bash
# Criar Procfile
echo "web: uvicorn main:app --host 0.0.0.0 --port \$PORT" > Procfile

# Criar requirements.txt (se não existir)
pip freeze > requirements.txt
```

#### 3. Criar App no Heroku
```bash
heroku create astrologia-br-api

# Adicionar PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Adicionar Redis
heroku addons:create heroku-redis:hobby-dev
```

#### 4. Configurar Environment Variables
```bash
heroku config:set GEONAMES_USERNAME=your_username
heroku config:set SECRET_KEY=your_secret_key
heroku config:set DEBUG=false
```

#### 5. Deploy
```bash
git push heroku main
```

### URLs no Heroku
- **API**: `https://astrologia-br-api.herokuapp.com`
- **Documentação**: `https://astrologia-br-api.herokuapp.com/docs`

---

## 📊 Comparação de Plataformas

| Plataforma | Gratuito | Performance | Escalabilidade | Setup Complexity |
|------------|----------|-------------|----------------|------------------|
| **VPS** | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Railway** | ✅ (512MB) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Render** | ✅ (750h) | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Fly.io** | ✅ (3 apps) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Heroku** | ❌ (2022) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |

---

## 🔍 Monitoramento e Logs

### Para Todas as Plataformas

#### 1. Health Checks
```bash
# Verificar se API está respondendo
curl https://your-domain.com/health

# Verificar documentação
curl https://your-domain.com/docs
```

#### 2. Logs
```bash
# Railway
railway logs

# Render
render logs

# Fly.io
fly logs

# VPS
docker-compose -f docker-compose.prod.yml logs -f api
```

#### 3. Métricas
- **API Response Time**: `/metrics` endpoint
- **Database Connections**: Verificar no provider
- **Error Rates**: Monitorar logs

---

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. API Não Carrega
```bash
# Verificar se container está rodando
docker ps

# Verificar logs
docker-compose logs api

# Verificar variáveis de ambiente
docker exec astrologia-api env
```

#### 2. Database Connection Error
```bash
# Verificar conexão com banco
docker exec astrologia-postgres pg_isready -U astrology_user -d astrology_prod

# Verificar DATABASE_URL
echo $DATABASE_URL
```

#### 3. SSL Certificate Issues
```bash
# Renovar certificado Let's Encrypt
sudo certbot renew

# Verificar certificado
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
```

#### 4. Memory Issues
```bash
# Verificar uso de memória
docker stats

# Ajustar limites no docker-compose
deploy:
  resources:
    limits:
      memory: 512M
```

---

## 💰 Custos Estimados

### VPS (Recomendado para Produção)
- **DigitalOcean**: $6/mês (1GB RAM, 1 vCPU)
- **Linode**: $5/mês (1GB RAM, 1 vCPU)
- **Vultr**: $2.50/mês (512MB RAM, 1 vCPU)

### Plataformas Gratuitas
- **Railway**: $0 (até limites)
- **Render**: $0 (até limites)
- **Fly.io**: $0 (até limites)

### Custos Adicionais
- **Domínio**: $10-20/ano
- **SSL**: Gratuito (Let's Encrypt)
- **Backup**: $5-10/mês (opcional)

---

## 🎯 Recomendações

### Para Desenvolvimento/Teste
- **Railway** ou **Render**: Setup rápido, gratuito

### Para Produção Pequena
- **VPS** (DigitalOcean/Linode): Controle total, custo baixo
- **Fly.io**: Performance excelente, deploy global

### Para Produção Escalável
- **VPS** com Docker Swarm ou Kubernetes
- **Railway** ou **Render** com planos pagos

---

## 📞 Suporte

Para problemas específicos:

- **VPS**: Verificar logs do Docker e Nginx
- **Railway**: Dashboard do Railway e documentação
- **Render**: Logs no dashboard e suporte
- **Fly.io**: `fly logs` e documentação
- **Heroku**: `heroku logs` e suporte

**Documentação da API**: Sempre disponível em `/docs` após deploy

---

**Última atualização**: Janeiro 2024</content>
</xai:function_call">Create comprehensive deployment guide for multiple platforms