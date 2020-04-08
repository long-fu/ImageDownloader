//
//  Dispath.swift
//  Example
//
//  Created by haoshuai on 2020/4/4.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import Foundation


class HSOperation: Operation {
    var op_name: String
    var sleep_timer: TimeInterval
    
    fileprivate var _executing : Bool = false
    override var isExecuting: Bool {
        get { return _executing }
        set {
            if newValue != _executing {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }

    fileprivate var _finished : Bool = false
    override var isFinished: Bool {
        get { return _finished }
        set {
            if newValue != _finished {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
//    override var isConcurrent: Bool {
//        get {
//            return true
//        }
//    }
    
    init(op_name: String,sleep_timer: TimeInterval) {
        self.op_name = op_name
        self.sleep_timer = sleep_timer
        
        super.init()
        
        self.isFinished = false
        self.isExecuting = false
    }
    
    
    override func start() {
        super.start()
        self.isExecuting = true
        self.isFinished = false
    }
    
    override func main() {
                
        
        DispatchQueue.global().async {
            debugPrint("开始任务", self.op_name, self.sleep_timer)
            sleep(UInt32(self.sleep_timer))
            debugPrint("完成任务", self.op_name, self.sleep_timer)
            self.complete()
        }
    }
    
    func complete() {
        self.isFinished = true
        self.isExecuting = false
//           [self willChangeValueForKey:@"isFinished"];
//           [self willChangeValueForKey:@"isExecuting"];
        
        
//           executing = NO;
//           finished = YES;
        
//           [self didChangeValueForKey:@"isExecuting"];
//           [self didChangeValueForKey:@"isFinished"];
    }
    
    override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        debugPrint("进行数据观察调用",key)
        return super.automaticallyNotifiesObservers(forKey: key)
    }
    
//    override init() {
//        super.init()
//
//        self.isExecuting = false
//        self.isFinished = false
//    }
    
    
    
}

//class HSOperation: Operation {
//
//    fileprivate var _executing : Bool = false
//    override var isExecuting: Bool {
//        get { return _executing }
//        set {
//            if newValue != _executing {
//                willChangeValue(forKey: "isExecuting")
//                _executing = newValue
//                didChangeValue(forKey: "isExecuting")
//            }
//        }
//    }
//
//    fileprivate var _finished : Bool = false
//    override var isFinished: Bool {
//        get { return _finished }
//        set {
//            if newValue != _finished {
//                willChangeValue(forKey: "isFinished")
//                _finished = newValue
//                didChangeValue(forKey: "isFinished")
//            }
//        }
//    }
//
//    override var isAsynchronous: Bool {
//        get {
//            return true
//        }
//    }
//
////    var asset: PHAsset?
//    /// 这里为原始坐标 - GPS获取到的数据
////    var location: CLLocation?
////    var isGPSLocation = true
////    var completedBlock: ((_ result: Result<MediaAssetModel,Error>) -> Void)?
////    init(asset: PHAsset,location: CLLocation,isGPSLocation: Bool = true, completion: @escaping (_ result: Result<MediaAssetModel,Error>) -> Void) {
////        self.isGPSLocation = isGPSLocation
////        self.asset = asset
////        self.location = location
////        self.completedBlock = completion
////        super.init()
////
////        self.isExecuting = false
////        self.isFinished = false
////    }
//
//    override init() {
//        super.init()
//
//        self.isExecuting = false
//        self.isFinished = false
//    }
//
//    override func main() {
//
//    }
//
//    override func start() {
//        isExecuting = true
//        isFinished = false
//
////        guard let asset = self.asset,let location = self.location,let completedBlock = self.completedBlock else {
////            fatalError()
////        }
//
//        func completed() {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.1)), execute: {
//                self.done()
//            })
//        }
//
////        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
////            if asset.mediaType == .image {
////
////                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: nil) { (image, info) in
////
////                    guard let image = image else {
////                        let error = NSError(domain: "onelcat.github.io.getImage", code: 500010, userInfo: nil)
////                        completedBlock(.failure(error))
////                        completed()
////                        return
////                    }
////
////                    let tempLocation: CLLocation
////
////                    if self.isGPSLocation {
////                        let aCoordinate = AMapCoordinateConvert(location.coordinate, AMapCoordinateType.GPS);
////                        tempLocation = CLLocation.init(coordinate: aCoordinate, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: location.speed, timestamp: Date())
////                    } else {
////                        tempLocation = location
////                    }
////
////                    let newImage = image.waterMarkedImage(location: tempLocation)
////                    guard let mediaModel:MediaAssetModel = MediaAssetFileManager.writeImage(at: newImage) else {
////                        let error = NSError(domain: "onelcat.github.io.getImage2jsonmodel", code: 500011, userInfo: nil)
////                        completedBlock(.failure(error))
////                        completed()
////                        return
////                    }
////                    completedBlock(.success(mediaModel))
////                    completed()
////                } // PHImageManager.default().requestImage
////
////            } // asset.mediaType == .image
////            else if asset.mediaType == .video {
////
////                // 暂时不生成水印
////                PHImageManager.default().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (avasset, audioMix, info) in
////                    guard let data_asset = avasset else {
////                        assert(false)
////                        let error = NSError(domain: "onelcat.github.io.getAVAsset", code: 500011, userInfo: nil)
////                        completedBlock(.failure(error))
////                        completed()
////                        return
////                    }
////
////                    MediaAssetFileManager.lowQuailtyAndWrite(asset: data_asset, completeHandle: { (result) in
////                        completedBlock(result)
////                        completed()
////                    })
////                }) // PHImageManager.default().requestAVAsset
////
////            } // else if asset.mediaType == .video
////        } // DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async
//
//    } // override func start()
//
//    // 完成
//    func done() {
//        self.isFinished = true
//        self.isExecuting = false
//        reset()
//    }
//
//    // 释放数据
//    func reset() {
////        self.asset = nil;
////        self.location = nil;
////        self.completedBlock = nil;
//    }
//}

//struct DispathQueue_HS {
//
//    let queue = OperationQueue()
//
//    func statr() {
//
//        let o = HSOperation()
//
////        直到接收器的所有相关操作完成执行后，才认为接收器准备就绪。如果接收者已经在执行其任务，则添加依赖项没有实际效果。此方法可能会更改接收器的isReady和依赖项属性。
////        在一组操作之间创建任何循环依赖关系是程序员的错误。这样做可能导致操作之间出现死锁，并可能冻结程序。
////        o.addDependency(<#T##op: Operation##Operation#>)
//
//        queue.addOperation(HSOperation())
//        queue.waitUntilAllOperationsAreFinished()
//    }
//}
