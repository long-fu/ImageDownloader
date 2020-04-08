//
//  ViewController.swift
//  Example
//
//  Created by haoshuai on 2020/3/14.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import UIKit
import ImageDownloader


struct ImageLoader {
    static var sampleImageURLs: [String] = []

}

class AN: UICollectionViewLayoutAttributes {
    
}

class AnimationCollectionViewLayout: UICollectionViewFlowLayout {
    
//    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//
//    }
    
    let contentSize: CGSize
    init(contentSize: CGSize) {
        self.contentSize = contentSize
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    override var collectionViewContentSize: CGSize {
//        return self.contentSize
//    }
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
//
//        attributes.alpha = 0.7
//        attributes.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        debugPrint("增加数据动画")
        return nil
    }
    
    
}

class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    private var slayout: AnimationCollectionViewLayout?
    
    private var blayout: AnimationCollectionViewLayout?
    
    private var isSamll = true
    
    var dataSource: [URL] = []
    
    var allDataSource: [URL] = []
    
    var index = 0
    
    private let pages = 100
    
    private var loading: Bool = false
    
    private func loadNewData() {
        
        var list = [IndexPath]()
        for i in 0 ..< pages {
            if index < allDataSource.count {
                let item = allDataSource[i]
                dataSource.append(item)
                index += 1
                let indexP = IndexPath(item: dataSource.count - 1, section: 0)
                list.append(indexP)
            } else {
                break
            }
        }
        
        self.collectionView.insertItems(at: list)
//        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        debugPrint("测试代码1")
//        let op = OperationQueue()
////        op.maxConcurrentOperationCount = 1
//        let bl1 = HSOperation(op_name: "111", sleep_timer: 2.0)
////        bl1.waitUntilFinished()
//        let bl2 = HSOperation(op_name: "222", sleep_timer: 1.0)
//        let bl3 = HSOperation(op_name: "333", sleep_timer: 0.5)
//        op.addOperation(bl1)
//        op.addOperation(bl2)
//        op.waitUntilAllOperationsAreFinished()
//        op.addOperation(bl3)
//        debugPrint("测试代码2")
        
        allDataSource = ImageLoader.sampleImageURLs.map{URL.init(string: $0)!}

        for i in 0 ..< pages {
            if index < allDataSource.count {
                let item = allDataSource[i]
                dataSource.append(item)
                index += 1
            } else {
                break
            }
        }
        debugPrint("加载的",dataSource.count)
        reloadButton.addTarget(self, action: #selector(self.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        collectionView.setconview
        let contentSize = UIScreen.main.bounds.inset(by: view.safeAreaInsets)
        let layout = AnimationCollectionViewLayout(contentSize: contentSize.size)
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        self.slayout = layout
        
        let layout2 = AnimationCollectionViewLayout(contentSize: contentSize.size)
        layout2.itemSize = CGSize(width: 130, height: 130)
        layout2.minimumInteritemSpacing = 2
        layout2.minimumLineSpacing = 2
        self.blayout = layout2
        
//        layout.collectionViewContentSize =
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
//        self.collectionView.collectionViewLayout = layout
        collectionView.setCollectionViewLayout(layout, animated: false, completion: nil)
        
    }
    
    
    @objc
    func buttonAction(_ sender: Any?) {
//        if isSamll {
//            self.collectionView.setCollectionViewLayout(blayout!, animated: true)
//        } else {
//            self.collectionView.setCollectionViewLayout(slayout!, animated: true)
//        }
//        isSamll = !isSamll
//        collectionView.editingInteractionConfiguration
        let loop = RunLoop()
        let queue = DispatchQueue(label: "runloop")
        queue.async {
            loop.add(Port(), forMode: RunLoop.Mode.common)
            
//            let timer = CFRunLoopTimer.self
//            loop.currentMode
        }
    }
    
    
}

extension ViewController: UICollectionViewDataSource {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            fatalError()
        }
        
        let url = dataSource[indexPath.item]
        debugPrint("加载任务",indexPath,url)
        ImageDownloader.default.downloadImage(url: url) { (result) in
            switch result {
            case let .success(image):
                cell.image = image
//                cell.setNeedsDisplay()
            case .failure(_):
                fatalError()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 预加载
        let url = dataSource[indexPath.row]
        debugPrint("预加载",indexPath,url)
        guard let icell = cell as? ImageCollectionViewCell else {
            fatalError()
        }
//        ImageDownloader.default.downloadImage(url: url, callback: nil)
        ImageDownloader.default.downloadImage(url: url) { (result) in
            switch result {
            case let .success(image):
                icell.image = image
//                icell.setNeedsDisplay()
            case .failure(_):
                fatalError()
            }
        }
        
        
        
//        icell.image
//        guard let icell = cell as? ImageCollectionViewCell else {
//            fatalError()
//        }
        
//
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let icell = cell as? ImageCollectionViewCell else {
            fatalError()
        }
        let url = self.dataSource[indexPath.item]
        // 这里删除回调
        ImageDownloader.default.cancelDownloadTask(request: url)
        icell.clean()
        // 取消下载
//        icell.clean()
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        debugPrint("交换数据", sourceIndexPath,destinationIndexPath)
    }
    
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let url = self.dataSource[indexPath.item]
//        debugPrint("点击的图片",url,indexPath)
//
//
//        let destination = IndexPath(item: 0, section: 0)
//        let data1 = self.dataSource[indexPath.item]
//
//        self.dataSource.remove(at: indexPath.item)
//        self.dataSource.insert(data1, at: 0)
//        // 不是交换
//        collectionView.moveItem(at: indexPath, to: destination)
    
//
    }
}

extension ViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
    }
    

    
    
    
}

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    
}

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        guard let photos = self.dataSource?.photo else {
//            fatalError()
//        }
//        let urls = indexPaths.compactMap { (index) -> URL in
//            let url = photos[index.item].getImageURL(size: CGSize(width: self.itemLength, height: self.itemLength))
//            return url
//        }
//        ImagePrefetcher(urls: urls).start()
        
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
}


extension ViewController: UIScrollViewDelegate {
       
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
            debugPrint(distance,loading)

        if !loading && distance < 200 {
                loading = true
                self.loadNewData()
                loading = false
    
        } // if
            
     
    }
    
}
