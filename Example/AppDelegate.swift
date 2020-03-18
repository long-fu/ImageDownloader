//
//  AppDelegate.swift
//  Example
//
//  Created by haoshuai on 2020/3/14.
//  Copyright © 2020 haoshuai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let url = Bundle.main.path(forResource: "data", ofType: "txt")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: url))
        let str = String.init(data: data, encoding: String.Encoding.utf8)!
        let urls = str.components(separatedBy: "\n")
        debugPrint("多少数据",urls.count)
        ImageLoader.sampleImageURLs = urls
        return true
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
        
    }
    
    

}

