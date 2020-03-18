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
        let attr1 = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        guard let attr = self.layoutAttributesForItem(at: indexPath) else {
            fatalError()
        }
        attr.transform =  CGAffineTransform.init(scaleX: 0.2, y: 0.2).rotated(by: .pi)

        attr.center = CGPoint(x: self.collectionView!.bounds.midX, y: self.collectionView!.bounds.midY)
        debugPrint("动画部分")
        return attr;
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        debugPrint("增加数据动画")
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
        
        
        for i in 0 ..< pages {
            if index < allDataSource.count {
                let item = allDataSource[i]
                dataSource.append(item)
                index += 1
            } else {
                break
            }
        }
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        layout.itemSize = CGSize(width: 100, height: 100)
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
        if isSamll {
            self.collectionView.setCollectionViewLayout(blayout!, animated: true)
        } else {
            self.collectionView.setCollectionViewLayout(slayout!, animated: true)
        }
        isSamll = !isSamll
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
    
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = self.dataSource[indexPath.item]
        debugPrint("点击的图片",url,indexPath)
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
