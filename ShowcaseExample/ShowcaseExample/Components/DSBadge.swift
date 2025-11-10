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

/// A badge for displaying status or counts
@Showcasable(icon: "tag.fill")
struct DSBadge: View {
    /// badge text
    let text: String
    /// badge color
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
        // error
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

#Preview {
    DSBadge.self
}
