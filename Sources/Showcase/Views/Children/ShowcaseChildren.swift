// Copyright (c) 2023 Pedro Almeida
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

/// The children views within the showcase.
public struct ShowcaseChildren: View {
    @Environment(\.scrollView) private var scrollView
    @Environment(\.nodeDepth) private var depth
    
    /// The data representing child showcase topics.
    let data: [Topic]
    
    /// The parent ID used for scrolling within the ScrollView.
    let parentID: Topic.ID
    
    private let impact = UIImpactFeedbackGenerator(style: .light)
    
    /// Initializes child views based on the provided data. If the data is empty returns nil.
    /// - Parameters:
    ///   - data: The data representing child showcase topics.
    ///   - parentID: The parent ID used for scrolling within the ScrollView.
    init?(
        data: [Topic]?,
        parentID: Topic.ID
    ) {
        guard let data = data, !data.isEmpty else { return nil }
        self.data = data
        self.parentID = parentID
    }
    
    /// The body of the child views within the showcase.
    public var body: some View {
        ForEach(data) { item in
            Showcase(item)
                .nodeDepth(depth + 1)
                .overlay(alignment: .topTrailing) {
                    scrollToTop
                }
        }
    }
    
    /// The button used for scrolling to the top of the ScrollView.
    @ViewBuilder private var scrollToTop: some View {
        if let scrollView = scrollView {
            Button {
                impact.impactOccurred()
                withAnimation {
                    scrollView.scrollTo(parentID)
                }
            } label: {
                Image(systemName: "chevron.up")
            }
            .padding(.top, 10)
            .foregroundStyle(.tertiary)
            .onAppear {
                impact.prepare()
            }
        }
    }
}
