import Foundation

extension Array where Element: Identifiable, Element.ID == String {
    func naturalSort() -> Self {
        sorted {
            $0.id.localizedStandardCompare($1.id) != .orderedDescending
        }
    }
}
