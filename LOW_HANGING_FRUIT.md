# Low-Hanging Fruit Optimizations

## Overview
Additional optimization opportunities found in the codebase after the initial performance improvements.

---

## 1. 🟢 **Modernize `DispatchQueue.main.async` to `@MainActor`**

**File:** `Sources/Showcase/Views/Embed/ShowcaseEmbed.swift:96`

**Current Code:**
```swift
func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
    webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] height, _ in
        guard let self = self, let height = height as? CGFloat else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            webView.scrollView.contentSize = CGSize(width: webView.bounds.width, height: height)
            webView.setNeedsLayout()
            self.parent.height = height
        }
    }
}
```

**Issue:**
- Manual `DispatchQueue.main.async` is verbose and error-prone
- Requires double `[weak self]` capture and double unwrapping
- Swift 5.5+ provides cleaner `@MainActor` approach

**Solution:**
```swift
func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
    webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] height, _ in
        guard let self = self, let height = height as? CGFloat else { return }

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            webView.scrollView.contentSize = CGSize(width: webView.bounds.width, height: height)
            webView.setNeedsLayout()
            self.parent.height = height
        }
    }
}
```

**Benefits:**
- ✅ More idiomatic Swift concurrency
- ✅ Compiler-enforced thread safety
- ✅ Better integration with structured concurrency
- ✅ Single `[weak self]` capture needed

**Impact:** Low effort, modernizes codebase

---

## 2. 🟡 **Optimize String Concatenation in Tests**

**File:** `Tests/ShowcaseTests/PerformanceTests.swift:251`

**Current Code:**
```swift
description: "A very long description " + String(repeating: "that repeats ", count: 100),
```

**Issue:**
- String concatenation with `+` creates intermediate String objects
- Not critical for test code, but shows poor practice

**Solution:**
```swift
description: """
    A very long description \(String(repeating: "that repeats ", count: 100))
    """,
```

**Benefits:**
- ✅ Single string interpolation (no intermediate allocations)
- ✅ More readable multiline format

**Impact:** Cosmetic improvement, test-only code

---

## 3. 🟢 **Add `final` to Classes That Don't Need Inheritance**

**Finding:** Several view coordinator classes could be marked `final` for optimization

**Example - ShowcaseEmbed.swift:**
```swift
// Current
class Coordinator: NSObject, WKNavigationDelegate {
    // ...
}

// Improved
final class Coordinator: NSObject, WKNavigationDelegate {
    // ...
}
```

**Files to Check:**
- `ShowcaseEmbed.swift` - Coordinator class
- Any other internal classes without inheritance

**Benefits:**
- ✅ Enables compiler optimizations (static dispatch)
- ✅ Prevents accidental subclassing
- ✅ Clearer intent (this class is not extensible)

**Impact:** Quick win - add `final` keyword where applicable

---

## 4. 🟢 **Potential `@inlinable` Opportunities**

**Candidates for inlining** (public performance-critical methods):

### Topic.isEmpty
```swift
@inlinable
public var isEmpty: Bool {
    description.isEmpty 
    && codeBlocks.isEmpty
    && previews.isEmpty
    && links.isEmpty
    && embeds.isEmpty
    && (children?.isEmpty ?? true)
}
```

### Lazy.wrappedValue (if made public API)
```swift
@inlinable
public var wrappedValue: Value {
    lock.lock()
    defer { lock.unlock() }
    
    if let cachedValue = cachedValue {
        return cachedValue
    } else {
        let value = closure()
        cachedValue = value
        return value
    }
}
```

**Benefits:**
- ✅ Eliminates function call overhead
- ✅ Enables cross-module optimizations
- ✅ Particularly useful for simple property accessors

**Caveats:**
- ⚠️ Increases binary size
- ⚠️ Makes ABI changes breaking (requires careful versioning)
- ⚠️ Only worth it for frequently called, simple methods

**Impact:** Micro-optimization - measure first before applying

---

## 5. 🟡 **Consider `@_specialize` for Generic Performance**

**File:** `Sources/Showcase/Helpers/EquatableForEach.swift`

**Current:**
```swift
struct EquatableForEach<Data: RandomAccessCollection, ID: Hashable, Content: View & Equatable>: View {
    // ...
}
```

**Potential Improvement:**
```swift
@_specialize(where Data == Array<Topic>)
@_specialize(where Data == Array<Chapter>)
struct EquatableForEach<Data: RandomAccessCollection, ID: Hashable, Content: View & Equatable>: View {
    // ...
}
```

**Benefits:**
- ✅ Creates optimized versions for common types
- ✅ Avoids runtime type checking overhead

**Caveats:**
- ⚠️ Underscored attribute (not stable API)
- ⚠️ May increase binary size
- ⚠️ Swift compiler already does some specialization

**Impact:** Advanced optimization - profile before implementing

---

## 6. 🟢 **Environment Value Optimization**

**File:** `Sources/Showcase/Environment/EnvironmentKeys.swift`

**Observation:** All environment keys use reference types (`ScrollViewProxy?`, `Binding?`)

**Current Best Practice:** ✅ Already optimal
- Using optionals avoids unnecessary allocations
- Reference types for proxies/bindings are correct

**No Action Needed** - Already following best practices

---

## 7. 🟢 **Computed Property Caching Opportunity**

**File:** `Sources/Showcase/Views/Chapter/ShowcaseChapters.swift:40`

**Current Code:**
```swift
private var chapters: [Chapter] {
    let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    // Early exit for empty search
    guard !trimmedQuery.isEmpty else { return data }
    return data.search(trimmedQuery)
}

var body: some View {
    ForEach(chapters) { chapter in
        // ...
    }
}
```

**Issue:**
- `chapters` computed property runs every time body is evaluated
- Search is performed on every SwiftUI re-render

**Solution - Already Optimal!** ✅
- The early exit `guard !trimmedQuery.isEmpty` prevents expensive search
- SwiftUI's diffing algorithm handles the array efficiently
- Adding `@State` cache would complicate state management

**No Action Needed** - Current implementation is appropriate

---

## 8. 🟡 **UISelectionFeedbackGenerator Reuse**

**Files:**
- `Sources/Showcase/Views/IndexMenu/ShowcaseIndexMenu.swift:74`
- `Sources/Showcase/Views/IndexList/ShowcaseIndexList.swift:69`

**Current Pattern:**
```swift
#if canImport(UIKit)
    let impact = UISelectionFeedbackGenerator()
#endif

// Used later:
Button {
    #if canImport(UIKit)
        impact.selectionChanged()
    #endif
    // ...
}
```

**Issue:**
- Creates new generator instance for each view
- Generators should be prepared before use for best performance

**Improved Pattern:**
```swift
#if canImport(UIKit)
@State private var impact: UISelectionFeedbackGenerator = {
    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    return generator
}()
#endif
```

**Benefits:**
- ✅ Reuses generator instance
- ✅ Pre-prepares generator for reduced latency
- ✅ Apple recommended pattern

**Impact:** Better haptic feedback responsiveness

---

## 9. 🟢 **Image Asset Caching (Already Optimal)**

**Observation:** All `Image(systemName:)` calls use SF Symbols

**Current Best Practice:** ✅ Already optimal
- SF Symbols are cached by the system
- No custom image loading needed
- SwiftUI handles asset caching automatically

**No Action Needed**

---

## 10. 🟡 **AsyncImage Optimization in Examples**

**File:** `ShowcaseExample/ShowcaseExample/Mocks/SystemComponents.swift:36-54`

**Current Code:**
```swift
AsyncImage(url: .init(string: "...")) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
```

**Potential Improvement:**
```swift
// Add caching/persistence strategy
AsyncImage(url: .init(string: "..."), transaction: Transaction(animation: .default)) { phase in
    switch phase {
    case .success(let image):
        image.resizable()
    case .failure:
        Image(systemName: "exclamationmark.triangle")
    case .empty:
        ProgressView()
    @unknown default:
        EmptyView()
    }
}
```

**Benefits:**
- ✅ Handles failure states explicitly
- ✅ Smoother transitions with animation
- ✅ Better error handling

**Impact:** Improves example app UX - documentation value

---

## Summary

### Quick Wins (Implement Now)
1. ✅ **Modernize to `@MainActor`** - Single file change, modern Swift
2. ✅ **Add `final` to coordinator classes** - Quick keyword additions
3. ✅ **Improve UISelectionFeedbackGenerator usage** - Better haptics

### Consider Later
4. 🤔 **`@inlinable` for hot paths** - Measure first, ABI implications
5. 🤔 **`@_specialize` for generics** - Advanced, profile-guided optimization
6. 🤔 **AsyncImage error handling** - Example/documentation improvement

### Already Optimal ✅
- Environment value design
- Computed property caching strategy
- Image asset management
- String operations (except test code)

---

## Recommendations Priority

1. **High Priority** (Do Now):
   - Modernize `DispatchQueue.main.async` → `@MainActor` Task
   - Add `final` to internal classes

2. **Medium Priority** (Next Sprint):
   - Optimize UISelectionFeedbackGenerator preparation
   - Improve AsyncImage error handling in examples

3. **Low Priority** (Measure First):
   - Profile before adding `@inlinable`
   - Consider `@_specialize` only if profiling shows benefit

---

**Overall Assessment:** The codebase is already well-optimized. The main improvements are **modernization** (Swift concurrency) and **minor refinements** rather than critical performance issues.
