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
private let toolbarItemSize: CGFloat = 15

// MARK: - ProfileEditView

struct ProfileEditView: View {
  
  let store: Store<ProfileHeaderState, ProfileHeaderAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ListWithoutSepatorsAndMargins {
        ForEach(EditEntry.supportCases) { entry in
          NavigationLink(destination: destination(viewStore: viewStore, entry: entry)) {
            entryRow(viewStore: viewStore, entry)
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
    case .avatar:
      EmptyView()
    default:
      ProfileEditingView(editingText: resp.user?.getInfo(entry) ?? "",
                         selectedId: entry == .group ? (resp.user?.flairGroupId ?? -1) : resp.selectedBadge.id,
                         birthDate: {
        if let birthday = resp.user?.birthday {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
          return dateFormatter.date(from: birthday) ?? Date()
        }
        return Date()
      }(),
                         store: self.store,
                         editEntry: entry)
    }
  }
  
  @ViewBuilder
  func entryRow(viewStore: ViewStore<ProfileHeaderState, ProfileHeaderAction>, _ entry: EditEntry) -> some View {
    HStack {
      Text(entry.description)
        .font(.system(size: settingTitleFontSize, weight: .semibold))
        .foregroundColor(Color.black)
      Spacer()
      if let info = viewStore.userResponse.user?.getInfo(entry) {
        Text(info)
          .font(.system(size: settingDetailFontSize))
          .foregroundColor(Color.black)
      }
      if entry == .avatar {
        avatar(template: viewStore.userResponse.user?.avatarTemplate)
      }
      Image(systemName: "chevron.right")
        .font(.system(size: settingDetailIconSize))
        .foregroundColor(Color.gray)
    }
  }
}

// MARK: - Extensions

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
  
  static var supportCases: [EditEntry] {
    return [.name, .bio_raw, .title, .group, .website, .date_of_birth]
  }
  
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
    ProfileEditingView(editingText: "test text",
                       selectedId: -1,
                       birthDate: Date(),
                       store: Store(initialState: ProfileHeaderState(), reducer: profileHeaderReducer, environment: ProfileEnvironment()),
                       editEntry: .name)
  }
}
#endif
