# BamStar Supabase Management Guide

**Last Updated:** 2025-08-28  
**Project:** BamStar  
**Project ID:** `tflvicpgyycvhttctcek`  
**Region:** Northeast Asia (Seoul)  
**Environment:** Production

---

## 🔑 Authentication & Access Tokens

### **Access Tokens**
```bash
# Primary Supabase CLI Access Token
export SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b

# MCP Server Auth Token
export MCP_AUTH_TOKEN=sb_secret_6gi2ZmG0XtspzcWuGVUkFw_OLfPWItH
```

### **Database Credentials**
- **Host:** `aws-1-ap-northeast-2.pooler.supabase.com`
- **Port:** `6543`
- **Database:** `postgres`
- **Username:** `postgres.tflvicpgyycvhttctcek`
- **Password:** `!@Wnrsmsek1`

---

## 🛠️ Essential Management Commands

### **Project Management**
```bash
# List all projects
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects list

# Get project details
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase projects api-keys --project-ref tflvicpgyycvhttctcek

# Link local environment to project
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase link --project-ref tflvicpgyycvhttctcek
```

### **Database Operations**
```bash
# Execute SQL query
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "SELECT COUNT(*) FROM users;"

# Execute SQL file
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --file migration.sql

# Database schema dump
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db dump --linked -f schema_dump.sql

# Push local migrations to remote
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db push --project-ref tflvicpgyycvhttctcek

# Reset database to latest migrations
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db reset --linked
```

### **Migration Management**
```bash
# Create new migration
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase migration new migration_name

# List all migrations
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase migration list --project-ref tflvicpgyycvhttctcek

# Apply specific migration
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase migration apply --project-ref tflvicpgyycvhttctcek
```

### **Edge Functions Management**
```bash
# List all edge functions
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions list --project-ref tflvicpgyycvhttctcek

# Deploy specific edge function
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy hashtag-processor --project-ref tflvicpgyycvhttctcek

# Deploy all edge functions
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy --project-ref tflvicpgyycvhttctcek

# Deploy with no JWT verification (for development)
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy function-name --project-ref tflvicpgyycvhttctcek --no-verify-jwt
```

---

## 📊 Monitoring & Health Checks

### **Database Health**
```bash
# Check connection status
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase status

# Check table counts
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
SELECT 
  schemaname,
  tablename,
  n_tup_ins as inserts,
  n_tup_upd as updates,
  n_tup_del as deletes
FROM pg_stat_user_tables 
ORDER BY n_tup_ins DESC;"

# Check active connections
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
SELECT COUNT(*) as active_connections 
FROM pg_stat_activity 
WHERE state = 'active';"
```

### **Performance Monitoring**
```bash
# Check slow queries
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;"

# Check table sizes
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
SELECT 
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"
```

---

## 🚀 Deployment Procedures

### **Pre-Deployment Checklist**
- [ ] Test migrations locally with `supabase start`
- [ ] Validate edge functions with local testing
- [ ] Check for breaking changes in schema
- [ ] Backup production data if needed
- [ ] Verify all required environment variables

### **Safe Deployment Process**

1. **Backup Current State**
   ```bash
   SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db dump --linked -f backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **Apply Database Changes**
   ```bash
   SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase db push --project-ref tflvicpgyycvhttctcek
   ```

3. **Deploy Edge Functions**
   ```bash
   SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy --project-ref tflvicpgyycvhttctcek
   ```

4. **Verify Deployment**
   ```bash
   # Check function status
   SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions list --project-ref tflvicpgyycvhttctcek
   
   # Test critical queries
   SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '1 hour';"
   ```

### **Rollback Procedures**
```bash
# Rollback to previous migration
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase migration rollback --project-ref tflvicpgyycvhttctcek

# Restore from backup
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --file backup_20250828_120000.sql
```

---

## 🔧 Maintenance Tasks

### **Daily Maintenance**
```bash
# Check error logs
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
SELECT * FROM pg_stat_database_conflicts 
WHERE datname = 'postgres';"

# Update hashtag trends cache
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions invoke daily-hashtag-curation --project-ref tflvicpgyycvhttctcek
```

### **Weekly Maintenance**
```bash
# Analyze table statistics
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "ANALYZE;"

# Clean up old push tokens
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
DELETE FROM push_tokens 
WHERE updated_at < NOW() - INTERVAL '30 days' 
AND is_active = false;"

# Update hashtag post counts
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
UPDATE community_hashtags 
SET post_count = (
  SELECT COUNT(*) 
  FROM post_hashtags 
  WHERE post_hashtags.hashtag_id = community_hashtags.id
);"
```

### **Monthly Maintenance**
```bash
# Database vacuum and analyze
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "VACUUM ANALYZE;"

# Archive old community posts (optional)
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
-- Archive posts older than 1 year
-- This is a template - implement archiving strategy as needed
SELECT COUNT(*) FROM community_posts 
WHERE created_at < NOW() - INTERVAL '1 year';"
```

---

## 🚨 Emergency Procedures

### **Database Issues**

**High CPU/Memory Usage:**
```bash
# Check active queries
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
SELECT pid, now() - pg_stat_activity.query_start AS duration, query 
FROM pg_stat_activity 
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';"

# Kill long-running queries (use with caution)
-- Get PID from above query, then:
-- SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "SELECT pg_cancel_backend(PID);"
```

**Connection Limits Reached:**
```bash
# Check connection count
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase sql --project-ref tflvicpgyycvhttctcek --execute "
SELECT COUNT(*) as total_connections, 
       SUM(CASE WHEN state = 'active' THEN 1 ELSE 0 END) as active_connections,
       SUM(CASE WHEN state = 'idle' THEN 1 ELSE 0 END) as idle_connections
FROM pg_stat_activity;"
```

### **Edge Function Issues**

**Function Not Responding:**
```bash
# Check function logs
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions logs hashtag-processor --project-ref tflvicpgyycvhttctcek

# Redeploy function
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy hashtag-processor --project-ref tflvicpgyycvhttctcek
```

**Function Deployment Failed:**
```bash
# Force deploy with verbose output
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions deploy function-name --project-ref tflvicpgyycvhttctcek --debug

# Check function status
SUPABASE_ACCESS_TOKEN=sbp_b4e5bfac8a545b8a2f2eb75140e7cfdbfb98158b supabase functions list --project-ref tflvicpgyycvhttctcek
```

---

## 💡 Best Practices

### **Security**
- Always use environment variables for tokens and credentials
- Regularly rotate access tokens
- Review RLS (Row Level Security) policies quarterly
- Monitor failed authentication attempts

### **Performance**
- Monitor slow queries weekly
- Keep hashtag trend cache updated
- Archive old data based on retention policies
- Use connection pooling in applications

### **Backup Strategy**
- Daily automated schema dumps
- Weekly data exports for critical tables
- Test restore procedures monthly
- Keep backups for minimum 90 days

### **Development Workflow**
1. Always test locally with `supabase start`
2. Use feature branches for database changes
3. Apply migrations in development first
4. Deploy during maintenance windows
5. Monitor for 30 minutes post-deployment

---

## 📞 Support Contacts

**Technical Issues:**
- Project Lead: Review `SUPABASE_CONNECTION_GUIDE.md`
- Database Issues: Check `SUPABASE_DATABASE_REFERENCE_COMPLETE.md`

**Emergency Escalation:**
1. Check application logs first
2. Review database performance metrics
3. Consult edge function logs
4. Contact Supabase support if infrastructure issues

---

## 📚 Reference Documents

- `SUPABASE_DATABASE_REFERENCE_COMPLETE.md` - Complete schema documentation
- `SUPABASE_CONNECTION_GUIDE.md` - Connection methods and troubleshooting
- `CLAUDE.md` - Development guidelines and quick commands

---

**This guide reflects current production operations as of 2025-08-28. Update after any significant infrastructure changes.**