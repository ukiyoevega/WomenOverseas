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
                if (!viewStore.topicResponse.isEmpty) {
                    List {
                        ForEach(viewStore.topicResponse, id: \.uuid) { res in
                            ForEach(res.topicList?.topics ?? []) { topic in
                                TopicRow(topic: topic,
                                         category: nil,
                                         user: res.users?.first(where: { $0.id == topic.posters?.first?.uid })
                                )
                            }
                        }
                        if viewStore.reachEnd {
                            center {
                                Text("就这些啦")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(UIColor.lightGray))
                                    .padding()
                            }

                        } else if !viewStore.topicResponse.isEmpty {
                            /// The pagination is done by appending a invisible rectancle at the bottom of the list, and trigerining the next page load as it appear... hacky way for now
                            center { ProgressView() }
                                .onAppear { viewStore.send(.loadTopics(onStart: false, tag: self.tag)) }
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Spacer()
                    center { ProgressView() }
                    Spacer()
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
