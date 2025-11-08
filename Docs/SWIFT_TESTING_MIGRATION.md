# Swift Testing Migration

This document describes the migration from XCTest to Swift Testing framework.

## Overview

All test files have been converted from XCTest to the modern Swift Testing framework introduced in Swift 5.9. Swift Testing provides:

- **Better test organization** with `@Suite` attributes
- **Clearer assertions** with `#expect` macro
- **Improved diagnostics** with detailed failure messages
- **Async/await support** built-in
- **Parameterized tests** (ready for future use)
- **Tags and traits** for flexible test execution

## Converted Files

### 1. ShowcaseTests.swift
**Before (XCTest):**
```swift
import XCTest
@testable import Showcase

final class ShowcaseTests: XCTestCase {
    func testExample() throws {
        // XCTAssert assertions
    }
}
```

**After (Swift Testing):**
```swift
import Testing
@testable import Showcase

@Suite("Showcase Framework Tests")
struct ShowcaseTests {
    @Test("Example test case")
    func example() throws {
        // #expect assertions
    }
}
```

### 2. OptimizationTests.swift
- **29 unit tests** converted to Swift Testing
- Organized into 6 nested suites:
  - `@Suite("Lazy Property Wrapper")` - Thread safety and caching tests
  - `@Suite("withIcon Early Exit Optimization")` - Early exit behavior tests
  - `@Suite("allChildren Flattening")` - Hierarchy flattening tests
  - `@Suite("isEmpty Short-Circuit Checks")` - Short-circuit optimization tests
  - `@Suite("Search Short-Circuit")` - Search optimization tests
  - `@Suite("Hashable Protocol Conformance")` - Protocol conformance tests

**Key Changes:**
- `XCTAssertEqual` → `#expect(a == b)`
- `XCTAssertTrue` → `#expect(condition)`
- `XCTAssertNotNil` → `#expect(value != nil)`
- `XCTestCase` class → `struct` with `@Suite` attribute
- `XCTestExpectation` → `withTaskGroup` for async concurrency tests
- Added `CallCounter` helper class for thread-safe counting in concurrent tests

### 3. PerformanceTests.swift
- **12 performance benchmark tests** converted
- Custom `measurePerformance()` helper function replaces XCTest's `measure` blocks
- Suite-level time limit: `@Suite("Performance Benchmarks", .timeLimit(.minutes(5)))`

**Performance Measurement Approach:**
```swift
static func measurePerformance<T>(
    _ operation: () -> T,
    iterations: Int = 10,
    targetSeconds: Double,
    file: StaticString = #filePath,
    line: Int = #line
) -> T {
    // Runs operation 10 times, calculates average
    // Records Issue if performance target not met
    // Returns: "Performance: 0.000123s (target: 0.001s) [✓]"
}
```

**Benefits:**
- Explicit performance targets in test code
- Clear pass/fail indicators with ✓/✗
- Averages over 10 iterations for consistency
- Source location tracking for failures

## Key API Changes

| XCTest | Swift Testing |
|--------|---------------|
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertTrue(condition)` | `#expect(condition)` |
| `XCTAssertFalse(condition)` | `#expect(!condition)` |
| `XCTAssertNil(value)` | `#expect(value == nil)` |
| `XCTAssertNotNil(value)` | `#expect(value != nil)` |
| `XCTAssertEqual(a, b, "message")` | `#expect(a == b, "message")` |
| `class XCTestCase` | `struct` with `@Suite` |
| `func testExample()` | `@Test func example()` |
| `XCTestExpectation` | `async/await` with `withTaskGroup` |
| `measure { }` | Custom `measurePerformance()` |

## Running Tests

```bash
# Run all tests
swift test

# Run specific suite
swift test --filter "Optimization Tests"

# Run specific test
swift test --filter "Thread safety with concurrent access"

# Verbose output
swift test --verbose
```

## Benefits of Swift Testing

1. **Type Safety**: `#expect` is type-safe and provides better compile-time checking
2. **Better Organization**: Nested suites create logical test hierarchies
3. **Descriptive Names**: Test names use string literals for clarity
4. **Async Native**: First-class `async/await` support without XCTest expectations
5. **Modern Swift**: Leverages Swift 5.9+ features like macros
6. **Parallel Execution**: Tests run in parallel by default (opt-out available)
7. **Rich Diagnostics**: Failure messages include full expression details

## Performance Test Targets

All performance targets are documented inline:

- `allChildren`: < 0.01s for 125-node tree
- `withIcon`: < 0.05s with early-exit optimization  
- `withIcon early exit`: < 0.001s (nearly instant)
- `search`: < 0.02s for 125 topics
- `search short-circuit`: < 0.005s with title match
- `chapter search`: < 0.03s for 100 topics
- `document search`: < 0.1s for 1000 topics
- `isEmpty`: < 0.001s (short-circuit quickly)
- `sorting`: < 0.05s for 1000 topics
- `hashable`: < 0.01s for 1000 operations
- `lazy properties`: < 0.001s (cached access)

## Migration Notes

### Threading Tests
- Original `XCTestExpectation` with `DispatchQueue.concurrentPerform` replaced with:
  - `async func` test methods
  - `withTaskGroup` for concurrent execution
  - `CallCounter` helper class for thread-safe counting (using `NSLock`)

### Custom Assertions
- Created `CallCounter` class as a `Sendable` type for thread-safe test data
- Implements locking mechanism to safely increment/read counter across tasks

### Warnings
- Two warnings about redundant `_` usage in void-returning functions (cosmetic only)
- These are from `measurePerformance()` calls where result is unused

## Future Enhancements

Swift Testing enables future test improvements:

1. **Parameterized Tests**: Use `@Test(arguments:)` for data-driven tests
2. **Test Tags**: Add `.tags(.performance, .smoke)` for selective execution
3. **Custom Traits**: Define project-specific test traits
4. **Test Plans**: JSON-based test configuration (Xcode 16+)
5. **Known Issues**: Mark flaky tests with `.bug("JIRA-123")`

## Compatibility

- **Minimum Swift Version**: 5.9
- **Minimum Xcode**: Xcode 15.0
- **Minimum macOS**: macOS 13.0 (Ventura)
- **Minimum iOS**: iOS 16.0

## Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [WWDC23: Meet Swift Testing](https://developer.apple.com/videos/play/wwdc2023/10179/)
- [WWDC24: Go further with Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10195/)
- [Swift Evolution Proposal SE-0367](https://github.com/apple/swift-evolution/blob/main/proposals/0367-conditional-attributes.md)

---

**Migration Completed**: November 4, 2025  
**Test Count**: 42 tests (29 optimization + 12 performance + 1 example)  
**Build Status**: ✅ Successful  
**All Tests**: ✅ Passing
