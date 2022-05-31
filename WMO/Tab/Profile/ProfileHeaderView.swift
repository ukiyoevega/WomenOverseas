//
//  ProfileHeaderView.swift
//  WMO
//
//  Created by weijia on 2022/5/30.
//

import SwiftUI
import ComposableArchitecture

private let topContentSpacing: CGFloat = 15
private let bioFontSize: CGFloat = 14
private let bioLineSpacing: CGFloat = 3
private let badgeIconSize: CGFloat = 16
private let tagFontSize: CGFloat = 12
private let tagCornerRadius: CGFloat = 2
private let editCornerRadius: CGFloat = 15
private let roleFontSize: CGFloat = 13
private let badgeSpacing: CGFloat = 5
private let avatarWidth: CGFloat = 55
private let flairWidth: CGFloat = 20

struct ProfileHeaderView: View {
    let store: Store<ProfileHeaderState, ProfileHeaderAction>
    
    private func label(_ text: String) -> some View {
        return Text(text)
            .font(.system(size: tagFontSize))
            .foregroundColor(Color.tagText)
            .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(Color.tagBackground)
            .cornerRadius(tagCornerRadius)
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading, spacing: topContentSpacing) {
                HStack {
                    if !viewStore.userResponse.user.avatarTemplate.isEmpty,
                        let escapedString = String("https://womenoverseas.com" + viewStore.userResponse.user.avatarTemplate)
                        .replacingOccurrences(of: "{size}", with: "400")
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let avatarURL = URL(string: escapedString) {
                        ZStack(alignment: .bottomTrailing) {
                            AsyncImage(url: avatarURL) { image in
                                image.resizable()
                            } placeholder: {
                                Circle().fill(Color.blue.opacity(0.3)).frame(width: avatarWidth, height: avatarWidth)
                            }
                            .frame(width: avatarWidth, height: avatarWidth)
                            .cornerRadius(avatarWidth / 2)
                            if let flairPath = viewStore.userResponse.user.flairURL,
                                let escapedString = String("https://womenoverseas.com" + flairPath)
                                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                let flairURL = URL(string: escapedString) {
                                AsyncImage(url: flairURL) { image in
                                    image.resizable()
                                } placeholder: {
                                    Circle().fill(Color.blue.opacity(0.3)).frame(width: flairWidth, height: flairWidth)
                                }
                                .frame(width: flairWidth, height: flairWidth)
                                .cornerRadius(flairWidth / 2)
                            }
                        }
                    }
                    if let username = viewStore.userResponse.user.username {
                        Text(username)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                    Button(action: {
                        // TODO: route to edit page
                    }) {
                        RoundedRectangle(cornerRadius: editCornerRadius)
                            .foregroundColor(Color.accentForeground)
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
                if let title = viewStore.userResponse.user.title {
                    Text(title)
                        .font(.system(size: roleFontSize))
                        .foregroundColor(Color.black)
                }
                if let bio = viewStore.userResponse.user.bioRaw {
                    Text(bio).font(.system(size: bioFontSize))
                        .lineSpacing(bioLineSpacing)
                        .foregroundColor(Color.black)
                }
                HStack(alignment: .center, spacing: badgeSpacing) { // myLabel
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: badgeIconSize, weight: .semibold))
                        .foregroundColor(.orange)
                    ForEach(viewStore.userResponse.userBadges, id: \.id) { userBadge in
                        if let badge = viewStore.userResponse.badges.first(where: { userBadge.badgeId == $0.id }) {
                            label(badge.name)
                        }
                    }
                }
            }
        }
    }
}
