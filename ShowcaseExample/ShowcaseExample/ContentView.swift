//
//  ContentView.swift
//  ShowcaseExample
//
//  Created by Pedro Almeida on 27.11.24.
//

import SwiftUI
import Showcase

struct ContentView: View {
    var body: some View {
        #if os(macOS) || os(visionOS)
        ShowcaseNavigationSplitView(.showcaseGuide)
        #else
        ShowcaseNavigationStack(.showcaseGuide)
        #endif
    }
}

#Preview {
    ContentView()
}
