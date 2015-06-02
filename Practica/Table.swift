//
//  Table.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 17/04/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit


class Table: UITableViewController,UITableViewDataSource, UITableViewDelegate
{
    
    var tableArray = [String]()
    var photo:UIImage?
    var friendSet = NSMutableSet()
    var friends = [String]()
    let cellIdentifier = "cell"
    let apiHelper = APIHelper()
    
    @IBOutlet weak var flex1: UIBarButtonItem!
    @IBOutlet weak var flex2: UIBarButtonItem!
    @IBOutlet weak var sendBarButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.tableArray = defaults.objectForKey("contacts") as! [String]
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
        
        var cell:customTableCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! customTableCell
        
        cell.textCell.text = (tableArray[indexPath.row] as String)
        cell.imageCell.image = UIImage(named:"bluecircle")
        
        return cell
        
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedCell:customTableCell = tableView.cellForRowAtIndexPath(indexPath) as! customTableCell
        selectedCell.imageCell.image = UIImage(named:"greencircle")
        
        var enviar:String
        let row = indexPath.row
        var nombre:String = tableArray[row] as String
        self.friendSet.addObject(nombre)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        enviar = "Send (\(self.friendSet.count.description))"
        
        self.sendBarButton.title = enviar
        
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:customTableCell = tableView.cellForRowAtIndexPath(indexPath) as! customTableCell
        selectedCell.imageCell.image = UIImage(named:"bluecircle")
        
        var enviar:String
        let row = indexPath.row
        var nombre:String = tableArray[row] as String
        self.friendSet.removeObject(nombre)
        
        if self.friendSet.count == 0
        {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        enviar = "Send (\(self.friendSet.count.description))"
        self.sendBarButton.title = enviar
    }
    
    @IBAction func send(sender: AnyObject) {
        
        //self.activityIndicator.hidden = false
        //self.activityIndicator.startanimating()
        let defaults = NSUserDefaults.standardUserDefaults()
        let username:String = defaults.objectForKey("username") as! String
        self.friends = self.friendSet.allObjects as! [String]
        
        // Create Multipart Upload request
        var imgData : NSData = UIImagePNGRepresentation(photo)
        let httpRequest = apiHelper.uploadRequest("photos/upload", data: imgData, owner: "\(username)", friends: self.friends)
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.apiHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                
                return
            }
            
            var jsonerror:NSError?
            let response = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as! NSDictionary
            
            if response.valueForKey("success") as! Bool == true
            {
                //self.activityIndicatorView.hidden = true
                self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        
        
    }
    
    func displayAlertMessage(header:String, alertDescription:String)
    {
        let alertVC = UIAlertController(title: header, message: alertDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
        
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
