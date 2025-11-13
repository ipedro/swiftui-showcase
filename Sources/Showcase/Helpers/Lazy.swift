// Lazy.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/13/25.
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

/// A property wrapper that initializes its value lazily and caches it for subsequent accesses.
/// The value is computed only upon the first access, making it efficient for expensive initialization operations.
///
/// Usage example:
/// ```swift
/// @Lazy var expensiveObject: ExpensiveClass = ExpensiveClass(parameters)
/// ```
///
/// Accessing `expensiveObject` for the first time will instantiate `ExpensiveClass` using the provided parameters,
/// and the same instance will be returned on subsequent accesses.
@propertyWrapper
public final class Lazy<Value> {
    /// The cached value, if it has already been computed. Otherwise, nil.
    private var cachedValue: Value?

    /// The closure that computes the value of the property. This closure is executed only once,
    /// the first time the property is accessed.
    private let closure: () -> Value

    /// Lock to ensure thread-safe access to the cached value.
    private let lock = NSLock()

    /// The property that clients access. It computes the value lazily if it hasn't been computed yet,
    /// otherwise, it returns the cached value.
    public var wrappedValue: Value {
        lock.lock()
        defer { lock.unlock() }

        if let cachedValue {
            return cachedValue
        } else {
            let value = closure()
            cachedValue = value
            return value
        }
    }

    /// Initializes the property wrapper with a closure that computes the value of the property.
    /// The closure is marked with `@autoclosure` to allow initializing the wrapper with a simple expression,
    /// which is then automatically wrapped into a closure.
    ///
    /// - Parameter wrappedValue: An autoclosure that computes the value of the property. It is executed only once,
    /// the first time the property is accessed.
    public init(wrappedValue: @escaping @autoclosure () -> Value) {
        closure = wrappedValue
    }

    public init(_ other: Lazy<Value>) {
        closure = other.closure
        cachedValue = other.cachedValue
    }
}
