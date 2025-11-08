<!-- markdownlint-disable -->
# API Refactoring Plan - Global Cleanup

**Branch:** `codex/improve-ergonomics-of-document-creation-apis`  
**Date:** November 8, 2025  
**Status:** In Progress

## 📊 Progress Summary

### ✅ Completed
1. **Link Type Extraction** (Phase 1)
   - ✅ Created `Models/Link/Link.swift` with standalone `Link` struct
   - ✅ Created `Models/Link/Link+Name.swift` with `Link.Name` nested type
   - ✅ Created `Models/Link/Link+Builder.swift` with `Link.Builder`
   - ✅ Updated `LinksImpl` to be internal in `TopicContentBuilder.swift`
   - ✅ Updated `Links()` function to return opaque `some TopicContentConvertible`
   
2. **Ordered Content Feature** (Bonus Work)
   - ✅ Implemented `TopicContentItem` enum for heterogeneous content
   - ✅ Updated view layer to render items in declaration order
   - ✅ Created comprehensive tests (55 tests passing)
   - ✅ Created PR #12 on clean branch `feature/ordered-content-rendering`

### 🚧 In Progress
- Updating all `Link` references throughout codebase
- Example app fixes for `Showcase.Link` qualified names

### ⏳ Remaining
- [ ] Extract `CodeBlock`, `Preview`, `Embed` types (Phase 1)
- [ ] Make remaining wrappers internal (Phase 2)
- [ ] **Move icons & descriptions to DSL** (Phase 2.5 - NEW)
  - [ ] Create DocumentContentBuilder with Icon/Description support
  - [ ] Add Icon() to ChapterContentBuilder
  - [ ] Add Icon() to TopicContentBuilder
  - [ ] Remove all `icon:` and `description:` parameters from inits
- [ ] Update all view files (Phase 4)
- [ ] Update all test files (Phase 4)
- [ ] Update all mock files (Phase 4)
- [ ] Remove deprecated code (Phase 5)
- [ ] Update documentation (Phase 6)

## 🎯 Goals

1. **Flatten nested types** - Remove `Topic.` prefix from sub-components
2. **Consolidate wrappers** - Hide implementation, expose only functions
3. **Standardize builders** - Consistent naming across framework
4. **Clean API surface** - Reduce public types, improve discoverability
5. **Remove deprecated code** - Clean break for new API

## 📋 Phase 1: Flatten Nested Types

### Primary Types (Remove `Topic.` prefix)

- [x] `Topic.Link` → `Link` ✅ **DONE** - Extracted to `Models/Link/Link.swift`
- [ ] `Topic.CodeBlock` → `CodeBlock`
- [ ] `Topic.Preview` → `Preview`
- [ ] `Topic.Embed` → `Embed`

### Nested Subtypes (Keep association)
- [x] `Topic.LinkName` → `Link.Name` ✅ **DONE** - In `Models/Link/Link+Name.swift`

### Builders (Nest under parent type)
- [x] `Topic.LinkBuilder` → `Link.Builder` ✅ **DONE** - In `Models/Link/Link+Builder.swift`
- [ ] `Topic.CodeBlockBuilder` → `CodeBlock.Builder`
- [ ] `Topic.PreviewBuilder` → `Preview.Builder`
- [ ] `Topic.EmbedBuilder` → `Embed.Builder`

### Keep Nested (Contextually appropriate)
- ✅ `Topic.Content` (specifically Topic content structure)
- ✅ `Chapter.Content` (specifically Chapter content structure)

## 📋 Phase 2: Remove Public Wrapper Types

### Architecture Pattern
With flattened types, we no longer need public wrapper structs. Functions return opaque `some TopicContentConvertible` types, with internal `*Impl` structs handling the implementation.

**Before (Link - Old API):**
```swift
// Public wrapper struct (REMOVED)
public struct TopicLinks: TopicContentConvertible { ... }

// Function returning concrete wrapper
public func Links(...) -> TopicLinks { TopicLinks(...) }
```

**After (Link - New API):**
```swift
// PUBLIC API - Function returns opaque type
@inlinable
public func Links(@Link.Builder _ builder: @escaping () -> [Link]) -> some TopicContentConvertible {
    LinksImpl(builder)
}

// INTERNAL - Implementation hidden with @usableFromInline
@usableFromInline
internal struct LinksImpl: TopicContentConvertible {
    @usableFromInline let builder: () -> [Link]
    @usableFromInline init(_ builder: @escaping () -> [Link]) { ... }
    @usableFromInline func merge(into content: inout Topic.Content) { ... }
}
```

### Public Wrapper Types to Remove
- [x] `TopicLinks` ✅ **DONE** - Removed, replaced with internal `LinksImpl` + `Links()` function
- [ ] `TopicCodeBlocks` - Remove, replace with internal `CodeBlocksImpl` + update `Code()` function
- [ ] `TopicPreviews` - Remove, replace with internal `PreviewsImpl` + update `Examples()` function  
- [ ] `TopicEmbeds` - Remove, replace with internal `EmbedsImpl` + update `Embeds()` function
- [ ] `TopicChildren` - Remove, replace with internal `ChildrenImpl` + update `Children()` function

### Functions to Update (Return opaque types)
- [x] `Links()` ✅ **DONE** - Returns `some TopicContentConvertible`, uses internal `LinksImpl`
- [ ] `Code()` - Change return type from `TopicCodeBlocks` to `some TopicContentConvertible`
- [ ] `Examples()` - Change return type from `TopicPreviews` to `some TopicContentConvertible`
- [ ] `Embeds()` - Change return type from `TopicEmbeds` to `some TopicContentConvertible`
- [ ] `Children()` - Change return type from `TopicChildren` to `some TopicContentConvertible`
- [ ] `Example()` - Update parameter types after CodeBlock/Preview flattening

## 📋 Phase 2.5: Unify API - Move Icons & Descriptions to DSL

### Problem
Inconsistent API across Document, Chapter, and Topic:
- **Document**: Uses parameters for description AND icon
- **Chapter**: Uses DSL for description, parameter for icon  
- **Topic**: Uses DSL for description, parameter for icon

**Current (Inconsistent):**
```swift
Document("Title", icon: Image(...), description: "...") {  // ❌ Parameters
    Chapter("Content", icon: Image(...)) {                 // ❌ Icon parameter
        Description { "..." }                              // ✅ DSL
        
        Topic("Button", icon: Image(...)) {                // ❌ Icon parameter  
            Description { "..." }                          // ✅ DSL
        }
    }
}
```

**Target (Consistent DSL):**
```swift
Document("Title") {
    Icon { Image(...) }        // ✅ DSL
    Description { "..." }      // ✅ DSL
    
    Chapter("Content") {
        Icon { Image(...) }    // ✅ DSL
        Description { "..." }  // ✅ DSL
        
        Topic("Button") {
            Icon { Image(...) }        // ✅ DSL
            Description { "..." }      // ✅ DSL
        }
    }
}
```

### Implementation Steps

#### Document
- [ ] Create `DocumentContentBuilder.swift` with:
  - `Document.Content` struct (icon, description, chapters)
  - `DocumentContentBuilder` result builder
  - `Icon()` function returning `DocumentContentConvertible`
  - `Description()` function returning `DocumentContentConvertible`
  - Internal `IconImpl` and `DescriptionImpl` structs
- [ ] Update `Document.init()` to accept only title + `@DocumentContentBuilder` closure
- [ ] Remove `icon:` and `description:` parameters from all Document inits
- [ ] Update icon cascade logic in Document

#### Chapter
- [ ] Update `ChapterContentBuilder.swift` to add:
  - `icon` property to `Chapter.Content` struct
  - `Icon()` function returning `ChapterContentConvertible`
  - Internal `IconImpl` struct
- [ ] Update `Chapter.init()` to remove `icon:` parameter
- [ ] Update icon cascade logic in Chapter

#### Topic
- [ ] Update `TopicContentBuilder.swift` to add:
  - `icon` property to `Topic.Content` struct
  - `Icon()` function returning `TopicContentConvertible`
  - Internal `IconImpl` struct
- [ ] Update `Topic.init()` to remove `icon:` parameter
- [ ] Update icon cascade logic in Topic

#### Example Updates
- [ ] Update `SystemComponents.swift` to use new DSL
- [ ] Update all mock files
- [ ] Update all test files

### Pattern to Follow
Each content builder needs:
```swift
// In Content struct
var icon: Image?

// Public DSL function
@inlinable
public func Icon(@ViewBuilder _ content: @escaping () -> Image) -> some [Type]ContentConvertible {
    IconImpl(content)
}

// Internal implementation
@usableFromInline
internal struct IconImpl: [Type]ContentConvertible {
    @usableFromInline let builder: () -> Image
    @usableFromInline init(_ builder: @escaping () -> Image) { ... }
    @usableFromInline func merge(into content: inout [Type].Content) {
        content.icon = builder()
    }
}
```

## 📋 Phase 3: File Reorganization

### Files to Rename
- [x] `Topic+Link.swift` → `Link.swift` ✅ **DONE** - Moved to `Models/Link/`
- [x] `Topic+LinkName.swift` → `Link+Name.swift` ✅ **DONE** - Moved to `Models/Link/`
- [x] `Topic+LinkBuilder.swift` → `Link+Builder.swift` ✅ **DONE** - Moved to `Models/Link/`
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
Document("Guide", icon: Image(systemName: "book"), description: "A guide") {
    Chapter("Basics", icon: Image(systemName: "1.circle")) {
        Description("Learn the basics")
        
        Topic("Button", icon: Image(systemName: "button")) {
            Description("How to use buttons")
            
            Links {
                Link("HIG", "https://...")
            }
            Code {
                CodeBlock { "Button(\"Tap\") { }" }
            }
            Preview {
                Button("Example") {}
            }
        }
    }
}
```

**After:**
```swift
Document("Guide") {
    Icon { Image(systemName: "book") }
    Description { "A guide" }
    
    Chapter("Basics") {
        Icon { Image(systemName: "1.circle") }
        Description { "Learn the basics" }
        
        Topic("Button") {
            Icon { Image(systemName: "button") }
            Description { "How to use buttons" }
            
            Link("HIG", "https://...")
            
            CodeBlock { "Button(\"Tap\") { }" }
            
            Preview {
                Button("Example") {}
            }
        }
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
