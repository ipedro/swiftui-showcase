// TestNavigationSplitView.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/13/25.
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

struct TestNavigationSplitView: View {
    @State private var selectedTest: TestCase?

    enum TestCase: String, CaseIterable, Identifiable {
        case simpleScrollView = "1. Simple ScrollView"
        case scrollViewWithToolbar = "2. ScrollView + Toolbar"
        case scrollViewReader = "3. ScrollViewReader"
        case scrollViewReaderWithToolbar = "4. ScrollViewReader + Toolbar"
        case scrollViewReaderAsModifier = "5. ScrollViewReader as Modifier"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationSplitView {
            List(TestCase.allCases, selection: $selectedTest) { testCase in
                Text(testCase.rawValue)
                    .tag(testCase)
            }
            .navigationTitle("Test Cases")
        } detail: {
            if let selectedTest {
                detailView(for: selectedTest)
            } else {
                Text("Select a test case")
            }
        }
    }

    @ViewBuilder
    private func detailView(for testCase: TestCase) -> some View {
        switch testCase {
        case .simpleScrollView:
            SimpleScrollViewTest()
        case .scrollViewWithToolbar:
            ScrollViewWithToolbarTest()
        case .scrollViewReader:
            ScrollViewReaderTest()
        case .scrollViewReaderWithToolbar:
            ScrollViewReaderWithToolbarTest()
        case .scrollViewReaderAsModifier:
            ScrollViewReaderAsModifierTest()
        }
    }
}

// Test 1: Simple ScrollView
struct SimpleScrollViewTest: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0 ..< 30) { i in
                    Text("Item \(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Simple ScrollView")
    }
}

// Test 2: ScrollView + Toolbar
struct ScrollViewWithToolbarTest: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0 ..< 30) { i in
                    Text("Item \(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("ScrollView + Toolbar")
        .toolbar {
            ToolbarItem {
                Button("Action") {}
            }
        }
    }
}

// Test 3: ScrollViewReader (without toolbar)
struct ScrollViewReaderTest: View {
    @State private var selectedID: Int?

    var body: some View {
        ScrollViewReader { _ in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0 ..< 30) { i in
                        Text("Item \(i)")
                            .id(i)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("ScrollViewReader")
    }
}

// Test 4: ScrollViewReader + Toolbar (THE PROBLEMATIC COMBO?)
struct ScrollViewReaderWithToolbarTest: View {
    @State private var selectedID: Int?

    var body: some View {
        ScrollViewReader { _ in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0 ..< 30) { i in
                        Text("Item \(i)")
                            .id(i)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("ScrollViewReader + Toolbar")
        .toolbar {
            ToolbarItem {
                Button("Action") {}
            }
        }
    }
}

// Test 5: ScrollViewReader as ViewModifier
struct ScrollViewReaderAsModifierTest: View {
    var body: some View {
        VStack(spacing: 20) {
            ForEach(0 ..< 30) { i in
                Text("Item \(i)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("ScrollViewReader as Modifier")
        .toolbar {
            ToolbarItem {
                Button("Action") {}
            }
        }
        .modifier(TestScrollViewReaderModifier())
    }
}

struct TestScrollViewReaderModifier: ViewModifier {
    @State private var selection: Int?

    func body(content: Content) -> some View {
        ScrollViewReader { _ in
            ScrollView {
                // Add the ZStack pattern from ShowcaseScrollViewReader
                ZStack(alignment: .top) {
                    // Top anchor (like ShowcaseScrollViewTopAnchor)
                    Color.clear.frame(height: 0).id(UUID())
                    content
                        .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    TestNavigationSplitView()
}
