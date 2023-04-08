//
//  PlainTopicListView.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

private let toolbarItemSize: CGFloat = 15

import ComposableArchitecture
import SwiftUI

struct PlainTopicListView: View {
  
  let store: Store<PlainTopicListState, PlainTopicListAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Group {
        placeholderedList(isEmpty: viewStore.topicResponse.isEmpty, reachBottom: viewStore.reachEnd, loadMoreAction: {
          viewStore.send(.loadTopics(onStart: false))
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
          Text(viewStore.type.title)
            .font(.system(size: toolbarItemSize, weight: .semibold))
            .foregroundColor(Color.black)
        }
      }
      .onAppear {
        // FIXME: reload upon coming back from webview
        viewStore.send(.loadTopics(onStart: true))
      }
    }
  }
}
