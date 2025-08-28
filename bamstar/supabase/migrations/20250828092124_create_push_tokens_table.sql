-- Create push tokens table for FCM token management
-- Supports multiple devices per user (important: UUID cannot be the primary key for multi-device support)
create table public.push_tokens (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) not null,
  fcm_token text not null,
  device_id text,
  platform text check (platform in ('android', 'ios', 'web')),
  is_active boolean not null default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  -- Ensure unique FCM tokens across the system
  constraint unique_fcm_token unique (fcm_token),
  -- Allow multiple devices per user but unique device_id per user
  constraint push_tokens_user_device_unique unique (user_id, device_id)
);

-- Create index for efficient queries by user
create index push_tokens_user_id_idx on public.push_tokens (user_id);
create index push_tokens_active_idx on public.push_tokens (user_id, is_active);

-- Enable RLS
alter table public.push_tokens enable row level security;

-- Create policies for push_tokens table
create policy "Users can view their own push tokens" on public.push_tokens
  for select using (auth.uid() = user_id);

create policy "Users can insert their own push tokens" on public.push_tokens
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own push tokens" on public.push_tokens
  for update using (auth.uid() = user_id);

create policy "Users can delete their own push tokens" on public.push_tokens
  for delete using (auth.uid() = user_id);

-- Create function to update updated_at column
create or replace function public.update_updated_at_push_tokens()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- Create trigger to automatically update updated_at
create trigger update_push_tokens_updated_at
  before update on public.push_tokens
  for each row
  execute function public.update_updated_at_push_tokens();