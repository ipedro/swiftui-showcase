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

/// A customizable button component for the design system
///
/// `DSButton` provides a consistent button interface with three built-in styles:
/// primary, secondary, and destructive. Each style automatically applies appropriate
/// colors and styling to match your design system.
///
/// ## Basic Usage
///
/// ```swift
/// DSButton(title: "Continue", style: .primary) {
///     print("Action triggered")
/// }
/// ```
///
/// ## Button Styles
///
/// Choose from three predefined styles depending on the action's importance:
///
/// ```swift
/// // Primary: For main actions
/// DSButton(title: "Save", style: .primary) {
///     saveDocument()
/// }
///
/// // Secondary: For alternative actions
/// DSButton(title: "Cancel", style: .secondary) {
///     dismissView()
/// }
///
/// // Destructive: For dangerous actions
/// DSButton(title: "Delete", style: .destructive) {
///     deleteItem()
/// }
/// ```
///
/// ## Styling and Customization
///
/// Combine with SwiftUI modifiers for additional customization:
///
/// ```swift
/// DSButton(title: "Custom", style: .primary) {
///     performAction()
/// }
/// .opacity(0.5)
/// .disabled(true)
/// ```
@Showcasable(icon: "button.horizontal")
struct DSButton: View {
    let title: String
    let style: Style
    let action: () -> Void
    
    enum Style {
        case primary, secondary, destructive
        
        var color: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return .gray
            case .destructive: return .red
            }
        }
    }
    
    @ShowcaseExample(title: "Primary Button")
    static var primary: some View {
        DSButton(title: "Continue", style: .primary) {
            print("Primary action")
        }
    }
    
    @ShowcaseExample(
        title: "Secondary Button",
        description: "Use for less prominent actions"
    )
    static var secondary: some View {
        DSButton(title: "Cancel", style: .secondary) {
            print("Secondary action")
        }
    }
    
    @ShowcaseExample(title: "Destructive Action")
    static var destructive: some View {
        DSButton(title: "Delete", style: .destructive) {
            print("Destructive action")
        }
    }
    
    @ShowcaseExample(title: "Disabled State")
    static var disabled: some View {
        DSButton(title: "Unavailable", style: .primary) {}
            .opacity(0.5)
            .disabled(true)
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(style.color)
                .cornerRadius(8)
        }
    }
}
