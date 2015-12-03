//
//  ListaTableViewController.swift
//  FinalCM
//
//  Created by Antonio Santiago on 11/14/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import UIKit

class ListaTableViewController: UITableViewController {

    
    // MARK: ATTRIBUTES

    let xmlParser = ListaXMLParser()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: METHODS
    
    override func viewDidLoad() {

        self.title = "Lista de Juegos"
        super.viewDidLoad()
        
        // Efecto blur
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        imageView.image = UIImage(named: "SPSC.png")
        self.view.insertSubview(imageView, atIndex: 0)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let imageBlur = UIVisualEffectView(effect: blurEffect)
        imageBlur.frame = imageView.bounds
        imageView.addSubview(imageBlur)
        
        // Obtención de información desde el servidor
        
        if xmlParser.verifyValues() {
            print("Connection successful")
        } else {
            let noConnectionController = UIAlertController(title: "Conexión no establecida", message: "El servidor no está disponible o no tienes acceso a internet. Intenta más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
            noConnectionController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction: UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(noConnectionController, animated: true, completion: nil)
        }
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return xmlParser.posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "JuegoTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! JuegoTableViewCell

        let posts = xmlParser.posts[indexPath.row]
        let urlString = posts["URL"]
        
        cell.title.text = posts["NAME"]
        cell.about.text = posts["DESCRIPTION"]
        cell.thumbnail.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString!)!)!)
        cell.thumbnail.contentMode = UIViewContentMode.ScaleAspectFit
        
        var rotation: CATransform3D!
        rotation = CATransform3DMakeRotation(CGFloat((90.0*M_PI)/180.0), 0.0, 0.7, 0.4)
        rotation.m34 = 1.0/(-600)
        
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.alpha = 0
        cell.layer.transform = rotation
        cell.layer.anchorPoint = CGPointMake(0, 0.5)
        
        UIView.beginAnimations("rotation", context: nil)
        UIView.setAnimationDuration(0.8)
        cell.layer.transform = CATransform3DIdentity
        cell.alpha = 1
        cell.layer.shadowOffset = CGSizeMake(0, 0)
        UIView.commitAnimations()
        return cell
    }
    
    // MARK: TableViewDelegate Methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {  // Animation
        var rotation: CATransform3D!
        rotation = CATransform3DMakeRotation(CGFloat((90.0*M_PI)/180.0), 0.0, 0.7, 0.4)
        rotation.m34 = 1.0/(-600)
        
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.alpha = 0
        cell.layer.transform = rotation
        cell.layer.anchorPoint = CGPointMake(0, 0.5)
        
        UIView.beginAnimations("rotation", context: nil)
        UIView.setAnimationDuration(0.8)
        cell.layer.transform = CATransform3DIdentity
        cell.alpha = 1
        cell.layer.shadowOffset = CGSizeMake(0, 0)
        UIView.commitAnimations()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowGameDetail" {
        
            let juegoViewController = segue.destinationViewController as! JuegoViewController
            
            if let selectedGameCell = sender as? JuegoTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedGameCell)!
                let selectedGame = xmlParser.posts[indexPath.row]
                
                /*
                juegoViewController.gameTitle.text = selectedGame["NAME"]
                juegoViewController.gameDescription.text = selectedGame["DESCRIPTION"]
                */
                
                juegoViewController.gTitle = selectedGame["NAME"]
                juegoViewController.gDescription = selectedGame["DESCRIPTION"]
                juegoViewController.gID = selectedGame["ID"]
                juegoViewController.gURL = selectedGame["URL"]
            }
        }
    }
}
