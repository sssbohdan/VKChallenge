//
//  FeedViewModel.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

private struct Constants {
    static var showMoreButtonAfter: CGFloat { return 6 }
    static var maxTextLines: CGFloat { return 8 }
    static var placeholderName: String { return "Bohdan Savych".localized }
    static var textFont: UIFont { return UIFont.systemFont(ofSize: 14) }
}

protocol FeedViewModel: ViewModel {
    var feedsCount: Int { get }
    var appliedQuery: String { get }
    var unappliedQuery: String { get set }
    var queryKeyWords: [String] { get }
    
    var didLoginSuccessfully: (() -> Void)? { get set }
    var onAuthorizationError: (() -> Void)? { get set }
    var shouldReloadFeedItem: ((Int) -> Void)? { get set }
    var didFinishLoadUser: ((User) -> Void)? { get set }
    var didEndRefreshing: (() -> Void)? { get set }
    
    func feedItemCellViewModel(at index: Int) -> FeedItemCollectionViewCell.ViewModel
    func loginIfNeeded()
    func text(at index: Int) -> String
    func likes(at index: Int) -> String
    func reposts(at index: Int) -> String
    func comments(at index: Int) -> String
    func views(at index: Int) -> String
    func photos(at index: Int) -> [Photo]
    func textViewHeight(at index: Int) -> CGFloat
    func shouldShowShowMoreButton(at index: Int) -> Bool
    func currentUserImageURL() -> URL?
    func loadFeeds()
    func showMore(at index: Int)
    func refresh()
    func setTextViewWidth(_ textViewWidth: CGFloat, containerWidth: CGFloat)
    func search(query: String)
    func heightForItem(at index: Int) -> CGFloat
    func prefetchCellViewModel(at index: Int)
}

final class FeedViewModelImpl: BaseViewModel, FeedViewModel {
    var feedsCount: Int { return self.feedItems.count }
    var appliedQuery = "" {
        didSet {
            self.queryKeyWords = self.appliedQuery.withoutSpacesAndNewLines
                .split(separator: " ")
                .filter { !$0.isEmpty }
                .map(String.init)
        }
    }
    lazy var unappliedQuery = ""
    lazy var queryKeyWords = [String]()
    
    var didLoginSuccessfully: (() -> Void)?
    var onAuthorizationError: (() -> Void)?
    var didFinishLoadUser: ((User) -> Void)?
    var shouldReloadFeedItem: ((Int) -> Void)?
    var didEndRefreshing: (() -> Void)?
    
    private var feedItems: [FeedItem] {
        return self.feedStrategy.feedItems
    }
    private let networkManager: NetworkManager
    private lazy var usersSet = Set<User>()
    private lazy var groupsSet = Set<Group>()
    private lazy var sources = [Int: Sourcable]()
    private lazy var isLoadingNextPage = false
    private var currentUser: User?
    private var oneLineHeight: CGFloat?
    private var feedStrategy: FeedStrategy
    private var usersFeedStrategy: UsersFeedStrategy
    private var textViewWidth: CGFloat = 0
    private var containerWidth: CGFloat = 0
    
    private lazy var showMoreDict = [Int: Bool]()
    private lazy var feedItemsCellsViewModelsCache = NSCache<NSNumber, FeedItemCollectionViewCell.ViewModel>()
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        self.usersFeedStrategy = UsersFeedStrategy(networkManager: networkManager)
        self.feedStrategy = self.usersFeedStrategy

        super.init()
        
        VKSDKManager.shared.onAuthSuccess = strongify(weak: self) { `self` in
            self.loginIfNeeded()
        }
        
        VKSDKManager.shared.onAuthError = strongify(weak: self) { `self` in
            self.onAuthorizationError?()
        }
    }
    
    override func didReceiveMemoryWarning() {
        self.feedItemsCellsViewModelsCache.removeAllObjects()
    }
    
    func loginIfNeeded() {
        VKSDKManager.shared.wakeUp { state, error in
            guard error == nil else {
                return
            }
            
            switch state {
            case .authorized:
                self.loadFeeds()
                self.loadUser()
            case .initialized:
                VKSDKManager.shared.authorize()
            default:
                break
            }
        }
    }
    
    func username(at index: Int) -> String {
        let sourceId = self.feedItems[index].sourceId
        
        if let fullName = self.sources[sourceId]?.fullName  {
            return fullName
        }
        
        let source: Sourcable? = sourceId > 0
            ? self.getUser(sourceId: sourceId)
            : self.getGroup(sourceId: sourceId)
        
        return source?.fullName ?? Constants.placeholderName
    }
    
    func userImageURL(at index: Int) -> URL? {
        let sourceId = self.feedItems[index].sourceId
        
        if let path = self.sources[sourceId]?.imageURLPath  {
            return path.toURL()
        }
        
        let source: Sourcable? = sourceId > 0
            ? self.getUser(sourceId: sourceId)
            : self.getGroup(sourceId: sourceId)
        
        return source?.imageURLPath?.toURL()
    }
    
    func date(at index: Int) -> String {
        let date = self.feedItems[index].date
        return DateFormatterHelper.messageString(from: date)
    }
    
    func text(at index: Int) -> String {
        let text = self.feedItems[index].text
        return text
    }
    
    func likes(at index: Int) -> String {
        return self.convertedToKAppearenceIfNeeded(count: self.feedItems[index].likes.orZero)
    }
    
    func reposts(at index: Int) -> String {
        return self.convertedToKAppearenceIfNeeded(count: self.feedItems[index].reposts.orZero)
    }
    func comments(at index: Int) -> String {
        return self.convertedToKAppearenceIfNeeded(count: self.feedItems[index].comments.orZero)
    }
    
    func views(at index: Int) -> String {
        return self.convertedToKAppearenceIfNeeded(count: self.feedItems[index].views.orZero)
    }
    
    func photos(at index: Int) -> [Photo] {
        return self.feedItems[index].photos
    }
    
    func shouldShowShowMoreButton(at index: Int) -> Bool {
        let text = self.feedItems[index].text
        guard !text.isEmpty, self.showMoreDict[index] != true else { return false }

        let height = text.height(withConstrainedWidth: self.textViewWidth, font: Constants.textFont)
        let oneLineHeight = self.calculateOneLineHeight(for: textViewWidth)
        
        let lines = height / oneLineHeight
        return lines > Constants.maxTextLines
    }
    
    func textViewHeight(at index: Int) -> CGFloat {
        let text = self.feedItems[index].text
        
        guard !text.isEmpty else { return 0 }
        let real = text.height(withConstrainedWidth: self.textViewWidth, font: Constants.textFont)

        if self.showMoreDict[index] == true {
            return real
        } else {
            let oneLineHeight = self.calculateOneLineHeight(for: self.textViewWidth)
            let max = (oneLineHeight * Constants.showMoreButtonAfter) + 0.5
            return min(max, real)
        }
    }
    
    func showMore(at index: Int) {
        self.showMoreDict[index] = true
        self.feedItemsCellsViewModelsCache.removeObject(forKey: index as NSNumber)
        self.shouldReloadFeedItem?(index)
    }
    
    func loadFeeds() {
        guard !self.isLoadingNextPage, self.feedStrategy.nextFrom != nil else { return }
        self.isLoadingNextPage = true
        self.feedStrategy.loadFeed(
            success: { [unowned self] feeds in
                self.groupsSet.formUnion(feeds.groups)
                self.usersSet.formUnion(feeds.profiles)
                self.updateUI()
            },
            failure: { [unowned self] error in
                self.updateUI()
        })
    }
    
    func currentUserImageURL() -> URL? {
        return self.currentUser?.imageURLPath?.toURL()
    }
    
    func search(query: String) {
        self.appliedQuery = query
        self.feedStrategy = query.isEmpty
            ? self.usersFeedStrategy
            : SearchFeedStrategy(networkManager: self.networkManager, query: query)
        self.dataWasUpdated?()
        self.feedItemsCellsViewModelsCache.removeAllObjects()

        if self.feedStrategy.requireFeedLoading {
            self.loadFeeds()
        }
    }
    
    func refresh() {
        self.feedStrategy.nextFrom = "0"
        self.feedStrategy.feedItems = []
        self.usersSet = []
        self.groupsSet = []
        self.sources = [:]
        self.showMoreDict = [:]
        self.dataWasUpdated?()
        self.loadFeeds()
        self.loadUser()
    }
    
    func feedItemCellViewModel(at index: Int) -> FeedItemCollectionViewCell.ViewModel {
        if let viewModel = self.feedItemsCellsViewModelsCache.object(forKey: index as NSNumber) {
            return viewModel
        }
        
        
        let viewModel = self.createFeedCellViewModel(for: index)
        self.cacheCellViewModel(viewModel, at: index)

        return viewModel
    }
    
    func createFeedCellViewModel(for index: Int) -> FeedItemCollectionViewCell.ViewModel {
        let shouldShow = self.shouldShowShowMoreButton(at: index)
        let textHeight = self.textViewHeight(at: index)
        let username = self.username(at: index)
        let userImageURL = self.userImageURL(at: index)
        let date = self.date(at: index)
        let text = self.text(at: index)
        let likes = self.likes(at: index)
        let reposts = self.reposts(at: index)
        let comments = self.comments(at: index)
        let views = self.views(at: index)
        let photos = self.photos(at: index)
        let viewModel = FeedItemCollectionViewCell.ViewModel(username: username, userImageUrl: userImageURL, shouldShowMoreButton: shouldShow, textHeight: textHeight, date: date, text: text, likes: likes, reposts: reposts, comments: comments, views: views, queryKeyWords: queryKeyWords, photos: photos, containerWidth: containerWidth, index: index)
        
        return viewModel
    }
    
    func setTextViewWidth(_ textViewWidth: CGFloat, containerWidth: CGFloat) {
        self.textViewWidth = textViewWidth
        self.containerWidth = containerWidth
    }
    
    func heightForItem(at index: Int) -> CGFloat {
        let shouldShow = self.shouldShowShowMoreButton(at: index)
        let textHeight = self.textViewHeight(at: index)
        let height = FeedItemCollectionViewCell.determineHeight(text: self.text(at: index), shouldShowMoreButton: shouldShow, textHeight: textHeight, photos: self.photos(at: index), containerWidth: self.containerWidth, index: index)
        return height
    }
    
    func prefetchCellViewModel(at index: Int) {
        DispatchQueue.global(qos: .default).async {
            if self.feedItemsCellsViewModelsCache.object(forKey: index as NSNumber) == nil {
                let viewModel = self.createFeedCellViewModel(for: index)
                self.cacheCellViewModel(viewModel, at: index)
            }
        }
    }
}

// MARK: - Private
private extension FeedViewModelImpl {
    func cacheCellViewModel(_ viewModel: FeedItemCollectionViewCell.ViewModel, at index: Int) {
        DispatchQueue.global(qos: .default).async {
            self.feedItemsCellsViewModelsCache.setObject(viewModel, forKey: index as NSNumber)
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.didEndRefreshing?()
            self.dataWasUpdated?()
        }
        self.isLoadingNextPage = false
    }
    
    func getUser(sourceId: Int) -> User? {
        let user = self.usersSet.filter { $0.id == sourceId }.first
        user.map { self.sources[sourceId] = $0 }
        return user
    }
    
    func getGroup(sourceId: Int) -> Group? {
        let group = self.groupsSet.filter { $0.id == abs(sourceId) }.first
        group.map { self.sources[sourceId] = $0 }
        return group
    }
    
    func calculateOneLineHeight(for textWidth: CGFloat) -> CGFloat {
        if self.oneLineHeight == nil {
            self.oneLineHeight = Constants.placeholderName.height(withConstrainedWidth: textWidth, font: Constants.textFont)
        }
        
        return self.oneLineHeight!
    }
    
    func loadUser() {
        self.networkManager.loadUser(id: VKSDKManager.shared.currentUserId,
                                     success: { [unowned self] user in
                                        self.currentUser = user
                                        DispatchQueue.main.async {
                                            self.didFinishLoadUser?(user)
                                        }
        },
                                     failure: { error in
                                        
        })
    }
    
    func convertedToKAppearenceIfNeeded(count: Int) -> String {
        return count < 1000 ? "\(count)" : "\(Int((Double(count) / 1000).rounded(to: 1).rounded()))" + "K"
    }
}
