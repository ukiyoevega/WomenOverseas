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

struct EventList: View {
  let store: Store<[CategoryList.Category], TopicAction>
  @State private var events: [(String, [Topic])] = []
  @State private var selectedDate = Date()
  @State private var isListMode = false

  private var flatEvents: [Topic] {
    events.reduce([], { partialResult, next in
      partialResult + next.1
    })
  }

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          if !isListMode {
            CustomDatePicker(selectedDate: $selectedDate, events: $events, didSelectDate: {
              proxy.scrollTo(selectedDate.generateDateString(of: "yyyy-MM-dd"), anchor: .top)
            })
            .onAppear {
              if !events.isEmpty { return }
              guard let eventCategory = viewStore.state.first(where: { $0.slug == "events" }) else {
                return
              }
              Task {
                let topics = try await APIService.shared.getAllTopics(of: eventCategory)
                let flatEvents = topics.compactMap { response in
                  response.topicList?.topics?.filter { $0.eventStartsAt != nil }
                }.reduce([], +)
                .sorted(by: {
                  if let end0 = $0.eventEndDate, let end1 = $1.eventEndDate {
                    return end0 < end1
                  }
                  return $0.postsCount > $1.postsCount
                })
                let groupedEvents = Dictionary(grouping: flatEvents, by: { $0.eventStartsAt?.components(separatedBy: " ").first ?? "" })
                events = groupedEvents.sorted(by: { $0.key < $1.key })
                if let nextAvailable = events.last?.0 {
                  selectedDate = Date(string: nextAvailable)
                }
              }
            }
          }
          if events.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
          } else {
            ScrollView {
              ForEach(events, id: \.0) { section in
                Section {
                  ForEach(section.1) { event in
                    EventRow(event: event)
                  }
                } header: {
                  HStack {
                    Text(section.0)
                      .foregroundColor(.black)
                      .font(.system(size: 12, weight: .regular))
                    Spacer()
                  }.padding(.leading, 12)
                }
                .id(section.0)
              }
            }
            .onAppear {
              if let nextAvailable = events.last?.0 {
                proxy.scrollTo(nextAvailable, anchor: .top)
              }
            }
          }
        } // ScrollViewReader
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
    VStack {
      CustomDatePicker(selectedDate: .constant(Date()),
                       events: .constant([]),
                       didSelectDate: { })
      ScrollView {
        List((1...20), id: \.self) { count in
          HStack {
            Text("\(count)")
            EventRow(event: fakeTopic)
          }
        }
      }
    }
  }
}
#endif
