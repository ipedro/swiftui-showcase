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

/// A type that applies standard interaction behavior and a custom appearance to
/// all Showcases within a view hierarchy.
///
/// To configure the current index menu style for a view hierarchy, use the
/// ``ShowcaseDocument/showcaseIndexMenuStyle(_:)`` modifier.
public protocol ShowcaseIndexMenuStyle {
    /// A view that represents the body of a Showcase.
    associatedtype Body: View

    /// The properties of a Showcase.
    typealias Configuration = ShowcaseIndexMenuStyleConfiguration

    /// Creates a view that represents the body of a Showcase.
    ///
    /// The system calls this method for each ``ShowcaseDocument`` instance in a view
    /// hierarchy where this style is the current index menu style.
    ///
    /// - Parameter configuration: The properties of a Showcase.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

// MARK: - View Extension

extension View {
    /// Sets the style for ``ShowcaseDocument`` within this view to a index menu style with a
    /// custom appearance and custom interaction behavior.
    /// 
    /// Use this modifier to set a specific style for ``ShowcaseDocument`` instances
    /// within a view:
    /// 
    ///     ShowcaseDocument()
    ///         .showcaseIndexMenuStyle(MyCustomStyle())
    /// 
    /// - Parameter style: Any index menu style
    /// - Returns: A view that has the index menu style set in its environment.
    public func showcaseIndexMenuStyle<S: ShowcaseIndexMenuStyle>(_ style: S) -> some View {
        environment(\.indexMenuStyle, .init(style))
    }
}

// MARK: - Type Erasure

/// A type erased index menu style.
struct AnyShowcaseIndexMenuStyle: ShowcaseIndexMenuStyle {
    /// Current index menu style.
    var style: any ShowcaseIndexMenuStyle
   
    /// Creates a type erased index menu style.
    /// - Parameter style: Any index menu style
    init<S: ShowcaseIndexMenuStyle>(_ style: S) {
        self.style = style
    }
    
    func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct IndexMenuStyleKey: EnvironmentKey {
    static var defaultValue: AnyShowcaseIndexMenuStyle = .init(.menu())
}

extension EnvironmentValues {
    /// The current index menu style value.
    var indexMenuStyle: AnyShowcaseIndexMenuStyle {
        get { self[IndexMenuStyleKey.self] }
        set { self[IndexMenuStyleKey.self] = newValue }
    }
}
