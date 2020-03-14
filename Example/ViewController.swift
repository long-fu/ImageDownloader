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

    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        ImageLoader
        let urls = ImageLoader.sampleImageURLs // + ImageLoader.highResolutionImageURLs
        ImageDownloader.default.downloadImage(urls: urls)
        
        
        button.addTarget(self, action: #selector(self.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        // Do any additional setup after loading the view.
    }

    
    @objc
    func buttonAction(_ sender: UIButton) {
        let urls = ImageLoader.sampleImageURLs // + ImageLoader.highResolutionImageURLs
        ImageDownloader.default.downloadImage(urls: urls)
    }

}

