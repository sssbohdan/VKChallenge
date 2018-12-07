//
//  FeedViewController.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit
import VK_ios_sdk

private enum Section: CaseIterable {
    case search,
    feeds,
    loaded
}

private struct Constants {
    static var collectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    static var loadedCellHeight: CGFloat { return 64 }
    static var searchCellHeght: CGFloat { return 96 }
    static var spaceBetweenCells: CGFloat { return 12 }
    static var feedItemCellTextOffset: CGFloat { return 24 }
}

final class FeedViewController<T: FeedViewModel>: ViewController<T>,
    VKSdkUIDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
UICollectionViewDataSourcePrefetching {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var sections = Section.allCases
    private let likesImage = UIImage(named: "likes")!.withRenderingMode(.alwaysTemplate)
    private let commentsImage = UIImage(named: "comments")!.withRenderingMode(.alwaysTemplate)
    private let repostsImage = UIImage(named: "reposts")!.withRenderingMode(.alwaysTemplate)
    private let viewsImage = UIImage(named: "views")!.withRenderingMode(.alwaysTemplate)
    private var textViewWidth: CGFloat?
    private let refresher = UIRefreshControl()
    private lazy var rowsHeightsCache = NSCache<NSNumber, NSNumber>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        VKSDKManager.shared.uiDelegate = self
        self.viewModel.loginIfNeeded()
    }
    
    override func performOnceInViewDidAppear() {
        let textViewWidth = self.collectionView.bounds.width - Constants.collectionInsets.horizontal - Constants.feedItemCellTextOffset
        let containerWidth = self.collectionView.bounds.width - Constants.collectionInsets.horizontal
        self.viewModel.setTextViewWidth(textViewWidth, containerWidth: containerWidth)
        self.collectionView.setDelegateAndDatasource(to: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func configureConstraints() {
        [self.collectionView].forEach {
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            let cons = self.collectionView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor)
            cons.constant = 20
            cons.isActive = true
        }
        
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func configureBindnig() {
        super.configureBindnig()
        
        self.viewModel.onAuthorizationError = strongify(weak: self) { `self` in
            let alert = UIAlertController(title: "VKDevChallenge", message: "Please sign in to use app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok :(", style: .default, handler: { [unowned self] _ in
                self.viewModel.loginIfNeeded()
            }))
            self.present(alert, animated: true)
        }
        
        self.viewModel.didLoginSuccessfully = strongify(weak: self) { `self` in
            
        }
        
        self.viewModel.didFinishLoadUser = strongify(weak: self) { `self`, user in
            let section = Section.search
            let sectionIndex = self.sections.index(of: section)!
            self.collectionView.reloadItems(at: [IndexPath(item: 0, section: sectionIndex)])

        }
        
        self.viewModel.didEndRefreshing = strongify(weak: self) { `self` in
            self.refresher.endRefreshing()
        }
        
        self.viewModel.dataWasUpdated = strongify(weak: self) { `self` in
            self.collectionView.reloadData()
        }
        
        self.viewModel.shouldReloadFeedItem = strongify(weak: self) { `self`, index in
            let section = Section.feeds
            let sectionIndex = self.sections.index(of: section)!
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: sectionIndex)])
        }
    }
    
    override func configureUI() {
        super.configureUI()
        
        self.view.backgroundColor = UIColor.Feeds.background
        self.collectionView.backgroundColor = .clear
        self.collectionView.register(FeedItemCollectionViewCell.self)
        self.collectionView.register(SearchCollectionViewCell.self)
        self.collectionView.register(LoadedCollectionViewCell.self)
        
        self.collectionView.alwaysBounceVertical = true
        self.refresher.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.collectionView.addSubview(self.refresher)
    }
    
    @objc private func loadData() {
       self.viewModel.refresh()
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.feedsCount - 1 {
            self.viewModel.loadFeeds()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = self.sections[section]
        return self.numberOfItems(in: section)
    }
    
    private func numberOfItems(in section: Section) -> Int {
        switch section {
        case .feeds:
            return self.viewModel.feedsCount
        case .search:
            return 1
        case .loaded:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.sections[indexPath.section]
        switch section {
        case .feeds:
            return self.feedItemCell(for: indexPath)
        case .loaded:
            return self.loadedCell(for: indexPath)
        case .search:
            return self.searchCell(for: indexPath)
        }
    }
    
    private func loadedCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: LoadedCollectionViewCell.self)
        cell.configure(loaded: self.viewModel.feedsCount)
        return cell
    }
    
    private func searchCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: SearchCollectionViewCell.self)
        cell.configure(query: self.viewModel.unappliedQuery, userImageUrl: self.viewModel.currentUserImageURL())
        cell.onSearch = strongify(weak: self) { `self`, query in
            self.viewModel.search(query: query)
        }
        
        cell.onTextChange = strongify(weak: self) { `self`, text in
            self.viewModel.unappliedQuery = text
        }
        
        return cell
    }
    
    private func feedItemCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: FeedItemCollectionViewCell.self)
        let row = indexPath.row
        cell.configure(viewModel: self.viewModel.feedItemCellViewModel(at: row),
                       likesImage: self.likesImage,
                       commentsImage: self.commentsImage,
                       repostsImage: self.repostsImage,
                       viewsImage: self.viewsImage)
        
        cell.didTapShowMoreButton = strongify(weak: self) { `self` in
            self.viewModel.showMore(at: indexPath.row)
        }
        return cell
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = self.sections[indexPath.section]
        switch section {
        case .feeds:
            return CGSize(width: collectionView.bounds.width - Constants.collectionInsets.horizontal, height: self.viewModel.heightForItem(at: indexPath.item))
        case .loaded:
            return CGSize(width: collectionView.bounds.width, height: Constants.loadedCellHeight)
        case .search:
            return CGSize(width: collectionView.bounds.width, height: Constants.searchCellHeght)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.collectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.spaceBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - VKSdkUIDelegate
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        self.present(controller, animated: true)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
    }
}
