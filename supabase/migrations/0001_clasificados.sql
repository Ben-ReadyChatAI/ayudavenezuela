-- Ayuda Venezuela — classifieds (ofrezco / necesito servicios)
-- Run in Supabase project deomqpstbqcjtfxrnwif (SQL editor).
-- Two contact modes:
--   * whatsapp -> stored PUBLIC, rendered as a wa.me link
--   * email    -> stored PRIVATE (never exposed to anon); reached via the
--                 `contactar` edge function (relay), so the email stays hidden.

create extension if not exists pgcrypto;

create table if not exists public.clasificados (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  tipo          text not null check (tipo in ('ofrezco','necesito')),
  categoria     text not null check (char_length(categoria) <= 40),
  titulo        text not null check (char_length(titulo) between 3 and 120),
  descripcion   text check (char_length(descripcion) <= 1000),
  estado        text check (char_length(estado) <= 40),
  ciudad        text check (char_length(ciudad) <= 80),
  contacto_tipo text not null check (contacto_tipo in ('whatsapp','email')),
  whatsapp      text check (char_length(whatsapp) <= 25),   -- PUBLIC (digits + country code)
  email         text check (char_length(email) <= 200),     -- PRIVATE — never granted to anon
  status        text not null default 'publicado' check (status in ('publicado','pendiente','oculto')),
  constraint contacto_presente check (
    (contacto_tipo = 'whatsapp' and whatsapp is not null) or
    (contacto_tipo = 'email'    and email    is not null)
  )
);

create index if not exists clasificados_created_idx on public.clasificados (created_at desc);

alter table public.clasificados enable row level security;

-- Read only published rows
drop policy if exists "clasificados_read_published" on public.clasificados;
create policy "clasificados_read_published"
  on public.clasificados for select using (status = 'publicado');

-- Anonymous insert, forced to 'publicado'
drop policy if exists "clasificados_anon_insert" on public.clasificados;
create policy "clasificados_anon_insert"
  on public.clasificados for insert to anon with check (status = 'publicado');

-- Column-level privacy: anon may READ all columns EXCEPT email; may INSERT all fields.
revoke all on public.clasificados from anon;
grant select (id, created_at, tipo, categoria, titulo, descripcion, estado, ciudad,
              contacto_tipo, whatsapp, status) on public.clasificados to anon;
grant insert (tipo, categoria, titulo, descripcion, estado, ciudad,
              contacto_tipo, whatsapp, email, status) on public.clasificados to anon;

-- The `contactar` edge function uses the service-role key (bypasses RLS) to read
-- the private email and send the relayed message — the email is never returned to the browser.

-- ── Optional moderation: queue posts for review ─────────────────────────────
--   alter table public.clasificados alter column status set default 'pendiente';
--   -- approve by setting status='publicado'; the read policy already hides the rest.
