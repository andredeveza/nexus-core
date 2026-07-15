# Nexus Core

Sistema operacional de conteúdo baseado em IA.
Primeira implementação: Instagram [@trafegodigitalad](https://instagram.com/trafegodigitalad) — AD Tráfego Digital.

---

## O que é

O Nexus não cria posts. O Nexus constrói autoridade.
Cada publicação é consequência da estratégia, não o objetivo dela.

A inteligência fica na **arquitetura**, não no prompt.
Modelos de IA (Claude, GPT, Gemini, Manus) são executores especializados de camadas específicas.

## A tese editorial

> **Não te ensino IA. Te mostro o meu sistema rodando.**

O mercado está saturado de gente *explicando* IA.
Está vazio de gente *operando* IA e mostrando a operação por dentro.

O Nexus é ao mesmo tempo a ferramenta e o assunto: construção em público.
Ver [`docs/ad-bible.md`](docs/ad-bible.md).

---

## Arquitetura em uma tela

```
RADAR → EDITOR-CHEFE → ESTRATEGISTA → COPYWRITER → DIRETOR DE ARTE → PUBLISHER
  ↑                                                                      ↓
  └──────────────────────── ANALYTICS ←──────────────────────────────────┘
                                 ↓
                            MEMÓRIA (Supabase)
```

Sete camadas. Cada uma tem um contrato de entrada e saída definido.
Nenhuma camada inventa: todas consultam a Constituição, a AD Bible e o Acervo.

Detalhes em [`docs/architecture.md`](docs/architecture.md).

---

## Stack

| Camada | Ferramenta | Por quê |
|---|---|---|
| Normativo (constituição, prompts, acervo) | Markdown/YAML neste repo | Versionável, lido direto pelos agentes |
| Transacional (memória, métricas, grafo) | Supabase (Postgres) | Cresce sem limite, API pronta |
| Orquestração | n8n | Cron, retry, estado — LLM não faz isso |
| Executores | Claude / GPT / Manus | Um por camada, especializado |
| Design System | [ADTrafegoDigital_DesignSystem](https://github.com/andredeveza/ADTrafegoDigital_DesignSystem) | Fonte de verdade visual |

**Manus** entra apenas no Radar (pesquisa exploratória). Não é espinha dorsal — não tem cron confiável nem retry.

---

## Estrutura

```
nexus-core/
├── docs/
│   ├── architecture.md      # 7 camadas, contratos, fluxo
│   ├── constitution.md      # camada normativa — regras invioláveis
│   ├── ad-bible.md          # tese, método AD, vocabulário, exemplos
│   ├── design-system.md     # tokens espelhados + regras de arte
│   └── data-model.md        # schema Supabase + knowledge graph
├── prompts/
│   ├── 01-radar.md
│   ├── 02-editor-chefe.md
│   ├── 03-estrategista.md
│   ├── 04-copywriter.md
│   ├── 05-diretor-arte.md
│   ├── 06-publisher.md
│   └── 07-analytics.md
├── knowledge/
│   ├── personas.yaml        # 3 personas + oferta
│   ├── principios.md
│   └── acervo/
│       ├── hooks.yaml
│       ├── headlines.yaml
│       ├── ctas.yaml
│       └── layouts.yaml
├── runtime/
│   ├── supabase-schema.sql
│   └── n8n-flow.md
└── ROADMAP.md
```

---

## Estado atual

**Fase 0 — especificação.** Nada roda ainda.

O gargalo real do perfil hoje não é produção de conteúdo (90 posts, 622 seguidores,
94 visualizações/30d). É **formato e tese**. O Nexus só deve automatizar depois que
o formato Reels for validado manualmente. Ver [`ROADMAP.md`](ROADMAP.md).

Automatizar antes de validar = multiplicar o que já não funciona.

---

## Como um agente usa este repo

Ordem de leitura obrigatória para qualquer LLM que for executar uma camada:

1. `docs/constitution.md` — o que nunca pode ser violado
2. `docs/ad-bible.md` — como a marca pensa e fala
3. `knowledge/personas.yaml` — para quem
4. `prompts/0X-<camada>.md` — o seu papel específico
5. `knowledge/acervo/` — consulte antes de criar do zero

Regra: **nenhum agente cria do zero.** Consulta o Acervo primeiro.

---

© 2026 AD Tráfego Digital.
