

import SwiftUI

/// A view that represents a grid view.
struct ACGridStack<B, F>: View where B: View, F: View {
    @EnvironmentObject private var store: ACDataStore
    
    let constant: ACConstant
    var background: ((ACIndexSet?, ACData?) -> B)?
    var foreground: ((ACIndexSet?, ACData?) -> F)?
    
    @State private var rowSize: CGSize = .zero
    @State private var titleWidth: CGFloat = .zero
    @State private var _titleSize: CGSize = .zero
    
    var body: some View {
        content
            .font(store.constant.font)
    }
    
    // MARK: - Properties

    /// Property that displays the grid view.
    private var content: some View {
        let spacing = store.constant.spacing
        return ZStack {
            if constant.axisMode == .horizontal {
                HStack(alignment: .top, spacing: spacing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("M")
                            .frame(height: rowSize.height)
                            .padding(.top, rowSize.height * 2 + spacing * 2)
                        Text("W")
                            .frame(height: rowSize.height)
                            .padding(.top, rowSize.height + spacing * 2)
                        Text("F")
                            .frame(height: rowSize.height)
                            .padding(.top, rowSize.height + spacing * 2)
                    }
                    ForEach(Array(store.datas.enumerated()), id: \.offset) { column, datas in
                        LazyVStack(alignment: .leading, spacing: spacing) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: rowSize.height, height: rowSize.height)
                                .overlay(getMonthTitle(column), alignment: .leading)
                            ForEach(Array(datas.enumerated()), id: \.offset) { row, data in
                                getRowView(column: column, row: row, data: data)
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: spacing) {
                    ZStack(alignment: .bottom) {
                        let size = titleWidth
                        Text("M")
                            .offset(x: size + (rowSize.width * 1 + spacing * 2))
                        Text("W")
                            .offset(x: size + (rowSize.width * 3 + spacing * 4))
                        Text("F")
                            .offset(x: size + (rowSize.width * 5 + spacing * 5))
                    }
                    ForEach(Array(store.datas.enumerated()), id: \.offset) { column, datas in
                        HStack(alignment: .top, spacing: spacing) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: titleWidth, height: rowSize.height)
                                .overlay(getMonthTitle(column), alignment: .trailing)
                            ForEach(Array(datas.enumerated()), id: \.offset) { row, data in
                                getRowView(column: column, row: row, data: data)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// A method that returns a row view.
    /// - Parameters:
    ///   - column: The column position index.
    ///   - row: The row position index.
    ///   - data: The model that defines the row view.
    /// - Returns: -
    private func getRowView(column: Int, row: Int, data: ACData) -> some View {
        ZStack {
            background?(ACIndexSet(column: column, row: row), data)
            foreground?(ACIndexSet(column: column, row: row), data)
                .opacity(getOpacity(count: data.count))
                .takeSize($rowSize)
        }
    }
    
    /// A method returns the month title.
    /// - Parameter column: The column position index.
    /// - Returns: -
    private func getMonthTitle(_ column: Int) -> some View {
        ZStack {
            if !store.datas[0].isEmpty {
                if column >= 1 {
                    if store.datas[column - 1][0].date.monthTitle != store.datas[column][0].date.monthTitle {
                        Text(store.datas[column][0].date.monthTitle)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .takeSize($_titleSize)
                    }
                } else {
                    let date = store.datas[column][0].date
                    if date > constant.fromDate && date < constant.toDate {
                        Text(date.monthTitle)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .takeSize($_titleSize)
                    }
                }
            }
        }
        .onChange(of: _titleSize) { _ in
            titleWidth = max(titleWidth, _titleSize.width)
        }
    }
    
    /// Returns the opacity value based on the level.
    /// - Parameter count: The number contributed to the current date.
    /// - Returns: Transparency value.
    private func getOpacity(count: Int) -> CGFloat {
        if count <  ACLevel.first.rawValue * store.constant.levelSpacing{
           
            return ACLevel.zero.opacity
        } else if ACLevel.first.rawValue * store.constant.levelSpacing >= count {
            return ACLevel.first.opacity
        } else if ACLevel.second.rawValue * store.constant.levelSpacing >= count {
            return ACLevel.second.opacity
        } else if ACLevel.third.rawValue * store.constant.levelSpacing >= count {
            return ACLevel.third.opacity
        } else if ACLevel.fourth.rawValue * store.constant.levelSpacing >= count {
            return ACLevel.fourth.opacity
        }
        return 1.0
    }
}

extension ACGridStack where B: View, F: View {
    /// Initializes `ACGridStack`
    /// - Parameters:
    ///   - constant: Settings that define the contribution view.
    ///   - background: The view that is the background of the row view.
    ///   - foreground: The view that is the foreground of the row view.
    init(constant: ACConstant,
         @ViewBuilder background: @escaping (ACIndexSet?, ACData?) -> B,
         @ViewBuilder foreground: @escaping (ACIndexSet?, ACData?) -> F)
    {
        self.constant = constant
        self.background = background
        self.foreground = foreground
    }
}

struct ACGridStack_Previews: PreviewProvider {
    static var previews: some View {
        AxisContribution(
            constant: .init(),
            source: [:]
        )
    }
}
