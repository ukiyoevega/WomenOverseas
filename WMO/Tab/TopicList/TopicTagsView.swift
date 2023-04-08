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
            viewStore.send(.toggleSortSheet)
          } label: {
            Image(systemName: "arrow.up.arrow.down")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(Color.mainIcon)
          }
        }
      }
      .actionSheet(isPresented: viewStore.binding(get: \.showSortSheet, send: TagAction.toggleSortSheet)) {
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
