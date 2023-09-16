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

extension Document {
    public static let systemComponents = Self(
        "Components",
        description: "Learn how to use and customize system-defined components to give people a familiar and consistent experience.",
        Chapter(
            "Content",
            description: "Learn how to use and customize system-defined components to give people a familiar and consistent experience.",
            .imageViews,
            Topic(
                title: "Charts",
                description: { "Organize data in a chart to communicate information with clarity and visual appeal." },
                previews: .init(minHeight: 250) {
                    Group {
                        AsyncImage(url: .init(string: "https://docs-assets.developer.apple.com/published/99ff482fad4dd4768a7280ce055bbe5d/charts-anatomy@2x.png")
                        ) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        
                        AsyncImage(url: .init(string: "https://docs-assets.developer.apple.com/published/2c2b96ba943f42c1d5d1f9a32e3734eb/bar-marks@2x.png")
                        ) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        
                        AsyncImage(url: .init(string: "https://docs-assets.developer.apple.com/published/ae570f541a660059884424b2f29c9fab/line-marks@2x.png")
                        ) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .scaledToFit()
                }
            ),
            Topic(title: "Text views"),
            Topic(title: "Web views")
        ),
        Chapter(
            "Layout and organization",
            Topic(title: "Boxes"),
            Topic(title: "Collections"),
            Topic(title: "Column views"),
            Topic(title: "Disclosure controls"),
            Topic(title: "Labels"),
            Topic(title: "Lists and tables"),
            Topic(title: "Lockups"),
            Topic(title: "Outline views"),
            Topic(title: "Split views"),
            Topic(title: "Tab views")
        ),
        Chapter(
            "Menus and actions",
            Topic(title: "Activity views"),
            Topic(title: "Buttons"),
            Topic(title: "Context menus"),
            Topic(title: "Dock menus"),
            Topic(title: "Edit menus"),
            Topic(title: "Menus"),
            Topic(title: "Ornaments"),
            Topic(title: "Pop-up buttons"),
            Topic(title: "Pull-down buttons"),
            Topic(title: "Toolbars")
        ),
        Chapter(
            "Navigation and search",
            Topic(title: "Navigation bars"),
            Topic(title: "Path controls"),
            Topic(title: "Search fields"),
            Topic(title: "Sidebars"),
            Topic(title: "Tab bars"),
            Topic(title: "Token fields")
        ),
        Chapter(
            "Presentation",
            Topic(title: "Action sheets"),
            Topic(title: "Alerts"),
            Topic(title: "Page controls"),
            Topic(title: "Panels"),
            Topic(title: "Popovers"),
            Topic(title: "Scroll views"),
            Topic(title: "Sheets"),
            Topic(title: "Windows")
        ),
        Chapter("Selection and input"),
        Chapter("Status"),
        Chapter("System experiences")
    )
}

extension Topic {
    static let imageViews = Self(
        title: "Image views",
        description: {
            "An image view displays a single image — or in some cases, an animated sequence of images — on a transparent or opaque background."
        },
        links: {
            Link(.docs, .imageViewsDocs)
        },
        children: [
            .init(
                title: "Image",
                description: {
                    "Use an Image instance when you want to add images to your SwiftUI app."
                },
                examples: {
        """
        Image(systemName: "swift")

        // or

        Image("your-asset-name")
        """
                },
                previews: .init {
                    Image(systemName: "star")
                        .imageScale(.large)
                }
            ),
            .init(
                title: "AsyncImage",
                description: {
                    "This view uses the shared URLSession instance to load an image from the specified URL, and then display it. For example, you can display an icon that’s stored on a server:"
                },
                examples: {
        """
        AsyncImage(
            url: .init(
                string: "https://docs-assets.developer.apple.com/published/b38ef3054b1d61b2a8f936cd81814d10/components-image-view-intro@2x.png")
        """
                },
                previews: .init {
                    AsyncImage(url: .imageViewsPreview) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                }
            ),
        ]
    )
}

private extension Topic.LinkName {
    static let docs: Self = "Documentation"
}

private extension URL {
    static let imageViewsPreview = Self.init(string: "https://docs-assets.developer.apple.com/published/b38ef3054b1d61b2a8f936cd81814d10/components-image-view-intro@2x.png")
    
    static let imageViewsDocs = Self.init(string: "https://developer.apple.com/design/human-interface-guidelines/image-views")
}

// MARK: - Previews

struct SystemLibrary_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone 14 Pro", "iPad (10th generation)"], id: \.self) { device in
            ShowcaseNavigationView(.systemComponents)
                .previewLayout(.sizeThatFits)
                .previewDevice(PreviewDevice(rawValue: device))
        }
    }
}
