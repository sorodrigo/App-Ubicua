//
//  Table.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 17/04/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class Table: UITableViewController,UITableViewDataSource, UITableViewDelegate
{
    
    var tableArray = NSMutableArray()
    
    var rowSet = NSMutableSet()
    let cellIdentifier = "cell"
    
    
    @IBOutlet weak var flex1: UIBarButtonItem!
    @IBOutlet weak var flex2: UIBarButtonItem!
    @IBOutlet weak var sendBarButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getContacts()
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        var nib = UINib(nibName: "customCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return tableArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:customCellController = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! customCellController
        
        // Configure the cell..
        
        let row = indexPath.row
        cell.textCell.text = tableArray[row] as! String
        cell.imageCell.image = UIImage(named:"bluecircle")
        
        return cell
        
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedCell:customCellController = tableView.cellForRowAtIndexPath(indexPath) as! customCellController
        //selectedCell.contentView.backgroundColor = UIColor.whiteColor()
        selectedCell.imageCell.image = UIImage(named:"greencircle")
        
        var enviar:String
        let row = indexPath.row
        var nombre:String = tableArray[row] as! String
        self.rowSet.addObject(nombre)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        enviar = "Send ("
        enviar += self.rowSet.count.description
        enviar += ")"
        self.sendBarButton.title = enviar
        
        
        println(self.rowSet.description)
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:customCellController = tableView.cellForRowAtIndexPath(indexPath) as! customCellController
        selectedCell.contentView.backgroundColor = UIColor.whiteColor()
        selectedCell.imageCell.image = UIImage(named:"bluecircle")
        
        var enviar:String
        let row = indexPath.row
        var nombre:String = tableArray[row] as! String
        self.rowSet.removeObject(nombre)
        
        if self.rowSet.count == 0
        {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        enviar = "Send ("
        enviar += self.rowSet.count.description
        enviar += ")"
        self.sendBarButton.title = enviar
        
        println(self.rowSet.description)
    }
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    @IBAction func send(sender: AnyObject) {
        
        var param = [
            "title" : "mono",
            "usuario" : "Gonzalo"
        ]
        
        let image = UIImage(named: "babybaboon.png")
        let imgData = UIImagePNGRepresentation(image)
        
        let urlRequest = urlRequestWithComponents("http://localhost:8080/upload", parameters: param, imageData: imgData)
        
        upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
               
            }
            .responseJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
               var r = response!.statusCode.description.toInt()
                println("RESPONSE \(r)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
                
                if r == 200 {
                
                    self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                }
        }
    }
    
    func getContacts () {
        
        var contacts = NSArray()
        
        let status = ABAddressBookGetAuthorizationStatus()
        if status == .Denied || status == .Restricted {
            // user previously denied, to tell them to fix that in settings
            println("not granted before")
        }
        
        var error: Unmanaged<CFErrorRef>? = nil
        
        var addressBook: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        
        if addressBook == nil {
            println(error?.takeRetainedValue())
            
        }
        
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            (granted, error) in
            if !granted {
                // warn the user that because they just denied permission, this functionality won't work
                // also let them know that they have to fix this in settings
                println("not granted")
            }
            
            if let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() as? NSArray {
                // now do something with the array of people
                println("asignando contacts")
                //self.tableArray = ["Pedro", "Pablo", "Luis", "Juan", "John", "Mike", "Hendricks", "Gordons", "Larios", "Grey", "Goose", "Walker"]
            
                var i = 0;
                for person:ABRecordRef in people {
                    
                    var contactFirstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as? NSString
                    var contactLastName = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue() as? NSString
                    
                    var fullName:String = contactFirstName! as String
                    fullName += " "
                    fullName += contactLastName! as String
                     self.tableArray.insertObject(fullName, atIndex: i)
                }
                
            }
        }
    }
}

/*
// Override to support conditional editing of the table view.
override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
// Return NO if you do not want the specified item to be editable.
return true
}
*/

/*
// Override to support editing the table view.
override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
if editingStyle == .Delete {
// Delete the row from the data source
tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
} else if editingStyle == .Insert {
// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
}
}
*/

/*
// Override to support rearranging the table view.
override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

}
*/

/*
// Override to support conditional rearranging of the table view.
override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
// Return NO if you do not want the item to be re-orderable.
return true
}
*/

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
}
*/
