# Choosing edges

Pick a swipe edge that doesn't conflict with the enclosing scroll view.

## Overview

`AwesomeSwipeActions` accepts any `SwiftUI.Edge` for its `from:` parameter:
`.leading`, `.trailing`, `.top`, `.bottom`. Two edges (`.leading`/`.trailing`)
swipe horizontally; the other two (`.top`/`.bottom`) swipe vertically.

Mixing a swipe axis with the same scroll axis creates an unavoidable conflict:
both gestures want the same drag, and the scroll view usually wins. The
library protects you from this *across* axes — the first drag sample is
classified at 50° from the swipe axis, and anything past that threshold is
treated as a scroll instead of a swipe — but it cannot disambiguate within
the same axis.

The conflict-free combinations:

| | scroll axis: vertical | scroll axis: horizontal | non-scrolling |
|---|---|---|---|
| `.leading` / `.trailing` | ✅ | ⚠️ conflict | ✅ |
| `.top` / `.bottom` | ⚠️ conflict | ✅ | ✅ |

## Common scenarios

### Vertical list with horizontal swipe (most common)

`ScrollView { LazyVStack { … } }` with `from: .leading` or `.trailing`.
This is the classic mail/messages app layout — the swipe axis is
perpendicular to the scroll axis, so the angle filter cleanly separates
the two intents. Use it whenever possible.

### Horizontal carousel with vertical swipe

`ScrollView(.horizontal) { LazyHStack { … } }` with `from: .top` or
`.bottom`. Cards in a carousel benefit from vertical swipes for
favourite/delete because users are already used to horizontal scrolling
and vertical swipes feel like a different intent.

### Non-scrolling layouts

A static stack of cards, a single highlighted row, a popover — anywhere
the swipe is not enclosed in a `ScrollView`, both axes are safe. Use
whichever direction makes the most sense for your design.

### Combining multiple edges on one row

Using up to four edges on the same row is supported as long as each edge
respects the conflict table above. The shared coordinator keeps them in
sync — opening one closes the others automatically.

```swift
ItemRow(item)
    .awesomeSwipeActions(for: item, coordinator: coord, from: .leading) {
        AwesomeSwipeButton(tint: .green, systemImage: "checkmark") { … }
    }
    .awesomeSwipeActions(for: item, coordinator: coord, from: .trailing) {
        AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { … }
    }
```

## Why we don't auto-detect the conflict

A child view in SwiftUI cannot reliably ask its parent `ScrollView` "what is
your scroll axis?" — there is no environment value or read API for it, and
walking up the hierarchy via `UIViewRepresentable` would break the library's
pure-SwiftUI promise. Picking the right edge is part of the design choice
when you adopt vertical swipes; this article exists to make the trade-off
explicit.
