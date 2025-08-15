Supabase MCP server (minimal)

Setup:

1. Copy `.env.sample` from `dev/supabase` to `dev/supabase/.env` and edit if needed.
2. Start Supabase/Postgres (local) with docker-compose:

```bash
cd dev/supabase
docker-compose up -d
```

3. Install and run the MCP server:

```bash
cd mcp/supabase-mcp
npm install
SUPABASE_URL=http://localhost:5433 SUPABASE_ANON_KEY=anon_key npm start
```

The server exposes:
- GET /health
- GET /users (reads from `users` table in Supabase)

This is a minimal example. For production, implement auth, migrations, and secrets handling.
