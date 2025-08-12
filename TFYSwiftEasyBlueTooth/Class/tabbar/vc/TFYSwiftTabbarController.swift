//
//  TFYSwiftTabbarController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//

import UIKit

class TFYSwiftTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabbar = UITabBar.appearance()
        tabbar.tintColor = .orange
        tabbar.backgroundColor = .white
        tabbar.isTranslucent = false
        tabbar.shadowImage = UIImage.blueimageWithColor(color: .white)
        tabbar.backgroundImage = UIImage.blueimageWithColor(color: .white)
        
        addChildVC(childVC: ViewController(), tile1: "全部", image1: "home")
        addChildVC(childVC: TFYSwiftMineController(), tile1: "我的", image1: "me")
    }
    
    func addChildVC(childVC:UIViewController,tile1:String,image1:String) -> Void {
        childVC.title = tile1
        
        var img = UIImage(named: image1)
        img = img?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var selectedImg = UIImage(named: image1 + "_selected")
        selectedImg = selectedImg?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        childVC.tabBarItem.image = img
        childVC.tabBarItem.selectedImage = selectedImg
        let nav = UINavigationController(rootViewController: childVC)
        nav.view.backgroundColor = .white
        addChild(nav)
    }

}
