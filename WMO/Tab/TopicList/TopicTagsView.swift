//
//  TopicTagsView.swift
//  WMO
//
//  Created by weijia on 2022/6/17.
//

import SwiftUI
import ComposableArchitecture

private let tagFontSize: CGFloat = 13
private let tagNumberSize: CGFloat = 12
private let tagCornerRadius: CGFloat = 2
private let itemSpacing: CGFloat = 10
private let flowSpacing: CGFloat = 15
private let tagTextPadding = EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
private let toolbarItemSize: CGFloat = 15

enum TagOrder {
    case alphabet, counts
}

struct TopicTagsView: View {
    let store: Store<TagState, TagAction>
    @State private var showingAlert = false

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView(.vertical) {
                if viewStore.tags.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    VFlow(alignment: .leading, horizontalSpacing: itemSpacing, verticalSpacing: itemSpacing) {
                        ForEach(viewStore.tags, id: \.id) { tag in
                            tagButton(name: tag.name, count: tag.count)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: flowSpacing, bottom: flowSpacing, trailing: flowSpacing))
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("标签")
                        .font(.system(size: toolbarItemSize, weight: .semibold))
                        .foregroundColor(Color.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAlert = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.mainIcon)
                    }
                }
            }
            .actionSheet(isPresented: $showingAlert) {
                ActionSheet(
                    title: Text("话题排序"),
                    buttons: [
                        .default(Text("按名称排序")) {
                            viewStore.send(.tapTagOrder(.alphabet))
                        },
                        .default(Text("按话题数排序")) {
                            viewStore.send(.tapTagOrder(.counts))
                        },
                        .cancel(Text("取消"))]
                )
            }
            .onAppear {
                if viewStore.tags.isEmpty {
                    viewStore.send(.loadTags)
                }
            }
            .navigationBarTitle("") // workaround: remove back button title
        }
    }

    private func tagButton(name: String, count: Int) -> some View {
        let content = Text(name)
            .foregroundColor(Color.black)
            .font(.system(size: tagFontSize, weight: .semibold))
        +
        Text(" x \(count)")
            .foregroundColor(Color.gray)
            .font(.system(size: tagNumberSize))

        let fullContent: Text
        if name == "精华贴" {
            fullContent = (Text(Image(systemName: "crown"))
                .foregroundColor(Color.yellow)
                .font(.system(size: tagFontSize, weight: .semibold))
            + content)
        } else {
            fullContent = content
        }
        
        return NavigationLink(destination: TagTopicListView(tag: name, store: self.store)) {
            fullContent
            .padding(tagTextPadding)
            .background(Color.tagBackground)
            .cornerRadius(tagCornerRadius)
        }
    }
}

struct TagTopicListView: View {
    let tag: String
    let store: Store<TagState, TagAction>

    @ViewBuilder
    func center<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let view = HStack(alignment: .center) {
            Spacer()
            content()
            Spacer()
        }
        if #available(iOS 15.0, *) {
            view.listRowSeparator(.hidden)
        } else {
            view
        }
    }

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
