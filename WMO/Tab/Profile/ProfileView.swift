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

// 关注者 8 - 正在关注 1 - 加入日期： 20 年 0 月 4 日 - 最后一个帖子 23 小时 - 最后活动 4 分钟 - 浏览量 627
// https://womenoverseas.com/u/merry_go_round/summary
struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ListWithoutSepatorsAndMargins {
                Group {
                    ProfileHeaderView(store: self.store.scope(state: \.profileHeaderState, action: ProfileAction.header))
                    ProfileSummaryView(store: self.store.scope(state: \.profileSummaryState, action: ProfileAction.summary))
                        .padding([.top, .bottom])
                    ForEach(SettingEntry.allCases) { entry in
                        NavigationLink(destination: entryView(entry)) {
                            entryRow(entry, toggle: viewStore
                                        .binding(get: \.isNativeMode, send: ProfileAction.toggleNativeMode))
                            .padding([.top, .bottom])
                        }
                        .navigationBarTitle("") // remove back button title
                    }
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
    func entryRow(_ entry: SettingEntry, toggle: Binding<Bool>) -> some View {
        HStack(spacing: settingEntryIconTitleSpacing) {
            Image(systemName: entry.iconName)
                .frame(width: settingEntrySize)
                .foregroundColor(Color.gray)
            Text(entry.description)
                .font(.system(size: settingEntryFontSize, weight: .semibold))
                .foregroundColor(Color.black)
            Spacer()

//            if entry == .theme {
//                Toggle(isOn: toggle) { }
//                        .toggleStyle(SmallToggleStyle())
//            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: settingDetailSize))
                    .foregroundColor(Color.gray)
//            }
        }
    }
    
    @ViewBuilder
    func entryView(_ entry: SettingEntry) -> some View {
        switch entry {
        case .notification:
            NotificationListView(store: self.store.scope(state: \.notificationState, action: ProfileAction.notification))
//        case .theme:
//            Text(entry.description)
//        case .settings:
//            Text(entry.description)
        case .aboutUs:
            AboutView()
        case .donation:
            Webview(type: .home, url: "https://womenoverseas.com/t/topic/11426")
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
    
//    case account
    case notification
//    case theme
//    case settings
    case aboutUs
    case donation
    
    var description: String {
        get {
            switch self {
//            case .account: return "我的账号"
            case .notification: return "我的通知"
//            case .theme: return "切换到原生模式"
//            case .settings: return "设置"
            case .aboutUs: return "关于我们"
            case .donation: return "捐助"
            }
        }
    }
    
    var iconName: String {
        get {
            switch self {
//            case .account: return "person.crop.artframe"
            case .notification: return "envelope"
            case .donation: return "yensign.circle"
//            case .settings: return "gearshape.2"
            case .aboutUs: return "info.circle"
//            case .theme: return "switch.2"
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
