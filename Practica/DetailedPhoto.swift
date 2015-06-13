//
//  DetailedPhoto.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 15/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class DetailedPhoto: UIViewController {
    
    var photo:UIImage?
    var friends = [String:PhotoFriend]()
    var selectedHeader:Int = 0
    var selectedItem:Int = 0
    @IBOutlet weak var photoView: UIImageView!
    
    //Se pinta la foto recibida desde Collection
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoView.image = photo
        self.navigationController?.setToolbarHidden(false, animated: false)
        var tap = UITapGestureRecognizer(target: self, action: "imageTapped:")
        photoView.addGestureRecognizer(tap)
    }
    // Si la imagen es pulsada se esconden el toolbar y el navigation bar. Se pinta el background de negro.
    //Si estan ocultos se vuelven a mostrar y se pinta el background de blanco
    func imageTapped(img: AnyObject)
    {
        if (self.navigationController?.toolbar.hidden == false){
            self.navigationController?.setToolbarHidden(true, animated: true)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.view.backgroundColor = UIColor.blackColor()
        }
        else{
            self.navigationController?.setToolbarHidden(false, animated: true)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.view.backgroundColor = UIColor.whiteColor()
        }
    }
    //Si se da click en compartir se muestra el pop up de compartir del sistema operativo
    @IBAction func share(sender: AnyObject) {
        
        var imageArray = [UIImage]()
        imageArray.append(photo!)
        
        
        let shareScreen = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
        self.presentViewController(shareScreen, animated: true, completion: nil)
    }
    //Si se da click en eliminar se elimina la imagen y el URL del diccionario de photofriends
    @IBAction func deletePhoto(sender: AnyObject) {
        var key: String = Array(friends.keys)[selectedHeader]
        friends[key]!.photos.removeAtIndex(selectedItem)
        friends[key]!.uniqueurl.removeAtIndex(selectedItem)
        
        //Si el photofriend no tiene mas urls se elimina
        if(friends[key]!.uniqueurl.count == 0)
        {
            friends.removeValueForKey(key)
        }
        //Se actualizan los user defaults y se hace unwind a la collection.
        let defaults = NSUserDefaults.standardUserDefaults()
        let username:String = defaults.objectForKey("username") as! String
        let data = NSKeyedArchiver.archivedDataWithRootObject(friends)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "\(username)friends")
        defaults.synchronize()
        self.performSegueWithIdentifier("unwindDetailedPhotoID", sender: sender)
    }
    
}
