//
//  ProfileView.swift
//  WMO
//
//  Created by weijia on 2022/5/24.
//

import Foundation
import SwiftUI

private let leadingSpace: CGFloat = 15
private let settingEntrySize: CGFloat = 22
private let settingEntryFontSize: CGFloat = 14
private let settingEntryIconTitleSpacing: CGFloat = 8
private let settingDetailSize: CGFloat = 15
private let roleFontSize: CGFloat = 13
private let flairSpacing: CGFloat = 5
private let statisticNumberSize: CGFloat = 14
private let statisticTitleSize: CGFloat = 12
private let tagFontSize: CGFloat = 12
private let tagCornerRadius: CGFloat = 2
private let topContentSpacing: CGFloat = 15
private let editCornerRadius: CGFloat = 15
private let bioFontSize: CGFloat = 14
private let bioLineSpacing: CGFloat = 3
private let badgeIconSize: CGFloat = 16
private let statisticSpacing: CGFloat = 15
private let statisticNumberTitleSpacing: CGFloat = 5

private let mockedStatsics = [
    ("访问天数", 50222), ("阅读时间", 5220), ("浏览的话题", 50222), ("已读帖子", 5110), ("关注", 50), ("粉丝", 5), ("连续访问", 51230)
]

struct ProfileView: View {
    
    private func makeEntry(_ entry: SettingEntry) -> some View {
        return Text("")
    }
    
    private func label(_ text: String) -> some View {
        return Text(text)
            .font(.system(size: tagFontSize))
            .foregroundColor(Color("tag_text", bundle: nil))
            .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(Color("tag_bg", bundle: nil))
            .cornerRadius(tagCornerRadius)
    }
    
    var body: some View {
        NavigationView {
            ListWithoutSepatorsAndMargins {
                Group {
                    VStack(alignment: .leading, spacing: topContentSpacing) {
                        HStack {
                            Circle().fill(Color.blue.opacity(0.3)).frame(width: 46, height: 46)
                            Spacer()
                            Button(action: {
                                // Button action
                            }) {
                                RoundedRectangle(cornerRadius: editCornerRadius)
                                    .foregroundColor(Color("button_pink", bundle: nil))
                                    .frame(width: 80, height: 30)
                                    .overlay(
                                        HStack(spacing: 3) {
                                            Image(systemName: "square.and.pencil")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white)
                                            Text("编辑资料")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.white)
                                        })
                            }
                        } // avatar and edit
                        Text("社区参与者")
                            .font(.system(size: roleFontSize))
                        Text(" ❤️🌍🌳👩‍💻 我觉得我还可以抢救一下我觉得我还可以抢救一下我觉得我还可以抢救一下我觉得我还可以抢救一下我觉得我还可以抢救一下我觉得我还可以抢救一下").font(.system(size: bioFontSize))
                            .lineSpacing(bioLineSpacing)
                        HStack(alignment: .center, spacing: flairSpacing) { // myLabel
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: badgeIconSize, weight: .semibold))
                                .foregroundColor(.orange)
                            label("爱好者")
                            label("全年不落")
                            label("社区参与者")
                        }
                    } // Top Section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: statisticSpacing) {
                            ForEach(mockedStatsics, id: \.0) { item in
                                VStack(spacing: statisticNumberTitleSpacing) {
                                    Text("\(item.1)")
                                        .font(.system(size: statisticNumberSize, weight: .semibold, design: .default))
                                        .foregroundColor(Color.gray)
                                    Text(item.0)
                                        .font(.system(size: statisticTitleSize))
                                }
                                Divider() // TODO: remove for last item
                            }
                        }
                    }.padding([.top, .bottom]) // Statistic Section
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
                    } // Entries
                }
            }
            .padding()
            .navigationBarTitle(Text("个人"))
            .navigationBarTitleDisplayMode(.inline)
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

#if DEBUG
struct ProfileView_Previews : PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif
