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

import Foundation

/// Represents a section within a showcase library, containing showcase elements.
public struct ShowcaseSection: Identifiable {
    /// The unique identifier for the section.
    public var id: String { "section-\(title)" }
    
    /// The title of the section.
    public let title: String
    
    /// The showcase elements within the section.
    public let data: [ShowcaseElement]
    
    /// Initializes a showcase section with the specified title and showcase elements.
    /// - Parameters:
    ///   - title: The title of the section.
    ///   - elements: The showcase elements within the section.
    public init(_ title: String, _ elements: [ShowcaseElement]) {
        self.title = title
        self.data = elements.naturalSort()
    }
    
    /// Initializes a showcase section with the specified title and showcase elements.
    /// - Parameters:
    ///   - title: The title of the section.
    ///   - elements: The showcase elements within the section.
    public init(_ title: String, _ elements: ShowcaseElement...) {
        self.title = title
        self.data = elements.naturalSort()
    }
}
