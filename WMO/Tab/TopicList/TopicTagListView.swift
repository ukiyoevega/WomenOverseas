//
//  TopicTagListView.swift
//  WMO
//
//  Created by weijia on 2022/6/21.
//

import SwiftUI
import ComposableArchitecture

private let toolbarItemSize: CGFloat = 15

struct TagTopicListView: View {
    let tag: String
    let store: Store<TagState, TagAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                placeholderedList(isEmpty: viewStore.topicResponse.isEmpty, reachBottom: viewStore.reachEnd, loadMoreAction: {
                    viewStore.send(.loadTopics(onStart: false, tag: self.tag))
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
                    Text(tag)
                        .font(.system(size: toolbarItemSize, weight: .semibold))
                        .foregroundColor(Color.black)
                }
            }
            .onAppear {
                viewStore.send(.loadTopics(onStart: true, tag: self.tag))
            }
        }
    }
}
