//
//  ImageDownloader.swift
//  HSImageDownloader
//
//  Created by haoshuai on 2020/3/14.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import Foundation

typealias TaskCallback = (_ block:(Result<Data,Error>))->Void

struct DownloadTask {
    
    var task: URLSessionDownloadTask
    
    var callback: TaskCallback
    
    func cancel() {
        task.cancel()
    }
}


open class ImageDownloader: NSObject {
    
    // 实现优先队列 - 可以不用实现
    
    public static let `default` = ImageDownloader()
    
    private var tasks = Dictionary<URL,DownloadTask>()
    
    
    private var failureErrorTask = Dictionary<URL,Error>()
    
    private let elock = NSLock()
    
    private let slock = NSLock()
    
    private func addErrorTask(key: URL, error: Error) {
        elock.lock()
        defer {
            elock.unlock()
        }
        failureErrorTask[key] = error
    }
    
    private func removeErrorTask(key: URL) {
        elock.lock()
        defer {
            elock.unlock()
        }
        _ = failureErrorTask.removeValue(forKey: key)
    }
    
    private var successTask = Dictionary<URL,URL>()
    
    private func addSuccessTask(key: URL, location: URL) {
        slock.lock()
        defer {
            slock.unlock()
        }
        successTask[key] = location
    }
    
    private func removeSuccessTask(key: URL) {
        slock.lock()
        defer {
            slock.unlock()
        }
        _ = successTask.removeValue(forKey: key)
    }
    
    
    private lazy var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        return configuration
    }()
    
    private let maxConcurrentOperationCount: Int
    
    private lazy var session: URLSession = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        return session
    }()
    
    public init(maxConcurrentOperationCount: Int = 10) {
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
    
    private func imageRequestWithURL(_ url: URL) -> URLRequest {
        let request = URLRequest.init(url: url)
        return request
    }
    
    open func downloadImage(request: URLRequest) {
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    open func downloadImage(url: URL) {
        if ImageCache.default.cache(request: url) {
            return
        }
        let request = imageRequestWithURL(url)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    open func downloadImage(urls: [URL]) {
        for url in urls {
            if ImageCache.default.cache(request: url) {
                continue
            }
            
            let request = imageRequestWithURL(url)
            let task = session.downloadTask(with: request)
            task.resume()
        }
    }
    
}

extension ImageDownloader: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 任务完成
        
        
        guard let requestUrl = downloadTask.currentRequest?.url else {
            fatalError("下载失败")
        }
        
        debugPrint("任务完成",Thread.current)
        do {
            let url = try ImageCache.default.storage(request: requestUrl, path: location)
//            successTask[requestUrl] = url
            self.addSuccessTask(key: requestUrl, location: url)
        } catch {
            fatalError("任务错误")
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let requestUrl = task.currentRequest?.url else {
            fatalError("下载失败")
        }
        if let error = error {
            self.addErrorTask(key: requestUrl, error: error)
            debugPrint("任务失败")
        } else {
            debugPrint("任务成功",Thread.current)
        }
        
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        //Tells the URL session that the session has been invalidated. 告诉URL会话该会话已失效。
    }
    


    
}
