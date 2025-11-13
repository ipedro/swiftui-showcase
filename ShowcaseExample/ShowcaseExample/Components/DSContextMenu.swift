// DSContextMenu.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/10/25.
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

import Showcase
import ShowcaseMacros
import SwiftUI

/// A contextual menu with icons and keyboard shortcuts
///
/// `DSContextMenu` provides a native-feeling context menu with support for:
/// - SF Symbols icons
/// - Keyboard shortcuts
/// - Destructive actions
/// - Dividers for grouping
///
/// ## Implementation
///
/// ```swift
/// Text("Right-click me")
///     .contextMenu {
///         DSContextMenu {
///             DSContextMenu.Item(
///                 title: "Copy",
///                 icon: "doc.on.doc",
///                 shortcut: "⌘C"
///             ) {
///                 // Copy action
///             }
///         }
///     }
/// ```
///
/// ## Accessibility
///
/// All menu items support VoiceOver and keyboard navigation.
/// Keyboard shortcuts are automatically announced.
@Showcasable(icon: "ellipsis.circle")
struct DSContextMenu: View {
    let items: [Item]

    struct Item: Identifiable {
        let id = UUID()
        let title: String
        let icon: String?
        let shortcut: String?
        let isDestructive: Bool
        let action: () -> Void

        init(
            title: String,
            icon: String? = nil,
            shortcut: String? = nil,
            isDestructive: Bool = false,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.shortcut = shortcut
            self.isDestructive = isDestructive
            self.action = action
        }
    }

    @ShowcaseExample(title: "Edit Actions")
    static var editActions: some View {
        Text("Right-click for menu")
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .contextMenu {
                Button(action: {}) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                Button(action: {}) {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }
                Button(action: {}) {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
            }
    }

    @ShowcaseExample(title: "File Operations", description: "Common file management actions")
    static var fileOperations: some View {
        Text("File.pdf")
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .contextMenu {
                Button(action: {}) {
                    Label("Open", systemImage: "folder.open")
                }
                Button(action: {}) {
                    Label("Rename", systemImage: "pencil")
                }
                Divider()
                Button(action: {}) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Divider()
                Button(role: .destructive, action: {}) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }

    @ShowcaseExample(title: "Text Formatting", description: "Rich text editing options")
    static var formatting: some View {
        Text("Selected Text")
            .padding()
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(8)
            .contextMenu {
                Button(action: {}) {
                    Label("Bold", systemImage: "bold")
                }
                Button(action: {}) {
                    Label("Italic", systemImage: "italic")
                }
                Button(action: {}) {
                    Label("Underline", systemImage: "underline")
                }
                Divider()
                Button(action: {}) {
                    Label("Font Size", systemImage: "textformat.size")
                }
                Button(action: {}) {
                    Label("Color", systemImage: "paintpalette")
                }
            }
    }

    var body: some View {
        ForEach(items) { item in
            Button(action: item.action) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                    }
                    Text(item.title)
                    Spacer()
                    if let shortcut = item.shortcut {
                        Text(shortcut)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .foregroundColor(item.isDestructive ? .red : .primary)
        }
    }
}

#Preview {
    DSContextMenu.self
}
