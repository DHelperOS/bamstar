-- Create roles table
create table if not exists public.roles (
  id serial primary key,
  name text unique not null
);

comment on table public.roles is '역할 테이블';

-- Seed roles
insert into public.roles (name) values
  ('GUEST'), ('MEMBER'), ('PLACE'), ('ADMIN')
on conflict (name) do nothing;

-- Create users table referencing auth.users
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  role_id int not null references public.roles(id),
  ci text unique,
  is_adult boolean not null default false,
  email text unique,
  phone text unique,
  created_at timestamptz not null default now()
);

comment on column public.users.ci is '본인 인증 시 발급받는 고유 식별자(CI). 인증 전에는 NULL 상태.';
comment on column public.users.email is 'auth.users의 이메일 복사본. 소셜 로그인 등 경우에 따라 NULL일 수 있음.';
comment on column public.users.phone is 'auth.users의 휴대폰 번호 복사본. 소셜 로그인 등 경우에 따라 NULL일 수 있음.';

-- Default GUEST role via trigger when role_id is null
create or replace function public.set_default_guest_role()
returns trigger as $$
begin
  if new.role_id is null then
    select r.id into new.role_id from public.roles r where r.name = 'GUEST';
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_users_default_role on public.users;
create trigger trg_users_default_role
before insert on public.users
for each row execute function public.set_default_guest_role();

-- Devices table
create table if not exists public.devices (
  id bigserial primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  device_uuid text,
  device_os text,
  last_login_at timestamptz
);

comment on table public.devices is '사용자가 등록한 모든 기기의 목록을 관리합니다.';

-- Avoid duplicate device per user
create unique index if not exists uq_devices_user_device_uuid on public.devices (user_id, device_uuid);

-- RLS policies
alter table public.users enable row level security;
alter table public.devices enable row level security;

-- Users policies: insert/select/update own row
drop policy if exists users_insert_self on public.users;
create policy users_insert_self on public.users
  for insert to authenticated with check (id = auth.uid());

drop policy if exists users_select_self on public.users;
create policy users_select_self on public.users
  for select to authenticated using (id = auth.uid());

drop policy if exists users_update_self on public.users;
create policy users_update_self on public.users
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Devices policies: insert/select/update own devices
drop policy if exists devices_insert_own on public.devices;
create policy devices_insert_own on public.devices
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists devices_select_own on public.devices;
create policy devices_select_own on public.devices
  for select to authenticated using (user_id = auth.uid());

drop policy if exists devices_update_own on public.devices;
create policy devices_update_own on public.devices
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
