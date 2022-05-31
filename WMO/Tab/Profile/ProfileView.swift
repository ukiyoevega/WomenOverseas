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
                            HStack(spacing: settingEntryIconTitleSpacing) {
                                Image(systemName: entry.iconName)
                                    .frame(width: settingEntrySize)
                                    .foregroundColor(Color.gray)
                                Text(entry.description)
                                    .font(.system(size: settingEntryFontSize, weight: .semibold))
                                    .foregroundColor(Color.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: settingDetailSize))
                                    .foregroundColor(Color.gray)
                            }
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("个人").foregroundColor(Color.black)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewStore.send(.summary(.refresh))
                viewStore.send(.header(.refresh))
            }
        }
    }
    
    @ViewBuilder
    func entryView(_ entry: SettingEntry) -> some View {
        switch entry {
        case .account:
            Text(entry.description)
        case .notification:
            Text(entry.description)
        case .theme:
            Text(entry.description)
        case .settings:
            Text(entry.description)
        case .aboutUs:
            Text(entry.description)
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
            ScrollView {
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
    
    case account
    case notification
    case theme
    case settings
    case aboutUs
    case donation
    
    var description: String {
        get {
            switch self {
            case .account: return "我的账号"
            case .notification: return "我的通知"
            case .donation: return "捐助"
            case .settings: return "设置"
            case .aboutUs: return "关于我们"
            case .theme: return "切换到原生模式"
            }
        }
    }
    
    var iconName: String {
        get {
            switch self {
            case .account: return "person.crop.artframe"
            case .notification: return "envelope"
            case .donation: return "yensign.circle"
            case .settings: return "gearshape.2"
            case .aboutUs: return "info.circle"
            case .theme: return "switch.2"
            }
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
