//
//  VerticalAlignment.swift
//  SwiftUI-Pickers
//
//  Created by Serge Gori on 19/06/2023.
//

import SwiftUI

extension VerticalAlignment {
    private enum CenterAlignmentID: AlignmentID {
        static func defaultValue(in dimension: ViewDimensions) -> CGFloat {
            return dimension[VerticalAlignment.center]
        }
    }
    
    static var verticalCenterAlignment: VerticalAlignment {
        VerticalAlignment(CenterAlignmentID.self)
    }
}
