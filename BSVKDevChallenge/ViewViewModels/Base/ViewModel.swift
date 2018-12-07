//
//  ViewModel.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

protocol ViewModel: class {
    var dataWasUpdated: (() -> Void)? { get set }

    var shouldPush: ((UIViewController, Bool) -> Void)? { get set }
    var shouldPop: ((Bool) -> UIViewController?)? { get set }
    var shouldPopToRoot: ((Bool) -> [UIViewController]?)? { get set }

    var shouldPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)? { get set }
    var shouldDismmiss: ((Bool, (() -> Void)?) -> Void)? { get set }

    func didReceiveMemoryWarning()
}

class BaseViewModel: ViewModel {
    var dataWasUpdated: (() -> Void)?
    var shouldPush: ((UIViewController, Bool) -> Void)?
    var shouldPop: ((Bool) -> UIViewController?)?
    var shouldPopToRoot: ((Bool) -> [UIViewController]?)?
    var shouldPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)?
    var shouldDismmiss: ((Bool, (() -> Void)?) -> Void)?
    
    func didReceiveMemoryWarning() {
        print("receive memory warning")
    }
}
