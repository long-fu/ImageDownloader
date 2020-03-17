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
    static let sampleImageURLs: [URL] = {
        let prefix = "https://raw.githubusercontent.com/onevcat/Kingfisher-TestImages/master/DemoAppImage/Loading"
        return (1...10).map { URL(string: "\(prefix)/kingfisher-\($0).jpg")! }
    }()

    static let highResolutionImageURLs: [URL] = {
        let prefix = "https://raw.githubusercontent.com/onevcat/Kingfisher-TestImages/master/DemoAppImage/HighResolution"
        return (1...20).map { URL(string: "\(prefix)/\($0).jpg")! }
    }()
    
    static let gifImageURLs: [URL] = {
        let prefix = "https://raw.githubusercontent.com/onevcat/Kingfisher-TestImages/master/DemoAppImage/GIF"
        return (1...3).map { URL(string: "\(prefix)/\($0).gif")! }
    }()

    static let progressiveImageURL: URL = {
        let prefix = "https://raw.githubusercontent.com/onevcat/Kingfisher-TestImages/master/DemoAppImage/Progressive"
        return URL(string: "\(prefix)/progressive.jpg")!
    }()
}

class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    var dataSource: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urls = ImageLoader.sampleImageURLs // + ImageLoader.highResolutionImageURLs
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
        debugPrint("加载任务",indexPath)
        let url = dataSource[indexPath.item]
        ImageDownloader.default.downloadImage(url: url) { (result) in
            switch result {
            case let .success(image):
                cell.image = image
                cell.setNeedsDisplay()
            case .failure(_):
                fatalError()
            }
        }
        return cell
    }
    
    
}

extension ViewController: UICollectionViewDelegate {
    
}


