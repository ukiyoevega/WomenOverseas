//
//  NotificationCore.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

import ComposableArchitecture

// MARK: - Notification

struct NotificationState: Equatable {
  var notifications: [NotificationMessage] = []
  var toastMessage: String?
}

enum NotificationAction {
  case loadList
  case dismissToast
  case notificationResponse(Result<NotificationResponse, Failure>)
  
}

let notificationReducer = AnyReducer<NotificationState, NotificationAction, ProfileEnvironment> { state, action, environment in
  switch action {
  case .dismissToast:
    state.toastMessage = nil
    
  case .notificationResponse(.success(let response)):
    state.notifications = response.notifications
    
  case .notificationResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .loadList:
    return APIService.shared.getNotifications(.list)
      .receive(on: environment.mainQueue)
      .catchToEffect(NotificationAction.notificationResponse)
  }
  return .none
}
