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
                
                
        } else {
            self.displayAlertMessage("Missing Information", alertDescription: "Some of the required parameters are missing")
            self.activityIndicator.stopAnimating()
        }
    }
    
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
    func displayAlertMessage(header:String, alertDescription:String)
    {
        let alertVC = UIAlertController(title: header, message: alertDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
        
    }
    
    func makeSignUpRequest(username:String, password:String, phone: String)
    {   let httpRequest = apiHelper.buildRequest("users/signup", method: "POST")
        
        // 3. Send the request Body
        httpRequest.HTTPBody = "{\"username\":\"\(username)\",\"password\":\"\(password)\",\"phoneNumber\":\"\(phone)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // 4. Send the request
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
    
    func makeSignInRequest(username:String, password:String) {
        // Create HTTP request and set request Body
        let httpRequest = apiHelper.buildRequest("users/signin", method: "POST")
        
        httpRequest.HTTPBody = "{\"username\":\"\(username)\",\"password\":\"\(password)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
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
    
    func makeContactsRequest(){
        var error:NSError?
        self.addressbook.createAddressBook()
        var contacts: [String] = self.addressbook.getPhoneNumbers()
        //println(contacts.description)
               let httpRequest = apiHelper.uploadRequest("users/contacts", data: nil, owner: "none", friends: contacts)
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
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
                        
                        contactsList.append(contactsData.valueForKey("username")! as! String)
                    }
                }
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(contactsList, forKey: "contacts")
            }
            
                self.makeSignInRequest(self.loginUsernameText.text, password: self.loginPasswordText.text)
            })
    }
    
    func updateUserLoggedInFlag(response: NSDictionary, username: String) {
        
        if response.valueForKey("success") as! Bool == true
        {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("loggedIn", forKey: "userLoggedIn")
            defaults.setObject(username, forKey: "username")
            defaults.synchronize()
            
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    
    @IBAction func unwindHome(sender: UIStoryboardSegue){
        
    }
    
   
//                    var alert = UIAlertController(title: "Sorry", message: "Contacts permission was not granted. Change it on phone settings.", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//                    //TODO: Handler que haga reload en la tableview
//                    self.presentViewController(alert,animated: true, completion: nil)
    
    
    
            
    
        
        
    
    
}
