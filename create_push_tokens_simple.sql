-- Create push_tokens table (execute this in Supabase Dashboard SQL Editor)
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  fcm_token text NOT NULL UNIQUE,
  device_id text,
  platform text CHECK (platform IN ('android', 'ios', 'web')),
  is_active boolean DEFAULT true NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL,
  CONSTRAINT push_tokens_user_device_unique UNIQUE (user_id, device_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS push_tokens_user_id_idx ON public.push_tokens (user_id);
CREATE INDEX IF NOT EXISTS push_tokens_active_idx ON public.push_tokens (user_id, is_active);

-- Enable RLS (Row Level Security)
ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for users" ON public.push_tokens
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for users" ON public.push_tokens
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update for users" ON public.push_tokens
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Enable delete for users" ON public.push_tokens
    FOR DELETE USING (auth.uid() = user_id);