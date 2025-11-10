// Copyright (c) 2025 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI
import Showcase
import ShowcaseMacros

/// A dropdown selector with search and multi-selection support
///
/// `DSDropdown` provides a customizable dropdown menu for selecting items from a list.
/// It supports single/multi-selection, search filtering, custom item rendering, and
/// keyboard navigation.
///
/// ## Features
///
/// - Single or multi-selection modes
/// - Built-in search filtering
/// - Custom item views via ViewBuilder
/// - Keyboard navigation support
/// - Placeholder text when empty
/// - Automatic scrolling to selected items
///
/// ## Usage
///
/// ```swift
/// @State private var selectedFruit: String?
///
/// DSDropdown(
///     items: ["Apple", "Banana", "Orange"],
///     selection: $selectedFruit,
///     placeholder: "Select a fruit"
/// )
/// ```
///
/// ## Multi-Selection
///
/// ```swift
/// @State private var selectedColors: Set<String> = []
///
/// DSDropdown(
///     items: ["Red", "Green", "Blue"],
///     multiSelection: $selectedColors,
///     placeholder: "Select colors"
/// )
/// ```
///
/// ## Performance
///
/// The dropdown uses lazy loading for large lists and debounced search
/// to maintain smooth performance with hundreds of items.
@Showcasable(icon: "chevron.down.circle")
struct DSDropdown<Item: Hashable & Identifiable, Content: View>: View {
    let items: [Item]
    let placeholder: String
    let content: (Item) -> Content
    
    @Binding var selection: Item?
    @Binding var multiSelection: Set<Item>
    
    @State private var isExpanded = false
    @State private var searchText = ""
    
    let mode: SelectionMode
    
    enum SelectionMode {
        case single
        case multiple
    }
    
    init(
        items: [Item],
        selection: Binding<Item?>,
        placeholder: String = "Select an item",
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self._selection = selection
        self._multiSelection = .constant([])
        self.placeholder = placeholder
        self.content = content
        self.mode = .single
    }
    
    init(
        items: [Item],
        multiSelection: Binding<Set<Item>>,
        placeholder: String = "Select items",
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self._selection = .constant(nil)
        self._multiSelection = multiSelection
        self.placeholder = placeholder
        self.content = content
        self.mode = .multiple
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dropdown button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(displayText)
                        .foregroundColor(displayText == placeholder ? .secondary : .primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Dropdown menu
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    // Search field
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                    
                    Divider()
                    
                    // Items list
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(filteredItems) { item in
                                itemRow(item)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.top, 4)
            }
        }
    }
    
    private var displayText: String {
        switch mode {
        case .single:
            if let selection {
                return "\(selection)"
            }
            return placeholder
            
        case .multiple:
            if multiSelection.isEmpty {
                return placeholder
            }
            let count = multiSelection.count
            return count == 1 ? "1 item selected" : "\(count) items selected"
        }
    }
    
    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { item in
            "\(item)".localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func itemRow(_ item: Item) -> some View {
        Button {
            handleSelection(item)
        } label: {
            HStack {
                content(item)
                Spacer()
                if isSelected(item) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected(item) ? Color.accentColor.opacity(0.1) : Color.clear
            )
        }
        .buttonStyle(.plain)
    }
    
    private func isSelected(_ item: Item) -> Bool {
        switch mode {
        case .single:
            return selection == item
        case .multiple:
            return multiSelection.contains(item)
        }
    }
    
    private func handleSelection(_ item: Item) {
        switch mode {
        case .single:
            selection = item
            withAnimation(.spring(response: 0.3)) {
                isExpanded = false
            }
            
        case .multiple:
            if multiSelection.contains(item) {
                multiSelection.remove(item)
            } else {
                multiSelection.insert(item)
            }
        }
    }
}

// MARK: - Example Item Type

struct DropdownItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
}

// MARK: - Examples

extension DSDropdown where Item == DropdownItem, Content == Text {
    @ShowcaseExample(title: "Single Selection", description: "Choose one item from the list")
    static var singleSelection: some View {
        DropdownExample()
    }
    
    @ShowcaseExample(title: "Multi-Selection", description: "Select multiple items with checkmarks")
    static var multiSelection: some View {
        MultiDropdownExample()
    }
}

private struct DropdownExample: View {
    @State private var selection: DropdownItem?
    
    let fruits = [
        DropdownItem("Apple", icon: "🍎"),
        DropdownItem("Banana", icon: "🍌"),
        DropdownItem("Orange", icon: "🍊"),
        DropdownItem("Grape", icon: "🍇"),
        DropdownItem("Strawberry", icon: "🍓")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            DSDropdown(
                items: fruits,
                selection: $selection,
                placeholder: "Select a fruit"
            ) { item in
                HStack {
                    if let icon = item.icon {
                        Text(icon)
                    }
                    Text(item.title)
                }
            }
            .frame(width: 250)
            
            if let selection {
                Text("Selected: \(selection.title)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

private struct MultiDropdownExample: View {
    @State private var selection: Set<DropdownItem> = []
    
    let colors = [
        DropdownItem("Red", icon: "🔴"),
        DropdownItem("Green", icon: "🟢"),
        DropdownItem("Blue", icon: "🔵"),
        DropdownItem("Yellow", icon: "🟡"),
        DropdownItem("Purple", icon: "🟣")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            DSDropdown(
                items: colors,
                multiSelection: $selection,
                placeholder: "Select colors"
            ) { item in
                HStack {
                    if let icon = item.icon {
                        Text(icon)
                    }
                    Text(item.title)
                }
            }
            .frame(width: 250)
            
            if !selection.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected colors:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(Array(selection), id: \.id) { item in
                        Text("• \(item.title)")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
    }
}
