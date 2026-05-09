# ``AwesomeSwipeActions``

Swipe actions for `ScrollView` — everything SwiftUI's `swipeActions` gives you inside `List`, now available in any scrollable container.

## Overview

SwiftUI's built-in `swipeActions` modifier is tied exclusively to `List`. The moment you switch to `ScrollView + LazyVStack` — for custom spacing, fully custom cells, sticky headers, or pull-to-refresh — swipe actions stop working.

**AwesomeSwipeActions** closes that gap. It brings the same swipe-to-reveal behaviour to any scrollable view, with an API intentionally designed to mirror `.swipeActions` so migration is a matter of minutes.

### Key features

- **Works where `swipeActions` doesn't** — `ScrollView + LazyVStack`, `ScrollView + LazyHStack`, custom containers
- **Four edges** — `.leading`, `.trailing`, `.top`, `.bottom` via the `from: Edge` parameter
- **Standard `Button` support** — use `AwesomeSwipeButton` for convenience, or any SwiftUI `Button` with `.tint()`
- **O(1) re-renders** — only the opening and closing rows re-render; the rest of the scroll view is untouched
- **Scroll-safe gestures** — angle filtering prevents interference with the enclosing scroll view (perpendicular axes only)
- **Native physics** — rubber-banding past the action panel and velocity-based snap
- **Programmatic open & close** via the coordinator
- **Reduced Motion** — spring snaps replaced with linear curves automatically

### Why not just use swipeActions?

```
ScrollView {                       // ← swipeActions does NOT work here
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item)
                .swipeActions { … } // ← silently ignored
        }
    }
}
```

`swipeActions` is processed by `UITableView` under the hood. Outside of `List` there is no table view, so the modifier has no effect. `AwesomeSwipeActions` implements the same behaviour in pure SwiftUI, independent of the container.

### Comparison with swipeActions

| | `swipeActions` | `AwesomeSwipeActions` |
|---|:---:|:---:|
| `List` | ✅ | ✅ |
| `ScrollView + LazyVStack` | ❌ | ✅ |
| `ScrollView + LazyHStack` | ❌ | ✅ |
| Custom spacing & separators | ❌ | ✅ |
| Leading & trailing edges | ✅ | ✅ |
| Top & bottom edges (vertical swipe) | ❌ | ✅ |
| Rubber-band & velocity snap | ❌ | ✅ |
| Programmatic open & close | ❌ | ✅ |
| Honors Reduced Motion | partial | ✅ |

---

## Getting Started

### 1 — Create a coordinator

Create one ``AwesomeSwipeCoordinator`` per scroll view using `@State`. It ensures only one row is open at a time across the entire scroll view.

```swift
@State private var swipeCoordinator = AwesomeSwipeCoordinator()
```

### 2 — Wrap your rows in ScrollView + LazyVStack

Attach `.awesomeSwipeActions` to each row inside `ForEach`. Pass the same coordinator instance to every row.

```swift
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(messages) { message in
            MessageRow(message: message)
                .awesomeSwipeActions(id: message.id, coordinator: swipeCoordinator) {
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

### 3 — Use standard Button for full control

`AwesomeSwipeButton` is a convenience wrapper. Any SwiftUI `Button` with a `.tint()` modifier works inside the closure:

```swift
.awesomeSwipeActions(id: item.id, coordinator: swipeCoordinator, from: .leading) {
    Button { archive(item) } label: {
        Label("Archive", systemImage: "archivebox")
            .frame(width: 74)
            .frame(maxHeight: .infinity)
    }
    .tint(.orange)
}
```

> **Note:** Always add `.tint(color)` explicitly when using a plain `Button`.
> Custom `ButtonStyle` implementations do not inherit the colour from `Button(role: .destructive)`,
> so `.tint(.red)` must be set manually for destructive actions.

### Both edges on the same row

Apply the modifier twice with different edges:

```swift
MessageRow(message: message)
    .awesomeSwipeActions(id: message.id, coordinator: swipeCoordinator, from: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(message) }
    }
    .awesomeSwipeActions(id: message.id, coordinator: swipeCoordinator, from: .trailing) {
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(message) }
    }
```

### Programmatic open & close

**Close** the currently open row from anywhere — for example after a network request completes:

```swift
Task {
    try await performAction()
    swipeCoordinator.close()
}
```

**Open** any row from any edge programmatically — useful for tutorials and tests:

```swift
swipeCoordinator.open(id: messages.first!.id, from: .trailing)
```

### Vertical swipe (top / bottom)

Vertical edges work the same way as horizontal ones, but care is needed about
the enclosing scroll view's axis — see <doc:Choosing-Edges>.

```swift
Card(item: item)
    .awesomeSwipeActions(for: item, coordinator: swipeCoordinator, from: .top) {
        AwesomeSwipeButton(tint: .orange, systemImage: "star.fill") { favourite(item) }
    }
```

---

## Topics

### Essentials

- ``AwesomeSwipeCoordinator``

### Declaring Actions

- ``AwesomeSwipeButton``

### Articles

- <doc:Choosing-Edges>
