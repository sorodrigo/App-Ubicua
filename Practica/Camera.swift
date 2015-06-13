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
    
    //En esta función tomaremos la foto desde la cámara, en caso de no tener acceso a ella, llamará a noCamera()
    
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
    
    //Debido a que solo se puede acceder a la cámara con la licencia de desarrollador, se llamará a está función donde nos dará un mensaje de error y nos llevará a la fototeca
    
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
    
    //Descartar Camara
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.doNotAlert = true
        performSegueWithIdentifier("unwindCamera", sender: self)
    }
    
    //Pasamos la foto tomada a la siguiente vista
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "photoTaken" {
            self.doNotAlert = false
            let destinationVC = segue.destinationViewController as! Photo
            destinationVC.photo = self.photo
        }
    }
    
    
    
}