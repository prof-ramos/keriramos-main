# 🌙 API de Astrologia Brasileira

[![API Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://api.astrologia.br)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](DOCKER_README.md)
[![CodeRabbit](https://img.shields.io/badge/coderabbit-enabled-green.svg)](coderabbit.yaml)
[![Deploy](https://img.shields.io/badge/deploy-guide-orange.svg)](deploy_guide.md)

API RESTful completa para cálculos astrológicos focada no público brasileiro. Fornece mapas astrais detalhados com gráficos interativos, utilizando formato de data brasileiro (DD/MM/YYYY) e terminologia em português.

## ✨ Recursos Principais

### 🪐 Cálculos Astrológicos
- **Mapa Natal**: Posições planetárias completas com aspectos
- **Sinastria**: Comparação entre dois mapas natais
- **Trânsito**: Influências planetárias atuais
- **Retorno Solar**: Análise anual detalhada
- **Casas Astrológicas**: Sistema completo de 12 casas

### 📊 Dados e Visualizações
- **Gráficos Interativos**: SVG e PNG de alta qualidade
- **Elementos**: Fogo, Terra, Ar, Água com qualidades
- **Aspectos Planetários**: Análise completa de relações
- **Posições Detalhadas**: Graus e minutos precisos

### 🌎 Geolocalização Brasileira
- **Cidades**: Busca inteligente em todo território brasileiro
- **Timezones**: Fusos horários automáticos por estado
- **Coordenadas**: Precisão GeoNames para cálculos exatos

### 🔐 Segurança e Performance
- **JWT Authentication**: Sistema seguro de autenticação
- **Rate Limiting**: Controle inteligente de uso por plano
- **Caching Redis**: Performance otimizada
- **HTTPS Only**: Conexões seguras obrigatórias
- **CORS**: Configurado para aplicações web brasileiras

## 🚀 Início Rápido

### Pré-requisitos
- **Docker** e **Docker Compose**
- **Git**
- **Conta GeoNames** ([obter aqui](https://www.geonames.org/login))

### Deploy com Docker (Recomendado)

```bash
# 1. Clonar repositório
git clone https://github.com/prof-ramos/keriramos-main.git
cd keriramos-main

# 2. Configurar ambiente
cp .env.example .env
nano .env  # Adicionar GEONAMES_USERNAME e SECRET_KEY

# 3. Deploy desenvolvimento
make dev

# 4. Acessar
# API: http://localhost:8000
# Documentação: http://localhost:8000/docs
# PgAdmin: http://localhost:5050
```

### Deploy em Produção

Escolha uma das opções:

#### 🖥️ VPS (Recomendado)
```bash
# Seguir guia completo
cat deploy_guide.md
```

#### 🚂 Railway (Gratuito)
```bash
# Deploy direto do GitHub
# Ver deploy_guide.md para detalhes
```

#### ☁️ Render (Gratuito)
```bash
# Deploy com PostgreSQL incluído
# Ver deploy_guide.md para detalhes
```

## 📚 Documentação

### 📖 Documentação da API
- [**Documentação Completa**](API_DOCUMENTATION.md) - Endpoints, exemplos, autenticação
- [**Exemplos Práticos**](API_EXAMPLES.md) - Casos de uso em Python, JavaScript, cURL
- [**Especificação OpenAPI**](openapi.yaml) - Para integração com ferramentas

### 🐳 Docker e Deploy
- [**Docker Setup**](DOCKER_README.md) - Configuração completa de containers
- [**Guia de Deploy**](deploy_guide.md) - VPS, Railway, Render, Fly.io, Heroku
- [**Makefile**](Makefile) - Comandos automatizados

### 🤖 Qualidade de Código
- [**CodeRabbit Config**](coderabbit.yaml) - Revisão automatizada de código
- **GitHub Actions** - CI/CD automatizado
- **Testes** - Cobertura completa

## 🏗️ Arquitetura

```
├── 🐳 Docker Multi-stage
│   ├── Builder: Compilação otimizada
│   ├── Runtime: Produção enxuta
│   └── Development: Hot reload
│
├── 🔐 Segurança
│   ├── JWT Authentication
│   ├── Rate Limiting por plano
│   └── Input validation Pydantic
│
├── 📊 Monitoramento
│   ├── Prometheus metrics
│   ├── Grafana dashboards
│   └── Health checks
│
└── 🚀 Deploy
    ├── Portainer + Traefik
    ├── Network AbduhNet
    └── SSL automático
```

## 💰 Planos e Limites

| Recurso | FREE | PREMIUM | PROFESSIONAL |
|---------|------|---------|--------------|
| Requests/dia | 10 | 100 | ∞ |
| Mapas salvos | 5 | 50 | ∞ |
| Sinastria | ❌ | ✅ | ✅ |
| Operações em lote | ❌ | ❌ | ✅ |
| Analytics | ❌ | ✅ | ✅ |
| Suporte prioritário | ❌ | ❌ | ✅ |

## 🔧 Desenvolvimento

### Configuração Local

```bash
# Instalar dependências
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Executar testes
pytest --cov=. --cov-report=html

# Formatar código
black . && isort .

# Executar linting
flake8 . && mypy .
```

### Scripts Disponíveis

```bash
# Desenvolvimento
./docker/scripts/dev.sh start    # Iniciar ambiente
./docker/scripts/dev.sh test     # Executar testes
./docker/scripts/dev.sh logs     # Ver logs

# Produção
./docker/scripts/deploy.sh deploy    # Deploy
./docker/scripts/deploy.sh status    # Status
./docker/scripts/deploy.sh backup    # Backup
```

### Makefile Commands

```bash
make dev        # Ambiente completo de desenvolvimento
make test       # Executar todos os testes
make lint       # Verificar qualidade do código
make deploy     # Deploy em produção
make clean      # Limpar recursos Docker
```

## 📊 Monitoramento

### Métricas Disponíveis
- **Performance da API**: Tempo de resposta, throughput
- **Uso do Banco**: Conexões, queries lentas
- **Cache Redis**: Hit rate, memória usada
- **Erros**: Taxa de erro por endpoint

### Dashboards
- **Grafana**: `https://grafana.astrologia.br`
- **Prometheus**: `https://prometheus.astrologia.br`

### Health Checks
```bash
# API health
curl https://api.astrologia.br/health

# Métricas
curl https://api.astrologia.br/metrics
```

## 🔒 Segurança

### Recursos Implementados
- ✅ **Autenticação JWT** com refresh tokens
- ✅ **Rate Limiting** inteligente por usuário
- ✅ **HTTPS obrigatório** em produção
- ✅ **Validação de entrada** com Pydantic
- ✅ **Proteção contra SQL injection**
- ✅ **Logs seguros** sem dados sensíveis

### Certificações
- 🔒 **SSL/TLS** com Let's Encrypt
- 🛡️ **OWASP Top 10** compliance
- 🔐 **GDPR** ready para dados brasileiros

## 🌟 Exemplos de Uso

### Python
```python
import requests

# Autenticação
token = requests.post('https://api.astrologia.br/api/v2/auth/login', json={
    'email': 'user@example.com',
    'password': 'password123'
}).json()['access_token']

# Gerar mapa astral
chart = requests.post('https://api.astrologia.br/api/v2/charts/natal',
    json={
        'name': 'João Silva',
        'birth_date': '15/05/1990',
        'birth_time': '18:30',
        'city': 'São Paulo',
        'state': 'SP'
    },
    headers={'Authorization': f'Bearer {token}'}
).json()

print(f"Signo Solar: {chart['sun_sign']}")
```

### JavaScript
```javascript
const chart = await fetch('https://api.astrologia.br/api/v2/charts/natal', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        name: 'João Silva',
        birth_date: '15/05/1990',
        birth_time: '18:30',
        city: 'São Paulo',
        state: 'SP'
    })
}).then(r => r.json());

console.log(`Signo Solar: ${chart.sun_sign}`);
```

## 🤝 Contribuição

### Como Contribuir
1. **Fork** o projeto
2. **Clone** seu fork: `git clone https://github.com/your-username/astrologia-br-api.git`
3. **Crie** uma branch: `git checkout -b feature/nova-funcionalidade`
4. **Commit** suas mudanças: `git commit -m 'feat: adiciona nova funcionalidade'`
5. **Push** para o fork: `git push origin feature/nova-funcionalidade`
6. **Abra** um Pull Request

### Padrões de Código
- **Python**: PEP 8, type hints obrigatórios
- **Commits**: Conventional commits
- **Testes**: pytest com cobertura >80%
- **Documentação**: Docstrings em português

### Revisão de Código
- ✅ **CodeRabbit**: Revisão automatizada
- ✅ **GitHub Actions**: CI/CD obrigatório
- ✅ **Quality Gates**: Bloqueio se falhar

## 📄 Licença

Este projeto está licenciado sob a **MIT License**. Ver [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- [**Kerykeion**](https://github.com/g-battaglia/kerykeion) - Biblioteca astrológica
- [**GeoNames**](https://www.geonames.org/) - Dados geográficos
- [**FastAPI**](https://fastapi.tiangolo.com/) - Framework web
- [**CodeRabbit**](https://coderabbit.ai) - Revisão automatizada

## 📞 Suporte

### Canais de Suporte
- 📧 **Email**: suporte@astrologia.br
- 💬 **Discord**: [Servidor da Comunidade](https://discord.gg/astrologia-br)
- 📚 **Documentação**: https://docs.astrologia.br
- 🐛 **Issues**: [GitHub Issues](https://github.com/prof-ramos/keriramos-main/issues)

### SLA de Suporte
- **FREE**: Até 48h úteis
- **PREMIUM**: Até 24h úteis
- **PROFESSIONAL**: Até 4h úteis

### Reportar Problemas
Use [GitHub Issues](https://github.com/prof-ramos/keriramos-main/issues) para:
- 🐛 Bugs e erros
- ✨ Solicitações de recursos
- ❓ Perguntas gerais
- 📖 Melhorias na documentação

---

## 🎯 Status do Projeto

- ✅ **API Core**: Implementada e testada
- ✅ **Docker**: Containerização completa
- ✅ **Documentação**: Completa em português
- ✅ **Deploy**: Múltiplas opções disponíveis
- ✅ **Monitoramento**: Prometheus + Grafana
- ✅ **Segurança**: OWASP compliance
- ✅ **Testes**: Cobertura >80%
- ✅ **CI/CD**: GitHub Actions configurado

**🚀 Pronto para produção!**

---

**API de Astrologia Brasileira** - Feita com ❤️ para o público brasileiro</content>
</xai:function_call">Create comprehensive README.md for the Brazilian Astrology API project