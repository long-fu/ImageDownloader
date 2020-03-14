//
//  HSIError.swift
//  ImageDownloader
//
//  Created by haoshuai on 2020/3/14.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import Foundation



struct HSIError {
    enum CacheError:Error {
        case fileError(String)
    }
    
    enum DownloaderErrpr:Error {
        case urlError(String)
    }
}


extension Date {
    func cmp() -> TimeInterval {
        let timeInterval = Date()
        return timeInterval.timeIntervalSince1970 - self.timeIntervalSince1970
    }
}
