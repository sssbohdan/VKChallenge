//
//  ViewModel.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

protocol ViewModel: class {
    var dataWasUpdated: (() -> Void)? { get set }
    
    func didReceiveMemoryWarning()
}

class BaseViewModel: ViewModel {
    var dataWasUpdated: (() -> Void)?
    
    func didReceiveMemoryWarning() {
        print("receive memory warning")
    }
}
