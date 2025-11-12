// ShowcaseCodeBlockCopyButton.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/12/25.
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
#if os(iOS)
    import UIKit
#endif

// MARK: - Copy To Pasteboard

struct ShowcaseCodeBlockCopyButton: View {
    /// The text to be copied to the pasteboard.
    let rawValue: String

    #if os(iOS)
        private let impact = UISelectionFeedbackGenerator()
    #endif

    @State
    private var isShowingTooltip = false

    private let padding: CGFloat = 9

    var body: some View {
        Button {
            #if os(iOS)
                UIPasteboard.general.string = rawValue
                impact.selectionChanged()
            #endif
            withAnimation(.bouncy) {
                isShowingTooltip = true
            }

            withAnimation(.easeInOut(duration: 0.3).delay(1.5)) {
                isShowingTooltip = false
            }
        } label: {
            HStack(spacing: padding) {
                VStack {
                    if isShowingTooltip {
                        Text("Copied Code")
                            .font(.footnote)
                            .padding(.leading, padding)
                            .transition(
                                .move(edge: .trailing)
                                    .combined(with: .opacity)
                            )
                    }
                }
                .clipped()

                CopyIcon(isActive: isShowingTooltip)
            }
            .padding(padding)
            .background {
                if isShowingTooltip {
                    Capsule().fill(.bar)
                }
            }
        }
        .disabled(isShowingTooltip)
        .buttonStyle(_ButtonStyle())
    }

    private struct _ButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }

    private struct CopyIcon: View {
        var isActive: Bool

        var body: some View {
            Image(systemName: "doc.on.doc\(isActive ? ".fill" : "")")
                .scaleEffect(isActive ? 1.5 : 1)
                .foregroundStyle(.primary.opacity(0.5))
                .padding(.leading, 2)
        }
    }
}
