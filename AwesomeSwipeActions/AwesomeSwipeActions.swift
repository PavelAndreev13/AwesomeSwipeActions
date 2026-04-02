/// # AwesomeSwipeActions
///
/// A SwiftUI framework providing fully custom swipe actions for list rows,
/// designed as a drop-in analog to SwiftUI's native `swipeActions` modifier.
///
/// ## Public API
/// - ``AwesomeSwipeCoordinator`` — coordinates open/close state across all rows
/// - ``AwesomeSwipeButton``      — declares a single swipe action button
/// - ``SwipeActionEdge``         — `.leading` or `.trailing`
/// - `View.awesomeSwipeActions`  — the main modifier applied to each row
///
/// ## Usage with List
/// ```swift
/// @State private var coordinator = AwesomeSwipeCoordinator()
///
/// List {
///     ForEach(items) { item in
///         Text(item.title)
///             .awesomeSwipeActions(id: item.id, coordinator: coordinator) {
///                 AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit(item) }
///                 AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
///             }
///     }
/// }
/// ```
///
/// ## Usage with ScrollView + LazyVStack
/// ```swift
/// @State private var coordinator = AwesomeSwipeCoordinator()
///
/// ScrollView {
///     LazyVStack(spacing: 0) {
///         ForEach(items) { item in
///             Text(item.title)
///                 .awesomeSwipeActions(id: item.id, coordinator: coordinator) {
///                     AwesomeSwipeButton(tint: .orange, systemImage: "star") { favourite(item) }
///                     AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
///                 }
///         }
///     }
/// }
/// ```
import SwiftUI

// MARK: - Previews

// Previews use UIColor system colours — guard to iOS/tvOS only.
#if DEBUG && canImport(UIKit)
private struct PreviewItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
}

private let sampleItems = (0..<20).map {
    PreviewItem(id: $0, title: "Item \($0 + 1)", subtitle: "Swipe left or right")
}

private struct DemoRow: View {
    let item: PreviewItem

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Text("\(item.id + 1)")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

// MARK: Preview Views

/// Trailing edge demo: Edit + Delete buttons revealed by swiping left.
private struct TrailingEdgeDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = sampleItems

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(items) { item in
                        DemoRow(item: item)
                            .awesomeSwipeActions(
                                id: item.id,
                                coordinator: coordinator,
                                edge: .trailing
                            ) {
                                AwesomeSwipeButton(tint: .blue, systemImage: "pencil") {
                                    print("Edit \(item.title)")
                                }
                                AwesomeSwipeButton(
                                    tint: .red,
                                    role: .destructive,
                                    systemImage: "trash"
                                ) {
                                    items.removeAll { $0.id == item.id }
                                }
                            }
                        Divider().padding(.leading, 68)
                    }
                }
                .background(Color(.systemBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Trailing Edge")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Leading edge demo: Done + Star buttons revealed by swiping right.
private struct LeadingEdgeDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = sampleItems

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(items) { item in
                        DemoRow(item: item)
                            .awesomeSwipeActions(
                                id: item.id,
                                coordinator: coordinator,
                                edge: .leading
                            ) {
                                AwesomeSwipeButton(tint: .green, systemImage: "checkmark") {
                                    print("Done \(item.title)")
                                }
                                AwesomeSwipeButton(tint: .orange, systemImage: "star.fill") {
                                    print("Favourite \(item.title)")
                                }
                            }
                        Divider().padding(.leading, 68)
                    }
                }
                .background(Color(.systemBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Leading Edge")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Both edges demo: swipe right for Done, swipe left for Delete.
private struct BothEdgesDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = sampleItems

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(items) { item in
                        DemoRow(item: item)
                            .awesomeSwipeActions(
                                id: item.id,
                                coordinator: coordinator,
                                edge: .leading
                            ) {
                                AwesomeSwipeButton(tint: .green, systemImage: "checkmark") {
                                    print("Done \(item.title)")
                                }
                            }
                            .awesomeSwipeActions(
                                id: item.id,
                                coordinator: coordinator,
                                edge: .trailing
                            ) {
                                AwesomeSwipeButton(
                                    tint: .red,
                                    role: .destructive,
                                    systemImage: "trash"
                                ) {
                                    items.removeAll { $0.id == item.id }
                                }
                            }
                        Divider().padding(.leading, 68)
                    }
                }
                .background(Color(.systemBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Both Edges")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: PreviewProvider

/// Standard SwiftUI Button demo — shows that .tint() + .frame() is all that's needed.
private struct StandardButtonDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = sampleItems

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(items) { item in
                        DemoRow(item: item)
                            .awesomeSwipeActions(
                                id: item.id,
                                coordinator: coordinator,
                                edge: .trailing
                            ) {
                                // Standard SwiftUI Button — no AwesomeSwipeButton needed
                                Button { print("Archive \(item.title)") } label: {
                                    Label("Archive", systemImage: "archivebox")
                                        .frame(width: 74)
                                        .frame(maxHeight: .infinity)
                                }
                                .tint(.orange)

                                Button(role: .destructive) {
                                    items.removeAll { $0.id == item.id }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .frame(width: 74)
                                        .frame(maxHeight: .infinity)
                                }
                                .tint(.red)   // needed: custom ButtonStyle doesn't inherit role colour
                            }
                        Divider().padding(.leading, 68)
                    }
                }
                .background(Color(.systemBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Standard Button")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AwesomeSwipeAction_Previews: PreviewProvider {
    static var previews: some View {
        TrailingEdgeDemo()
            .previewDisplayName("Trailing — Edit & Delete")
        LeadingEdgeDemo()
            .previewDisplayName("Leading — Done & Star")
        BothEdgesDemo()
            .previewDisplayName("Both Edges")
        StandardButtonDemo()
            .previewDisplayName("Standard SwiftUI Button")
    }
}
#endif


