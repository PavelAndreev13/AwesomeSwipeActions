# Changelog

All notable changes to **AwesomeSwipeActions** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/PavelAndreev13/AwesomeSwipeActions/releases/tag/1.0.0
