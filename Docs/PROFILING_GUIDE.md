# Profiling Guide with Instruments

This guide helps you profile Showcase with Xcode Instruments to measure actual performance improvements.

---

## Quick Start

### 1. Build for Profiling

```bash
# Build in Release mode for accurate profiling
swift build -c release

# Or open the example app
open ShowcaseExample/ShowcaseExample.xcodeproj
```

### 2. Launch Instruments

**From Xcode:**
1. Open `ShowcaseExample.xcodeproj`
2. Select **Product → Profile** (⌘I)
3. Choose a profiling template (see below)

**From Terminal:**
```bash
# Launch Instruments directly
instruments -t "Time Profiler" ShowcaseExample.app
```

---

## Profiling Templates

### Time Profiler (CPU Performance)

**What it measures:** CPU usage, hot spots, time spent in functions

**Best for:**
- Syntax highlighting performance
- Search algorithm efficiency
- Recursive traversal (allChildren)
- View rendering performance

**How to use:**
1. Launch Time Profiler
2. Record while interacting with the app
3. Look for:
   - `makeAttributed` (should be called once per code block)
   - `search(query:)` (should short-circuit quickly)
   - `allChildren` (should be O(n) not O(n²))
   - `withIcon` (should early-exit when icon exists)

**Expected results after optimizations:**
- `makeAttributed`: Called once per code block, cached
- Search: < 5ms for typical queries
- `allChildren`: Linear time proportional to node count
- `withIcon`: Near-instant with early exit

---

### Allocations (Memory Performance)

**What it measures:** Memory allocations, leaks, object lifecycle

**Best for:**
- Detecting memory leaks (WebView coordinator)
- Measuring struct copy efficiency
- Array allocation patterns
- String allocation overhead

**How to use:**
1. Launch Allocations template
2. Record while navigating the app
3. Look for:
   - Growing memory without deallocation (leaks)
   - Excessive array allocations in `withIcon`
   - String allocations in search
   - WebView coordinator lifecycle

**Expected results after optimizations:**
- No memory leaks in WebView
- ~80% fewer allocations in `withIcon` (early exit)
- Stable memory growth
- Minimal string allocations

---

### Leaks (Memory Leak Detection)

**What it measures:** Retain cycles and leaked memory

**Best for:**
- WebView coordinator leak (fixed with `[weak self]`)
- Lazy property wrapper thread safety
- Closure capture cycles

**How to use:**
1. Launch Leaks template
2. Record while using embeds and WebViews
3. Look for:
   - WKWebView leaks (should be zero after fix)
   - Coordinator leaks (should be zero after fix)
   - Any red "Leaked" indicators

**Expected results after optimizations:**
- Zero leaks in WebView usage
- Zero coordinator leaks
- Stable memory footprint

---

### System Trace (Overall Performance)

**What it measures:** CPU, memory, disk, network all together

**Best for:**
- Overall app responsiveness
- UI thread blocking
- Background task efficiency

**How to use:**
1. Launch System Trace
2. Record typical usage session
3. Look for:
   - Main thread blocking
   - Frame drops during scrolling
   - Background thread usage

**Expected results after optimizations:**
- Smooth 60 FPS scrolling
- Main thread mostly idle
- No frame drops

---

## Performance Baselines

After the optimizations, you should see these metrics:

### Time Profiler Targets

| Operation | Target Time | Notes |
|-----------|-------------|-------|
| Syntax Highlighting | < 50ms | Per code block, first time |
| Syntax Highlighting (cached) | < 1ms | Subsequent accesses |
| Search (title match) | < 2ms | Short-circuit optimization |
| Search (deep scan) | < 20ms | 100+ topics |
| `allChildren` | < 10ms | 125 nodes (3 levels) |
| `withIcon` (early exit) | < 1ms | When icon exists |
| `withIcon` (propagate) | < 50ms | 100 nodes |
| `isEmpty` check | < 0.1ms | Short-circuit |

### Allocations Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Memory leaks | 0 | WebView, coordinators |
| `withIcon` allocations | ~20 | With early exit (was 100+) |
| Search allocations | < 10 | String pooling |
| Struct copies | Minimal | Early exit pattern |

---

## Profiling Scenarios

### Scenario 1: Large Document Scrolling

**Setup:**
1. Create document with 100 chapters, 10 topics each
2. Enable code blocks for all topics

**Profile:**
- Time Profiler for CPU usage
- Target: Smooth 60 FPS scrolling
- Look for: Cached syntax highlighting

**Commands:**
```swift
let document = Document("Large Test") {
    for i in 0..<100 {
        Chapter("Chapter \(i)") {
            for j in 0..<10 {
                Topic("Topic \(j)") {
                    Code {
                        Topic.CodeBlock(text: {
                            "func example\(i)_\(j)() {}"
                        })
                    }
                }
            }
        }
    }
}
```

---

### Scenario 2: Deep Hierarchy Navigation

**Setup:**
1. Create 5-level deep topic tree
2. Navigate through all levels

**Profile:**
- Time Profiler for recursion efficiency
- Allocations for struct copying
- Target: Linear time traversal

**Commands:**
```swift
func createDeepTopic(depth: Int) -> Topic {
    guard depth > 0 else {
        return Topic("Leaf") {}
    }

    return Topic("Level \(depth)") {
        createDeepTopic(depth: depth - 1)
    }
}
```

---

### Scenario 3: Live Search

**Setup:**
1. Large document loaded
2. Type search queries character by character

**Profile:**
- Time Profiler for search responsiveness
- Target: < 50ms per keystroke
- Look for: Short-circuit optimization

---

### Scenario 4: Icon Propagation

**Setup:**
1. Document with no icons
2. Apply icon to document

**Profile:**
- Time Profiler for propagation speed
- Allocations for struct copies
- Target: < 100ms for 1000 topics

---

## Interpreting Results

### ✅ Good Indicators

- Time Profiler:
  - Flat call graph (no deep recursion)
  - Short function execution times
  - Mostly idle main thread during scrolling

- Allocations:
  - Stable memory growth
  - No continuous allocations during idle
  - Minimal transient allocations

- Leaks:
  - Zero leaks detected
  - All objects properly deallocated

### ⚠️ Warning Signs

- Time Profiler:
  - Functions taking > 100ms
  - Deep call stacks (> 50 frames)
  - Main thread blocking

- Allocations:
  - Growing memory without bounds
  - Allocations during idle state
  - Large persistent allocations

- Leaks:
  - Any red leak indicators
  - Growing abandoned memory

---

## Comparing Before/After

To validate optimizations:

1. **Check out pre-optimization commit:**
   ```bash
   git checkout <commit-before-optimizations>
   ```

2. **Profile the old code:**
   - Record baseline metrics
   - Save Instruments trace file

3. **Check out optimized code:**
   ```bash
   git checkout main
   ```

4. **Profile the new code:**
   - Record new metrics
   - Compare with baseline

5. **Expected improvements:**
   - 60-85% CPU reduction in scrolling
   - 70-80% fewer allocations in `withIcon`
   - 40% faster searches
   - Zero memory leaks

---

## Automated Profiling

Use XCTest performance metrics to track regressions:

```bash
# Run performance tests
swift test --filter PerformanceTests

# Generate baseline (first run)
# Subsequent runs compare against baseline
```

XCTest will fail if performance regresses > 10%.

---

## CI/CD Integration

Add performance regression detection:

```yaml
# .github/workflows/performance.yml
- name: Performance Tests
  run: |
    swift test --filter PerformanceTests
    # Fails if regression detected
```

---

## Tips & Tricks

### 1. Profile in Release Mode
Always profile with optimizations enabled:
```bash
swift build -c release
```

### 2. Use Realistic Data
Test with production-sized datasets for accurate results.

### 3. Warm Up
Run operations once before measuring to account for caching.

### 4. Compare Apples to Apples
Use same hardware and conditions for before/after comparisons.

### 5. Multiple Runs
Average results across 5-10 runs to reduce variance.

---

## Tools Reference

- **Time Profiler:** CPU usage and hot spots
- **Allocations:** Memory allocation tracking
- **Leaks:** Memory leak detection
- **System Trace:** Overall system performance
- **Network:** API calls and data transfer
- **Energy Log:** Battery impact

---

## Next Steps

1. ✅ Run Time Profiler on large document scrolling
2. ✅ Run Allocations on icon propagation
3. ✅ Run Leaks on WebView usage
4. ✅ Compare before/after optimization metrics
5. ✅ Document findings in performance report

**Expected Outcome:** Validate 60-85% performance improvements across all metrics.
