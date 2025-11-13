// DesignSystemChapter.swift
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
import SwiftUI

extension Chapter {
    /// Design system components with @Showcasable macro
    static let designSystem = Chapter("Design System") {
        Description {
            """
            A complete design system with reusable UI components.

            All components use the @Showcasable macro with auto-generated code blocks \
            from @ShowcaseExample annotations. This ensures documentation always matches \
            the actual implementation.

            **Features:**
            * Automatic code block generation from @ShowcaseExample
            * Live interactive previews
            * Type-safe documentation
            * Compile-time verification
            * Consistent design patterns
            """
        }

        DSButton.self
        DSCard<AnyView>.self
        DSBadge.self
        DSAsyncImage.self
        DSContextMenu.self
        DSSkeletonLoader.self
        DSDropdown<DropdownItem, Text>.self
    }
}
