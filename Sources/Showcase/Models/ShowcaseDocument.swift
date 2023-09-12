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

/// Represents a document split into chapters, with navigatable chapters that contain code examples, descriptions, and links.
public struct ShowcaseDocument: Identifiable {
    /// The unique identifier for the document.
    public var id: String { "document-\(title)" }
    
    /// The title of the document.
    public let title: String
    
    /// The optional description of the document.
    public let description: String?
    
    /// The chapters within the document.
    public let chapters: [ShowcaseChapter]
    
    /// Initializes a showcase document with the specified title, chapters and an optional description.
    /// - Parameters:
    ///   - title: The title of the document.
    ///   - chapters: The chapters within the document.
    ///   - description: The optional description of the document.
    public init(_ title: String, description: String? = nil, _ chapters: [ShowcaseChapter] = []) {
        self.title = title
        self.description = description
        self.chapters = chapters.naturalSort()
    }
    
    /// Initializes a showcase document with the specified title, chapters and an optional description.
    /// - Parameters:
    ///   - title: The title of the document.
    ///   - chapters: The chapters within the document.
    ///   - description: The optional description of the document.
    public init(_ title: String, description: String? = nil, _ chapters: ShowcaseChapter...) {
        self.title = title
        self.description = description
        self.chapters = chapters.naturalSort()
    }
}
