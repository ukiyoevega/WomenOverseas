//
//  ProfileEditDetailView.swift
//  WMO
//
//  Created by weijia on 2022/7/3.
//

import SwiftUI
import ComposableArchitecture

private let settingEditingFontSize: CGFloat = 14
private let textFieldTextInset: CGFloat = 12
private let toolbarItemSize: CGFloat = 15

// MARK: - ProfileSelectionView

protocol CustomIdentifiable {
  var identifier: Int { get }
}

// MARK: - ProfileEditingView

struct ProfileEditingView: View {
  
  @State var editingText: String
  @State var selectedId: Int
  @State var birthDate: Date
  
  let store: Store<ProfileHeaderState, ProfileHeaderAction>
  let editEntry: EditEntry
  
  @State private var isEditing: Bool = false
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        editingContent(viewStore: viewStore)
        if viewStore.isLoading {
          center {
            ProgressView()
          }
        }
      }
      .toast(message: viewStore.toastMessage ?? "",
             isShowing:  viewStore.binding(get: { state in
        return !(state.toastMessage ?? "").isEmpty
        
      }, send: .dismissToast), duration: Toast.short)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("编辑" + editEntry.description)
            .font(.system(size: toolbarItemSize, weight: .semibold))
            .foregroundColor(Color.black)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            switch editEntry {
            case .title:
              viewStore.send(.update(name: "title", value: viewStore.userResponse.updatedBadgeName(id: selectedId)))
            case .group:
              viewStore.send(.update(name: "flair_group_id", value: selectedId == -1 ? "" : "\(selectedId)"))
            case .date_of_birth:
              viewStore.send(.update(name: "date_of_birth", value: self.birthDate.exactDateString))
            case .name, .bio_raw, .website:
              viewStore.send(.update(name: self.editEntry.rawValue, value: self.editingText))
            case .avatar:
              break
            }
          } label: {
            Text("完成")
              .font(.system(size: toolbarItemSize, weight: .bold))
              .foregroundColor(Color.mainIcon)
          }
        }
      }
    }
  }
  
  @ViewBuilder
  func editingContent(viewStore: ViewStore<ProfileHeaderState, ProfileHeaderAction>) -> some View {
    switch editEntry {
    case .title:
      Form {
        button(id: -1, name: "无")
        ForEach(viewStore.userResponse.badges ?? [], id: \.identifier) { item in
          button(id: item.identifier, name: item.description)
        }
      }
    case .group:
      Form {
        button(id: -1, name: "无")
        ForEach(viewStore.userResponse.user?.groups ?? [], id: \.identifier) { item in
          button(id: item.identifier, name: item.description)
        }
      }
    case .name, .bio_raw, .website:
      Form {
        TextField(editEntry.description, text: $editingText, onEditingChanged: { isEditing = $0 })
          .textFieldStyle(PlainTextFieldStyle())
          .multilineTextAlignment(.leading)
          .accentColor(Color.accentForeground)
          .font(.system(size: settingEditingFontSize, weight: .semibold))
      }
    case .date_of_birth:
      Form {
        VStack {
          DatePicker("Date of Birth", selection: $birthDate, in: ...Date(), displayedComponents: .date)
            .datePickerStyle(WheelDatePickerStyle())
            .environment(\.locale, .init(identifier: "zh-Hans"))
        }
      }
    case .avatar:
      EmptyView()
    }
  }
  
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
}
