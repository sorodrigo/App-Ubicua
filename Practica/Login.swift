//
//  Login.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 16/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class Login: UIViewController {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func login(sender: AnyObject) {
        
        self.performSegueWithIdentifier("login", sender: sender)
    }
   
}
