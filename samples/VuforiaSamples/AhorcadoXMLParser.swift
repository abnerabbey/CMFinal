//
//  AhorcadoXMLParser.swift
//  FinalCM
//
//  Created by Antonio Santiago on 11/8/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import Foundation

class AhorcadoXMLParser: NSXMLParser, NSXMLParserDelegate {
    
    // MARK: Attributes
    
    var posts: [[String: String]]!
    var element: String!
    var categoria: String?
    var palabra: String?
    var stringValue: String?
    var counter: Int!
    
    // MARK: Methods
    func verifyValues() -> Bool {
        parseXML(NSURL(string: "http://www.serverbpw.com/cm/2016-1/hangman.php")!)
        var valueExists = false
        if (categoria?.characters.count > 0) && (palabra?.characters.count > 0) {
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
            categoria = nil
            palabra = nil
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
                categoria = stringValue
            } else if counter == 1 {
                palabra = stringValue
            }
            stringValue = nil
            counter!++
        }
        
        if elementName == "array" {
            var element = [String: String]()
            if categoria != nil {
                element["CATEGORIA"] = categoria
            }
            if palabra != nil {
                element["PALABRA"] = palabra
            }            
            posts.append(element)
        }
    }
}
