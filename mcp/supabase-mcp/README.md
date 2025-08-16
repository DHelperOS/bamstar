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

Migration usage
--------------

This MCP exposes endpoints to list and run SQL migrations located in `dev/supabase/migrations`.

Environment variables:

- `SUPABASE_DB_URL` - Postgres connection string used to connect to the Supabase database (service role or db user).
- `MCP_AUTH_TOKEN` - token required in the `X-MCP-AUTH` header to call the `/migrate` endpoint.

Endpoints:

- `GET /migrations/list` - returns the `.sql` files under `dev/supabase/migrations`.
- `POST /migrate` - apply a migration. JSON body: `{ "filename": "20250816_init_users_roles_devices.sql" }` and header `X-MCP-AUTH: <token>`.

Example:

```bash
curl -X POST "http://mcp-host:3000/migrate" \
	-H "Content-Type: application/json" \
	-H "X-MCP-AUTH: ${MCP_AUTH_TOKEN}" \
	-d '{"filename":"20250816_init_users_roles_devices.sql"}'
```

Security notes: run MCP in a trusted network, use a strong `MCP_AUTH_TOKEN`, and avoid exposing it to the public internet for production databases.
