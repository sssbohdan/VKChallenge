//
//  SearchCollectionViewCell.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

private struct Constants {
    static var firstResponderTextFieldLeft: CGFloat { return  12 }
    static var notFirstResponderTextFieldLeft: CGFloat { return 60 }
}

final class SearchCollectionViewCell: UICollectionViewCell, NibReusable, UITextFieldDelegate {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var searchImageView: UIImageView!
    
    var onTextChange: ((String) -> Void)?
    var onSearch: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImageView.toCirle()
        self.searchView.backgroundColor = UIColor.SearchCell.searchBackground
        self.searchView.roundCorner(radius: 10)
        self.userImageView.backgroundColor = .lightGray
        self.searchTextField.delegate = self
        let search = UIImage(named: "search")!.withRenderingMode(.alwaysTemplate)
        self.searchImageView.tintColor = UIColor.Feeds.statsImage
        self.searchImageView.image = search
    }
    
    func configure(query: String, userImageUrl: URL?) {
        self.searchTextField.text = query
        self.userImageView.setImage(url: userImageUrl)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.animateFirstResponder(assign: true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.animateFirstResponder(assign: false)
        self.onSearch?(textField.text!.withoutSpacesAndNewLines)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func animateFirstResponder(assign: Bool) {
        UIView.animate(withDuration: 0.3, delay: assign ? 0 : 0.3, animations: {
            self.userImageView.alpha = assign ? 0 : 1
        })
        
        
        self.searchViewLeftConstraint.constant = assign ? Constants.firstResponderTextFieldLeft : Constants.notFirstResponderTextFieldLeft
        UIView.animate(withDuration: 0.3, delay: assign ? 0.3 : 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, animations: {
            self.layoutIfNeeded()
        })
    }
    
    @IBAction func onTextChange(sender: UITextField) {
        self.onTextChange?(sender.text!)
    }
}
