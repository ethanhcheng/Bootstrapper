# Python Standards

Apply clear naming, explicit error handling, and minimal side effects. Validate inputs at boundaries, avoid silent exception handling, and remove dead code and unused imports.

## Async/Await
- Use `asyncio.get_running_loop()` in async functions (not `get_event_loop()`)
- Wrap blocking I/O in `loop.run_in_executor(None, fn)`
- Add try/except around external service calls

## File Operations
- Always specify `encoding='utf-8'` for text files
- Use `pathlib.Path` over `os.path` when possible
- Close files properly (use context managers)

## Threading
- Use locks for shared mutable state
- Make background threads `daemon=True`
- Check locks and state atomically (no TOCTOU)

## Race Condition Prevention
- Wrap all check-then-act patterns in a lock: `with lock: if x: use(x)`
- Use `threading.Lock` for thread-shared state, `asyncio.Lock` for async-shared state
- Never append/modify shared lists or dicts from multiple threads without a lock
- All `queue.get()` calls must have a timeout to prevent indefinite blocking
- Daemon threads must check a `_stop_event` or flag and exit cleanly on shutdown
- External resource operations (open/close/read/write) must not race across threads

## App Freeze & Break Prevention
- Never perform blocking I/O (network, file, subprocess, inference) on the UI/main thread
- All network requests must include explicit `timeout=` (connect + read)
- All `thread.join()` calls must include a timeout
- All subprocess calls must include a timeout
- Every background thread and async task must have a top-level `try/except` with logging
- All `while True` loops must have a break/stop-flag check and a sleep
- All retry loops must have a max attempt count
- UI updates from background threads must use the framework's thread-safe dispatch
- Always close streams and file handles in `finally` blocks or context managers
- Never hold a lock across an `await` or blocking call (deadlock risk)

## Error Handling
- Log exceptions with context: `log.warning("Action failed: %s", exc)`
- Never silently swallow exceptions without logging
- Error messages must include what was attempted, which resource, and what input

## Imports
- Remove unused imports
- Use lazy imports for heavy modules
- Prefer specific imports: `from module import func` over `import module`

## Data Structures
- Use `copy.deepcopy()` for nested dicts/lists when mutation must not leak
- Initialize mutable defaults as `None`, not `[]` or `{}`
