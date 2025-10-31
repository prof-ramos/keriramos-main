# Documentação da API de Astrologia Brasileira

## Visão Geral

A API de Astrologia Brasileira é uma API RESTful completa para cálculos astrológicos focada no público brasileiro. Utiliza formato de data brasileiro (DD/MM/YYYY) e fornece mapas astrológicos detalhados com gráficos SVG/PNG.

**Base URL**: `https://api.astrologia.br`
**Versão**: 2.0.0
**Formato de Resposta**: JSON
**Autenticação**: JWT Bearer Token ou API Key

## Autenticação

### JWT Authentication
```bash
# Obter token
curl -X POST https://api.astrologia.br/api/v2/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'

# Usar token
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://api.astrologia.br/api/v2/charts/natal
```

### API Key Authentication
```bash
curl -H "X-API-Key: YOUR_API_KEY" \
  https://api.astrologia.br/api/v2/charts/natal
```

## Rate Limiting

- **FREE**: 10 requests/minuto
- **PREMIUM**: 100 requests/minuto
- **PROFESSIONAL**: 1000 requests/minuto
- **ADMIN**: Ilimitado

Headers de resposta incluem:
- `X-RateLimit-Limit`: Limite total
- `X-RateLimit-Remaining`: Requests restantes
- `X-RateLimit-Reset`: Timestamp de reset

## Endpoints da API

### 1. Mapas Astrológicos

#### POST /api/v2/charts/natal
Gera um mapa astral natal completo.

**Request Body:**
```json
{
  "name": "João Silva",
  "birth_date": "15/05/1990",
  "birth_time": "18:30",
  "city": "São Paulo",
  "state": "SP",
  "country": "BR",
  "include_charts": true,
  "chart_format": "SVG"
}
```

**Response (200):**
```json
{
  "chart_id": "chart_123456",
  "user_id": null,
  "name": "João Silva",
  "sun_sign": "Touro",
  "moon_sign": "Leão",
  "rising_sign": "Escorpião",
  "planets": {
    "sun": {"sign": "Touro", "house": 1, "degree": 24.5},
    "moon": {"sign": "Leão", "house": 4, "degree": 12.3},
    "mercury": {"sign": "Touro", "house": 1, "degree": 18.7}
  },
  "houses": {
    "house1": "Escorpião",
    "house2": "Sagitário",
    "house3": "Capricórnio"
  },
  "aspects": [
    {
      "planet1": "sun",
      "planet2": "moon",
      "aspect_type": "sextil",
      "orb": 2.1
    }
  ],
  "elements": {
    "elemento": "Terra",
    "qualidade": "Fixo"
  },
  "location": {
    "city": "São Paulo",
    "state": "SP",
    "coordinates": {"lat": -23.5505, "lng": -46.6333},
    "timezone": "America/Sao_Paulo"
  },
  "charts": {
    "svg": "<svg>...</svg>",
    "png": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
  },
  "created_at": "2024-01-15T10:30:00Z",
  "calculation_time_ms": 245.67
}
```

**Exemplo de uso:**
```bash
curl -X POST https://api.astrologia.br/api/v2/charts/natal \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "João Silva",
    "birth_date": "15/05/1990",
    "birth_time": "18:30",
    "city": "São Paulo",
    "state": "SP"
  }'
```

**Limitações:**
- Data deve estar no formato DD/MM/YYYY
- Hora deve estar no formato HH:MM
- Cidade deve existir no banco de dados GeoNames
- Estado deve ser sigla válida (2 caracteres)

#### POST /api/v2/charts/synastry
Gera comparação sinástrica entre dois mapas natais.

**Request Body:**
```json
{
  "person1": {
    "name": "João Silva",
    "birth_date": "15/05/1990",
    "birth_time": "18:30",
    "city": "São Paulo",
    "state": "SP"
  },
  "person2": {
    "name": "Maria Santos",
    "birth_date": "22/08/1985",
    "birth_time": "14:15",
    "city": "Rio de Janeiro",
    "state": "RJ"
  },
  "include_charts": true
}
```

**Response (200):**
```json
{
  "synastry_id": "syn_123456",
  "person1": {...},
  "person2": {...},
  "composite_chart": {...},
  "aspects": [...],
  "compatibility_score": 85.5,
  "charts": {...}
}
```

#### GET /api/v2/charts/{chart_id}
Recupera um mapa astral salvo.

**Parâmetros de URL:**
- `chart_id`: ID único do mapa (string)

**Response (200):** Mesmo formato do POST /natal

**Exemplo:**
```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://api.astrologia.br/api/v2/charts/chart_123456
```

#### GET /api/v2/charts/user/{user_id}
Lista mapas astrológicos do usuário (com paginação).

**Parâmetros de Query:**
- `page`: Página atual (default: 1)
- `limit`: Itens por página (default: 20, max: 100)
- `sort`: Ordenação (created_at, name) (default: -created_at)

**Response (200):**
```json
{
  "charts": [
    {
      "chart_id": "chart_123",
      "name": "João Silva",
      "sun_sign": "Touro",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  }
}
```

### 2. Autenticação e Usuários

#### POST /api/v2/auth/register
Registra um novo usuário.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "name": "João Silva",
  "plan": "free"
}
```

**Response (201):**
```json
{
  "user_id": "user_123456",
  "email": "user@example.com",
  "name": "João Silva",
  "plan": "free",
  "created_at": "2024-01-15T10:30:00Z",
  "email_verified": false
}
```

**Limitações:**
- Email deve ser único
- Senha deve ter mínimo 8 caracteres
- Plan deve ser: free, premium, professional

#### POST /api/v2/auth/login
Faz login e retorna tokens JWT.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response (200):**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 900,
  "user": {
    "user_id": "user_123456",
    "email": "user@example.com",
    "name": "João Silva",
    "plan": "free"
  }
}
```

#### POST /api/v2/auth/refresh
Renova o token de acesso usando refresh token.

**Request Body:**
```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### GET /api/v2/users/profile
Obtém perfil do usuário autenticado.

**Response (200):**
```json
{
  "user_id": "user_123456",
  "email": "user@example.com",
  "name": "João Silva",
  "plan": "free",
  "created_at": "2024-01-15T10:30:00Z",
  "last_login": "2024-01-15T10:30:00Z",
  "charts_count": 15,
  "api_calls_this_month": 145
}
```

### 3. Dados Geográficos

#### GET /api/v2/locations/cities
Busca cidades brasileiras.

**Parâmetros de Query:**
- `q`: Termo de busca (obrigatório)
- `state`: Filtrar por estado (opcional)
- `limit`: Número máximo de resultados (default: 10, max: 50)

**Exemplo:**
```bash
curl "https://api.astrologia.br/api/v2/locations/cities?q=São%20Paulo&state=SP"
```

**Response (200):**
```json
{
  "cities": [
    {
      "city_id": "br_sp_sao_paulo",
      "name": "São Paulo",
      "state": "SP",
      "coordinates": {"lat": -23.5505, "lng": -46.6333},
      "population": 12325232
    }
  ]
}
```

#### GET /api/v2/locations/timezones
Obtém timezone por estado brasileiro.

**Parâmetros de Query:**
- `state`: Sigla do estado (obrigatório)

**Exemplo:**
```bash
curl "https://api.astrologia.br/api/v2/locations/timezones?state=SP"
```

**Response (200):**
```json
{
  "state": "SP",
  "timezone": "America/Sao_Paulo",
  "utc_offset": "-03:00",
  "description": "Horário de Brasília"
}
```

### 4. Operações em Lote

#### POST /api/v2/batch/charts
Gera múltiplos mapas astrológicos em lote.

**Request Body:**
```json
{
  "requests": [
    {
      "name": "João Silva",
      "birth_date": "15/05/1990",
      "birth_time": "18:30",
      "city": "São Paulo",
      "state": "SP"
    },
    {
      "name": "Maria Santos",
      "birth_date": "22/08/1985",
      "birth_time": "14:15",
      "city": "Rio de Janeiro",
      "state": "RJ"
    }
  ],
  "callback_url": "https://myapp.com/webhook/batch-complete",
  "priority": "normal"
}
```

**Response (202):**
```json
{
  "batch_id": "batch_123456",
  "status": "processing",
  "total_requests": 2,
  "estimated_completion": "2024-01-15T10:35:00Z",
  "webhook_url": "https://myapp.com/webhook/batch-complete"
}
```

**Limitações:**
- Máximo 100 requests por lote
- Apenas usuários Professional ou superiores
- Callback URL deve ser HTTPS

#### GET /api/v2/batch/status/{batch_id}
Verifica status de um job em lote.

**Response (200):**
```json
{
  "batch_id": "batch_123456",
  "status": "completed",
  "progress": {
    "completed": 2,
    "total": 2,
    "failed": 0
  },
  "results_url": "/api/v2/batch/results/batch_123456",
  "completed_at": "2024-01-15T10:32:00Z"
}
```

### 5. Analytics e Monitoramento

#### GET /api/v2/analytics/usage
Estatísticas de uso da API (apenas usuários Professional/Admin).

**Parâmetros de Query:**
- `period`: Período (7d, 30d, 90d) (default: 30d)

**Response (200):**
```json
{
  "period": "30d",
  "total_requests": 15420,
  "requests_by_endpoint": {
    "/api/v2/charts/natal": 12340,
    "/api/v2/locations/cities": 1540
  },
  "requests_by_day": [
    {"date": "2024-01-01", "count": 450},
    {"date": "2024-01-02", "count": 520}
  ],
  "average_response_time": 245.67,
  "error_rate": 0.02
}
```

#### GET /api/v2/health
Verificação de saúde da API.

**Response (200):**
```json
{
  "status": "healthy",
  "version": "2.0.0",
  "timestamp": "2024-01-15T10:30:00Z",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "geonames": "healthy"
  },
  "uptime": "15d 4h 23m"
}
```

## Códigos de Erro

| Código | Descrição | Exemplo |
|--------|-----------|---------|
| 400 | Dados de entrada inválidos | Data em formato incorreto |
| 401 | Não autorizado | Token JWT inválido |
| 403 | Proibido | Permissões insuficientes |
| 404 | Não encontrado | Mapa ou usuário inexistente |
| 409 | Conflito | Email já cadastrado |
| 422 | Entidade não processável | Lógica de negócio inválida |
| 429 | Muitas requisições | Rate limit excedido |
| 500 | Erro interno do servidor | Erro inesperado |

**Formato de erro padrão:**
```json
{
  "error_code": "VALIDATION_ERROR",
  "message": "Formato de data inválido. Use DD/MM/YYYY",
  "details": {
    "field": "birth_date",
    "provided_value": "1990-05-15"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```

## Limitações Gerais

1. **Rate Limiting**: Aplicado por IP e usuário
2. **Tamanho de Payload**: Máximo 10MB por request
3. **Timeout**: 30 segundos para requests normais, 5 minutos para lotes
4. **Cache**: Resultados cached por 1 hora
5. **Geolocalização**: Apenas cidades brasileiras suportadas
6. **Formatos**: Data (DD/MM/YYYY), Hora (HH:MM)
7. **Codificação**: UTF-8 obrigatório
8. **HTTPS**: Apenas conexões seguras permitidas

## Suporte

Para suporte técnico:
- **Email**: suporte@astrologia.br
- **Documentação Interativa**: https://api.astrologia.br/docs
- **Status Page**: https://status.astrologia.br

## Changelog

### v2.0.0 (Atual)
- API completamente redesenhada
- Suporte a autenticação JWT
- Sistema de permissões RBAC
- Operações em lote
- Webhooks
- Analytics avançados

### v1.0.0 (Legado - Depreciado)
- Endpoint único para mapa natal
- Sem autenticação
- Funcionalidades limitadas

---

**Última atualização**: Janeiro 2024
**Versão da documentação**: 2.0.0