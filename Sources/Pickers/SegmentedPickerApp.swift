////
////  SegmentedPickerApp.swift
////  SwiftUI-Pickers
////
////  Created by Serge Gori on 19/06/2023.
////

import SwiftUI

//@main
struct SegmentedPickerApp: View {
    let myCustomAction: (Int, Int?) -> Int? = { index, selectedIndex in
        // Do something with selectedIndex and index
        return selectedIndex == index ? nil : index    }
    
    let contentView: ContentView
    
    
    init() {
        contentView = ContentView()
        ContentView.customAction = myCustomAction
    }
    var body: some View {
        contentView
    }
}


struct SegmentedPickerApp_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedPickerApp()
    }
}

