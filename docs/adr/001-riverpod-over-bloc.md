# ADR-001: Riverpod over BLoC for State Management

**Status:** Accepted
**Date:** 2026-01-15

## Context

LinkNote needs a state management solution for a feature-first Clean Architecture with 6 independent modules. Key requirements:

- Type-safe dependency injection without runtime service locators
- Async state handling (loading/data/error) for network-dependent features
- Code generation to minimize boilerplate
- Testability via provider overrides

## Options Considered

| Criteria | Riverpod 3.x | BLoC/Cubit | Provider + GetIt |
|----------|-------------|------------|------------------|
| DI | Built-in (compile-time) | Requires GetIt or similar | GetIt (runtime) |
| Async states | `AsyncValue<T>` built-in | Manual `emit()` | Manual |
| Code gen | `@riverpod` annotation | `freezed` for states | None |
| Boilerplate | Low (generated) | Medium (Event/State) | High |
| Testing | `ProviderScope.overrides` | `BlocTest` | GetIt reset |
| Learning curve | Moderate | Low-moderate | Low |

## Decision

**Riverpod 3.x with code generation** (`riverpod_annotation` + `riverpod_generator`).

### Reasons

1. **Unified DI + State**: Riverpod serves as both dependency injection container and state management — no need for a separate service locator like GetIt. Each feature's DI wiring is a single `_di_providers.dart` file with `@riverpod` annotations.

2. **AsyncNotifier fits the domain**: Every feature in LinkNote is network-first with local fallback. `AsyncNotifier` provides `AsyncLoading`, `AsyncData`, `AsyncError` states out of the box, eliminating manual loading/error state classes.

3. **Provider dependencies are declarative**: `ref.watch(authProvider)` in `collectionRepository` provider automatically rebuilds the repository when auth state changes. With BLoC this would require manual stream subscriptions.

4. **Code generation reduces surface area for bugs**: `@riverpod` generates the provider, its type, and its ref — no hand-written `StateNotifierProvider<T, S>` signatures to keep in sync.

## Consequences

- **Positive**: Zero hand-written providers across 6 modules. DI and state management are a single concern.
- **Positive**: `ProviderScope.overrides` makes widget tests trivial — swap real repositories with mocks in one line.
- **Negative**: `build_runner` is required for code generation. Added to CI pipeline.
- **Negative**: Riverpod's mental model (provider lifecycle, `ref.watch` vs `ref.read`) has a learning curve for developers familiar with BLoC.

## References

- [Riverpod Documentation](https://riverpod.dev)
- [riverpod_annotation API](https://pub.dev/packages/riverpod_annotation)
