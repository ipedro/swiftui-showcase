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
    /// The data representing child showcase topics.
    let data: [Topic]
    
    /// The nesting level of the showcase.
    let level: Int
    
    /// The parent ID used for scrolling within the ScrollView.
    let parentID: Topic.ID
    
    /// Allows scrolling of the views.
    let scrollView: ScrollViewProxy
    
    private let impact = UIImpactFeedbackGenerator(style: .light)
    
    /// Initializes child views based on the provided data. If the data is empty returns nil.
    /// - Parameters:
    ///   - data: The data representing child showcase topics.
    ///   - level: The nesting level of the showcase.
    ///   - parentID: The parent ID used for scrolling within the ScrollView.
    ///   - scrollView: Allows scrolling of the views.
    init?(
        data: [Topic]?,
        level: Int,
        parentID: Topic.ID,
        scrollView: ScrollViewProxy
    ) {
        guard let data = data, !data.isEmpty else { return nil }
        self.data = data
        self.level = level
        self.parentID = parentID
        self.scrollView = scrollView
    }
    
    /// The body of the child views within the showcase.
    public var body: some View {
        ForEach(data) { item in
            ShowcaseContent(data: item, level: level)
                .overlay(alignment: .topTrailing) {
                    scrollToTop
                }
        }
    }
    
    /// The button used for scrolling to the top of the ScrollView.
    private var scrollToTop: some View {
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
