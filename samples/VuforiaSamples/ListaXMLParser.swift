//
//  AhorcadoXMLParser.swift
//  FinalCM
//
//  Created by Antonio Santiago on 11/13/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//


import Foundation

class ListaXMLParser: NSXMLParser, NSXMLParserDelegate {
    
    // MARK: Attributes
    
    var posts: [[String: String]] = [[:]]
    var element: String!
    
    var gID, gName, gDescription, gURL, stringValue: String?
    
    var counter: Int!
    
    
    
    // MARK: Methods
    
    func verifyValues() -> Bool {
        parseXML(NSURL(string: "http://www.serverbpw.com/cm/2016-1/list.php")!)
        var valueExists = false
        posts.removeFirst()
        if (gID?.characters.count > 0) && (gName?.characters.count > 0) && (gDescription?.characters.count > 0) && (gURL?.characters.count > 0){
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
            gID = nil
            gName = nil
            gDescription = nil
            gURL = nil
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
                gID = stringValue
            } else if counter == 1 {
                gName = stringValue
            } else if counter == 2 {
                gDescription = stringValue
            } else if counter == 3 {
                gURL = stringValue
            }
            stringValue = nil
            counter!++
        }
        
        if elementName == "array" {
            var element = [String: String]()
            if gID != nil {
                element["ID"] = gID
            }
            if gName != nil {
                element["NAME"] = gName
            }
            if gDescription != nil {
                element["DESCRIPTION"] = gDescription
            }
            if gURL != nil {
                element["URL"] = gURL
            }
            posts.append(element)
        }
    }
}