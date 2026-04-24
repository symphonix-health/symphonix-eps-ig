# Operations Handbook

**Project:** symphonix-eps-ig
**Date:** 2026-04-24
**Status:** Draft

---

## 1. System Overview

**Type:** spring-service
**Components:** 4 task groups

---

## 2. Health Checks

- **Endpoint:** GET /health
- **Expected:** `{"status": "healthy"}`
- **Frequency:** Every 30 seconds
- **Alert on:** 3 consecutive failures

---

## 3. Monitoring

### 3.1 Key Metrics

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| api_latency_p95 | 95th percentile response time | > 200ms |
| error_rate | 5xx responses / total | > 0.5% |
| db_query_p95 | Database query latency | > 100ms |

### 3.2 Logs

- Application logs: stdout/stderr (structured JSON)
- Access logs: request method, path, status, duration
- Error logs: stack traces with correlation ID

---

## 4. Troubleshooting

### 4.1 High API Latency

**Diagnosis:**
1. Check database query latency
2. Check external service response times
3. Check CPU/memory utilization

**Resolution:**
- Optimize slow queries (add indexes)
- Scale horizontally (add instances)
- Enable caching if not already active

### 4.2 High Error Rate

**Diagnosis:**
1. Check application logs for stack traces
2. Identify error pattern (specific endpoint, all endpoints)
3. Check dependent service health

**Resolution:**
- Fix application bug and redeploy
- Restart service if transient
- Rollback if regression

### 4.3 Database Connection Issues

**Diagnosis:**
1. Verify database host is reachable
2. Check connection pool utilization
3. Look for long-running queries

**Resolution:**
- Kill long-running queries
- Increase connection pool size
- Restart database if unresponsive

---

## 5. Runbooks

### 5.1 Service Restart

```bash
# Graceful restart
kill -SIGTERM $(pgrep -f "uvicorn src.main")
sleep 5
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

### 5.2 Database Backup

```bash
# SQLite
cp data/app.db data/app.db.backup.$(date +%Y%m%d)

# PostgreSQL
pg_dump -h host -U user dbname > backup_$(date +%Y%m%d).sql
```

### 5.3 Emergency Rollback

See DEPLOYMENT.md Section 4.

---

## 6. Security Operations

- **Credential rotation:** Quarterly or on compromise
- **Dependency audit:** Monthly (`pip-audit`)
- **Patching:** Critical CVEs within 48 hours
- **Incident response:** Detect -> Isolate -> Preserve -> Notify -> Analyze -> Remediate
