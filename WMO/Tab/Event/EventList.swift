//
//  EventList.swift
//  WMO
//
//  Created by jia on 2023/4/8.
//

import SwiftUI
import ComposableArchitecture
import Combine

private let eventListBackground = Color(hex: "FBFBFB")
private let navigationTitleSize: CGFloat = 18
private let eventRowPadding: CGFloat = 4

struct EventList: View {
  let store: Store<[CategoryList.Category], TopicAction>
  @State private var events: [Topic] = []
  @State private var selectedDate = Date()
  @State private var isListMode = false

  private var currentDateEvents: [Topic] {
    return events.filter({ topic in
      guard let startDate = topic.eventStartDate else {
        return false
      }
      return Calendar.current.isDate(startDate, inSameDayAs: selectedDate)
    })
  }

  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView {
        if isListMode {
          ForEach(events) { event in
            EventRow(event: event)
          }.padding([.top], eventRowPadding)
        } else {
          CustomDatePicker(selectedDate: $selectedDate, events: $events)
          if events.isEmpty {
            center { ProgressView() }
          } else {
            ForEach(currentDateEvents) { event in
              EventRow(event: event)
            }.padding([.top], eventRowPadding)
          }
        }
      }
      .onAppear {
        if !events.isEmpty { return }
        guard let eventCategory = viewStore.state.first(where: { $0.slug == "events" }) else {
          return
        }
        Task {
          let topics = try await APIService.shared.getAllTopics(of: eventCategory)
          events = topics.compactMap { response in
            response.topicList?.topics?.filter { $0.eventStartsAt != nil }
          }.reduce([], +)
          .sorted(by: {
            if let end0 = $0.eventEndDate, let end1 = $1.eventEndDate {
              return end0 > end1
            }
            return $0.postsCount > $1.postsCount
          })
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text("活动日历")
            .foregroundColor(Color.eventTint)
            .font(.system(size: navigationTitleSize, weight: .bold))
        }
      }
      .background(eventListBackground)
      .navigationBarItems(
        trailing:
          HStack(spacing: 0) {
            Button(action: {
              isListMode = !isListMode
            }) {
              Image(systemName: isListMode ? "calendar" : "list.bullet.rectangle")
                .font(.system(size: 14, weight: .medium))
            }.foregroundColor(Color.mainIcon)
            NavigationLink(destination: Text("add event")) {
              Image(systemName: "plus.circle")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.mainIcon)
            }
          }
      )
    }
  }
}

#if DEBUG
struct EventList_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      CustomDatePicker(selectedDate: .constant(Date()),
                       events: .constant([]))
    }
  }
}
#endif
