//
//  Collection.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 05/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class Collection: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let cellIdentifier = "pic"
    var friends = [PhotoFriend]()
    var selectedHeader:Int?
    var selectedItem:Int?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        friends.append(PhotoFriend(name: "gonzo"))
        friends.append(PhotoFriend(name: "roderick"))
        friends.append(PhotoFriend(name: "cora"))
        friends.append(PhotoFriend(name: "javi"))

        friends[0].photos.append(UIImage(named: "prueba1")!)
        friends[1].photos.append(UIImage(named: "prueba2")!)
        friends[2].photos.append(UIImage(named: "prueba1")!)
        friends[2].photos.append(UIImage(named: "prueba2")!)
        friends[2].photos.append(UIImage(named: "prueba3")!)
        friends[3].photos.append(UIImage(named: "prueba4")!)
        friends[3].photos.append(UIImage(named: "prueba3")!)
        friends[3].photos.append(UIImage(named: "prueba2")!)
        friends[3].photos.append(UIImage(named: "prueba1")!)
        




    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return friends.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends[section].photos.count
    }
    
   override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var cell : customCollectionCell = self.collectionView?.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! customCollectionCell
    
    
    cell.picture.image = friends[indexPath.section].photos[indexPath.item]
    
    return cell
    
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "header",
                    forIndexPath: indexPath)
                    as! CollectionHeader
                
                headerView.headerName.text = friends[indexPath.section].name
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
        self.friends = sender.sourceViewController.friends
        self.collectionView?.reloadData()
        self.navigationController?.setToolbarHidden(true, animated: false)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var cell = sender as! customCollectionCell
        if segue.identifier == "photoDetail" {
            
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
