# LinkNote — Agent entry (Codex / multi-agent)

> Canonical rules: [`docs/ai-guidelines.md`](docs/ai-guidelines.md)
> Claude-oriented notes: [`CLAUDE.md`](CLAUDE.md)

## Quick verify

```bash
flutter analyze
flutter test
```

## Hard rules

- Do not commit secrets (service accounts, service role keys, private keys).
- Do not `git push` without explicit user approval.
- Do not claim done on analyze timeout / environment failure (`UNVERIFIED` ≠ PASS).
- Respect feature-first Clean Architecture boundaries.

## Before coding

1. Read `docs/ai-guidelines.md` if present.
2. Skim `tasks/lessons.md` recent items when present.
3. Prefer smallest safe change; run analyze/tests for touched areas.
