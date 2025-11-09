// Copyright (c) 2024 Pedro Almeida
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

/// A custom button with a gradient background and rounded corners.
/// This demonstrates the @Showcasable macro for automatic documentation generation.
@Showcasable(chapter: "Buttons", icon: "paintbrush.fill")
struct GradientButton: View {
    let title: String
    let action: () -> Void
    
    @ShowcaseExample(title: "Default Style")
    static var defaultStyle: some View {
        GradientButton(title: "Tap Me") {
            print("Button tapped!")
        }
    }
    
    @ShowcaseExample(title: "Long Title")
    static var longTitle: some View {
        GradientButton(title: "This is a Very Long Button Title") {
            print("Long button tapped!")
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Usage Example

struct ShowcasableMacroExample: View {
    var body: some View {
        Chapter("Macro Examples") {
            // The macro automatically generated this showcaseTopic property
            GradientButton.showcaseTopic
        }
    }
}

#Preview {
    ShowcaseNavigationStack {
        Document {
            ShowcasableMacroExample()
        }
    }
}
