//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Виктория Щербакова on 25.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        window?.makeKeyAndVisible()
    }
}

