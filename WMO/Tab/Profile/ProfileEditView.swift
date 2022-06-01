//
//  ProfileEditView.swift
//  WMO
//
//  Created by weijia on 2022/5/31.
//

import SwiftUI
import ComposableArchitecture

private let settingDetailIconSize: CGFloat = 15
private let settingDetailFontSize: CGFloat = 12
private let settingTitleFontSize: CGFloat = 14
private let settingEditingFontSize: CGFloat = 14
private let textFieldTextInset: CGFloat = 12
private let toolbarItemSize: CGFloat = 15
private let avatarWidth: CGFloat = 40

struct ProfileEditView: View {

    let store: Store<ProfileHeaderState, ProfileHeaderAction>
    let user: User.User

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ListWithoutSepatorsAndMargins {
                ForEach(EditEntry.allCases) { entry in
                    NavigationLink(destination: ProfileEditingView(editingText: viewStore.userResponse.user.getInfo(entry) ?? "", store: self.store, editEntry: entry)) {
                        entryRow(entry)
                            .padding([.top, .bottom])
                    }
                    .navigationBarTitle("") // remove back button title
                }
            }
            .padding([.leading, .trailing, .top])
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("个人资料")
                        .font(.system(size: toolbarItemSize, weight: .semibold))
                        .foregroundColor(Color.black)
                }
            }
        }
    }

    @ViewBuilder
    func entryRow(_ entry: EditEntry) -> some View {
        HStack {
            Text(entry.description)
                .font(.system(size: settingTitleFontSize, weight: .semibold))
                .foregroundColor(Color.black)
            Spacer()
            if let info = self.user.getInfo(entry) {
                Text(info)
                    .font(.system(size: settingDetailFontSize))
                    .foregroundColor(Color.black)
            }
            if entry == .avatar, !user.avatarTemplate.isEmpty,
               let escapedString = String("https://womenoverseas.com" + user.avatarTemplate)
                .replacingOccurrences(of: "{size}", with: "400")
               .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let avatarURL = URL(string: escapedString) {
                AsyncImage(url: avatarURL) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color.blue.opacity(0.3)).frame(width: avatarWidth, height: avatarWidth)
                }
                .frame(width: avatarWidth, height: avatarWidth)
                .cornerRadius(avatarWidth / 2)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: settingDetailIconSize))
                .foregroundColor(Color.gray)
        }
    }
}

struct ProfileEditingView: View {

    @State var editingText: String = ""

    let store: Store<ProfileHeaderState, ProfileHeaderAction>
    let editEntry: EditEntry

    @State private var isEditing: Bool = false

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                Form {
                    TextField(editEntry.description, text: $editingText, onEditingChanged: { isEditing = $0 })
                        .textFieldStyle(PlainTextFieldStyle())
                        .multilineTextAlignment(.leading)
                        .accentColor(Color.accentForeground)
                        .font(.system(size: settingEditingFontSize, weight: .semibold))
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("编辑" + editEntry.description)
                        .font(.system(size: toolbarItemSize, weight: .semibold))
                        .foregroundColor(Color.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewStore.send(.update(name: self.editEntry.rawValue, value: self.editingText))
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: toolbarItemSize, weight: .bold))
                            .foregroundColor(editingText.isEmpty ? Color.gray.opacity(0.5) : Color.mainIcon)
                    }
                    .disabled(editingText.isEmpty)
                }
            }
        }
    }
}

enum EditEntry: String, CustomStringConvertible, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case avatar
    case name
    case bio
    // case timezone
    case title
    case group // 资历
    case site
    case birthday

    var description: String {
        get {
            switch self {
            case .avatar: return "头像"
            case .name: return "姓名"
            case .bio: return "自我介绍"
            case .title: return "头衔"
            case .group: return "资历"
            case .site: return "网站"
            case .birthday: return "出生日期"
            }
        }
    }

    var placeholder: String? {
        get {
            switch self {
            case .name:
                return "您的全名（可选）"
            case .bio:
                return "自我介绍"
            case .site:
                return "网站"
            default:
                return nil
            }
        }
    }
}

#if DEBUG
struct ProfileEditView_Previews : PreviewProvider {
    static var previews: some View {
        ProfileEditingView(store: Store(initialState: ProfileHeaderState(), reducer: profileHeaderReducer, environment: ProfileEnvironment()), editEntry: .name)
            .hud(isPresented: .constant(true)) {
                Text("hud message")
            }
    }
}
#endif
