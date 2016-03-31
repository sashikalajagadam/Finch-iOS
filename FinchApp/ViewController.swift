//
//  ViewController.swift
//  FinchApp
//
//  Created by Sashi on 09/03/16.
//  Copyright © 2016 Anteros. All rights reserved.
//

import Foundation
import UIKit

import BLEComm      //Library for reading CSV data
import DFQueue      //Library for writing and reading from circular queue
import FFTWindow    //Library for FFT circular queue
import Surge        //Library for FFT transformation
import Charts


///Converting String array to float/double array
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

///Convert String to Int
extension String {
    var intValue: Int {
        return (self as NSString).integerValue
    }
}

///Convert String to Float
extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

///Convert String to String
extension String {
    var strValue: String {
        return (self as NSString) as String
    }
}

///Replace occurrence of string with another string
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

class ViewController: UIViewController, UITextFieldDelegate, ChartViewDelegate {
    var storyBoard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
    
//    @IBOutlet weak var lblCSVData: UILabel!
//    @IBOutlet weak var lblEnqueue: UILabel!
//    @IBOutlet var lblfftEnqueued: UILabel!
//    @IBOutlet var lblFftDq: UILabel!
    
//    @IBOutlet var txtFftDq: UITextField!
    @IBOutlet var lineChartView: LineChartView!
    var filename: String = ""
    
    //CircularBuffer
    var buffer = CircularBuffer<String>(count: 0)   //Data window buffer
    var fftBuffer = FFTCirBuffer<String>(count: 0)  //FFT buffer
    
    var fftArray = [Float]()    //FFT data array
    var enqArray = [Float]()
 
    @IBOutlet var windowSize: UITextField!
    @IBOutlet var overlap: UITextField!
    
    var winSize = 0
    var datOverlap = 0
    
    func appDelegate () -> AppDelegate
    {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Get file from resource bundle
        filename = NSBundle.mainBundle().pathForResource("sample", ofType: "csv")!
        lineChartView.delegate = self
        lineChartView.xAxis.enabled = true
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.rightAxis.drawLabelsEnabled = false
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //Pass FFT data to chart view controller
//        if (segue.identifier == "chartSegue") {
//            let cvc = segue.destinationViewController as! ChartViewController
////            cvc.delegate = self
////            cvc.fftData = fftArray
//            cvc.fftBuffer = appDelegate().fftDataBuffer
//        }
    }
    
    @IBAction func ExitApp() {
        exit(0)
    }

    @IBAction func BLEReader() {
        self.winSize =  Int (self.windowSize.text!)!
        self.datOverlap = Int (self.overlap.text!)!
        
        //Set buffer size
        buffer = CircularBuffer<String>(count: winSize*100)
        fftBuffer = FFTCirBuffer<String>(count: winSize*100)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        dispatch_async(dispatch_get_main_queue(), {
            NSThread.detachNewThreadSelector(#selector(ViewController.enQ), toTarget: self, withObject: nil)
        })
    }
    
    /// START: Data Framer enqueue and dequeue
    //Enqueue to BLE circular buffer
    func enQ() {
        var retEnQ: String = ""
        
        if let data = NSData(contentsOfFile: filename) {
            if let content = NSString(data: data, encoding: NSUTF8StringEncoding) {
                let fileContent = String(content)
                
                let csvParser = CSVReader.init(String: fileContent, headers: nil)
                
                for element in csvParser.rows {
                    retEnQ = String(self.buffer.enqueue(element.description))
                    
                    NSThread.sleepForTimeInterval(0.1)
                    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
                        NSThread.detachNewThreadSelector(#selector(ViewController.deQ), toTarget: self, withObject: nil)
                    })
                }
            }
        }
    }
    
    //DeQueue from BLE Circular buffer
    func deQ()  {
        var prevDat: String = ""
        var readDat: String = ""
        var fftenqData: String
        
        while !buffer.isEmpty  {
            
            //Returns dataframer window. Pass window size and overlap as parameters
            let value = buffer.dequeue(Int (self.windowSize.text!)!, overlap: Int (self.overlap.text!)!)
            
            if (prevDat != String(value)) {
                readDat = (value!.strValue)
            }
            let tmp = readDat.strValue
            if tmp != "" {
                fftenqData = tmp
                NSThread.detachNewThreadSelector(#selector(ViewController.fftEnQ(_:)), toTarget: self, withObject: fftenqData)
                prevDat = readDat
            }
        }
    }
    /// END
    
    /// START: FFT Window enqueue and dequeue
    // Enqueue to data window to FFT circular buffer
    func fftEnQ(fftenqData: String) {
        fftBuffer.enqueue(fftenqData)
        NSThread.detachNewThreadSelector(#selector(ViewController.fftDeQ), toTarget: self, withObject: nil)
    }
    
    // Dequeue data window from FFT buffer
    func fftDeQ() {
        var DqDataStrings = [String]()
        var floatArray = [Float]()
        
        while !fftBuffer.isEmpty {
            let fftDQData = fftBuffer.dequeue()
            
            DqDataStrings.append(fftDQData!)    // Append each data window to buffer
            
            //Convert each data window to float array
            for item in DqDataStrings {
                let tmp = item.replace("[", withString: "")
                let tmp1 = tmp.replace("]", withString: ",")
                let tmp2 = tmp1.replace("\"", withString: "")
                let tmp3 = tmp2.componentsSeparatedByString(",")
                
                for eachString in tmp3 {
                    //Trim whitespaces if there are any and convert to float array
                    let trimmedString = eachString.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if trimmedString != "" {
                        if let num = Float(trimmedString) {
                            floatArray.append(num)
                        } else {
                            print("Error converting to Float")
                        }
                    }
                }
            }
            // Perform FFT on the float array
            self.fftArray = Surge.fft(floatArray)
            lineChartUpdate(fftArray)   // Draw line graph of the fft'ed data
        }
    }
    /// END

    
    // Draw line graph      
    func lineChartUpdate(values: [Float]) {
        
        var allLineChartDataSets: [LineChartDataSet] = [LineChartDataSet]()
        var dataEntries: [ChartDataEntry] = []
        var xVals: [String] = [String]()
        
        for i in 0..<values.count {
            let xNSNumber = i as NSNumber
            let xString : String = xNSNumber.stringValue
            xVals.append(xString)
            
            let dataEntry = ChartDataEntry(value: Double(values[i]), xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet2 = LineChartDataSet(yVals: dataEntries, label: "FFT Data")
        lineChartDataSet2.setColor(UIColor.redColor())
        lineChartDataSet2.setCircleColor(UIColor.redColor())
        allLineChartDataSets.append(lineChartDataSet2)
        
        let lineChartData = LineChartData(xVals: xVals, dataSets: allLineChartDataSets)
        lineChartView.data = lineChartData
    }
}
