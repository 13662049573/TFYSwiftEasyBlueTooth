//
//  SceneDelegate.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/9.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let navigationBar = UINavigationBar.appearance()
            navigationBar.barTintColor = .white
            navigationBar.tintColor = .black
            navigationBar.barStyle = .default
            navigationBar.isTranslucent = false
            navigationBar.backgroundColor = .white
            navigationBar.clipsToBounds = false
            navigationBar.setBackgroundImage(UIImage.blueimageWithColor(color: .white), for: .default)
            navigationBar.setBackgroundImage(UIImage.blueimageWithColor(color: .white), for: .any, barMetrics: .default)
            navigationBar.shadowImage = UIImage.blueimageWithColor(color: .white)
            
           
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
            ]
            
            window.rootViewController = TFYSwiftTabbarController()
            
            self.window = window
            
            window.makeKeyAndVisible()
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }

}

