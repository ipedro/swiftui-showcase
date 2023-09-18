import SwiftUI

extension Text {
    init?(_ optional: String?) {
        guard let string = optional else { return nil }
        self.init(verbatim: string)
    }
}
