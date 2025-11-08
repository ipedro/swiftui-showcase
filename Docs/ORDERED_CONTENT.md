# Ordered Content Implementation Plan

## Decision

Add support for **ordered content rendering** that honors the declaration order of topic components in the builder DSL, replacing the current type-grouped fixed-order rendering.

### Current Behavior
```swift
Topic {
    ExternalLink(...)
    CodeBlock { ... }
    Example { ... }
    ExternalEmbed(...)
}
```

Currently renders as: **Links → Description → Examples → Embeds → Code Blocks** (fixed order)

### Desired Behavior
Render components in **declaration order**: **Link → Code → Example → Embed**

---

## Architecture

### Type-Erased Content Item Enum

Create an enum that wraps all content types while preserving their order:

```swift
public enum TopicContentItem: Identifiable {
    case link(ExternalLink)
    case codeBlock(CodeBlock)
    case example(Example)
    case embed(ExternalEmbed)
    
    public var id: UUID {
        switch self {
        case .link(let link): link.id
        case .codeBlock(let block): block.id
        case .example(let example): example.id
        case .embed(let embed): embed.id
        }
    }
}
```

### Storage Strategy

**Topic.Content** stores items in a single ordered array:

```swift
public struct Content {
    public var description: String?
    public var items: [TopicContentItem]  // NEW: Ordered heterogeneous items
    public var children: [Topic]
    
    // OPTIONAL: Backward compatibility computed properties
    public var links: [ExternalLink] {
        items.compactMap { if case .link(let l) = $0 { return l }; return nil }
    }
    public var codeBlocks: [CodeBlock] {
        items.compactMap { if case .codeBlock(let c) = $0 { return c }; return nil }
    }
    public var examples: [Example] {
        items.compactMap { if case .example(let e) = $0 { return e }; return nil }
    }
    public var embeds: [ExternalEmbed] {
        items.compactMap { if case .embed(let e) = $0 { return e }; return nil }
    }
}
```

### Protocol Implementation

Each content type appends itself to the items array:

```swift
extension ExternalLink: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.link(self))
    }
}

extension CodeBlock: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.codeBlock(self))
    }
}

extension Example: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.example(self))
    }
}

extension ExternalEmbed: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.embed(self))
    }
}
```

### View Rendering

**ShowcaseContent** iterates over items in order:

```swift
VStack(alignment: .leading, spacing: 30) {
    // Title + scroll button
    HStack(alignment: .firstTextBaseline) {
        title.font(preferredTitleFont ?? titleStyle(depth: depth))
        if depth > 0 {
            ShowcaseScrollTopButton()
        }
    }
    
    // Description (always first after title)
    description
    
    // Ordered content items
    ForEach(items) { item in
        switch item {
        case .link(let link):
            ShowcaseLink(data: link)
        case .codeBlock(let block):
            ShowcaseCodeBlock(data: block)
        case .example(let example):
            ShowcasePreview(data: example)
        case .embed(let embed):
            ShowcaseEmbed(data: embed)
        }
    }
}
```

---

## Performance Considerations

Based on [Apple's SwiftUI Performance Documentation](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance/):

### ✅ Constant View Count
The `ForEach` + `switch` pattern produces exactly **1 view per item** (constant count), which is optimal for SwiftUI's diffing algorithm.

### ✅ Stable Identifiers
Each `TopicContentItem` has a stable `UUID` identifier, enabling efficient view tracking and updates.

### ✅ No Performance Anti-patterns
- No conditional rendering that varies view count
- No stored closures capturing extra state
- No expensive calculations in view body
- No unnecessary type erasure (enum is more efficient than `AnyView`)

### 📊 Expected Performance
**Equal or better** than current grouped rendering because:
- Single ForEach iteration vs multiple type-specific iterations
- More efficient diffing with unified item collection
- Reduced view hierarchy complexity (no grouping wrappers)

---

## Implementation Phases

### Prerequisites
**Complete API refactoring first** to use renamed types:
- ✅ `Link` → `ExternalLink`
- ✅ `Preview` → `Example`
- ✅ `Embed` → `ExternalEmbed`
- ✅ `CodeBlock` (no change)

This ensures `TopicContentItem` uses finalized names from the start.

### Phase 1: Core Infrastructure
**Files to create/modify:**
- `Sources/Showcase/Models/Topic/TopicContentItem.swift` (NEW)

**Tasks:**
1. Create `TopicContentItem` enum with cases for all content types
2. Implement `Identifiable` conformance
3. Add to Xcode project and Package.swift if needed

**Validation:**
- Enum compiles successfully
- ID property returns correct UUID from wrapped types

---

### Phase 2: Content Structure Updates
**Files to modify:**
- `Sources/Showcase/Models/Topic/TopicContentBuilder.swift`

**Tasks:**
1. Add `items: [TopicContentItem]` property to `Topic.Content`
2. Initialize `items` to empty array in initializer
3. Keep existing separate arrays for backward compatibility (optional)
4. Update `merge()` method to handle items array

**Validation:**
- Topic.Content compiles with new property
- Existing code still works with separate arrays

---

### Phase 3: Protocol Implementation Updates
**Files to modify:**
- `Sources/Showcase/Models/Link/Link.swift` (or ExternalLink.swift)
- `Sources/Showcase/Models/CodeBlock/Topic+CodeBlock.swift`
- `Sources/Showcase/Models/Preview/Topic+Preview.swift` (or Example.swift)
- `Sources/Showcase/Models/Embed/Topic+Embed.swift` (or ExternalEmbed.swift)

**Tasks:**
1. Update each `TopicContentConvertible.merge()` to append to `items` array
2. Keep backward compatibility by also appending to separate arrays (temporary)
3. Update `Description` conformance (if needed - it's not a content item)

**Validation:**
- Builder correctly populates items array in declaration order
- Separate arrays also populated correctly
- Tests pass

---

### Phase 4: Topic Model Updates
**Files to modify:**
- `Sources/Showcase/Models/Topic/Topic.swift`

**Tasks:**
1. Add `@Lazy public var items: [TopicContentItem]` property
2. Update initializers to extract and store `content.items`
3. OPTIONAL: Add computed properties for backward compatibility:
   ```swift
   @Lazy public var links: [ExternalLink]
   @Lazy public var codeBlocks: [CodeBlock]
   // etc.
   ```
4. Update deprecated initializers if needed

**Validation:**
- Topic initializes correctly with items
- Items array contains elements in declaration order
- Existing code using separate arrays still works (if compatibility added)

---

### Phase 5: View Layer Updates
**Files to modify:**
- `Sources/Showcase/Views/Topic/ShowcaseTopic.swift`
- `Sources/Showcase/Views/Content/ShowcaseContent.swift`
- `Sources/Showcase/Views/Content/ShowcaseContentConfiguration.swift` (generated by @StyledView)

**Tasks:**

**ShowcaseTopic.swift:**
1. Remove separate helper methods: `links()`, `embeds()`, `codeBlocks()`, `previews()`
2. Add single `orderedItems()` method with ForEach + switch
3. Update `makeContentConfiguration()` to pass items instead of grouped views

**ShowcaseContent.swift:**
1. Update `@StyledView` properties:
   - Remove: `previews`, `links`, `embeds`, `codeBlocks`
   - Add: `items: [TopicContentItem]`
2. Update body to render items with ForEach + switch
3. Keep description rendering before items

**Validation:**
- Views compile successfully
- Items render in declaration order
- Spacing and layout preserved
- No visual regressions

---

### Phase 6: Cleanup (Optional)
**Files to consider deprecating:**
- `Sources/Showcase/Views/Link/ShowcaseLinks.swift`
- `Sources/Showcase/Views/CodeBlock/ShowcaseCodeBlocks.swift`
- `Sources/Showcase/Views/Preview/ShowcasePreviews.swift`
- `Sources/Showcase/Views/Embed/ShowcaseEmbeds.swift`

**Tasks:**
1. Mark grouping wrappers as deprecated if no longer used
2. Remove if safe to do so (breaking change)
3. Update documentation

---

### Phase 7: Testing & Validation
**Files to create/modify:**
- `Tests/ShowcaseTests/OrderedContentTests.swift` (NEW)
- Update existing tests as needed

**Test Cases:**
1. **Order preservation**: Items render in declaration order
2. **Mixed content**: All four types together in various orders
3. **Single type**: Each type alone still works
4. **Empty items**: Empty array doesn't crash
5. **Backward compatibility**: Separate arrays still work (if implemented)
6. **Performance**: No regressions in update speed
7. **Identity**: View updates don't recreate stable views

**Validation Commands:**
```bash
swift test
swift build
```

---

## File Changes Summary

### New Files
- `Sources/Showcase/Models/Topic/TopicContentItem.swift`
- `Tests/ShowcaseTests/OrderedContentTests.swift`

### Modified Files
1. `Sources/Showcase/Models/Topic/TopicContentBuilder.swift`
2. `Sources/Showcase/Models/Topic/Topic.swift`
3. `Sources/Showcase/Models/Link/Link.swift` (ExternalLink after rename)
4. `Sources/Showcase/Models/CodeBlock/Topic+CodeBlock.swift`
5. `Sources/Showcase/Models/Preview/Topic+Preview.swift` (Example after rename)
6. `Sources/Showcase/Models/Embed/Topic+Embed.swift` (ExternalEmbed after rename)
7. `Sources/Showcase/Views/Topic/ShowcaseTopic.swift`
8. `Sources/Showcase/Views/Content/ShowcaseContent.swift`

### Potentially Deprecated
- `Sources/Showcase/Views/Link/ShowcaseLinks.swift`
- `Sources/Showcase/Views/CodeBlock/ShowcaseCodeBlocks.swift`
- `Sources/Showcase/Views/Preview/ShowcasePreviews.swift`
- `Sources/Showcase/Views/Embed/ShowcaseEmbeds.swift`

---

## Backward Compatibility Strategy

### Option A: Full Compatibility (Recommended for v1.0)
- Keep separate arrays in `Topic.Content` as computed properties
- Keep separate `@Lazy` properties in `Topic` as computed
- Maintain both storage mechanisms temporarily
- Deprecate in future version

### Option B: Breaking Change (Recommended for v2.0)
- Remove separate arrays entirely
- Only use `items` array
- Update all code to use items
- Simpler architecture, but breaks existing code

**Recommendation**: Start with Option A, measure adoption, move to Option B in major version.

---

## Integration with API Refactoring

This ordered content feature **depends on** the API refactoring being completed:

1. **Complete type renames first**:
   - Link → ExternalLink
   - Preview → Example
   - Embed → ExternalEmbed

2. **Then implement ordered content**:
   - TopicContentItem uses new names
   - No need to refactor twice

3. **Both features ship together**:
   - Flat API (no wrapper functions)
   - Ordered content rendering
   - Clean, modern API surface

---

## Success Criteria

### Functional
- ✅ Components render in declaration order
- ✅ All four content types supported
- ✅ Mixed content works correctly
- ✅ Empty content doesn't crash
- ✅ Builder syntax unchanged

### Performance
- ✅ No view update regressions
- ✅ Constant view count maintained
- ✅ Efficient diffing with stable IDs
- ✅ No memory leaks

### Code Quality
- ✅ All tests pass
- ✅ No SwiftLint violations
- ✅ Documentation updated
- ✅ Example app demonstrates feature

---

## Example Usage

```swift
Document("SwiftUI Components") {
    Chapter("Buttons") {
        Topic("Button Styles") {
            Description("SwiftUI provides multiple built-in button styles")
            
            // Renders in this exact order:
            ExternalLink("Apple Documentation", url: URL(...)!)
            
            CodeBlock(language: .swift) {
                """
                Button("Tap Me") { }
                    .buttonStyle(.borderedProminent)
                """
            }
            
            Example("Default Style") {
                Button("Default") { }
            }
            
            Example("Bordered") {
                Button("Bordered") { }
                    .buttonStyle(.bordered)
            }
            
            ExternalEmbed(url: URL(string: "https://example.com/demo")!)
            
            CodeBlock(language: .swift) {
                """
                // More variations...
                """
            }
        }
    }
}
```

**Output order**: Link → Code → Example → Example → Embed → Code

---

## Notes

- TopicContentBuilder doesn't need changes (already supports TopicContentConvertible)
- Description remains special-cased (not a content item, always renders before items)
- Children remain special-cased (hierarchical navigation structure)
- ForEach + switch is Apple's recommended pattern for heterogeneous collections
- Performance is equal or better than current grouped approach

---

## Timeline Estimate

- **Phase 1**: 30 minutes (enum creation)
- **Phase 2**: 30 minutes (Content structure)
- **Phase 3**: 1 hour (protocol updates + testing)
- **Phase 4**: 1 hour (Topic updates)
- **Phase 5**: 2 hours (view layer updates)
- **Phase 6**: 30 minutes (cleanup)
- **Phase 7**: 1.5 hours (comprehensive testing)

**Total**: ~7 hours (full implementation + testing)

---

## Related Documents

- [API_REFACTORING_PLAN.md](./API_REFACTORING_PLAN.md) - Type renames (prerequisite)
- [PERFORMANCE_ANALYSIS.md](./PERFORMANCE_ANALYSIS.md) - Existing performance benchmarks
- [MODEL_OPTIMIZATIONS.md](./MODEL_OPTIMIZATIONS.md) - Model layer improvements

---

**Status**: 📝 Planning Complete - Ready for Implementation
**Last Updated**: 2025-11-08
**Next Step**: Complete API refactoring, then start Phase 1
