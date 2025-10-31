# API de Astrologia Brasileira

[![API Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://api.astrologia.br)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-stable-brightgreen.svg)](https://status.astrologia.br)

API RESTful completa para cálculos astrológicos focada no público brasileiro. Fornece mapas astrais detalhados com gráficos interativos, utilizando formato de data brasileiro (DD/MM/YYYY).

## 🚀 Início Rápido

### 1. Obter Token de Acesso

```bash
# Registrar usuário
curl -X POST https://api.astrologia.br/api/v2/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seu@email.com",
    "password": "sua_senha",
    "name": "Seu Nome",
    "plan": "free"
  }'

# Fazer login
curl -X POST https://api.astrologia.br/api/v2/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seu@email.com",
    "password": "sua_senha"
  }'
```

### 2. Gerar Primeiro Mapa Astral

```bash
curl -X POST https://api.astrologia.br/api/v2/charts/natal \
  -H "Authorization: Bearer SEU_TOKEN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Silva",
    "birth_date": "15/05/1990",
    "birth_time": "18:30",
    "city": "São Paulo",
    "state": "SP"
  }'
```

## 📋 Índice

- [Recursos](#-recursos)
- [Planos e Limites](#-planos-e-limites)
- [Instalação e Setup](#-instalação-e-setup)
- [Documentação da API](#-documentação-da-api)
- [Exemplos de Uso](#-exemplos-de-uso)
- [SDKs Disponíveis](#-sdks-disponíveis)
- [Tratamento de Erros](#-tratamento-de-erros)
- [Suporte](#-suporte)

## ✨ Recursos

### 🪐 Cálculos Astrológicos
- **Mapa Natal**: Posições planetárias completas
- **Sinastria**: Comparação entre dois mapas
- **Trânsito**: Influências planetárias atuais
- **Retorno Solar**: Análise anual
- **Aspectos**: Relações entre planetas
- **Casas Astrológicas**: Divisão do mapa

### 📊 Dados e Visualizações
- **Gráficos Interativos**: SVG e PNG
- **Posições Detalhadas**: Graus e minutos
- **Elementos**: Fogo, Terra, Ar, Água
- **Qualidades**: Cardinal, Fixo, Mutável

### 🌎 Geolocalização Brasileira
- **Cidades**: Busca inteligente por nome
- **Estados**: Timezones automáticos
- **Coordenadas**: Precisão GeoNames
- **Fusos Horários**: Suporte completo ao Brasil

### 🔐 Segurança e Performance
- **JWT Authentication**: Tokens seguros
- **Rate Limiting**: Controle de uso por plano
- **Caching**: Redis para alta performance
- **HTTPS Only**: Conexões seguras
- **CORS**: Suporte a aplicações web

## 💰 Planos e Limites

| Recurso | FREE | PREMIUM | PROFESSIONAL |
|---------|------|---------|--------------|
| Requests/dia | 10 | 100 | ∞ |
| Requests/minuto | 10 | 100 | 1000 |
| Mapas salvos | 5 | 50 | ∞ |
| Sinastria | ❌ | ✅ | ✅ |
| Operações em lote | ❌ | ❌ | ✅ |
| Analytics | ❌ | ✅ | ✅ |
| Webhooks | ❌ | ✅ | ✅ |
| Suporte prioritário | ❌ | ❌ | ✅ |

## 🛠️ Instalação e Setup

### Pré-requisitos
- Python 3.8+
- pip ou uv
- Conta no GeoNames (para desenvolvimento local)

### Instalação Local

```bash
# Clonar repositório
git clone https://github.com/astrologia-br/api.git
cd api

# Instalar dependências
pip install -r requirements.txt

# Ou usando uv (recomendado)
uv pip install -r requirements.txt

# Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas chaves
```

### Configuração

```bash
# Variáveis obrigatórias
GEONAMES_USERNAME=seu_username_geonames
SECRET_KEY=sua_chave_secreta_jwt
REDIS_URL=redis://localhost:6379

# Opcionais
DEBUG=true
DATABASE_URL=postgresql://user:pass@localhost/astrologia
```

### Executar Localmente

```bash
# Desenvolvimento
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Produção
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## 📚 Documentação da API

### Documentação Interativa
- **Swagger UI**: https://api.astrologia.br/docs
- **ReDoc**: https://api.astrologia.br/redoc
- **OpenAPI 3.0**: https://api.astrologia.br/openapi.json

### Arquivos de Documentação
- [`API_DOCUMENTATION.md`](./API_DOCUMENTATION.md) - Documentação completa
- [`API_EXAMPLES.md`](./API_EXAMPLES.md) - Exemplos práticos
- [`openapi.yaml`](./openapi.yaml) - Especificação OpenAPI

### Endpoints Principais

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | `/api/v2/charts/natal` | Gerar mapa natal |
| POST | `/api/v2/charts/synastry` | Comparação sinástrica |
| GET | `/api/v2/charts/{id}` | Recuperar mapa salvo |
| POST | `/api/v2/auth/login` | Autenticação JWT |
| GET | `/api/v2/locations/cities` | Buscar cidades |
| POST | `/api/v2/batch/charts` | Operações em lote |

## 💻 Exemplos de Uso

### Python
```python
import requests

# Autenticação
response = requests.post('https://api.astrologia.br/api/v2/auth/login', json={
    'email': 'user@example.com',
    'password': 'password123'
})
token = response.json()['access_token']

# Gerar mapa
headers = {'Authorization': f'Bearer {token}'}
chart = requests.post('https://api.astrologia.br/api/v2/charts/natal',
    json={
        'name': 'João Silva',
        'birth_date': '15/05/1990',
        'birth_time': '18:30',
        'city': 'São Paulo',
        'state': 'SP'
    },
    headers=headers
).json()

print(f"Signo Solar: {chart['sun_sign']}")
```

### JavaScript
```javascript
// Usando fetch
const token = await login();
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

### cURL
```bash
# Login
TOKEN=$(curl -s -X POST https://api.astrologia.br/api/v2/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}' \
  | jq -r '.access_token')

# Gerar mapa
curl -X POST https://api.astrologia.br/api/v2/charts/natal \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Silva",
    "birth_date": "15/05/1990",
    "birth_time": "18:30",
    "city": "São Paulo",
    "state": "SP"
  }'
```

## 📦 SDKs Disponíveis

### SDK Python
```bash
pip install astrologia-br-sdk
```

```python
from astrologia_br import AstrologiaBR

client = AstrologiaBR(api_key='your_api_key')
chart = client.charts.create_natal(
    name='João Silva',
    birth_date='15/05/1990',
    birth_time='18:30',
    city='São Paulo',
    state='SP'
)
```

### SDK JavaScript
```bash
npm install astrologia-br-sdk
```

```javascript
import { AstrologiaBR } from 'astrologia-br-sdk';

const client = new AstrologiaBR({ apiKey: 'your_api_key' });
const chart = await client.charts.createNatal({
    name: 'João Silva',
    birthDate: '15/05/1990',
    birthTime: '18:30',
    city: 'São Paulo',
    state: 'SP'
});
```

## ⚠️ Tratamento de Erros

### Códigos de Status HTTP

| Código | Descrição | Tratamento |
|--------|-----------|------------|
| 200 | Sucesso | Processar resposta |
| 201 | Criado | Recurso criado |
| 202 | Aceito | Operação assíncrona |
| 400 | Dados inválidos | Verificar entrada |
| 401 | Não autorizado | Renovar token |
| 403 | Proibido | Verificar permissões |
| 404 | Não encontrado | Verificar ID |
| 409 | Conflito | Recurso já existe |
| 422 | Lógica inválida | Verificar regras |
| 429 | Rate limit | Aguardar e tentar novamente |
| 500 | Erro interno | Reportar ao suporte |

### Exemplo de Tratamento
```python
try:
    response = requests.post(url, json=data, headers=headers)
    response.raise_for_status()
    return response.json()
except requests.exceptions.HTTPError as e:
    error = e.response.json()
    if e.response.status_code == 429:
        retry_after = error.get('details', {}).get('retry_after_seconds', 60)
        print(f"Rate limit. Tentar em {retry_after}s")
    else:
        print(f"Erro: {error['message']}")
except Exception as e:
    print(f"Erro de conexão: {str(e)}")
```

## 🔧 Desenvolvimento

### Estrutura do Projeto
```
├── main.py                 # Aplicação FastAPI principal
├── models.py               # Modelos Pydantic
├── chart_generator.py      # Gerador de gráficos
├── geonames_client.py      # Cliente GeoNames
├── API_DOCUMENTATION.md    # Documentação completa
├── API_EXAMPLES.md         # Exemplos práticos
├── openapi.yaml           # Especificação OpenAPI
├── requirements.txt       # Dependências Python
└── README_API.md          # Este arquivo
```

### Executar Testes
```bash
# Instalar dependências de desenvolvimento
pip install -r requirements-dev.txt

# Executar testes
pytest

# Com cobertura
pytest --cov=. --cov-report=html
```

### Contribuir
1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📞 Suporte

### Canais de Suporte
- **📧 Email**: suporte@astrologia.br
- **💬 Chat**: https://chat.astrologia.br
- **📚 Documentação**: https://docs.astrologia.br
- **📊 Status**: https://status.astrologia.br

### Reportar Problemas
Use o [GitHub Issues](https://github.com/astrologia-br/api/issues) para:
- Bugs e erros
- Solicitações de recursos
- Perguntas gerais

### SLA de Suporte
- **FREE**: Até 48h úteis
- **PREMIUM**: Até 24h úteis
- **PROFESSIONAL**: Até 4h úteis

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## 🙏 Agradecimentos

- [Kerykeion](https://github.com/g-battaglia/kerykeion) - Biblioteca astrológica
- [GeoNames](https://www.geonames.org/) - Dados geográficos
- [FastAPI](https://fastapi.tiangolo.com/) - Framework web

---

**API de Astrologia Brasileira** - Feita com ❤️ para o público brasileiro