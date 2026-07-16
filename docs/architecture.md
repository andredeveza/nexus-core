# Arquitetura — Nexus Core

Sete camadas. Cada uma com contrato de entrada e saída explícito.
A inteligência está aqui, não nos prompts.

---

## Princípio de design

**1.** Nenhuma camada confia na camada anterior. Cada uma valida a entrada.
**2.** Filtro barato antes de agente caro. Sempre.
**3.** Toda decisão é registrada com justificativa. Decisão sem log não aconteceu.
**4.** O humano é uma camada, não uma exceção. Aprovação é um nó do fluxo.
**5.** Falha é estado válido. Todo contrato tem caminho de erro.

---

## Fluxo

```
┌─────────┐
│  RADAR  │  varre fontes, propõe sinais
└────┬────┘
     │ signal[]
     ▼
┌──────────────┐
│ FILTRO BURRO │  regex + regras, sem LLM  ← corta 90% do custo
└────┬─────────┘
     │ signal[] (filtrado)
     ▼
┌──────────────┐
│ EDITOR-CHEFE │  vale publicar? formato? prioridade?
└────┬─────────┘
     │ brief
     ▼
┌───────────────┐
│ ESTRATEGISTA  │  persona, objetivo, ângulo, CTA
└────┬──────────┘
     │ strategy
     ▼
┌──────────────┐
│  COPYWRITER  │  hook, roteiro, legenda, comentários
└────┬─────────┘
     │ copy
     ▼
┌──────────────────┐
│ DIRETOR DE ARTE  │  escolhe componente do DS, monta spec
└────┬─────────────┘
     │ art_spec
     ▼
┌──────────────────┐
│ ⏸ HUMANO (v1)    │  aprovação obrigatória na Fase 1-2
└────┬─────────────┘
     │ approved
     ▼
┌─────────────┐
│  PUBLISHER  │  agenda, publica, distribui
└────┬────────┘
     │ publication_id
     ▼
┌─────────────┐
│  ANALYTICS  │  D+1, D+7, D+30
└────┬────────┘
     │ metrics + insights
     ▼
┌─────────────┐
│   MEMÓRIA   │ ──────► realimenta Radar e Editor-Chefe
└─────────────┘
```

---

## Camada 1 — RADAR

**Papel:** descobrir oportunidade. Não julga qualidade.

**Executor:** Manus (exploratório) + n8n (RSS/API determinístico)

**Fontes:**
- Determinístico (n8n, sem LLM): RSS de OpenAI, Anthropic, Google AI, Meta AI · GitHub trending · Product Hunt
- Exploratório (Manus, 1× ao dia): Reddit, X, newsletters, blogs
- **Interno (prioritário):** commits do próprio Nexus, erros do log, métricas anômalas

> A fonte interna é a mais importante. A tese é build in public — o sistema é a pauta.

**Entrada:** `{ date, sources[], memory_context }`

**Saída:**
```json
{
  "signals": [{
    "id": "uuid",
    "source": "internal|rss|manus",
    "raw": "texto bruto",
    "url": "...",
    "type": "launch|erro_proprio|metrica|debate|ferramenta",
    "captured_at": "iso8601"
  }]
}
```

**Falha:** fonte fora do ar → registra e segue. Nunca bloqueia o pipeline.

---

## Camada 1.5 — FILTRO BURRO

**Papel:** matar 90% dos sinais antes de gastar token.

**Executor:** código. **Sem LLM.**

**Regras (ordem):**
1. Sinal `internal` → passa sempre.
2. Sinal duplicado nos últimos 7 dias (hash de URL/título) → mata.
3. Sinal sem operação própria possível → mata. *(Notícia pura é proibida por Constituição Art. 4.4)*
4. Sinal com palavra banida no título → penaliza.
5. Ângulo com 3 falhas na memória → mata.

**Por que existe:** Editor-Chefe rodando em 40 sinais/dia custa ~US$ 4/dia. Rodando em 4, custa US$ 0,40.
Mesma decisão final, 10× mais barato.

---

## Camada 2 — EDITOR-CHEFE

**Papel:** decidir se vale publicar. Nenhuma publicação nasce sem passar aqui.

**Executor:** Claude (raciocínio, custo médio)

**Entrada:** `signals[]` (filtrados) + memória (últimos 30 dias) + cota de formato do ciclo

**Saída:**
```json
{
  "decision": "approve|reject",
  "reason": "obrigatório, sempre",
  "brief": {
    "id": "uuid",
    "angle": "o ângulo específico, não o tema",
    "format": "reels|carousel|story",
    "priority": 1,
    "objective": "autoridade|lead|venda|retencao|distribuicao",
    "evidence_needed": "que tela/número/erro precisa existir"
  }
}
```

**Regras duras:**
- Aplica o teste final da AD Bible (§9). Três perguntas.
- Respeita a cota do Art. 8.1 (70/20/10). Se a cota de carrossel estourou, rejeita ou converte para Reels.
- Respeita a proporção do Art. 5.3 (6 autoridade / 3 lead / 1 venda por 10).
- `evidence_needed` vazio = rejeição automática. Sem evidência não há conteúdo.

---

## Camada 3 — ESTRATEGISTA

**Papel:** escolher persona, objetivo, narrativa e CTA. Um de cada.

**Executor:** Claude

**Entrada:** `brief` + `personas.yaml` + memória de desempenho por persona

**Saída:**
```json
{
  "persona": "operador_solo|dono_pme|construtor",
  "objective": "autoridade",
  "narrative": "tensao|operacao|principio|convite",
  "cta_id": "ref ao acervo/ctas.yaml",
  "ladder_step": "gratis|playbook|blueprint|implementacao",
  "hypothesis": "por que isso deve funcionar — testável"
}
```

**Regras duras:**
- Uma persona. Uma. (Const. Art. 2.2)
- Um objetivo. (Art. 5.1)
- Um CTA, vindo do acervo. (Art. 5.2, 7.4)
- `hypothesis` é obrigatória — é o que o Analytics vai validar depois.

---

## Camada 4 — COPYWRITER

**Papel:** produzir o texto. Segue o Método AD.

**Executor:** Claude (qualidade de escrita importa aqui)

**Entrada:** `brief` + `strategy` + `acervo/hooks.yaml` + `acervo/headlines.yaml` + AD Bible

**Saída:**
```json
{
  "hook": "≤ 2 segundos de leitura",
  "headline": "≤ 8 palavras",
  "script": [
    {"beat": "tensao", "text": "..."},
    {"beat": "operacao", "text": "...", "screen": "o que aparece na tela"},
    {"beat": "principio", "text": "..."},
    {"beat": "convite", "text": "..."}
  ],
  "caption": "...",
  "cta": "...",
  "first_comment": "...",
  "stories_derived": ["...", "..."]
}
```

**Regras duras:**
- Consulta o acervo **antes** de criar. (README, regra final)
- Zero palavra banida. Validação por regex antes de sair da camada.
- Estrutura do Método AD obrigatória em Reels e Carrossel.
- Todo `beat: operacao` precisa de `screen` preenchido.

---

## Camada 5 — DIRETOR DE ARTE

**Papel:** escolher componente aprovado do Design System. **Nunca inventar.**

**Executor:** Claude + Design System como contexto

**Entrada:** `copy` + `design-system.md` + `acervo/layouts.yaml`

**Saída:**
```json
{
  "template_id": "ref ao Design System",
  "mode": "dark|light",
  "cards": [{
    "index": 1,
    "layout": "hero|split|quote|data|screen",
    "tokens": {"bg": "--ink", "accent": "--blue", "title": "--title"},
    "content": {"title": "...", "body": "...", "image_slot": "founder-dark"}
  }],
  "chrome": {"top": "@trafegodigitalad · AD TRÁFEGO DIGITAL · ©2026", "bottom": "✦ ARRASTE PARA O LADO →"}
}
```

**Regras duras:**
- `template_id` deve existir no Design System. Inexistente = falha, não improviso.
- Uma ideia por card. (Art. 9.6)
- Neon só em destaque/glow. (Art. 9.4)
- Alternância claro/escuro consultando o feed dos últimos 6 posts. (Art. 9.5)

---

## Camada 5.5 — HUMANO

**Papel:** aprovar. Existe nas Fases 1 e 2. Sai na Fase 3 (se sair).

**Entrada:** `art_spec` + `copy` + preview

**Saída:** `approved | rejected + reason`

> O motivo da rejeição alimenta a memória. É o dado mais valioso do sistema no início.

---

## Camada 6 — PUBLISHER

**Papel:** agendar, publicar, distribuir.

**Executor:** n8n + Instagram Graph API

**Entrada:** `approved_content` + janela de publicação

**Saída:** `{ publication_id, published_at, permalink }`

**Regras duras:**
- Retry com backoff exponencial. Rate limit não é erro fatal.
- Registra em `publications` **antes** de publicar. (Art. 10.1)
- Falha de publicação → notifica humano, não tenta "dar um jeito".

---

## Camada 7 — ANALYTICS

**Papel:** medir e devolver aprendizado ao sistema.

**Executor:** n8n (coleta) + Claude (interpretação, 1× por semana)

**Coleta:** D+1, D+7, D+30 — alcance, retenção (Reels: % até o fim), salvamentos, compartilhamentos, comentários, cliques no link, DMs.

**Saída:**
```json
{
  "publication_id": "uuid",
  "metrics": {"reach": 0, "retention_pct": 0, "saves": 0, "shares": 0, "clicks": 0},
  "hypothesis_result": "confirmed|refuted|inconclusive",
  "insight": "texto curto, acionável",
  "constitution_amendment": "opcional — proposta de emenda"
}
```

**Regras duras:**
- Toda métrica volta para `publications`. (Art. 10.2)
- Testa a `hypothesis` que o Estrategista declarou. Hipótese refutada 3× = ângulo morto no Filtro Burro.
- Pode **propor** emenda à Constituição. Nunca aplicar sozinho. (Art. 11.4)

---

## Métrica-guia do sistema

Não é seguidor. Não é curtida.

**Fase 1-2:** retenção média em Reels (% que assiste até o fim).
**Fase 3+:** leads qualificados / semana.

Seguidor é consequência. Retenção é causa.

---

## Custo estimado (referência)

| Camada | Chamadas/dia | Custo/dia |
|---|---|---|
| Radar (Manus) | 1 | ~US$ 0,50 |
| Filtro Burro | — | US$ 0 |
| Editor-Chefe | ~4 | ~US$ 0,40 |
| Estrategista | ~1 | ~US$ 0,15 |
| Copywriter | ~1 | ~US$ 0,30 |
| Diretor de Arte | ~1 | ~US$ 0,20 |
| Analytics | 0,15 (semanal) | ~US$ 0,10 |
| **Total** | | **~US$ 1,65/dia · ~US$ 50/mês** |

Sem o Filtro Burro, o Editor-Chefe sozinho passa de US$ 4/dia. É por isso que ele existe.
