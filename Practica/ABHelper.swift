//
//  ABHelper.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 01/06/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI

class ABHelper {
    
    var addressBook: ABAddressBookRef?
    
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
    
    func getPhoneNumbers() -> [String] {
        
        var contacts: [String] = []
        let people = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as NSArray as [ABRecord]
        for person in people {
            
            let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
            let phones: ABMultiValueRef =
            Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
                as NSObject as ABMultiValueRef
            
            let countOfPhones = ABMultiValueGetCount(phones)
            
            for index in 0..<countOfPhones{
                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
                let phone: String = Unmanaged.fromOpaque(unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
                
                var a = phone.stringByReplacingOccurrencesOfString("(", withString: "")
                var b = a.stringByReplacingOccurrencesOfString(")", withString: "")
                var c = b.stringByReplacingOccurrencesOfString("-", withString: "")
                var d = c.stringByReplacingOccurrencesOfString(" ", withString: "")
                var e = d.stringByReplacingOccurrencesOfString(String(Character(UnicodeScalar(160))), withString: "")
                var strPhone = e.stringByReplacingOccurrencesOfString("+", withString: "")
                
                contacts.append(strPhone)
                
            }
        }
        return contacts
    }
}