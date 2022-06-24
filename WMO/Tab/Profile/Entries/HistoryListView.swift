//
//  HistoryListView.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

private let toolbarItemSize: CGFloat = 15

import ComposableArchitecture
import SwiftUI

struct HistoryListView: View {
    let store: Store<HistoryState, HistoryAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                placeholderedList(isEmpty: viewStore.topicResponse.isEmpty, reachBottom: viewStore.reachEnd, loadMoreAction: {
                    viewStore.send(.loadHistory(onStart: false))
                }) {
                    ForEach(viewStore.topicResponse, id: \.uuid) { res in
                        ForEach(res.topicList?.topics ?? []) { topic in
                            TopicRow(topic: topic,
                                     category: nil,
                                     user: res.users?.first(where: { $0.id == topic.posters?.first?.uid })
                            )
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("浏览历史")
                        .font(.system(size: toolbarItemSize, weight: .semibold))
                        .foregroundColor(Color.black)
                }
            }
            .onAppear {
                // FIXME: reload upon coming back from webview
                viewStore.send(.loadHistory(onStart: true))
            }
        }
    }
}
