//: Playground - noun: a place where people can play

import UIKit
import Foundation
import XCPlayground
import BLEComm      //Library for reading CSV data
import DFQueue      //Library for writing and reading from circular queue
import FFTWindow    //Library for FFT circular queue
import Surge        //Library for FFT transformation


///*****************************************
///Converting String array to float/double array
///*****************************************
protocol StringType { }
extension String: StringType {  }

extension Array where Element: StringType {
    var doubleArrayValue:[Double] {
        return map{Double(String($0)) ?? 0.0}
    }
    var floatArrayValue:[Float] {
        return map{Float(String($0)) ?? 0.0}
    }
}

///*****************************************
///Convert String to Int
///*****************************************
extension String {
    var intValue: Int {
        return (self as NSString).integerValue
    }
}

///*****************************************
///Convert String to Float
///*****************************************
extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

///*****************************************
///Convert String to String
///*****************************************
extension String {
    var strValue: String {
        return (self as NSString) as String
    }
}

///*****************************************
///Replace occurrence of string with another string
///*****************************************
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

func plot<T>(values: [T], title: String) {
    for value in values {
        XCPlaygroundPage.currentPage.captureValue(value, withIdentifier: title)
    }
}

