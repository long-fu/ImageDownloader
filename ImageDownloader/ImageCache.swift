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
    
    // web url:file url - 说是线程安全
    private let cache:NSCache = NSCache<NSString,NSString>()
    
    private let lock = NSLock()
    
    private func addCache(request url: URL,file path: URL) {
        lock.lock()
        defer {
            lock.unlock()
        }
        cache.setObject(path.path as NSString, forKey: url.absoluteString as NSString)
    }
    
    
    public func cache(request url: URL) -> Bool {
        let md5_str = url.absoluteString.md5
        let path = self.cacheDirectory.appendingPathComponent("\(md5_str).tmp", isDirectory: false)
        let result = FileManager.default.fileExists(atPath: path.path)
        if result { debugPrint("存在数据", path) }
        return result
    }
    
    public func cache(request url: URL) -> URL? {
        guard let paht =  cache.object(forKey: url.absoluteString as NSString) else {
            return nil
        }
        return URL(fileURLWithPath: paht as String)
    }
    
    public func removeCache(request url: URL) {
        lock.lock()
        defer {
            lock.unlock()
        }
        cache.removeObject(forKey: url.absoluteString as NSString)
    }
    
    
    
    public static let `default` = ImageCache(name: "default")
    
//    private let downloadCache = NSCache<NSString,NSString>()
    
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
        
    }
    

    
    func storage(request url: URL,path file: URL) throws ->  URL {
        
        let data = try Data(contentsOf: file)
        
        let md5_str = url.absoluteString.md5 // 直接缓存数据
//        debugPrint("最后的后缀",file.lastPathComponent)
        let path = self.cacheDirectory.appendingPathComponent("\(md5_str).tmp", isDirectory: false)
        
        try data.write(to: path)
        
        self.addCache(request: url, file: path)
        
        return path
    }
    
    
    
}
