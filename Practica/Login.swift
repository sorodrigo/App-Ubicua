//
//  Login.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 16/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class Login: UIViewController {
    
    @IBOutlet weak var loginUsernameText: UITextField!
    @IBOutlet weak var loginPasswordText: UITextField!
    @IBOutlet weak var signupUsernameText: UITextField!
    @IBOutlet weak var signupPasswordText: UITextField!
    
    @IBOutlet weak var signupPhoneNumberText: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    let apiHelper = APIHelper()
    let addressbook = ABHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userLoggedIn") != nil {
            self.performSegueWithIdentifier("login", sender: self)
        }
        
    }
    
    // botón login lanza este método que esconde el teclado, inicia el activity indicator y lanza la petición de login al servidor.
    @IBAction func login(sender: AnyObject) {
        

        if self.loginUsernameText.isFirstResponder() {
            self.loginUsernameText.resignFirstResponder()
        }
        
        if self.loginPasswordText.isFirstResponder() {
            self.loginPasswordText.resignFirstResponder()
        }
        
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        if count(self.loginUsernameText.text) > 0 &&
            count(self.loginPasswordText.text) > 0 {
                
                makeContactsRequest()
                
          
        }
            // en caso de que un campo este vacio se lanza un error.
        else {
            self.displayAlertMessage("Missing Information", alertDescription: "Some of the required parameters are missing")
            self.activityIndicator.stopAnimating()
        }
    }
    
    // Al hacer click en signup aparece una segunda pantalla que maneja el signup.
    //// Botón signup lanza este método que esconde el teclado, inicia el activity indicator y lanza la petición de login al servidor.
    @IBAction func signup(sender: AnyObject) {
        if self.signupUsernameText.isFirstResponder() {
            self.signupUsernameText.resignFirstResponder()
        }
        
        if self.signupPasswordText.isFirstResponder() {
            self.signupPasswordText.resignFirstResponder()
        }
        
        if self.signupPhoneNumberText.isFirstResponder() {
            self.signupPhoneNumberText.resignFirstResponder()
        }
        
        // start activity indicator
        self.activityIndicator2.hidden = false
        self.activityIndicator2.startAnimating()
        
        if count(self.signupUsernameText.text) > 0 && count(self.signupPasswordText.text) > 0
            && count(self.signupPhoneNumberText.text) > 0 {
                makeSignUpRequest(self.signupUsernameText.text, password: self.signupPasswordText.text,
                    phone: self.signupPhoneNumberText.text)
        } else {
            self.displayAlertMessage("Parameters Required", alertDescription:
                "Some of the required parameters are missing")
            self.activityIndicator2.stopAnimating()
        }
        
        
    }
    
    //método de conveniencia para lanzar una alert.
    func displayAlertMessage(header:String, alertDescription:String)
    {
        let alertVC = UIAlertController(title: header, message: alertDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
        
    }
    
    //método que hace la request al servidor para hacer Sign Up.
    func makeSignUpRequest(username:String, password:String, phone: String)
    {
        //Se crea la request
        let httpRequest = apiHelper.buildRequest("users/signup", method: "POST")
        
        // Se envía el body de la request
        httpRequest.HTTPBody = "{\"username\":\"\(username)\",\"password\":\"\(password)\",\"phoneNumber\":\"\(phone)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Se envía la request
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            if error != nil {
                let errorMessage = self.apiHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                
                return
            }
            self.activityIndicator2.stopAnimating()
            self.performSegueWithIdentifier("home", sender: self)
            self.displayAlertMessage("Success", alertDescription: "Account has been created")
        })
        
    }
    
    //método que hace la request al servidor para hacer Sign In.
    func makeSignInRequest(username:String, password:String) {
        
        
        // Se crea la request
        let httpRequest = apiHelper.buildRequest("users/signin", method: "POST")
        
        // Se crea el body de la request
        httpRequest.HTTPBody = "{\"username\":\"\(username)\",\"password\":\"\(password)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        
        //Se envía la request
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Muestra el error
            if error != nil {
                let errorMessage = self.apiHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                
                return
            }
            
            self.activityIndicator.stopAnimating()
            var jsonerror:NSError?
            let response = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as! NSDictionary
            
            self.updateUserLoggedInFlag(response, username: username)
        })
        
    }
    
    //método que hace la request al servidor para a partir de un array de numeros de la agenda obtener usernames que tengan un numero en ese array
    func makeContactsRequest(){
        var error:NSError?
        
        //se crea la referencia a la addressbook
        self.addressbook.createAddressBook()
        
        //Se crea un array de strings y se llena con todos los numeros de la addressbook del sistema
        var contacts: [String] = self.addressbook.getPhoneNumbers()
        
        //Se envía la request para enviar el array
        let httpRequest = apiHelper.uploadRequest("users/contacts", data: nil, owner: "none", friends: contacts)
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            
            if error != nil {
                let errorMessage = self.apiHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                
                return
            }
            
            var jsonerror:NSError?
            let response = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as? NSArray
            
            if response != nil {
                var contactsList : [String] = []
                for contactsData in response as! [AnyObject]
                {
                    if contactsData.valueForKey("username")! as! NSObject != NSNull(){
                        //Se lee la response y se almacena un array de usernames
                        contactsList.append(contactsData.valueForKey("username")! as! String)
                    }
                }
                //Se almacenan los contactos en los User Defaults
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(contactsList, forKey: "contacts")
            }
                //Se realiza la petición de Sign In
                self.makeSignInRequest(self.loginUsernameText.text, password: self.loginPasswordText.text)
            })
    }
    
    //Metodo que crea un flag en la aplicacion para que si un usuario se ha loggeado no se tenga que volver a loggear
    func updateUserLoggedInFlag(response: NSDictionary, username: String) {
        
        if response.valueForKey("success") as! Bool == true
        {
            let defaults = NSUserDefaults.standardUserDefaults()
            //Se almacena el username y un flag loggedIn.
            defaults.setObject("loggedIn", forKey: "userLoggedIn")
            defaults.setObject(username, forKey: "username")
            defaults.synchronize()
            
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    //Un wind para regresar a la pagina de login.
    @IBAction func unwindHome(sender: UIStoryboardSegue){
        
    }
    
}
