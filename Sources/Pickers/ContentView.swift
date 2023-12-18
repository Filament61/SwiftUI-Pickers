//
//  ContentView.swift
//  SwiftUI-Pickers
//
//  Created by Serge Gori on 19/06/2023.
//

import SwiftUI

struct ContentView: View {
    
    static var customAction: ((Int, Int?) -> Int?)? = nil
    

    
    @State private var titles: [String] = ["Petite", "Garde", "Sans", "Contre"]
    
    @State var selectedIndex: Int? = nil
    
    func handleSelection(index: Int) {
        selectedIndex = Action.toggle(index: index, selectedIndex: selectedIndex)
    }
    
    var body: some View {
        setPicker(titles: Array(titles)).padding()
        
    }
    
    @ViewBuilder
    private func getSegment(_ title: String) -> some View {
        DemoPickerSegment(title: title)
    }
    
    @ViewBuilder
    private func setPicker(titles: [String]) -> some View {
        SegmentedPicker(options: titles,
                        selectedIndex: Binding(get: { selectedIndex },
                                               set: { selectedIndex = $0 }),
                        action: handleSelection,
                        content: { title, isSelected in getSegment(title) })
    }
}


struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
