//
//  NotificationListView.swift
//  WMO
//
//  Created by weijia on 2022/6/19.
//

import ComposableArchitecture
import SwiftUI

private let toolbarItemSize: CGFloat = 15
private let notiIconSize: CGFloat = 14
private let receivedAtFontSize: CGFloat = 11

struct NotificationListView: View {
    let store: Store<NotificationState, NotificationAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            placeholderedList(isEmpty: viewStore.notifications.isEmpty, reachBottom: true, loadMoreAction: {
                // TODO:
            }) {
                ForEach(viewStore.notifications) { noti in
                    if let type = noti.type, type != .group_message_summary, let topicId = noti.topicId {
                        webviewLink("https://womenoverseas.com/t/topic/\(topicId)",
                                    title: noti.payload.topicTitle ?? "")  {
                            NotificationRow(message: noti)
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                        }
                    } else {
                        NotificationRow(message: noti)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                    }
                }
            }
            .onAppear {
                viewStore.send(.loadList)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("通知")
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

private struct NotificationRow: View {
    let message: NotificationMessage

    private func content(type: NotificationMessage.`Type`?) -> Text {
        let midString: String
        let endString: String
        if type == .granted_badge {
            midString = "获得了"
            endString = message.payload.badgeName ?? "徽章"
        } else {
            midString = message.payload.displayUsername ?? "unknown"
            endString = message.payload.topicTitle ?? message.fancyTitle ?? ""
        }
        let concated =
        Text(Image(systemName: type?.icon ?? "questionmark"))
            .font(.system(size: notiIconSize, weight: .semibold))
            .foregroundColor(.orange)
        +
        Text(" " + midString)
            .font(.system(size: notiIconSize))
        +
        Text(endString)
            .font(.system(size: notiIconSize, weight: .semibold))
        return concated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            content(type: message.type)
            HStack {
                Spacer()
                Text(message.createdAt.readableAgo)
                    .font(.system(size: receivedAtFontSize))
                    .foregroundColor(Color.systemLightGray)
            }
        }
    }
}

#if DEBUG
let fakeData =
    NotificationMessage(id: 2234,
                        userId: 23424,
                        externalId: nil,
                        type: .granted_badge,
                        read: true,
                        highPriority: false,
                        createdAt: "2022-02-25T08:26:24.143Z",
                        postNumber: nil,
                        topicId: nil,
                        fancyTitle: nil,
                        slug: nil,
                        payload: .init(badgeId: 1, badgeName: "身份明确的好人", badgeSlug: nil, badgeTitle: false, username: "weijia", topicTitle: nil, originalPostId: nil, originalPostType: nil, originalUsername: nil, revisionNumber: nil, displayUsername: nil, title: nil, bookmarkName: nil, bookmarkableUrl: nil, count: 1, groupId: nil, groupName: "admins", inboxCount: 111),
                        isWarning: nil)
struct NotificationListView_Previews : PreviewProvider {
    static var previews: some View {
        List {
            ForEach(0..<3) { _ in
                NotificationRow(message: fakeData)
            }
        }.listStyle(PlainListStyle())
    }
}
#endif
