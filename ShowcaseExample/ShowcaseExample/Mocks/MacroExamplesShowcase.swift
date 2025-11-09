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

//
//  MacroExamplesShowcase.swift
//  ShowcaseExample
//
//  Real examples using @Showcasable macro with auto-generated code blocks.
//  Demonstrates the new Phase 6 feature: @ShowcaseExample automatically
//  generates CodeBlocks showing the source code alongside the preview.
//

import SwiftUI
import Showcase
import ShowcaseMacros

// MARK: - Button Component with Auto-Generated Code

/// A customizable button component for the design system
@Showcasable(chapter: "Components", icon: "button.horizontal")
struct DSButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive
        
        var color: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return .gray
            case .destructive: return .red
            }
        }
    }
    
    // Examples with auto-generated code blocks (showCode defaults to true)
    @ShowcaseExample(title: "Primary Button")
    static var primary: some View {
        DSButton(title: "Continue", style: .primary) {
            print("Primary action")
        }
    }
    
    @ShowcaseExample(
        title: "Secondary Button",
        description: "Use for less prominent actions"
    )
    static var secondary: some View {
        DSButton(title: "Cancel", style: .secondary) {
            print("Secondary action")
        }
    }
    
    @ShowcaseExample(title: "Destructive Action")
    static var destructive: some View {
        DSButton(title: "Delete", style: .destructive) {
            print("Destructive action")
        }
    }
    
    // Example WITHOUT code block (explicitly disabled)
    @ShowcaseExample(title: "Disabled State", showCode: false)
    static var disabled: some View {
        DSButton(title: "Unavailable", style: .primary) {}
            .opacity(0.5)
            .disabled(true)
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(style.color)
                .cornerRadius(8)
        }
    }
}

// MARK: - Card Component

/// A card component with customizable content
@Showcasable(chapter: "Components", icon: "rectangle.stack")
struct DSCard<Content: View>: View {
    let title: String?
    let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    @ShowcaseExample(title: "Simple Card")
    static var simple: some View {
        DSCard(title: "Welcome") {
            Text("This is a simple card component")
                .foregroundColor(.secondary)
        }
    }
    
    @ShowcaseExample(title: "Card with Image")
    static var withImage: some View {
        DSCard(title: "Photo Card") {
            VStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                Text("Add your photo here")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ShowcaseExample(
        title: "Card without Title",
        description: "Cards can omit the title for cleaner layouts"
    )
    static var noTitle: some View {
        DSCard {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Operation completed successfully")
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Badge Component

/// A badge for displaying status or counts
@Showcasable(chapter: "Components", icon: "tag.fill")
struct DSBadge: View {
    let text: String
    let color: Color
    
    @ShowcaseExample(title: "Success Badge")
    static var success: some View {
        DSBadge(text: "Active", color: .green)
    }
    
    @ShowcaseExample(title: "Warning Badge")
    static var warning: some View {
        DSBadge(text: "Pending", color: .orange)
    }
    
    @ShowcaseExample(title: "Error Badge")
    static var error: some View {
        DSBadge(text: "Failed", color: .red)
    }
    
    @ShowcaseExample(title: "Count Badge")
    static var count: some View {
        DSBadge(text: "99+", color: .blue)
    }
    
    var body: some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

// MARK: - Showcase Chapter

extension Chapter {
    /// Chapter showcasing components created with @Showcasable macro
    /// and auto-generated code blocks from @ShowcaseExample
    static let macroExamples = Chapter("Macro Examples") {
        Description {
            """
            Real components using the @Showcasable macro with automatic code block generation.
            
            Each @ShowcaseExample automatically generates a CodeBlock showing the source code \
            alongside the live preview. This ensures documentation always matches the actual code.
            
            **Key Features:**
            • Code blocks auto-generated from examples (no manual duplication)
            • Always accurate and up-to-date with the actual code
            • Compile-time checked (code must be valid to build)
            • Optional: disable with `showCode: false` parameter
            """
        }
        
        DSButton.showcaseTopic
        DSCard.showcaseTopic
        DSBadge.showcaseTopic
    }
}
