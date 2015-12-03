//
//  MapXMLParser.swift
//  FinalCM
//
//  Created by Antonio Santiago on 11/17/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import Foundation

class MapXMLParser: NSXMLParser, NSXMLParserDelegate {
    
    // MARK: Attributes
    
    var posts: [[String: String]] = [[:]]
    var element: String!
    
    var latitude, longitude, storeName, stringValue: String?
    
    var counter: Int!
    
    
    // MARK: Methods
    
    func verifyValues() -> Bool {
        
        parseXML(NSURL(string: "http://www.serverbpw.com/cm/2016-1/stores.php")!)
        var valueExists = false
        posts.removeFirst()
        if (latitude?.characters.count > 0 && longitude?.characters.count > 0 && storeName?.characters.count > 0){
            valueExists = true
        }
        
        return valueExists
    }
    
    // MARK: NSXMLParser Methods
    
    func parseXML(url: NSURL) {
        posts = [[:]]
        let parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        if elementName == "array" {
            latitude = nil
            longitude = nil
            storeName = nil
            counter = 0
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if element == "string" {
            if stringValue == nil {
                stringValue = string
            } else {
                stringValue! += string
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "string" {
            stringValue = stringValue?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if counter == 0 {
                storeName = stringValue
            } else if counter == 1 {
                latitude = stringValue
            } else if counter == 2 {
                longitude = stringValue
            }
            stringValue = nil
            counter!++
        }
        
        if elementName == "array" {
            var element = [String: String]()
            if storeName != nil {
                element["NAME"] = storeName
            }
            if latitude != nil {
                element["LATITUDE"] = latitude
            }
            if longitude != nil {
                element["LONGITUDE"] = longitude
            }
            posts.append(element)
        }
    }

}