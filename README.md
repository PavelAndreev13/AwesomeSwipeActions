<div align="center">

<img width="622" height="264" alt="CompleteImage" src="https://github.com/user-attachments/assets/f0fd81fd-402e-48bb-bfa3-8c9e1afe95c9" />



<img width="250" height="500" alt="preview_vertical_git" src="https://github.com/user-attachments/assets/b8eea67c-b1f1-4bb8-a308-efcaa2827a8b" />
<img width="250" height="500" alt="horizont_preview_git" src="https://github.com/user-attachments/assets/3050c4e0-1f5d-4008-94ab-023ca9a19f46" />



  <h1>AwesomeSwipeActions</h1>

  <p>
    <b>Swipe-to-reveal actions for any <code>ScrollView</code> — what SwiftUI's native <code>swipeActions</code> should have been.</b>
  </p>

  <p>
    <a href="https://swift.org"><img alt="Swift 5.9" src="https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white" /></a>
    <a href="https://developer.apple.com/ios/"><img alt="iOS 17+" src="https://img.shields.io/badge/iOS-17%2B-000?logo=apple&logoColor=white" /></a>
    <a href="https://developer.apple.com/macos/"><img alt="macOS 14+" src="https://img.shields.io/badge/macOS-14%2B-000?logo=apple&logoColor=white" /></a>
    <a href="https://developer.apple.com/visionos/"><img alt="visionOS 1+" src="https://img.shields.io/badge/visionOS-1%2B-000?logo=apple&logoColor=white" /></a>
    <a href="https://swift.org/package-manager/"><img alt="SPM" src="https://img.shields.io/badge/SPM-compatible-brightgreen" /></a>
    <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>
  </p>
</div>

```swift
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(messages) { message in
            MessageRow(message: message)
                .awesomeSwipeActions(for: message, coordinator: coordinator) {
                    AwesomeSwipeButton(tint: .blue, systemImage: "square.and.arrow.up") {
                        share(message)
                    }
                    AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") {
                        delete(message)
                    }
                }
        }
    }
}
```

---

## Table of Contents

- [Why AwesomeSwipeActions?](#why-awesomeswipeactions)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Trailing edge](#trailing-edge-default)
  - [Leading edge](#leading-edge)
  - [Both edges on the same row](#both-edges-on-the-same-row)
  - [Vertical edges (top / bottom)](#vertical-edges-top--bottom)
  - [Rounded corners](#rounded-corners)
  - [Using a standard SwiftUI Button](#using-a-standard-swiftui-button)
  - [Programmatic open & close](#programmatic-open--close)
  - [Observing the open row](#observing-the-open-row)
- [Accessibility](#accessibility)
- [Reduced motion](#reduced-motion)
- [API Reference](#api-reference)
- [How It Works](#how-it-works)
- [Migration from v1.x](#migration-from-v1x)
- [License](#license)

---

## Why AwesomeSwipeActions?

SwiftUI's built-in `.swipeActions` is tied to `List` — it relies on `UITableView` under the hood and is **silently ignored** the moment you switch to `ScrollView`:

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item)
                .swipeActions { … }   // ← has NO effect here
        }
    }
}
```

`AwesomeSwipeActions` fills that gap with a pure-SwiftUI implementation that works in any scrollable container, mirrors the `.swipeActions` API, and adds features the native modifier lacks.

| | `swipeActions` | `AwesomeSwipeActions` |
|---|:---:|:---:|
| `List` | ✅ | ✅ |
| `ScrollView` + `LazyVStack` | ❌ | ✅ |
| `ScrollView` + `LazyHStack` | ❌ | ✅ |
| Custom spacing & separators | ❌ | ✅ |
| Leading & trailing edges | ✅ | ✅ |
| **Top & bottom edges (vertical swipe)** | ❌ | ✅ |
| Rubber-band & velocity snap | ❌ | ✅ |
| Programmatic open & close | ❌ | ✅ |
| Observe the open row | ❌ | ✅ |
| O(1) re-renders on large lists | ❌ | ✅ |
| VoiceOver rotor actions | ✅ | ✅ |
| Honors Reduced Motion | partial | ✅ |

---

## Features

- 🎯 **Drop-in API** — `awesomeSwipeActions(from: Edge)` reads like native `swipeActions(edge:)` and accepts the same SwiftUI `Edge` cases you already use elsewhere (`.transition(.move(edge:))`, `.safeAreaInset(edge:)`, …).
- ↔️ **Four edges** — `.leading` / `.trailing` for horizontal swipes, `.top` / `.bottom` for vertical swipes.
- 🪶 **Pure SwiftUI** — no `UIKit` or `AppKit` interop, no `UIViewRepresentable`; works on iOS, macOS, and visionOS.
- ⚡ **O(1) re-renders** — only the opening and closing rows update; the rest of the list is untouched, even with thousands of rows.
- 🌊 **Native physics** — rubber-band past the panel boundary and velocity-based snap, identical to the system feel.
- 🎚 **Multiple edges per row** — leading + trailing + top + bottom can coexist on the same row.
- 🎨 **Flexible buttons** — use the convenience `AwesomeSwipeButton`, or any standard SwiftUI `Button` with `.tint(_:)`.
- ♿ **VoiceOver-ready** — actions are exposed as `accessibilityActions`, matching the rotor behaviour of native `swipeActions`.
- 🤏 **Reduced Motion** — replaces spring physics with a short linear curve when the system flag is on.
- 🔄 **Reactive** — observe `coordinator.openRowID` and call `coordinator.open(id:from:)` from anywhere.
- 🛡 **Strict-concurrency clean** — `AwesomeSwipeCoordinator` is `@MainActor`-isolated; the package builds with the strict-concurrency upcoming feature enabled.

---

## Requirements

|   | Minimum |
|---|---|
| iOS | 17.0 |
| macOS | 14.0 |
| visionOS | 1.0 |
| Swift | 5.9 |
| Xcode | 15.0 |
| Library version | **2.2.0** |

---

## Installation

### Swift Package Manager

#### In Xcode

1. Open your project and choose **File → Add Package Dependencies…**
2. Paste the repository URL:
   ```
   https://github.com/PavelAndreev13/AwesomeSwipeActions
   ```
3. Choose **Up to Next Major Version** starting at `2.2.0`.
4. Click **Add Package**.

#### In `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/PavelAndreev13/AwesomeSwipeActions", from: "2.2.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["AwesomeSwipeActions"]
    )
]
```

---

## Quick Start

### 1. Import the library

```swift
import AwesomeSwipeActions
```

### 2. Create a coordinator

Create one `AwesomeSwipeCoordinator` per scroll view using `@State`. It ensures only one row is open at a time.

```swift
@State private var coordinator = AwesomeSwipeCoordinator()
```

### 3. Attach `awesomeSwipeActions` to each row

```swift
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(messages) { message in
            MessageRow(message: message)
                .awesomeSwipeActions(for: message, coordinator: coordinator) {
                    AwesomeSwipeButton(tint: .orange, systemImage: "bell") { remind(message) }
                    AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(message) }
                }
        }
    }
}
```

That's it — swipe left on any row to reveal the buttons.

> **Tip:** if your row data is `Identifiable`, prefer the `for:` overload above. Otherwise pass an explicit id with `awesomeSwipeActions(id: …, coordinator: …)`.

---

## Usage

### Trailing edge (default)

Swipe **left** to reveal actions on the right side of the row:

```swift
ItemRow(item)
    .awesomeSwipeActions(for: item, coordinator: coordinator) {
        AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit(item) }
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
    }
```

![trailing](https://github.com/user-attachments/assets/d80304b2-3449-4702-a414-99980b1fa87d)

### Leading edge

Swipe **right** to reveal actions on the left side of the row:

```swift
ItemRow(item)
    .awesomeSwipeActions(for: item, coordinator: coordinator, from: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(item) }
    }
```

![leading](https://github.com/user-attachments/assets/3309fd44-783b-43d7-bd8d-91e39daccce2)

### Both edges on the same row

Apply the modifier twice with different edges — the same `coordinator` will keep them synchronised:

```swift
ItemRow(item)
    .awesomeSwipeActions(for: item, coordinator: coordinator, from: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(item) }
    }
    .awesomeSwipeActions(for: item, coordinator: coordinator, from: .trailing) {
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
    }
```

![both edges](https://github.com/user-attachments/assets/e84b73be-643b-4ba5-994e-baf3efb2bc35)

### Vertical edges (top / bottom)

> ## 🚫 Not supported: vertical edge **inside a vertical `ScrollView`**
>
> Vertical swipe edges (`.top`, `.bottom`) share their gesture axis with a vertical-scrolling parent. Both gestures want the same drag, so **either scroll or swipe will silently break** depending on the iOS version. This is a fundamental gesture-system limitation, not something the library can resolve.
>
> | Container | `.leading` / `.trailing` | `.top` / `.bottom` |
> |---|:---:|:---:|
> | **Vertical `ScrollView`** (most common) | ✅ supported | 🚫 **NOT supported** |
> | **Horizontal `ScrollView`** | 🚫 **NOT supported** | ✅ supported |
> | Non-scrolling container | ✅ supported | ✅ supported |
>
> Pick the **edge axis perpendicular to the scroll axis** (or use a non-scrolling container). The library prints DEBUG-only console hints when it suspects a mismatch — see the *containerAxis* note below.

Swipe **up** or **down** on a card to reveal actions from the `.bottom` or `.top` edges. Vertical swipes shine on cards inside a horizontal scroll view, where the swipe axis is perpendicular to the scroll axis:

```swift
ScrollView(.horizontal) {
    LazyHStack(spacing: 12) {
        ForEach(items) { item in
            Card(item: item)
                .awesomeSwipeActions(
                    for: item, coordinator: coordinator,
                    from: .top, containerAxis: .horizontal
                ) {
                    AwesomeSwipeButton(tint: .orange, systemImage: "star.fill") {
                        favourite(item)
                    }
                }
                .awesomeSwipeActions(
                    for: item, coordinator: coordinator,
                    from: .bottom, containerAxis: .horizontal
                ) {
                    AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") {
                        delete(item)
                    }
                }
        }
    }
}
```

> **🛡 Tell the modifier where it lives.** The optional **`containerAxis: Axis?`** parameter lets you declare the enclosing scroll-axis explicitly. In **DEBUG builds** the modifier prints a one-time console hint when:
> - You use a vertical edge (`.top` / `.bottom`) without setting `containerAxis` — a generic reminder that vertical edges only work in horizontal-scrolling or non-scrolling containers.
> - You set `containerAxis:` to the same axis as the swipe edge — a more pointed warning that this exact combination is the conflict in the table above.
>
> Both warnings are gated behind `#if DEBUG` and absent from release builds. Pass `containerAxis: .horizontal` in `LazyHStack` carousels (as above) to declare your intent and silence the generic hint. The library cannot detect the parent's axis automatically — that would require UIKit interop, which would break the pure-SwiftUI guarantee.

### Rounded corners

Pass `cornerRadius:` to `AwesomeSwipeButton` (or to `awesomeButtonStyle(tint:cornerRadius:)`) for rounded action buttons. Default is `0` — square corners, matching the system look.

```swift
ItemRow(item)
    .awesomeSwipeActions(for: item, coordinator: coordinator) {
        AwesomeSwipeButton(tint: .blue, cornerRadius: 12, systemImage: "pencil") { edit(item) }
        AwesomeSwipeButton(tint: .red, role: .destructive, cornerRadius: 12, systemImage: "trash") { delete(item) }
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))   // also round the row's own corners
```

For pill-shaped buttons with visible gaps between them, use a large `cornerRadius` and add padding inside the `label:` builder:

```swift
AwesomeSwipeButton(tint: .orange, cornerRadius: 999) {
    star(item)
} label: {
    Image(systemName: "star.fill").padding(8)
}
```

The same `cornerRadius:` knob exists on `awesomeButtonStyle(tint:cornerRadius:)` for plain `Button` use:

```swift
Button { delete(item) } label: {
    Label("Delete", systemImage: "trash")
}
.awesomeButtonStyle(tint: .red, cornerRadius: 12)
```

### Using a standard SwiftUI Button

`AwesomeSwipeButton` is a convenience — anything you can build with `Button` works too. There are two paths.

**Option A — `awesomeButtonStyle(tint:)` modifier (recommended for plain buttons)**

```swift
.awesomeSwipeActions(for: item, coordinator: coordinator) {
    Button { archive(item) } label: {
        Label("Archive", systemImage: "archivebox")
    }
    .awesomeButtonStyle(tint: .orange)

    Button(role: .destructive) { delete(item) } label: {
        Label("Delete", systemImage: "trash")
    }
    .awesomeButtonStyle(tint: .red)
}
```

![standard button](https://github.com/user-attachments/assets/69945b60-4da8-4a3a-b494-2a023a4611f5)

**Option B — fully manual styling**

```swift
.awesomeSwipeActions(for: item, coordinator: coordinator) {
    Button { archive(item) } label: {
        Label("Archive", systemImage: "archivebox")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 74)
            .frame(maxHeight: .infinity)
    }
    .tint(.orange)
}
```

> **Note:** Always set `.tint(_:)` explicitly — the background colour is derived from the tint, not from `Button(role:)`.

### Programmatic open & close

**Close** the open row from anywhere — for example after an async action completes:

```swift
Button("Delete selected") {
    Task {
        await performDelete()
        coordinator.close()
    }
}
```

**Open** a specific row programmatically — useful for tutorials, onboarding peeks, and tests:

```swift
// Hint: peek the trash button on the first row
coordinator.open(id: items.first!.id, from: .trailing)
```

### Observing the open row

`coordinator.openRowID` publishes the user-supplied id of the currently open row, or `nil` when all rows are closed. It's safe to compare against your own ids:

```swift
.onReceive(coordinator.$openRowID) { id in
    if id == AnyHashable(focusedItem.id) {
        // this row just opened
    }
}
```

---

## Accessibility

Swipe-only UI is invisible to assistive technologies, so `AwesomeSwipeActions` exposes the buttons inside the panel as **accessibility actions** on the row itself — matching the rotor behaviour of native `swipeActions`.

VoiceOver users can:

1. Focus a row.
2. Open the actions rotor (swipe up or down with one finger when the rotor is set to *Actions*).
3. Pick one of the buttons (e.g. "Delete", "Archive") without ever performing the swipe gesture.

This works automatically — there's no extra modifier to add. The buttons you place in the `content:` builder are the same buttons VoiceOver picks up.

---

## Reduced motion

When the user has **Reduce Motion** enabled in System Settings → Accessibility → Motion, the spring snap animation is automatically replaced with a short linear curve (`linear(duration: 0.15)`). Buttons stay tappable and the rubber-band physics still apply during the gesture itself; only the snap-open / snap-close transitions are simplified. No additional configuration is required.

---

## API Reference

### `awesomeSwipeActions(id:coordinator:from:containerAxis:content:)`

```swift
func awesomeSwipeActions<ID: Hashable & Sendable, ActionContent: View>(
    id: ID,
    coordinator: AwesomeSwipeCoordinator,
    from edge: Edge = .trailing,
    containerAxis: Axis? = nil,
    @ViewBuilder content: () -> ActionContent
) -> some View
```

| Parameter | Description |
|---|---|
| `id` | A unique identifier for the row, used to coordinate open/close state. |
| `coordinator` | A shared `AwesomeSwipeCoordinator` instance created with `@State`. |
| `from` | The `Edge` from which actions slide in. Default: `.trailing`. Accepts `.top`, `.leading`, `.bottom`, `.trailing`. |
| `containerAxis` | Optional hint about the axis of the enclosing scroll view. Used in DEBUG builds to surface edge / axis mismatches as console warnings; ignored in release builds. Default: `nil` (no validation). |
| `content` | A `@ViewBuilder` closure containing the action buttons. |

### `awesomeSwipeActions(for:coordinator:from:containerAxis:content:)`

Convenience overload for `Identifiable` data — uses `item.id` automatically.

```swift
func awesomeSwipeActions<Item: Identifiable, ActionContent: View>(
    for item: Item,
    coordinator: AwesomeSwipeCoordinator,
    from edge: Edge = .trailing,
    containerAxis: Axis? = nil,
    @ViewBuilder content: () -> ActionContent
) -> some View where Item.ID: Hashable & Sendable
```

### `AwesomeSwipeCoordinator`

`@MainActor`-isolated `ObservableObject` that ensures only one row is open at a time. Create one per scroll view.

```swift
@State private var coordinator = AwesomeSwipeCoordinator()
```

| Member | Description |
|---|---|
| `openRowID: AnyHashable?` | Published. The user-supplied id of the currently open row (`nil` when all closed). Comparable with your own ids. |
| `close()` | Programmatically closes the open row, if any. |
| `open(id:from:)` | Programmatically opens a specific row from a given edge. Closes whatever row was open before. |

### `AwesomeSwipeButton`

A pre-styled convenience button for use inside `awesomeSwipeActions`.

```swift
// SF Symbol icon
AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit() }

// Destructive style (overrides the tint with red)
AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete() }

// Rounded corners
AwesomeSwipeButton(tint: .blue, cornerRadius: 12, systemImage: "pencil") { edit() }

// Pill (use a large radius + label padding so adjacent buttons get visible gaps)
AwesomeSwipeButton(tint: .orange, cornerRadius: 999) { star() } label: {
    Image(systemName: "star.fill").padding(8)
}

// Custom label
AwesomeSwipeButton(tint: .purple, action: { pin() }) {
    VStack(spacing: 4) {
        Image(systemName: "pin")
        Text("Pin").font(.caption2)
    }
}
```

| Parameter | Description |
|---|---|
| `tint` | Background colour of the button. Default: `.gray`. |
| `role` | When `.destructive`, the tint is overridden with `.red`. |
| `cornerRadius` | Radius applied to all four corners of the button's background and content. Default: `0` (square corners, matches the system swipe-actions look). |
| `systemImage` | An SF Symbol name (convenience initialiser). |
| `action` | Closure invoked when the button is tapped. |

> **Pill tip:** stacked rounded buttons in the same panel sit edge-to-edge by
> default (no gap between them), so adjacent corners trim each other. Add
> `.padding(_:)` inside the `label:` builder to introduce visible gaps and
> get capsule-style buttons.

### `awesomeButtonStyle(tint:)` / `awesomeButtonStyle(tint:cornerRadius:)`

Applies the standard `AwesomeSwipeActions` button appearance to any SwiftUI `Button`. An alternative to `AwesomeSwipeButton` when you prefer plain `Button` ergonomics.

```swift
func awesomeButtonStyle(tint: Color) -> some View
func awesomeButtonStyle(tint: Color, cornerRadius: CGFloat) -> some View
```

Sets a fixed cross-axis size of `74 pt`, white foreground, medium font weight, and a press-opacity feedback — identical to `AwesomeSwipeButton`. The fixed dimension is `width` inside a horizontal panel (leading/trailing) and `height` inside a vertical panel (top/bottom); axis is read from the environment automatically. Pass `cornerRadius:` to round the button's corners.

### `Edge`

The `from:` parameter accepts SwiftUI's native [`Edge`](https://developer.apple.com/documentation/swiftui/edge):

```swift
public enum Edge {
    case top       // swipe down → actions appear at the top
    case leading   // swipe right → actions appear on the left
    case bottom    // swipe up   → actions appear at the bottom
    case trailing  // swipe left → actions appear on the right (default)
}
```

---

## How It Works

### O(1) re-renders

The coordinator is held inside `AwesomeSwipeModifier` as a plain `let` constant — **not** as `@ObservedObject`. This means the modifier's `body` never establishes a SwiftUI observation dependency on the active row, so opening one row never causes other rows to re-render.

Cross-cell coordination happens via `.onReceive(coordinator.$activeKey)` — an imperative Combine side-effect that fires outside SwiftUI's body evaluation chain. Only the two affected rows (the one opening and the one closing) ever re-render per interaction.

### Scroll conflict prevention

Two layers of protection:

1. **Drag minimum-distance threshold.** `DragGesture` uses a `minimumDistance` of **10 pt** on iOS 17 / 18 / macOS 14 / 15 / visionOS 1 — small enough for snappy swipes. On **iOS 26+** the same threshold is bumped to **30 pt** via `#available`, because the iOS 26 SDK changed `ScrollView`'s pan-recognizer priority — at 10 pt our gesture would win against scroll. 30 pt gives the scroll-view's recognizer enough room to claim vertical drags first. Fully transparent — pre-26 builds keep the original feel.

2. **First-sample angle filter.** Once a drag is recognised, the modifier computes the gesture angle on the first sample using `atan2`. If the angle is more than **50° off the swipe axis** the drag is flagged as cross-axis and all subsequent samples are ignored, letting the scroll view take over naturally. Horizontal edges (`.leading` / `.trailing`) reject vertical drags this way; vertical edges (`.top` / `.bottom`) do the inverse.

### Rubber-band physics

Dragging past the action panel boundary applies the standard iOS rubber-band formula:

```
f(x) = (1 - 1 / ((x · c / d) + 1)) · d     where c = 0.55
```

This produces progressively increasing resistance identical to the native feel.

### Concurrency

`AwesomeSwipeCoordinator` is annotated `@MainActor` so all state mutations happen on the main thread. The package builds cleanly with `.enableUpcomingFeature("StrictConcurrency")` enabled.

---

## Migration

### From v1.x → v2.x

Version 2.0 renames the `edge:` parameter to `from:` and changes its type from `HorizontalEdge` to SwiftUI's four-case `Edge`. For most call sites it's a single-token edit:

```diff
- .awesomeSwipeActions(for: item, coordinator: coord, edge: .leading) { … }
+ .awesomeSwipeActions(for: item, coordinator: coord, from: .leading) { … }
```

Calls that omitted `edge:` (relying on the default `.trailing`) compile unchanged.

If you upgrade without renaming, the v1 overloads are kept as `@available(*, deprecated)` bridges and Xcode offers a one-tap fix-it. Both overloads will be removed in v3.

`closeAll()` was renamed to `close()` in v1 and remains as a deprecated alias; use `close()`.

### From v2.0 → v2.1 / v2.2 (additive — no action required)

- **2.1.0** added the `cornerRadius:` parameter on `AwesomeSwipeButton` and the `awesomeButtonStyle(tint:cornerRadius:)` overload. Existing calls compile unchanged with the default `0` (square corners).
- **2.2.0** fixed vertical scroll on iOS 26 (transparent — no API change) and added the optional `containerAxis: Axis? = nil` hint parameter. Existing 2.0 / 2.1 calls compile unchanged.

No code changes are required when bumping inside the v2.x range; SPM resolves the latest minor automatically.

---

## License

`AwesomeSwipeActions` is released under the [MIT License](LICENSE).
