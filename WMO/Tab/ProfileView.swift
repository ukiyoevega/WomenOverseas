//
//  ProfileView.swift
//  WMO
//
//  Created by weijia on 2022/5/24.
//

import ComposableArchitecture
import SwiftUI

private let leadingSpace: CGFloat = 15
private let settingEntrySize: CGFloat = 22
private let settingEntryFontSize: CGFloat = 14
private let settingEntryIconTitleSpacing: CGFloat = 8
private let settingDetailSize: CGFloat = 15
private let roleFontSize: CGFloat = 13
private let flairSpacing: CGFloat = 5
private let tagFontSize: CGFloat = 12
private let tagCornerRadius: CGFloat = 2
private let topContentSpacing: CGFloat = 15
private let editCornerRadius: CGFloat = 15
private let bioFontSize: CGFloat = 14
private let bioLineSpacing: CGFloat = 3
private let badgeIconSize: CGFloat = 16

struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>
    
    private func label(_ text: String) -> some View {
        return Text(text)
            .font(.system(size: tagFontSize))
            .foregroundColor(Color("tag_text", bundle: nil))
            .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(Color("tag_bg", bundle: nil))
            .cornerRadius(tagCornerRadius)
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ListWithoutSepatorsAndMargins {
                    Group {
                        ProfileSummaryView(store: self.store.scope(state: \.profileSummaryState, action: ProfileAction.summary))
                                            .padding([.top, .bottom]) // 2. Statistic Section
                        ForEach(SettingEntry.allCases) { entry in
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
                            }.padding([.top, .bottom])
                        } // 3. Entries
                    }
                }
                .padding()
                .navigationBarTitle(Text("个人"))
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewStore.send(.summary(.refresh))
                }
            }
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
    case donation
    case settings
    case theme
    case aboutUs
    
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
/*
#if DEBUG
struct ProfileView_Previews : PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif
*/
