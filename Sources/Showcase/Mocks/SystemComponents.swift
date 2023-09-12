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

import SwiftUI

extension ShowcaseDocument {
    public static let systemComponents = Self(
        "Components",
        ShowcaseChapter(
            "Content",
            .imageViews,
            ShowcaseTopic(title: "Charts"),
            ShowcaseTopic(title: "Text views"),
            ShowcaseTopic(title: "Web views")
        ),
        ShowcaseChapter(
            "Layout and organization",
            ShowcaseTopic(title: "Boxes"),
            ShowcaseTopic(title: "Collections"),
            ShowcaseTopic(title: "Column views"),
            ShowcaseTopic(title: "Disclosure controls"),
            ShowcaseTopic(title: "Labels"),
            ShowcaseTopic(title: "Lists and tables"),
            ShowcaseTopic(title: "Lockups"),
            ShowcaseTopic(title: "Outline views"),
            ShowcaseTopic(title: "Split views"),
            ShowcaseTopic(title: "Tab views")
        ),
        ShowcaseChapter(
            "Menus and actions",
            ShowcaseTopic(title: "Activity views"),
            ShowcaseTopic(title: "Buttons"),
            ShowcaseTopic(title: "Context menus"),
            ShowcaseTopic(title: "Dock menus"),
            ShowcaseTopic(title: "Edit menus"),
            ShowcaseTopic(title: "Menus"),
            ShowcaseTopic(title: "Ornaments"),
            ShowcaseTopic(title: "Pop-up buttons"),
            ShowcaseTopic(title: "Pull-down buttons"),
            ShowcaseTopic(title: "Toolbars")
        ),
        ShowcaseChapter(
            "Navigation and search",
            ShowcaseTopic(title: "Navigation bars"),
            ShowcaseTopic(title: "Path controls"),
            ShowcaseTopic(title: "Search fields"),
            ShowcaseTopic(title: "Sidebars"),
            ShowcaseTopic(title: "Tab bars"),
            ShowcaseTopic(title: "Token fields")
        ),
        ShowcaseChapter(
            "Presentation",
            ShowcaseTopic(title: "Action sheets"),
            ShowcaseTopic(title: "Alerts"),
            ShowcaseTopic(title: "Page controls"),
            ShowcaseTopic(title: "Panels"),
            ShowcaseTopic(title: "Popovers"),
            ShowcaseTopic(title: "Scroll views"),
            ShowcaseTopic(title: "Sheets"),
            ShowcaseTopic(title: "Windows")
        ),
        ShowcaseChapter("Selection and input"),
        ShowcaseChapter("Status"),
        ShowcaseChapter("System experiences")
    )
}

extension ShowcaseTopic {
    static let imageViews = Self(
        title: "Image views",
        description: {
            "An image view displays a single image — or in some cases, an animated sequence of images — on a transparent or opaque background."
        },
        links: {
            ExternalLink(.appleHig, .imageViewsDocs)
        },
        examples: {
            CodeBlock("Static Image") {
"""
Image(systemName: "swift")

// or

Image("your-asset-name")
"""
            }
            
            CodeBlock("Async Image") {
"""
AsyncImage(url: .init(string: "https://docs-assets.developer.apple.com/published/b38ef3054b1d61b2a8f936cd81814d10/components-image-view-intro~dark@2x.png")
"""
            }
        },
        previews: .init {
            AsyncImage(url: .imageViewsPreview)
        }
    )
}

private extension ShowcaseTopic.LinkName {
    static let appleHig: Self = "Documentation"
}

private extension URL {
    static let imageViewsPreview = Self.init(string: "https://docs-assets.developer.apple.com/published/b38ef3054b1d61b2a8f936cd81814d10/components-image-view-intro~dark@2x.png")
    
    static let imageViewsDocs = Self.init(string: "https://developer.apple.com/design/human-interface-guidelines/image-views")
}

// MARK: - Previews

struct SystemLibrary_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseNavigationView(.systemComponents)
            .listStyle(.sidebar)
    }
}
