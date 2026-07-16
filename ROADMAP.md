# ROADMAP

## Leia isto antes de construir qualquer coisa

Estado do perfil em 2026-07-15:

```
90 posts · 622 seguidores · 94 visualizações em 30 dias
```

**Diagnóstico:** o gargalo não é produção de conteúdo. É formato e tese.
90 posts com alcance quase nulo significa que o conteúdo não está sendo distribuído nem retido.

**Consequência:** automatizar produção agora multiplica exatamente o que já não funciona.
Um Nexus rodando perfeito publicaria 3× mais posts que ninguém vê.

Por isso a Fase 1 é manual. Não é preguiça — é sequência.

---

## Fase 1 — Validar o formato (30 dias) · MANUAL

**Nada do Nexus roda. Zero automação.**

- 15-20 Reels em 30 dias
- Todos sob a tese: *"Não te ensino IA. Te mostro o meu sistema rodando."*
- Assunto: a construção do próprio Nexus (build in public)
- Método AD em todos: tensão → operação → princípio → convite
- Registro manual em `publications` (planilha ou Supabase, tanto faz)

**Métrica-guia:** retenção média em Reels.

| Resultado | Decisão |
|---|---|
| retenção ≥ 40% | segue para Fase 2 |
| retenção 25-40% | mais 15 Reels, ajusta hook |
| retenção < 25% | **a tese está errada.** Volta ao posicionamento. |

> Não pule esta fase. Se a tese não funciona manual, ela não funciona automatizada.
> O Nexus não conserta conteúdo ruim — ele acelera o que já existe.

**Entregável de conteúdo:** cada Reels desta fase é sobre construir o Nexus. A fase se auto-financia em pauta.

---

## Fase 2 — Assistir, não automatizar (30-60 dias)

O Nexus entra como **copiloto**. Humano continua no controle.

Ativar, nesta ordem:

1. **Supabase** — schema em `runtime/supabase-schema.sql`. Sem isso não há memória, sem memória não há aprendizado.
2. **Radar (fonte interna apenas)** — commits, erros, métricas. Sem fontes externas ainda.
3. **Filtro Burro** — código, sem LLM.
4. **Editor-Chefe** — decide, humano confirma. Meta: taxa de rejeição 70-80%.
5. **Copywriter** — rascunha, humano reescreve. Cada reescrita alimenta o acervo.

**Ainda manual:** arte, publicação, tudo que sai.

**Métrica de sucesso da fase:** % de rascunhos do Copywriter aprovados sem reescrita.
Abaixo de 30% → o problema está no acervo, não no modelo.

**Sinal de alerta:** se o Editor-Chefe aprova > 50%, ele virou carimbo. Endurece o prompt.

---

## Fase 3 — Pipeline com portão humano (60-120 dias)

Fluxo completo roda. Humano aprova antes de publicar.

- Radar com fontes externas
- Estrategista + Diretor de Arte ativos
- Publisher agendando
- Analytics coletando D+1/D+7/D+30
- **Portão humano obrigatório** antes do Publisher

`rejection_reason` de cada rejeição humana é o dado mais valioso do sistema nesta fase.

**Saída da fase:** 20 publicações seguidas aprovadas sem edição.

---

## Fase 4 — Autonomia parcial (120+ dias)

Portão humano sai **por categoria**, não de uma vez.

Ordem sugerida:
1. Stories (baixo risco)
2. Reels de log/bastidor
3. Carrossel editorial
4. Nunca: conteúdo com objetivo `venda`

Humano revisa semanalmente, não por peça.

**Condição de reversão:** 2 publicações ruins seguidas → portão volta. Sem discussão.

---

## Fase 5 — Nexus como produto

Só depois que o sistema opera a AD por 90 dias sem intervenção diária.

- `nexus-core` público → autoridade + lead (já é público desde o dia 1)
- Nexus Blueprint (R$ 497) → o sistema empacotado
- Implementação (R$ 5-15k) → vem de DM, não de funil

**Não construa o Blueprint antes disso.** Vender sistema que não opera é o teatro que a marca combate.

---

## O que NÃO fazer

| Tentação | Por que não |
|---|---|
| Automatizar antes de validar formato | Multiplica o que não funciona |
| Construir os 7 agentes de uma vez | Não sabe qual é o gargalo real |
| Neo4j / Pinecone / stack complexa | Volume não justifica. É teatro técnico. |
| Manus como orquestrador | Sem cron confiável, sem retry, sem estado |
| Publicar notícia de IA | Const. Art. 4.4. É o que já fracassou em 90 posts. |
| Criar o Blueprint na Fase 1 | Produto antes de audiência |
| Esconder quando quebrar | Destrói a tese inteira (Art. 12.4) |

---

## Marcos

| Marco | Métrica | Prazo |
|---|---|---|
| Tese validada | retenção ≥ 40% em Reels | 30 dias |
| Memória viva | 30 publicações com métrica D+7 | 60 dias |
| Copiloto útil | 30% dos rascunhos aprovados sem reescrita | 90 dias |
| Pipeline confiável | 20 aprovações seguidas sem edição | 120 dias |
| Autonomia parcial | Stories publicando sozinho | 150 dias |
| Produto | primeira venda do Blueprint | 180+ dias |

---

## Registro de decisões

| Data | Decisão | Motivo |
|---|---|---|
| 2026-07-15 | Postgres, não Neo4j | < 10k nós. Grafo em SQL resolve. |
| 2026-07-15 | n8n orquestra, não Manus | Manus não tem cron/retry/estado |
| 2026-07-15 | Filtro Burro antes do Editor-Chefe | US$ 4/dia → US$ 0,40/dia |
| 2026-07-15 | Fase 1 manual | Automatizar antes de validar = multiplicar erro |
| 2026-07-15 | Tese "sistema rodando", não "ensino IA" | Categoria de professor exige credencial; operador não |
| 2026-07-15 | 70% Reels | 90 posts em carrossel = 622 seguidores |
