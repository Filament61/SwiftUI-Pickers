//
//  Action.swift
//
//
//  Created by Serge GORI on 13/12/2023.
//

import Foundation

public enum Action {
    case normal(index: Int)
    case toggle(index: Int, selectedIndex: Int?)
//    case custom
    
//    func handleSelection(index: Int) {
//        selectedIndex = Action.toggle(index: index, selectedIndex: selectedIndex)
//    }
//    switch handleSelection {
//
//    }
    
    public static func normal(index: Int) -> Int {
        return index
    }
    public static func toggle(index: Int, selectedIndex: Int?) -> Int? {
        return selectedIndex == index ? nil : index
    }
    public static func custom(index: Int, selectedIndex: Int?) -> Int? {
        return (ContentView.customAction ?? Self.toggle)(index, selectedIndex)
    }
}

