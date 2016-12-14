//
//  AppDelegate.swift
//  QRCodeDemo
//
//  Created by 函冰 on 2016/12/7.
//  Copyright © 2016年 今晚打老虎. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window?.rootViewController = QRCodeViewController.shareInstance()
        window?.makeKeyAndVisible()
        
        return true
    }
}

func DLog<T> (messge : T,method : String = #function,line : Int = #line)->(){
    #if DEBUG
        print( (method),"--",(line),(messge))
    #endif
}
