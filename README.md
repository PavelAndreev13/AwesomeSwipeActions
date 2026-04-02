
<img width="2042" height="483" alt="Logo" src="https://github.com/user-attachments/assets/31412f39-dc89-4abd-8d2e-4cee9cfb87ac" />

Swipe actions for `ScrollView` — everything SwiftUI's `swipeActions` gives you inside `List`, now available in any scrollable container.

```swift
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(messages) { message in
            MessageRow(message: message)
                .awesomeSwipeActions(id: message.id, coordinator: coordinator) {
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

## Why AwesomeSwipeActions?

SwiftUI's built-in `.swipeActions` is tied to `List` — it relies on `UITableView` under the hood and is **silently ignored** the moment you switch to `ScrollView`:

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item)
                .swipeActions { … }  // ← has NO effect here
        }
    }
}
```

`AwesomeSwipeActions` fills that gap with a pure-SwiftUI implementation that works in any scrollable container, mirrors the `.swipeActions` API, and adds features the native modifier lacks.

| | `swipeActions` | `AwesomeSwipeActions` |
|---|:---:|:---:|
| `List` | ✅ | ✅ |
| `ScrollView + LazyVStack` | ❌ | ✅ |
| `ScrollView + LazyHStack` | ❌ | ✅ |
| Custom spacing & separators | ❌ | ✅ |
| Leading & trailing edge | ✅ | ✅ |
| Rubber-band & velocity snap | ❌ | ✅ |
| Programmatic close | ❌ | ✅ |
| O(1) re-renders on large lists | ❌ | ✅ |

---

## Features

- **Works where `swipeActions` doesn't** — any `ScrollView`-based layout
- **Familiar API** — `.awesomeSwipeActions` mirrors the signature of `.swipeActions`
- **Leading & trailing edges** — independently configurable per row
- **Standard `Button` support** — use `AwesomeSwipeButton` for convenience, or any SwiftUI `Button` with `.tint()`
- **O(1) re-renders** — only the opening and closing rows re-render; the rest of the list is untouched
- **Scroll-safe gestures** — horizontal angle filtering prevents any interference with vertical scrolling
- **Native physics** — rubber-banding past the action panel and velocity-based snap

---

## Requirements

| | Minimum |
|---|---|
| iOS | 17.0 |
| macOS | 14.0 |
| visionOS | 1.0 |
| Swift | 5.9 |
| Xcode | 15.0 |

---

## Installation

### Swift Package Manager

**In Xcode:**

1. Open your project and go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/your-username/AwesomeSwipeAction
   ```
3. Select **Up to Next Major Version** starting from `1.0.0`
4. Click **Add Package**

**In `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/your-username/AwesomeSwipeActions", from: "1.0.0")
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

### 1 — Import the library

```swift
import AwesomeSwipeActions
```

### 2 — Create a coordinator

Create one `AwesomeSwipeCoordinator` per scroll view using `@State`. It ensures only one row is open at a time.

```swift
@State private var coordinator = AwesomeSwipeCoordinator()
```

### 3 — Attach `.awesomeSwipeActions` to each row

```swift
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(messages) { message in
            MessageRow(message: message)
                .awesomeSwipeActions(id: message.id, coordinator: coordinator) {
                    AwesomeSwipeButton(tint: .orange, systemImage: "bell") {
                        remind(message)
                    }
                    AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") {
                        delete(message)
                    }
                }
        }
    }
}
```

That's it. Swipe left on any row to reveal the buttons.

---

## Usage

### Trailing edge (default)

Swipe **left** to reveal actions on the right side of the row:

```swift
ItemRow(item)
    .awesomeSwipeActions(id: item.id, coordinator: coordinator) {
        AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit(item) }
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
    }
```

### Leading edge

Swipe **right** to reveal actions on the left side of the row:

```swift
ItemRow(item)
    .awesomeSwipeActions(id: item.id, coordinator: coordinator, edge: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(item) }
    }
```

### Both edges on the same row

Apply the modifier twice with different edges:

```swift
ItemRow(item)
    .awesomeSwipeActions(id: item.id, coordinator: coordinator, edge: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { markRead(item) }
    }
    .awesomeSwipeActions(id: item.id, coordinator: coordinator, edge: .trailing) {
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
    }
```

### Using standard SwiftUI `Button`

`AwesomeSwipeButton` is optional. There are two ways to use a plain `Button` instead.

#### Option A — `.awesomeButtonStyle(tint:)` modifier

The quickest way. Apply `.awesomeButtonStyle(tint:)` to any `Button` and it gets the same fixed width, white foreground, and press feedback as `AwesomeSwipeButton`:

```swift
.awesomeSwipeActions(id: item.id, coordinator: coordinator) {
    Button { archive(item) } label: {
        Label("Archive", systemImage: "archivebox")
    }
    .awesomeButtonStyle(tint: .orange)

    Button { delete(item) } label: {
        Label("Delete", systemImage: "trash")
    }
    .awesomeButtonStyle(tint: .red)
}
```

#### Option B — fully manual styling

Full control over every detail. Set the frame, foreground, and tint yourself:

```swift
.awesomeSwipeActions(id: item.id, coordinator: coordinator) {
    Button {
        archive(item)
    } label: {
        Label("Archive", systemImage: "archivebox")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 74)
            .frame(maxHeight: .infinity)
    }
    .tint(.orange)

    Button {
        delete(item)
    } label: {
        Label("Delete", systemImage: "trash")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 74)
            .frame(maxHeight: .infinity)
    }
    .tint(.red)
}
```

> **Note:** Always set `.tint(color)` explicitly — background colour is derived from the tint, not from `Button(role:)`.

### Programmatic close

Close the open row from anywhere — for example after an async action completes:

```swift
Button("Delete") {
    Task {
        await performDelete()
        coordinator.closeAll()
    }
}
```

You can also observe which row is open by subscribing to `coordinator.$activeID`:

```swift
.onReceive(coordinator.$activeID) { id in
    print("Active row: \(String(describing: id))")
}
```

---

## API Reference

### `awesomeSwipeActions(id:coordinator:edge:content:)`

```swift
func awesomeSwipeActions<ID: Hashable, ActionContent: View>(
    id: ID,
    coordinator: AwesomeSwipeCoordinator,
    edge: SwipeActionEdge = .trailing,
    @ViewBuilder content: () -> ActionContent
) -> some View
```

| Parameter | Description |
|---|---|
| `id` | A unique identifier for the row, used to coordinate open/close state |
| `coordinator` | A shared `AwesomeSwipeCoordinator` instance created with `@State` |
| `edge` | The edge from which actions slide in. Default: `.trailing` |
| `content` | A `@ViewBuilder` closure containing action buttons |

---

### `AwesomeSwipeCoordinator`

Coordinates swipe state across all rows. Create one per scroll view.

```swift
@State private var coordinator = AwesomeSwipeCoordinator()
```

| Member | Description |
|---|---|
| `activeID: AnyHashable?` | The ID of the currently open row (`nil` if all closed) |
| `closeAll()` | Programmatically closes whichever row is currently open |

---

### `AwesomeSwipeButton`

A pre-styled convenience button for use inside `.awesomeSwipeActions`.

```swift
// SF Symbol icon
AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit() }

// Destructive style (automatically uses red tint)
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
| `tint` | Background colour of the button. Default: `.gray` |
| `role` | When `.destructive`, tint is overridden with `.red` |
| `systemImage` | SF Symbol name (convenience initialiser) |
| `action` | Closure called when the button is tapped |

---

### `awesomeButtonStyle(tint:)`

Applies the standard AwesomeSwipeAction button appearance to any SwiftUI `Button`. An alternative to `AwesomeSwipeButton` when you want to use a plain `Button` without boilerplate.

```swift
func awesomeButtonStyle(tint: Color) -> some View
```

Sets a fixed width of `74 pt`, `maxHeight: .infinity`, white foreground, medium font weight, and press-opacity feedback — identical to `AwesomeSwipeButton`.

---

### `SwipeActionEdge`

```swift
public enum SwipeActionEdge {
    case leading   // swipe right → actions appear on the left
    case trailing  // swipe left  → actions appear on the right (default)
}
```

---

## How It Works

### O(1) re-renders

The coordinator is held inside `AwesomeSwipeModifier` as a plain `let` constant — **not** as `@ObservedObject`. This means the modifier's `body` never establishes a SwiftUI observation dependency on `activeID`, so opening one row never causes other rows to re-render.

Cross-cell coordination happens via `.onReceive(coordinator.$activeID)` — an imperative Combine side-effect that fires outside SwiftUI's body evaluation chain. Only the two affected rows (the one opening and the one closing) ever re-render per interaction.

### Scroll conflict prevention

The first drag sample computes the angle from horizontal using `atan2(dy, dx)`. If the angle exceeds 50° the gesture is flagged as vertical and all subsequent samples are ignored, allowing the scroll view to take over naturally.

### Rubber-band physics

Dragging past the action panel boundary applies the standard iOS rubber-band formula:

```
f(x) = (1 - 1 / ((x · c / d) + 1)) · d     where c = 0.55
```

This provides progressively increasing resistance identical to the native feel.

---

## License

AwesomeSwipeAction is available under the MIT license. See the [LICENSE](LICENSE) file for details.
