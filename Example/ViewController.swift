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

class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    var dataSource: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urls = ImageLoader.sampleImageURLs.map{URL.init(string: $0)!}
        
        self.dataSource = urls
        
        reloadButton.addTarget(self, action: #selector(self.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.setCollectionViewLayout(layout, animated: false, completion: nil)
        
    }
    
    
    @objc
    func buttonAction(_ sender: Any?) {
        
    }
    
    
}

extension ViewController: UICollectionViewDataSource {
    
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

