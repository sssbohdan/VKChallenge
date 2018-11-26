//
//  ImageCacher.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

final class ImageCacher {
    private let cache = NSCache<NSURL, UIImage>()
    private lazy var observer: NSObjectProtocol = {
        return NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] notification in
            self?.cache.removeAllObjects()
        }
    }()
    
    static let shared = ImageCacher()
    
    private init() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self.observer)
    }
    
    func image(forKey key: URL) -> UIImage? {
        print("retrieve url - \(key)")
        return self.cache.object(forKey: key as NSURL)
    }
    
    func save(image: UIImage, forKey key: URL) {
        print("cached url - \(key)")
        self.cache.setObject(image, forKey: key as NSURL)
    }
}

extension UIImageView {
    private static var taskKey = 0
    private static var urlKey = 0
    
    private var currentTask: URLSessionTask? {
        get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var currentURL: URL? {
        get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func cancelLoad() {
        self.currentTask?.cancel()
        self.currentTask = nil
        self.currentTask = nil
        self.image = nil
    }
    
    func setImage(url: URL?) {
        guard let url = url else { return }

        if let cachedImage = ImageCacher.shared.image(forKey: url) {
            self.image = cachedImage
            return
        }
        
        self.currentURL = url
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.currentTask = nil
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                return
            }
            
            ImageCacher.shared.save(image: downloadedImage, forKey: url)
            
            if url == self?.currentURL {
                DispatchQueue.main.async {
                    self?.image = downloadedImage
                }
            }
        }
        
        self.currentTask = task
        task.resume()
    }
}
