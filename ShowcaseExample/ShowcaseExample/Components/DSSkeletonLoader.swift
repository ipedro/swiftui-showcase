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

/// A skeleton loading placeholder with animated shimmer effect
///
/// `DSSkeletonLoader` provides visual feedback during content loading by displaying
/// animated placeholder shapes. It supports different shapes and customizable animations.
///
/// ## Shapes
///
/// - `circle` - Perfect for avatars
/// - `rectangle` - For images and cards
/// - `text with lines` - Multiple text line placeholders
/// - `roundedRectangle` - With custom corner radius
///
/// ## Animation
///
/// The shimmer effect automatically starts and uses system animation timing
/// for smooth performance across all devices.
@Showcasable(icon: "square.dashed")
struct DSSkeletonLoader: View {
    let shape: Shape
    @State private var isAnimating = false
    
    enum Shape {
        case circle(size: CGFloat = 60)
        case rectangle(width: CGFloat = 200, height: CGFloat = 100)
        case text(lines: Int = 1, width: CGFloat = 200)
        case roundedRectangle(width: CGFloat = 200, height: CGFloat = 100, cornerRadius: CGFloat = 12)
    }
    
    @ShowcaseExample(title: "Avatar Skeleton")
    static var avatar: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                DSSkeletonLoader(shape: .circle(size: 60))
                VStack(alignment: .leading, spacing: 8) {
                    DSSkeletonLoader(shape: .text(lines: 1, width: 120))
                    DSSkeletonLoader(shape: .text(lines: 1, width: 80))
                }
            }
        }
        .padding()
    }
    
    @ShowcaseExample(title: "Card Skeleton", description: "Loading placeholder for content cards")
    static var card: some View {
        VStack(alignment: .leading, spacing: 12) {
            DSSkeletonLoader(shape: .roundedRectangle(width: 300, height: 180, cornerRadius: 12))
            DSSkeletonLoader(shape: .text(lines: 1, width: 200))
            DSSkeletonLoader(shape: .text(lines: 2, width: 280))
        }
        .padding()
    }
    
    @ShowcaseExample(title: "List Item Skeleton", description: "For list views")
    static var listItem: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 12) {
                    DSSkeletonLoader(shape: .circle(size: 40))
                    VStack(alignment: .leading, spacing: 6) {
                        DSSkeletonLoader(shape: .text(lines: 1, width: 180))
                        DSSkeletonLoader(shape: .text(lines: 1, width: 120))
                    }
                }
            }
        }
        .padding()
    }
    
    @ShowcaseExample(title: "Custom Shapes", description: "Mix and match different skeleton shapes")
    static var custom: some View {
        HStack(spacing: 20) {
            DSSkeletonLoader(shape: .circle(size: 80))
            DSSkeletonLoader(shape: .rectangle(width: 80, height: 80))
            DSSkeletonLoader(shape: .roundedRectangle(width: 80, height: 80, cornerRadius: 16))
        }
        .padding()
    }
    
    var body: some View {
        Group {
            switch shape {
            case .circle(let size):
                Circle()
                    .fill(skeletonGradient)
                    .frame(width: size, height: size)
                    
            case .rectangle(let width, let height):
                Rectangle()
                    .fill(skeletonGradient)
                    .frame(width: width, height: height)
                    
            case .roundedRectangle(let width, let height, let cornerRadius):
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(skeletonGradient)
                    .frame(width: width, height: height)
                    
            case .text(let lines, let width):
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<lines, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(skeletonGradient)
                            .frame(
                                width: index == lines - 1 ? width * 0.7 : width,
                                height: 12
                            )
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private var skeletonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.2),
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.2)
            ],
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}
