//
//  EventRow.swift
//  WMO
//
//  Created by jia on 2023/4/21.
//

import SwiftUI

private let eventRowCornerRadius: CGFloat = 6
private let eventRowShadowRadius: CGFloat = 17
private let eventRowShadowOffsetY: CGFloat = 4
private let eventRowShadowOpacity: CGFloat = 0.05
private let eventRowPadding: CGFloat = 4
private let titleFontSize: CGFloat = 14
private let itemVerticalSpacing: CGFloat = 9
private let unsignBackgroundColor: Color = Color(hex: "9EB83B")
private let signedTextColor: Color = .white
private let unsignTextColor: Color = .white
private let checkDetailTextColor = Color(hex: "BDBDBD")
private let invalidTextColor = Color(hex: "8B8B8B")
private let buttonCornerRadius: CGFloat = 10

struct EventRow: View {
  private let event: Topic
  private let invalid: Bool
  init(event: Topic) {
    self.event = event
    if let endDate = event.eventEndDate {
      self.invalid = endDate < Date()
    } else {
      self.invalid = true
    }
  }

  var body: some View {
    NavigationLink(destination: Webview(type: .home, url: "https://womenoverseas.com/t/topic/\(event.id)", secKey: nil)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(event.title)
            .font(.system(size: 15, weight: .semibold))
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color.black)
        }
      }) {
        HStack(spacing: 0) {
          Rectangle()
            .foregroundColor(Color.eventTint)
            .frame(width: 3)
          VStack(alignment: .leading, spacing: itemVerticalSpacing) {
            Text(event.title)
              .multilineTextAlignment(.leading)
              .foregroundColor(invalid ? invalidTextColor : .black)
              .font(.system(size: titleFontSize, weight: .bold))
            HStack {
              (Text(Image(systemName: "clock")) + Text(" 活动时间：\(event.eventStartsAt ?? "")"))
                .foregroundColor(invalid ? invalidTextColor : .black)
                .font(.system(size: titleFontSize))
              /*
              (Text(Image(systemName: "checkmark")) + Text("已参与"))
                .font(.system(size: titleFontSize))
                .foregroundColor(signedTextColor)
                .padding(.init(top: 4, leading: 10, bottom: 4, trailing: 10))
                .background(Color.eventTint)
                .cornerRadius(buttonCornerRadius)
               */
              Spacer()
              (Text("查看详情") + Text(Image(systemName: "chevron.right")))
                .font(.system(size: titleFontSize))
                .foregroundColor(checkDetailTextColor)
            }
          }
          .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
          .background(Color.white)
        }
        .cornerRadius(eventRowCornerRadius)
        .shadow(color: .black.opacity(eventRowShadowOpacity), radius: eventRowShadowRadius, y: eventRowShadowOffsetY)
        .padding(EdgeInsets(top: eventRowPadding, leading: eventRowPadding * 2, bottom: eventRowPadding, trailing: eventRowPadding * 2))
      }
  }
}
