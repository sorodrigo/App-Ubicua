//
//  CollectionTableCell.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 14/06/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import UIKit

class CustomCollectionView: UICollectionView {
    
    var indexPath: NSIndexPath!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class CollectionTableCell: UITableViewCell {
    
    var collectionView: CustomCollectionView!
    //Se inicializa la celda de la tableview y se añade la collectionview, se modifican sus parametros y se registra la celda de la collection view
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(4, 5, 4, 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSizeMake(91, 91)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView = CustomCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.collectionView.registerClass(customCollectionCell.self, forCellWithReuseIdentifier: "collectioncell")
        var cNib:UINib? = UINib(nibName: "customCollectionCell", bundle: nil)
        collectionView.registerNib(cNib, forCellWithReuseIdentifier: "collectioncell")
        self.collectionView.showsHorizontalScrollIndicator = false
        self.contentView.addSubview(self.collectionView)
        self.layoutMargins = UIEdgeInsetsMake(10, 0, 10, 0)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.contentView.bounds
        self.collectionView.frame = CGRectMake(0, 0.5, frame.size.width, frame.size.height - 1)
    }
    //se establece el datasource y delegate, se linkea el indexpath de la tableview con el indexpath de la collectionview.
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, indexPath: NSIndexPath) {
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.indexPath = indexPath
        self.collectionView.tag = indexPath.section
        self.collectionView.reloadData()
    }

}
