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
private let titleLineSpacing: CGFloat = 3

struct BookmarkListView: View {
    let store: Store<BookmarkState, BookmarkAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                ForEach(viewStore.bookmarks) { bookmark in
                    BookmarkRow(bookmark: bookmark, category: viewStore.categories.first(where: { $0.id == bookmark.categoryId }))
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                viewStore.send(.loadCategories)
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
    let category: CategoryList.Category?

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
                        Text(bookmark.title)
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
                Text(bookmark.excerpt)
                    .foregroundColor(.gray)
                    .font(.system(size: titleFontSize))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(titleLineSpacing)
                if let lastPosted = bookmark.updatedAt {
                    HStack {
                        Spacer()
                        Text(lastPosted.readableAgo)
                            .font(.system(size: 11))
                            .foregroundColor(Color(UIColor.lightGray))
                    }
                } // lastUpdated
            }.padding(rowPadding)
        }
    }
}
