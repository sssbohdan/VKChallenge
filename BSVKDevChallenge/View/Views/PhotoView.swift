//
//  PhotoView.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

private struct Constants {
    static var pageHolderHeight: CGFloat { return 39 }
    static var pageControlerSize: CGSize { return CGSize(width: 55, height: 7) }
    static var maxAspectRatio: Double { return 1.3 }
}

final class PhotoView: UIView {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var photos = [Photo]()
    private lazy var pageControl = UIPageControl()
    private lazy var pageHolerView = UIView()
    private var pageHolderHeightConstraint: NSLayoutConstraint!
    private var totalHeight: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.collectionView.setDelegateAndDatasource(to: self)
        self.collectionView.register(PhotoCollectionViewCell.self)
        self.addSubview(self.collectionView, with: ConstraintsSettings(left: 0, right: 0, top: 0))
        self.addSubview(self.pageHolerView, with: ConstraintsSettings(left: 0, right: 0, bottom: 0))
        self.collectionView.bottomAnchor.constraint(equalTo: self.pageHolerView.topAnchor).isActive = true
        self.pageHolderHeightConstraint = self.pageHolerView.heightAnchor.constraint(equalToConstant: 0)
        self.pageHolderHeightConstraint.isActive = true
        self.pageHolerView.backgroundColor = .clear
        self.pageHolerView.addSubview(self.pageControl, with: ConstraintsSettings(width: Constants.pageControlerSize.width, height: Constants.pageControlerSize.height, centerX: 0, centerY: 0))
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        self.collectionView.isPagingEnabled = true
        self.collectionView.backgroundColor = .clear
        self.pageControl.currentPageIndicatorTintColor = UIColor.PhotoView.currentPageIndicatorTintColor
        self.pageControl.pageIndicatorTintColor = UIColor.PhotoView.pageIndicatorTintColor
        self.pageHolerView.clipsToBounds = true
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(photos: [Photo], totalHeight: CGFloat) {
        self.pageHolderHeightConstraint.constant = photos.count > 1 ? Constants.pageHolderHeight : 0
        self.photos = photos
        self.collectionView.reloadData()
        self.pageControl.numberOfPages = photos.count
        self.pageControl.currentPage = 0
        self.totalHeight = totalHeight
    }
    
    func clear() {
        self.photos = []
        self.collectionView.visibleCells.forEach { $0.prepareForReuse() }
    }
    
    static func determineHeight(photos: [Photo], containerWidth: CGFloat, index: Int) -> CGFloat {
        guard !photos.isEmpty else { return 0 }
        
        var maxRatio = photos
            .compactMap { $0.averageSize }
            .map { $0.height / $0.width }
            .max() ?? 1
        maxRatio = min(maxRatio, Constants.maxAspectRatio)
        var height = CGFloat(maxRatio) * containerWidth
//        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
//        print("Ratio \(maxRatio)")
//        print("Container height \(height)")
//        print("Container widht \(containerWidth)")
//        print("Index \(index)")
//        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        if photos.count > 1 {
            height += Constants.pageHolderHeight
        }
        
        return height
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControl.currentPage = page
    }
}

extension PhotoView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PhotoCollectionViewCell.self)
        let photo = photos[indexPath.row]
        cell.configure(imageURL: photo.averageSize?.url.toURL())
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
//        print("photo cell size \(collectionView.frame.size)")
//        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        if var totalHeight = self.totalHeight {
            if photos.count > 1 {
               totalHeight -= Constants.pageHolderHeight
            }
            
            return CGSize(width: collectionView.bounds.width, height: totalHeight)
        }
        
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
