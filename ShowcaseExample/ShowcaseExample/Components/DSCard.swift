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

/// A card component with customizable content
///
/// > The card takes a generic content.
@Showcasable(icon: "rectangle.stack", examples: [DSCardExamples.self])
struct DSCard<Content: View>: View {
    let title: String?
    let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
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

// MARK: - Examples

struct DSCardExamples {
    @ShowcaseExample(title: "Simple Card")
    static var simple: some View {
        DSCard(title: "Welcome") {
            Text("This is a simple card component")
                .foregroundColor(.secondary)
        }
    }
    
    @ShowcaseExample(title: "Card with Image", description: "A card containing an image and text")
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
    
    @ShowcaseExample(title: "Card without Title", description: "Cards can omit the title for a cleaner look")
    static var noTitle: some View {
        DSCard {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Operation completed successfully")
            }
        }
    }
}
