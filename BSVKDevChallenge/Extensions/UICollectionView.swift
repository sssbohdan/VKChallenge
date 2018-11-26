//
//  UICollectionView.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

extension UICollectionView {
    func setDelegateAndDatasource(to object: UICollectionViewDelegate & UICollectionViewDataSource) {
        self.delegate = object
        self.dataSource = object
    }
}
