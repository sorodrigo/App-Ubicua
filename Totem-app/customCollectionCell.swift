//
//  customCollectionCell.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 14/06/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class customCollectionCell: UICollectionViewCell {

    @IBOutlet var picture: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
