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
AyudaVenezuela's own Supabase project ref = `deomqpstbqcjtfxrnwif`, name `AyudaVe.Lat`
(dashboard: https://supabase.com/dashboard/project/deomqpstbqcjtfxrnwif,
URL: https://deomqpstbqcjtfxrnwif.supabase.co). Backs `link_suggestions` +
`admin_users` (see `supabase/migrations/0002_link_suggestions.sql`).

**It lives on its OWN Supabase account** — NOT the real-estate (Habitania) account.
So the `supabase` / `supabase-dev` MCP servers (refs `frpinstqlqykihdktbml` /
`ruqqxbnbcnpxgdyzopsy`) and their PAT canNOT reach AyudaVe. Use one of these instead:

- **A — native MCP (preferred for queries + migrations):** MCP server `supabase-ayudave`
  (scoped to `deomqpstbqcjtfxrnwif`, configured in `~/.claude.json`). Tools
  `mcp__supabase-ayudave__execute_sql`, `apply_migration`, etc. Loads at session start.
- **B — Management API (full SQL incl. DDL, works mid-session):** PAT in user env var
  `SUPABASE_AYUDAVE_PAT`. Quick check:
  `curl -sS -X POST https://api.supabase.com/v1/projects/deomqpstbqcjtfxrnwif/database/query -H "Authorization: Bearer $SUPABASE_AYUDAVE_PAT" -H "Content-Type: application/json" -d '{"query":"select 1"}'`
- **C — PostgREST (data read/write, bypasses RLS, no DDL):** service-role secret in
  local `.env` key `secret_key`. Hit `https://deomqpstbqcjtfxrnwif.supabase.co/rest/v1/<table>`
  with `apikey` + `Authorization: Bearer <secret_key>` headers.
- **D — direct Postgres (full power, scripted):** `.env` key `DB_password`. No `psql` on
  this machine — use node `pg` (install in scratchpad). Host
  `db.deomqpstbqcjtfxrnwif.supabase.co:5432` (may be IPv6-only; fall back to the IPv4 pooler).

Never commit these creds. `.env`, `~/.claude.json`, and the env var hold them; CLAUDE.md
only names the keys, never the values. Don't auto-fix the Habitania `email_messages` /
`email_events` RLS advisory — that's a different project.

## Email — use Resend (NOT the Gmail draft integration)
To send mail (e.g. summaries to community admins like Yennia), send via **Resend**.
Do NOT use the Gmail MCP — it can only create drafts, not send.

- **API key:** user env var `RESEND_API_KEY` (persistent, user-scope on this machine).
  Read from env; never hardcode/commit.
- **Verified sender domain:** `ayudavenezuela.lat` (status `verified`, us-east-1). Send
  `from` an address on it, e.g. `Ayuda Venezuela <hola@ayudavenezuela.lat>`.
  (`ayudavenezuela.com` is NOT verified — don't send from it.)
- **Set `reply_to`** to a real inbox (e.g. `ben_hain@readychatai.com`) so replies reach a human.
- **Send:** `POST https://api.resend.com/emails` with `Authorization: Bearer $RESEND_API_KEY`,
  JSON body `{from, to, reply_to, subject, html}`. Returns an email `id`; check delivery via
  `GET https://api.resend.com/emails/{id}`.
- Send UTF-8 bytes (Spanish accents/emoji) — PowerShell: pass
  `[Text.Encoding]::UTF8.GetBytes($body)` with `ContentType "application/json; charset=utf-8"`.

**Inbound / replies:** email TO this project (e.g. `avisos@ayudavenezuela.lat`, replies from
community admins) is received via **Resend inbound** — NOT the connected Gmail. List/read it:
- `GET https://api.resend.com/emails/inbound?limit=25` → recent received messages.
- `GET https://api.resend.com/emails/inbound/{id}` → full body (`text` / `html`).
So to check whether someone replied, poll the inbound endpoint, not Gmail. Set `reply_to`
on outbound sends if you want replies to reach a person's inbox instead of `avisos@`.
