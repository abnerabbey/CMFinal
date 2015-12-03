//
//  JuegoViewController.swift
//  FinalCM
//
//  Created by Antonio Santiago on 11/15/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import UIKit

class JuegoViewController: UIViewController, NSXMLParserDelegate {
    
    // MARK: ATTRIBUTES
    var images = [String]()
    var gTitle: String?
    var gDescription: String?
    var gURL: String?
    var gID: String?
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var urlAddress = NSMutableString()
    var urlString = ""
    var imageCounter = 0
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    
    // MARK: ACTIONS
    
    @IBAction func differentImagePressed(sender: UIButton) {
        
        if sender.tag == 0 {                // LEFT
            if imageCounter == images.startIndex {
                imageCounter = images.endIndex-1
            } else {
                imageCounter--
            }
        } else {                            // RIGHT
            if imageCounter == images.endIndex-1 {
                imageCounter = images.startIndex
            } else {
                imageCounter++
            }
        }
        
        urlString = images[imageCounter]
        gameImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)!)!)
        
        /*
        
        This code is not longer necessary since XMLParsing is now correctly done. It served as a 
        string cropper, to delete elements such as \n, \t
        
        print("imageCounter value is \(imageCounter)")
        if imageCounter != 0 {
            var difference = 0
            if imageCounter > 1 {
                let sizeOfString = images[imageCounter].characters.count
                let previousStringSize = images[imageCounter-1].characters.count
                print("sizeOfString is \(sizeOfString)\npreviousStringSize is \(previousStringSize)")
                if(previousStringSize < sizeOfString) {
                    difference = sizeOfString-previousStringSize
                }
            }
            print("difference value is \(difference)")
            urlString = deleteUnwantedCharacters(images[imageCounter],length: 48+difference)
        } else {
            urlString = images[imageCounter]
        }
        */
    }
    
    func verifyConnection() -> Bool{
        beginParsing()
        var imagesExist = false
        if images.count > 0 {
            imagesExist = true
        } else {
            imagesExist = false
            let noConnectionAlert = UIAlertController(title: "No se han podido obtener las imágenes", message: "El servidor no está disponible o no tienes conexión a internet. Intenta más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
            noConnectionAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction: UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(noConnectionAlert, animated: true, completion: nil)
        }
        return imagesExist
    }
    
    // MARK: METHODS
    
    /*
    func deleteUnwantedCharacters(urlAddress: String, length: Int) -> String {
        
        var finalURL = urlAddress
        finalURL.removeRange(finalURL.startIndex.advancedBy(length)..<finalURL.endIndex)
        print(finalURL)

        return finalURL
    }
    */
    
    override func viewDidLoad() {
        backgroundImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: gURL!)!)!)
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.alpha = 0.2
        images.append(gURL!)
        super.viewDidLoad()
        self.navigationItem.title = gTitle!
        
        verifyConnection()
        
        gameTitle.text = gTitle
        gameDescription.text = gDescription
        gameDescription.textAlignment = NSTextAlignment.Justified
        
        urlString = images[imageCounter]
        gameImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)!)!)
        gameImage.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    // MARK: NSXMLParser
    
    func beginParsing() {
        posts = []
        parser = NSXMLParser(contentsOfURL: NSURL(string: "http://www.serverbpw.com/cm/2016-1/gallery.php?id=\(gID!)")!)!
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: NSXMLParserDelegate Methods
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName
        if (elementName as NSString).isEqualToString("key") {
            elements = NSMutableDictionary()
            elements = [:]
            urlAddress = NSMutableString()
            urlAddress = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if element.isEqualToString("string") {
            urlAddress.appendString(string)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqualToString("string") {
            if !urlAddress.isEqual(nil) {
                elements.setObject(urlAddress, forKey: "URL")
                images.append(String(urlAddress))
            }
            posts.addObject(elements)
            print(posts)
        }
    }
}
