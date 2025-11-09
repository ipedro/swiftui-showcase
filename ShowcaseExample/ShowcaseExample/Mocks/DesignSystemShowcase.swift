// Copyright (c) 2025 Pedro Almeida
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

//
//  DesignSystemShowcase.swift
//  ShowcaseExample
//
//  Demonstrates what the @Showcasable macro generates for SwiftUI components.
//  These Topics show comprehensive API documentation with:
//  • Hierarchical structure with nested initializer/method/property Topics
//  • Doc comment parsing (summary, parameters, returns, throws)
//  • Static vs instance member categorization  
//  • Type relationships (protocols, generics)
//  • Multiple examples
//  • Code blocks for integration
//  • Design guideline links
//

import SwiftUI
import Showcase

// MARK: - 1. Primary Button Topic (Demonstrating @Showcasable output)

extension Topic {
    static let dsPrimaryButton = Topic("DSPrimaryButton") {
        Description {
            """
            A primary action button following design system guidelines.
            
            Use this button for the main call-to-action in your interface. \
            It provides clear visual hierarchy with bold styling.
            
            **Note**: Always pair with a secondary button when presenting choices
            
            ## Type Relationships
            
            Conforms to: `View`
            """
        }
        
        ExternalLink(
            "Design Guidelines",
            URL(string: "https://developer.apple.com/design/human-interface-guidelines/buttons")!
        )
        
        // Examples
        Example("Default") {
            Button("Continue") {
                print("Primary action")
            }
            .buttonStyle(.borderedProminent)
        }
        
        Example("Destructive") {
            Button("Delete Account") {}
                .buttonStyle(.borderedProminent)
                .tint(.red)
        }
        
        // Code Blocks
        CodeBlock("Basic Usage") {
            """
            Button("Save") {
                saveChanges()
            }
            .buttonStyle(.borderedProminent)
            """
        }
        
        CodeBlock("With Loading State") {
            """
            @State private var isLoading = false
            
            Button(isLoading ? "Saving..." : "Save") {
                Task {
                    isLoading = true
                    await save()
                    isLoading = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            """
        }
        
        // NESTED TOPICS - AUTO-GENERATED FROM MEMBERS
        
        Topic("init(title:action:)") {
            Description {
                """
                Creates a primary button with a title
                
                **Parameters:**
                • `title`: The button's label text
                • `action`: The action to perform when tapped
                """
            }
            
            CodeBlock("Declaration") {
                "init(title: String, action: @escaping () -> Void)"
            }
        }
        
        Topic("title") {
            Description("The button's label text")
            
            CodeBlock("Declaration") {
                "let title: String"
            }
        }
        
        Topic("action") {
            Description("The action to perform when tapped")
            
            CodeBlock("Declaration") {
                "let action: () -> Void"
            }
        }
    }
}

// MARK: - 2. Card Topic

extension Topic {
    static let dsCard = Topic("DSCard") {
        Description {
            """
            A versatile card container for grouping related content.
            
            Cards provide visual separation and clear content boundaries \
            in your interface. Supports optional headers and footers.
            
            ## Type Relationships
            
            Conforms to: `View`
            Generic Parameters: `Content: View`
            """
        }
        
        Example("Simple Card") {
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Title")
                        .font(.headline)
                    Text("Card content goes here with some description text.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        Example("Elevated Card") {
            GroupBox {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Featured Content")
                        .font(.headline)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        
        CodeBlock("Custom Styling") {
            """
            GroupBox {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("Success!")
                        .font(.title2)
                }
                .padding()
            }
            """
        }
        
        // Nested Topics
        Topic("init(content:)") {
            Description {
                """
                Creates a card with custom content
                
                **Parameters:**
                • `content`: The view to display inside the card
                """
            }
            
            CodeBlock("Declaration") {
                "init(@ViewBuilder content: () -> Content)"
            }
        }
        
        Topic("elevation(_:)") {
            Description {
                """
                Sets the card's elevation
                
                **Parameters:**
                • `elevation`: Shadow intensity from 0 to 5
                
                **Returns:** Modified card view
                """
            }
            
            CodeBlock("Declaration") {
                "func elevation(_ elevation: Double) -> DSCard"
            }
        }
    }
}

// MARK: - 3. Badge Topic

extension Topic {
    static let dsBadge = Topic("DSBadge") {
        Description {
            """
            A small status or count indicator badge.
            
            Perfect for notification counts, status indicators, \
            or highlighting new content.
            
            ## Type Relationships
            
            Conforms to: `View`
            Contains: `BadgeSize` enum with cases `.small`, `.medium`, `.large`
            """
        }
        
        Example("Notification Count") {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.title2)
                Text("3")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(.red)
                    .clipShape(Capsule())
            }
        }
        
        Example("Status Badges") {
            HStack(spacing: 12) {
                Text("New")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .clipShape(Capsule())
                
                Text("Sale")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.orange)
                    .clipShape(Capsule())
                
                Text("Pro")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.purple)
                    .clipShape(Capsule())
            }
        }
        
        Example("Sizes") {
            HStack(spacing: 12) {
                Text("SM")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
                
                Text("MD")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
                
                Text("LG")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        
        // Nested Topics
        Topic("init(_:)") {
            Description {
                """
                Creates a badge with text
                
                **Parameters:**
                • `text`: The badge content
                """
            }
            
            CodeBlock("Declaration") {
                "init(_ text: String)"
            }
        }
        
        Topic("color(_:)") {
            Description {
                """
                Sets the badge color
                
                **Parameters:**
                • `color`: The background color
                
                **Returns:** Modified badge
                """
            }
            
            CodeBlock("Declaration") {
                "func color(_ color: Color) -> DSBadge"
            }
        }
        
        Topic("size(_:)") {
            Description {
                """
                Sets the badge size
                
                **Parameters:**
                • `size`: The desired size
                
                **Returns:** Modified badge
                """
            }
            
            CodeBlock("Declaration") {
                "func size(_ size: BadgeSize) -> DSBadge"
            }
        }
    }
}

// MARK: - 4. Avatar Topic

extension Topic {
    static let dsAvatar = Topic("DSAvatar") {
        Description {
            """
            A circular user avatar with fallback initials.
            
            Displays user profile images with automatic fallback \
            to initials when no image is available.
            
            ## Type Relationships
            
            Conforms to: `View`
            """
        }
        
        Example("Initials") {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 32, height: 32)
                    Text("PA")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                ZStack {
                    Circle()
                        .fill(.purple)
                        .frame(width: 40, height: 40)
                    Text("JD")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                ZStack {
                    Circle()
                        .fill(.orange)
                        .frame(width: 48, height: 48)
                    Text("MK")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        
        Example("Different Sizes") {
            HStack(spacing: 20) {
                ForEach([("XS", 24.0), ("S", 32.0), ("M", 40.0), ("L", 56.0), ("XL", 72.0)], id: \.0) { item in
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: item.1, height: item.1)
                        Text(item.0)
                            .font(.system(size: item.1 * 0.4, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        
        CodeBlock("With User Data") {
            """
            struct User {
                let name: String
                var initials: String {
                    name.split(separator: " ")
                        .compactMap { $0.first }
                        .map(String.init)
                        .joined()
                }
            }
            
            let user = User(name: "Pedro Almeida")
            
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 40, height: 40)
                Text(user.initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            """
        }
        
        // Nested Topics
        Topic("init(initials:imageName:)") {
            Description {
                """
                Creates an avatar
                
                **Parameters:**
                • `initials`: Fallback initials
                • `imageName`: Optional image name
                """
            }
            
            CodeBlock("Declaration") {
                "init(initials: String, imageName: String? = nil)"
            }
        }
        
        Topic("size(_:)") {
            Description {
                """
                Sets the avatar size
                
                **Parameters:**
                • `size`: Diameter in points
                
                **Returns:** Modified avatar
                """
            }
            
            CodeBlock("Declaration") {
                "func size(_ size: CGFloat) -> DSAvatar"
            }
        }
    }
}

// MARK: - 5. Progress Indicator Topic

extension Topic {
    static let dsProgressIndicator = Topic("DSProgressIndicator") {
        Description {
            """
            A progress indicator for loading states and determinate progress.
            
            Supports both indeterminate (spinning) and determinate (percentage) \
            progress visualization.
            
            ## Type Relationships
            
            Conforms to: `View`
            Contains: `IndicatorSize` enum with cases `.small`, `.medium`, `.large`
            """
        }
        
        Example("Indeterminate") {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Processing data...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        Example("Determinate") {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ProgressView(value: 0.3)
                        .frame(width: 120)
                    Text("30% complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 12) {
                    ProgressView(value: 0.65)
                        .frame(width: 120)
                    Text("Uploading files...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        CodeBlock("With Async Task") {
            """
            @State private var progress: Double = 0.0
            
            var body: some View {
                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .frame(width: 120)
                    Text("Downloading...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .task {
                    for i in 0...100 {
                        try? await Task.sleep(for: .milliseconds(50))
                        progress = Double(i) / 100
                    }
                }
            }
            """
        }
        
        // Nested Topics
        Topic("init(progress:message:)") {
            Description {
                """
                Creates a progress indicator
                
                **Parameters:**
                • `progress`: Optional progress value (nil for indeterminate)
                • `message`: Optional loading message
                """
            }
            
            CodeBlock("Declaration") {
                "init(progress: Double? = nil, message: String? = nil)"
            }
        }
        
        Topic("message(_:)") {
            Description {
                """
                Sets the loading message
                
                **Parameters:**
                • `message`: Message to display
                
                **Returns:** Modified indicator
                """
            }
            
            CodeBlock("Declaration") {
                "func message(_ message: String) -> DSProgressIndicator"
            }
        }
    }
}

// MARK: - 6. Text Field Topic

extension Topic {
    static let dsTextField = Topic("DSTextField") {
        Description {
            """
            A styled text input field with label and validation support.
            
            Provides consistent text input styling across the app with \
            built-in validation states and error messaging.
            
            ## Type Relationships
            
            Conforms to: `View`
            """
        }
        
        Example("Basic") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextField("Enter your email", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        Example("With Error") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextField("", text: .constant("123"))
                    .textFieldStyle(.roundedBorder)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.red, lineWidth: 1)
                    }
                
                Text("Password must be at least 8 characters")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        // Nested Topics
        Topic("init(_:text:)") {
            Description {
                """
                Creates a text field
                
                **Parameters:**
                • `label`: The field label
                • `text`: Binding to the text value
                """
            }
            
            CodeBlock("Declaration") {
                "init(_ label: String, text: Binding<String>)"
            }
        }
        
        Topic("placeholder(_:)") {
            Description {
                """
                Sets the placeholder text
                
                **Parameters:**
                • `placeholder`: The placeholder string
                
                **Returns:** Modified text field
                """
            }
            
            CodeBlock("Declaration") {
                "func placeholder(_ placeholder: String) -> DSTextField"
            }
        }
        
        Topic("error(_:message:)") {
            Description {
                """
                Sets error state
                
                **Parameters:**
                • `isError`: Whether field has error
                • `message`: Optional error message
                
                **Returns:** Modified text field
                """
            }
            
            CodeBlock("Declaration") {
                "func error(_ isError: Bool, message: String? = nil) -> DSTextField"
            }
        }
    }
}
