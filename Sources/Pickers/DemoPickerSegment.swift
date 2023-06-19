//
//  DemoPickerSegment.swift
//  SegmentedPicker
//
//  Created by Alexander Kraev on 10.02.2022.
//

import SwiftUI

struct DemoPickerSegment: View {
    
    @State var title: String
    
    var body: some View {
        VStack(spacing: 4.0) {
            Text(title)
//                .kerning(0.3)
                .fixedSize()
                .foregroundColor(.black)
                .font(.body)
                .lineLimit(1)
        }
//        .frame(height: 28.0)
    }
}
