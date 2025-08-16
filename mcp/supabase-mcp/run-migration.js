#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

async function main() {
  try {
    const sqlPathArg = process.argv[2] || 'dev/supabase/migrations/20250816_init_users_roles_devices.sql';
    const sqlPath = path.resolve(process.cwd(), sqlPathArg);
    const conn = process.env.SUPABASE_DB_URL;
    if (!conn) {
      console.error('ERROR: SUPABASE_DB_URL not set in environment');
      process.exit(1);
    }
    if (!fs.existsSync(sqlPath)) {
      console.error(`ERROR: SQL file not found: ${sqlPath}`);
      process.exit(1);
    }
    const sql = fs.readFileSync(sqlPath, 'utf8');
    console.log(`Applying migration file: ${sqlPath}`);

    const client = new Client({ connectionString: conn, ssl: { rejectUnauthorized: false } });
    await client.connect();
    try {
      await client.query('BEGIN');
      await client.query(sql);
      await client.query('COMMIT');
      console.log('Migration applied successfully');
    } catch (err) {
      await client.query('ROLLBACK');
      console.error('Migration failed, rolled back. Error:', err.message || err);
      process.exitCode = 2;
    } finally {
      await client.end();
    }
  } catch (err) {
    console.error('Unhandled error:', err.message || err);
    process.exit(1);
  }
}

main();
