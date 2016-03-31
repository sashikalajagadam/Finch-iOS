//
//  CircularBuffer.swift
//  DFQueue
//
//  Created by Sashikala on 14/03/16.
//  Copyright © 2016 Anteros. All rights reserved.
//

import Foundation

//Extensions for converting String to float / Double
extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}


public struct CircularBuffer<T> {
    private var array: [T?]
    private var readIndex = 0
    private var writeIndex = 0
    var dataArray:[T] = []      //Holds the data window
    var dqString: String?   //Data window is returned as a string
    
    public init(count: Int) {
        array = [T?](count: count, repeatedValue: nil)
    }
    
    //Returns false if out of space
    public mutating func enqueue(element: T) -> T? {
        if !isFull {
            array[writeIndex % array.count] = element
            writeIndex += 1
            
            return element
        } else {
            return nil
        }
    }
    
    //Returns nil if the buffer is empty.
    public mutating func dequeue() -> T? {
        if !isEmpty {
            let element = array[readIndex % array.count]
            readIndex += 1
            return element
        } else {
            return nil
        }
    }
    
    //Returns nil if the buffer is empty.
    public mutating func dequeue(dataWinSize: Int, overlap: Int) -> String? {
        var index: Int = 0
        if !isEmpty {
            let element = array[readIndex % array.count]
            readIndex += 1
            //Append dequeued data to the buffer
            dataArray.append(element!)
            dqString = ""
            
            //Create data window only if the read index is greater than window size
            if readIndex >= dataWinSize + 1 {
                let arr = Array(dataArray)
                while arr.count != index {
                    //Handle data which do not fall into the window size with overlap
                    if ((arr.count - index) < dataWinSize )
                    {
                        return dqString
                    }
                    //Slice the data
                    let arrNew = arr[index..<dataWinSize+index]
                    //Concatenate sliced data. Cannot return sliced data without contatinating. Throws exception
                    dqString = concatenateNumbers(arrNew)
                    
                    //Shift index by overlap
                    index += overlap
                }
                return dqString
            }
            return dqString
        } else {
            return dqString
        }
    }
    
    func dataWindow(dataArr: [T], winSize: Int, overlap: Int) -> String {
        //Convert to array for slicing of data
        let arr = Array(dataArr)
        var index: Int = 0
        var dataString: String = ""
        
        while arr.count != index {
            if ((arr.count - index) < winSize )
            {
                return dataString
            }
            let arrNew = arr[index..<winSize+index]
            dataString = concatenateNumbers(arrNew)
            index += overlap + 1
        }
        return dataString
    }
    
    func concatenateNumbers<S: SequenceType>(numbers: S) -> String {
        let result = numbers.reduce(",") { $0 + "\($1)" }
        return result
    }//reduce(numbers, "") { $0 + "\($1)" }
    
    
    private var availableSpaceForReading: Int {
        return writeIndex - readIndex
    }
    
    public var isEmpty: Bool {
        return availableSpaceForReading == 0
    }
    
    private var availableSpaceForWriting: Int {
        return array.count - availableSpaceForReading
    }
    
    public var isFull: Bool {
        return availableSpaceForWriting == 0
    }
}
