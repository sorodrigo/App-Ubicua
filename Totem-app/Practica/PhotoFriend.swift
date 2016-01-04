//
//  PhotoFriend.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 07/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import Foundation
import UIKit

//Clase PhotoFriend: Se utiliza para almacenar las fotos descargadas. Contiene un nombre de propietario de la foto, un array de photos tomadas por dicho propietario y un array de URL desde donde se descargan dichas fotos.
class PhotoFriend: NSObject, NSCoding {
    var owner: String = ""
    var uniqueurl = [String]()
    var photos = [UIImage]()
    
    init(owner: String)
    {
        self.owner = owner;
    }
    //Metodo init que se utiliza para implementar el protocolo de serializacion para las user defaults, se deserializan los atributos de un objeto almacenado en User Defaults
    required init(coder aDecoder: NSCoder) {
        self.owner = aDecoder.decodeObjectForKey("owner") as! String
        self.uniqueurl = aDecoder.decodeObjectForKey("uniqueurl") as! [String]
        self.photos = aDecoder.decodeObjectForKey("photos") as! [UIImage]
    }
    
    //Metodo en el que se serializan los atributos de un objeto almacenado en los User Defaults
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(owner, forKey: "owner")
        aCoder.encodeObject(uniqueurl, forKey: "uniqueurl")
        aCoder.encodeObject(photos, forKey: "photos")

    }
    
    
}