# Modelo de Dados

Normativo em Markdown (este repo). Transacional em Supabase.

## Por que essa divisão

| | Markdown/YAML | Supabase |
|---|---|---|
| Muda com que frequência? | Raro (semanas) | Constante (diário) |
| Quem lê? | Agentes, como contexto | Agentes, como query |
| Precisa de histórico? | Sim → Git | Não → timestamp basta |
| Cresce sem limite? | Não | Sim |

Constituição, AD Bible, prompts, acervo → **Markdown.** Versionado, auditável, lido direto.
Sinais, briefs, publicações, métricas, grafo → **Supabase.** Cresce, consulta, agrega.

## Decisão: Postgres, não Neo4j

O knowledge graph é `nodes` + `edges` em Postgres.

**Por quê:**
- Volume esperado: < 10k nós em 12 meses. Postgres com índice resolve.
- Neo4j = mais um serviço, mais um backup, mais uma linguagem (Cypher).
- Ganho real de grafo aparece em travessias profundas (5+ saltos). O Nexus faz 2-3.

**Quando revisar:** > 100k nós ou travessia > 4 saltos virando gargalo.

*(Essa decisão é conteúdo. Ver AD Bible §2 — "por que eu NÃO usei Neo4j".)*

## Tabelas

```
signals      → Radar
briefs       → Editor-Chefe (decisão + motivo, sempre)
strategies   → Estrategista (persona, CTA, hipótese)
publications → memória central (Art. 10.1)
metrics      → D+1, D+7, D+30 (Art. 10.2)
insights     → Analytics (hipótese testada)
dead_angles  → realimenta o Filtro Burro (Art. 10.3)
amendments   → propostas à Constituição (Art. 11.4)
nodes/edges  → knowledge graph
agent_costs  → custo por camada (vira conteúdo)
```

## Grafo — modelo

```
persona ──resolve──> problema
problema ──resolvido_por──> ferramenta
ferramenta ──gera──> case
case ──ilustra──> conteudo
conteudo ──converte_em──> cta
cta ──leva_a──> produto
conteudo ──usa──> layout
```

`edges.weight` é ajustado pelo Analytics conforme desempenho.
Aresta que nunca converte tende a zero e para de ser sugerida.

## Constraints que importam

**`evidence_required_on_approve`** — brief aprovado sem `evidence_needed` é impossível no banco.
A Constituição (Art. 4.3) vira restrição de schema, não confiança no prompt.

**`unique (publication_id, window)`** — impede métrica duplicada.

**`reason not null` em briefs** — rejeição sem motivo não entra. É o dado que ensina o sistema.

## Views

| View | Consumidor | Uso |
|---|---|---|
| `v_format_quota` | Editor-Chefe | cota 70/20/10 (Art. 8.1) |
| `v_performance_by_persona` | Estrategista | escolha de persona |
| `v_cost_per_publication` | Analytics + conteúdo | custo real → post |
| `v_editor_rejection_rate` | humano | Editor-Chefe está rejeitando o bastante? |

Alvo de `v_editor_rejection_rate`: **70-80%**.
Abaixo de 50% = o Editor virou carimbo.
