<div align="center">
<img width="700" height="168" alt="asa-logo-horizontal-dark 1" src="https://github.com/user-attachments/assets/9e80dc0a-f7e0-4e55-8f14-ab09f1c75fbd" />

<img width="400" height="600" alt="no_name" src="https://github.com/user-attachments/assets/c160aedc-cdc6-4614-8999-69caef3d3aea" />


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
  - [Using a standard SwiftUI Button](#using-a-standard-swiftui-button)
  - [Programmatic close](#programmatic-close)
  - [Observing the open row](#observing-the-open-row)
- [Accessibility](#accessibility)
- [API Reference](#api-reference)
- [How It Works](#how-it-works)
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
| Rubber-band & velocity snap | ❌ | ✅ |
| Programmatic close | ❌ | ✅ |
| Observe the open row | ❌ | ✅ |
| O(1) re-renders on large lists | ❌ | ✅ |
| VoiceOver rotor actions | ✅ | ✅ |

---

## Features

- 🎯 **Drop-in API** — `awesomeSwipeActions` mirrors the signature of native `swipeActions`, including the `edge:` parameter (`HorizontalEdge`).
- 🪶 **Pure SwiftUI** — no `UIKit` or `AppKit` interop, no UIViewRepresentable; works on iOS, macOS, and visionOS.
- ⚡ **O(1) re-renders** — only the opening and closing rows update; the rest of the list is untouched, even with thousands of rows.
- 🌊 **Native physics** — rubber-band past the panel boundary and velocity-based snap, identical to the system feel.
- 🎚 **Both edges** — leading and trailing actions can coexist on the same row.
- 🎨 **Flexible buttons** — use the convenience `AwesomeSwipeButton`, or any standard SwiftUI `Button` with `.tint(_:)`.
- ♿ **VoiceOver-ready** — actions are exposed as `accessibilityActions`, matching the rotor behaviour of native `swipeActions`.
- 🔄 **Reactive** — observe `coordinator.openRowID` to react when a row opens or closes.
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

---

## Installation

### Swift Package Manager

#### In Xcode

1. Open your project and choose **File → Add Package Dependencies…**
2. Paste the repository URL:
   ```
   https://github.com/PavelAndreev13/AwesomeSwipeActions
   ```
3. Choose **Up to Next Major Version** starting at `1.0.0`.
4. Click **Add Package**.

#### In `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/PavelAndreev13/AwesomeSwipeActions", from: "1.0.0")
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
    .awesomeSwipeActions(for: item, coordinator: coordinator, edge: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(item) }
    }
```

![leading](https://github.com/user-attachments/assets/3309fd44-783b-43d7-bd8d-91e39daccce2)

### Both edges on the same row

Apply the modifier twice with different edges — the same `coordinator` will keep them synchronised:

```swift
ItemRow(item)
    .awesomeSwipeActions(for: item, coordinator: coordinator, edge: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(item) }
    }
    .awesomeSwipeActions(for: item, coordinator: coordinator, edge: .trailing) {
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
    }
```

![both edges](https://github.com/user-attachments/assets/e84b73be-643b-4ba5-994e-baf3efb2bc35)

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

### Programmatic close

Close the open row from anywhere — for example after an async action completes:

```swift
Button("Delete selected") {
    Task {
        await performDelete()
        coordinator.close()
    }
}
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

## API Reference

### `awesomeSwipeActions(id:coordinator:edge:content:)`

```swift
func awesomeSwipeActions<ID: Hashable & Sendable, ActionContent: View>(
    id: ID,
    coordinator: AwesomeSwipeCoordinator,
    edge: HorizontalEdge = .trailing,
    @ViewBuilder content: () -> ActionContent
) -> some View
```

| Parameter | Description |
|---|---|
| `id` | A unique identifier for the row, used to coordinate open/close state. |
| `coordinator` | A shared `AwesomeSwipeCoordinator` instance created with `@State`. |
| `edge` | The `HorizontalEdge` from which actions slide in. Default: `.trailing`. |
| `content` | A `@ViewBuilder` closure containing the action buttons. |

### `awesomeSwipeActions(for:coordinator:edge:content:)`

Convenience overload for `Identifiable` data — uses `item.id` automatically.

```swift
func awesomeSwipeActions<Item: Identifiable, ActionContent: View>(
    for item: Item,
    coordinator: AwesomeSwipeCoordinator,
    edge: HorizontalEdge = .trailing,
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

### `AwesomeSwipeButton`

A pre-styled convenience button for use inside `awesomeSwipeActions`.

```swift
// SF Symbol icon
AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit() }

// Destructive style (overrides the tint with red)
AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete() }

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
| `systemImage` | An SF Symbol name (convenience initialiser). |
| `action` | Closure invoked when the button is tapped. |

### `awesomeButtonStyle(tint:)`

Applies the standard `AwesomeSwipeActions` button appearance to any SwiftUI `Button`. An alternative to `AwesomeSwipeButton` when you prefer plain `Button` ergonomics.

```swift
func awesomeButtonStyle(tint: Color) -> some View
```

Sets a fixed width of `74 pt`, `maxHeight: .infinity`, white foreground, medium font weight, and a press-opacity feedback — identical to `AwesomeSwipeButton`.

### `HorizontalEdge`

The `edge:` parameter accepts SwiftUI's native [`HorizontalEdge`](https://developer.apple.com/documentation/swiftui/horizontaledge):

```swift
public enum HorizontalEdge {
    case leading   // swipe right → actions appear on the left
    case trailing  // swipe left  → actions appear on the right (default)
}
```

---

## How It Works

### O(1) re-renders

The coordinator is held inside `AwesomeSwipeModifier` as a plain `let` constant — **not** as `@ObservedObject`. This means the modifier's `body` never establishes a SwiftUI observation dependency on the active row, so opening one row never causes other rows to re-render.

Cross-cell coordination happens via `.onReceive(coordinator.$activeKey)` — an imperative Combine side-effect that fires outside SwiftUI's body evaluation chain. Only the two affected rows (the one opening and the one closing) ever re-render per interaction.

### Scroll conflict prevention

The first drag sample computes the angle from horizontal using `atan2(dy, dx)`. If the angle exceeds 50° the gesture is flagged as vertical and all subsequent samples are ignored, allowing the scroll view to take over naturally.

### Rubber-band physics

Dragging past the action panel boundary applies the standard iOS rubber-band formula:

```
f(x) = (1 - 1 / ((x · c / d) + 1)) · d     where c = 0.55
```

This produces progressively increasing resistance identical to the native feel.

### Concurrency

`AwesomeSwipeCoordinator` is annotated `@MainActor` so all state mutations happen on the main thread. The package builds cleanly with `.enableUpcomingFeature("StrictConcurrency")` enabled.

---

## License

`AwesomeSwipeActions` is released under the [MIT License](LICENSE).
