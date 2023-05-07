//
//  EventHandler.swift
//  WMO
//
//  Created by jia on 2023/5/7.
//

import Foundation
import EventKit

private let eventStateUserDefaultKey = "com.womenoverseas.eventStatesUserDefaultKey"

class EventHandler {

  static let shared = EventHandler()
  private var store = EKEventStore()
  
  public var eventStates: [String: Bool] {
    get {
      UserDefaults.standard.value(forKey: eventStateUserDefaultKey) as? [String: Bool] ?? [:]
    }
    set {
      UserDefaults.standard.set(newValue, forKey: eventStateUserDefaultKey)
    }
  }

  private func requestAccess(_ onFinish: @escaping (Error?) -> Void) {
    store.requestAccess(to: .event) { granted, error in
      if let error = error {
        onFinish(error)
      } else if granted {
        onFinish(nil)
      }
    }
  }

  public func addEvent(_ event: Topic,
                       onFinish: @escaping (Error?) -> Void) {
    self.requestAccess() { [weak self] _ in
      self?.store = EKEventStore()
      guard let store = self?.store else { return }
      let ekEvent = EKEvent(eventStore: store)
      ekEvent.title = event.title
      ekEvent.calendar = store.defaultCalendarForNewEvents
      if let startDate = event.eventStartsAt {
        ekEvent.startDate = Date(string: startDate, format: "yyyy-MM-dd hh:mm:ss")
      }
      if let endDate = event.eventEndsAt {
        ekEvent.endDate = Date(string: endDate, format: "yyyy-MM-dd hh:mm:sss")
      }
      ekEvent.addAlarm(EKAlarm(relativeOffset: -1800)) // 30 mins before
      ekEvent.addAlarm(EKAlarm(relativeOffset: -86400)) // a day before
      do {
        try store.save(ekEvent, span: .thisEvent, commit: true)
        self?.eventStates["\(event.id)"] = true
        onFinish(nil)
      } catch {
        onFinish(error)
      }
    }
  }

  public func containEvent(id: String) -> Bool {
    return eventStates[id] ?? false
  }
}
