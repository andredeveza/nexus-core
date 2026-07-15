-- Nexus Core — Schema Supabase (Postgres)
-- Camada transacional. O normativo fica em Markdown no repo.
--
-- Decisão de arquitetura: knowledge graph em `nodes` + `edges`, não Neo4j.
-- Motivo: volume esperado < 10k nós. Postgres com índice resolve.
-- Neo4j seria custo operacional sem ganho. Revisar se passar de 100k nós.

-- ============================================================
-- RADAR
-- ============================================================

create table signals (
  id            uuid primary key default gen_random_uuid(),
  source        text not null check (source in ('internal','rss','manus')),
  type          text not null check (type in ('erro_proprio','metrica','arquitetura','custo','ferramenta','debate')),
  raw           text not null,
  url           text,
  possible_operation text not null,          -- vazio = sinal inválido (prompt 01)
  hash          text not null,               -- dedupe do Filtro Burro
  killed_by     text,                        -- null = passou o filtro
  captured_at   timestamptz not null default now()
);

create index on signals (hash, captured_at desc);
create index on signals (source, captured_at desc);

-- ============================================================
-- EDITOR-CHEFE
-- ============================================================

create table briefs (
  id              uuid primary key default gen_random_uuid(),
  signal_id       uuid references signals(id),
  decision        text not null check (decision in ('approve','reject')),
  reason          text not null,             -- obrigatório mesmo em reject
  angle           text,
  format          text check (format in ('reels','carousel','story')),
  priority        int,
  objective       text check (objective in ('autoridade','lead','venda','retencao','distribuicao')),
  evidence_needed text,
  created_at      timestamptz not null default now(),

  -- Const. Art. 4.3 + prompt 02: aprovado sem evidência é impossível
  constraint evidence_required_on_approve
    check (decision = 'reject' or (evidence_needed is not null and evidence_needed <> ''))
);

create index on briefs (decision, created_at desc);

-- ============================================================
-- ESTRATEGISTA
-- ============================================================

create table strategies (
  id          uuid primary key default gen_random_uuid(),
  brief_id    uuid not null references briefs(id),
  persona     text not null check (persona in ('operador_solo','dono_pme','construtor')),
  objective   text not null,
  narrative   jsonb not null,                -- {tensao, operacao, principio, convite}
  cta_id      text not null,                 -- ref a acervo/ctas.yaml
  ladder_step text check (ladder_step in ('gratis','playbook','blueprint','implementacao')),
  hypothesis  text not null,                 -- falseável — Analytics testa em D+7
  created_at  timestamptz not null default now()
);

-- ============================================================
-- PUBLICAÇÕES (memória central — Const. Art. 10)
-- ============================================================

create table publications (
  id            uuid primary key default gen_random_uuid(),
  brief_id      uuid not null references briefs(id),
  strategy_id   uuid not null references strategies(id),

  copy          jsonb not null,              -- saída do Copywriter
  art_spec      jsonb not null,              -- saída do Diretor de Arte

  status        text not null default 'scheduled'
                check (status in ('scheduled','published','failed','rejected_by_human')),
  approved_by   text,                        -- 'human' | 'auto'
  rejection_reason text,                     -- o dado mais valioso da Fase 1

  scheduled_for timestamptz,
  published_at  timestamptz,
  permalink     text,
  attempts      int default 0,
  error         text,

  created_at    timestamptz not null default now()
);

create index on publications (status, scheduled_for);
create index on publications (published_at desc);

-- ============================================================
-- MÉTRICAS (Const. Art. 10.2 — D+1, D+7, D+30)
-- ============================================================

create table metrics (
  id             uuid primary key default gen_random_uuid(),
  publication_id uuid not null references publications(id),
  window         text not null check (window in ('d1','d7','d30')),

  reach          int default 0,
  retention_pct  numeric(5,2),               -- MÉTRICA-GUIA fase 1-2
  saves          int default 0,
  shares         int default 0,
  comments       int default 0,
  clicks         int default 0,
  dms            int default 0,

  collected_at   timestamptz not null default now(),
  unique (publication_id, window)
);

-- ============================================================
-- INSIGHTS (Analytics)
-- ============================================================

create table insights (
  id                uuid primary key default gen_random_uuid(),
  publication_id    uuid references publications(id),
  hypothesis        text not null,
  hypothesis_result text not null check (hypothesis_result in ('confirmed','refuted','inconclusive')),
  insight           text not null,
  created_at        timestamptz not null default now()
);

-- Ângulos mortos → alimentam o Filtro Burro (Const. Art. 10.3)
create table dead_angles (
  id          uuid primary key default gen_random_uuid(),
  angle_hash  text not null unique,
  angle       text not null,
  failures    int not null default 1,
  killed_at   timestamptz not null default now()
);

-- Emendas propostas pelo Analytics (Const. Art. 11.4 — aprovação humana)
create table amendments (
  id         uuid primary key default gen_random_uuid(),
  article    text not null,
  evidence   text not null,
  proposal   text not null,
  status     text not null default 'proposed'
             check (status in ('proposed','accepted','rejected')),
  created_at timestamptz not null default now()
);

-- ============================================================
-- KNOWLEDGE GRAPH
-- ============================================================

create table nodes (
  id         uuid primary key default gen_random_uuid(),
  type       text not null check (type in
             ('persona','problema','ferramenta','produto','case','conteudo','cta','layout','principio')),
  label      text not null,
  props      jsonb default '{}',
  created_at timestamptz not null default now()
);

create table edges (
  id         uuid primary key default gen_random_uuid(),
  from_node  uuid not null references nodes(id),
  to_node    uuid not null references nodes(id),
  relation   text not null,                  -- 'resolve','gera','converte_em','ilustra'
  weight     numeric default 1.0,            -- Analytics ajusta com desempenho
  props      jsonb default '{}',
  created_at timestamptz not null default now()
);

create index on edges (from_node, relation);
create index on edges (to_node, relation);

-- ============================================================
-- CUSTO (a marca vende operação — o custo é público)
-- ============================================================

create table agent_costs (
  id         uuid primary key default gen_random_uuid(),
  agent      text not null,                  -- '01-radar' ... '07-analytics'
  brief_id   uuid references briefs(id),
  model      text,
  tokens_in  int,
  tokens_out int,
  cost_usd   numeric(10,4),
  created_at timestamptz not null default now()
);

create index on agent_costs (agent, created_at desc);

-- ============================================================
-- VIEWS
-- ============================================================

-- Cota de formato do ciclo atual (Const. Art. 8.1 — 70/20/10)
create view v_format_quota as
select
  (art_spec->>'format')                                             as format,
  count(*)                                                          as used,
  round(100.0 * count(*) / nullif(sum(count(*)) over (), 0), 1)     as pct
from publications
where status = 'published'
  and published_at > now() - interval '30 days'
group by 1;

-- Desempenho por persona → Estrategista
create view v_performance_by_persona as
select
  s.persona,
  count(distinct p.id)          as posts,
  round(avg(m.retention_pct),2) as avg_retention,
  sum(m.saves)                  as saves,
  sum(m.shares)                 as shares,
  sum(m.dms)                    as dms
from publications p
join strategies s on s.id = p.strategy_id
left join metrics m on m.publication_id = p.id and m.window = 'd7'
where p.status = 'published'
group by 1;

-- Custo por publicação (vira conteúdo — build in public)
create view v_cost_per_publication as
select
  p.id,
  p.permalink,
  round(sum(c.cost_usd), 4) as cost_usd,
  m.reach,
  case when m.reach > 0
       then round(sum(c.cost_usd) / m.reach * 1000, 4)
  end as cost_per_1k_reach
from publications p
left join agent_costs c on c.brief_id = p.brief_id
left join metrics m on m.publication_id = p.id and m.window = 'd7'
group by p.id, p.permalink, m.reach;

-- Taxa de rejeição do Editor-Chefe (saudável: 70-80%)
create view v_editor_rejection_rate as
select
  date_trunc('week', created_at)                                        as week,
  count(*) filter (where decision = 'reject')                           as rejected,
  count(*)                                                              as total,
  round(100.0 * count(*) filter (where decision = 'reject') / count(*), 1) as reject_pct
from briefs
group by 1
order by 1 desc;
