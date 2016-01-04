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
    var friends = [String:PhotoFriend]() //diccionario de photofriends con el owner como clave
    var selectedHeader:Int?
    var selectedItem:Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
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
                    self.collectionView?.reloadData()
                }
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    // MARK: - Collection view data source
    
    //Se inicializan las secciones de la collection con el numero de PhotoFriends que tiene el usuario
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return friends.count
    }
    //Cada seccion se inicializa con el numero de fotos de su propietario
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var key: String = Array(friends.keys)[section]
        
        return friends[key]!.uniqueurl.count
    }
    
    //Metodo encargado de cargar las fotos desde memoria o desde internet
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var key: String = Array(friends.keys)[indexPath.section]
        var cell : customCollectionCell = self.collectionView?.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! customCollectionCell
        
        //Si el numero de fotos en la seccion que se esta pintando es igual al indice de foto actual, significa que el indice es mayor que el numero de fotos descargadas y se procede a descargar las fotos restantes
        if friends[key]?.photos.count == indexPath.item {
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
                            cell.picture!.image = image
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
            cell.picture!.image = friends[key]?.photos[indexPath.item]
        }
        
        return cell
        
    }
    //metodo encargado de pintar las headers de cada seccion
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
                //Se pinta el nombre de propietario en la header
                headerView.headerName.text = friends[key]?.owner
                return headerView
            default:
                
                assert(false, "Unexpected element kind")
            }
    }
    
    //Al hacer click en una foto se lanza el segue photodetail
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var selectedCell:customCollectionCell = collectionView.cellForItemAtIndexPath(indexPath) as! customCollectionCell
        
        self.selectedHeader = indexPath.section
        self.selectedItem = indexPath.item
        
        self.performSegueWithIdentifier("photoDetail", sender: selectedCell)
        
    }
    //Unwind a la collection view
    @IBAction func unwindDetailedPhoto(sender: UIStoryboardSegue){
        
        //Si es llamado desde la vista DetailedPhoto se actualizan la variable friends
        if sender.identifier == "unwindDetailedPhotoID"
        {
            self.friends = sender.sourceViewController.friends
            self.collectionView?.reloadData()
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
