## 📋 Pull Request Template - API de Astrologia Brasileira

### 🎯 Tipo de Mudança
Marque com um `x` o tipo de mudança introduzida:
- [ ] 🐛 **Bug fix** (correção de bug que não quebra compatibilidade)
- [ ] ✨ **New feature** (nova funcionalidade que não quebra compatibilidade)
- [ ] 💥 **Breaking change** (mudança que quebra compatibilidade)
- [ ] 📚 **Documentation** (mudanças apenas na documentação)
- [ ] 🎨 **Style** (formatação, missing semi colons, etc)
- [ ] ♻️ **Refactor** (refatoração de código)
- [ ] ⚡ **Performance** (melhoria de performance)
- [ ] ✅ **Tests** (adição ou correção de testes)
- [ ] 🔧 **Build/CI** (mudanças em build, CI, dependências)
- [ ] 🔒 **Security** (correções de segurança)

### 📝 Descrição

**O que foi implementado/mudado:**

**Por que foi implementado:**

**Como testar:**

### 🔗 Links Relacionados

- **Issue/Ticket:** [Link para issue](#)
- **Documentação:** [Link para docs](#)
- **Deploy notes:** [Notas sobre deploy](#)

### ✅ Checklist

#### Código
- [ ] Meu código segue os padrões do projeto
- [ ] Executei `make lint` e não há erros
- [ ] Executei `make test` e todos passam
- [ ] Executei `make format` para formatar o código
- [ ] Adicionei testes para novas funcionalidades
- [ ] Cobertura de testes > 80%

#### Segurança
- [ ] Não há secrets hardcoded
- [ ] Validação de entrada implementada
- [ ] Não há vulnerabilidades conhecidas
- [ ] Logs não expõem dados sensíveis

#### Documentação
- [ ] Documentação da API atualizada
- [ ] Exemplos de uso incluídos
- [ ] Comentários no código em português
- [ ] CHANGELOG atualizado (se aplicável)

#### Performance
- [ ] Não há queries N+1
- [ ] Cache implementado quando apropriado
- [ ] Recursos otimizados
- [ ] Testes de performance executados

### 🧪 Testes Realizados

**Testes Unitários:**
- [ ] Models Pydantic validados
- [ ] Funções utilitárias testadas
- [ ] Tratamento de erros verificado

**Testes de Integração:**
- [ ] Endpoints da API testados
- [ ] Banco de dados integrado
- [ ] Cache Redis funcionando

**Testes E2E:**
- [ ] Fluxo completo testado
- [ ] Autenticação JWT validada
- [ ] Rate limiting verificado

### 🚀 Deployment

**Deployment necessário:**
- [ ] Apenas código (deploy automático)
- [ ] Database migration necessária
- [ ] Environment variables novas
- [ ] Configuração de infraestrutura
- [ ] Aprovação manual necessária

**Riscos do deploy:**
- [ ] Baixo risco (mudanças isoladas)
- [ ] Médio risco (pode afetar usuários)
- [ ] Alto risco (mudanças críticas)

**Rollback plan:**
- [ ] Deploy anterior disponível
- [ ] Database backup realizado
- [ ] Feature flag implementado

### 📊 Métricas

**Antes da mudança:**
- Cobertura de testes: X%
- Performance: Y ms
- Security score: Z

**Depois da mudança:**
- Cobertura de testes: X%
- Performance: Y ms
- Security score: Z

### 🎨 Screenshots/Vídeos (se aplicável)

**Antes:**
[Adicionar screenshots]

**Depois:**
[Adicionar screenshots]

### 👥 Revisores Sugeridos

- [ ] @prof-ramos (mantenedor)
- [ ] @equipe-backend
- [ ] @equipe-frontend (se UI afetada)

### 📅 Estimativa de Revisão

- [ ] Até 1 hora (mudanças simples)
- [ ] 1-4 horas (funcionalidades novas)
- [ ] 4+ horas (mudanças complexas)

---

**⚠️ Importante:** Todos os itens do checklist devem ser marcados antes da aprovação. Se algum item não se aplica, justifique no comentário.

**🎯 Lembre-se:** Este PR segue os princípios da API de Astrologia Brasileira: qualidade, segurança, performance e experiência do usuário brasileiro.