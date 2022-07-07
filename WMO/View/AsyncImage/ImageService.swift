//
//  ImageService.swift
//  WMO
//
//  Created by weijia on 2022/5/29.
//

import CommonCrypto
import UIKit

struct Cache: MemoryCostValue {
    enum CacheType: Equatable {
        case downloaded
        case resumable(String?)
    }
    var data: Data
    var cacheType: CacheType
    
    var memoryCost: Int {
        return data.count
    }
}

public final class ImageService: NSObject {
    public enum ImageError: Error {
        case decodingError
        case taskCancel
        case downloadError(Error)
        case invalidURLResponse
        
        public var isCanceled: Bool {
            guard case .taskCancel = self else { return false }
            return true
        }
    }
    
    struct Completion {
        let scale: CGFloat
        let handler: (Result<UIImage, ImageError>) -> Void
    }
    
    public static let shared = ImageService()
    
    private let memoryCache = LRUCache<URL, Cache>(30 * 1024 * 1024)
    private let lock = NSLock()
    private let session: URLSession
    private let sessionDelegat = SessionDelegate()
    private let ioQueue: DispatchQueue
    
    private override init() {
        ioQueue = DispatchQueue(label: "com.womenoverseas.CustomAsyncImage.ioQueue")
        session = URLSession(configuration: .ephemeral, delegate: sessionDelegat, delegateQueue: nil)
        super.init()
        sessionDelegat.onTaskFinished = { [weak self] url, cache in
            self?.storeToMemory(url: url, cache: cache)
            self?.storeToDisk(value: cache.data, forKey: url.absoluteString)
        }
    }
    
    // MARK: - Downloading
    
    public func fetchImage(url: URL, scale: CGFloat, completionHandler: @escaping (Result<UIImage, ImageError>) -> Void) -> DownloadTask? {
        if let image = fetchImageInMemory(url: url, scale: scale) {
            completionHandler(.success(image))
            return nil
        }
        if isDiskCached(for: url.absoluteString) {
            fetchFromDisk(forKey: url.absoluteString) { data in
                if let data = data {
                    self.storeToMemory(url: url, cache: Cache(data: data, cacheType: .downloaded))
                    if let image = UIImage(data: data, scale: scale) {
                        completionHandler(.success(image))
                        return
                    }
                }
                completionHandler(.failure(.decodingError))
            }
            return nil
        } else {
            let task = addDownloadTask(url: url, completion: Completion(scale: scale, handler: completionHandler))
            task.dataTask.resume()
            return task
        }
    }
    
    private func addDownloadTask(url: URL, completion: Completion) -> DownloadTask {
        let downloadTask: DownloadTask
        if let existingTask = sessionDelegat.task(for: url) {
            downloadTask = sessionDelegat.append(existingTask, completion: completion)
        } else {
            let sessionDataTask: URLSessionDataTask
            lock.lock()
            defer {
                lock.unlock()
            }
            if let cache = memoryCache[url], case .resumable(let validator) = cache.cacheType {
                var urlRequest = URLRequest(url: url)
                var headers = urlRequest.allHTTPHeaderFields ?? [:]
                headers["Range"] = "bytes=\(cache.memoryCost)-"
                headers["If-Range"] = validator
                urlRequest.allHTTPHeaderFields = headers
                sessionDataTask = session.dataTask(with: urlRequest)
                downloadTask = sessionDelegat.addTask(sessionDataTask, url: url, data: cache.data, completion: completion)
            } else {
                downloadTask = sessionDelegat.addTask(session.dataTask(with: url), url: url, completion: completion)
            }
        }
        return downloadTask
    }

    // MARK: - Memory Cache

    private func storeToMemory(url: URL, cache: Cache) {
        lock.lock()
        memoryCache[url] = cache
        lock.unlock()
    }
    
    private func fetchImageInMemory(url: URL, scale: CGFloat) -> UIImage? {
        lock.lock()
        defer {
            lock.unlock()
        }
        if let data = memoryCache[url]?.data, let image = UIImage(data: data, scale: scale) {
            return image
        } else {
            return nil
        }
    }
    
    // MARK: - Disk Cache
    
    lazy var folderURL: URL = {
        let url: URL
        do {
            url = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
        } catch let error {
            fatalError("\(error)")
        }
        let folderUrl = url.appendingPathComponent("com.zeu.cache", isDirectory: true)
        if FileManager.default.fileExists(atPath: folderUrl.path) {
            return folderUrl
        }
        
        do {
            try FileManager.default.createDirectory(
                atPath: folderUrl.path,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error {
            print(error)
        }
        return folderUrl
    }()

    private func isDiskCached(for key: String) -> Bool {
        FileManager.default.fileExists(atPath: cacheFileURL(forKey: key).path)
    }
    
    private func cacheFileURL(forKey key: String) -> URL {
        folderURL.appendingPathComponent(key.sha256)
    }
    
    private func storeToDisk(value: Data, forKey key: String) {
        ioQueue.async {
            let fileURL = self.cacheFileURL(forKey: key)
            let now = Date()
            let attributes: [FileAttributeKey : Any] = [.creationDate: Date(timeIntervalSince1970: ceil(now.timeIntervalSince1970))]
            FileManager.default.createFile(atPath: fileURL.path, contents: value, attributes: attributes)
        }
    }
    
    private func fetchFromDisk(forKey key: String, completion: @escaping (Data?) -> Void) {
        ioQueue.async {
            let fileManager = FileManager.default
            let fileURL = self.cacheFileURL(forKey: key)
            let filePath = fileURL.path
            guard fileManager.fileExists(atPath: filePath) else {
                completion(nil)
                return
            }
            do {
                let data = try Data(contentsOf: fileURL)
                completion(data)
            } catch {
                completion(nil)
            }
        }
    }
}

// MAKR: - SessionDelegate

final class SessionDelegate: NSObject {
    var tasks: [URL: DataTask] = [:]
    var onTaskFinished: ((URL, Cache) -> Void)?
    var lock = NSLock()
    
    func addTask(_ dataTask: URLSessionDataTask, url: URL, data: Data? = nil, completion: ImageService.Completion) -> DownloadTask {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        let task = DataTask(task: dataTask, url: url)
        if let data = data {
            task.data = data
        }
        task.onCancelled = { [weak self] url, token, completion in
            guard let self = self, let task = self.task(for: url) else {
                return
            }
            
            let error = ImageService.ImageError.taskCancel
            completion.handler(.failure(error))
            if !task.containsCompletions {
                let dataTask = task.task
                
                self.lock.lock()
                dataTask.cancel()
                self.tasks[url] = nil
                self.lock.unlock()
                
            }
        }
        let token = task.addCompletion(completion)
        tasks[url] = task
        return DownloadTask(dataTask: task, cancelToken: token)
    }
    
    func append(_ task: DataTask, completion: ImageService.Completion) -> DownloadTask {
        let token = task.addCompletion(completion)
        return DownloadTask(dataTask: task, cancelToken: token)
    }
    
    func task(for url: URL) -> DataTask? {
        lock.lock()
        defer {
            lock.unlock()
        }
        return tasks[url]
    }
    
    func task(for task: URLSessionTask) -> DataTask? {
        guard let url = task.originalRequest?.url, let dataTask = self.task(for: url) else {
            return nil
        }
        return dataTask
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse else {
            onCompleted(task: dataTask, error: .invalidURLResponse)
            completionHandler(.cancel)
            return
        }
        let httpStatusCode = httpResponse.statusCode
        guard (200..<400).contains(httpStatusCode) else {
            onCompleted(task: dataTask, error: .invalidURLResponse)
            completionHandler(.cancel)
            return
        }
        if httpStatusCode == 200, let task = self.task(for: dataTask) {
            task.data = Data()
        }
        completionHandler(.allow)
    }
        
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = self.task(for: dataTask) else {
            return
        }
        task.didReceiveData(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            onCompleted(task: task, error: .downloadError(error))
            return
        }
        onCompleted(task: task)
    }
    
    func onCompleted(task: URLSessionTask, error: ImageService.ImageError? = nil) {
        guard let dataTask = self.task(for: task) else {
            return
        }
        onCompleted(dataTask: dataTask, error: error)
    }
    
    func onCompleted(dataTask: DataTask, error: ImageService.ImageError? = nil) {
        lock.lock()
        tasks[dataTask.url] = nil
        lock.unlock()
        if error == nil {
            dataTask.complete(result: .success(dataTask.data))
            onTaskFinished?(dataTask.url, Cache(data: dataTask.data, cacheType: .downloaded))
        } else {
            guard !dataTask.data.isEmpty,
                  let response = dataTask.task.response as? HTTPURLResponse,
                  dataTask.data.count < response.expectedContentLength,
                  response.statusCode == 200 || response.statusCode == 206,
                  let acceptRanges = response.allHeaderFields["Accept-Ranges"] as? String,
                  acceptRanges.lowercased() == "bytes"
            else {
                return
            }
            let headers = response.allHeaderFields
            if let validator = (headers["ETag"] ?? headers["Etag"] ?? headers["Last-Modified"]) as? String {
                onTaskFinished?(dataTask.url, Cache(data: dataTask.data, cacheType: .resumable(validator)))
            } else {
                onTaskFinished?(dataTask.url, Cache(data: dataTask.data, cacheType: .resumable(nil)))
            }
        }
    }
}

