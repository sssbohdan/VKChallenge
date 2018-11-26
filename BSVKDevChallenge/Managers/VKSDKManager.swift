//
//  VKSDKManager.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation
import VK_ios_sdk

final class VKSDKManager: NSObject {
    private let permissions = ["friends", "email", "wall", "groups", "photos"]
    private let sdk = VKSdk.initialize(withAppId: GlobalConstants.VK.appID)
    
    static let shared = VKSDKManager()
    
    var uiDelegate: VKSdkUIDelegate? {
        didSet {
            self.sdk?.uiDelegate = self.uiDelegate
        }
    }
    
    var accessToken: String {
        return VKSdk.accessToken().accessToken
    }
    var currentUserId: Int {
        return VKSdk.accessToken().localUser.id.intValue
    }
    
    var onAuthError: (() -> Void)?
    var onAuthSuccess: (() -> Void)?
    
    private override init() {
        super.init()
        self.sdk?.register(self)
    }
    
    func wakeUp(completion: @escaping  (VKAuthorizationState, Error?) -> Void) {
        VKSdk.wakeUpSession(self.permissions, complete: completion)
    }
    
    func authorize() {
        VKSdk.authorize(permissions)
    }
}

// MARK: - VKSdkDelegate
extension VKSDKManager: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        result.error != nil ? self.onAuthError?() : self.onAuthSuccess?()
    }
    
    func vkSdkUserAuthorizationFailed() {
        self.onAuthError?()
    }
    
    func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
    }
}
