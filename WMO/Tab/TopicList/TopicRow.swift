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
private let avatarWidth: CGFloat = 40
private let titleFontSize: CGFloat = 15
private let titleLineSpacing: CGFloat = 3
private let bottomRightElementsFontSize: CGFloat = 11

struct TopicRow: View {

    let topic: Topic
    let category: CategoryList.Category?
    let user: User.User?

    private func category(_ categoryItem: CategoryList.Category) -> some View {
        let tint = Color(hex: categoryItem.color)
        return Text(categoryItem.displayName)
            .font(.system(size: categoryFontSize))
            .foregroundColor(tint)
            .padding(categoryTextPaddingInRow)
            .background(tint.opacity(categoryBackgroundOpacity))
            .cornerRadius(categoryCornerRadiusInRow)
        /*
        return Text(categoryItem.displayName)
            .font(.system(size: categoryFontSize))
            .foregroundColor(.white)
            .padding(.init(top: 3, leading: 8, bottom: 3, trailing: 8))
            .background(Color(hex: categoryItem.color))
            .cornerRadius(topicCategoryCornerRadius)
         */
    }

    private func label(_ text: String) -> some View {
        return Text(text)
            .font(.system(size: tagFontSize))
            .foregroundColor(Color.tagText)
            .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(Color.tagBackground)
            .cornerRadius(tagCornerRadius)
    }

    private func lastPostedAt(_ iso8601: String?) -> String {
        guard let iso8601 = iso8601 else { return "" }
        let formatter = Date.dateFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: iso8601)?.dateStringWithAgo ?? ""
    }

    private func titleText(_ topic: Topic) -> Text {
        if topic.pinned == true {
            return Text(Image(systemName: "pin")) + Text(topic.title)
        } else {
            return Text(topic.title)
        }
    }

    var body: some View {
        ZStack {
            NavigationLink(destination: Webview(type: .home, url: "https://womenoverseas.com/t/topic/\(topic.id)")) {
                EmptyView()
            }
            .opacity(0)
            .navigationBarTitle("") // workaround: remove back button title
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
                                category(categoryItem)
                            }
                            ForEach(topic.tags ?? [], id: \.hashValue) { tag in
                                label(tag)
                            }
                        }
                    } // title, tags
                    Spacer()
                    if let user = self.user,
                       let escapedString = String("https://womenoverseas.com" + user.avatarTemplate)
                        .replacingOccurrences(of: "{size}", with: "400")
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let avatarURL = URL(string: escapedString) {
                        VStack(alignment: .trailing) {
                            AsyncImage(url: avatarURL) { image in
                                image.resizable()
                            } placeholder: {
                                Circle().fill(Color.avatarPlaceholder).frame(width: avatarWidth)
                            }
                            .frame(width: avatarWidth, height: avatarWidth)
                            .cornerRadius(avatarWidth / 2)
                        }
                    }
                } // title, tags, avatar
                HStack(spacing: detailInfoSpacing) {
                    Text(lastPostedAt(topic.lastPostedAt)).font(.system(size: bottomRightElementsFontSize))
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
