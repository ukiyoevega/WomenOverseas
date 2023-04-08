//
//  AsyncAvatarImage.swift
//  WMO
//
//  Created by weijia on 2022/5/29.
// https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/

import SwiftUI

public enum AsyncImageStatus {
  case empty
  case success(Image)
  case failure(Error)
  
  var image: Image? {
    guard case .success(let image) = self else { return nil }
    return image
  }
  
  var error: Error? {
    guard case .failure(let error) = self else { return nil }
    return error
  }
}

// MARK: - AsyncImage

public struct CustomAsyncImage<Content: View>: View {
  enum LoadState {
    case none
    case loading
    case loaded
  }
  @ObservedObject var loader: ImageLoader
  var content: ((AsyncImageStatus) -> Content)?
  @State var loadState: LoadState = .none
  @ViewBuilder
  var contentOrImage: some View {
    if let content = content {
      content(loader.asyncImageStatus)
    } else if let image = loader.asyncImageStatus.image {
      image
    } else {
      Color(.secondarySystemBackground)
    }
  }
  
  public var body: some View {
    contentOrImage
      .onAppear {
        if loadState == .none {
          loader.loadImage { succeed in
            loadState = succeed ? .loaded : .none
          }
          loadState = .loading
        }
      }
    // TODO: cancel logic
    //            .onDisappear { loader.cancelDownload() }
  }
  
  public init(url: URL, scale: CGFloat = 1) where Content == Image {
    print("avatarURL \(url)")
    loader = ImageLoader(url: url, scale: scale)
  }
  
  public init<Img: View, Placeholder: View>(url: URL?, scale: CGFloat = 1,
                                            content: @escaping (Image) -> Img,
                                            placeholder: @escaping () -> Placeholder) where Content == _ConditionalContent<Img, Placeholder> {
    self.init(url: url, scale: scale) { phase in
      if let image = phase.image {
        content(image)
      } else {
        placeholder()
      }
    }
  }
  
  public init(url: URL?, scale: CGFloat = 1,
              transaction: Transaction = Transaction(),
              @ViewBuilder content: @escaping (AsyncImageStatus) -> Content) {
    self.content = content
    loader = ImageLoader(url: url, scale: scale)
  }
}

// MARK: - ImageLoader

final class ImageLoader: ObservableObject {
  @Published var asyncImageStatus = AsyncImageStatus.empty
  private let scale: CGFloat
  private let url: URL?
  private var downloadTask: DownloadTask?
  
  init(url: URL?, scale: CGFloat) {
    self.url = url
    self.scale = scale
  }
  
  deinit {
    cancelDownload()
  }
  
  func loadImage(completion: @escaping (Bool) -> Void) {
    guard let url = url, asyncImageStatus.image == nil else { return }
    downloadTask = ImageService.shared.fetchImage(url: url, scale: scale) {
      [weak self] result in
      guard let self = self else { return }
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        switch result {
        case .success(let image):
          self.asyncImageStatus = .success(Image(uiImage: image))
          completion(true)
        case .failure(let error):
          if error.isCanceled { return }
          self.asyncImageStatus = .failure(error)
          completion(false)
        }
        
        self.downloadTask = nil
      }
    }
  }
  
  func cancelDownload() {
    downloadTask?.cancel()
  }
}
