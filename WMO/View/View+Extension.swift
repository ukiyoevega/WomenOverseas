//
//  View+Extension.swift
//  WMO
//
//  Created by weijia on 2022/6/22.
//

import SwiftUI

private let avatarWidth: CGFloat = 40
private let toolbarItemSize: CGFloat = 15

extension View {
  @ViewBuilder
  func webviewLink<Content: View>(_ urlString: String, title: String, @ViewBuilder content: () -> Content) -> some View {
    ZStack {
      NavigationLink(destination: Webview(type: .home, url: urlString, secKey: nil)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text(title)
              .font(.system(size: toolbarItemSize, weight: .semibold))
              .fixedSize(horizontal: false, vertical: true)
              .foregroundColor(Color.black)
          }
        }) {
          EmptyView()
        }
        .opacity(0)
        .navigationBarTitle("") // workaround: remove back button title
      content()
    }
  }
  
  @ViewBuilder
  func attributedText(_ stringWithAttributes: [StringWithAttributes], fontSize: CGFloat) -> some View {
    stringWithAttributes
      .map { pair in
        if #available(iOS 15, *), let link = pair.attrs[.link], let url = link as? URL {
          var attributedString = AttributedString(pair.string)
          attributedString.underlineStyle = .single
          attributedString.link = url
          return Text(attributedString)
            .foregroundColor(Color.red)
            .font(.system(size: fontSize))
        } else {
          return Text(pair.string)
            .foregroundColor(.gray)
            .font(.system(size: fontSize))
        }
      }
      .reduce(Text(""), +)
      .lineSpacing(3)
  }
  
  @ViewBuilder
  func avatar(template: String?, size: CGFloat = avatarWidth) -> some View {
    if let template = template, !template.isEmpty, let escapedString = String("https://womenoverseas.com" + template)
      .replacingOccurrences(of: "{size}", with: "400")
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
       let avatarURL = URL(string: escapedString) {
      if #available(iOS 15.0, *) {
        AsyncImage(url: avatarURL) { image in
          image.resizable()
        } placeholder: {
          Circle().fill(Color.avatarPlaceholder).frame(width: size)
        }
        .frame(width: size, height: size)
        .cornerRadius(size / 2)
      } else {
        CustomAsyncImage(url: avatarURL) { image in
          image.resizable()
        } placeholder: {
          Circle().fill(Color.avatarPlaceholder).frame(width: size)
        }
        .frame(width: size, height: size)
        .cornerRadius(size / 2)
      }
    } else {
      EmptyView()
    }
  }
  
  @ViewBuilder
  func center<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    let view = HStack(alignment: .center) {
      Spacer()
      content()
      Spacer()
    }
    if #available(iOS 15.0, *) {
      view.listRowSeparator(.hidden)
    } else {
      view
    }
  }
  
  @ViewBuilder
  func placeholderedList<Content: View>(isEmpty: Bool,
                                        reachBottom: Bool,
                                        loadMoreAction: @escaping () -> Void,
                                        @ViewBuilder content: @escaping () -> Content) -> some View {
    if (!isEmpty) {
      List {
        Group {
          content()
        }
        if reachBottom {
          center {
            Text("已经到底啦")
              .font(.system(size: 11))
              .foregroundColor(Color(UIColor.lightGray))
              .padding()
          }
          
        } else if !isEmpty {
          /// The pagination is done by appending a invisible rectancle at the bottom of the list, and trigerining the next page load as it appear... hacky way for now
          center { ProgressView() }
            .onAppear { loadMoreAction() }
        }
      }
      .listStyle(PlainListStyle())
    } else {
      if (reachBottom) {
        center {
          Text("这里啥都没有")
            .font(.system(size: 14))
            .foregroundColor(Color(UIColor.lightGray))
            .padding()
        }
      } else {
        Spacer()
        center { ProgressView() }
        Spacer()
      }
    }
  }
}
