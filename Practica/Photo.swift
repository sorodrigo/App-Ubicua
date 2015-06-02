//
//  Photo.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 21/04/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class Photo: UIViewController {
    
    var photo:UIImage?
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoView.image = photo
        self.activityIndicator.hidden = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func image(image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>)
    {
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func savePhoto(sender: AnyObject) {
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        UIImageWriteToSavedPhotosAlbum(photo, self,"image:didFinishSavingWithError:contextInfo:", nil)
        
        
        
    }
    
    @IBAction func unwindPhotoView(segue: UIStoryboardSegue){}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sharePhoto" {
            let navVC = segue.destinationViewController as! UINavigationController
            let tableVC = navVC.viewControllers.first as! Table
            tableVC.photo = photo
        }
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
