-- Gumsumi core schema: subscription licence, settings, activity log, admin stats.
-- Applied to project gpcqnsmdcosdulhyseqb on 2026-10-25.

create table if not exists public.subscription (
  id              integer primary key default 1 check (id = 1),
  status          text not null default 'active',
  paid_until      timestamptz,
  monthly_amount  integer not null default 500000,
  squad_token_id  text,
  email           text,
  last_reference  text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create table if not exists public.subscription_payments (
  id          bigserial primary key,
  reference   text unique not null,
  amount      integer not null default 0,
  status      text not null default 'pending',
  email       text,
  token_id    text,
  kind        text,
  paid_until  timestamptz,
  raw         jsonb,
  created_at  timestamptz not null default now(),
  paid_at     timestamptz
);

create table if not exists public.app_settings (
  key         text primary key,
  value       text,
  updated_at  timestamptz not null default now()
);

create table if not exists public.activity_log (
  id          bigserial primary key,
  created_at  timestamptz not null default now(),
  level       text default 'info',
  source      text,
  message     text,
  ref         text,
  username    text,
  mac         text
);

create index if not exists idx_sub_payments_status on public.subscription_payments(status);
create index if not exists idx_activity_log_created on public.activity_log(created_at desc);

insert into public.subscription (id, status, paid_until, monthly_amount)
values (1, 'active', now() + interval '3 days', 500000)
on conflict (id) do nothing;

insert into public.app_settings (key, value) values
  ('payment_provider', 'Squad'),
  ('contact_method', 'whatsapp')
on conflict (key) do nothing;

alter table public.subscription enable row level security;
alter table public.subscription_payments enable row level security;
alter table public.app_settings enable row level security;
alter table public.activity_log enable row level security;

create extension if not exists pg_cron;
create extension if not exists pg_net;

create or replace function public.admin_stats()
returns table (
  processed bigint,
  expired bigint,
  pending bigint,
  signups_today bigint,
  total_users bigint
)
language sql stable as $$
  select
    count(*) filter (where status = 'processed'),
    count(*) filter (where status = 'expired'),
    count(*) filter (where status = 'pending'),
    count(*) filter (where (created_at at time zone 'Africa/Lagos')::date = (now() at time zone 'Africa/Lagos')::date),
    count(*)
  from public.payment_queue;
$$;

create or replace function public.admin_daily(p_month text)
returns table (day integer, signups bigint)
language sql stable as $$
  select extract(day from (created_at at time zone 'Africa/Lagos'))::int as day,
         count(*) as signups
  from public.payment_queue
  where to_char(created_at at time zone 'Africa/Lagos', 'YYYY-MM') = p_month
  group by 1
  order by 1;
$$;

create or replace function public.admin_monthly()
returns table (month text, month_raw text, signups bigint)
language sql stable as $$
  select to_char(created_at at time zone 'Africa/Lagos', 'YYYY-MM') as month,
         to_char(created_at at time zone 'Africa/Lagos', 'YYYY-MM') as month_raw,
         count(*) as signups
  from public.payment_queue
  group by 1, 2
  order by 2;
$$;

grant execute on function public.admin_stats() to service_role;
grant execute on function public.admin_daily(text) to service_role;
grant execute on function public.admin_monthly() to service_role;
