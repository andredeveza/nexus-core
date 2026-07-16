# Agente 06 — PUBLISHER

**Executor:** n8n + Instagram Graph API
**LLM:** nenhum. Esta camada é código.

---

## Papel

Agendar, publicar, distribuir. Sem julgamento.

Você não decide nada. Se chegou aqui, já foi decidido.

---

## Entrada

```json
{
  "brief_id": "uuid",
  "art_spec": {...},
  "copy": {...},
  "approved_by": "human|auto",
  "scheduled_for": "iso8601"
}
```

---

## Processo

### 1. Registro ANTES de publicar (Const. Art. 10.1)

```sql
INSERT INTO publications (id, brief_id, status, scheduled_for, ...)
VALUES (..., 'scheduled', ...);
```

Publicar sem registrar = o sistema não aprende. É bug.

### 2. Janela de publicação

Definida por dado, não por achismo.
Fase 1: usar o horário de maior atividade histórica do perfil.
Sem dado suficiente → 19h-21h (padrão BR), e o Analytics corrige depois.

### 3. Publicação

Instagram Graph API. Container → publish.

### 4. Retry

Backoff exponencial: 1min, 2min, 4min, 8min. Máximo 4 tentativas.

Rate limit **não é erro fatal**. É esperado. Trata e segue.

### 5. Falha final

Após 4 tentativas → notifica humano. Status `failed`.
**Nunca "dar um jeito".** Nunca publicar versão alternativa por conta própria.

---

## Saída

```json
{
  "publication_id": "uuid",
  "status": "published|failed",
  "published_at": "iso8601",
  "permalink": "https://instagram.com/p/...",
  "attempts": 1,
  "error": null
}
```

---

## Distribuição derivada

Após publicar com sucesso:
1. Stories derivados (de `copy.stories_derived`) → 2h depois
2. Primeiro comentário → imediato
3. Se persona = `construtor` e tem link de repo → cross-post no X/Threads

---

## Restrições

- Nunca alterar copy. Nem uma vírgula.
- Nunca alterar arte.
- Nunca republicar automaticamente.
- Falha é estado válido. Reportar > improvisar.
