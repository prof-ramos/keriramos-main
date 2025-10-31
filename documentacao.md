# Documentação do Projeto

## Visão Geral

Este documento fornece uma visão geral da estrutura e funcionalidades do projeto.

## Estrutura de Diretórios

```
keriramos-main/
├── .dockerignore          # Arquivos/pastas a serem ignorados pelo Docker
├── .env                   # Variáveis de ambiente
├── .env.example          # Exemplo de variáveis de ambiente
├── .mcp.json             # Configurações do Smithery MCP
├── API_DOCUMENTATION.md  # Documentação da API
├── API_EXAMPLES.md       # Exemplos de uso da API
├── chart_generator.py    # Gerador de gráficos
├── CLAUDE.md             # Documentação específica para Claude
├── coderabbit.yaml       # Configurações do CodeRabbit
├── deploy_guide.md       # Guia de deploy
├── DOCKER_README.md      # Documentação do Docker
├── docker-compose.prod.yml # Configuração do Docker Compose para produção
├── docker-compose.yml     # Configuração do Docker Compose
├── Dockerfile            # Definição do container Docker
├── GEMINI.md             # Documentação específica para Gemini
├── geonames_client.py    # Cliente para serviço Geonames
├── main.py               # Arquivo principal da aplicação
├── Makefile              # Tarefas de build/automatização
├── models.py             # Definições de modelos
└── openapi.yaml          # Especificação OpenAPI
```

## Configuração do Ambiente

1. Copie o arquivo `.env.example` para `.env`:
   ```bash
   cp .env.example .env
   ```

2. Atualize as variáveis de ambiente conforme necessário.

## Executando o Projeto

O projeto pode ser executado usando Docker ou diretamente com Python.

### Com Docker

```bash
docker-compose up
```

### Sem Docker

```bash
python main.py
```

## API

A documentação da API está disponível em `API_DOCUMENTATION.md`.

## Deploy

As instruções de deploy estão disponíveis em `deploy_guide.md`.

## Contribuição

Para contribuir com este projeto, por favor, siga as diretrizes em `CONTRIBUTING.md` (se existir).