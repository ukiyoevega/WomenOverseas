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

// MARK: - ProfileEditView

struct ProfileEditView: View {

    let store: Store<ProfileHeaderState, ProfileHeaderAction>
    let user: User.User // TODO: remove

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ListWithoutSepatorsAndMargins {
                ForEach(EditEntry.allCases) { entry in
                    NavigationLink(destination: destination(viewStore: viewStore, entry: entry)) {
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
    func destination(viewStore: ViewStore<ProfileHeaderState, ProfileHeaderAction>, entry: EditEntry) -> some View {
        let resp = viewStore.userResponse
        switch entry {
        case .name, .bio_raw, .website:
            ProfileEditingView(editingText: resp.user.getInfo(entry) ?? "", store: self.store, editEntry: entry)
        case .title:
            ProfileSelectionView(selectedId: resp.selectedBadge.id, items: resp.badges ?? [], updateAction: { selectedId in
                viewStore.send(.update(name: entry.rawValue, value: viewStore.userResponse.updatedBadgeName(id: selectedId)))
            })
        case .group:
            ProfileSelectionView(selectedId: resp.user.flairGroupId ?? -1, items: resp.user.groups ?? [], updateAction: { selectedId in
                viewStore.send(.update(name: "flair_group_id", value: selectedId == -1 ? "" : "\(selectedId)"))
            })
        case .date_of_birth:
            ProfileDateView(updateAction: { dateString in
                viewStore.send(.update(name: "date_of_birth", value: dateString))
            })
        case .avatar:
            EmptyView()
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

// MARK: - ProfileSelectionView

fileprivate struct ProfileSelectionView<Item: CustomStringConvertible & CustomIdentifiable>: View {

    @State var selectedId: Int
    let items: [Item]
    let updateAction: (Int) -> Void

    func button(id: Int, name: String) -> some View {
        Button {
            self.selectedId = id
        } label: {
            HStack {
                Text(name)
                    .foregroundColor(Color.black)
                    .font(.system(size: settingEditingFontSize, weight: .semibold))
                Spacer()
                if (self.selectedId == id) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .font(.system(size: toolbarItemSize, weight: .bold))
                        .frame(width: 20, height: 15)
                        .foregroundColor(Color.mainIcon)

                }
            }
        }
    }

    public var body: some View {
        Form {
            button(id: -1, name: "无")
            ForEach(items, id: \.identifier) { item in
                button(id: item.identifier, name: item.description)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("编辑头衔")
                    .font(.system(size: toolbarItemSize, weight: .semibold))
                    .foregroundColor(Color.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    updateAction(self.selectedId)
                } label: {
                    Text("完成")
                        .font(.system(size: toolbarItemSize, weight: .bold))
                        .foregroundColor(Color.mainIcon)
                }
            }
        }
    }
}

// MARK: - ProfileDateView

fileprivate struct ProfileDateView: View {
    @State var birthDate = Date()
    let updateAction: (String) -> Void

    var body: some View {
        Form {
            VStack {
                DatePicker("Date of Birth", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .environment(\.locale, .init(identifier: "zh-Hans"))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("编辑生日")
                    .font(.system(size: toolbarItemSize, weight: .semibold))
                    .foregroundColor(Color.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    updateAction(self.birthDate.exactDateString)
                } label: {
                    Text("完成")
                        .font(.system(size: toolbarItemSize, weight: .bold))
                        .foregroundColor(Color.mainIcon)
                }
            }
        }
    }
}

// MARK: - ProfileEditingView

fileprivate struct ProfileEditingView: View {

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
                /*
                .hud(isPresented: viewStore.binding(get: \.successMessage, send: .dismissToast)) {
                    Label(viewStore.successMessage, systemImage: "star.fill")
                }
                 */
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
                        Text("完成")
                            .font(.system(size: toolbarItemSize, weight: .bold))
                            .foregroundColor(editingText.isEmpty ? Color.gray.opacity(0.5) : Color.mainIcon)
                    }
                    .disabled(editingText.isEmpty)
                }
            }
        }
    }
}

// MARK: - Extensions

fileprivate protocol CustomIdentifiable {
    var identifier: Int { get }
}

extension User.Badge: CustomStringConvertible, CustomIdentifiable {
    var identifier: Int { self.id }
    var description: String { self.name }
}
extension User.FlairGroup: CustomStringConvertible, CustomIdentifiable {
    var identifier: Int { self.id }
    var description: String { self.name }
}

enum EditEntry: String, CustomStringConvertible, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case avatar
    case name
    case bio_raw
    // case timezone
    case title
    case group // 资历
    case website
    case date_of_birth

    var description: String {
        get {
            switch self {
            case .avatar: return "头像"
            case .name: return "姓名"
            case .bio_raw: return "自我介绍"
            case .title: return "头衔"
            case .group: return "资历"
            case .website: return "网站"
            case .date_of_birth: return "出生日期"
            }
        }
    }

    var placeholder: String? {
        get {
            switch self {
            case .name:
                return "您的全名（可选）"
            case .bio_raw:
                return "自我介绍"
            case .website:
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
            .hud(isPresented: .constant("safs")) {
                Text("hud message")
            }
    }
}
#endif
