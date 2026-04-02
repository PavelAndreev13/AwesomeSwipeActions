# ``AwesomeSwipeActions``

Swipe actions for `ScrollView` — everything SwiftUI's `swipeActions` gives you inside `List`, now available in any scrollable container.

## Overview

SwiftUI's built-in `swipeActions` modifier is tied exclusively to `List`. The moment you switch to `ScrollView + LazyVStack` — for custom spacing, fully custom cells, sticky headers, or pull-to-refresh — swipe actions stop working.

**AwesomeSwipeActions** closes that gap. It brings the same swipe-to-reveal behaviour to any scrollable view, with an API intentionally designed to mirror `.swipeActions` so migration is a matter of minutes.

### Key features

- **Works where `swipeActions` doesn't** — `ScrollView + LazyVStack`, `ScrollView + LazyHStack`, custom containers
- **Familiar API** — `.awesomeSwipeActions` mirrors the signature of `.swipeActions` exactly
- **Leading & trailing edges** — reveal actions by swiping right or left, independently per row
- **Standard `Button` support** — use `AwesomeSwipeButton` for convenience, or any SwiftUI `Button` with `.tint()`
- **O(1) re-renders** — only the opening and closing rows re-render; the rest of the scroll view is untouched
- **Scroll-safe gestures** — horizontal angle filtering prevents any interference with vertical scrolling
- **Native physics** — rubber-banding past the action panel and velocity-based snap

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
| Leading & trailing edge | ✅ | ✅ |
| Rubber-band & velocity snap | ❌ | ✅ |
| Programmatic close | ❌ | ✅ |

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
.awesomeSwipeActions(id: item.id, coordinator: swipeCoordinator, edge: .leading) {
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
    .awesomeSwipeActions(id: message.id, coordinator: swipeCoordinator, edge: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(message) }
    }
    .awesomeSwipeActions(id: message.id, coordinator: swipeCoordinator, edge: .trailing) {
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(message) }
    }
```

### Programmatic close

Close the currently open row from anywhere — for example after a network request completes:

```swift
Task {
    try await performAction()
    swipeCoordinator.closeAll()
}
```

---

## Topics

### Essentials

- ``AwesomeSwipeCoordinator``

### Declaring Actions

- ``AwesomeSwipeButton``
- ``SwipeActionEdge``
