//
//  DataTask.swift
//  WMO
//
//  Created by weijia on 2022/5/29.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import CommonCrypto

public struct DownloadTask {
  let dataTask: DataTask
  let cancelToken: Int
  
  func cancel() {
    dataTask.cancel(token: cancelToken)
  }
}

final class DataTask {
  private let lock = NSLock()
  private var started = false
  private var completionHandlersStore = [Int: ImageService.Completion]()
  private var currentToken = 0
  
  let task: URLSessionDataTask
  let url: URL
  var data: Data
  
  var onCancelled: ((URL, Int, ImageService.Completion) -> Void)?
  var containsCompletions: Bool {
    lock.lock()
    defer {
      lock.unlock()
    }
    return !completionHandlersStore.isEmpty
  }
  
  init(task: URLSessionDataTask, url: URL) {
    self.task = task
    self.url = url
    self.data = Data()
  }
  
  func resume() {
    if started { return }
    self.started = true
    task.resume()
  }
  
  func addCompletion(_ completion: ImageService.Completion) -> Int {
    lock.lock()
    defer {
      lock.unlock()
    }
    completionHandlersStore[currentToken] = completion
    defer {
      currentToken += 1
    }
    return currentToken
  }
  
  func removeCompletion(_ token: Int) -> ImageService.Completion? {
    lock.lock()
    defer {
      lock.unlock()
    }
    if let completion = completionHandlersStore[token] {
      completionHandlersStore[token] = nil
      return completion
    }
    return nil
  }
  
  func cancel(token: Int) {
    guard let completion = removeCompletion(token) else {
      return
    }
    onCancelled?(url, token, completion)
  }
  
  func didReceiveData(_ data: Data) {
    self.data.append(data)
  }
  
  func complete(result: Result<Data, ImageService.ImageError>) {
    lock.lock()
    switch result {
    case .success(let data):
      for completion in completionHandlersStore.values {
        if let image = UIImage(data: data, scale: completion.scale) {
          completion.handler(.success(image))
        } else {
          completion.handler(.failure(.decodingError))
        }
      }
    case .failure(let error):
      for completion in completionHandlersStore.values {
        completion.handler(.failure(error))
      }
    }
    lock.unlock()
  }
  
}

extension String {
  var sha256: String {
    let data = Data(self.utf8)
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return hash.map { String(format: "%02x", $0) }.joined()
  }
}
