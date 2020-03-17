//
//  ImageDownloader.swift
//  HSImageDownloader
//
//  Created by haoshuai on 2020/3/14.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import Foundation
import UIKit

public typealias TaskCallback = (_ block:(Result<UIImage,Error>))->Void

struct DownloadTask {
    
    var task: URLSessionDownloadTask
    
    var callback: TaskCallback?
    
    func cancel() {
        task.cancel()
    }
}


public class ImageDownloader: NSObject {
    
    // 实现优先队列 - 可以不用实现
    
    public static let `default` = ImageDownloader()
    
    private var tasks = Dictionary<URL,DownloadTask>()
    
    private let tlock = NSLock()
    
    private func addTask(key: URL, task: DownloadTask) {
        tlock.lock()
        defer {
            tlock.unlock()
        }
        tasks[key] = task
    }
    
    private func removeTask(key: URL) {
        tlock.lock()
        defer {
            tlock.unlock()
        }
        _ = tasks[key] = tasks.removeValue(forKey: key)
    }
    
    private func task(key: URL) -> DownloadTask? {
        tlock.lock()
        defer {
            tlock.unlock()
        }
        let task = tasks[key]
        return task
    }
    
    // 缓存结果是非常耗内存的这里 可以返回文件url
    private var result = Dictionary<URL,Result<UIImage,Error>>()
    
    private let rlock = NSLock()
    
    private func addResult(key: URL, result: Result<UIImage,Error>) {
        rlock.lock()
        defer {
            rlock.unlock()
        }
        self.result[key] = result
    }
    
    private func removeResult(key: URL) {
        rlock.lock()
        defer {
            rlock.unlock()
        }
        result.removeValue(forKey: key)
    }
    
    private func result(key: URL) -> Result<UIImage,Error>? {
        rlock.lock()
        defer {
            rlock.unlock()
        }
        return result[key]
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
        var request = URLRequest.init(url: url)
        // this will make sure the request always returns the cached image
        request.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataDontLoad
        request.httpShouldHandleCookies = false
        request.httpShouldUsePipelining = true
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }
    
    open func downloadImage(request: URLRequest) {
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    open func downloadImage(url: URL,callback: (TaskCallback)?) {
        
        if ImageCache.default.cache(request: url) {
            if let image = ImageCache.default.cache(request: url) {
                let result: Result<UIImage,Error> = .success(image)
                debugPrint("已经缓存结果了")
                callback?(result)
            } else {
                fatalError("这里的逻辑不应存在")
            }
            return
        }
        
        if let _ = self.task(key: url) {
            debugPrint("已经存在任务")
            return
        }
        
        let request = imageRequestWithURL(url)
        let task = session.downloadTask(with: request)
        
        debugPrint("下载任务",task,url)
        let downloadTask = DownloadTask(task: task, callback: callback)
        self.addTask(key: url, task: downloadTask)
        task.resume()
        
    }
    
    // 进行数据与下载 不用回调是最好的
    open func downloadImage(urls: [URL],callback: (TaskCallback)?) {
        for url in urls {
            if ImageCache.default.cache(request: url) {
                continue
            }
            
            let request = imageRequestWithURL(url)
            let task = session.downloadTask(with: request)
            
            let downloadTask = DownloadTask(task: task, callback: callback)
            self.addTask(key: url, task: downloadTask)
            
            task.resume()
        }
    }
    
}

extension ImageDownloader: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 任务完成
        guard let requestUrl = downloadTask.currentRequest?.url,let task = self.task(key: requestUrl) else {
            fatalError("下载失败")
        }
        
        debugPrint("任务完成",Thread.current)
        do {
            
            // 单独的文件存储 也就是文件拷贝
            let url = try ImageCache.default.storage(request: requestUrl, path: location)
            
            DispatchQueue.global().async {
                guard let image = UIImage(contentsOfFile: url.path) else {
                    fatalError()
                }
                ImageCache.default.addCache(request: url, image: image)
                
                let result:Result<UIImage,Error> = .success(image)
                
                self.addResult(key: requestUrl, result: result)
                
                task.callback?(result)
                self.removeTask(key: requestUrl)
            }
            
        } catch {
            fatalError("任务错误")
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let requestUrl = task.currentRequest?.url else {
            fatalError("下载失败")
        }
        if let error = error {
            let result:Result<UIImage,Error> = .failure(error)
            self.addResult(key: requestUrl, result: result)
            debugPrint("任务失败")
        } else {
            debugPrint("任务成功",Thread.current)
        }
        
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        //Tells the URL session that the session has been invalidated. 告诉URL会话该会话已失效。
    }
    


    
}
