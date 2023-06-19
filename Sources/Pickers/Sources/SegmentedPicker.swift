//
//  SegmentedPicker.swift
//  SegmentedPicker
//
//  Created by Alexander Kraev on 10.02.2022.
//

import SwiftUI


/// `SegmentedPicker` est une vue personnalisée qui affiche un contrôle de sélection segmentée.
///
/// Créez un `SegmentedPicker` en passant un tableau de données pour les segments, un indice de segment sélectionné et deux closures pour définir le contenu des segments et le style de la sélection.
///
/// - Parameters:
///   - data: Un tableau de `Element` qui détermine le nombre de segments dans le sélecteur.
///   - selectedIndex: Un `Binding` vers l'indice du segment actuellement sélectionné dans `data`. Si cet argument est `nil`, aucun segment n'est sélectionné.
///   - content: Une closure qui prend un `Element` de `data` et un `Bool` indiquant si le segment est sélectionné, et retourne la vue à afficher pour le segment.
///   - selection: Une closure qui retourne une vue qui est utilisée pour styliser le segment sélectionné. Si `nil`, aucun style n'est appliqué.
///
/// - Note: Les segments sont affichés dans l'ordre dans lequel ils apparaissent dans `data`.
///   - `Element`: Le type de données que le `SegmentedPicker` affiche.
///   - `Content`: Le type de vue à afficher pour chaque segment.
///   - `Selection`: Le type de vue à utiliser pour styliser le segment sélectionné.
///
public struct SegmentedPicker<Element, Content, Selection>: View where Content: View,
                                                                       Selection: View {
    
    public typealias Data = [Element]
    
    @State private var frames: [CGRect]
    @Binding private var selectedIndex: Data.Index?
    @State var height: CGFloat = 28.0
    
    
    
    private let data: Data
    private let selection: () -> Selection?
    private let content: (Data.Element, Bool) -> Content
    private let selectionAlignment: VerticalAlignment
    
    /// Initialisation de `SegmentedPicker`.
    ///
    /// - Parameters:
    ///   - data: Un tableau de données représentant chaque segment.
    ///   - selectedIndex: Une liaison à l'index du segment actuellement sélectionné.
    ///   - content: Une closure retournant la vue pour chaque segment.
    ///   - selection: Une closure retournant la vue utilisée pour styliser le segment sélectionné.
    public init(_ data: Data,
                selectedIndex: Binding<Data.Index?>,
                selectionAlignment: VerticalAlignment = .center,
                @ViewBuilder content: @escaping (Data.Element, Bool) -> Content,
                @ViewBuilder selection: @escaping () -> Selection?) {
        
        self.data = data
        self.content = content
        self.selection = selection
        self.selectionAlignment = selectionAlignment
        self._selectedIndex = selectedIndex
        self._frames = State(wrappedValue: Array(repeating: .zero,
                                                 count: data.count))
    }
    
    public var body: some View {
        ZStack(alignment: Alignment(horizontal: .horizontalCenterAlignment,
                                    vertical: selectionAlignment)) {
            // Sélection
            if let selectedIndex = selectedIndex {
                selection()
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.gray.opacity(0.3))
                    .shadow(color: .gray.opacity(0.1),
                            radius: 8,
                            x: 0,
                            y: 3)
                    .frame(width: { frames[selectedIndex].width > 0 ? frames[selectedIndex].width - 4 : 0 }(),
                           height: height - 4)
                    .alignmentGuide(.horizontalCenterAlignment) { dimensions in
                        dimensions[HorizontalAlignment.center]
                    }
            }
            
            HStack(spacing: 0) {
                ForEach(data.indices, id: \.self) { index in
                    // Segments
                    Button(action: { selectedIndex = selectedIndex == index ? nil : index },
                           label: {
                        HStack {
                            Spacer()
                            content(data[index], selectedIndex == index)
                            Spacer()
                        }
                        .padding(.vertical, 12.0)
                        .frame(height: height)
                        .contentShape(Rectangle())
                    })
                    .buttonStyle(PlainButtonStyle())
                    .background(GeometryReader { proxy in
                        Color.clear.onAppear { frames[index] = proxy.frame(in: .global) }
                    })
                    .alignmentGuide(.horizontalCenterAlignment,
                                    isActive: selectedIndex == index) { dimensions in
                        dimensions[HorizontalAlignment.center]
                    }
                    // Séparateurs
                    if  index < (data.indices.count - 1) {
                        if let selectedIndex = selectedIndex, index >= 0 {
                            customDivider(opacity: index == selectedIndex - 1 || index == selectedIndex ? 0.0 : 1.0)
                        } else {
                            customDivider(opacity: 1.0)
                        }
                    }
                }
            }
        }
        .frame(height: height)
        .background(.gray.opacity(0.3))
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.3), value: self.selectedIndex)    }
    
    /// Crée un séparateur à placer entre deux segments.
    private func customDivider(opacity: Double) -> some View {
        Divider()
            .background(Color.gray)
            .frame(height: height * 0.5)
            .opacity(opacity)
    }
}

public extension SegmentedPicker where Selection == EmptyView {
    /// Initialisation de `SegmentedPicker`.
    ///
    /// - Parameters:
    ///   - data: Un tableau de données représentant chaque segment.
    ///   - selectedIndex: Une liaison à l'index du segment actuellement sélectionné.
    ///   - content: Une closure retournant la vue pour chaque segment.
    init(_ data: Data,
         selectedIndex: Binding<Data.Index?>,
         @ViewBuilder content: @escaping (Data.Element, Bool) -> Content)
    {
        self.data = data
        self.content = content
        self.selection = { nil }
        self.selectionAlignment = .center
        self._selectedIndex = selectedIndex
        self._frames = State(wrappedValue: Array(repeating: .zero,
                                                 count: data.count))
    }
}

struct SegmentedPicker_Previews: PreviewProvider {
    
    struct SegmentedPickerExample: View {
        
        let tabs = ["One", "Two", "Three", "Four"]
        @State var selectedIndex: Int? = nil
        
        var body: some View {
            SegmentedPicker(tabs, selectedIndex: $selectedIndex) { tab, isSelected in
                Text(tab)
            }
        }
    }
    
    static var previews: some View {
        SegmentedPickerExample()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

//enum SegmentedPickerStyle {
//    case `default`
//    case stroked
//    case capsule
//    case custom(cornerRadius: CGFloat)
//    
//    var selection: any View {
//        switch self {
//        case .default:
//            return RoundedRectangle(cornerRadius: 8)
//                .foregroundColor(.gray.opacity(0.3))
//                .shadow(color: .gray.opacity(0.1),
//                        radius: 8,
//                        x: 0,
//                        y: 3)
//        case .stroked:
//            return EmptyView()
//        case .capsule:
//            return EmptyView()
//        case .custom(cornerRadius: _):
//            return EmptyView()
//        }
//        
//    }
//}
