//
//  PhotoCollectionViewCell.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet private weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        self.photoImageView.cancelLoad()
    }
    
    func configure(imageURL: URL?, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.photoImageView.contentMode = contentMode
        self.photoImageView.setImage(url: imageURL)
    }
}
