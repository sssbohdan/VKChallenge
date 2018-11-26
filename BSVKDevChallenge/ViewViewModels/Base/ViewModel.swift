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
}
