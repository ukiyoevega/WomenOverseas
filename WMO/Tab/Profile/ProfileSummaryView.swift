//
//  CategoriesView.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import SwiftUI
import ComposableArchitecture

private let statisticNumberSize: CGFloat = 14
private let statisticTitleSize: CGFloat = 12
private let statisticNumberTitleSpacing: CGFloat = 5
private let statisticSpacing: CGFloat = 15

struct ProfileSummaryView: View {
    let store: Store<ProfileSummaryState, ProfileSummaryAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: statisticSpacing) {
                    ForEach(viewStore.userResponse.summary.statisticEntries, id: \.0) { item in
                        
                        VStack(spacing: statisticNumberTitleSpacing) {
                            Text("\(item.count)")
                                .font(.system(size: statisticNumberSize, weight: .semibold, design: .default))
                                .foregroundColor(Color.gray)
                            Text(item.title)
                                .font(.system(size: statisticTitleSize))
                                .foregroundColor(Color.black)
                        }
                        if item.title != "发帖量" { // TODO: remove hard-coding
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
