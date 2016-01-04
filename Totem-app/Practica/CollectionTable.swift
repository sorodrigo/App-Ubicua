//
//  CollectionTable.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 14/06/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class CollectionTable: UITableViewController {
    
    let apiHelper = APIHelper()
    var friends = [String:PhotoFriend]()
    var selectedHeader:Int?
    var selectedItem:Int?
    var contentOffsetDictionary: NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(CollectionTableCell.self, forCellReuseIdentifier: "tablecell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.registerClass(HeaderCell.self, forCellReuseIdentifier: "HeaderCell")
        var cNib:UINib? = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(cNib!, forCellReuseIdentifier: "HeaderCell")
        self.contentOffsetDictionary = NSMutableDictionary()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //Se lee el nombre de usuario y se comprueba que el usuario esta loggeado
        let defaults = NSUserDefaults.standardUserDefaults()
        let username:String = defaults.objectForKey("username") as! String
        if defaults.objectForKey("userLoggedIn") == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        //Se leen las fotos previamente descargadas que se habian almacenado en memoria
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("\(username)friends") as? NSData {
            self.friends = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String:PhotoFriend]
        }
        //PULL: Se descarga la informacion de las fotos de usuario
        self.loadPhotoData()
        self.tableView.reloadData()
    }
    
    func loadPhotoData () {
        // Se crea una http request para descargar la informacion de las fotos recibidas
        let defaults = NSUserDefaults.standardUserDefaults()
        let username:String = defaults.objectForKey("username") as! String
        let httpRequest = apiHelper.buildRequest("photos/users/\(username)", method: "GET")
        
        //Se envia la request
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            
            if error != nil {
                let errorMessage = self.apiHelper.getErrorMessage(error)
                let errorAlert = UIAlertView(title:"Error", message:errorMessage as String, delegate:nil, cancelButtonTitle:"OK")
                errorAlert.show()
                return
            }
            
            var err: NSError?
            
            if let jsonDataArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &err) as? NSArray! {
                // Se lee la respuesta que contiene las personas que han enviado fotos al usuario y los URL
                //el servidor envia las fotos recibidas a partir de la fecha de la descarga anterior
                if jsonDataArray != nil {
                    for imageDataDict in jsonDataArray {
                        for photos in imageDataDict as! [AnyObject] {
                            var owner = photos.valueForKey("owner") as! String
                            var uniqueurl = photos.valueForKey("uniqueurl") as! String
                            //Si es la primera vez que ese usuario te envia una foto se crea un nuevo PhotoFriend
                            if self.friends[owner] == nil {
                                var imgObj = PhotoFriend(owner: owner)
                                imgObj.uniqueurl.append(uniqueurl)
                                self.friends[owner] = imgObj
                            }
                            else
                            {   //En caso contrario se añade el URL al PhotoFriend que ha enviado la foto
                                self.friends[owner]?.uniqueurl.append(uniqueurl)
                            }
                        }
                    }
                    let defaults = NSUserDefaults.standardUserDefaults()
                    //Despues de la descarga se actualizan los user defaults y se recarga la vista
                    let data = NSKeyedArchiver.archivedDataWithRootObject(self.friends)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: "\(username)friends")
                    defaults.synchronize()
                    self.tableView?.reloadData()
                }
                
            }
        })
    }
    
    //Metodo encargado de hacer log out.
    @IBAction func logout(sender: AnyObject) {
        //Se elimina el flag userLoggedIn
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userLoggedIn")
        let username:String = defaults.objectForKey("username") as! String
        let data = NSKeyedArchiver.archivedDataWithRootObject(friends)
        //Se almacenan los photofriends en los user defaults
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "\(username)friends")
        defaults.synchronize()
        
        //Se decarta la vista
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //Unwind a la collection view
    @IBAction func unwindDetailedPhoto(sender: UIStoryboardSegue){
        
        //Si es llamado desde la vista DetailedPhoto se actualizan la variable friends
        if sender.identifier == "unwindDetailedPhotoID"
        {
            self.friends = sender.sourceViewController.friends
            self.tableView?.reloadData()
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Se hace segue a DetailedPhoto y se pasan los valores de la foto seleccionada, su indice de foto y seccion y el diccionario de photofriends
        if segue.identifier == "photoDetail" {
            var cell = sender as! customCollectionCell
            let destinationVC = segue.destinationViewController as! DetailedPhoto
            destinationVC.photo = cell.picture!.image
            destinationVC.friends = self.friends
            destinationVC.selectedHeader = self.selectedHeader!
            destinationVC.selectedItem = self.selectedItem!
            
        }
    }
    
}
    // MARK: - Table view data source
    extension CollectionTable {
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("tablecell", forIndexPath: indexPath) as! CollectionTableCell
            return cell
        }
        
        override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            let collectionCell: CollectionTableCell = cell as! CollectionTableCell
            collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, indexPath: indexPath)
            let index: NSInteger = collectionCell.collectionView.tag
            let value: AnyObject? = self.contentOffsetDictionary.valueForKey(index.description)
            let horizontalOffset: CGFloat = CGFloat(value != nil ? value!.floatValue : 0)
            collectionCell.collectionView.setContentOffset(CGPointMake(horizontalOffset, 0), animated: false)
        }
        
        override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 100
        }
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return self.friends.count
        }
        
        //metodo encargado de pintar las headers de cada seccion
        override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
            var key: String = Array(friends.keys)[section]
            
            headerCell.headerLabel.text = friends[key]?.owner
            
            return headerCell
        }
        //tamaño de header
        override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 43.0
        }
}

// MARK: - Collection View Data source and Delegate
extension CollectionTable: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        var key: String = Array(friends.keys)[collectionView.tag]
        return self.friends[key]!.uniqueurl.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: customCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectioncell", forIndexPath: indexPath) as! customCollectionCell
        var key: String = Array(friends.keys)[collectionView.tag]
        // AQUI SE ESTABLECE LA IMAGEN
        //Si el numero de fotos en la seccion que se esta pintando es igual al indice de foto actual, significa que el indice es mayor que el numero de fotos descargadas y se procede a descargar las fotos restantes
        if friends[key]?.photos.count <= indexPath.item {
            //Se realiza la request de url almacenado en el photofriend actual
            var photoUrl = "\(APIHelper.BASE_URL)/photos/\(friends[key]!.uniqueurl[indexPath.item])"
            println(photoUrl)
            var imgURL: NSURL = NSURL(string: photoUrl)!
            
            // Se descarga una representacion de la foto en NSData
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            //Se envía la request asincronamente para no bloquear la interfaz
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        //Se crea y se añade la foto al diccionario de photofriends
                        var image = UIImage(data: data)
                        self.friends[key]!.photos.append(image!)
                        //Se pinta
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.picture.image = image
                        })
                        //Se actualizan los user defaults
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
        {   //Si el numero de fotos en la seccion que se esta pintando es menor al indice, se carga la foto de memoria.
            cell.picture.image = friends[key]?.photos[indexPath.item]
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // AQUI SE HACE EL SEGUE A LA DETAILED VIEW
        var selectedCell:customCollectionCell = collectionView.cellForItemAtIndexPath(indexPath) as! customCollectionCell
        
        self.selectedHeader = collectionView.tag
        self.selectedItem = indexPath.item
        
        self.performSegueWithIdentifier("photoDetail", sender: selectedCell)
    }
    //control del scroll 
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(UICollectionView) {
            return
        }
        let horizontalOffset: CGFloat = scrollView.contentOffset.x
        let collectionView: UICollectionView = scrollView as! UICollectionView
        self.contentOffsetDictionary.setValue(horizontalOffset, forKey: collectionView.tag.description)
}
    

}