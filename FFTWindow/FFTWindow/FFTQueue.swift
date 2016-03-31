//
//  FFTQueue.swift
//  FFTWindow
//
//  Created by Sashikala on 17/03/16.
//  Copyright © 2016 Anteros. All rights reserved.
//

import Foundation

public struct FFTCirBuffer<T> {
    private var array: [T?]
    private var readIndex = 0
    private var writeIndex = 0
    var dataArray:[T] = []      //Holds the data window
    var dqString: String = ""   //Data window is returned as a string
    
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
        //            OSAtomicIncrement64(UnsafeMutablePointer<Int64>(bitPattern: writeIndex + 1))
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