const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(express.json());

const SUPABASE_URL = process.env.SUPABASE_URL || 'http://localhost:5433';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'anon_key_placeholder';
const SUPABASE_DB_URL = process.env.SUPABASE_DB_URL || '';
const MCP_AUTH_TOKEN = process.env.MCP_AUTH_TOKEN || '';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const { Client } = require('pg');

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/users', async (req, res) => {
  const { data, error } = await supabase.from('users').select('*').limit(10);
  if (error) return res.status(500).json({ error });
  res.json({ data });
});

// List migrations available in repo path (assumes MCP runs from repo root)
app.get('/migrations/list', async (req, res) => {
  const fs = require('fs');
  const path = 'dev/supabase/migrations';
  try {
    const files = fs.readdirSync(path).filter(f => f.endsWith('.sql'));
    res.json({ files });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// Run a migration by filename. Protected by MCP_AUTH_TOKEN header.
app.post('/migrate', async (req, res) => {
  try {
    const token = req.headers['x-mcp-auth'] || '';
    if (!MCP_AUTH_TOKEN || token !== MCP_AUTH_TOKEN) {
      return res.status(401).json({ error: 'unauthorized' });
    }
    const { filename } = req.body || {};
    if (!filename) return res.status(400).json({ error: 'filename required' });
    const fs = require('fs');
    const path = `dev/supabase/migrations/${filename}`;
    if (!fs.existsSync(path)) return res.status(404).json({ error: 'migration not found' });
    if (!SUPABASE_DB_URL) return res.status(500).json({ error: 'SUPABASE_DB_URL not configured on MCP' });

    const sql = fs.readFileSync(path, 'utf8');
    const client = new Client({ connectionString: SUPABASE_DB_URL, ssl: { rejectUnauthorized: false } });
    await client.connect();
    try {
      await client.query('BEGIN');
      await client.query(sql);
      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      await client.end();
    }
    res.json({ ok: true, filename });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`MCP server listening on ${port}`));
