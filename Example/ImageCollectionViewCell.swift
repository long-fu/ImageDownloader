//
//  ImageCollectionViewCell.swift
//  Example
//
//  Created by haoshuai on 2020/3/18.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var image: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //
        image?.draw(in: rect)
    }
}
