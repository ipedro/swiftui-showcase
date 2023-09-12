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

/// Represents a chapter within a showcase document, containing showcase topics.
public struct ShowcaseChapter: Identifiable {
    /// The unique identifier for the chapter.
    public var id: String { "chapter-\(title)" }
    
    /// The title of the chapter.
    public let title: String
    
    /// The optional description of the chapter.
    public let description: String?
    
    /// The showcase topics within the chapter.
    public let data: [ShowcaseTopic]
    
    /// Initializes a showcase chapter with the specified title and showcase topics.
    /// - Parameters:
    ///   - title: The title of the chapter.
    ///   - elements: The showcase topics within the chapter.
    ///   - description: The optional description of the chapter.
    public init(_ title: String, description: String? = nil, _ elements: [ShowcaseTopic] = []) {
        self.title = title
        self.description = description
        self.data = elements.naturalSort()
    }
    
    /// Initializes a showcase chapter with the specified title and showcase topics.
    /// - Parameters:
    ///   - title: The title of the chapter.
    ///   - elements: The showcase topics within the chapter.
    ///   - description: The optional description of the chapter.
    public init(_ title: String, description: String? = nil, _ elements: ShowcaseTopic...) {
        self.title = title
        self.description = description
        self.data = elements.naturalSort()
    }
}
