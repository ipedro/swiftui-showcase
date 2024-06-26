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

public extension ShowcaseIndexMenuStyle where Self == DefaultIndexMenuStyle<ShowcaseIndexMenuIcon> {
    /// A context menu style with an icon as a label.
    /// - Parameter iconName: The name of the system symbol image. Use the SF Symbols app to look up the names of system symbol images.
    static func menu(_ iconName: String = "list.bullet") -> Self {
        DefaultIndexMenuStyle {
            ShowcaseIndexMenuIcon(systemName: iconName)
        }
    }
}

public struct DefaultIndexMenuStyle<Label: View>: ShowcaseIndexMenuStyle {
    var label: Label
    
    /// Creates a default index menu style.
    /// - Parameter label: A closure that returns a view
    init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        if let content = configuration.label {
            Menu {
                content
            } label: {
                label
            }
        }
    }
}
