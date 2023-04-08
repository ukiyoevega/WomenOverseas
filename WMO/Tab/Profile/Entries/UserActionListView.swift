//
//  UserActionListView.swift
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
private let bottomRightElementsFontSize: CGFloat = 11

import ComposableArchitecture
import SwiftUI

struct UserActionListView: View {
  let store: Store<UserActionState, UserActionAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Group {
        placeholderedList(isEmpty: viewStore.userActions.isEmpty, reachBottom: viewStore.reachEnd, loadMoreAction: {
          viewStore.send(.loadUserAction(onStart: false))
        }) {
          ForEach(viewStore.userActions, id: \.id) { userAction in
            UserActionRow(userAction: userAction, stringWithAttributes: viewStore.userActionAttributes[userAction.id] ?? [])
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(viewStore.type.title)
            .font(.system(size: toolbarItemSize, weight: .semibold))
            .foregroundColor(Color.black)
        }
      }
      .onAppear {
        // FIXME: reload upon coming back from webview
        viewStore.send(.loadUserAction(onStart: true))
      }
    }
  }
}

struct UserActionRow: View {
  
  let userAction: UserAction
  let stringWithAttributes: [StringWithAttributes]
  
  var body: some View {
    ZStack {
      VStack(spacing: itemVerticalSpacing) {
        HStack(alignment: .top) {
          Text(userAction.title)
            .foregroundColor(.black)
            .font(.system(size: titleFontSize))
            .fixedSize(horizontal: false, vertical: true)
            .lineSpacing(titleLineSpacing)
          Spacer()
          EmptyView()
          avatar(template: userAction.avatarTemplate)
        } // title, avatar
        attributedText(stringWithAttributes,
                       fontSize: excerptFontSize)
        .fixedSize(horizontal: false, vertical: true)
        HStack {
          Text(userAction.createdAt.readableAgo).font(.system(size: bottomRightElementsFontSize))
          Spacer()
        }
      }
      .padding(rowPadding)
    }
  }
}
