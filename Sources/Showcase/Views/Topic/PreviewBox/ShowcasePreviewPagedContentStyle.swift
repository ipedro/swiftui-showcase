//  Copyright (c) 2023 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SwiftUI
#if canImport(UIKit)

// MARK: - Styles

public extension ShowcasePreviewContentStyle where Self == ShowcasePreviewPagedContentStyle {
    /// A paged style for content preview.
    /// - Parameters:
    ///   - currentIndicator: The tint color to apply to the current page indicator.
    ///   - indicator: The tint color to apply to the page indicator.
    static func paged(currentIndicator: Color = .primary, indicator: Color = .secondary) -> ShowcasePreviewPagedContentStyle {
        ShowcasePreviewPagedContentStyle(
            currentPageIndicator: currentIndicator,
            indicator: indicator)
    }
}

public struct ShowcasePreviewPagedContentStyle: ShowcasePreviewContentStyle {
    /// The tint color to apply to the current page indicator.
    var currentPageIndicator: Color
    /// The tint color to apply to the page indicator.
    var indicator: Color
    
    public func makeBody(configuration: Configuration) -> some View {
        TabView {
            configuration.content
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .onAppear(perform: setupPageControl)
    }
    
    /// Sets up the appearance of the page control for paged preview.
    private func setupPageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(currentPageIndicator)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(indicator)
    }
}
#endif
