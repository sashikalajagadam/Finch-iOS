//
//  CSVReader.swift
//  BLEComm
//
//  Created by Sashi on 08/03/16.
//  Copyright © 2016 Anteros. All rights reserved.
//

import Foundation

public extension String {
    func splitOnNewLine () -> ([String]) {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
}

//CSV reader class
public class CSVReader {
    
    public let columnCount: Int
    public let headers: [String]
    public let keyedRows: [[String: String]]?
    public let rows: [[String]]
    
    //Another method - Read lines from file and form a string.
    //Reads the contents regardless of header present or not
    public func linesFromResource(fileName: String) -> [String]? {
        
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil) else {
            return nil
        }
        do {
            let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            return content.componentsSeparatedByString("\n")
        } catch {
            return nil
        }
    }
    
    public init(String string: String, headers: [String]?, separator: String) {
        let lines: [String] = includeQuotedStringInFields(Fields: string.splitOnNewLine().filter{(includeElement: String) -> Bool in
            return !includeElement.isEmpty
            }, quotedString: "")
        
        var parsedLines = lines.map{
            (transform: String) -> [String] in
            let commaSanitized = includeQuotedStringInFields(Fields: transform.componentsSeparatedByString(separator),quotedString: separator)
                .map
                {
                    (input: String) -> String in
                    return sanitizedStringMap(String: input)
                }
                .map
                {
                    (input: String) -> String in
                    //input.stringByReplacingOccurrencesOfString("\"\"", withString: "\"", options: NSStringCompareOptions.LiteralSearch)
                    return input.stringByReplacingOccurrencesOfString("\"\"", withString: ",", options: NSStringCompareOptions.LiteralSearch)
            }
            
            return commaSanitized
        }
        
        let tempHeaders: [String]
        
        if let unwrappedHeaders = headers {
            tempHeaders = unwrappedHeaders
        }
        else {
            tempHeaders = parsedLines[0]
            parsedLines.removeAtIndex(0)
        }
        self.rows = parsedLines
        self.columnCount = tempHeaders.count
        
        let keysAndRows = self.rows.map { (field: [String]) -> [String: String] in
            
            var row = [String: String]()
            
            for (index, value) in field.enumerate() {
                row[tempHeaders[index]] = value
            }
            
            return row
        }
        
        self.keyedRows = keysAndRows
        self.headers = tempHeaders
    }
    
    //In case the csv has header
    public convenience init(String string: String) {
        self.init(String: string, headers: nil, separator: ",")
    }
    
    public convenience init(String string: String, separator: String) {
        self.init(String: string, headers: nil, separator: separator)
    }
    
    public convenience init(String string: String, headers: [String]?) {
        self.init(String: string, headers: headers, separator: ",")
    }
    //end
    
}

//Helper functions
func includeQuotedStringInFields(Fields fields: [String], quotedString: String) -> [String] {
    
    var mergedField = ""
    var newArray = [String]()
    
    for field in fields {
        mergedField += field
        
        if mergedField.componentsSeparatedByString("\"").count%2 != 1 {
            mergedField += quotedString
            continue
        }
        newArray.append(mergedField)
        mergedField = ""
    }
    
    return newArray
}

func sanitizedStringMap(String string: String) -> String {
    
    let startsWithQuote = string.hasPrefix("") //("\"")
    let endsWithQuote = string.hasSuffix("") //("\"")
    
    if startsWithQuote && endsWithQuote {
        let startIndex = string.startIndex.advancedBy(1)
        let endIndex = string.endIndex.advancedBy(-1)
        let range = startIndex ..< endIndex
        let sanitizedField = string.substringWithRange(range)
        
        return sanitizedField
    }
    else {
        return string
    }
}

enum ImportError: ErrorType {
    case FileNotFound
    case CouldntGetArray
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}