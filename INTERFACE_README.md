# 🌟 Interface Terminal - API de Astrologia Brasileira

## Visão Geral

Interface web inspirada em terminal/CLI para a **API de Astrologia Brasileira**. Design autêntico de linha de comando com tecnologias web modernas, proporcionando uma experiência única e profissional.

## 🎨 Características

### Design Terminal Autêntico
- **Fontes monoespaçadas**: Monaco, Menlo, Ubuntu Mono
- **Esquema de cores terminal**: Tema escuro com acentos laranja (#d97706)
- **Elementos CLI**: Prompts ($, >), cursores, arte ASCII
- **Animações suaves**: Transições e efeitos hover

### 4 Seções Principais

#### 1. 📋 Documentação da API
- Referência completa de endpoints
- Busca em tempo real de endpoints
- Filtros por método HTTP (GET, POST, PUT, DELETE)
- Exemplos de comandos curl copiáveis
- Cards interativos com detalhes de parâmetros

**Endpoints Documentados:**
- `GET /api/v1/mapa-astral` - Gera mapa astral completo
- `GET /api/v1/horoscopo` - Retorna horóscopo diário/semanal/mensal
- `POST /api/v1/sinastria` - Calcula compatibilidade entre mapas
- `GET /api/v1/transitos` - Retorna trânsitos planetários

#### 2. ⭐ Consulta Astrológica
- **Calculadora de Mapa Astral**
  - Formulário com data, hora e local de nascimento
  - Entrada de coordenadas (latitude/longitude)
  - Resultados detalhados com signos e ascendente

- **Horóscopo do Dia**
  - Grid com os 12 signos zodiacais
  - Símbolos astrológicos (♈, ♉, ♊, etc.)
  - Previsões personalizadas
  - Avaliação de amor, trabalho e saúde

#### 3. 📊 Dashboard da API
- **Status do Sistema**
  - Indicador de status online/offline
  - Uptime e versão da API
  - Última atualização

- **Métricas de Uso**
  - Barras de progresso animadas
  - Contadores de requisições
  - Estatísticas por tipo de consulta

- **Gráfico de Tempo de Resposta**
  - Visualização em barras CLI
  - Monitoramento por período do dia

- **Log de Atividade Recente**
  - Requisições em tempo real
  - Status codes coloridos
  - Métodos HTTP destacados

#### 4. 💻 Portal do Desenvolvedor
- **Guia de Início Rápido**
  - 3 passos para começar
  - Comandos curl copiáveis
  - Instruções de autenticação

- **API Playground**
  - Teste interativo de endpoints
  - Seletor de método HTTP
  - Editor de headers e body JSON
  - Visualização de respostas formatadas

- **Autenticação**
  - Formulário de login/registro
  - Geração de API keys
  - Display de chave com cópia rápida

- **Exemplos de Código**
  - JavaScript (fetch API)
  - Python (requests)
  - PHP (curl)
  - cURL (command line)
  - Tabs navegáveis entre linguagens

## 🎯 Funcionalidades Interativas

### Navegação
- Menu de navegação CLI com comandos
- Tabs ativas com destaque visual
- Suporte a hash URL (#docs, #consulta, #dashboard, #dev)

### Busca e Filtros
- Busca em tempo real nos endpoints
- Filtros por método HTTP
- Feedback visual de resultados

### Copiar para Área de Transferência
- Botões de cópia em todos os comandos
- Feedback visual de sucesso (✓)
- Fallback para navegadores antigos

### Formulários
- Validação de dados
- Simulação de chamadas API
- Resultados formatados em tempo real

### Atalhos de Teclado
- `Ctrl/Cmd + K` - Focar na busca
- `ESC` - Limpar busca

## 📁 Estrutura de Arquivos

```
keriramos-main/
├── index.html                 # HTML principal
├── css/
│   ├── terminal-base.css      # Estilos base do terminal
│   ├── terminal-components.css # Componentes reutilizáveis
│   └── terminal-layout.css    # Layouts e utilidades
├── js/
│   └── terminal-ui.js         # JavaScript interativo
├── README.md                  # README original
└── INTERFACE_README.md        # Esta documentação
```

## 🎨 Paleta de Cores

```css
/* Backgrounds */
--bg-primary: #0f0f0f      /* Preto terminal */
--bg-secondary: #1a1a1a    /* Cinza escuro */
--bg-tertiary: #2a2a2a     /* Cinza médio */

/* Textos */
--text-primary: #ffffff    /* Branco */
--text-secondary: #a0a0a0  /* Cinza claro */
--text-accent: #d97706     /* Laranja */
--text-success: #10b981    /* Verde */
--text-warning: #f59e0b    /* Amarelo */
--text-error: #ef4444      /* Vermelho */
--text-info: #3b82f6       /* Azul */

/* Bordas */
--border-primary: #404040  /* Cinza escuro */
--border-secondary: #606060 /* Cinza médio */
```

## 🔧 Tecnologias Utilizadas

- **HTML5**: Estrutura semântica
- **CSS3**: Custom Properties, Grid, Flexbox, Animações
- **JavaScript ES6+**: Interatividade moderna
- **Sem frameworks**: Vanilla JS para máxima performance

## 📱 Responsividade

A interface é totalmente responsiva com breakpoints:

- **Desktop**: > 1200px - Layout completo em grid
- **Tablet**: 768px - 1200px - Grid adaptativo
- **Mobile**: < 768px - Layout em coluna única
- **Small Mobile**: < 480px - Otimizações adicionais

## ♿ Acessibilidade

- **Contraste**: WCAG AAA compliant
- **Navegação por teclado**: Totalmente suportada
- **Screen readers**: HTML semântico
- **Focus indicators**: Visíveis e destacados

## 🚀 Como Usar

### Abrir Localmente

1. Clone o repositório:
```bash
git clone https://github.com/prof-ramos/keriramos-main.git
cd keriramos-main
```

2. Abra o arquivo no navegador:
```bash
# Linux/Mac
open index.html

# Windows
start index.html

# Ou use um servidor local
python -m http.server 8000
# Acesse: http://localhost:8000
```

### Integração com API Real

Para conectar com sua API real, edite `js/terminal-ui.js`:

1. Substitua as funções de simulação (`simulateAPICall`, `generateMapaAstral`) por chamadas `fetch()` reais
2. Configure a URL base da API
3. Adicione tratamento de erros adequado

**Exemplo:**
```javascript
async function callRealAPI(endpoint, options) {
    const API_BASE = 'https://api.astro.br';

    try {
        const response = await fetch(`${API_BASE}${endpoint}`, options);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('API Error:', error);
        return { error: true, message: error.message };
    }
}
```

## 🎭 Demonstração de Recursos

### Busca de Endpoints
Digite qualquer termo relacionado aos endpoints (ex: "mapa", "horóscopo", "transitos") e veja os resultados filtrarem em tempo real.

### Filtros por Método
Clique nos chips de filtro (GET, POST, PUT, DELETE) para ver apenas endpoints desse método.

### Calculadora de Mapa Astral
1. Vá para a seção "Consulta"
2. Preencha data, hora e local de nascimento
3. Clique em "Calcular Mapa Astral"
4. Veja seus signos solar, lunar e ascendente

### Horóscopo
1. Na seção "Consulta", role até "Horóscopo do Dia"
2. Clique em qualquer signo
3. Leia sua previsão personalizada

### API Playground
1. Vá para "Portal do Desenvolvedor"
2. Na seção "API Playground", configure:
   - Método HTTP
   - Endpoint
   - Headers (opcional)
   - Body JSON (para POST)
3. Clique em "Executar Requisição"
4. Veja a resposta formatada

### Copiar Exemplos
Todos os comandos curl e códigos de exemplo têm botões 📋 para copiar instantaneamente.

## 🌟 Destaques de Design

### Arte ASCII
```
   █████╗ ███████╗████████╗██████╗  ██████╗     ██████╗ ██████╗
  ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗    ██╔══██╗██╔══██╗
  ███████║███████╗   ██║   ██████╔╝██║   ██║    ██████╔╝██████╔╝
  ██╔══██║╚════██║   ██║   ██╔══██╗██║   ██║    ██╔══██╗██╔══██╗
  ██║  ██║███████║   ██║   ██║  ██║╚██████╔╝    ██████╔╝██║  ██║
  ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝     ╚═════╝ ╚═╝  ╚═╝
```

### Controles de Janela
Círculos coloridos no estilo macOS (🔴 🟡 🟢) no topo da interface.

### Indicadores de Status
Pontos pulsantes (●) mostrando status do sistema em tempo real.

### Barras de Progresso CLI
Visualizações de métricas com barras de progresso no estilo terminal.

## 📊 Performance

- **Zero dependências**: Sem bibliotecas externas
- **CSS otimizado**: Custom properties para tematização eficiente
- **JavaScript leve**: < 10KB minificado
- **Carregamento rápido**: Todos os recursos inline ou locais

## 🔮 Próximas Melhorias Sugeridas

1. **Tema Claro**: Adicionar tema light com toggle
2. **Histórico de Comandos**: Armazenar buscas recentes
3. **Autocomplete**: Sugestões de endpoints na busca
4. **Exportação**: Download de resultados em JSON/PDF
5. **WebSocket**: Atualizações em tempo real no dashboard
6. **Gráficos Avançados**: Integração com biblioteca de charts
7. **Múltiplos Idiomas**: i18n para português e inglês
8. **PWA**: Transformar em Progressive Web App

## 📝 Licença

Este projeto está sob a mesma licença do repositório principal.

## 👨‍💻 Autor

Desenvolvido como interface terminal para a **API de Astrologia Brasileira**.

---

**Aproveite a experiência CLI! ✨**

Para suporte ou dúvidas, consulte a documentação da API ou abra uma issue no repositório.
