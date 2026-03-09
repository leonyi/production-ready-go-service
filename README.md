# production-ready-python-foundations

**This repository values learning in public over presenting finished answers.**

This project is a deliberately small, opinionated, and evolving foundation for
building **production-ready Python services**, with a strong emphasis on:

- clarity of thought
- correctness under real-world constraints
- testability and observability
- explaining *why* decisions are made, not just *what* they are

It is not a framework.  
It is not a starter template.  

It is a **thinking tool**.

---

## Why this repo exists

Modern Python services often fail not because of missing features, but because of
weak foundations: unclear boundaries, ad-hoc configuration, untestable time-based
logic, or observability bolted on too late.

This repository exists to:

- explore and stress-test **production-ready Python patterns**
- practice building small systems with **operational correctness**
- serve as a reusable **foundation** for applied features (including AI systems)
- provide an interview-ready, explainable codebase

Some code may be revised, rewritten, or removed over time. That is intentional.

---

## How this repo is intended to be used

This repository can be used in one of three ways:

- **Forked** as a starting point for a new service
- **Imported as a package** to reuse foundational components
- **Read and adapted** selectively as a reference

We intentionally keep usage flexible until real constraints force a decision.

---

## Repository structure (layered, not grouped)

This repo follows a **layered architecture**, where imports flow strictly
downward and each layer has a narrow responsibility, not by feature or framework.

The goal is to keep the mental model small, boundaries clear, and dependencies flowing in one direction.

```text
src/prod_skeleton/
├── api/ # Transport & process boundaries (FastAPI, middleware)
├── app/ # External-facing handlers & request/response models
├── business/ # Domain logic and ops-aware components
├── foundation/ # Reusable, dependency-free building blocks
```

### Layer responsibilities

#### `api/` — process & transport
“How does a request enter and leave the system?”

Owns:
- FastAPI app factory and lifespan wiring
- HTTP middleware (logging, request IDs, timing)
- Transport concerns only  
 
Does not own:
- Business logic
- Domain decisions
- Cross-layer orchestration

#### `app/` — API surface
“What does the outside world see?”

Owns:
- Request/response schemas
- Handlers that orchestrate calls into `business/`
- Input validation and response shaping

Does not own:
- Core domain rules
- Persistence or infrastructure mechanics

#### `business/` — domain + ops-aware logic
“What problem are we actually solving?”

Owns:
- Core system behavior (e.g. caching, rate limiting, health checks)
- Interfaces that allow backing services to be swapped
- May emit logs

Does not own:
- HTTP, frameworks, or transport concerns
- Low-level utilities

#### `foundation/` — project “stdlib” - core building blocks
“If everything else disappeared, what code would still make sense?”

Owns:
- Utilities, config, error primitives
- No logging
- No framework imports
- Designed for reuse and testability. Code that is dependency-light & framework agnostic.

Does not know:
- Business rules
- Application flow
- Transport details

#### Dependency Rule (IMPORTANT!)

api → app → business → foundation

Lower layers must never import from higher layers. 
This rule is enforced to preserve clarity, testability, and long-term maintainability.

### Design Inspiration

This repository draws inspiration from layered Go application architectures
popularized by ArdanLabs, particularly their emphasis on ownership-based
directories and strict dependency direction.

The implementation here is intentionally Pythonic and adapted through
experimentation rather than direct translation.

---

## Design principles

This repo explicitly optimizes for:

- **Single Responsibility & Cohesion**
- **Loose coupling and clear abstractions**
- **Deterministic testing** (e.g. FakeClock instead of sleeps)
- **12-Factor App compliance**
- **Defensibility over cleverness**
- **KISS / DRY / YAGNI**

Tradeoffs are documented as they arise.

## Development workflow

This project intentionally defers CI setup until core service features are in place.
All checks (tests, linting, type-checking, import contracts) are designed to run locally
and will later be automated via CI without structural changes.


## Testing
Tests live at the repository root in 'tests/' (outside 'src/'). This is intentional:
it ensures tests import `prod_skeleton` the same way production code does (via the installed package),
and prevents filesystem-import quirks from hiding packaging or layering issues.

Run tests:

```bash
make test
```

---

## What is included so far

- FastAPI app factory with env-based settings
- Structured logging to stdout
- Request correlation IDs
- Request timing with route templates
- Clock abstraction for deterministic time
- Strict layering enforced with import-linter

See `PUBLIC_CONTRACT.md` for what is considered stable.

---
### Observability Substrate (OTel-Ready)

This repository includes a deliberately small, production-credible observability substrate.

The goal is not to build a monitoring framework, but to create a stable seam that:

- Enables request correlation across logs
- Emits structured operational metrics
- Can be backed by OpenTelemetry later without refactoring business logic
- Keeps observability concerns out of the domain layer

### Request Correlation

- `RequestIdMiddleware` reads or generates `X-Request-Id`
- The request id is stored in a `contextvars` store (async-safe)
- Logging enrichment injects `rid=...` automatically into every log line
- Context is reset after each request to prevent cross-request leakage

You can validate propagation locally:

```bash
make smoke
```

## What this is not

- A polished framework
- A guarantee of API stability
- A one-size-fits-all solution

Breaking changes are expected as learning progresses.

---

## License & usage

This project is shared to support learning, discussion, and exploration.
Use it freely, adapt it thoughtfully, and expect it to evolve.


## Repository Map

| Path                                     | Purpose                               | Notes                                              |
|------------------------------------------|---------------------------------------|----------------------------------------------------|
| `src/prod_skeleton/`                     | Root Python package                   | Installable package containing all source code     |
| **`src/prod_skeleton/api/`**             | **Process & transport layer**         | FastAPI app factory, middleware, lifecycle         |
| `src/prod_skeleton/api/middleware/`      | HTTP middleware                       | Request ID, timing, logging, access concerns       |
| `src/prod_skeleton/api/observability/`   | Logging & correlation wiring          | Request ID context, log enrichment                 |
| `src/prod_skeleton/api/services/`        | API entrypoints                       | Routers and service-specific wiring                |
| **`src/prod_skeleton/app/`**             | **API surface layer**                 | Request/response schemas and handlers              |
| `src/prod_skeleton/app/services/`        | Feature-level handlers                | Orchestrates calls into `business/`                |
| **`src/prod_skeleton/business/`**        | **Domain & ops-aware logic**          | Cache, rate limiting, health checks                |
| `src/prod_skeleton/business/health/`     | Health & readiness checks             | Used by liveness/readiness endpoints               |
| **`src/prod_skeleton/foundation/`**      | **Reusable primitives (“project stdlib”)** | No logging, no frameworks                     |
| `src/prod_skeleton/foundation/config/`   | Configuration primitives              | Env-based `Settings`, parsing helpers              |
| `src/prod_skeleton/foundation/time/`     | Time abstractions                     | `Clock`, `SystemClock`, `FakeClock`                |
| `tests/`                                 | Unit tests                            | Deterministic tests using `FakeClock`              |
| `importlinter.cfg`                       | Architecture enforcement              | Prevents upward imports                            |
| `pyproject.toml`                         | Build & dependency config             | Defines installable package                        |
| `PUBLIC_CONTRACT.md`                     | Stability & intent contract           | What is guaranteed vs experimental                 |
| `README.md`                              | Project overview                      | Philosophy, structure, usage                       |


**Notes on Table Entries**
- The rows corresponding to api/, app/, business/, and foundation/ represent architectural layers. Subdirectories exist to support those layers and do not introduce new boundaries.
- Anything under foundation/ must remain usable and dependency-free
- Anything under api/ is allowed to depend on frameworks and logging.
- Imports must always flow down the table, never up!
- If a piece of code feels hard to place in this table, that is usually a signal that the abstraction is unclear.

