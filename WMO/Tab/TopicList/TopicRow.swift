//
//  TopicRow.swift
//  WMO
//
//  Created by weijia on 2022/6/17.
//

import SwiftUI

private let categoryFontSize: CGFloat = 13
private let categoryTextPaddingInRow = EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8)
private let categoryBackgroundOpacity: CGFloat = 0.25
private let categoryCornerRadiusInRow: CGFloat = 10
private let tagFontSize: CGFloat = 12
private let tagCornerRadius: CGFloat = 2
private let itemVerticalSpacing: CGFloat = 10
private let rowPadding = EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0)
private let detailInfoSpacing: CGFloat = 4
private let titleFontSize: CGFloat = 15
private let titleLineSpacing: CGFloat = 3
private let bottomRightElementsFontSize: CGFloat = 11
private let toolbarItemSize: CGFloat = 15

struct CategoryView: View {
  let categoryItem: CategoryList.Category
  var body: some View {
    Text(categoryItem.displayName)
      .font(.system(size: categoryFontSize))
      .foregroundColor(Color(hex: categoryItem.color))
      .padding(categoryTextPaddingInRow)
      .background(Color(hex: categoryItem.color).opacity(categoryBackgroundOpacity))
      .cornerRadius(categoryCornerRadiusInRow)
  }
}

struct TagView: View {
  let tag: String
  var body: some View {
    Text(tag)
      .font(.system(size: tagFontSize))
      .foregroundColor(Color.tagText)
      .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
      .background(Color.tagBackground)
      .cornerRadius(tagCornerRadius)
  }
}

struct TopicRow: View {
  
  let topic: Topic
  let category: CategoryList.Category?
  let user: User.User?
  
  private func titleText(_ topic: Topic) -> Text {
    if topic.pinned == true {
      return Text(Image(systemName: "pin")) + Text(topic.title)
    } else {
      return Text(topic.title)
    }
  }
  
  var body: some View {
    webviewLink("https://womenoverseas.com/t/topic/\(topic.id)",
                title: topic.title) {
      VStack(spacing: itemVerticalSpacing) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: itemVerticalSpacing) {
            titleText(topic)
              .foregroundColor(.black)
              .font(.system(size: titleFontSize))
              .fixedSize(horizontal: false, vertical: true)
              .lineSpacing(titleLineSpacing)
            HStack() { // category_tags
              if let categoryItem = self.category {
                CategoryView(categoryItem: categoryItem)
              }
              ForEach(topic.tags ?? [], id: \.hashValue) { tag in
                TagView(tag: tag)
              }
            }
          } // title, tags
          Spacer()
          avatar(template: self.user?.avatarTemplate)
        } // title, tags, avatar
        HStack(spacing: detailInfoSpacing) {
          if let lastPosted = topic.lastPostedAt {
            Text(lastPosted.readableAgo + "更新").font(.system(size: bottomRightElementsFontSize))
          }
          Spacer()
          Image(systemName: "eye.fill").font(.system(size: bottomRightElementsFontSize))
          Text("\(topic.views ?? 0)").font(.system(size: bottomRightElementsFontSize))
          Image(systemName: "circle.fill").font(.system(size: 2.5))
          Image(systemName: "text.bubble.fill").font(.system(size: bottomRightElementsFontSize))
          Text("\(topic.postsCount)").font(.system(size: bottomRightElementsFontSize))
          Image(systemName: "circle.fill").font(.system(size: 2.5))
          Image(systemName: "heart.fill").font(.system(size: bottomRightElementsFontSize))
          Text("\(topic.likeCount ?? 0)").font(.system(size: bottomRightElementsFontSize))
        } // lastUpdated, views, posts, likes
        .foregroundColor(Color(UIColor.lightGray))
      }.padding(rowPadding)
    }
  }
}
