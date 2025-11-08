<!-- markdownlint-disable -->
# API Refactoring Plan - Global Cleanup

**Branch:** `codex/improve-ergonomics-of-document-creation-apis`  
**Date:** November 8, 2025  
**Status:** Planning → Implementation

## 🎯 Goals

1. **Flatten nested types** - Remove `Topic.` prefix from sub-components
2. **Consolidate wrappers** - Hide implementation, expose only functions
3. **Standardize builders** - Consistent naming across framework
4. **Clean API surface** - Reduce public types, improve discoverability
5. **Remove deprecated code** - Clean break for new API

## 📋 Phase 1: Flatten Nested Types

### Primary Types (Remove `Topic.` prefix)

- [ ] `Topic.Link` → `Link`
- [ ] `Topic.CodeBlock` → `CodeBlock`
- [ ] `Topic.Preview` → `Preview`
- [ ] `Topic.Embed` → `Embed`

### Nested Subtypes (Keep association)
- [ ] `Topic.LinkName` → `Link.Name`

### Builders (Nest under parent type)
- [ ] `Topic.LinkBuilder` → `Link.Builder`
- [ ] `Topic.CodeBlockBuilder` → `CodeBlock.Builder`
- [ ] `Topic.PreviewBuilder` → `Preview.Builder`
- [ ] `Topic.EmbedBuilder` → `Embed.Builder`

### Keep Nested (Contextually appropriate)
- ✅ `Topic.Content` (specifically Topic content structure)
- ✅ `Chapter.Content` (specifically Chapter content structure)

## 📋 Phase 2: Consolidate Wrappers & Functions

### Current Architecture (Redundant)
```swift
// Public wrapper struct
public struct TopicLinks: TopicContentConvertible { ... }

// Public convenience function
public func Links(...) -> TopicLinks { TopicLinks(...) }
```

### New Architecture (Consolidated)
```swift
// PUBLIC API - Only the function is visible
@inlinable
public func Links(@Link.Builder _ builder: @escaping () -> [Link]) -> some TopicContentConvertible {
    LinksImpl(builder)
}

// INTERNAL IMPLEMENTATION - Hidden from users
@usableFromInline
internal struct LinksImpl: TopicContentConvertible {
    @usableFromInline let builder: () -> [Link]
    @usableFromInline init(_ builder: @escaping () -> [Link]) { ... }
    @usableFromInline func merge(into content: inout Topic.Content) { ... }
}
```

### Wrappers to Remove (Make Internal)
- [ ] `TopicLinks` → `@usableFromInline internal LinksImpl`
- [ ] `TopicCodeBlocks` → `@usableFromInline internal CodeBlocksImpl`
- [ ] `TopicPreviews` → `@usableFromInline internal PreviewsImpl`
- [ ] `TopicEmbeds` → `@usableFromInline internal EmbedsImpl`
- [ ] `TopicChildren` → `@usableFromInline internal ChildrenImpl`

### Functions to Keep (Update signatures)
- [ ] `Links()` - return `some TopicContentConvertible`
- [ ] `Code()` - return `some TopicContentConvertible`
- [ ] `Previews()` - return `some TopicContentConvertible`
- [ ] `Embeds()` - return `some TopicContentConvertible`
- [ ] `Children()` - return `some TopicContentConvertible`
- [ ] `Preview()` - already returns concrete type, update parameters

## 📋 Phase 3: File Reorganization

### Files to Rename
- [ ] `Topic+Link.swift` → `Link.swift`
- [ ] `Topic+LinkName.swift` → `Link+Name.swift`
- [ ] `Topic+LinkBuilder.swift` → `Link+Builder.swift`
- [ ] `Topic+CodeBlock.swift` → `CodeBlock.swift`
- [ ] `Topic+CodeBlockBuilder.swift` → `CodeBlock+Builder.swift`
- [ ] `Topic+Preview.swift` → `Preview.swift`
- [ ] `Topic+PreviewBuilder.swift` → `Preview+Builder.swift`
- [ ] `Topic+Embed.swift` → `Embed.swift`
- [ ] `Topic+EmbedBuilder.swift` → `Embed+Builder.swift`

### Directory Structure (After)
```
Models/
  Topic/
    Topic.swift
    TopicBuilder.swift
    TopicContentBuilder.swift
  Link/
    Link.swift
    Link+Name.swift
    Link+Builder.swift
  CodeBlock/
    CodeBlock.swift
    CodeBlock+Builder.swift
  Preview/
    Preview.swift
    Preview+Builder.swift
  Embed/
    Embed.swift
    Embed+Builder.swift
  Chapter/
    Chapter.swift
    ChapterBuilder.swift
    ChapterContentBuilder.swift
  Document/
    Document.swift
```

## 📋 Phase 4: Update All References

### View Files
- [ ] `ShowcaseLink.swift` - update `Topic.Link` → `Link`
- [ ] `ShowcaseCodeBlock.swift` - update `Topic.CodeBlock` → `CodeBlock`
- [ ] `ShowcasePreview.swift` - update `Topic.Preview` → `Preview`
- [ ] `ShowcaseEmbed.swift` - update `Topic.Embed` → `Embed`
- [ ] Any other view files using these types

### Test Files
- [ ] `ShowcaseTests.swift`
- [ ] `OptimizationTests.swift`
- [ ] `PerformanceTests.swift`
- [ ] `DefaultBuilderTests.swift`
- [ ] Update all type references

### Mock Files
- [ ] `MockButton.swift`
- [ ] `MockCard.swift`
- [ ] `MockAccordion.swift`
- [ ] `MockPreviews.swift`
- [ ] `SystemComponents.swift`

### Example App
- [ ] `ContentView.swift`
- [ ] Any other files in ShowcaseExample

## 📋 Phase 5: Remove Deprecated Code

### Deprecated Initializers in Topic.swift
- [ ] Remove 8 deprecated `Topic.init()` methods
- [ ] Clean break since we're doing breaking changes anyway

### Verify No Other Deprecations
- [ ] Search for `@available(*, deprecated` across codebase
- [ ] Remove or update as needed

## 📋 Phase 6: Documentation Updates

### Update Copilot Instructions
- [ ] `.github/copilot-instructions.md` - update type names
- [ ] Update hierarchy examples
- [ ] Update code samples

### Update README
- [ ] Update code examples with new API
- [ ] Update quick start guide
- [ ] Update feature descriptions

### Update Code Comments
- [ ] Triple-slash documentation
- [ ] Inline comments referencing old names
- [ ] DocC documentation if present

## 🧪 Testing Strategy

### Unit Tests
- [ ] Run full test suite after each phase
- [ ] Verify all 49 tests still pass
- [ ] No performance regressions

### Build Verification
- [ ] `swift build` succeeds
- [ ] `swift test` succeeds
- [ ] Example app builds successfully

### SwiftLint
- [ ] No new violations introduced
- [ ] CI passes

## 📊 Impact Assessment

### API Changes (User-Facing)

**Before:**
```swift
Topic("Button") {
    Links {
        Topic.Link("HIG", "https://...")
    }
    Code {
        Topic.CodeBlock { "code here" }
    }
    Preview {
        Button("Example") {}
    }
}
```

**After:**
```swift
Topic("Button") {
    Links {
        Link("HIG", "https://...")
    }
    Code {
        CodeBlock { "code here" }
    }
    Preview {
        Button("Example") {}
    }
}
```

### Breaking Changes
- ✅ Type names shortened (less verbose)
- ✅ Cleaner imports (no Topic. prefix needed)
- ✅ Wrapper types removed from public API
- ⚠️ All existing code needs updates
- ⚠️ But already on breaking change branch

### Public API Reduction
- **Before:** ~15 public types for Topic sub-components
- **After:** ~8 public types (Link, CodeBlock, Preview, Embed + builders)
- **Hidden:** 5 internal implementation structs

## 🚀 Implementation Order

1. **Start with Link** (smallest scope)
   - Flatten Link types
   - Update Link builder
   - Consolidate Links wrapper
   - Update all Link references
   - Run tests

2. **CodeBlock** (similar to Link)
   - Same pattern as Link
   - Run tests

3. **Preview** (has codeBlock dependency)
   - Update after CodeBlock is done
   - Run tests

4. **Embed** (independent)
   - Same pattern
   - Run tests

5. **Global updates**
   - Update all view files
   - Update all test files
   - Update all mock files
   - Run full test suite

6. **Cleanup**
   - Remove deprecated code
   - Update documentation
   - Final verification

## ✅ Success Criteria

- [ ] All tests pass
- [ ] No SwiftLint violations
- [ ] Example app builds and runs
- [ ] Documentation updated
- [ ] No public wrapper types
- [ ] All nested types flattened
- [ ] Clean git history (good commit messages)

## 📝 Notes

- Keep commits atomic (one logical change per commit)
- Run tests after each major change
- Update this document as we progress
- Mark items complete with timestamps

---

**Next Step:** Start with Phase 1 - Flatten Link types
