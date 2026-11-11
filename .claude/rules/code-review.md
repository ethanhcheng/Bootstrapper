# Code Review

## When The Full Review Runs

- Feature-tier work, before the PR is marked ready.
- Whenever the human asks for a review.

A full review checks every file in scope against every dimension below, tiers the findings (Critical / High / Moderate / Low), and records them in the plan doc. A small change gets the same questions applied to the lines it touches, not a sweep of the codebase.

## Review Dimensions

### Resource Efficiency
- No unnecessary allocations, copies, or repeated computation in hot paths.
- Pools, executors, and caches are bounded and cleaned up on shutdown.
- No unbounded growth of collections in long-running loops or streams.
- Temporary files and scratch storage have cleanup or a TTL.

### Speed
- No blocking I/O on an event loop, a request hot path, or a UI thread.
- Every network call, subprocess call, and blocking wait has an explicit timeout.
- Sequential operations that could run concurrently are flagged.
- No unnecessary serialization round-trips and no N+1 queries.
- Startup paths warm the resources the first request needs.

### Concurrency
- Shared mutable state is protected by the mechanism the runtime provides: a lock, a transaction, or a single-writer queue.
- Check-then-act on shared state is atomic.
- No lock is held across an await, blocking I/O, or a sleep.
- Background workers can be stopped cleanly and do not block process exit.
- No fire-and-forget async work: results are awaited, stored, or given an error handler.
- No time-of-check/time-of-use races on the file system, the database, or state transitions.

### Memory And Handles
- Streams, file handles, connections, and subprocesses are closed on every path, including errors.
- Caches and registries have eviction.
- Cancelled or timed-out work leaves no orphaned references, timers, or listeners.
- Closures do not hold large objects past their useful life.

### Edge Cases
- Null, undefined, or missing on every input, return value, and optional field.
- Empty collections, strings, and buffers.
- Boundary values: zero, negative, maximum, a single element.
- Error returns from external services: 4xx and 5xx, connection refused, DNS failure, timeout.
- Malformed input: invalid JSON, unexpected content type, oversized payload, truncated stream.
- Concurrent use: two requests for the same resource, rapid connect and disconnect, double close.

### Error Handling
- No catch-all that swallows cancellation, interrupts, or errors it cannot handle.
- Every external call (network, file, subprocess, database) handles failure and logs it.
- Error messages say what was attempted, on which resource, with what input.
- No silent failure: returning a default without logging is a finding.
- Retry loops have a maximum attempt count.

### Security
- No string-built queries or commands: SQL, NoSQL, or shell.
- No unvalidated user input in subprocess arguments, file paths, or dynamic evaluation.
- Auth and signature checks use constant-time comparison.
- Uploads are checked for size and content type.
- No secrets in logs, error messages, or responses.

### Contract Consistency
- Signatures match between caller and callee across module boundaries.
- Every environment variable the code reads appears in `.env.example` and the deploy templates, with sensitive values redacted.
- Service names and ports in container or deploy config match the real ones.
- API route paths and methods match what clients call.
