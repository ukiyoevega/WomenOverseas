//
//  ProfileHeaderView.swift
//  WMO
//
//  Created by weijia on 2022/5/30.
//

import SwiftUI
import ComposableArchitecture
// Header
private let topContentSpacing: CGFloat = 10
private let bioFontSize: CGFloat = 14
private let editFontSize: CGFloat = 12
private let bioLineSpacing: CGFloat = 3
private let badgeIconSize: CGFloat = 16
private let tagFontSize: CGFloat = 12
private let tagCornerRadius: CGFloat = 2
private let websiteCornerRadius: CGFloat = 8
private let editCornerRadius: CGFloat = 15
private let roleFontSize: CGFloat = 13
private let badgeSpacing: CGFloat = 5
private let avatarWidth: CGFloat = 55
private let flairWidth: CGFloat = 20
private let displaynameSize: CGFloat = 20
private let usernameSize: CGFloat = 15

// Summary
private let statisticNumberSize: CGFloat = 14
private let statisticTitleSize: CGFloat = 12
private let statisticNumberTitleSpacing: CGFloat = 5
private let statisticSpacing: CGFloat = 15

struct ProfileSummaryView: View {
  let store: Store<ProfileSummaryState, ProfileSummaryAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: statisticSpacing) {
          ForEach(viewStore.userResponse.summary.statisticEntries, id: \.0) { item in
            VStack(spacing: statisticNumberTitleSpacing) {
              Text(item.count)
                .font(.system(size: statisticNumberSize, weight: .semibold, design: .default))
                .foregroundColor(Color.gray)
              Text(item.title)
                .font(.system(size: statisticTitleSize))
                .foregroundColor(Color.black)
            }
            if item.title != "发帖量" { // TODO: remove hard-coding
              Divider()
            }
          }
        }
      }
      .toast(message: viewStore.toastMessage ?? "",
             isShowing:  viewStore.binding(get: { state in state.toastMessage?.isEmpty ?? false }, send: .dismissToast),
             duration: Toast.short)
    }
  }
}

struct ProfileHeaderView: View {
  let store: Store<ProfileHeaderState, ProfileHeaderAction>
  @State var enterEdit = false
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading, spacing: topContentSpacing) {
        HStack {
          ZStack(alignment: .bottomTrailing) {
            avatar(template: viewStore.userResponse.user?.avatarTemplate, size: avatarWidth)
            avatar(template: viewStore.userResponse.user?.flairURL, size: flairWidth)
          }
          .onTapGesture {
            self.enterEdit = true
          }
          VStack(alignment: .leading, spacing: badgeSpacing) {
            Text(viewStore.userResponse.user?.name ?? "")
              .font(.system(size: displaynameSize, weight: .semibold)) // displayname
            HStack(spacing: 3) {
              Text(viewStore.userResponse.user?.username ?? "")
                .font(.system(size: usernameSize)) // username
              if let title = viewStore.userResponse.user?.title, !title.isEmpty {
                Text(title)
                  .font(.system(size: tagFontSize))
                  .foregroundColor(Color.gray)
              } // title badge
            }
          }
          .foregroundColor(Color.black)
          Spacer()
          NavigationLink(destination: ProfileEditView(store: self.store), isActive: $enterEdit) {
            RoundedRectangle(cornerRadius: editCornerRadius)
              .foregroundColor(Color.mainIcon)
              .frame(width: 80, height: 30)
              .overlay(
                HStack(spacing: 3) {
                  Image(systemName: "square.and.pencil")
                    .font(.system(size: editFontSize))
                    .foregroundColor(.white)
                  Text("编辑资料")
                    .font(.system(size: editFontSize, weight: .medium))
                    .foregroundColor(.white)
                })
          }
          .navigationBarTitle("") // remove back button title
        } // 1.avatar names edit
        if #available(iOS 15, *),
           let websiteName = viewStore.userResponse.user?.websiteName,
           let website = URL(string: viewStore.userResponse.user?.website ?? "") {
          websiteLabel(name: websiteName, url: website)
        } // 2. website
        if let bio = viewStore.userResponse.user?.bioRaw {
          Text(bio).font(.system(size: bioFontSize))
            .lineSpacing(bioLineSpacing)
            .foregroundColor(Color.black)
        } // 3.bio
        HStack(alignment: .center, spacing: badgeSpacing) {
          Image(systemName: "checkmark.seal")
            .font(.system(size: badgeIconSize, weight: .semibold))
            .foregroundColor(.orange)
          ForEach(viewStore.userResponse.userBadges ?? [], id: \.id) { userBadge in
            if let badge = viewStore.userResponse.badges?.first(where: { userBadge.badgeId == $0.id }) {
              label(badge.name)
            }
          }
          Spacer()
          Button(action: {
            viewStore.send(.togglshowInfo, animation: .default)
          }) {
            Image(systemName: viewStore.showInfo ? "arrowtriangle.up.circle" : "arrowtriangle.down.circle")
              .font(.system(size: 13, weight: .medium))
              .foregroundColor(Color.gray)
          }
        } // 4.badges
        if viewStore.showInfo {
          accountStatistics(viewStore.userResponse.user,
                            badges: viewStore.userResponse.badges)
        } // 5.account info
      }
      .toast(message: viewStore.toastMessage ?? "",
             isShowing:  viewStore.binding(get: { state in
        return !(state.toastMessage ?? "").isEmpty

      }, send: .dismissToast),
             duration: Toast.short)
    }
  }

  private func label(_ text: String) -> some View {
    return Text(text)
      .font(.system(size: tagFontSize))
      .foregroundColor(Color.tagText)
      .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
      .background(Color.tagBackground)
      .cornerRadius(tagCornerRadius)
  }

  @available(iOS 15, *)
  private func websiteLabel(name: String, url: URL) -> some View {
    let globeText = Text(Image(systemName: "globe")).foregroundColor(Color.globeBlue)
    var astr = AttributedString(" \(name)")
    astr.underlineStyle = .none
    astr.setAttributes(AttributeContainer.foregroundColor(.gray))
    astr.link = url
    return (globeText + Text(astr))
      .font(.system(size: tagFontSize))
      .padding(.init(top: 3, leading: 6, bottom: 3, trailing: 6))
      .background(Color.globeBlue.opacity(0.3))
      .cornerRadius(websiteCornerRadius)
  }

  private func accountStatistics(_ user: User.User?, badges: [User.Badge]?) -> some View {
    let result: [(String, String?)] = [
      ("加入日期", user?.createdAt?.readableAgo),
      ("最后一个帖子", user?.lastPostedAt?.readableAgo),
      ("最后活动", user?.lastSeenAt?.readableAgo),
      ("浏览量", {
        if let count = user?.viewCount {
          return "\(count)"
        } else {
          return nil
        }
      }()),
      ("信任级别", {
        if let level = user?.trustLevel {
          return badges?.first(where: { $0.id == level })?.name
        } else {
          return nil
        }
      }()),
    ]
    let statistic: [(String, String)] = result.compactMap { title, info in
      if let info = info { return (title, info) }
      return nil
    }
    return VStack {
      Divider()
      statistic.map { title, info in
        Text("\(title) ")
          .font(.system(size: statisticTitleSize))
          .foregroundColor(Color.black)
        +
        Text("\(info)   ")
          .font(.system(size: statisticTitleSize))
          .foregroundColor(Color.gray)
      }.reduce(Text(""), +)
      Divider()
    }
  }
}
