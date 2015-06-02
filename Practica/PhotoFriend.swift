//
//  PhotoFriend.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 07/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import Foundation
import UIKit

class PhotoFriend: NSObject, NSCoding {
    var owner: String = ""
    var uniqueurl = [String]()
    var photos = [UIImage]()
    
    init(owner: String)
    {
        self.owner = owner;
    }
    
    required init(coder aDecoder: NSCoder) {
        self.owner = aDecoder.decodeObjectForKey("owner") as! String
        self.uniqueurl = aDecoder.decodeObjectForKey("uniqueurl") as! [String]
        self.photos = aDecoder.decodeObjectForKey("photos") as! [UIImage]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(owner, forKey: "owner")
        aCoder.encodeObject(uniqueurl, forKey: "uniqueurl")
        aCoder.encodeObject(photos, forKey: "photos")

    }
    
    
}