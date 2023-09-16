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


import Foundation

/// Represents an external link associated with a showcase element.
public struct ExternalLink: Identifiable {
    /// The unique identifier for the external link (based on the URL).
    public var id: String { url.absoluteString }
    
    /// The title of the external link.
    public var title: LinkName
    
    /// The URL of the external link.
    public var url: URL
    
    /// Initializes an external link with the specified title and URL.
    /// - Parameters:
    ///   - title: The title of the external link.
    ///   - url: The URL of the external link.
    public init?(_ title: LinkName, _ url: URL?) {
        guard let url = url else { return nil }
        self.title = title
        self.url = url
    }
}

/// A result builder for creating external links.
@resultBuilder public struct ExternalLinkBuilder {
    /// Builds an array of external links from individual components.
    public static func buildBlock() -> [ExternalLink] { [] }
    
    /// Builds an array of external links from variadic components.
    public static func buildBlock(_ components: ExternalLink...) -> [ExternalLink] { components }
    
    /// Builds an array of external links from optional components, filtering out nil values.
    public static func buildBlock(_ components: ExternalLink?...) -> [ExternalLink] { components.compactMap { $0 } }
}
