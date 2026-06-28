-- Ayuda Venezuela — community link suggestions with admin curation.
-- Public visitors can submit pending suggestions. Only authenticated users
-- allowlisted in public.admin_users can read and curate the queue.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  email      text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.link_suggestions (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  title           text not null check (char_length(title) between 3 and 140),
  url             text not null check (char_length(url) between 8 and 500),
  category        text not null check (char_length(category) <= 60),
  link_type       text not null default 'website'
                    check (link_type in ('website','whatsapp_channel','whatsapp_group','social','document','other')),
  description     text check (char_length(description) <= 1200),
  verification    text check (char_length(verification) <= 1200),
  submitter_name  text check (char_length(submitter_name) <= 120),
  submitter_email text check (char_length(submitter_email) <= 200),
  status          text not null default 'pending'
                    check (status in ('pending','approved','rejected','archived')),
  admin_notes     text check (char_length(admin_notes) <= 1200),
  reviewed_by     uuid references auth.users(id),
  reviewed_at     timestamptz
);

create index if not exists link_suggestions_status_created_idx
  on public.link_suggestions (status, created_at desc);

create or replace function public.set_link_suggestions_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_link_suggestions_updated_at on public.link_suggestions;
create trigger set_link_suggestions_updated_at
  before update on public.link_suggestions
  for each row execute function public.set_link_suggestions_updated_at();

alter table public.admin_users enable row level security;
alter table public.link_suggestions enable row level security;

drop policy if exists "admin_users_read_self" on public.admin_users;
create policy "admin_users_read_self"
  on public.admin_users for select to authenticated
  using (user_id = auth.uid());

drop policy if exists "link_suggestions_public_insert_pending" on public.link_suggestions;
create policy "link_suggestions_public_insert_pending"
  on public.link_suggestions for insert to anon
  with check (
    status = 'pending'
    and reviewed_by is null
    and reviewed_at is null
    and admin_notes is null
  );

drop policy if exists "link_suggestions_admin_select" on public.link_suggestions;
create policy "link_suggestions_admin_select"
  on public.link_suggestions for select to authenticated
  using (exists (
    select 1 from public.admin_users au where au.user_id = auth.uid()
  ));

drop policy if exists "link_suggestions_admin_update" on public.link_suggestions;
create policy "link_suggestions_admin_update"
  on public.link_suggestions for update to authenticated
  using (exists (
    select 1 from public.admin_users au where au.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.admin_users au where au.user_id = auth.uid()
  ));

revoke all on public.admin_users from anon, authenticated;
revoke all on public.link_suggestions from anon, authenticated;

grant select on public.admin_users to authenticated;
grant insert (title, url, category, link_type, description, verification, submitter_name, submitter_email, status)
  on public.link_suggestions to anon;
grant select, update (status, admin_notes, reviewed_by, reviewed_at)
  on public.link_suggestions to authenticated;

-- After creating Supabase Auth users for the admin team, add each one here:
-- insert into public.admin_users (user_id, email)
-- values ('00000000-0000-0000-0000-000000000000', 'admin@example.com');
