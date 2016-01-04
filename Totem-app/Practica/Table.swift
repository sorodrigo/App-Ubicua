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
    
    var tableDict = [String:[String]]()
    var photo:UIImage?
    var friendSet = NSMutableSet()
    var friends = [String]()
    let cellIdentifier = "cell"
    let apiHelper = APIHelper()
    var sectionsArray: [String]!
    var indexArray: [String]!
    
    @IBOutlet weak var flex1: UIBarButtonItem!
    @IBOutlet weak var flex2: UIBarButtonItem!
    @IBOutlet weak var sendBarButton: UIBarButtonItem!
    
    //Se cargan los contactos con cuenta desde los user defaults
    override func viewDidLoad() {
        indexArray = ["#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
        let defaults = NSUserDefaults.standardUserDefaults()
        
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(true, animated: false)
        tableDict = getDictionary(defaults.objectForKey("contacts") as! [String])
        sectionsArray = Array(tableDict.keys).sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    //crea diccionario con la inicial como clave a partir del array de strings recibidos
    func getDictionary(contacts: [String]) ->[String:[String]]{
        var dict = [String:[String]]()
        
        for contact in contacts{
            var charIndex:String = (contact as NSString).substringToIndex(1)
            charIndex = charIndex.capitalizedString
            if contains(indexArray, charIndex){
                if (dict[charIndex] == nil){
                    dict[charIndex] = [contact]
                }
                else{
                    dict[charIndex]?.append(contact)
                }
            }
            else if dict["#"] == nil {
                
                dict["#"] = [contact]
            }
            else {
                dict["#"]?.append(contact)
            }
            
            
            
        }
        return dict
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return sectionsArray.count
    }
    //Se pinta una celda por cada contacto
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var key = sectionsArray[section]
        return tableDict[key]!.count
    }
    
    //Se pintan las celdas
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var key = sectionsArray[indexPath.section]
        var cell:customTableCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! customTableCell
        
        cell.textCell.text = tableDict[key]![indexPath.row] as String
        cell.imageCell.image = UIImage(named:"bluecircle")
        
        return cell
        
        
    }
    
    //Si se selecciona una celda se cambia marca la celda seleccionada y se muestra la toolbar con un contador de contactos seleccionados
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var key = sectionsArray[indexPath.section]
        var selectedCell:customTableCell = tableView.cellForRowAtIndexPath(indexPath) as! customTableCell
        selectedCell.imageCell.image = UIImage(named:"greencircle")
        
        var enviar:String
        let row = indexPath.row
        var nombre:String = tableDict[key]![indexPath.row] as String
        self.friendSet.addObject(nombre)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        enviar = "Send (\(self.friendSet.count.description))"
        
        self.sendBarButton.title = enviar
        
    }
    //Si se deselecciona una celda se revierte al estado inicial y se decrece el contador de contactos seleccionados, en caso de que no haya ninguno se esconde a toolbar
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var key = sectionsArray[indexPath.section]
        var selectedCell:customTableCell = tableView.cellForRowAtIndexPath(indexPath) as! customTableCell
        selectedCell.imageCell.image = UIImage(named:"bluecircle")
        
        var enviar:String
        let row = indexPath.row
        var nombre:String = tableDict[key]![indexPath.row] as String
        self.friendSet.removeObject(nombre)
        
        if self.friendSet.count == 0
        {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        enviar = "Send (\(self.friendSet.count.description))"
        self.sendBarButton.title = enviar
    }
    
    //titulo de seccion
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //Array(friendsDiccionario.keys)[section]
        return sectionsArray[section]
    }
    
    //indices
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return indexArray
    }
    
    //Al hacer click busca en el array de secciones existentes el indice de la tabla
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String,
        atIndex index: Int)
        -> Int {
            return (sectionsArray as NSArray).indexOfObject(title)
    }
    
    @IBAction func send(sender: AnyObject) {
        
        //self.activityIndicator.hidden = false
        //self.activityIndicator.startanimating()
        let defaults = NSUserDefaults.standardUserDefaults()
        let username:String = defaults.objectForKey("username") as! String
        self.friends = self.friendSet.allObjects as! [String]
        
        // Se crea la request multipart con la foto en NSData
        var imgData : NSData = UIImagePNGRepresentation(photo)
        let httpRequest = apiHelper.uploadRequest("photos/upload", data: imgData, owner: "\(username)", friends: self.friends)
        apiHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Se muestra el error
            if error != nil {
                let errorMessage = self.apiHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                
                return
            }
            
            var jsonerror:NSError?
            let response = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as! NSDictionary
            //Si se ha enviado correctamente se descarta la vista y se regresa a la camara.
            if response.valueForKey("success") as! Bool == true
            {
                //self.activityIndicatorView.hidden = true
                self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        
        
    }
    //metodo de conveniencia para mostrar los errores
    func displayAlertMessage(header:String, alertDescription:String)
    {
        let alertVC = UIAlertController(title: header, message: alertDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
        
    }
    
}