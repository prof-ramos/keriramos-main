---
name: 🐛 Bug Report
about: Reportar um bug encontrado na API
title: "[BUG] "
labels: ["bug", "triage"]
assignees: []
---

## 🐛 Bug Report

### 📋 Descrição do Bug
**O que aconteceu:**
Uma descrição clara e concisa do bug.

**O que deveria acontecer:**
Comportamento esperado.

### 🔄 Como Reproduzir
Passos para reproduzir o comportamento:
1. Ir para '...'
2. Clicar em '....'
3. Ver erro

### 📊 Ambiente
- **OS:** [e.g. Ubuntu 20.04, macOS 12.0]
- **Browser:** [e.g. Chrome 91, Firefox 89]
- **Versão da API:** [e.g. v2.0.0]
- **Endpoint afetado:** [e.g. `/api/v2/charts/natal`]

### 📝 Request/Response
**Request enviado:**
```json
{
  "name": "João Silva",
  "birth_date": "15/05/1990",
  "birth_time": "18:30",
  "city": "São Paulo",
  "state": "SP"
}
```

**Response recebido:**
```json
{
  "error": "Internal Server Error",
  "message": "..."
}
```

### 📸 Screenshots/Logs
Se aplicável, adicione screenshots ou logs para ajudar a explicar o problema.

### 🔍 Informações Adicionais
- **Frequência:** Sempre, Às vezes, Uma vez
- **Impacto:** Baixo, Médio, Alto, Crítico
- **Usuários afetados:** Quantos usuários são impactados?
- **Workaround:** Existe alguma solução temporária?

### ✅ Checklist
- [ ] Testei em diferentes browsers
- [ ] Verifiquei se o bug já foi reportado
- [ ] Tentei reproduzir em ambiente de desenvolvimento
- [ ] Li a documentação relevante