//
//  ContentView.swift
//  SegmentedPicker
//
//  Created by Alexander Kraev on 10.02.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var titles: [String] = ["1", "Title 2", "Title 3", "Title 4"]
    
    @State var selectedIndex: Int? = nil
    
    
    var body: some View {
        setPicker(titles: Array(titles)).padding()
        
    }
    
    @ViewBuilder
    private func getSegment(_ title: String) -> some View {
        DemoPickerSegment(title: title, desc: "")
    }
    
    @ViewBuilder
    private func setPicker(titles: [String]) -> some View {
        SegmentedPicker(titles,
                        selectedIndex: Binding(get: { selectedIndex },
                                               set: { selectedIndex = $0 }),
                        content: { title, isSelected in getSegment(title) })
    }
}


struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
