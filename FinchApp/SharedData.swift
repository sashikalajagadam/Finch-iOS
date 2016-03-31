//
//  SharedData.swift
//  FinchiOS
//
//  Created by Sashikala on 29/03/16.
//  Copyright © 2016 Anteros. All rights reserved.
//

import Foundation

class ShareData {
    class var sharedInstance: ShareData {
        struct Static {
            static var instance: ShareData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ShareData()
        }
        
        return Static.instance!
    }
    
    var FFTData : [Float]  = [Float]()
//    var selectedTheme : AnyObject! //Some Object
//    var someBoolValue : Bool!
}