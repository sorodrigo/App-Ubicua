//
//  Collection.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 05/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class Collection: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let apiHelper = APIHelper()
    let cellIdentifier = "pic"
    var friends = [String:PhotoFriend]()
    var selectedHeader:Int?
    var selectedItem:Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let username:String = defaults.objectForKey("username") as! String
        if defaults.objectForKey("userLoggedIn") == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("\(username)friends") as? NSData {
            self.friends = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String:PhotoFriend]
        }
        
        self.loadPhotoData()
    }
    
    func loadPhotoData () {
        // Create HTTP request and set request Body
        let defaults = NSUserDefaults.standardUserDefaults()
        let username:String = defaults.objectForKey("username") as! String
        let httpRequest = apiHelper.buildRequest("photos/users/\(username)", method: "GET")
        
        // Send HTTP request to load existing selfie
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.apiHelper.getErrorMessage(error)
                let errorAlert = UIAlertView(title:"Error", message:errorMessage as String, delegate:nil, cancelButtonTitle:"OK")
                errorAlert.show()
                return
            }
            
            var err: NSError?
            
            if let jsonDataArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &err) as? NSArray! {
                // load the collection view with existing selfies
                if jsonDataArray != nil {
                    for imageDataDict in jsonDataArray {
                        for photos in imageDataDict as! [AnyObject] {
                            var owner = photos.valueForKey("owner") as! String
                            var uniqueurl = photos.valueForKey("uniqueurl") as! String
                            
                            if self.friends[owner] == nil {
                                var imgObj = PhotoFriend(owner: owner)
                                imgObj.uniqueurl.append(uniqueurl)
                                self.friends[owner] = imgObj
                            }
                            else
                            {
                                self.friends[owner]?.uniqueurl.append(uniqueurl)
                            }
                        }
                    }
                    let defaults = NSUserDefaults.standardUserDefaults()
                    
                    let data = NSKeyedArchiver.archivedDataWithRootObject(self.friends)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: "\(username)friends")
                    defaults.synchronize()
                    self.collectionView?.reloadData()
                }
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        let username:String = defaults.objectForKey("username") as! String
        let data = NSKeyedArchiver.archivedDataWithRootObject(friends)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "\(username)friends")
        defaults.synchronize()
        
        self.friends.removeAll(keepCapacity: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return friends.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var key: String = Array(friends.keys)[section]
        
        return friends[key]!.uniqueurl.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var key: String = Array(friends.keys)[indexPath.section]
        var cell : customCollectionCell = self.collectionView?.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! customCollectionCell
        
        if friends[key]?.photos.count == indexPath.item {
            var photoUrl = "\(APIHelper.BASE_URL)/photos/\(friends[key]!.uniqueurl[indexPath.item])"
            println(photoUrl)
            var imgURL: NSURL = NSURL(string: photoUrl)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        var image = UIImage(data: data)
                        self.friends[key]!.photos.append(image!)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.picture.image = image
                        })
                        let defaults = NSUserDefaults.standardUserDefaults()
                        let username:String = defaults.objectForKey("username") as! String
                        let data = NSKeyedArchiver.archivedDataWithRootObject(self.friends)
                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "\(username)friends")
                        defaults.synchronize()
                        
                    } else {
                        println("Error: \(error.localizedDescription)")
                    }
            })
            
        }
        else
        {
            cell.picture.image = friends[key]?.photos[indexPath.item]
        }
        
        return cell
        
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            var key: String = Array(friends.keys)[indexPath.section]
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "header",
                    forIndexPath: indexPath)
                    as! CollectionHeader
                
                headerView.headerName.text = friends[key]?.owner
                return headerView
            default:
                
                assert(false, "Unexpected element kind")
            }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var selectedCell:customCollectionCell = collectionView.cellForItemAtIndexPath(indexPath) as! customCollectionCell
        
        self.selectedHeader = indexPath.section
        self.selectedItem = indexPath.item
        
        self.performSegueWithIdentifier("photoDetail", sender: selectedCell)
        
    }
    
    @IBAction func unwindDetailedPhoto(sender: UIStoryboardSegue){
        
        if sender.identifier == "unwindDetailedPhotoID"
        {
            self.friends = sender.sourceViewController.friends
            self.collectionView?.reloadData()
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "photoDetail" {
            var cell = sender as! customCollectionCell
            let destinationVC = segue.destinationViewController as! DetailedPhoto
            destinationVC.photo = cell.picture.image
            destinationVC.friends = self.friends
            destinationVC.selectedHeader = self.selectedHeader!
            destinationVC.selectedItem = self.selectedItem!
            
        }
    }
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
