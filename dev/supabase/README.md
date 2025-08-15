Supabase local setup (quick)

This folder contains a minimal docker-compose and sample env for connecting to a Supabase project.

Supabase CLI (recommended)

macOS (Homebrew):

```bash
brew install supabase/tap/supabase
```

Linux (deb-based):

```bash
# see https://supabase.com/docs/guides/cli
curl -sL https://supabase.com/cli/install | sh
```

Windows (scoop/choco):

```powershell
scoop install supabase
# or
choco install supabase
```

Quick start

```bash
cp .env.sample .env
supabase login                # opens browser for supabase.com auth
supabase init                 # initializes local supabase config
supabase start                # starts local emulation (requires supabase CLI)
```

Notes
- Your `.env.sample` currently points to a hosted Supabase instance (NEXT_PUBLIC_SUPABASE_URL). If you want to emulate locally, update `.env` accordingly.
- Keep keys out of git; never commit `.env`.
