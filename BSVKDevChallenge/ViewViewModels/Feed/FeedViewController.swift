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
        return UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 8)
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
    UICollectionViewDelegateFlowLayout
{
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var sections = Section.allCases
    private let likesImage = UIImage(named: "likes")!.withRenderingMode(.alwaysTemplate)
    private let commentsImage = UIImage(named: "comments")!.withRenderingMode(.alwaysTemplate)
    private let repostsImage = UIImage(named: "reposts")!.withRenderingMode(.alwaysTemplate)
    private let viewsImage = UIImage(named: "views")!.withRenderingMode(.alwaysTemplate)
    private var textViewWidth: CGFloat?
    private let refresher = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        VKSDKManager.shared.uiDelegate = self
        self.viewModel.loginIfNeeded()
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
        if #available(iOS 11.0, *) {
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
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
        
        self.collectionView.setDelegateAndDatasource(to: self)
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
        let textViewWidth = self.collectionView.bounds.width - Constants.collectionInsets.horizontal - Constants.feedItemCellTextOffset
        let shouldShow = self.viewModel.shouldShowShowMoreButton(at: indexPath.row, textViewWidth: textViewWidth)
        let textHeight = self.viewModel.textViewHeight(at: indexPath.row, textViewWidth: textViewWidth)
        let username = self.viewModel.username(at: row)
        let userImageURL = self.viewModel.userImageURL(at: row)
        let date = self.viewModel.date(at: row)
        let text = self.viewModel.text(at: row)
        let likes = self.viewModel.likes(at: row)
        let reposts = self.viewModel.reposts(at: row)
        let comments = self.viewModel.comments(at: row)
        let views = self.viewModel.views(at: row)
        let photos = self.viewModel.photos(at: row)
        
        cell.configure(username: username,
                       userImageUrl: userImageURL,
                       shouldShowMoreButton: shouldShow,
                       textHeight: textHeight,
                       date: date,
                       text: text,
                       likes: likes,
                       reposts: reposts,
                       comments: comments,
                       views: views,
                       queryKeyWords: self.viewModel.queryKeyWords,
                       likesImage: self.likesImage,
                       commentsImage: self.commentsImage,
                       repostsImage: self.repostsImage,
                       viewsImage: self.viewsImage,
                       photos: photos,
                       containerWidth: self.collectionView.bounds.width - Constants.collectionInsets.horizontal, index: row)
        
        
        cell.didTapShowMoreButton = strongify(weak: self) { `self` in
            self.viewModel.showMore(at: indexPath.row)
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = self.sections[indexPath.section]
        switch section {
        case .feeds:
            let textViewWidth = collectionView.bounds.width - Constants.collectionInsets.horizontal - Constants.feedItemCellTextOffset
            let shouldShow = self.viewModel.shouldShowShowMoreButton(at: indexPath.row, textViewWidth: textViewWidth)
            let textHeight = self.viewModel.textViewHeight(at: indexPath.row, textViewWidth: textViewWidth)
            let height = FeedItemCollectionViewCell.determineHeight(text: self.viewModel.text(at: indexPath.item), shouldShowMoreButton: shouldShow, textHeight: textHeight, photos: self.viewModel.photos(at: indexPath.row), containerWidth: collectionView.bounds.width - Constants.collectionInsets.horizontal, index: indexPath.row)
            return CGSize(width: collectionView.bounds.width - Constants.collectionInsets.horizontal, height: height)
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
