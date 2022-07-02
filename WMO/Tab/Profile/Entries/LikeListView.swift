//
//  LikeListView.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

private let toolbarItemSize: CGFloat = 15
private let itemVerticalSpacing: CGFloat = 10
private let titleFontSize: CGFloat = 15
private let rowPadding = EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0)
private let excerptFontSize: CGFloat = 13
private let titleLineSpacing: CGFloat = 3
import ComposableArchitecture
import SwiftUI

struct LikeListView: View {
    let store: Store<LikeState, LikeAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                placeholderedList(isEmpty: viewStore.likesElement.isEmpty, reachBottom: viewStore.reachEnd, loadMoreAction: {
                    viewStore.send(.loadLike(onStart: false))
                }) {
                    ForEach(viewStore.likesElement, id: \.id) { like in
                        LikeRow(like: like, stringWithAttributes: viewStore.likeContent[like.id] ?? [])
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("我赞过的")
                        .font(.system(size: toolbarItemSize, weight: .semibold))
                        .foregroundColor(Color.black)
                }
            }
            .onAppear {
                // FIXME: reload upon coming back from webview
                viewStore.send(.loadLike(onStart: true))
            }
        }
    }
}

struct LikeRow: View {

    let like: UserAction
    let stringWithAttributes: [StringWithAttributes]

    var body: some View {
        ZStack {
            VStack(spacing: itemVerticalSpacing) {
                HStack(alignment: .top) {
                    Text(like.title)
                        .foregroundColor(.black)
                        .font(.system(size: titleFontSize))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(titleLineSpacing)
                    Spacer()
                    EmptyView()
                    avatar(template: like.avatarTemplate)
                } // title, avatar
                attributedText(stringWithAttributes,
                               fontSize: excerptFontSize)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(rowPadding)
        }
    }
}
