import SwiftUI

/// The children views within the showcase.
public struct ShowcaseChildren: View {
    /// The data representing child showcase elements.
    let data: [ShowcaseElement.Content]
    
    /// The nesting level of the showcase.
    let level: Int
    
    /// The parent ID used for scrolling within the ScrollView.
    let parentID: ShowcaseElement.ID
    
    /// Allows scrolling of the views.
    let scrollView: ScrollViewProxy
    
    /// Initializes child views based on the provided data. If the data is empty returns nil.
    /// - Parameters:
    ///   - data: The data representing child showcase elements.
    ///   - level: The nesting level of the showcase.
    ///   - parentID: The parent ID used for scrolling within the ScrollView.
    init?(
        data: [ShowcaseElement.Content]?,
        level: Int,
        parentID: ShowcaseElement.ID,
        scrollView: ScrollViewProxy
    ) {
        guard let data = data, !data.isEmpty else { return nil }
        self.data = data
        self.level = level
        self.parentID = parentID
        self.scrollView = scrollView
    }
    
    /// The body of the child views within the showcase.
    public var body: some View {
        ForEach(data) { item in
            ZStack(alignment: .topTrailing) {
                ShowcaseContent(data: item, level: level)
                scrollToTop
            }
        }
    }
    
    /// The button used for scrolling to the top of the ScrollView.
    private var scrollToTop: some View {
        Button {
            withAnimation {
                scrollView.scrollTo(parentID)
            }
        } label: {
            Image(systemName: "chevron.up")
        }
        .padding(.top, 10)
        .foregroundStyle(.tertiary)
    }
}
