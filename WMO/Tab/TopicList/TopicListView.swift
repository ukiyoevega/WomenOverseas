//
//  LatestView.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import SwiftUI
import ComposableArchitecture

private let itemVerticalSpacing: CGFloat = 10
private let titleFontSize: CGFloat = 15
private let titleLineSpacing: CGFloat = 3
private let categoryFontSize: CGFloat = 13
private let tagFontSize: CGFloat = 12
private let lastViewFontSize: CGFloat = 11
private let rowPadding = EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0)
private let avatarWidth: CGFloat = 40
private let detailInfoSpacing: CGFloat = 4
private let categoryCornerRadius: CGFloat = 10
private let tagCornerRadius: CGFloat = 2

struct TopicListView: View {
    let store: Store<TopicState, TopicAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                Section {
                    ForEach(viewStore.topicResponse, id: \.uuid) { res in
                        ForEach(res.topicList.topics) { topic in
                            TopicRow(topic: topic,
                                     category: viewStore.categories.first(where: { $0.id == topic.categoryId }),
                                     user: res.users.first(where: { $0.id == topic.posters.first?.uid })
                            )
                        }
                    }
                } header: {
                    CategoriesView(categories: viewStore.categories)
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .onAppear {
                            viewStore.send(.loadCategories)
                        }
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                viewStore.send(.loadTopics)
            }
        }
    }
}

struct TopicRow: View {
    
    let topic: Topic
    let category: CategoryList.Category?
    let user: User.User?

    private func category(_ categoryItem: CategoryList.Category) -> some View {
        return Text(categoryItem.displayName)
            .font(.system(size: categoryFontSize))
            .foregroundColor(.white)
            .padding(.init(top: 3, leading: 8, bottom: 3, trailing: 8))
            .background(Color(hex: categoryItem.color))
            .cornerRadius(categoryCornerRadius)
    }
    
    private func label(_ text: String) -> some View {
        return Text(text)
            .font(.system(size: tagFontSize))
            .foregroundColor(Color("tag_text", bundle: nil))
            .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(Color("tag_bg", bundle: nil))
            .cornerRadius(tagCornerRadius)
    }
    
    var body: some View {
        
        VStack(spacing: itemVerticalSpacing) { // content_bottomRow
            HStack(alignment: .top) { // titleTags_avatar
                VStack(alignment: .leading, spacing: itemVerticalSpacing) { // title + tags
                    Text(topic.title)
                        .foregroundColor(.black)
                        .font(.system(size: titleFontSize))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(titleLineSpacing)
                    HStack() { // category_tags
                        if let categoryItem = self.category {
                            category(categoryItem)
                        }
                        ForEach(topic.tags, id: \.hashValue) { tag in
                            label(tag)
                        }
                    }
                }
                Spacer()
                if let user = self.user,
                    let escapedString = String("https://womenoverseas.com" + user.avatarTemplate)
                    .replacingOccurrences(of: "{size}", with: "400")
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let avatarURL = URL(string: escapedString) {
                    AsyncImage(url: avatarURL) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.blue.opacity(0.3)).frame(width: avatarWidth)
                    }
                    .frame(width: avatarWidth, height: avatarWidth)
                    .cornerRadius(avatarWidth / 2)
                }
            }
            HStack(spacing: detailInfoSpacing) { // lastUpdated_viewCount_postCount
                Text(topic.lastPostedAt).font(.system(size: lastViewFontSize))
                Spacer()
                Image(systemName: "eye.fill").font(.system(size: lastViewFontSize))
                Text("\(topic.views)").font(.system(size: lastViewFontSize))
                Image(systemName: "circle.fill").font(.system(size: 2.5))
                Image(systemName: "text.bubble.fill").font(.system(size: lastViewFontSize))
                Text("\(topic.postsCount)").font(.system(size: lastViewFontSize))
            }.foregroundColor(Color(UIColor.lightGray))
        }.padding(rowPadding)
    }
}

#if DEBUG
let fakeTopic = Topic(id: 1,
                      title: "前性别NGOer/activist,现性别研究专业学渣博士生,也感兴趣很多别的欢迎一起讨论",
                      fancyTitle: "saffa", slug: "safsf",
                      postsCount: 1, replyCount: 1, highestPostNumber: 1,
                      imageUrl: nil,
                      createdAt: "2021", lastPostedAt: "2022", bumped: false, bumpedAt: "2022",
                      archetype: "arche", unseen: false,
                      lastReadPostNumber: 0, unread: 0, newPosts: 0, unreadPosts: 0,
                      pinned: false, unpinned: 0,
                      visible: false, closed: false, archived: false,
                      notificationLevel: 1,
                      bookmarked: false, liked: false,
                      tags: ["saf", "sffdf", "fdfdfdfdfdfdf"],
                      views: 2, likeCount: 1,
                      hasSummary: false,
                      lastPosterUsername: "fasfsakufuomeiwycfo",
                      categoryId: 2,
                      pinnedGlobally: false,
                      featuredLink: nil,
                      hasAcceptedAnswer: false,
                      posters: []
)


struct CategoriesFakeView: View {
    
    private func category(_ type: Category, selected: Bool) -> some View {
        let tint = Color("category_\(type.rawValue)", bundle: nil)
        return Text(type.description)
            .font(.system(size: 13))
            .foregroundColor(tint)
            .padding(.init(top: 6, leading: 10, bottom: 6, trailing: 10))
            .background(tint.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(tint, lineWidth: selected ? 1.5 : 0)
            )
            .cornerRadius(16)
    }
    
    var body: some View {
        var scrollView = ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(Category.allCases) { cat in
                    category(cat, selected: cat == .study)
                }
            }
            .padding([.leading, .trailing], 15)
            .padding([.bottom], 6)
        }
        scrollView.showsIndicators = false
        return scrollView
    }
}

struct HomeView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack(spacing: 0) {
                CategoriesFakeView()
                List {
                    ForEach(0..<50) { _ in
                        TopicRow(topic: fakeTopic, category: nil, user: nil)
                    }
                }.listStyle(PlainListStyle())
            }.navigationBarTitle("首页")
        }
    }
}
#endif
