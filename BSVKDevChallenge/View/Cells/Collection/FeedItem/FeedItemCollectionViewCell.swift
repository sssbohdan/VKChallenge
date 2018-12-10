//
//  FeedI.swift
//  BSVKDevChallenge
//
//  Created by bbb on 12/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

private struct Constants {
    static var userImageTop: CGFloat { return 12 }
    static var userImageHeight: CGFloat { return 36 }
    static var textViewTop: CGFloat { return 10 }
    static var showMoreButtonHeight: CGFloat { return 20 }
    static var showMoreButtonBottom: CGFloat { return 0 }
    static var statsBottom: CGFloat { return 15 }
    static var statsHeight: CGFloat { return 19 }
    static var statsTop: CGFloat { return 4 }
    static var defaultCornerRadius: CGFloat { return 10 }
    static var showMoreButtonBottomDefault: CGFloat { return 4 }
    static var infoButtonWidth: CGFloat { return 18 }
}

final class FeedItemCollectionViewCell: UICollectionViewCell {
    final class ViewModel {
        let username: String
        let userImageUrl: URL?
        let shouldShowMoreButton: Bool
        let textHeight: CGFloat
        let date: String
        let text: String
        let likes: String
        let reposts: String
        let comments: String
        let views: String
        let queryKeyWords: [String]
        let photos: [Photo]
        let containerWidth: CGFloat
        let index: Int
        
        init(username: String,
             userImageUrl: URL?,
             shouldShowMoreButton: Bool,
             textHeight: CGFloat,
             date: String,
             text: String,
             likes: String,
             reposts: String,
             comments: String,
             views: String,
             queryKeyWords: [String],
             photos: [Photo],
             containerWidth: CGFloat,
             index: Int) {
            self.username = username
            self.userImageUrl = userImageUrl
            self.shouldShowMoreButton = shouldShowMoreButton
            self.textHeight = textHeight
            self.date = date
            self.text = text
            self.likes = likes
            self.reposts = reposts
            self.comments = comments
            self.views = views
            self.queryKeyWords = queryKeyWords
            self.photos = photos
            self.containerWidth = containerWidth
            self.index = index
        }
    }
    private lazy var userImageView = UIImageView()
    private lazy var usernameLabel = UILabel()
    private lazy var dateLabel = UILabel()
    private lazy var textView = UITextViewFixed()
    private lazy var likesCountLabel = UILabel()
    private lazy var commentsCountLabel = UILabel()
    private lazy var repostsCountLabel = UILabel()
    private lazy var viewsCountLabel = UILabel()
    private lazy var likesImageView = UIImageView()
    private lazy var commentsImageView = UIImageView()
    private lazy var repostsImageView = UIImageView()
    private lazy var viewsImageView = UIImageView()
    private lazy var showMoreButton = UIButton()
    private lazy var photosHolderView = UIView()
    private lazy var feedInfoHolderView = UIView()
    
    private lazy var textViewHeight: CGFloat = 0
    private lazy var photosHolderHeight: CGFloat = 0
    private lazy var shouldShowMoreButton = false
    private lazy var photoView = PhotoView(frame: .zero)
    static var font = UIFont.systemFont(ofSize: 14)
    private var index: Int?
    private let leftInfoAspectRatio: CGFloat = 2.5 / 4
    
    var didTapShowMoreButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        self.configureUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layout()
    }
    
    override func prepareForReuse() {
        self.index.map { print("prepare for reuse \($0)") }
        self.photoView.clear()
        self.index = nil
        self.userImageView.cancelLoad()
        self.userImageView.image = nil
        self.textViewHeight = 0
        self.photosHolderHeight = 0
    }
    
    func configure(viewModel: FeedItemCollectionViewCell.ViewModel,
                   likesImage: UIImage,
                   commentsImage: UIImage,
                   repostsImage: UIImage,
                   viewsImage: UIImage) {
        self.textViewHeight = viewModel.textHeight
        self.photosHolderHeight = PhotoView.determineHeight(photos: viewModel.photos, containerWidth: viewModel.containerWidth, index: viewModel.index)
        self.shouldShowMoreButton = viewModel.shouldShowMoreButton
        self.index = viewModel.index
        self.likesImageView.image = likesImage
        self.commentsImageView.image = commentsImage
        self.repostsImageView.image = repostsImage
        self.viewsImageView.image = viewsImage
        self.likesCountLabel.text = viewModel.likes
        self.commentsCountLabel.text = viewModel.comments
        self.repostsCountLabel.text = viewModel.reposts
        self.viewsCountLabel.text = viewModel.views
        let attributedText = NSAttributedString(base: viewModel.text,
                                                keyWords: viewModel.queryKeyWords,
                                                foregroundColor: UIColor.FeedItemCell.text, font: FeedItemCollectionViewCell.font,
                                                highlightForeground: UIColor.FeedItemCell.highlighTextForeground,
                                                highlighBackground: UIColor.FeedItemCell.highlighTextBackground)
        self.textView.attributedText = attributedText
        self.usernameLabel.text = viewModel.username
        self.userImageView.setImage(url: viewModel.userImageUrl)
        self.dateLabel.text = viewModel.date
        self.dateLabel.textColor = UIColor.FeedItemCell.date
        self.photoView.update(photos: viewModel.photos, totalHeight: self.photosHolderHeight)
        self.layout()
        self.userImageView.toCirle()
        self.roundCorner(radius: Constants.defaultCornerRadius)
    }
}

// MARK: - Static
extension FeedItemCollectionViewCell {
    static func determineHeight(text: String,
                                shouldShowMoreButton: Bool,
                                textHeight: CGFloat,
                                photos: [Photo],
                                containerWidth: CGFloat,
                                index: Int) -> CGFloat {
        var accumulator: CGFloat = 0
        accumulator += Constants.userImageTop
        accumulator += Constants.userImageHeight
        accumulator += text.isEmpty ? 0 : Constants.textViewTop
        accumulator += textHeight
        accumulator += shouldShowMoreButton ? Constants.showMoreButtonHeight : 0
        accumulator += shouldShowMoreButton ? 0 : 0
        accumulator += shouldShowMoreButton ? Constants.showMoreButtonBottom : Constants.showMoreButtonBottomDefault
        accumulator += PhotoView.determineHeight(photos: photos, containerWidth: containerWidth, index: index)
        accumulator += Constants.statsBottom
        accumulator += Constants.statsHeight
        accumulator += Constants.statsTop
        
        return accumulator
    }
}

// MARK: - Private
private extension FeedItemCollectionViewCell {
    func layout() {
        let textViewWidth = self.bounds.width - (12 * 2)
        let textViewEmpty = self.textView.text.isEmpty
        let textViewYOrigin = textViewEmpty ? 58 - Constants.textViewTop : 58
        let showMoreYOrigin = textViewYOrigin + self.textViewHeight
        let showMoreHeight = self.shouldShowMoreButton ? Constants.showMoreButtonHeight : 0
        let showMoreButtonBottom = showMoreYOrigin + (self.shouldShowMoreButton ? Constants.showMoreButtonBottom : Constants.showMoreButtonBottomDefault)
        let feedInfoYOrigin = self.photosHolderHeight + showMoreButtonBottom + Constants.statsTop

        self.userImageView.frame = CGRect(x: 12, y: 12, width: 36, height: 36)
        self.usernameLabel.frame.origin = CGPoint(x: 58, y: 14)
        self.dateLabel.frame.origin = CGPoint(x: 58, y: 33.5)
        [self.usernameLabel, self.dateLabel].forEach { $0.sizeToFit() }
        self.textView.frame = CGRect(x: 12, y: textViewYOrigin, width: textViewWidth, height: self.textViewHeight)
        self.showMoreButton.frame = CGRect(x: 12, y: showMoreYOrigin, width: textViewWidth, height: showMoreHeight)
        self.photosHolderView.frame = CGRect(x: 12, y: showMoreButtonBottom, width: textViewWidth, height: self.photosHolderHeight)
        self.feedInfoHolderView.frame = CGRect(x: 0, y: feedInfoYOrigin, width: self.bounds.width, height: Constants.statsHeight)
        let infoWidth = self.bounds.width * self.leftInfoAspectRatio / 3
        let infoLabelsImages = [(self.likesCountLabel, self.likesImageView), (self.commentsCountLabel, self.commentsImageView), (self.repostsCountLabel, self.repostsImageView)]
        
        var acc: CGFloat = 19
        for  (label, imageView) in infoLabelsImages {
            imageView.frame = CGRect(x: acc, y: 0, width: Constants.infoButtonWidth, height: Constants.statsHeight)
            let labelOrigin = acc + 5 + Constants.infoButtonWidth
            label.sizeToFit()
            label.frame.origin = CGPoint(x: labelOrigin, y: (Constants.statsHeight - label.frame.height) / 2)
            acc += infoWidth
        }
        
        self.viewsCountLabel.sizeToFit()
        self.viewsCountLabel.frame.origin = CGPoint(x: self.bounds.width - 5 - self.viewsCountLabel.bounds.width, y: (Constants.statsHeight - viewsCountLabel.frame.height) / 2)
        self.viewsImageView.frame = CGRect(x: viewsCountLabel.frame.origin.x - 5 - Constants.infoButtonWidth, y: 0, width: Constants.infoButtonWidth, height: Constants.statsHeight)
    }
    
    func configureUI() {
        [self.userImageView,
         self.usernameLabel,
         self.dateLabel,
         self.textView,
         self.feedInfoHolderView,
         self.showMoreButton,
         self.photosHolderView]
            .forEach { self.addSubview($0) }
        
        
        [self.likesCountLabel,
         self.commentsCountLabel,
         self.repostsCountLabel,
         self.viewsCountLabel,
         self.viewsImageView,
         self.likesImageView,
         self.repostsImageView,
         self.commentsImageView]
            .forEach { self.feedInfoHolderView.addSubview($0) }
        
        self.contentView.backgroundColor = .white
        
        [self.likesImageView, self.commentsImageView, self.repostsImageView, self.viewsImageView, self.userImageView]
            .forEach {
                $0.contentMode = .scaleAspectFit
                $0.tintColor = UIColor.Feeds.statsImage
        }
        
        [self.likesCountLabel,
         self.commentsCountLabel,
         self.repostsCountLabel]
            .forEach {
                $0.textColor = UIColor.FeedItemCell.likes
                $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        self.viewsCountLabel.textColor = UIColor.FeedItemCell.views
        self.usernameLabel.textColor = UIColor.FeedItemCell.username
        self.textView.textColor = UIColor.FeedItemCell.plainText
        self.userImageView.backgroundColor = .lightGray
        self.photosHolderView.addSubview(self.photoView, with: ConstraintsSettings.zero)
        self.textView.delegate = self
        self.showMoreButton.addTarget(self, action: #selector(showMoreAction), for: .touchUpInside)
        self.usernameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.dateLabel.font = UIFont.systemFont(ofSize: 12)
    }
}

// MARK: - Actions
private extension FeedItemCollectionViewCell {
    @objc func showMoreAction(sender: UIButton) {
        self.didTapShowMoreButton?()
    }
}


// MARK: - UITextViewDelegate
extension FeedItemCollectionViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}

