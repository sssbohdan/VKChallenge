//
//  LoadedCollectionViewCell.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

final class LoadedCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet private weak var loadedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadedLabel.textColor = UIColor(red:0.56, green:0.58, blue:0.60, alpha:1.00)
    }
    
    func configure(loaded: Int) {
        self.loadedLabel?.text = "Loaded: \(loaded)"
    }
}
