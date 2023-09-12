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

import SwiftUI
@_implementationOnly import Splash

extension Theme {
    static func xcodeDark(withFont font: Splash.Font) -> Theme {
        return Theme(
            font: font,
            plainTextColor: .init(white: 1, alpha: 0.85),
            tokenColors: [
                .keyword: .init(rgb: 0xFC83B7),
                .string: .init(rgb: 0xFC6A5D),
                .type: .init(rgb: 0xD0A8FF),
                .call: .init(rgb: 0xD0A8FF),
                .number: .init(rgb: 0xD0BF69),
                .comment: .init(rgb: 0x6C7986),
                .property: .init(white: 1, alpha: 0.85),
                .dotAccess: .init(rgb: 0xD0A8FF),
                .preprocessing: .init(rgb: 0xFD8F3F)
            ],
            backgroundColor: .init(rgb: 0x292A2F)
        )
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}


extension SwiftUI.Color {
   init(rgb: Int) {
       self = Color(UIColor(rgb: rgb))
   }
}
