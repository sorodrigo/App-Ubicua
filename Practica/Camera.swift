//
//  Camera.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 21/04/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class Camera: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var doNotAlert: Bool = false
    @IBOutlet weak var photo: UIImage!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.shootPhoto()
        //self.photofromLibrary()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindCameraView(segue : UIStoryboardSegue ){
        self.doNotAlert = false
    }
    
    func photofromLibrary() {
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)//4
    }
    
    func shootPhoto() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            presentViewController(picker, animated: true, completion: nil)
        } else {
            if !doNotAlert
            {
                noCamera()
            }
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (alert) -> Void in
            self.photofromLibrary()
        }
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        photo = chosenImage
        self.doNotAlert = true
        dismissViewControllerAnimated(false, completion: nil)
        performSegueWithIdentifier("photoTaken", sender: self)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.doNotAlert = true
        performSegueWithIdentifier("unwindCamera", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "photoTaken" {
            self.doNotAlert = false
            let destinationVC = segue.destinationViewController as! Photo
            destinationVC.photo = self.photo
        }
    }
    
    
    
}
