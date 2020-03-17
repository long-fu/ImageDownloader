//
//  ImageCache.swift
//  HSImageDownloader
//
//  Created by haoshuai on 2020/3/14.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import Foundation
import UIKit


// 实现文件缓存

public class ImageCache {
    
    private let name: String
    
    // web url:file url - 说是线程安全 APP重启就会回收
    private let cache:NSCache = NSCache<NSString,UIImage>()
    
    private let lock = NSLock()
    
//    private func addCache(request url: URL,file path: URL) {
////        lock.lock()
////        defer {
////            lock.unlock()
////        }
////        cache.setObject(path.path as NSString, forKey: url.absoluteString as NSString)
//
//    }
    
    func addCache(request url: URL, image: UIImage) {
//        lock.lock()
//        defer {
//            lock.unlock()
//        }
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    // 磁盘已经有数据
    public func cache(request url: URL) -> Bool {
        let md5_str = url.absoluteString.md5
        let path = self.cacheDirectory.appendingPathComponent("\(md5_str).tmp", isDirectory: false)
        let result = FileManager.default.fileExists(atPath: path.path)
        return result
    }
    
    // 需要和 func cache(request url: URL) -> Bool 一起使用
    public func cache(request url: URL) -> UIImage? {
        if let image =  cache.object(forKey: url.absoluteString as NSString) {
            return image
        }
        let md5_str = url.absoluteString.md5
        let path = self.cacheDirectory.appendingPathComponent("\(md5_str).tmp", isDirectory: false)
        guard let image = UIImage(contentsOfFile: path.path) else {
            // 和判断一起应该是存在的
            return nil
        }
        self.addCache(request: url, image: image)
        return image
    }
    
    public func removeCache(request url: URL) {
//        lock.lock()
//        defer {
//            lock.unlock()
//        }
        cache.removeObject(forKey: url.absoluteString as NSString)
    }
    @objc
    public func removeAllCache() {
//        lock.lock()
//        defer {
//            lock.unlock()
//        }
        cache.removeAllObjects()
    }
    
    public static let `default` = ImageCache(name: "default")
    
    public var totalCostLimit: Int {
        didSet {
            cache.totalCostLimit = totalCostLimit
        }
    }
    
    public var countLimit: Int {
        didSet {
            cache.countLimit = countLimit
        }
    }
    
    private lazy var cacheDirectory: URL = {
        guard let dstPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            fatalError()
        }
//        let path = URL(fileURLWithPath: root).appendPathComponent("HS_ImageCache", isDirectory: true)
        let path = (dstPath as NSString).appendingPathComponent("HS_ImageCache")
//        debugPrint("下载的目录",path)
        if FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        
//        debugPrint("需要创建的目录",path)
        
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            
            return URL(fileURLWithPath: path)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }()
    
    init(name: String,totalCostLimit: Int = 1000,countLimit: Int = 10000) {
        self.name = ""
        
        self.totalCostLimit = totalCostLimit
        self.countLimit = countLimit
        
        cache.totalCostLimit = totalCostLimit
        cache.countLimit = countLimit
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeAllCache), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    // 单纯的存储文件
    func storage(request url: URL,path file: URL) throws ->  URL {
        
        let data = try Data(contentsOf: file)
        
        let md5_str = url.absoluteString.md5 // 直接缓存数据
//        debugPrint("最后的后缀",file.lastPathComponent)
        let path = self.cacheDirectory.appendingPathComponent("\(md5_str).tmp", isDirectory: false)
        
        try data.write(to: path)
        

        return path
    }
    
    
    
}
