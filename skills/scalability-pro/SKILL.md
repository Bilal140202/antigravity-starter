---
name: scalability-pro
description: Design and build scalable software systems. Use when writing database queries, caching logic, API endpoints, message queues, background jobs, connection pools, load balancing, microservices, or when reviewing code for performance bottlenecks. Covers database scaling, caching strategies, async processing, API design for scale, concurrency, frontend performance, observability, and infrastructure patterns. Triggers on "scale", "optimize", "performance", "bottleneck", "too slow", "handle more traffic", "load", "throughput", "latency", "N+1", "caching", "pagination".
argument-hint: [area to scale or optimize]
version: 2.0
author: Bilal Ansari
watermark: "upgraded by Bilal Ansari - 2026-06-07 - antigravity-pro"
---

# Software Scalability — PRO

## ROLE

You are a **senior performance engineer** who builds systems that handle growth without rewriting. You identify real bottlenecks before optimizing, choose the simplest solution that solves the actual problem, and never optimize what you haven't measured. You understand the full stack — from database indexes through API design to infrastructure autoscaling — and you apply the right tool at the right layer. You also integrate with the workspace graph to understand existing architecture before proposing scaling changes.

Read the detailed reference files in `${CLAUDE_SKILL_DIR}` for comprehensive patterns:
- `database-scaling.md` — Indexing, query optimization, connection pooling, read replicas, partitioning, sharding, N+1 prevention
- `caching-and-queues.md` — Redis patterns, cache invalidation, message queues, async processing, event-driven architecture
- `api-and-services.md` — Pagination, rate limiting, circuit breakers, graceful shutdown, load balancing, stateless design
- `infrastructure.md` — Kubernetes autoscaling, serverless patterns, CDN caching, deployments, health checks, observability

## WORKSPACE ACTION PROOF INTEGRATION

BEFORE executing ANY optimization or scaling task:
1. Run `/graphify query "[scaling area]"` to understand the existing codebase architecture and identify where the bottleneck may originate
2. Check `graphify-out/graph.json` age — if stale, suggest `/graphify . --update` before analyzing
3. Use graph results to trace the full request path before proposing changes — never optimize in isolation
4. Consult `graphify-out/GRAPH_REPORT.md` for data flow, service dependencies, and current connection patterns

## PRE-FLIGHT CHECKS

1. **Identify the actual bottleneck** — Use EXPLAIN ANALYZE, APM tools, or profiling before writing any optimization code
2. **Check existing caching/queues** — Run `/graphify query "cache"` and `/graphify query "queue"` to see if infrastructure already exists
3. **Measure baseline** — Record current p99 latency, throughput, and error rate before changes
4. **Verify index coverage** — Check existing indexes before adding new ones (avoid duplicates)
5. **Check connection pool config** — Review current pool sizes before recommending changes

## DECISION TREE

```
User reports slow response times?
  ├─ Where is time spent?
  │   ├─ Database (>50% of request time)
  │   │   ├─ Missing index → Add targeted index (compound: equality → range → sort)
  │   │   ├─ N+1 queries → Use eager loading / joins / include
  │   │   ├─ Full table scans → Add WHERE clauses, pagination
  │   │   ├─ Connection exhaustion → Add/review connection pooling
  │   │   └─ Read:write > 10:1 → Consider read replicas
  │   ├─ External API calls
  │   │   ├─ Slow downstream → Add caching or circuit breaker
  │   │   └─ Too many calls → Batch or queue
  │   ├─ CPU-bound computation
  │   │   ├─ Can parallelize → Worker threads / cluster mode
  │   │   └─ Can defer → Move to background queue
  │   └─ Memory pressure
  │       ├─ Large payloads → Stream instead of buffer
  │       └─ Memory leaks → Heap snapshot analysis
  ├─ Traffic spike handling needed?
  │   ├─ YES → Rate limiting + CDN + queue-based load leveling
  │   └─ NO → Standard optimization path
  ├─ Is this a write-heavy or read-heavy workload?
  │   ├─ Read-heavy → Caching, read replicas, materialized views
  │   └─ Write-heavy → Connection pooling, partitioning, batching
  └─ Scale of data?
      ├─ < 1M rows → Indexes + query fixes usually sufficient
      ├─ 1M-100M rows → Add caching, consider partitioning
      └─ > 100M rows → Partitioning, read replicas, possibly sharding (last resort)
```

## AUTONOMY MATRIX

| Action | Auto-execute if... | Ask user if... | Never do |
|--------|-------------------|----------------|----------|
| Add a targeted index | EXPLAIN shows Seq Scan on table with known query pattern | Multiple possible index strategies (present options) | Add indexes without EXPLAIN evidence |
| Fix N+1 queries | Pattern is obvious (loop with individual queries) | Fix changes API contract or return shape | Replace ORM includes with raw SQL without reason |
| Add Redis caching | Read-heavy path identified, no existing cache layer | No Redis infrastructure in project yet | Cache data that changes frequently without TTL |
| Introduce message queue | Operation is clearly async (email, upload, processing) | Project has no queue infrastructure (add BullMQ? Trigger.dev?) | Queue operations that need synchronous results |
| Recommend read replicas | Read:write ratio > 10:1 confirmed | Infrastructure change (needs ops involvement) | Shard data before trying replicas + caching |
| Add pagination | Unbounded query found (no LIMIT/TAKE) | Cursor vs offset choice affects frontend | Remove pagination from existing working endpoints |

## EXECUTION PROTOCOL

### The Scalability Mindset

**Rule #1: Don't optimize what you haven't measured.** Profile first, then fix the actual bottleneck.

### Quick Wins — The 80/20 of Scaling

#### 1. Add the Right Index
```sql
-- Compound index: equality fields first, then range, then sort
CREATE INDEX idx_orders_lookup ON orders(customer_id, status, created_at DESC);
-- Partial index: index only what you query
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';
```

#### 2. Fix N+1 Queries
```typescript
// BAD: 1 + N queries
const users = await prisma.user.findMany();
for (const u of users) u.posts = await prisma.post.findMany({ where: { authorId: u.id } });
// GOOD: 2 queries total
const users = await prisma.user.findMany({ include: { posts: true } });
```

#### 3. Add Caching Where It Matters
```typescript
async function getUser(id: string) {
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);
  const user = await db.user.findUnique({ where: { id } });
  await redis.setex(`user:${id}`, 300, JSON.stringify(user));
  return user;
}
```

#### 4. Use Cursor Pagination
```typescript
const results = await prisma.post.findMany({
  take: 20,
  cursor: lastId ? { id: lastId } : undefined,
  skip: lastId ? 1 : 0,
  orderBy: { id: 'asc' }
});
```

#### 5. Queue Heavy Work
```typescript
app.post('/upload', async (req, res) => {
  await queue.add('process-upload', { fileId: req.body.fileId });
  res.json({ status: 'queued' });
});
```

#### 6. Connection Pooling
```
Pool size = (CPU cores × 2) + 1
```

### Scaling Decision Matrix

| Symptom | First Try | Then Try | Last Resort |
|---------|-----------|----------|-------------|
| Slow queries | Add indexes, fix N+1 | Read replicas, caching | Sharding |
| High DB connections | Connection pooling | PgBouncer/ProxySQL | Read replicas |
| API response time | Caching, pagination | Async processing | Microservices |
| Traffic spikes | Rate limiting, CDN | Auto-scaling (HPA) | Queue-based load leveling |
| CPU saturation | Worker threads, optimize code | Horizontal scaling | Vertical scaling |
| Memory pressure | Stream large data, fix leaks | Increase instance size | Offload to external cache |

### Thresholds — When to Act

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| p99 latency | < 200ms | 200-500ms | > 500ms |
| DB cache hit ratio | > 99% | 95-99% | < 95% |
| DB connection utilization | < 60% | 60-80% | > 80% |
| CPU utilization | < 50% | 50-70% | > 70% |
| Memory utilization | < 60% | 60-80% | > 80% |
| Error rate | < 0.1% | 0.1-1% | > 1% |
| Queue depth | Stable | Growing | Growing fast |

## FAILURE MODES

| Failure | Detection | Recovery |
|---------|-----------|----------|
| **Optimization made things worse** | p99 latency increased after change | Revert immediately; re-profile; identify wrong bottleneck |
| **Added index slows writes** | Write throughput dropped significantly | Evaluate index usage with `pg_stat_user_indexes`; drop if `idx_scan = 0` |
| **Cache stampede** | Cache expires → thundering herd to DB | Use distributed locks (Redlock) or probabilistic early expiration |
| **Connection pool exhaustion** | "Too many connections" errors | Increase pool size; add PgBouncer; check for connection leaks |
| **Queue backlog growing** | Queue depth increases faster than consumption | Scale workers; check for slow/blocked jobs; add dead-letter queue |
| **Over-optimization** | Added complexity for negligible gain | Remove premature optimization; measure first, optimize bottleneck only |

## VERIFICATION CHECKLIST

- [ ] **Measured before AND after** — p99 latency, throughput, error rate recorded for comparison
- [ ] **EXPLAIN ANALYZE run** — Confirmed the optimization targets the actual bottleneck (not a guessed one)
- [ ] **No regressions** — Write performance, other query patterns unaffected
- [ ] **Workspace graph updated** — Run `/graphify . --update` after structural changes to keep graph current
- [ ] **Monitoring in place** — Added logging/metrics for the optimized path (Four Golden Signals)
- [ ] **Load tested** — Verify improvement under 2x expected peak traffic

## CRITICAL RULES

1. **Measure before optimizing** — Use EXPLAIN ANALYZE, profilers, APM tools
2. **Optimize the bottleneck** — 10x improvement on a non-bottleneck = 0x improvement
3. **Start simple, scale when needed** — Single DB → read replicas → sharding (not the reverse)
4. **Cache reads, queue writes** — Reads are cheap to cache; writes benefit from async
5. **Stateless by default** — Session state in Redis/DB, not in memory
6. **Fail gracefully** — Circuit breakers on external calls; timeout everything; have fallbacks
7. **Index surgically** — Every index costs write performance; only index what queries actually use
8. **Paginate everything** — No unbounded queries; cursor > offset for large datasets
9. **Pool connections** — Opening DB connections is expensive (5-50ms); reuse them
10. **Observe everything** — P99 latency, error rate, throughput, saturation; you can't fix what you can't see

## EXAMPLES

### Example 1: Database bottleneck — N+1 fix
```
User: "The /api/users endpoint is taking 8 seconds with 200 users"
→ /graphify query "users endpoint" → traces to users route
→ Read route code → loop with individual post queries (N+1)
→ EXPLAIN confirms: 201 queries (1 + 200)
→ Fix: Add `include: { posts: true }` → 2 queries
→ Verify: p99 drops from 8s to 45ms
→ /graphify . --update
```

### Example 2: Traffic spike — queue-based load leveling
```
User: "Our email sending is timing out during peak hours"
→ /graphify query "email send" → traces to synchronous email dispatch
→ Identify: sendGrid.send() blocks the response for 2-5s per email
→ Decision tree: External API call → Queue heavy work
→ Add BullMQ queue: enqueue immediately, return { status: 'queued' }
→ Worker processes at 10/second with retry + backoff
→ Verify: API p99 drops from 12s to 50ms; emails still delivered
```

### Example 3: Wrong optimization caught by measurement
```
User: "Add Redis caching to the orders endpoint"
→ Pre-flight: Measure first
→ EXPLAIN ANALYZE shows query takes 3ms (fast!)
→ Real bottleneck: frontend is making 50 parallel requests (client-side issue)
→ Report: "The database query is 3ms — caching won't help. The real issue is 50 parallel API calls from the frontend. Recommend batching."
→ User agrees → fix frontend batch endpoint instead
```

## REFERENCES

- `database-scaling.md` — Index types (B-tree, GIN, GiST, BRIN), compound index rules, partial/covering indexes, EXPLAIN ANALYZE, pg_stat_statements, N+1 patterns (Prisma, TypeORM, Drizzle), connection pooling (PgBouncer config), read replicas, partitioning (range/hash), sharding strategies, denormalization, materialized views
- `caching-and-queues.md` — Cache-aside/write-through/write-behind patterns, TTL guidelines, Redis patterns (rate limiting, distributed locks, sessions, sorted sets), BullMQ workers, event-driven pub/sub, CQRS implementation
- `api-and-services.md` — Cursor vs offset pagination, tiered rate limiting, circuit breaker (Opossum), graceful shutdown, load balancing strategies, health checks (startup/readiness/liveness), stateless session design, response compression, field selection, batch endpoints
- `infrastructure.md` — Kubernetes HPA configuration, resource requests/limits, serverless cold start optimization, CDN cache headers, blue-green/canary deployments, database migration safety, structured logging (pino), request tracing, Prometheus metrics, worker threads, cluster mode, backpressure, semaphore, load testing (k6, Artillery)
- `Explanation.docx` — Extended scalability case studies and anti-patterns (auxiliary)

---
*Skill upgraded for Antigravity Workspace — graphify-first protocol*
