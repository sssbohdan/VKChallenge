//
//  ControllerInitializer.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class ControllerInitializer {
    static func getFeedViewController() -> FeedViewController<FeedViewModelImpl> {
        let networkManager = NetworkManagerImpl(dataLoader: DataLoaderImpl(urlSession: URLSession.shared))
        let viewModel = FeedViewModelImpl(networkManager: networkManager)
        let viewController = FeedViewController(viewModel: viewModel)
        return viewController
    }
}
