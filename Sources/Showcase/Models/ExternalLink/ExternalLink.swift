// ExternalLink.swift
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

import Foundation

/// Represents an external link associated with a showcase element.
public struct ExternalLink: Identifiable, Hashable, Equatable {
    /// The unique identifier for the external link (based on the URL).
    public let id = UUID()

    /// The title of the external link.
    public var name: ExternalLink.Name

    /// The URL of the external link.
    public var url: URL

    public static func == (lhs: ExternalLink, rhs: ExternalLink) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Initializes an external link with the specified title and URL.
    /// - Parameters:
    ///   - name: The title of the external link.
    ///   - url: The URL of the external link.
    public init?(_ name: ExternalLink.Name, _ url: URL?) {
        guard let url = url else { return nil }
        self.name = name
        self.url = url
    }

    /// Initializes an external link with the specified title and URL.
    /// - Parameters:
    ///   - name: The title of the external link.
    ///   - url: The URL of the external link.
    public init?(_ name: ExternalLink.Name, _ urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.name = name
        self.url = url
    }
}
