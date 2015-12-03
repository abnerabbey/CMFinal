//
//  ScannerViewController.swift
//  FinalCM
//
//  Created by Antonio Santiago on 10/27/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import UIKit

class ScannerViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Escáner"
        
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.height))
        imageView.image = UIImage(named: "SPSC.png")
        self.view.insertSubview(imageView, atIndex: 0)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurBackground = UIVisualEffectView(effect: blurEffect)
        blurBackground.frame = imageView.bounds
        imageView.addSubview(blurBackground)

    }

    
    //MARK: ImagePicker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
