# Changelog

All notable changes to **AwesomeSwipeActions** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] — 2026-05-09

### Added

- **Vertical swipe edges (`.top` and `.bottom`).** Apply a swipe-action panel
  that emerges from the top or bottom of a row. Works best inside horizontal
  scroll views or non-scrolling containers — see the *Vertical edges* section
  in the README for axis-conflict guidance.
- **Programmatic `coordinator.open(id:from:)`.** Open any row from any edge
  outside of a gesture, useful for tutorials, onboarding peeks, and tests:
  ```swift
  coordinator.open(id: items.first!.id, from: .trailing)
  ```
- **`accessibilityReduceMotion` honoring.** Spring snap animations are
  replaced with a short linear curve when the system flag is on, matching
  the platform-wide preference.
- New internal `SwipeAxisStrategy` value type centralises every
  axis-conditional decision (offset application, gesture component, panel
  alignment) so adding more edges in the future is mechanical.
- Tests: new suites `SwipeAxisStrategy` (15 tests), `SwipeEdgeKey`
  (3 tests), `RubberBand` (6 tests), plus 5 new coordinator tests for
  `open(id:from:)` — totalling **38 tests** in 4 suites, all passing.

### Changed (BREAKING)

- **Parameter renamed: `edge:` → `from:`.** Both modifier overloads now read
  `awesomeSwipeActions(... , from: Edge = .trailing , ...)`. The new name
  more accurately describes "which edge actions slide *from*", matches
  native SwiftUI vocabulary (`safeAreaInset(edge:)`,
  `transition(.move(edge:))`), and unifies the parameter name across the
  four-edge surface.
- **Type changed: `HorizontalEdge` → `SwiftUI.Edge`.** The new four-case
  type unlocks `.top` and `.bottom` while remaining a native SwiftUI type
  (no library-specific replacement enum). The default value remains
  `.trailing`, so callers that omitted the parameter compile unchanged.
- `AwesomeSwipeButton` and `awesomeButtonStyle(tint:)` now read the swipe
  axis from the environment (injected by `SwipeActionsPanel`) and choose
  the correct fixed dimension automatically — `width` inside a horizontal
  panel, `height` inside a vertical panel. Defaults to horizontal sizing
  outside a swipe context, preserving v1 visual behaviour.
- Renamed internal preference key `SwipePanelWidthKey` →
  `SwipePanelDimensionKey` to reflect that it now reports the panel's size
  along whichever swipe axis applies.

### Deprecated

- `awesomeSwipeActions(id:coordinator:edge:content:)` and
  `awesomeSwipeActions(for:coordinator:edge:content:)` accepting
  `edge: HorizontalEdge` — both forwarded to the new `from:` overloads via
  `@available(*, deprecated, renamed:)`. Xcode offers a one-tap fix-it.
  These bridges will be removed in 3.0.

### Migration

For most call sites, a single-token edit suffices:

```diff
- .awesomeSwipeActions(for: item, coordinator: coord, edge: .leading) { … }
+ .awesomeSwipeActions(for: item, coordinator: coord, from: .leading) { … }
```

Callers that omitted `edge:` (relying on the `.trailing` default) compile
unchanged. Users locked at `from: "1.0.0"` must opt into `from: "2.0.0"`
explicitly per SemVer.

## [1.0.0] — 2026-04-28

Initial public release.

### Added

- `View.awesomeSwipeActions(id:coordinator:edge:content:)` — the main modifier
  that adds custom swipe actions to any view inside a `ScrollView`.
- `View.awesomeSwipeActions(for:coordinator:edge:content:)` — convenience
  overload that takes any `Identifiable` item and uses its `id` automatically.
- `AwesomeSwipeCoordinator` (`@MainActor`-isolated) for coordinating
  open/close state across all rows in a scroll view:
  - `openRowID: AnyHashable?` — the user-supplied id of the currently open row,
    safe to compare against your own ids.
  - `close()` — programmatically close the open row.
- `AwesomeSwipeButton<Label>` — pre-styled button with two initialisers:
  custom-label and SF-Symbol convenience.
- `View.awesomeButtonStyle(tint:)` — apply the standard
  AwesomeSwipeActions appearance to any SwiftUI `Button`.
- VoiceOver support: action buttons are exposed as accessibility actions on
  the row, matching the rotor behaviour of the native `swipeActions`.
- O(1) re-renders — only the opening and closing rows update on each
  interaction; the rest of the list is untouched.
- Native iOS rubber-band physics and velocity-based snap (>300 units/s).
- Scroll conflict prevention via 50° angle filtering on the first drag sample.
- Reactive row-width tracking via `.onGeometryChange` (handles rotation,
  split-view, and Dynamic Type changes).
- Strict concurrency clean: builds with
  `.enableUpcomingFeature("StrictConcurrency")` enabled.
- DocC documentation catalogue.
- Unit tests covering coordinator state machine.
- GitHub Actions CI: `swift build` (debug + release) + `swift test` on
  `macos-14`.

### Notes

- Targets **iOS 17+**, **macOS 14+**, **visionOS 1+**.
- The `edge:` parameter accepts `SwiftUI.HorizontalEdge` (`.leading` or
  `.trailing`), mirroring the signature of native `swipeActions(edge:)` for
  drop-in familiarity.
- `closeAll()` is provided as a deprecated alias for `close()` for source-
  compatibility with pre-1.0 betas; it will be removed in a future major
  version.

[2.0.0]: https://github.com/PavelAndreev13/AwesomeSwipeActions/releases/tag/2.0.0
[1.0.0]: https://github.com/PavelAndreev13/AwesomeSwipeActions/releases/tag/1.0.0
