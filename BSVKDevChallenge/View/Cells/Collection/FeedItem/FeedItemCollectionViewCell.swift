//
//  FeedItemCollectionViewCell.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
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
}

final class FeedItemCollectionViewCell: UICollectionViewCell, NibReusable {
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
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var textView: UITextViewFixed!
    @IBOutlet private weak var likesCountLabel: UILabel!
    @IBOutlet private weak var commentsCountLabel: UILabel!
    @IBOutlet private weak var repostsCountLabel: UILabel!
    @IBOutlet private weak var viewsCountLabel: UILabel!
    @IBOutlet private weak var likesImageView: UIImageView!
    @IBOutlet private weak var commentsImageView: UIImageView!
    @IBOutlet private weak var repostsImageView: UIImageView!
    @IBOutlet private weak var viewsImageView: UIImageView!
    @IBOutlet private weak var showMoreButton: UIButton!
    @IBOutlet private weak var photosHolderView: UIView!
    
    @IBOutlet private var showMoreButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var showMoreButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet private var showMoreButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var photosHolderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var photosHolderToTextTopConstraint: NSLayoutConstraint!
    @IBOutlet private var photosHolderToImageTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private var statsViewToPhotosTopConstraint: NSLayoutConstraint!
    @IBOutlet private var statsViewToShowMoreButtonTopConstraint: NSLayoutConstraint!
    
    var didTapShowMoreButton: (() -> Void)?
    
    private lazy var photoView = PhotoView(frame: .zero)
    static var font = UIFont.systemFont(ofSize: 14)
    private var index: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureUI()
    }
    
    override func prepareForReuse() {
        self.index.map { print("prepare for reuse \($0)") }
        self.photoView.clear()
        self.index = nil
        self.userImageView.cancelLoad()
        self.userImageView.image = nil
    }
    
    func configure(viewModel: FeedItemCollectionViewCell.ViewModel,
                   likesImage: UIImage,
                   commentsImage: UIImage,
                   repostsImage: UIImage,
                   viewsImage: UIImage) {
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
        let photoViewHeight = PhotoView.determineHeight(photos: viewModel.photos, containerWidth: viewModel.containerWidth, index: viewModel.index)
        self.photoView.update(photos: viewModel.photos, totalHeight: photoViewHeight)
        
        self.showMoreButtonHeightConstraint.constant = viewModel.shouldShowMoreButton ? Constants.showMoreButtonHeight : 0
        self.showMoreButtonTopConstraint.constant = viewModel.shouldShowMoreButton ? 0 : 0
        self.showMoreButtonBottomConstraint.constant = viewModel.shouldShowMoreButton ? Constants.showMoreButtonBottom : Constants.showMoreButtonBottomDefault
        
        self.textViewTopConstraint.constant = viewModel.text.isEmpty ? 0 : Constants.textViewTop
        self.textViewHeight.constant = viewModel.textHeight
        self.photosHolderViewHeightConstraint.constant = photoViewHeight
    }
    
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

// MARK: - Actions
private extension FeedItemCollectionViewCell {
    @IBAction func showMoreAction(sender: UIButton) {
        didTapShowMoreButton?()
    }
}

// MARK: - Private
private extension FeedItemCollectionViewCell {
    func configureUI() {
        self.roundCorner(radius: Constants.defaultCornerRadius)
        self.contentView.backgroundColor = .white
        self.userImageView.toCirle()
        
        [self.likesImageView, self.commentsImageView, self.repostsImageView, self.viewsImageView, self.userImageView]
            .forEach {
                $0?.contentMode = .scaleAspectFit
                $0?.tintColor = UIColor.Feeds.statsImage
        }
        
        [self.likesCountLabel,
         self.commentsCountLabel,
         self.repostsCountLabel]
            .forEach {
                $0?.textColor = UIColor.FeedItemCell.likes
        }
        
        self.viewsCountLabel.textColor = UIColor.FeedItemCell.views
        self.usernameLabel.textColor = UIColor.FeedItemCell.username
        self.textView.textColor = UIColor.FeedItemCell.plainText
        self.userImageView.backgroundColor = .lightGray
        self.photosHolderView.addSubview(self.photoView, with: ConstraintsSettings.zero)
        self.textView.delegate = self
    }
}

// MARK: - UITextViewDelegate
extension FeedItemCollectionViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}
