// ShowcaseNote.swift
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

import SwiftUI

/// A view that displays a note callout with appropriate styling.
struct ShowcaseNote: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title with icon
            HStack(spacing: 6) {
                Image(systemName: note.type.systemImage)
                    .font(.headline)
                    .foregroundStyle(note.type.color)
                
                Text(note.type.title)
                    .font(.headline)
                    .foregroundStyle(note.type.color)
            }
            
            // Content with markdown support
            Text(renderContent())
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(note.type.backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(note.type.borderColor, lineWidth: 1)
        )
    }
    
    private func renderContent() -> AttributedString {
        do {
            return try AttributedString(styledMarkdown: note.content)
        } catch {
            return AttributedString(note.content)
        }
    }
}

// MARK: - Note Type Styling

extension Note.NoteType {
    /// The system image name for this note type
    var systemImage: String {
        switch self {
        case .note:
            return "info.circle.fill"
        case .important:
            return "exclamationmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .deprecated:
            return "xmark.octagon.fill"
        case .experimental:
            return "flask.fill"
        case .tip:
            return "lightbulb.fill"
        }
    }
    
    /// The foreground color for this note type
    var color: Color {
        switch self {
        case .note:
            return .blue
        case .important:
            return .purple
        case .warning:
            return .orange
        case .deprecated:
            return .red
        case .experimental:
            return .yellow
        case .tip:
            return .green
        }
    }
    
    /// The background color for this note type
    var backgroundColor: Color {
        color.opacity(0.1)
    }
    
    /// The border color for this note type
    var borderColor: Color {
        color.opacity(0.3)
    }
}

// MARK: - Preview

#Preview("Note Types") {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(Note.NoteType.allCases, id: \.self) { type in
                ShowcaseNote(note: Note(type) {
                    "This is a **\(type.title)** callout with `inline code` and *emphasis*."
                })
            }
        }
        .padding()
    }
}

#Preview("Real World Example") {
    ScrollView {
        VStack(spacing: 16) {
            ShowcaseNote(note: Note(.deprecated) {
                """
                The `oldMethod()` API is deprecated. Use `newMethod()` instead.
                """
            })
            
            ShowcaseNote(note: Note(.warning) {
                """
                **Always** call `cleanup()` before deallocating resources.
                """
            })
            
            ShowcaseNote(note: Note(.tip) {
                """
                For better performance, consider using `LazyVStack` for long lists.
                """
            })
        }
        .padding()
    }
}
