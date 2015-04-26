//SwiftAddressBook - A strong-typed Swift Wrapper for ABAddressBook
//Copyright (C) 2014  Socialbit GmbH
//
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see http://www.gnu.org/licenses/ .
//If you would to like license this software for non-free commercial use,
//please write us at kontakt@socialbit.de .

import UIKit
import AddressBook

//MARK: global address book variable

public let swiftAddressBook : SwiftAddressBook? = SwiftAddressBook(0)

//MARK: Address Book

public class SwiftAddressBook {
    
    public var internalAddressBook : ABAddressBook!
    
    private init?(_ dummy : Int) {
        var err : Unmanaged<CFError>? = nil
        let ab = ABAddressBookCreateWithOptions(nil, &err)
        if err == nil {
            internalAddressBook = ab.takeRetainedValue()
        }
        else {
            return nil
        }
    }
    
    public class func authorizationStatus() -> ABAuthorizationStatus {
        return ABAddressBookGetAuthorizationStatus()
    }
    
    public func requestAccessWithCompletion( completion : (Bool, CFError?) -> Void ) {
        ABAddressBookRequestAccessWithCompletion(internalAddressBook) {(let b : Bool, c : CFError!) -> Void in completion(b,c)}
    }
    
    public func hasUnsavedChanges() -> Bool {
        return ABAddressBookHasUnsavedChanges(internalAddressBook)
    }
    
    public func save() -> CFError? {
        return errorIfNoSuccess { ABAddressBookSave(self.internalAddressBook, $0)}
    }
    
    public func revert() {
        ABAddressBookRevert(internalAddressBook)
    }
    
    public func addRecord(record : SwiftAddressBookRecord) -> CFError? {
        return errorIfNoSuccess { ABAddressBookAddRecord(self.internalAddressBook, record.internalRecord, $0) }
    }
    
    public func removeRecord(record : SwiftAddressBookRecord) -> CFError? {
        return errorIfNoSuccess { ABAddressBookRemoveRecord(self.internalAddressBook, record.internalRecord, $0) }
    }
    
//    //This function does not yet work
//    public func registerExternalChangeCallback(callback: (AnyObject) -> Void) {
//        //call some objective C function (c function pointer does not work in swift)
//    }
//
//    //This function does not yet work
//    public func unregisterExternalChangeCallback(callback: (AnyObject) -> Void) {
//        //call some objective C function (c function pointer does not work in swift)
//    }
    
    
    //MARK: person records
    
    public var personCount : Int {
        get {
            return ABAddressBookGetPersonCount(internalAddressBook)
        }
    }
    
    public func personWithRecordId(recordId : Int32) -> SwiftAddressBookPerson? {
        return SwiftAddressBookRecord(record: ABAddressBookGetPersonWithRecordID(internalAddressBook, recordId).takeUnretainedValue()).convertToPerson()
    }
    
    public var allPeople : [SwiftAddressBookPerson]? {
        get {
            return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeople(internalAddressBook).takeRetainedValue())
        }
    }
    
    public func allPeopleInSource(source : SwiftAddressBookSource) -> [SwiftAddressBookPerson]? {
        return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeopleInSource(internalAddressBook, source.internalRecord).takeRetainedValue())
    }
    
    public func allPeopleInSourceWithSortOrdering(source : SwiftAddressBookSource, ordering : SwiftAddressBookOrdering) -> [SwiftAddressBookPerson]? {
        return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(internalAddressBook, source.internalRecord, ordering.abPersonSortOrderingValue).takeRetainedValue())
    }
	
	public func peopleWithName(name : String) -> [SwiftAddressBookPerson]? {
		return convertRecordsToPersons(ABAddressBookCopyPeopleWithName(internalAddressBook, name).takeRetainedValue())
	}


    //MARK: group records
    
    public func groupWithRecordId(recordId : Int32) -> SwiftAddressBookGroup? {
        return SwiftAddressBookRecord(record: ABAddressBookGetGroupWithRecordID(internalAddressBook, recordId).takeUnretainedValue()).convertToGroup()
    }
    
    public var groupCount : Int {
        get {
            return ABAddressBookGetGroupCount(internalAddressBook)
        }
    }
    
    public var arrayOfAllGroups : [SwiftAddressBookGroup]? {
        get {
            return convertRecordsToGroups(ABAddressBookCopyArrayOfAllGroups(internalAddressBook).takeRetainedValue())
        }
    }
    
    public func allGroupsInSource(source : SwiftAddressBookSource) -> [SwiftAddressBookGroup]? {
        return convertRecordsToGroups(ABAddressBookCopyArrayOfAllGroupsInSource(internalAddressBook, source.internalRecord).takeRetainedValue())
    }
    
    
    //MARK: sources
    
    public var defaultSource : SwiftAddressBookSource? {
        get {
            return SwiftAddressBookSource(record: ABAddressBookCopyDefaultSource(internalAddressBook).takeRetainedValue())
        }
    }
    
    public func sourceWithRecordId(sourceId : Int32) -> SwiftAddressBookSource? {
        return SwiftAddressBookSource(record: ABAddressBookGetSourceWithRecordID(internalAddressBook, sourceId).takeUnretainedValue())
    }
    
    public var allSources : [SwiftAddressBookSource]? {
        get {
            return convertRecordsToSources(ABAddressBookCopyArrayOfAllSources(internalAddressBook).takeRetainedValue())
        }
    }
    
}


