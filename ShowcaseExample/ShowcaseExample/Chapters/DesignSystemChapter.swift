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

extension Chapter {
    /// Design system components with @Showcasable macro
    static let designSystemComponents = Chapter("Components") {
        Description {
            """
            Core UI components for building consistent interfaces.
            
            All components use the @Showcasable macro with auto-generated code blocks \
            from @ShowcaseExample annotations. This ensures documentation always matches \
            the actual implementation.
            
            **Features:**
            * Automatic code block generation
            * Live interactive examples
            * Type-safe documentation
            * Compile-time verification
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
