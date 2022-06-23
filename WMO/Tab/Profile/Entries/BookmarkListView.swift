//
//  BookmarkListView.swift
//  WMO
//
//  Created by weijia on 2022/6/21.
//

import ComposableArchitecture
import SwiftUI

private let toolbarItemSize: CGFloat = 15
private let notiIconSize: CGFloat = 14
private let receivedAtFontSize: CGFloat = 11

private let itemVerticalSpacing: CGFloat = 10
private let rowPadding = EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0)
private let avatarWidth: CGFloat = 40
private let titleFontSize: CGFloat = 15
private let excerptFontSize: CGFloat = 13
private let titleLineSpacing: CGFloat = 3

struct BookmarkListView: View {
    let store: Store<BookmarkState, BookmarkAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            placeholderedList(isEmpty: viewStore.bookmarks.isEmpty, reachBottom: viewStore.reachEnd, loadMoreAction: {
                viewStore.send(.loadList)
            }) {
                ForEach(viewStore.bookmarks, id: \.id) { bookmark in
                    BookmarkRow(bookmark: bookmark, togglePinAction: {
                        viewStore.send(.togglePin(id: bookmark.id))
                    }, removeAction: {
                        viewStore.send(.remove(id: bookmark.id))
                    }, stringWithAttributes: viewStore.bookmarkContent[bookmark.id] ?? [], category: viewStore.categories.first(where: { $0.id == bookmark.categoryId }))
                }
            }
            .onAppear {
                if (viewStore.categories.isEmpty) {
                    viewStore.send(.loadCategories)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("我的书签")
                        .font(.system(size: toolbarItemSize, weight: .semibold))
                        .foregroundColor(Color.black)
                }
            }
            .toast(message: viewStore.toastMessage ?? "",
                   isShowing:  viewStore.binding(get: { state in
                return !(state.toastMessage ?? "").isEmpty

            }, send: .dismissToast),
                   duration: Toast.short)
        }
    }
}


struct BookmarkRow: View {

    let bookmark: Bookmark
    let togglePinAction: () -> Void
    let removeAction: () -> Void
    let stringWithAttributes: [StringWithAttributes]
    let category: CategoryList.Category?
    @State private var showingAlert = false

    private func titleText(_ bookmark: Bookmark) -> Text {
        if bookmark.pinned {
            return Text(Image(systemName: "pin")) + Text(bookmark.title)
        } else {
            return Text(bookmark.title)
        }
    }

    var body: some View {
        ZStack {
            NavigationLink(destination: Webview(type: .home, url: bookmark.bookmarkableUrl)) {
                EmptyView()
            }
            .opacity(0)
            .navigationBarTitle("") // workaround: remove back button title
            VStack(spacing: itemVerticalSpacing) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: itemVerticalSpacing) {
                        titleText(bookmark)
                            .foregroundColor(.black)
                            .font(.system(size: titleFontSize))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(titleLineSpacing)
                        HStack() { // category_tags
                            if let categoryItem = self.category {
                                CategoryView(categoryItem: categoryItem)
                            }
                            ForEach(bookmark.tags, id: \.hashValue) { tag in
                                TagView(tag: tag)
                            }
                        }
                    } // title, tags
                    Spacer()
                    if let user = bookmark.user,
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
                stringWithAttributes
                    .map(text(_:))
                    .reduce(Text(""), +)
                    .lineSpacing(titleLineSpacing)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    [(bookmark.createdAt, "收藏，"), (bookmark.bumpedAt, "更新")].map { dateString, suffix in
                        Text(dateString.readableAgo + suffix)
                            .font(.system(size: 11))
                            .foregroundColor(Color(UIColor.lightGray))
                    }.reduce(Text(""), +)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.system(size: 11))
                        .foregroundColor(Color(UIColor.lightGray))
                        .onTapGesture {
                            showingAlert = true
                        }
                } // lastUpdated
            }
            .padding(rowPadding)
            .actionSheet(isPresented: $showingAlert) {
                ActionSheet(
                    title: Text("编辑书签"),
                    buttons: [
                        .default(Text(bookmark.pinned ? "取消置顶" : "置顶")) {
                            self.togglePinAction()
                        },
                        .default(Text("删除")) {
                            self.removeAction()
                        },
                        .cancel(Text("取消"))]
                )
            }
        }
    }

    private func text(_ pair: StringWithAttributes) -> Text {
        if #available(iOS 15, *), let link = pair.attrs[.link], let url = link as? URL {
            var attributedString = AttributedString(pair.string)
            attributedString.underlineStyle = .single
            attributedString.link = url
            return Text(attributedString)
                .foregroundColor(Color.red)
                .font(.system(size: excerptFontSize))
        } else {
            return Text(pair.string)
                .foregroundColor(.gray)
                .font(.system(size: excerptFontSize))
        }
    }
}
