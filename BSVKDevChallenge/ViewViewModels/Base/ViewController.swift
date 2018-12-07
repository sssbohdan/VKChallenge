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
    private lazy var viewDidAppearWasCalled = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        defer { self.viewDidAppearWasCalled = true }
        
        if !self.viewDidAppearWasCalled {
            self.performOnceInViewDidAppear()
        }
    }
    
    override func didReceiveMemoryWarning() {
        self.viewModel.didReceiveMemoryWarning()
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
        self.viewModel.shouldPop = self.navigationController?.popViewController
        self.viewModel.shouldPush = self.navigationController?.pushViewController
        self.viewModel.shouldPresent = self.navigationController?.present
        self.viewModel.shouldPopToRoot = self.navigationController?.popToRootViewController
        self.viewModel.shouldDismmiss = self.navigationController?.dismiss
    }
    
    func performOnceInViewDidAppear() {
        
    }
}
