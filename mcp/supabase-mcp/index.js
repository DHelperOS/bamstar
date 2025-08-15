const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(express.json());

const SUPABASE_URL = process.env.SUPABASE_URL || 'http://localhost:5433';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'anon_key_placeholder';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/users', async (req, res) => {
  const { data, error } = await supabase.from('users').select('*').limit(10);
  if (error) return res.status(500).json({ error });
  res.json({ data });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`MCP server listening on ${port}`));
