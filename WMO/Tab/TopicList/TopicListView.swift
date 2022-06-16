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

    @ViewBuilder
    func categories(_ viewStore: ViewStore<TopicState, TopicAction>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: categoriesSpacing) {
                ForEach(viewStore.categories, id: \.id) { cat in
                    category(cat.displayName, color: cat.color, selected: viewStore.currentCategory.id == cat.id) {
                        viewStore.send(.tapCategory(cat))
                    }
                }
            }
            .padding([.leading, .trailing], categoriespadding)
            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        } // categories
    }

    private func getTopicCategory(topic: Topic, _ viewStore: ViewStore<TopicState, TopicAction>) -> CategoryList.Category? {
        if let parentCategory = viewStore.categories.first(where: { $0.id == topic.categoryId }) {
            return parentCategory
        } else {
            let currentCategoryId = viewStore.currentCategory.id
            return viewStore.subCategories[currentCategoryId]?.first(where: { $0.id == topic.categoryId })
        }
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                categories(viewStore)
                if (!viewStore.topicResponse.isEmpty) {
                    List {
                        ForEach(viewStore.topicResponse, id: \.uuid) { res in
                            ForEach(res.topicList?.topics ?? []) { topic in
                                TopicRow(topic: topic,
                                         category: getTopicCategory(topic: topic, viewStore),
                                         user: res.users?.first(where: { $0.id == topic.posters?.first?.uid })
                                )
                            }
                        }
                        if viewStore.reachEnd {
                            center {
                                Text("已经到底啦")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(UIColor.lightGray))
                                    .padding()
                            }

                        } else if !viewStore.topicResponse.isEmpty {
                            /// The pagination is done by appending a invisible rectancle at the bottom of the list, and trigerining the next page load as it appear... hacky way for now
                            center { ProgressView() }
                                .onAppear { viewStore.send(.loadTopics) }
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Spacer()
                    center { ProgressView() }
                    Spacer()
                }
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
//                            let x = viewStore.binding({ state in
//                                state.toastMessage?.isEmpty ?? false
//                            }, sending: .dismissToast)
                        }) {
                            ZStack(alignment: .bottomTrailing) {
                                Image(systemName: "arrow.up.arrow.down.square")
                                    .font(.system(size: 17, weight: .medium))
                                if let order = viewStore.currentOrder {
                                    Image(systemName: order.icon)
                                    .font(.system(size: 10, weight: .medium))
                                    .offset(x: 10)
                                }
                            }
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
                        .default(Text("恢复默认")) {
                            viewStore.send(.tapCategory(.all))
                        },
                        .cancel(Text("取消"))]
                )
            }
            .toast(message: viewStore.toastMessage ?? "",
                   isShowing:  viewStore.binding(get: { state in
                return !(state.toastMessage ?? "").isEmpty

            }, send: .dismissToast),
                   duration: Toast.short)
        }
    }

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
                                Circle().fill(Color.avatarPlaceholder).frame(width: avatarWidth)
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
                    Text("\(topic.likeCount ?? 0)").font(.system(size: lastViewFontSize))
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

struct HomeView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack(spacing: 0) {
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


struct Toast: ViewModifier {
  // these correspond to Android values f
  // or DURATION_SHORT and DURATION_LONG
  static let short: TimeInterval = 2
  static let long: TimeInterval = 3.5

  let message: String
  @Binding var isShowing: Bool
  let config: Config

  func body(content: Content) -> some View {
    ZStack {
      content
      toastView
    }
  }

  private var toastView: some View {
    VStack {
      Spacer()
      if isShowing {
        Group {
          Text(message)
            .multilineTextAlignment(.center)
            .foregroundColor(config.textColor)
            .font(config.font)
            .padding(8)
        }
        .background(config.backgroundColor)
        .cornerRadius(8)
        .onTapGesture {
          isShowing = false
        }
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
            isShowing = false
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 18)
    .animation(config.animation, value: isShowing)
    .transition(config.transition)
  }

  struct Config {
    let textColor: Color
    let font: Font
    let backgroundColor: Color
    let duration: TimeInterval
    let transition: AnyTransition
    let animation: Animation

    init(textColor: Color = .white,
         font: Font = .system(size: 14),
         backgroundColor: Color = .black.opacity(0.588),
         duration: TimeInterval = Toast.short,
         transition: AnyTransition = .opacity,
         animation: Animation = .linear(duration: 0.3)) {
      self.textColor = textColor
      self.font = font
      self.backgroundColor = backgroundColor
      self.duration = duration
      self.transition = transition
      self.animation = animation
    }
  }
}

extension View {
  func toast(message: String,
             isShowing: Binding<Bool>,
             config: Toast.Config) -> some View {
    self.modifier(Toast(message: message,
                        isShowing: isShowing,
                        config: config))
  }

  func toast(message: String,
             isShowing: Binding<Bool>,
             duration: TimeInterval) -> some View {
    self.modifier(Toast(message: message,
                        isShowing: isShowing,
                        config: .init(duration: duration)))
  }
}
