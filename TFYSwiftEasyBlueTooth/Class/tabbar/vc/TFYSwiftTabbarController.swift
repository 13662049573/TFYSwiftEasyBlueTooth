//
//  TFYSwiftTabbarController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//

import UIKit

class TFYSwiftTabbarController: UITabBarController {

    private var didSetupTabBarTransparency = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupInitialViewController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 只在第一次布局时设置透明度效果
        setupTabBarTransparency()
    }
    
    /// 设置初始视图控制器（只创建首页）
    private func setupInitialViewController() {
        // 创建所有视图控制器，但延迟UI设置
        let homeVC = ViewController()
        let demoVC = TFYSwiftMineController()
        
        // 包装到导航控制器中
        let homeNav = createNavigationController(rootViewController: homeVC,
                                                  title: "全部",
                                                  image: UIImage(named: "home"),
                                                  selectedImage: UIImage(named: "home_selected"))
        
        let demoNav = createNavigationController(rootViewController: demoVC,
                                                 title: "演示",
                                                 image: UIImage(named: "message"),
                                                 selectedImage: UIImage(named: "message_selected"))
        
        // 设置标签栏控制器的视图控制器数组
        viewControllers = [homeNav, demoNav]
    }
    
    
    /// 创建导航控制器
    /// - Parameters:
    ///   - rootViewController: 根视图控制器
    ///   - title: 标题
    ///   - image: 未选中图标
    ///   - selectedImage: 选中图标
    /// - Returns: 配置好的导航控制器
    private func createNavigationController(rootViewController: UIViewController,
                                           title: String,
                                           image: UIImage?,
                                           selectedImage: UIImage?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.selectedImage = selectedImage
        rootViewController.navigationItem.title = title
        return navigationController
    }
    
    /// 设置标签栏外观
    private func setupTabBarAppearance() {
        // 设置标签栏选中颜色
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        // iOS 15+ 需要使用新的 appearance API
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // 设置标签栏项目的外观
            appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    /// 设置TabBar透明度效果（仅执行一次，避免重复触碰私有子视图）
    private func setupTabBarTransparency() {
        guard !didSetupTabBarTransparency else { return }
        didSetupTabBarTransparency = true
        for v in view.getTabBarPlatterViews("_UITabBarContainerWrapperView") {
            v.backgroundColor = .clear
        }
        for v in tabBar.getTabBarPlatterViews("_UITabBarPlatterView") {
            v.backgroundColor = .clear
        }
    }

}

extension UIView {
    func getTabBarPlatterViews(_ viewStr:String) -> [UIView] {
        return self.subviews.filter { view in
            String(describing: type(of: view)).contains(viewStr)
        }
    }
}
