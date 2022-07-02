//
//  ProfileView.swift
//  WMO
//
//  Created by weijia on 2022/5/24.
//

import ComposableArchitecture
import SwiftUI

private let settingEntrySize: CGFloat = 22
private let settingEntryFontSize: CGFloat = 14
private let settingEntryIconTitleSpacing: CGFloat = 8
private let settingDetailSize: CGFloat = 15

// TODO: View profile: 关注者, 正在关注, 加入日期, 最后一个帖子, 最后活动, 浏览量
struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ListWithoutSepatorsAndMargins {
                Group {
                    ProfileHeaderView(store: self.store.scope(state: \.profileHeaderState, action: ProfileAction.header))
                    ProfileSummaryView(store: self.store.scope(state: \.profileSummaryState, action: ProfileAction.summary))
                        .padding([.top, .bottom])
                    Section(header: Text("")) {
                        ForEach(SettingEntry.myEntries) { entry in
                            entryRow(entry)
                        }
                    }

                    Section(header: Text("")) {
                        ForEach(SettingEntry.otherEntries) { entry in
                            entryRow(entry)
                        }
                    }
                    #if DEBUG
                    Section(header: Text("")) {
                        ForEach(SettingEntry.ongoingEntries) { entry in
                            entryRow(entry)
                        }
                    }
                    #endif
                }
            }
            .padding([.leading, .trailing, .top])
            .onAppear {
                viewStore.send(.summary(.refresh))
                viewStore.send(.header(.refresh))
            }
        }
    }

    @ViewBuilder
    func entryRow(_ entry: SettingEntry, toggle: Binding<Bool>? = nil) -> some View {
        /* toggle be like
         viewStore.binding(get: \.isNativeMode, send: ProfileAction.toggleNativeMode)
         */
        NavigationLink(destination: entryView(entry)) {
            HStack(spacing: settingEntryIconTitleSpacing) {
                Image(systemName: entry.iconName)
                    .frame(width: settingEntrySize)
                    .foregroundColor(Color.gray)
                Text(entry.description)
                    .font(.system(size: settingEntryFontSize, weight: .semibold))
                    .foregroundColor(Color.black)
                Spacer()

                if let toggle = toggle {
                    Toggle(isOn: toggle) { }
                            .toggleStyle(SmallToggleStyle())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: settingDetailSize))
                        .foregroundColor(Color.gray)
                }
            }
            .padding([.top, .bottom])
        }
        .navigationBarTitle("") // remove back button title
    }
    
    @ViewBuilder
    func entryView(_ entry: SettingEntry) -> some View {
        switch entry {
        case .notification:
            NotificationListView(store: self.store.scope(state: \.notificationState, action: ProfileAction.notification))
        case .aboutUs:
            AboutView()
        case .donation:
            Webview(type: .home, url: "https://womenoverseas.com/t/topic/11426")
        case .bookmark:
            BookmarkListView(store: Store(initialState: BookmarkState(), reducer: bookmarkReducer, environment: ProfileEnvironment()))
        case .history:
            HistoryListView(store: Store(initialState: HistoryState(), reducer: historyReducer, environment: TopicEnvironment()))
        case .liked:
            LikeListView(store: Store(initialState: LikeState(), reducer: likeReducer, environment: TopicEnvironment()))
        default:
            Text(entry.description)
        }
    }
}

struct NoButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

struct ListWithoutSepatorsAndMargins<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    self.content()
                }
                .buttonStyle(NoButtonStyle())
            }
        } else {
            List {
                self.content()
            }
            .listStyle(PlainListStyle())
            .buttonStyle(NoButtonStyle())
        }
    }
}

enum SettingEntry: String, CustomStringConvertible, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    static var myEntries: [SettingEntry] {
        return [.notification, .bookmark, .liked, .history]
    }

    static var otherEntries: [SettingEntry] {
        return [.aboutUs, .donation]
    }

    static var ongoingEntries: [SettingEntry] {
        return [.draft, .account, .theme, .settings, .createdTopic, .replied]
    }

    case notification
    case bookmark
    case liked
    case history

    case aboutUs
    case donation

    case draft
    case createdTopic
    case replied
    case account
    case theme
    case settings

    var description: String {
        get {
            switch self {
            case .account: return "我的账号"
            case .notification: return "我的通知"
            case .bookmark: return "我的书签"
            case .liked: return "我赞过的"
            case .history: return "浏览历史"
            case .theme: return "切换到原生模式"
            case .settings: return "设置"
            case .aboutUs: return "关于我们"
            case .donation: return "捐助"
            case .createdTopic: return "我的话题"
            case .replied: return "我的回复"
            case .draft: return "我的草稿"
            }
        }
    }
    
    var iconName: String {
        get {
            switch self {
            case .account: return "person.crop.artframe"
            case .notification: return "envelope"
            case .bookmark: return "bookmark"
            case .liked: return "heart"
            case .history: return "book"
            case .donation: return "yensign.circle"
            case .settings: return "gearshape.2"
            case .aboutUs: return "info.circle"
            case .theme: return "switch.2"
            case .createdTopic: return "doc.text"
            case .replied: return "arrowshape.turn.up.left"
            case .draft: return "doc.append"
            }
        }
    }
}

struct SmallToggleStyle: ToggleStyle {

    private let toggleWidth: CGFloat = 35
    private let toggleHeight: CGFloat = 21
    private let circlePadding: CGFloat = 3
    private let circleOffset: CGFloat = 7

    var circleHeight: CGFloat {
        toggleHeight - circlePadding * 2
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(configuration.isOn ? Color.mainIcon : .gray)
                .frame(width: toggleWidth, height: toggleHeight, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(.all, circlePadding)
                        .offset(x: configuration.isOn ? circleOffset : -circleOffset, y: 0)
                        .animation(Animation.linear(duration: 0.1))

                ).cornerRadius(circleHeight)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

#if DEBUG
struct ProfileView_Previews : PreviewProvider {
    static var previews: some View {
        ProfileView(store: Store(initialState: ProfileState(),
                                 reducer: profileReducer, environment: ()))
    }
}
#endif
