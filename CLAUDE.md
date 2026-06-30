# Ayuda Venezuela — project rules

## Classifieds stay OFF. Link suggestions are the active community workflow.
The "Clasificados" / Ofrezco–Necesito board is **disabled on purpose**. There are already
too many classifieds sites; this project deliberately does not add another.

- Do **NOT** set `PUBLIC_CLASSIFIEDS_ENABLED=true` (Coolify env or Dockerfile build arg).
- Do **NOT** un-hide the homepage quick-nav chip / teaser CTA or surface the `/clasificados`
  board.
- It only gets enabled when the user says, **in that message**, to enable classifieds.
  "Fix the env / redeploy / make it consistent" is **not** permission to turn it on.
- If a deploy or a Coolify duplicate-env bug ever flips it back on, **turn it off again**
  (delete the `PUBLIC_CLASSIFIEDS_ENABLED` env so it falls back to the Dockerfile default `false`).
- The email-relay pieces stay dormant too.

The code can stay in the repo (gated behind the flag); just never ship it enabled. Community
submissions should go through `/sugerir/`, then a small admin group reviews them at
`/admin/sugerencias/`.

## Design
Warm "golden hour over El Ávila" identity — Hanken Grotesk; sand/gold/green/red/sky palette
(see `src/styles/global.css` `:root`). Logo = `public/logo.png` (the sun-heart over the hand).
Keep it warm, friendly, and **compact** — minimize vertical scrolling, use horizontal space.

## Hosting
Static Astro on Coolify (app `flqqe4804uyjxtgivp8e1ekw`, project AyudaVe, Chicago Host),
public via the Cloudflare tunnel `openocr`. Deploy = push to `main` + trigger a Coolify deploy.
`PUBLIC_*` vars reach the build as Dockerfile build args. Never commit `.env`.

## Supabase (link suggestions backend)
AyudaVenezuela's own Supabase project ref = `deomqpstbqcjtfxrnwif`
(dashboard: https://supabase.com/dashboard/project/deomqpstbqcjtfxrnwif,
URL: https://deomqpstbqcjtfxrnwif.supabase.co). Backs `link_suggestions` +
`admin_users` (see `supabase/migrations/0002_link_suggestions.sql`).
**NOTE:** the connected `supabase` / `supabase-dev` MCP servers point at the
real-estate (Habitania) prod/dev projects, NOT this one — they cannot touch
AyudaVe's DB. Run AyudaVe SQL via the dashboard SQL editor for `deomqpstbqcjtfxrnwif`.
