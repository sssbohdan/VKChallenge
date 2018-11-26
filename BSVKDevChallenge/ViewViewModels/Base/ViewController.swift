//
//  ViewController.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

/// - warning: Abstract - don't create instance of this class.
class ViewController<T: ViewModel>: UIViewController {
    let viewModel: T
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = UIView(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureConstraints()
        self.configureUI()
        self.configureBindnig()
    }
    
    deinit {
        print("☠️", self)
    }
    
    // MARK: - Override point
    func configureUI() {
        view.backgroundColor = .white
    }
    
    func configureConstraints() {
        
    }
    
    func configureBindnig() {
        
    }
}
