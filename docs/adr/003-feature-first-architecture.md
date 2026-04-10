# ADR-003: Feature-First over Layer-First Project Structure

**Status:** Accepted
**Date:** 2026-01-10

## Context

A Flutter project with 6 feature modules (auth, link, collection, search, notification, profile) and 13 screens needs a scalable directory structure. The two dominant approaches are:

- **Layer-first**: Group by technical layer (`data/`, `domain/`, `presentation/` at the top level)
- **Feature-first**: Group by business domain (`features/auth/`, `features/link/`, etc.), each containing its own layers

## Options Considered

### Layer-First

```
lib/
├── data/
│   ├── auth/
│   ├── link/
│   └── collection/
├── domain/
│   ├── auth/
│   ├── link/
│   └── collection/
└── presentation/
    ├── auth/
    ├── link/
    └── collection/
```

### Feature-First (chosen)

```
lib/
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── link/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── collection/
        ├── data/
        ├── domain/
        └── presentation/
```

## Decision

**Feature-first** with strict layer boundaries within each feature.

### Reasons

1. **Cohesion**: All code related to "links" lives in `features/link/`. Adding a new field to a link entity means changes are scoped to one directory — the DTO, mapper, entity, usecase, provider, and screen are all neighbors.

2. **Zero cross-feature imports**: Each feature module is self-contained. `link/` never imports from `collection/domain/`. Shared concerns live in `core/` (error handling, network) or `shared/` (reusable widgets). This rule is enforced by code review.

3. **Parallel development**: Independent features can be developed, tested, and reviewed in isolation. The link feature was completed with mock data before the collection feature was started.

4. **Deletability**: If a feature is removed (e.g., notifications), deleting `features/notification/` removes everything with no orphaned references elsewhere.

5. **Scales with team size**: In a multi-developer environment, each developer can own a feature directory without merge conflicts in shared layer directories.

## Consequences

- **Positive**: Adding the search feature required zero changes to existing features — only new files in `features/search/`.
- **Positive**: Test files mirror the feature structure (`test/features/link/...`), making test discovery intuitive.
- **Negative**: Some duplication in boilerplate — each feature has its own `_di_providers.dart` with similar patterns. Accepted trade-off for isolation.
- **Negative**: Cross-feature data sharing requires going through `core/` or shared providers, adding a small layer of indirection.

## References

- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture)
- Reso Coder's Clean Architecture series
