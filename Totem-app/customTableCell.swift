//
//  customTableCell.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 07/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class customTableCell: UITableViewCell {

    @IBOutlet weak var textCell: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
