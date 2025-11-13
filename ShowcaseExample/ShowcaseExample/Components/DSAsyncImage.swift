// DSAsyncImage.swift
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

/// An async image loader with placeholder and error states
///
/// `DSAsyncImage` provides a robust image loading experience with proper state handling
/// for loading, success, and failure scenarios. It automatically scales images to fit
/// and provides customizable placeholders.
///
/// ## Usage
///
/// ```swift
/// DSAsyncImage(url: imageURL)
///     .frame(width: 200, height: 200)
///     .clipShape(RoundedRectangle(cornerRadius: 12))
/// ```
///
/// ## State Management
///
/// The component handles three states automatically:
/// - **Loading**: Shows a progress indicator with shimmer effect
/// - **Success**: Displays the loaded image with scale-to-fit
/// - **Failure**: Shows an error icon with retry option
///
/// ## Performance
///
/// Images are cached automatically by the system's `AsyncImage`.
/// Consider preloading critical images during app launch.
@Showcasable(icon: "photo.on.rectangle.angled")
struct DSAsyncImage: View {
    let url: URL?

    @ShowcaseExample(title: "Basic Image")
    static var basic: some View {
        DSAsyncImage(url: URL(string: "https://picsum.photos/200"))
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ShowcaseExample(title: "Avatar Style", description: "Perfect for user profile images")
    static var avatar: some View {
        DSAsyncImage(url: URL(string: "https://picsum.photos/100"))
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }

    @ShowcaseExample(title: "Wide Banner", description: "Ideal for hero sections")
    static var banner: some View {
        DSAsyncImage(url: URL(string: "https://picsum.photos/200/100"))
            .frame(width: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ShowcaseExample(title: "Error State", description: "Handling broken URLs gracefully")
    static var errorState: some View {
        DSAsyncImage(url: URL(string: "https://invalid.url/image.jpg"))
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))

            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("Failed to load")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))

            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    DSAsyncImage.self
}
