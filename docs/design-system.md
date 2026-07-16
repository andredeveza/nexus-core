# Design System — espelho operacional

Fonte de verdade: [andredeveza/ADTrafegoDigital_DesignSystem](https://github.com/andredeveza/ADTrafegoDigital_DesignSystem)
Este documento é o **espelho** que o Diretor de Arte lê. Em divergência, o repositório original vence.

---

## Conceito

Empresa de tecnologia de alto nível para IA aplicada a negócios e marketing.

Atributos: autoridade · tecnologia · inteligência · clareza · alto valor · sofisticação · confiança.
Referências: Apple, OpenAI, Notion, Stripe, Arc, Linear, Vercel.

Estilo: minimalista, futurista, elegante, clean, editorial, premium.
**Nunca:** genérico, amador, infantil, excessivamente colorido.

> **Nota de divergência (2026-07):** o feed atual não cumpre este conceito.
> Cards com 6 features empilhadas, rosto em quase todas as peças, densidade alta.
> O Design System prega Linear; a execução entrega tecnologia genérica.
> O Art. 9.6 da Constituição (uma ideia por card) existe para corrigir isso.

---

## Tokens

```css
/* Modo escuro (padrão premium) */
--ink:        #06070A;  /* fundo principal */
--graphite:   #101319;  /* painéis / cards */
--slate:      #1B212B;  /* superfícies elevadas */
--gray:       #8B94A3;  /* texto secundário */
--title:      #EEF1F6;  /* títulos */

/* Marca */
--blue-deep:  #0A47A8;  /* cor da marca, CTAs */
--blue:       #1C7ED6;  /* primária, gradientes */
--neon:       #57A8FF;  /* destaque, glow — uso mínimo */

/* Modo claro */
--bg-light:   #FFFFFF;
--panel-light:#F4F6FA;
--title-light:#0A0C10;
--text-light: #5A6474;
--cta-light:  #0A47A8;

/* Painel editorial */
--loud:       #1C4FE0;

/* Gradiente */
--brand-gradient: linear-gradient(135deg, #0A47A8, #1C7ED6 55%, #57A8FF);
```

**Regra do neon** (Const. Art. 9.4): destaque, glow, microdetalhe. Nunca fundo de área grande.

**Ritmo** (Art. 9.5): o feed alterna claro/escuro **de propósito**. Nunca 3 seguidos no mesmo modo.

---

## Tipografia

| Uso | Fonte | Pesos |
|---|---|---|
| Display / títulos | **Satoshi** | 700 / 900 |
| Corpo / leitura | **General Sans** | 400 / 500 |
| Dados / prompts / chrome | **JetBrains Mono** | 400 / 500 |
| Frases editoriais | **Instrument Serif** | 400 |

Escala: Display 46px+ · Título 30px · Subtítulo 20px · Corpo 15px
Tracking negativo nos títulos: `-.02em`

**Mapeamento por layout:**
- `hero` → Satoshi 900
- `data` → JetBrains Mono 500 (o número é o herói)
- `quote` → Instrument Serif 400
- `screen` → JetBrains Mono 400
- chrome → JetBrains Mono uppercase, tracking largo

---

## Elementos visuais

Grid técnico fino · glow neon discreto · glassmorphism leve · formas geométricas ·
linhas e nós de dados · espaçamento amplo · hierarquia clara.

Blur em brilhos de fundo. **Nunca em texto.**

---

## Chrome do carrossel editorial

```
Topo:    @trafegodigitalad · AD TRÁFEGO DIGITAL · ©2026
Rodapé:  ✦ ARRASTE PARA O LADO →
```

JetBrains Mono, uppercase, tracking largo.

---

## Imagens

Pessoas em ambiente tecnológico, escritórios modernos, dados, interfaces, hologramas discretos,
fundo desfocado, iluminação cinematográfica.

**Evitar:** clichês de robôs.

Assets disponíveis:
- `founder-dark` → conteúdo técnico
- `founder-office` → conteúdo de negócio
- `founder-window` → editorial

> Usar com moderação. O feed atual satura de rosto.
> Se o título é forte, não use foto — foto compete com texto.

**Print de tela:** sempre real. Mockup é violação da tese (a marca vende operação, não teatro).

---

## Formatos

- Feed: 1080 × 1350 (4:5)
- Stories / Reels: 1080 × 1920 (9:16)
- Destaques: capas circulares

---

## Tom de voz

Direto e técnico (autoridade) · provocativo (hooks fortes) · educativo.
Poucas palavras, muito impacto.

Detalhamento completo em `docs/ad-bible.md` §5-6.

---

## Princípio

> Toda arte pertence à mesma marca.
> Mesmo sem o logotipo, deve ser reconhecível como @trafegodigitalad.

Um único diretor de arte. Uma só marca.
