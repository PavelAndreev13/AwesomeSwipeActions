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

fileprivate struct PreviewItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
}

private let mockItems: [PreviewItem] = (0..<20).map {
        PreviewItem(
            id: $0,
            title: "Item \($0 + 1)",
            subtitle: "Swipe left or right"
        )
}

fileprivate struct DemoRow: View {
    let item: PreviewItem
    var isDone: Bool = false
    var isFavorite: Bool = false

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
                    .strikethrough(isDone)
                    .foregroundStyle(isDone ? .secondary : .primary)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isFavorite ? Color.orange.opacity(0.1) : Color(.systemBackground))
    }
}

// MARK: Preview Views

/// Trailing edge demo: Edit + Delete buttons revealed by swiping left.
fileprivate struct TrailingEdgeDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = mockItems

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
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
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                     
                    }
                }
                .background(.clear)
            }
            .padding(.horizontal, 20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Trailing Edge")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Leading edge demo: Done + Star buttons revealed by swiping right.
fileprivate struct LeadingEdgeDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = mockItems
    @State private var doneIDs: Set<Int> = []
    @State private var favoriteIDs: Set<Int> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 5) {
                    ForEach(items) { item in
                        DemoRow(item: item)
                            .awesomeSwipeActions(
                                id: item.id,
                                coordinator: coordinator,
                                edge: .leading
                            ) {
                                AwesomeSwipeButton(tint: .green, systemImage: "checkmark") {
                                    toggleDone(item.id)
                                }
                                AwesomeSwipeButton(tint: .orange, systemImage: "star.fill") {
                                    toggleFavorite(item.id)
                                }
                            }
                         
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .background(.clear)
            }
            .padding(.horizontal, 20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Leading Edge")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func toggleDone(_ id: Int) {
        if doneIDs.contains(id) { doneIDs.remove(id) } else { doneIDs.insert(id) }
    }

    private func toggleFavorite(_ id: Int) {
        if favoriteIDs.contains(id) { favoriteIDs.remove(id) } else { favoriteIDs.insert(id) }
    }
}

/// Both edges demo: swipe right for Done/Star, swipe left for Delete.
fileprivate struct BothEdgesDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = mockItems
    @State private var doneIDs: Set<Int> = []
    @State private var favoriteIDs: Set<Int> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 5) {
                    ForEach(items) { item in
                        DemoRow(
                            item: item,
                            isDone: doneIDs.contains(item.id),
                            isFavorite: favoriteIDs.contains(item.id)
                        )
                        .awesomeSwipeActions(
                            id: item.id,
                            coordinator: coordinator,
                            edge: .leading
                        ) {
                            AwesomeSwipeButton(tint: .green, systemImage: "checkmark") {
                                toggleDone(item.id)
                            }
                            AwesomeSwipeButton(tint: .orange, systemImage: "star.fill") {
                                toggleFavorite(item.id)
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
                    
                    }
                }
                .background(.clear)
            }
            .padding(.horizontal, 20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Both Edges")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func toggleDone(_ id: Int) {
        if doneIDs.contains(id) { doneIDs.remove(id) } else { doneIDs.insert(id) }
    }

    private func toggleFavorite(_ id: Int) {
        if favoriteIDs.contains(id) { favoriteIDs.remove(id) } else { favoriteIDs.insert(id) }
    }
}

// MARK: PreviewProvider

/// Standard SwiftUI Button demo — shows that .tint() + .frame() is all that's needed.
fileprivate struct StandardButtonDemo: View {
    @State private var coordinator = AwesomeSwipeCoordinator()
    @State private var items = mockItems

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
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
                                        .font(.caption2)
                                        .frame(width: 74)
                                        .frame(maxHeight: .infinity)
                                }
                                .tint(.orange)

                                Button(role: .destructive) {
                                    items.removeAll { $0.id == item.id }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .font(.caption)
                                        .frame(width: 74)
                                        .frame(maxHeight: .infinity)
                                }
                                .tint(.red)   // needed: custom ButtonStyle doesn't inherit role colour
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                       
                    }
                }
               
                .background(.clear)
            }
            .padding(.horizontal, 20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Standard Button")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AwesomeSwipeActions_Previews: PreviewProvider {
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


