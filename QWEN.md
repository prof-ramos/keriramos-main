# Contexto do Projeto: API de Astrologia Brasileira

## Visão Geral do Projeto

O projeto é uma API RESTful completa para cálculos astrológicos focada no público brasileiro. Desenvolvida em Python com o framework FastAPI, fornece mapas astrais detalhados com gráficos interativos, utilizando formato de data brasileiro (DD/MM/YYYY) e terminologia em português.

### Principais Características:
- **API RESTful** com endpoints para cálculos astrológicos completos
- **Formatação brasileira** de datas e horários (DD/MM/YYYY e HH:MM)
- **Suporte a gráficos SVG e PNG** para mapas astrais
- **Geolocalização integrada** com GeoNames para cidades brasileiras
- **Sistema de cache** para otimizar cálculos repetidos
- **Limitação de requisições** (rate limiting) por IP
- **Suporte a múltiplos planos** (FREE, PREMIUM, PROFESSIONAL)
- **Deploy com Docker** e Docker Compose
- **Monitoramento de performance** com endpoints dedicados

## Arquitetura e Tecnologias

### Stack Principal:
- **Backend**: Python 3.14 com FastAPI
- **Biblioteca astrológica**: Kerykeion
- **Geolocalização**: GeoNames API
- **Cache**: Redis
- **Banco de dados**: PostgreSQL
- **Containerização**: Docker e Docker Compose
- **Autenticação**: JWT Bearer Token
- **Gráficos**: SVG gerados via Kerykeion

### Estrutura de Arquivos:
```
keriramos-main/
├── main.py                 # Aplicação FastAPI principal
├── models.py               # Definições de modelos Pydantic
├── geonames_client.py      # Cliente para API GeoNames
├── chart_generator.py      # Gerador de gráficos astrológicos
├── requirements.txt        # Dependências Python
├── Dockerfile             # Definição do container Docker
├── docker-compose.yml     # Configuração de múltiplos serviços
├── Makefile               # Comandos automatizados
├── API_DOCUMENTATION.md   # Documentação completa da API
├── README.md              # Documentação principal do projeto
└── ...
```

## Funcionalidades Principais

### 1. Cálculos Astrológicos
- **Mapa Natal**: Posições planetárias completas com aspectos
- **Sinastria**: Comparação entre dois mapas natais
- **Trânsito**: Influências planetárias atuais
- **Retorno Solar**: Análise anual detalhada
- **Casas Astrológicas**: Sistema completo de 12 casas

### 2. Geração de Gráficos
- Gráficos SVG de alta qualidade para mapas astrais
- Suporte a formatos SVG e PNG (base64)
- Visualizações interativas dos dados astrológicos

### 3. Geolocalização Brasileira
- Busca inteligente por cidades brasileiras
- Fusos horários automáticos por estado
- Coordenações precisas via GeoNames

### 4. Recursos de Desempenho
- Sistema de cache em memória para cálculos repetidos
- Compressão GZip para respostas otimizadas
- Rate limiting para controle de uso
- Processamento assíncrono com asyncio

## Estrutura do Código

### main.py
- Aplicação FastAPI com endpoints para cálculos astrológicos
- Middleware para CORS e compressão GZip
- Sistema de rate limiting baseado em IP
- Cache em memória para cálculos repetidos
- Conversão de formatos de data/hora brasileiros (DD/MM/YYYY, HH:MM)

### models.py
- Definições Pydantic para requisições e respostas da API
- Estrutura de dados para:
  - Requisições de mapas astrais (nome, data, hora, cidade, estado)
  - Respostas com dados astrológicos completos
  - Elementos, casas, planetas e aspectos

### geonames_client.py
- Cliente assíncrono para API GeoNames
- Cache baseado em estado e cidade
- Determinação de fusos horários brasileiros
- Tratamento de erros e timeouts

### chart_generator.py
- Geração de gráficos SVG via Kerykeion
- Sistema de fallback para criação de gráficos básicos
- Conversão para formatos PNG (base64)

## Configuração e Execução

### Requisitos:
- Docker e Docker Compose
- Conta no GeoNames (gratuita)
- Variáveis de ambiente configuradas

### Comandos Comuns:
```bash
# Configurar ambiente
cp .env.example .env
# Editar .env com credenciais do GeoNames

# Iniciar ambiente de desenvolvimento
make dev

# Executar testes
make test

# Ver logs
make logs

# Formatar código
make format

# Linting
make lint
```

### Endpoints Principais:
- `POST /mapa-astral` - Geração de mapa astral natal
- `GET /health` - Verificação de saúde da API
- `GET /performance` - Estatísticas de desempenho

## Considerações de Desenvolvimento

### Padrões e Convenções:
- Uso de type hints obrigatórios
- Código e documentação em português brasileiro
- Validação de entrada com Pydantic
- Formato de data DD/MM/YYYY e hora HH:MM
- Nomenclatura de cidades e estados em português

### Práticas de Segurança:
- Rate limiting por IP
- Cache em memória (não persistente por padrão)
- Autenticação JWT (implantada na v2.0+)
- Validação de entradas
- Timeout de requisições

### Otimizações:
- Cache de cálculos astroológicos
- Compressão de respostas GZip
- Processamento assíncrono
- Pool de conexões com Redis
- Cache de geolocalização

## Extensibilidade

O projeto é estruturado para facilitar:
- Implementação de novos tipos de mapas (sinastria, trânsitos)
- Adição de novos formatos de gráficos
- Integração com provedores de cache externos
- Implementação de autenticação e planos de usuário
- Adição de endpoints de analytics e monitoramento
- Internacionalização para outros formatos de data

## Dados de Entrada e Saída

### Formato de Requisição:
```json
{
  "nome": "João Silva",
  "data_nascimento": "15/05/1990",
  "hora_nascimento": "18:30",
  "cidade": "São Paulo",
  "estado": "SP"
}
```

### Formato de Resposta:
- Signo solar, lunar e ascendente
- Posições planetárias (signo, casa, grau)
- 12 casas astrológicas
- Elementos (fogo, terra, ar, água)
- Gráficos SVG e PNG (opcional)
- Detalhes da localização calculada

## Considerações Específicas para Modificação

### Ao modificar cálculos astrológicos:
- Preservar o formato DD/MM/YYYY para datas e HH:MM para horas
- Manter a integração com GeoNames para fusos horários corretos
- Considerar os fusos horários específicos de cada estado brasileiro
- Testar com cidades brasileiras conhecidas para validação

### Ao adicionar novos endpoints:
- Utilizar o mesmo sistema de cache para otimização
- Manter os mesmos padrões de erro e tratamento de exceções
- Aplicar as mesmas políticas de rate limiting
- Garantir suporte para formatos brasileiros de data/hora

### Ao expandir recursos:
- Considerar o impacto no cache e na performance
- Manter consistência com a linguagem portuguesa
- Assegurar a compatibilidade com o ecossistema FastAPI
- Utilizar as mesmas ferramentas de containerização e deploy