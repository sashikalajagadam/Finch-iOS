//
//  ChartViewController.swift
//  FinchiOS
//
//  Created by Sashikala on 29/03/16.
//  Copyright © 2016 Anteros. All rights reserved.
//

import UIKit
import Charts
import Foundation
//import FFTDataQueue

class ChartViewController: UIViewController, ChartViewDelegate{

    var originViewController: ViewController?
    var values = [Float]()
    var fftData = [Float]()
//    var buffer = FFTDataBuffer<[Float]>(count: 0)
//    var fftBuffer = FFTDataBuffer<[Float]>(count: 0)
    
    weak var delegate: FftValueDelegate?
    
    @IBOutlet var lineChartView: LineChartView!
    
    func appDelegate () -> AppDelegate
    {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    @IBAction func Dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lineChartView.delegate = self
        lineChartView.xAxis.enabled = true
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.rightAxis.drawLabelsEnabled = false
        
        //Copy FFT data from first view controller
//        values = fftData
//        buffer = appDelegate().fftDataBuffer
        
        lineChartUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lineChartUpdate() {
        
        var allLineChartDataSets: [LineChartDataSet] = [LineChartDataSet]()
        var dataEntries: [ChartDataEntry] = []
        var xVals: [String] = [String]()
        
//        if !appDelegate().fftDataBuffer.isEmpty {
//            values = appDelegate().fftDataBuffer.dequeue()
//        values = (delegate?.changeData())!
        
        for i in 0..<values.count {  //values.count
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
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
