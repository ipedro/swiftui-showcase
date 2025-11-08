// Copyright (c) 2023 Pedro Almeida
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

import Showcase
import SwiftUI

extension Topic {
    static let mockButton = Topic("Button") {
        Description {
            """
            A button initiates an instantaneous action.

            A stylized representation of two horizontally aligned buttons. The image is tinted red to subtly reflect the red in the original six-color Apple logo.
            Versatile and highly customizable, buttons give people simple, familiar ways to do tasks in your app.
            """
        }

        Links {
            ExternalLink(" HIG", "https://developer.apple.com/design/human-interface-guidelines/buttons")
        }

        Code {
            Topic.CodeBlock {
                """
                Button("I'm a bordered button") {
                    // do something
                }
                .buttonStyle(.bordered)
                """
            }
        }

        Preview {
            Button("I'm a bordered button") {
                // do something
            }
            .buttonStyle(.bordered)
        }
    }
}

struct TopicButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowcaseNavigationStack(
                Document("Button") {
                    Chapter("Chapter") {
                        Topic.mockButton
                    }
                }
            )
        }
    }
}
