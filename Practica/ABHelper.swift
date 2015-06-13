//
//  ABHelper.swift
//  Practica
//
//  Created by Rodrigo SolÌs Morales on 01/06/15.
//  Copyright (c) 2015 Rodrigo SolÌs Morales. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI

class ABHelper {
    
    var addressBook: ABAddressBookRef?
    
    //En esta funcion solicitaremos al sistema operativo permiso para acceder a la agenda de contactos del propio sistema operativo
    
    func createAddressBook() -> Bool {
        var status = true
        var error: Unmanaged<CFErrorRef>? = nil
        
        self.addressBook = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        
        if self.addressBook == nil {
            println(error?.takeRetainedValue())
            
        }
        
        ABAddressBookRequestAccessWithCompletion(self.addressBook) {
            (granted, error) in
            if !granted {
                
                status = false
                return
            }
        }
        
        return status
    }
    
    //En esta funcion conseguiremos devolver los contactos creados con el numero de telefono que nos proporciona el sistema operativo
    
    func getPhoneNumbers() -> [String] {
        
        var contacts: [String] = [] // variable donde almacenar los contactos que devolveremos
        //se leen todos los contactos de SO
        let people = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as NSArray as [ABRecord]
        for person in people {
            
            let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
            let phones: ABMultiValueRef =
            Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
                as NSObject as ABMultiValueRef
            
            let countOfPhones = ABMultiValueGetCount(phones)
            //Se recorren todos los numeros de un contacto
            for index in 0..<countOfPhones{
                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
                let phone: String = Unmanaged.fromOpaque(unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
                
                var a = phone.stringByReplacingOccurrencesOfString("(", withString: "")
                var b = a.stringByReplacingOccurrencesOfString(")", withString: "")
                var c = b.stringByReplacingOccurrencesOfString("-", withString: "")
                var d = c.stringByReplacingOccurrencesOfString(" ", withString: "")
                var e = d.stringByReplacingOccurrencesOfString(String(Character(UnicodeScalar(160))), withString: "")
                var strPhone = e.stringByReplacingOccurrencesOfString("+", withString: "")
                //Se añade cada numero al array
                contacts.append(strPhone)
                
            }
        }
        return contacts
    }
}
