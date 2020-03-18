//
//  ImageCollectionViewCell.swift
//  Example
//
//  Created by haoshuai on 2020/3/18.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = self.bounds
        addSubview(imageView)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        backgroundColor = UIColor.yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
//        DispatchQueue.global().async {
//            DispatchQueue.main.async {
//                
//            }
//        }
//        self.image?.draw(in: rect)
//        imageView.image = self.image
    }
    
    func clean() {
        imageView.image = nil
//        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0);
//        guard let context = UIGraphicsGetCurrentContext() else {
//            fatalError()
//        }
//        UIColor.red.set()
//        context.fill(self.bounds)
//
//        DispatchQueue.global().async {
//            DispatchQueue.main.async {
//
//
//            }
//        }
        
    }
    
}
