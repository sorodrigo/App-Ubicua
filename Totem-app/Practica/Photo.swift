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
        
    }
    
    //Selector para parar el activity indicator despues de haberse guardado la imagen
    func image(image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>)
    {
        self.activityIndicator.stopAnimating()
    }
    
    //Metodo que guarda la foto tomada por la camara a la fototeca de SO
    @IBAction func savePhoto(sender: AnyObject) {
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        UIImageWriteToSavedPhotosAlbum(photo, self,"image:didFinishSavingWithError:contextInfo:", nil)
        
        
        
    }
    //Unwind a la pantalla de la foto tomada desde la pantalla de enviar
    @IBAction func unwindPhotoView(segue: UIStoryboardSegue){}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sharePhoto" {
            let navVC = segue.destinationViewController as! UINavigationController
            let tableVC = navVC.viewControllers.first as! Table
            tableVC.photo = photo
        }
    }
}
