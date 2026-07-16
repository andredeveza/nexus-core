# n8n — Desenho dos fluxos

n8n orquestra. LLM executa. Nunca o contrário.

**Por que n8n e não Manus:** cron confiável, retry nativo, estado persistente, log auditável.
Manus é ótimo em tarefa exploratória. Péssimo em rodar todo dia às 6h por 12 meses.

---

## Fluxo 1 — RADAR (diário, 06:00)

```
[Cron 06:00]
   ├─→ [HTTP] RSS OpenAI/Anthropic/Google/Meta
   ├─→ [HTTP] GitHub trending
   ├─→ [Supabase] métricas anômalas (>2σ)   ← FONTE PRIORITÁRIA
   ├─→ [n8n API] erros do log 24h            ← FONTE PRIORITÁRIA
   └─→ [Manus] pesquisa exploratória
        ↓
   [Merge]
        ↓
   [Code] FILTRO BURRO ── sem LLM
        ↓
   [Supabase] insert signals
```

### Filtro Burro (nó Code)

```javascript
const signals = $input.all().map(i => i.json);
const out = [];

for (const s of signals) {
  // 1. interno passa sempre — é a tese
  if (s.source === 'internal') { out.push(s); continue; }

  // 2. dedupe 7 dias
  const dup = await checkHash(s.hash, 7);
  if (dup) { kill(s, 'duplicate'); continue; }

  // 3. sem operação própria = notícia = proibido (Const. Art. 4.4)
  if (!s.possible_operation?.trim()) { kill(s, 'no_operation'); continue; }

  // 4. ângulo morto (Art. 10.3)
  const dead = await isDeadAngle(s.hash);
  if (dead) { kill(s, 'dead_angle'); continue; }

  // 5. palavra banida no título
  if (BANNED.some(w => s.raw.toLowerCase().includes(w))) { s.penalty = true; }

  out.push(s);
}

return out.slice(0, 15);  // teto rígido
```

**Impacto:** ~40 sinais → ~4. Editor-Chefe de US$ 4/dia → US$ 0,40/dia.

---

## Fluxo 2 — PIPELINE EDITORIAL (diário, 07:00)

```
[Cron 07:00]
   ↓
[Supabase] signals não processados
   ↓
[Claude] EDITOR-CHEFE ─── prompts/02
   ↓
[IF decision = reject] ──→ [Supabase] insert briefs (reason) ──→ FIM
   ↓ approve
[Supabase] insert briefs
   ↓
[Claude] ESTRATEGISTA ─── prompts/03
   ↓
[Supabase] insert strategies
   ↓
[Claude] COPYWRITER ─── prompts/04
   ↓
[Code] valida palavras banidas ── falhou? volta 1×, depois erro
   ↓
[Claude] DIRETOR DE ARTE ─── prompts/05
   ↓
[IF error = no_matching_layout] ──→ [Notifica humano] ──→ FIM
   ↓
[Supabase] insert publications (status=scheduled)
   ↓
[Telegram/WhatsApp] ⏸ PORTÃO HUMANO
```

### Portão humano

Fases 2-3: obrigatório.
Fase 4: sai por categoria.

```
[Wait for webhook]
   ├─ approve → Fluxo 3
   └─ reject  → [Supabase] update rejection_reason  ← dado mais valioso da Fase 2-3
```

---

## Fluxo 3 — PUBLISHER

```
[Webhook approve]
   ↓
[Supabase] update status = approved
   ↓
[Wait until] scheduled_for
   ↓
[HTTP] IG Graph API — create container
   ↓
[HTTP] IG Graph API — publish
   ↓
[IF error]
   └─→ [Wait] backoff 1→2→4→8min, máx 4×
        └─→ ainda falha? [Supabase] status=failed + [Notifica] + FIM
   ↓ ok
[Supabase] status=published, permalink
   ↓
[HTTP] primeiro comentário
   ↓
[Wait 2h] → [HTTP] stories derivados
```

**Nunca:** alterar copy, alterar arte, republicar sozinho, "dar um jeito".

---

## Fluxo 4 — ANALYTICS

```
[Cron 08:00]
   ↓
[Supabase] publicações em D+1, D+7 ou D+30
   ↓
[HTTP] IG Graph API insights
   ↓
[Supabase] insert metrics
   ↓
[IF window = d7]
   ↓
[Claude] ANALYTICS ─── prompts/07
   ↓
[Supabase] insert insights
   ↓
[IF hypothesis_result = refuted]
   └─→ [Code] conta falhas do ângulo
        └─→ [IF >= 3] [Supabase] insert dead_angles  ← volta pro Filtro Burro
   ↓
[IF constitution_amendment]
   └─→ [Supabase] insert amendments (status=proposed) + [Notifica humano]
```

---

## Fluxo 5 — CUSTO

Todo nó Claude escreve em `agent_costs`.

```
[Após cada chamada LLM]
   ↓
[Supabase] insert agent_costs {agent, model, tokens_in, tokens_out, cost_usd}
```

**Por que importa:** `v_cost_per_publication` vira post.
"Esse carrossel custou US$ 0,31 e alcançou 4.200 pessoas" é conteúdo — e é a tese.

---

## Alertas

| Condição | Ação |
|---|---|
| custo/dia > US$ 3 | notifica — Filtro Burro está falhando |
| taxa de rejeição do Editor < 50% | notifica — virou carimbo |
| Publisher falhou 4× | notifica |
| retenção D+7 < 20% em 3 seguidos | notifica — revisar tese |
| Radar 0 sinais por 2 dias | notifica — fonte quebrada |

---

## Ordem de construção

1. Supabase schema
2. Fluxo 1 (Radar interno + Filtro Burro) — sem LLM ainda
3. Fluxo 4 (Analytics) — mede o que já existe manual
4. Fluxo 2 até o Editor-Chefe
5. Resto do Fluxo 2
6. Fluxo 3

**Analytics antes do Copywriter.** Medir antes de produzir.
