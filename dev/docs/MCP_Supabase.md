# Supabase MCP for SuperClaude

This file documents how to start a Supabase MCP for this project and where secrets are stored.

Secrets saved to macOS Keychain by the assistant (account `bamstar`):

- `bamstar.NEXT_PUBLIC_SUPABASE_URL`
- `bamstar.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY`
- `bamstar.SUPABASE_ANON_KEY`
- `bamstar.SUPABASE_SERVICE_ROLE_KEY`
- `bamstar.SUPABASE_DB_URL`
- `bamstar.MCP_AUTH_TOKEN`

Runner script created locally at: `~/.claude/run_supabase_mcp.sh`

What the runner does:

- Reads each secret from macOS Keychain and exports them as environment variables.
- Executes a placeholder starter command:

  `npx -y @21st-dev/supabase-mcp start --transport stdio`

If you have a different Supabase MCP package or script, edit `~/.claude/run_supabase_mcp.sh` and replace the exec line.

Start the MCP in background and capture logs:

```bash
nohup ~/.claude/run_supabase_mcp.sh > /tmp/supabase_mcp.log 2>&1 & echo $! > /tmp/supabase_mcp.pid
tail -n 200 /tmp/supabase_mcp.log
```

After the service starts, run `claude mcp list` to verify it appears and is healthy.

Security notes:

- Keys are stored in macOS Keychain under account `bamstar`. Only processes run by the current user can access them.
- Do not commit secrets into version control. This file documents locations only; it does not contain secret values.
