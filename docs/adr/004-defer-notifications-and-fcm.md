# ADR-004: Defer Notifications (F06) and FCM Push out of MVP

**Status:** Accepted
**Date:** 2026-07-28

## Context

`lib/features/notification/` was built out as a full Clean Architecture slice — DTO, mapper, remote/local datasource, repository, three usecases, a Riverpod provider, and a paginated `NotificationScreen` with skeleton/empty/error states. It was reachable from the Home top bar bell (`Routes.notifications`).

Two facts made the feature non-functional in practice:

1. **Nothing writes notifications.** Across the whole repo, `from('notifications')` appears only as `select` (list) and `update` (`is_read`) — there is no `insert` anywhere, and no server-side trigger or Edge Function in the repo. The screen therefore renders an empty state permanently.

2. **The events that would trigger notifications do not exist.** PRD F06 defines the sources as collection-follow (F06-1), link comments (F06-2), and share invites (F06-3). None of those features exist in `lib/` — there is no social graph. The only sharing primitive shipped is a read-only public collection link.

`firebase_messaging` was present in `pubspec.yaml` but had zero usages in `lib/` — the release checklist had already excluded FCM from 1.1.6 and deferred it to a future version.

### Product fit

LinkNote's core loop is pull-shaped: save (external share → app) and retrieve (search → open). Push is justified when there is an event the user pays a cost for missing while outside the app. No such event exists today. The commonly proposed substitute — "you saved this and never read it" reminders — is a well-known read-later anti-pattern and was rejected rather than adopted as a replacement.

### Portfolio fit

The stated goal of this project is capability evidence plus a completed store release, not retention. The remaining FCM work (init, token/permission service, Android 13+ `POST_NOTIFICATIONS`, background handler, deep link, then APNs for iOS) is checkbox-level integration that does not differentiate, and it would additionally require a token table with RLS, a server-side send path, a privacy-policy update, and a Play Data Safety update. The same time spent on the share-intent pipeline and finishing the Play internal-test release is the stronger signal.

The actual risk to the portfolio was never "this app has no push" — reader/bookmark apps commonly ship without it. The risk was a PRD that promised notifications while the bell opened a permanently empty screen.

## Options Considered

| Option | Verdict |
|--------|---------|
| Build FCM now | Rejected — no send-side events exist; would ship token collection, a permission prompt, and an empty inbox |
| Replace with local "unread link" reminders | Rejected — weak user value, read-later anti-pattern, lower signal than FCM |
| Delete `features/notification/**` entirely | Rejected — the empty-screen exposure is fixed by removing the entry point; deleting working code has a revert cost and no additional benefit today |
| **Remove the entry point, keep the layer dormant** | **Chosen** |

## Decision

Notifications and FCM are **out of MVP scope**, deferred with an explicit reopen condition.

**Code**

- Home top bar bell removed; `Routes.notifications` route and constant removed. The screen is unreachable from the app.
- `firebase_messaging` removed from `pubspec.yaml` (unused dependency — it only widened the store/security review surface).
- `lib/features/notification/**` and its tests are **retained, dormant, and unrouted**. No `lib/` code references them.

**Reopen condition:** notifications are reconsidered only once a real notification-producing event exists (follow, comment, or invite). Adding FCM before that ordering is inverted.

**Compliance posture (unchanged, deliberately)**

- `docs/privacy-policy.md` keeps "푸시 알림 토큰 (현재 버전은 푸시 알림 미사용)". No token-collection clause is to be added.
- Play Data Safety continues to declare no push messages and no device/other IDs.

## Consequences

- **Positive**: No empty-forever surface in the shipped app; PRD and code now agree.
- **Positive**: Three packages dropped (`firebase_messaging` + 2 transitive), and the privacy policy / Data Safety declarations stay minimal and truthful.
- **Positive**: Phase 7 loses a blocking checklist section, moving the Play internal-test release closer.
- **Negative**: `features/notification/**` is dead code carrying maintenance cost — its tests still run in CI, and its Hive box stays in the sign-out clear contract. Accepted deliberately: the cost is small and bounded, and the slice is a working starting point if the reopen condition is ever met.
- **Negative**: The `notifications` Supabase table and its RLS remain provisioned but unused.

## References

- PRD F06 — `docs/linknote-prd.md`
- Phase 7 / Phase 8 FCM checklists — `docs/linknote-workflow.md`
- `docs/release-checklist.md` — prior "FCM 1.1.6 미포함" decision, now made permanent
