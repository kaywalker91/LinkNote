#!/usr/bin/env bash
# Anti-pattern detection script for LinkNote.
#
# Each category enforces accumulated lessons from `memory/feedback_*.md` so that
# residual violations cannot regrow silently between sessions. New patterns are
# added as separate "check_*" functions; activate them by toggling the call in
# main() once the codebase is clean of that pattern.

set -euo pipefail

cd "$(dirname "$0")/.."

EXIT_CODE=0
WARN_COUNT=0

red()    { printf '\033[31m%s\033[0m\n' "$1"; }
green()  { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }

# ────────────────────────────────────────────────────────────────────────────
# Category A — AppColors leftover whitelist (FAIL on new violations)
#
# Phase 4 dark-mode migration replaced screen-level AppColors usage with
# `context.palette.<token>`. The remaining sites are intentional:
#   - Data hex defaults (e.g. defaultTagColorHex stored as raw int)
#   - Material semantic colors (success/error SnackBar) that bypass palette
#   - Internal self-references inside the theme module itself
#
# Any new `AppColors.<X>` reference outside this whitelist is a regression.
# ────────────────────────────────────────────────────────────────────────────
check_appcolors_whitelist() {
  local label="A.AppColors whitelist"
  local allowed_pattern='^lib/(features/link/presentation/widgets/link_form_fields\.dart|shared/widgets/app_snack_bar\.dart|app/theme/(app_palette|app_theme|app_colors)\.dart):'

  local hits
  hits=$(grep -rn 'AppColors\.' lib --include='*.dart' \
           | grep -v '\.g\.dart\|\.freezed\.dart' || true)

  if [ -z "$hits" ]; then
    green "✓ ${label}: clean"
    return 0
  fi

  local violations
  violations=$(printf '%s\n' "$hits" | grep -Ev "$allowed_pattern" || true)

  if [ -z "$violations" ]; then
    green "✓ ${label}: clean (only whitelisted sites present)"
  else
    red "✗ ${label}: unexpected AppColors use site(s):"
    printf '%s\n' "$violations"
    red "  → migrate to context.palette.<token> or extend the whitelist with a written justification."
    EXIT_CODE=1
  fi
}

# ────────────────────────────────────────────────────────────────────────────
# Category B — `on Exception catch` regression guard (FAIL)
#
# Reason: `on Exception catch` does not catch Dart `Error` subtypes, so
# Hive/DTO/cast boundaries silently propagate Errors past the data layer.
# Lesson sources: feedback_dart_error_vs_exception.md (Session 28 + 41 + PR 2).
#
# PR 2 swept the remaining 34 sites to `on Object catch`. Any reintroduction
# is now a regression.
# ────────────────────────────────────────────────────────────────────────────
check_on_exception_catch() {
  local label="B.on Exception catch"
  local enforce=1

  local hits
  hits=$(grep -rn 'on Exception catch' lib --include='*.dart' \
           | grep -v '\.g\.dart\|\.freezed\.dart' || true)
  local count
  count=$(printf '%s' "$hits" | grep -c '^' || true)

  if [ "$count" -eq 0 ]; then
    green "✓ ${label}: 0 site(s)"
    return 0
  fi

  if [ "$enforce" -eq 1 ]; then
    red "✗ ${label}: ${count} site(s) still present (use 'on Object catch')"
    printf '%s\n' "$hits"
    EXIT_CODE=1
  else
    yellow "! ${label}: ${count} site(s) — tracked, will fail after PR 2"
    WARN_COUNT=$((WARN_COUNT + 1))
  fi
}

# ────────────────────────────────────────────────────────────────────────────
# Category C — raw exception embedded in Failure.message (FAIL)
#
# Reason: `on Object catch` fallbacks that build `Failure.X(message: e.toString())`
# or `message: '<ctx>: $e'` leak raw exception text (HiveError box names, key
# paths, stack fragments) into Failure.message. failure_ui surfaces message via
# the AuthFailure passthrough / kDebugMode branches, so raw exceptions can reach
# the UI. Lesson source: F5 (Session 61) — the sweep routed raw `e` to appLogger
# and replaced the message with null / a fixed context label.
#
# Typed-exception passthrough (`message: e.message`) and fixed string literals are
# fine; only raw `e.toString()` / bare `$e` interpolation inside a `Failure.X(...)`
# constructor is a regression.
# ────────────────────────────────────────────────────────────────────────────
check_failure_raw_exception_message() {
  local label='C.Failure(message: raw $e)'
  local enforce=1

  local hits
  hits=$(grep -rnE 'Failure\.[a-z]+\(.*message:.*(e\.toString\(\)|\$e[^[:alnum:]_])' lib --include='*.dart' \
           | grep -v '\.g\.dart\|\.freezed\.dart' || true)
  local count
  count=$(printf '%s' "$hits" | grep -c '^' || true)

  if [ "$count" -eq 0 ]; then
    green "✓ ${label}: 0 site(s)"
    return 0
  fi

  if [ "$enforce" -eq 1 ]; then
    red "✗ ${label}: ${count} site(s) — route raw e to appLogger; use null/fixed message"
    printf '%s\n' "$hits"
    red "  → see feedback: log raw exception, keep Failure.message sanitized."
    EXIT_CODE=1
  else
    yellow "! ${label}: ${count} site(s) — tracked, will fail after sweep"
    WARN_COUNT=$((WARN_COUNT + 1))
  fi
}

# ────────────────────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────────────────────
main() {
  echo "── anti-pattern checks ──"
  check_appcolors_whitelist
  check_on_exception_catch
  check_failure_raw_exception_message
  echo "────────────────────────"

  if [ "$EXIT_CODE" -ne 0 ]; then
    red "FAIL — fix violations above."
    exit "$EXIT_CODE"
  fi

  if [ "$WARN_COUNT" -gt 0 ]; then
    yellow "PASS (with ${WARN_COUNT} warning category)"
  else
    green "PASS"
  fi
}

main "$@"
