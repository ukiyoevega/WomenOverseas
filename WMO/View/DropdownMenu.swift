//
//  CategoriesView.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import SwiftUI

private let dropdownButtonHeight: CGFloat = 40
private let dropdownIconSize: CGFloat = 9
private let dropdownIconColor: Color = Color.mainIcon
private let dropdownTitleSize: CGFloat = 14
private let menuSpacing: CGFloat = 12
private let dropdownCornerRadius: CGFloat = 15
private let dropdownTitleColor: Color = .black
private let dropdownPlaceholderColor: Color = .gray
private let dropdownBackground: Color = Color.systemGroup
private let dropdownMaxHeight: CGFloat = 250
private let optionsLineHeight: CGFloat = 35

struct DropdownMenu<Item: CustomStringConvertible & Identifiable>: View {
  @State private var shouldShowDropdown = false
  @State private var selectedOption: Item? = nil
  let placeholder: String
  let options: [Item]
  let onOptionSelected: ((_ option: Item) -> Void)?
  
  var body: some View {
    Button(action: {
      self.shouldShowDropdown.toggle()
    }) {
      HStack {
        Text(selectedOption == nil ? placeholder : selectedOption!.description)
          .font(.system(size: dropdownTitleSize, weight: .semibold))
          .foregroundColor(selectedOption == nil ? dropdownPlaceholderColor: dropdownTitleColor)
        Spacer()
        Image(systemName: self.shouldShowDropdown ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
          .resizable()
          .frame(width: dropdownIconSize, height: dropdownIconSize)
          .font(.system(size: dropdownIconSize, weight: .medium))
          .foregroundColor(dropdownIconColor)
      }
    }
    .buttonStyle(PlainButtonStyle())
    .padding()
    .frame(width: .infinity, height: dropdownButtonHeight)
    .background(dropdownBackground)
    .cornerRadius(dropdownCornerRadius)
    .overlay(
      Group {
        if self.shouldShowDropdown {
          List {
            ForEach(self.options) { option in
              Button(action: {
                shouldShowDropdown = false
                selectedOption = option
                self.onOptionSelected?(option)
              }) {
                Text(option.description)
                  .font(.system(size: dropdownTitleSize, weight: .semibold))
                  .foregroundColor(dropdownTitleColor)
              }
              .listRowBackground(dropdownBackground)
            }
          }
          .environment(\.defaultMinListRowHeight, optionsLineHeight)
          .frame(height: min(CGFloat(options.count) * optionsLineHeight, dropdownMaxHeight))
          .background(dropdownBackground)
          .cornerRadius(dropdownCornerRadius)
          .padding(.top, dropdownButtonHeight + menuSpacing)
          .listStyle(PlainListStyle())
        }
      }, alignment: .topLeading)
    .animation(.easeInOut)
  }
}

#if DEBUG
extension User.Badge: Identifiable { }

struct DropdownMenu_Previews: PreviewProvider {
  static let options: [User.Badge] = [
    .init(id: 1, name: "hhssssss"),
    .init(id: 2, name: "fsadfhh"),
    .init(id: 3, name: "h2fs34h"),
    .init(id: 4, name: "hfsfdfdfdfh"),
    .init(id: 5, name: "dasfsaflksmlioerxypwoygfmpso"),
  ]
  
  static var previews: some View {
    DropdownMenu<User.Badge>(
      placeholder: "Day of the week",
      options: options,
      onOptionSelected: { option in
        print(option)
      })
    .padding(.horizontal)
  }
}
#endif
