//
//  SegmentedPicker.swift
//  SwiftUI-Pickers
//
//  Created by Serge Gori on 19/06/2023.
//

import SwiftUI


/// `SegmentedPicker` est une vue personnalisée qui affiche un contrôle de sélection segmentée.
///
/// Créez un `SegmentedPicker` en passant un tableau de données pour les segments, un indice de segment sélectionné et deux closures pour définir le contenu des segments et le style de la sélection.
///
/// - Parameters:
///   - options: Un tableau de `Element` qui détermine les options dans le sélecteur.
///   - selectedIndex: Un `Binding` vers l'indice du segment actuellement sélectionné dans `options`. Si cet argument est `nil`, aucune option n'est sélectionnée.
///   - content: Une closure qui prend une `Element` de `options` et un `Bool` indiquant si le segment est sélectionné, et retourne la vue à afficher pour le segment.
///   - selection: Une closure qui retourne une vue qui est utilisée pour styliser le segment sélectionné. Si `nil`, aucun style n'est appliqué.
///
/// - Note: Les segments sont affichés dans l'ordre dans lequel ils apparaissent dans `options`.
///   - `Element`: Le type de données que le `SegmentedPicker` affiche.
///   - `Content`: Le type de vue à afficher pour chaque segment.
///   - `Selection`: Le type de vue à utiliser pour styliser le segment sélectionné.
///
public struct SegmentedPicker<Element, Content, Selection>: View where Content: View,
                                                                       Selection: View {
    
    public typealias Options = [Element]
    
    @State private var frames: [CGRect]
    @Binding private var selectedIndex: Options.Index?
    @State var height: CGFloat = 32.0
    
    private let options: Options
    private let selection: () -> Selection?
    private let content: (Options.Element, Bool) -> Content
    private let selectionAlignment: VerticalAlignment
    private let action: (Int) -> Void
    
    private var selectionStyle: SelectionStyle = .regular
//    (
        //        guard let selectedIndex = selectedIndex else { return AnyView(EmptyView()) }
//        { AnyView(
//            VStack(spacing: 0) {
//                Spacer()
//                Rectangle()
//                    .fill(Color.red)
//                    .frame(height: 3)
//            }
//        ) }
//    )
    
    /// Initialisation de `SegmentedPicker`.
    ///
    /// - Parameters:
    ///   - options: Un tableau de données représentant chaque segment.
    ///   - selectedIndex: Une liaison à l'index du segment actuellement sélectionné.
    ///   - content: Une closure retournant la vue pour chaque segment.
    ///   - selection: Une closure retournant la vue utilisée pour styliser le segment sélectionné.
    public init(options: Options,
                selectedIndex: Binding<Options.Index?>,
                selectionAlignment: VerticalAlignment = .center,
                action: @escaping (Int) -> Void,
                @ViewBuilder content: @escaping (Options.Element, Bool) -> Content,
                @ViewBuilder selection: @escaping () -> Selection?) {
        
        self.options = options
        self.content = content
        self.selection = selection
        self.selectionAlignment = selectionAlignment
        self.action = action
        self._selectedIndex = selectedIndex
        self._frames = State(wrappedValue: Array(repeating: .zero,
                                                 count: options.count))
    }
//    let select: SelectionType = .regular
    
    public var body: some View {
        ZStack(alignment: Alignment(horizontal: .horizontalCenterAlignment,
                                    vertical: selectionAlignment)) {
            // Sélection ---------------------------------------------
            HStack {
                if let selectedIndex = selectedIndex {
                    AnyView(
                        Group {
                            switch selectionStyle {
                            case .regular: regularSelectionStyle()
                            case .underlined:
                                VStack(spacing: 0) {
                                    Spacer()
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(height: 1)
                                }
                            case .stroked:
                                strokedSelectionStyle()
                            case .capsule:
                                capsuleSelectionStyle()
                            case .custom(let selectionViewClosure):
                                if let selectionView = selectionViewClosure() {
                                    customSelectionStyle({ selectionView as! AnyView })
                                }
                            }
                        }
                            .frame(width: { frames[selectedIndex].width > 0 ? frames[selectedIndex].width - 4 : 0 }(),
                                   height: height - 4)
                            .alignmentGuide(.horizontalCenterAlignment) { dimensions in
                                dimensions[HorizontalAlignment.center]
                            }
                    )
                } else {
                    AnyView(EmptyView())
                }
            }
            .animation(.spring().speed(1.2), value: self.selectedIndex)
            
            //Options ------------------------------------------------
            HStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    
                    // Segments --------------------------------------
                    Button(action: { action(index) },
                           label: {
                        HStack {
                            Spacer()
                            content(options[index], selectedIndex == index)
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
                    
                    // Séparateurs -----------------------------------
                    HStack {
                        if  index < (options.indices.count - 1) {
                            if let selectedIndex = selectedIndex {
                                customDivider(opacity: index == selectedIndex - 1 || index == selectedIndex ? 0.0 : 1.0)
                            } else {
                                customDivider(opacity: 1.0)
                            }
                        }
                    }
                    .animation(.spring().speed(2.2), value: self.selectedIndex)
                }
            }
        }
        .frame(height: height)
        .background(.gray.opacity(0.25))
        .cornerRadius(8)
    }
    
    /// Crée un séparateur à placer entre deux segments.
    private func customDivider(opacity: Double) -> some View {
        Divider()
            .background(Color.gray)
            .frame(height: height * 0.55)
            .opacity(opacity)
    }
    
    // MARK: - Styles de sélection
    private func regularSelectionStyle() -> AnyView {
        return AnyView(RoundedRectangle(cornerRadius: 6)
            .foregroundColor(.white.opacity(0.8))
            .shadow(color: .gray.opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 3)
        )
    }
    private func underlinedSelectionStyle() -> AnyView {
        guard let selectedIndex = selectedIndex else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 1)
            }
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .gray.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 3)
                .frame(width: { frames[selectedIndex].width > 0 ? frames[selectedIndex].width - 4 : 0 }(),
                       height: height - 4)
                .alignmentGuide(.horizontalCenterAlignment) { dimensions in
                    dimensions[HorizontalAlignment.center]
                })
    }
    private func strokedSelectionStyle() -> AnyView {
        guard let selectedIndex = selectedIndex else { return AnyView(EmptyView()) }
        return AnyView(RoundedRectangle(cornerRadius: 6)
            .foregroundColor(.white.opacity(0.8))
            .shadow(color: .gray.opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 3)
            .frame(width: { frames[selectedIndex].width > 0 ? frames[selectedIndex].width - 4 : 0 }(),
                   height: height - 4)
            .alignmentGuide(.horizontalCenterAlignment) { dimensions in
                dimensions[HorizontalAlignment.center]
            })
    }
    private func capsuleSelectionStyle() -> AnyView {
        guard let selectedIndex = selectedIndex else { return AnyView(EmptyView()) }
        return AnyView(Capsule()
            .foregroundColor(.white.opacity(0.8))
            .shadow(color: .gray.opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 3)
            .frame(width: { frames[selectedIndex].width > 0 ? frames[selectedIndex].width - 4 : 0 }(),
                   height: height - 4)
            .alignmentGuide(.horizontalCenterAlignment) { dimensions in
                dimensions[HorizontalAlignment.center]
            })
    }
    private func customSelectionStyle(_ selectionView: @escaping () -> AnyView) -> AnyView {
        guard let selectedIndex = selectedIndex else { return AnyView(EmptyView()) }
        return AnyView(selectionView()
            .foregroundColor(.white.opacity(0.8))
            .shadow(color: .gray.opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 3)
            .frame(width: { frames[selectedIndex].width > 0 ? frames[selectedIndex].width - 4 : 0 }(),
                   height: height - 4)
            .alignmentGuide(.horizontalCenterAlignment) { dimensions in
                dimensions[HorizontalAlignment.center]
            } )
    }
}






//enum SelectionType {
//
//    typealias Options = [Any]
//
//    static var selectedIndex: Options.Index? = nil
//    static var options: Options = [ ]
//    static var frames: [CGRect] = Array(repeating: .zero,
//                                        count: options.count)
//    static var height: CGFloat = 0.0
//
//    case regular
//
//
//    var pkk: some View {
//        switch self {
//        case .regular:
//            return selection()
//        }
//    }
//    func selection() -> some View {
//        switch self {
//        case .regular:
//            guard let selectedIndex = SelectionType.selectedIndex else { return AnyView(EmptyView()) }
//            return AnyView(
//                RoundedRectangle(cornerRadius: 6)
//                    .foregroundColor(.white.opacity(0.8))
//                    .shadow(color: .gray.opacity(0.4),
//                            radius: 8,
//                            x: 0,
//                            y: 3)
//                    .frame(width: { SelectionType.frames[selectedIndex].width > 0 ?
//                        SelectionType.frames[selectedIndex].width - 4 : 0 }(),
//                           height: SelectionType.height - 4)
//                    .alignmentGuide(.horizontalCenterAlignment) { dimensions in
//                        dimensions[HorizontalAlignment.center]
//                    }
//            )
//        }
//    }
//}
//extension SelectionType {
//    init(options: Options, selectedIndex: Options.Index?, height: CGFloat) {
//        SelectionType.selectedIndex = selectedIndex
//        SelectionType.options = options
//        SelectionType.height = height
//    }
//}

//public struct MyPicker<Element>: View {
//
//    public typealias Options = [Element]
//
//    @State private var frames: [CGRect]
//    @Binding private var selectedIndex: Options.Index?
//    @State var height: CGFloat = 32.0
//
//    private let options: Options
//    private let selection: SelectionType<Options>
//    private let content: (Options.Element, Bool) -> Content
//    private let selectionAlignment: VerticalAlignment
//    private let action: (Int) -> Void
//
//    init(options: Options,
//         selectedIndex: Binding<Options.Index?>,
//         selectionAlignment: VerticalAlignment = .center,
//         action: @escaping (Int) -> Void,
//         @ViewBuilder content: @escaping (Options.Element, Bool) -> Content,
//         selection: SelectionType<Options>)
//
//    public var body: some View {
//        return SegmentedPicker(options: options,
//                               selectedIndex: $selectedIndex,
//                               selectionAlignment: .center,
//                               action: <#T##(Int) -> Void#>,
//                               content: <#T##(Array<Element>.Element, Bool) -> View#>,
//                               selection: SelectionType<Options>.regular(selectedIndex: selectedIndex).selection)
//    }
//
//
//}






public extension SegmentedPicker where Selection == EmptyView {
    /// Initialisation de `SegmentedPicker`.
    ///
    /// - Parameters:
    ///   - options: Un tableau de données représentant chaque segment c'est à dire chaque option.
    ///   - selectedIndex: Une liaison à l'index du segment actuellement sélectionné.
    ///   - content: Une closure retournant la vue pour chaque segment.
    init(options: Options,
         selectedIndex: Binding<Options.Index?>,
         action: @escaping (Int) -> Void,
         @ViewBuilder content: @escaping (Options.Element, Bool) -> Content)
    {
        self.options = options
        self.content = content
        self.selection = { nil }
        self.selectionAlignment = .center
        self.action = action
        self._selectedIndex = selectedIndex
        self._frames = State(wrappedValue: Array(repeating: .zero,
                                                 count: options.count))
    }
}

//public extension SegmentedPicker {
//    public init(options: Options,
//                selectedIndex: Binding<Options.Index?>,
//                selectionAlignment: VerticalAlignment = .center,
//                action: @escaping (Int) -> Void,
//                @ViewBuilder content: @escaping (Options.Element, Bool) -> Content,
//                selection: @escaping () -> Selection?) {
//
//        self.options = options
//        self.content = content
//        self.selection = selection
//        self.selectionAlignment = selectionAlignment
//        self.action = action
//        self._selectedIndex = selectedIndex
//        self._frames = State(wrappedValue: Array(repeating: .zero,
//                                                 count: options.count))
//    }
//}

struct SegmentedPicker_Previews: PreviewProvider {

    struct SegmentedPickerExample: View {

        let tabs = ["One", "Two", "Three", "Four"]
        @State var selectedIndex: Int? = nil
        let action: (Int) -> Void = { _ in }

        var body: some View {
            SegmentedPicker(options: tabs, selectedIndex: $selectedIndex, action: action) { tab, isSelected in
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

public enum SegmentedPickerStyle {
    case regular
    case underlined
    case stroked
    case capsule
    case custom(cornerRadius: CGFloat)

//    var selection: some View {
//        switch self {
//        case .regular:
//            guard let index = selectedIndex else { return AnyView(EmptyView()) }
//            return AnyView(RoundedRectangle(cornerRadius: 6)
//                .foregroundColor(.white.opacity(0.8))
//                .shadow(color: .gray.opacity(0.4),
//                        radius: 8,
//                        x: 0,
//                        y: 3)
//                .frame(width: { frames[index].width > 0 ? frames[index].width - 4 : 0 }(),
//                       height: height - 4)
//                .alignmentGuide(.horizontalCenterAlignment) { dimensions in
//                    dimensions[HorizontalAlignment.center]
//                })
//        case .stroked:
//            return EmptyView()
//        case .capsule:
//            return EmptyView()
//        case .custom(cornerRadius: _):
//            return EmptyView()
//        }
//
//    }
}
public enum SelectionStyle {
    case regular
    case underlined
    case stroked
    case capsule
    case custom( () -> (any View)?)
}
