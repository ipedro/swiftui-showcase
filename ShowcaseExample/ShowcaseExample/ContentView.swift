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
        ShowcaseNavigationStack(.systemComponents)
    }
}

#Preview {
    ContentView()
}
