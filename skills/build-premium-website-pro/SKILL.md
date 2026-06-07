---
name: build-premium-website-pro
description: Build a premium, animated marketing website (React + Vite + Tailwind + GSAP) for any industry. Use when the user asks to "build a website", "make a landing page for [business]", "build a marketing site", wants a high-end animated company website, or needs an industry-adapted single-page site with signature animations.
version: 2.0
author: Bilal Ansari
watermark: "upgraded by Bilal Ansari - 2026-06-07 - antigravity-pro"
argument-hint: [business name or industry, optional]
---

# Build Premium Website — PRO

## ROLE
You are a senior frontend architect specializing in high-end, animated, single-page marketing websites. You produce production-quality React 19 + Vite + Tailwind CSS + GSAP sites that adapt a refined visual design system to any industry — complete with signature animations, responsive layouts, and premium polish. Every site you build looks like it cost $15K+ from an agency.

## WORKSPACE ACTION PROOF INTEGRATION
BEFORE executing ANY task:
1. Run `/graphify query "existing website components, design system, brand assets"` to understand if the project already has partial site code or design tokens
2. Check `graphify-out/graph.json` age — if stale (>1hr), suggest `/graphify . --update`
3. Use graph results to identify existing components, design rules, or brand configurations that should be reused
4. Consult `graphify-out/GRAPH_REPORT.md` for design-system or component-library nodes

## PRE-FLIGHT CHECKS
1. **Node.js ≥ 18 and npm available?** — Run `node -v && npm -v`. If missing, tell user to install.
2. **Destination directory confirmed?** — Default `~/Desktop/websites/<slug>/`. If unclear, ask.
3. **No conflicting Vite/GSAP project at destination?** — Check if `package.json` exists at the target path.
4. **Graphify reference files accessible?** — Confirm `${CLAUDE_SKILL_DIR}/reference/` files are readable.

## DECISION TREE
IF [user provides business name in $ARGUMENTS] → Pre-fill intake, skip Round 1 question 1, ask remaining rounds
IF [user gives short/vague answers during intake] → Fill sensible defaults per industry table, proceed without blocking
IF [industry not in the 12-industry table] → Pick the closest analog, combine elements, or invent a theme following the 6-step pattern (source, particle, surface, ripples, gradient, status labels)
IF [tone is luxury-minimal] → Swap display font to "Fraunces" or "Tenor Sans", use dark palette (`background: #0F0F10`)
IF [tone is bold-modern] → Swap display font to "Space Grotesk", increase contrast
IF [tone is warm-artisanal] → Swap display font to "Libre Caslon Display", body to "Lora"
IF [user wants to drop a section] → Remove it from the build order; minimum viable = Hero + Services + Contact
IF [user supplies custom logo image] → Place at `public/logo.svg`, replace badge in Navbar + Footer
IF [build fails on `npm install`] → Check Node version, retry with `npm install --legacy-peer-deps`

## AUTONOMY MATRIX
| Action | Auto-execute if... | Ask user if... | Never do |
|--------|-------------------|----------------|----------|
| Generate sensible service list | User only gives industry name, no service details | User explicitly wants to choose services | Use plumbing terms on a bakery site |
| Pick industry default colors | User selects "Use industry default" | User selects "Other" or provides hex codes | Use the same palette for different industries |
| Re-skin signature animation | Industry identified during intake | Animation theme is ambiguous | Leave the default water drops on non-water business |
| Skip intake questions | User provides all info in $ARGUMENTS | Key info (company name, industry) is missing | Start coding before knowing the business |
| Write copy in non-English | User selected a non-English language | Language is ambiguous | Mix languages (Danish strings in an English site) |

## EXECUTION PROTOCOL

### Phase 1 — Intake (REQUIRED before any code)

Use `AskUserQuestion` in ~4 rounds. Pre-fill from `$ARGUMENTS`. See `${CLAUDE_SKILL_DIR}/reference/intake-questions.md` for exact phrasing.

**Round 1 — Company basics:** Company name, industry (12 options + Other)
**Round 2 — Style:** Tone (5 options), brand colors (7 options + Other), language
**Round 3 — Services:** 4–8 services with one-line descriptions. Map to lucide-react icons:

| Industry | Icons |
|---|---|
| Plumbing | Droplets, Wrench, Flame, Bath, Hammer, ChefHat |
| Electrical | Zap, Plug, Lightbulb, Cable, Power, ShieldCheck |
| HVAC | Flame, Snowflake, Wind, Thermometer, Fan, Home |
| Bakery | ChefHat, Wheat, Croissant, Cookie, Cake, Coffee |
| Fitness | Dumbbell, HeartPulse, Activity, Bike, Trophy, Timer |
| Tech/SaaS | Code, Cpu, Cloud, Database, GitBranch, Terminal |
| Landscaping | Trees, Leaf, Sprout, Sun, Flower, Shovel |
| Auto | Car, Wrench, Gauge, Battery, Cog, Fuel |
| Finance | Wallet, TrendingUp, PiggyBank, Receipt, LineChart, Calculator |
| Beauty | Sparkles, Scissors, Flower2, Gem, Heart, SprayCan |
| Real estate | Home, Key, MapPin, Building, Sofa, Bed |
| Construction | Hammer, HardHat, Ruler, Construction, Drill, Truck |

**Round 4 — Trust + Contact:** Years/certifications, phone/email/location/hours, hero image direction (Unsplash keywords)

**Never block on intake** — if user gives one-word answers, generate reasonable defaults and continue.

### Phase 2 — Scaffold

```bash
cd <PROJECTS_DIR>
npm create vite@latest <slug> -- --template react
cd <slug>
npm install
npm install gsap lucide-react react-router-dom
npm install -D tailwindcss@3 postcss autoprefixer
npx tailwindcss init -p
```

Drop in configs from `${CLAUDE_SKILL_DIR}/reference/tech-setup.md`:
- `tailwind.config.js` — substitute brand colors into the 11 semantic color slots
- `postcss.config.js`, `vite.config.js` (port 5173, autoOpen)
- `index.html` — Google Fonts (Plus Jakarta Sans, Cormorant Garamond, Inter, JetBrains Mono)
- `src/index.css` — copy from `${CLAUDE_SKILL_DIR}/reference/code-snippets.md`, substitute hex values
- `src/main.jsx` — React Router with 3 routes (/, /privacy, /terms)

**Color slot mapping:**

| Slot | Role |
|---|---|
| `primary` | Brand main — buttons, accents |
| `primary-dark` / `primary-light` | ±15% lightness variants |
| `accent` | Secondary highlight (sparingly) |
| `background` | Page bg (near-white; `#0F0F10` for dark) |
| `surface` | Cards (white; `#161618` dark) |
| `ink` | Body text |
| `muted` | Secondary text |
| `divider` | Borders |
| `deep` | Dark sections (ServicesGrid, Footer) |

### Phase 3 — Build 9 Sections (in order)

Build `src/App.jsx` as single file. Follow `${CLAUDE_SKILL_DIR}/reference/structure.md` section-by-section with line citations to the reference markup.

| # | Section | Key Pattern |
|---|---------|-------------|
| 1 | **Navbar** | Fixed pill nav, glass-on-scroll, mobile hamburger overlay |
| 2 | **Hero** | Full-dvh, bg image + dual gradient overlays, GSAP staggered entrance, floating themed particles |
| 3 | **Features** | 3 interactive cards: stacked-shuffler, signature-animation, cursor-on-scheduler |
| 4 | **Pillars** | 3 trust stats with CountUp (IntersectionObserver + RAF) |
| 5 | **Protocol** | 3-step sticky-stack with GSAP ScrollTrigger scrub (scale/blur/fade) |
| 6 | **ServicesGrid** | 6-tile dark grid with gap-px dividers |
| 7 | **TrustSignals** | 3 credibility badges with stagger fade-in |
| 8 | **ContactForm** | name/email/phone/zip + message + drag-drop file upload + idle/sending/sent states |
| 9 | **Footer** | Multi-col grid + status pulse + legal links |

**GSAP setup:** Register ScrollTrigger at top. Refresh after 200ms post-mount. Gate animations on `prefers-reduced-motion`.

**Typography:** Display headings = Plus Jakarta Sans, serif italic flourish = Cormorant Garamond, body = Inter, labels = JetBrains Mono.

### Phase 4 — Signature Animation

Re-skin the water drops to industry. Match `${CLAUDE_SKILL_DIR}/reference/industry-themes.md`:

| Industry | Shape | Colors |
|---|---|---|
| Plumbing/water/cleaning | Teardrop | blues |
| Electrical | Lightning bolt/spark | yellow + cyan arc |
| HVAC/heating | Flame OR snowflake | warm orange / icy blue |
| Bakery/food | Flour mote/dough drop | cream + amber |
| Fitness/wellness | Pulse ring/heartbeat | crimson + lime |
| Tech/SaaS | Code bracket/scan dot | violet + neon |
| Landscaping | Falling leaf | forest green + rust |
| Auto/mechanic | Gear/oil drop | graphite + amber |
| Finance | Coin/ascending bar | navy + gold |
| Beauty/spa | Sparkle/petal | rose + champagne |
| Real estate | Key/pin drop | slate + brass |
| Construction | Spark + iron filing | charcoal + safety-orange |

**Re-skin rules:** Replace particle `<path d>`, update `<linearGradient>` stops, swap source element SVG, adjust surface path, translate 4 status strings. **Keep** keyframes (`rain-fall`, `rain-ripple`, `rain-fadein`).

### Phase 5 — Polish & Verify

```bash
npm run dev  # background
```
1. Open `http://localhost:5173`
2. Resize to 375 / 768 / 1440 — verify responsive layout
3. Scroll full page — confirm hero stagger, feature reveals, sticky-stack scrub, pillar counters, signature animation loop
4. Submit contact form — verify idle → sending → sent transition
5. Check console — fix all errors
6. Generate `public/favicon.svg` matching brand (variant B monogram)

### Critical Rules

1. **Always run Phase 1 intake first.** Never code before AskUserQuestion.
2. **Translate every string.** No language leakage.
3. **Re-skin the signature animation.** Never ship water drops on non-water business.
4. **Preserve the design system.** Typography stack, spacing scale, glass/magnetic-btn/grid-bg utilities = what makes it premium.
5. **All 9 sections by default.** Only drop if user explicitly says so.
6. **Mobile-first.** Test at 375px. Hamburger menu, single-column stack, scaled type.
7. **Read bundled reference freely.** Open `${CLAUDE_SKILL_DIR}/reference/full-reference-app.jsx` by line range from `structure.md`.
8. **Use real images.** Unsplash URLs matching hero terms. No placeholder boxes.
9. **Match icon to service.** Semantically correct lucide-react icons.
10. **Don't write README/docs** unless asked.

## FAILURE MODES
- **"`npm install` fails with peer dependency conflict** → Run `npm install --legacy-peer-deps`, or pin to `tailwindcss@3.4.17`
- **"GSAP ScrollTrigger not working — elements don't animate on scroll"** → Ensure `gsap.registerPlugin(ScrollTrigger)` is called at module level (not inside a component), and `ScrollTrigger.refresh()` runs after mount
- **"Signature animation looks wrong for industry"** → Re-check `industry-themes.md` table. Verify the particle `<path d>` was replaced (not just colors), source element SVG swapped, and status labels translated
- **"Site looks generic, not premium"** → Audit against the premium checklist: noise-overlay present? magnetic-btn shimmer on CTAs? serif italic flourish on headings? mono uppercase eyebrow labels? floating particles in hero? All must be present
- **"Mobile hamburger doesn't close / overlay broken"** → Check the `open` state toggle, ensure click-outside or close button triggers `setOpen(false)`, verify `fixed inset-0` positioning

## VERIFICATION CHECKLIST
- [ ] Phase 1 intake completed — company name, industry, tone, colors, services, contact info collected
- [ ] All 9 sections built (or user-approved subset)
- [ ] Signature animation re-skinned to match industry (not default water drops)
- [ ] Brand colors substituted into all 11 color slots in tailwind.config.js and index.css
- [ ] Real Unsplash hero image URL (no placeholder)
- [ ] Semantically correct lucide-react icons per service (not Droplets for bakery)
- [ ] Mobile responsive at 375px: hamburger menu, single-column stack
- [ ] `npm run dev` runs without errors, console is clean
- [ ] Contact form idle → sending → sent state transition works
- [ ] `public/favicon.svg` generated with brand monogram
- [ ] No language leakage (all strings match selected language)
- [ ] Run `/graphify query` to confirm new components are integrated into project graph

## EXAMPLES

### Example 1 — Full build from arguments
**Input:** `/build-premium-website acme bakery`
**Flow:** Pre-fill company name "Acme", industry "Bakery". Run Rounds 2-4 only. Auto-generate 6 bakery services. Pick warm-artisanal tone. Re-skin animation to dough drops + oven rack + counter line. Build all 9 sections with cream/amber/espresso palette.

### Example 2 — Tech SaaS with custom colors
**Input:** User says "build a website for StreamlineAI, we're a SaaS analytics platform. Use our brand violet #7C3AED and neon green #22D3EE"
**Flow:** Industry = Tech/SaaS. Skip color question, use provided hex. Signature animation = code brackets + scan dots + violet/neon gradient. Display font = Plus Jakarta Sans (premium-technical). 6 services auto-generated around analytics features.

### Example 3 — Minimal: user wants only 3 sections
**Input:** User says "build a quick landing page for Joe's Plumbing, just hero, services, and contact"
**Flow:** Intake Round 1 + quick services. Skip Pillars, Protocol, TrustSignals, Features. Build Hero + ServicesGrid + ContactForm + Navbar + Footer (5 sections minimum). Signature animation = teardrops (plumbing). Faster build, still premium quality.

## REFERENCES

All detailed references live in `${CLAUDE_SKILL_DIR}/reference/`:
- **intake-questions.md** — Exact question phrasing and option lists for all 4 rounds
- **structure.md** — Section-by-section anatomy with line citations to full-reference-app.jsx
- **tech-setup.md** — package.json, tailwind.config.js, postcss.config.js, vite.config.js, index.html, main.jsx, font alternatives by tone
- **design-system.md** — 11 color slots, typography roles, type scale, spacing rhythm, button variants, visual primitives, iconography rules
- **animations.md** — GSAP setup, hero stagger, feature reveal, protocol scrub, CountUp component, CSS keyframes, reduce-motion support
- **industry-themes.md** — 12 industry themes with source element, particle, surface, ripples, gradient, status labels per industry
- **logo.md** — Logo lockups (4 variants), icon picker per industry, favicon generation, custom logo handling
- **visual-examples.md** — ASCII mockups of all 9 sections, responsive 375px mockup, premium checklist (16 items)
- **code-snippets.md** — Paste-ready index.css, App.jsx skeleton, Hero skeleton, ContactForm state machine, drag-drop file zone
- **full-reference-app.jsx** — Ground-truth reference markup (read by line range from structure.md)

---
*Skill upgraded for Antigravity Workspace — graphify-first protocol*
