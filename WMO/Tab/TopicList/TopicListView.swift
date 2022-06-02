//
//  LatestView.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import SwiftUI
import ComposableArchitecture

private let iconWidth: CGFloat = 50
private let itemVerticalSpacing: CGFloat = 10
private let titleFontSize: CGFloat = 15
private let titleLineSpacing: CGFloat = 3
private let categoryFontSize: CGFloat = 13
private let tagFontSize: CGFloat = 12
private let lastViewFontSize: CGFloat = 11
private let rowPadding = EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0)
private let avatarWidth: CGFloat = 40
private let detailInfoSpacing: CGFloat = 4
private let topicCategoryCornerRadius: CGFloat = 10
private let tagCornerRadius: CGFloat = 2

private let categoriesSpacing: CGFloat = 5
private let categoriespadding: CGFloat = 10
private let categoryTextPadding = EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
private let categoryBackgroundOpacity: CGFloat = 0.25
private let categoryCornerRadius: CGFloat = 16
private let categoryBorderWidth: CGFloat = 1.5

struct TopicListView: View {
    let store: Store<TopicState, TopicAction>
    @State private var showingAlert = false

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: categoriesSpacing) {
                        ForEach(viewStore.categories, id: \.id) { cat in
                            category(cat.displayName, color: cat.color, selected: viewStore.currentCategory?.id == cat.id) {
                                viewStore.send(.tapCategory(cat))
                            }
                        }
                    }
                    .padding([.leading, .trailing], categoriespadding)
                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                } // categories
                List {
                    ForEach(viewStore.topicResponse, id: \.uuid) { res in
                        ForEach(res.topicList.topics ?? []) { topic in
                            TopicRow(topic: topic,
                                     category: viewStore.categories.first(where: { $0.id == topic.categoryId }),
                                     user: res.users.first(where: { $0.id == topic.posters?.first?.uid })
                            )
                        }
                    }
                    /// The pagination is done by appending a invisible rectancle at the bottom of the list, and trigerining the next page load as it appear... hacky way for now
                    if !viewStore.topicResponse.isEmpty {
                        centeredProgressView
                            .onAppear { viewStore.send(.loadTopics) }
                    }
                }
                .listStyle(PlainListStyle())
            } // workaround for icon-style navigation bar title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("wo_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconWidth, height: 40, alignment: .center)
                }
            }
            .navigationBarItems(
                trailing:
                    HStack {
                        Button(action: {
                            showingAlert = true
                        }) {
                            Image(systemName: "arrow.up.arrow.down.square")
                                .font(.system(size: 16, weight: .medium))
                        }.foregroundColor(Color.mainIcon)
                    }
            )
            .onAppear {
                if viewStore.categories.isEmpty {
                    viewStore.send(.loadCategories)
                }
            }
            .actionSheet(isPresented: $showingAlert) {
                ActionSheet(
                    title: Text("话题排序"),
                    buttons: [
                        .default(Text("按浏览量排序")) {
                            viewStore.send(.tapOrder(.views))
                        },
                        .default(Text("按喜欢排序")) {
                            viewStore.send(.tapOrder(.likes))
                        },
                        .default(Text("按回复量排序")) {
                            viewStore.send(.tapOrder(.posts))
                        },
                        .default(Text("按热门排序")) {
                            viewStore.send(.tapOrder(.default))
                        },
                        .cancel()]
                )
            }
        }
    }

    @ViewBuilder
    var centeredProgressView: some View {
        let view = HStack(alignment: .center) {
            Spacer()
            ProgressView()
            Spacer()
        }
        if #available(iOS 15.0, *) {
            view.listRowSeparator(.hidden)
        } else {
            view
        }
    }

    private func category(_ title: String, color: String, selected: Bool, action: @escaping () -> Void) -> some View {
        let tint = Color(hex: color)
        let text = Text(title)
            .font(.system(size: categoryFontSize))
            .foregroundColor(tint)
            .padding(categoryTextPadding)
            .background(tint.opacity(categoryBackgroundOpacity))
            .overlay(
                RoundedRectangle(cornerRadius: categoryCornerRadius)
                    .stroke(tint, lineWidth: selected ? categoryBorderWidth : 0)
            )
            .cornerRadius(categoryCornerRadius)
        return Button(action: {
            action()
        }, label: {
            text
        })
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
            .cornerRadius(topicCategoryCornerRadius)
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

    var body: some View {
        ZStack {
            NavigationLink(destination: Webview(type: .home, url: "https://womenoverseas.com/t/topic/\(topic.id)")) {
                EmptyView()
            }
            .opacity(0)
            .navigationBarTitle("") // remove back button title
            VStack(spacing: itemVerticalSpacing) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: itemVerticalSpacing) {
                        Text(topic.title)
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
                                Circle().fill(Color.blue.opacity(0.3)).frame(width: avatarWidth)
                            }
                            .frame(width: avatarWidth, height: avatarWidth)
                            .cornerRadius(avatarWidth / 2)
                        }
                    }
                } // title, tags, avatar
                HStack(spacing: detailInfoSpacing) {
                    Text(lastPostedAt(topic.lastPostedAt)).font(.system(size: lastViewFontSize))
                    Spacer()
                    Image(systemName: "eye.fill").font(.system(size: lastViewFontSize))
                    Text("\(topic.views ?? 0)").font(.system(size: lastViewFontSize))
                    Image(systemName: "circle.fill").font(.system(size: 2.5))
                    Image(systemName: "text.bubble.fill").font(.system(size: lastViewFontSize))
                    Text("\(topic.postsCount)").font(.system(size: lastViewFontSize))
                    Image(systemName: "circle.fill").font(.system(size: 2.5))
                    Image(systemName: "heart.fill").font(.system(size: lastViewFontSize))
                    Text("\(topic.likeCount)").font(.system(size: lastViewFontSize))
                } // lastUpdated, views, posts, likes
                .foregroundColor(Color(UIColor.lightGray))
            }.padding(rowPadding)
        }
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
        let tint = Color.orange
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
