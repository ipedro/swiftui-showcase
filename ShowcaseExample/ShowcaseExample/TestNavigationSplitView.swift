// TestNavigationSplitView.swift
// Created for debugging NavigationSplitView scrolling issues

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
                ForEach(0..<30) { i in
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
                ForEach(0..<30) { i in
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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<30) { i in
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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<30) { i in
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
            ForEach(0..<30) { i in
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
        ScrollViewReader { scrollView in
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
