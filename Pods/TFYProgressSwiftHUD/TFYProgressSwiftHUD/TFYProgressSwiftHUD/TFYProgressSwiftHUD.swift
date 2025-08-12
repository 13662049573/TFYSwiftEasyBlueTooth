//
//  TFYProgressSwiftHUD.swift
//  TFYProgressSwiftHUD
//
//  Created by 田风有 on 2021/4/10.
//

import UIKit
import Foundation

public enum AnimationType {
    case systemActivityIndicator
    case horizontalCirclesPulse
    case lineScaling
    case singleCirclePulse
    case multipleCirclePulse
    case singleCircleScaleRipple
    case multipleCircleScaleRipple
    case circleSpinFade
    case lineSpinFade
    case circleRotateChase
    case circleStrokeSpin
}

public enum AnimatedIcon {
    case succeed
    case failed
    case added
}

public enum AlertIcon {
    case heart
    case doc
    case bookmark
    case moon
    case star
    case exclamation
    case flag
    case message
    case question
    case bolt
    case shuffle
    case eject
    case card
    case rotate
    case like
    case dislike
    case privacy
    case cart
    case search
}

@available(iOS 15.0, *)
extension AlertIcon {
    var image: UIImage? {
        switch self {
            case .heart:        return UIImage(systemName: "heart.fill")
            case .doc:            return UIImage(systemName: "doc.fill")
            case .bookmark:        return UIImage(systemName: "bookmark.fill")
            case .moon:            return UIImage(systemName: "moon.fill")
            case .star:            return UIImage(systemName: "star.fill")
            case .exclamation:    return UIImage(systemName: "exclamationmark.triangle.fill")
            case .flag:            return UIImage(systemName: "flag.fill")
            case .message:        return UIImage(systemName: "envelope.fill")
            case .question:        return UIImage(systemName: "questionmark.diamond.fill")
            case .bolt:            return UIImage(systemName: "bolt.fill")
            case .shuffle:        return UIImage(systemName: "shuffle")
            case .eject:        return UIImage(systemName: "eject.fill")
            case .card:            return UIImage(systemName: "creditcard.fill")
            case .rotate:        return UIImage(systemName: "rotate.right.fill")
            case .like:            return UIImage(systemName: "hand.thumbsup.fill")
            case .dislike:        return UIImage(systemName: "hand.thumbsdown.fill")
            case .privacy:        return UIImage(systemName: "hand.raised.fill")
            case .cart:            return UIImage(systemName: "cart.fill")
            case .search:        return UIImage(systemName: "magnifyingglass")
        }
    }
}

@available(iOS 15.0, *)
public class TFYProgressSwiftHUD: UIView {
    ///基本容器
    private var viewBackground:UIView?
    private var toolbarHUD:UIToolbar?
    private var labelStatus:UILabel?
    
    private var viewProgress:ProgressView?///自定义容器
    private var viewAnimation:UIView?///动画容器
    private var viewAnimatedIcon:UIView?///小图片动画容器
    private var staticImageView:UIImageView?///图片容器
    private var customView:UIView?///自定义view容器

    private var timer:Timer?///定时器
    ///动画类型
    private var animationType = AnimationType.systemActivityIndicator
    ///颜色默认设置
    private var colorBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    private var colorHUD = UIColor.black
    private var colorStatus = UIColor.white
    private var colorAnimation = UIColor.white
    private var colorProgress = UIColor.white
    
    ///更新颜色以支持深色模式
    private func updateColorsForAppearance() {
        colorBackground = UIColor.systemBackground.withAlphaComponent(0.2)
        colorHUD = UIColor.systemGray6
        colorStatus = UIColor.label
        colorAnimation = UIColor.label
        colorProgress = UIColor.label
    }
    ///默认图片设置
    private var fontStatus = UIFont.boldSystemFont(ofSize: 24)
    private var imageSuccess: UIImage = {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "checkmark")?.withTintColor(UIColor.systemGreen, renderingMode: .alwaysOriginal) ?? UIImage()
        } else {
            // 为iOS 15+提供默认的checkmark图片
            return UIImage()
        }
    }()
    private var imageError: UIImage = {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "xmark")?.withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal) ?? UIImage()
        } else {
            // 为iOS 15+提供默认的xmark图片
            return UIImage()
        }
    }()
    ///监听键盘事件
    private let keyboardWillShow    = UIResponder.keyboardWillShowNotification
    private let keyboardWillHide    = UIResponder.keyboardWillHideNotification
    private let keyboardDidShow     = UIResponder.keyboardDidShowNotification
    private let keyboardDidHide     = UIResponder.keyboardDidHideNotification
    ///检测模拟器在各个方向上的切换
    private var orientationDidChange = UIDevice.orientationDidChangeNotification
    ///单例模式
    static let shared:TFYProgressSwiftHUD = {
        let instance = TFYProgressSwiftHUD()
        return instance
    }()
    
    convenience private init() {
        self.init(frame:UIScreen.main.bounds)
        self.alpha = 0
    }
    
    required internal init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        updateColorsForAppearance()
        setupAppearanceObserver()
    }
    
    private func setupAppearanceObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appearanceDidChange),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appearanceDidChange() {
        updateColorsForAppearance()
    }
    
    private func setup(status:String? = nil , progress:CGFloat? = nil, animatedIcon:AnimatedIcon? = nil,staticImage:UIImage? = nil,customView:UIView? = nil,fullScreenCustomView:UIView? = nil,hide:Bool,interaction:Bool) {
        
        // 确保在主线程执行
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.setup(status: status, progress: progress, animatedIcon: animatedIcon, staticImage: staticImage, customView: customView, fullScreenCustomView: fullScreenCustomView, hide: hide, interaction: interaction)
            }
            return
        }
        
        setupNotifications()
        setupBackground(interaction)
        setupToolbar()
        setupLabel(status)
    
        if (progress == nil) && (animatedIcon == nil) && (staticImage == nil) && (customView == nil) && (fullScreenCustomView == nil) { setupAnimation()                }
        if (progress != nil) && (animatedIcon == nil) && (staticImage == nil) && (customView == nil) && (fullScreenCustomView == nil) { setupProgress(progress)            }
        if (progress == nil) && (animatedIcon != nil) && (staticImage == nil) && (customView == nil) && (fullScreenCustomView == nil) { setupAnimatedIcon(animatedIcon)    }
        if (progress == nil) && (animatedIcon == nil) && (staticImage != nil) && (customView == nil) && (fullScreenCustomView == nil) { setupStaticImage(staticImage)    }
        if (progress == nil) && (animatedIcon == nil) && (staticImage == nil) && (customView != nil) && (fullScreenCustomView == nil) { setupCustomView(customView)    }
        if (progress == nil) && (animatedIcon == nil) && (staticImage == nil) && (customView == nil) && (fullScreenCustomView != nil) { setupFullScreenCustomView(fullScreenCustomView)    }

        setupSize()
        setupPosition()
        
        hudShow()

        if (hide) {
            let text = labelStatus?.text ?? ""
            let delay = Double(text.count) * 0.03 + 1.25
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                self.hudHide()
            }
        }
    }
    ///弹出视图
    private func hudShow() {
        timer?.invalidate()
        timer = nil
        
        if (self.alpha != 1) {
            self.alpha = 1
            toolbarHUD?.alpha = 0
            toolbarHUD?.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)

            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.toolbarHUD?.transform = CGAffineTransform(scaleX: 1/1.4, y: 1/1.4)
                self.toolbarHUD?.alpha = 1
            }, completion: nil)
        }
    }
    ///隐藏视图
    private func hudHide() {

        if (self.alpha == 1) {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.toolbarHUD?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                self.toolbarHUD?.alpha = 0
            }, completion: { isFinished in
                self.hudDestroy()
                self.alpha = 0
            })
        }
    }
    ///清楚所有
    private func hudDestroy() {

        NotificationCenter.default.removeObserver(self)

        staticImageView?.removeFromSuperview();        staticImageView = nil
        viewAnimatedIcon?.removeFromSuperview();    viewAnimatedIcon = nil
        viewAnimation?.removeFromSuperview();        viewAnimation = nil
        viewProgress?.removeFromSuperview();        viewProgress = nil
        customView?.removeFromSuperview();            customView = nil

        labelStatus?.removeFromSuperview();            labelStatus = nil
        toolbarHUD?.removeFromSuperview();            toolbarHUD = nil
        viewBackground?.removeFromSuperview();        viewBackground = nil

        timer?.invalidate()
        timer = nil
        
        // 清理动画层
        viewAnimation?.layer.sublayers?.forEach { $0.removeAllAnimations() }
        viewAnimatedIcon?.layer.sublayers?.forEach { $0.removeAllAnimations() }
    }
    ///添加监听
    private func setupNotifications() {
        if viewBackground == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardWillHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardDidShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardDidHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: orientationDidChange, object: nil)
        }
    }
    ///添加底层容器在window 上
    private func setupBackground(_ interaction:Bool) {
        if viewBackground == nil {
            viewBackground = UIView(frame: self.bounds)
            if let window = KeyWindows() {
                window.addSubview(viewBackground!)
            } else {
                // 如果无法获取主窗口，尝试使用当前视图控制器的视图
                if let topViewController = getTopViewController() {
                    topViewController.view.addSubview(viewBackground!)
                }
            }
        }
        viewBackground?.backgroundColor = interaction ? .clear : colorBackground
        viewBackground?.isUserInteractionEnabled = (interaction == false)
    }
    
    ///获取顶层视图控制器
    private func getTopViewController() -> UIViewController? {
        if let window = KeyWindows() {
            var topViewController = window.rootViewController
            while let presentedViewController = topViewController?.presentedViewController {
                topViewController = presentedViewController
            }
            return topViewController
        }
        return nil
    }
    ///添加加载视图容器
    private func setupToolbar() {
        if toolbarHUD == nil {
            toolbarHUD = UIToolbar(frame: CGRect.zero)
            toolbarHUD?.isTranslucent = true
            toolbarHUD?.clipsToBounds = true
            toolbarHUD?.layer.cornerRadius = 10
            toolbarHUD?.layer.masksToBounds = true
            toolbarHUD?.isOpaque = false
            toolbarHUD?.clearsContextBeforeDrawing = true
            viewBackground?.addSubview(toolbarHUD!)
        }
        toolbarHUD?.backgroundColor = colorHUD
        toolbarHUD?.barTintColor = colorHUD
        toolbarHUD?.tintColor = colorHUD
    }
    ///添加文本容器
    private func setupLabel(_ status:String?) {
        if labelStatus == nil {
            labelStatus = UILabel()
            labelStatus?.textAlignment = .center
            labelStatus?.baselineAdjustment = .alignCenters
            labelStatus?.numberOfLines = 0
            toolbarHUD?.addSubview(labelStatus!)
        }
        labelStatus?.text = (status != "") ? status : nil
        labelStatus?.font = fontStatus
        labelStatus?.textColor = colorStatus
        labelStatus?.isHidden = (status == nil) ? true : false
        labelStatus?.adjustsFontForContentSizeCategory = true
        labelStatus?.isAccessibilityElement = true
        labelStatus?.accessibilityLabel = status
        labelStatus?.accessibilityTraits = .staticText
    }
    ///添加进度条容器
    private func setupProgress(_ progress: CGFloat?) {

        viewAnimation?.removeFromSuperview()
        viewAnimatedIcon?.removeFromSuperview()
        staticImageView?.removeFromSuperview()
        customView?.removeFromSuperview()

        if (viewProgress == nil) {
            viewProgress = ProgressView(colorProgress)
            viewProgress?.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        }

        if (viewProgress?.superview == nil) {
            toolbarHUD?.addSubview(viewProgress!)
        }

        viewProgress?.setProgress(progress!)
    }
    ///动画添加
    private func setupAnimation() {
        viewProgress?.removeFromSuperview()
        viewAnimatedIcon?.removeFromSuperview()
        staticImageView?.removeFromSuperview()
        customView?.removeFromSuperview()
        
        if viewAnimation == nil {
            viewAnimation = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        }
        
        if viewAnimation?.superview == nil {
            toolbarHUD?.addSubview(viewAnimation!)
        }
        
        viewAnimation?.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        viewAnimation?.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        if (animationType == .systemActivityIndicator)   { animationSystemActivityIndicator(viewAnimation!,color: colorAnimation)   }
        if (animationType == .horizontalCirclesPulse)    { animationHorizontalCirclesPulsc(viewAnimation!,color: colorAnimation)    }
        if (animationType == .lineScaling)               { animationLineScaling(viewAnimation!,color: colorAnimation)               }
        if (animationType == .singleCirclePulse)         { animationSingleCirclePulse(viewAnimation!,color: colorAnimation)         }
        if (animationType == .multipleCirclePulse)       { animationMultipleCirclePulse(viewAnimation!,color: colorAnimation)       }
        if (animationType == .singleCircleScaleRipple)   { animationSingleCircleScaleRipple(viewAnimation!,color: colorAnimation)   }
        if (animationType == .multipleCircleScaleRipple) { animationMultipleCircleScaleRipple(viewAnimation!,color: colorAnimation) }
        if (animationType == .circleSpinFade)            { animationCircleSpinFade(viewAnimation!,color: colorAnimation)            }
        if (animationType == .lineSpinFade)              { animationLineSpinFade(viewAnimation!,color: colorAnimation)              }
        if (animationType == .circleRotateChase)         { animationCircleRotateChase(viewAnimation!,color: colorAnimation)         }
        if (animationType == .circleStrokeSpin)          { animationCircleStrokeSpin(viewAnimation!,color: colorAnimation)          }
    }
    
    private func setupAnimatedIcon(_ animatedIcon:AnimatedIcon?) {
        viewProgress?.removeFromSuperview()
        viewAnimation?.removeFromSuperview()
        staticImageView?.removeFromSuperview()
        customView?.removeFromSuperview()
        
        if viewAnimatedIcon == nil {
            viewAnimatedIcon = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        }
        
        if (viewAnimatedIcon?.superview == nil) {
            toolbarHUD?.addSubview(viewAnimatedIcon!)
        }
        
        viewAnimatedIcon?.layer.sublayers?.forEach {
            $0.removeAllAnimations()
        }
        
        if (animatedIcon == .succeed)   { animatedIconSucceed(viewAnimatedIcon!,color: colorAnimation,alpha:self.alpha) }
        if (animatedIcon == .failed)    { animatedIconFailed(viewAnimatedIcon!,color: colorAnimation,alpha: self.alpha)  }
        if (animatedIcon == .added)     { animatedIconAdded(viewAnimatedIcon!,color: colorAnimation,alpha: self.alpha)   }

    }
    ///添加图片容器
    private func setupStaticImage(_ staticImage: UIImage?) {
        viewProgress?.removeFromSuperview()
        viewAnimation?.removeFromSuperview()
        viewAnimatedIcon?.removeFromSuperview()
        customView?.removeFromSuperview()

        if (staticImageView == nil) {
            staticImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        }

        if (staticImageView?.superview == nil) {
            toolbarHUD?.addSubview(staticImageView!)
        }

        staticImageView?.image = staticImage
        staticImageView?.contentMode = .scaleAspectFit
    }
    ///添加自定义view容器
    private func setupCustomView(_ customView: UIView?) {
        viewProgress?.removeFromSuperview()
        viewAnimation?.removeFromSuperview()
        viewAnimatedIcon?.removeFromSuperview()
        staticImageView?.removeFromSuperview()

        if (self.customView == nil) {
            self.customView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        }

        if (self.customView?.superview == nil) {
            toolbarHUD?.addSubview(self.customView!)
        }

        // 如果传入了自定义view，则替换当前的customView
        if let customView = customView {
            self.customView?.removeFromSuperview()
            self.customView = customView
            toolbarHUD?.addSubview(self.customView!)
        }
    }
    
    ///添加全屏自定义view容器
    private func setupFullScreenCustomView(_ customView: UIView?) {
        viewProgress?.removeFromSuperview()
        viewAnimation?.removeFromSuperview()
        viewAnimatedIcon?.removeFromSuperview()
        staticImageView?.removeFromSuperview()
        self.customView?.removeFromSuperview()

        // 如果传入了自定义view，则直接添加到背景view上
        if let customView = customView {
            self.customView = customView
            viewBackground?.addSubview(self.customView!)
            
            // 设置全屏布局
            self.customView?.translatesAutoresizingMaskIntoConstraints = false
            if let backgroundView = viewBackground, let customView = self.customView {
                NSLayoutConstraint.activate([
                    customView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                    customView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                    customView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                    customView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
                ])
            }
        }
    }
    ///计算文本大小
    private func setupSize() {
        var width: CGFloat = 120
        var height: CGFloat = 120

        if let text = labelStatus?.text {
            let sizeMax = CGSize(width: 250, height: 250)
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: labelStatus?.font as Any]
            var rectLabel = text.boundingRect(with: sizeMax, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

            width = ceil(rectLabel.size.width) + 60
            height = ceil(rectLabel.size.height) + 120

            if (width < 120) { width = 120 }

            rectLabel.origin.x = (width - rectLabel.size.width) / 2
            rectLabel.origin.y = (height - rectLabel.size.height) / 2 + 45

            labelStatus?.frame = rectLabel
        }

        // iPad适配：增加最小尺寸
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = max(width, 200)
            height = max(height, 200)
        }

        toolbarHUD?.bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let centerX = width/2
        var centerY = height/2

        if (labelStatus?.text != nil) { centerY = 55 }

        viewProgress?.center = CGPoint(x: centerX, y: centerY)
        viewAnimation?.center = CGPoint(x: centerX, y: centerY)
        viewAnimatedIcon?.center = CGPoint(x: centerX, y: centerY)
        staticImageView?.center = CGPoint(x: centerX, y: centerY)
        customView?.center = CGPoint(x: centerX, y: centerY)
    }
    
    ///背景容器监听
    @objc private func setupPosition(_ notification:Notification? = nil) {
        
        var heightKeyboard:CGFloat = 0
        var animationDuration:TimeInterval = 0
        
        if let notification = notification {
            let frameKeyborad = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero
            animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
            
            if (notification.name == keyboardWillShow) || (notification.name == keyboardDidShow) {
                heightKeyboard = frameKeyborad.size.height
            } else if (notification.name == keyboardWillHide) || (notification.name == keyboardDidHide) {
                heightKeyboard = 0
            } else {
                heightKeyboard = keyboardHeight()
            }
        } else {
            heightKeyboard = keyboardHeight()
        }
        
        let mainWindow = KeyWindows()!
        let screen = mainWindow.bounds
        let center = CGPoint(x: screen.size.width/2, y: (screen.size.height - heightKeyboard)/2)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .allowUserInteraction, animations: {
            self.toolbarHUD?.center = center
            self.viewBackground?.frame = screen
        }, completion: nil)
    }
    
    ///获取最合适的容器高度
    private func keyboardHeight() -> CGFloat {
        // 优先使用通知中的键盘高度
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
           let inputSetContainerView = NSClassFromString("UIInputSetContainerView"),
           let inputSetHostView = NSClassFromString("UIInputSetHostView"){
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // 获取窗口列表
                let windows = scene.windows
                for window in windows {
                    if window.isKind(of: keyboardWindowClass) {
                        for firstSubView in window.subviews {
                            if firstSubView.isKind(of: inputSetContainerView) {
                                for secondSubView in firstSubView.subviews {
                                    if secondSubView.isKind(of: inputSetHostView) {
                                        return secondSubView.frame.size.height
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 备用方案：使用屏幕高度差值
        if let window = KeyWindows() {
            let screenHeight = UIScreen.main.bounds.height
            let windowHeight = window.frame.height
            let keyboardHeight = screenHeight - windowHeight
            return keyboardHeight > 0 ? keyboardHeight : 0
        }
        
        return 0
    }
}

public func KeyWindows() -> UIWindow? {
    var keyWindow:UIWindow?
    keyWindow = UIApplication.shared.connectedScenes
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows.first
    return keyWindow
}

@available(iOS 15.0, *)
private class ProgressView:UIView {
    
    var color: UIColor = .systemBackground {
        didSet { setupLayers() }
    }
    private var progress:CGFloat = 0
    
    private var layerCircle = CAShapeLayer()
    private var layerProgress = CAShapeLayer()
    private var labelPercentage:UILabel = UILabel()
    
    convenience init(_ color: UIColor) {
        self.init(frame: .zero)
        self.color = color
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupLayers()
    }
    ///基本容器设置
    func setupLayers() {
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let width = frame.size.width
        let height = frame.size.height

        let center = CGPoint(x: width/2, y: height/2)
        let radiusCircle = width / 2
        let radiusProgress = width / 2 - 5

        let pathCircle = UIBezierPath(arcCenter: center, radius: radiusCircle, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)
        let pathProgress = UIBezierPath(arcCenter: center, radius: radiusProgress, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)

        layerCircle.path = pathCircle.cgPath
        layerCircle.fillColor = UIColor.clear.cgColor
        layerCircle.lineWidth = 3
        layerCircle.strokeColor = color.cgColor

        layerProgress.path = pathProgress.cgPath
        layerProgress.fillColor = UIColor.clear.cgColor
        layerProgress.lineWidth = 7
        layerProgress.strokeColor = color.cgColor
        layerProgress.strokeEnd = 0

        layer.addSublayer(layerCircle)
        layer.addSublayer(layerProgress)

        labelPercentage.frame = self.bounds
        labelPercentage.textColor = color
        labelPercentage.textAlignment = .center
        addSubview(labelPercentage)
    }
    
    ///加载动画
    func setProgress(_ value:CGFloat,duration:TimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progress
        animation.toValue = value
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        layerProgress.add(animation, forKey: "animation")
        
        progress = value
        labelPercentage.text = "\(Int(value*100))%"
        
    }
    
}


@available(iOS 15.0, *)
public extension TFYProgressSwiftHUD {
    ///选择展示内部动画属于
    class var animationType:AnimationType {
        get { shared.animationType }
        set { shared.animationType = newValue }
    }
    ///背景颜色自定义
    class var colorBackground: UIColor {
        get { shared.colorBackground }
        set { shared.colorBackground = newValue }
    }
    ///加载视图背景颜色
    class var colorHUD: UIColor {
        get { shared.colorHUD }
        set { shared.colorHUD = newValue }
    }
    ////字体颜色
    class var colorStatus: UIColor {
        get { shared.colorStatus }
        set { shared.colorStatus = newValue }
    }
    ///动画颜色
    class var colorAnimation: UIColor {
        get { shared.colorAnimation }
        set { shared.colorAnimation = newValue }
    }
    ///进度条颜色
    class var colorProgress: UIColor {
        get { shared.colorProgress }
        set { shared.colorProgress = newValue }
    }
    ///字体大小
    class var fontStatus: UIFont {
        get { shared.fontStatus }
        set { shared.fontStatus = newValue }
    }
    ///加载成功自定义图片
    class var imageSuccess: UIImage {
        get { shared.imageSuccess }
        set { shared.imageSuccess = newValue }
    }
    ///加载失败自定义图片
    class var imageError: UIImage {
        get { shared.imageError }
        set { shared.imageError = newValue }
    }
}

public extension TFYProgressSwiftHUD {
    ///隐藏视图
    class func dismiss() {
        DispatchQueue.main.async {
            shared.hudHide()
        }
    }
    ///带有加载圈文体的弹出视图
    class func show(_ status:String? = nil,interaction:Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status,hide: false, interaction: interaction)
        }
    }
    ///默认图片的文本弹出视图
    class func show(_ status:String? = nil,icon:AlertIcon,interaction:Bool = true) {
        let image = icon.image?.withTintColor(shared.colorAnimation, renderingMode: .alwaysOriginal)

        DispatchQueue.main.async {
            shared.setup(status: status, staticImage: image, hide: true, interaction: interaction)
        }
    }
    ///带有选择图片类型的文本弹出
    class func show(_ status: String? = nil, icon animatedIcon: AnimatedIcon, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, animatedIcon: animatedIcon, hide: true, interaction: interaction)
        }
    }
    ///自定义图片文本弹出视图
    class func showSuccess(_ status: String? = nil, image: UIImage? = nil, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, staticImage: image ?? shared.imageSuccess, hide: true, interaction: interaction)
        }
    }
    ///带有图片失败弹出视图
    class func showError(_ status: String? = nil, image: UIImage? = nil, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, staticImage: image ?? shared.imageError, hide: true, interaction: interaction)
        }
    }
    ///请求成功只有文本弹出视图
    class func showSucceed(_ status: String? = nil, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, animatedIcon: .succeed, hide: true, interaction: interaction)
        }
    }
    ///请求失败只有文本视图弹出
    class func showFailed(_ status: String? = nil, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, animatedIcon: .failed, hide: true, interaction: interaction)
        }
    }
    ///描述文本弹出视图
    class func showAdded(_ status: String? = nil, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, animatedIcon: .added, hide: true, interaction: interaction)
        }
    }
    ///带有加载进度条视图弹出
    class func showProgress(_ progress: CGFloat, interaction: Bool = false) {
        DispatchQueue.main.async {
            shared.setup(progress: progress, hide: false, interaction: interaction)
        }
    }
    /// 自定义进度条视图弹出
    class func showProgress(_ status: String?, _ progress: CGFloat, interaction: Bool = false) {
        DispatchQueue.main.async {
            shared.setup(status: status, progress: progress, hide: false, interaction: interaction)
        }
    }
    
    /// 自定义view弹出视图
    class func show(_ status: String? = nil, customView: UIView, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, customView: customView, hide: false, interaction: interaction)
        }
    }
    
    /// 自定义view弹出视图（带自动隐藏）
    class func show(_ status: String? = nil, customView: UIView, hide: Bool = true, interaction: Bool = true) {
        DispatchQueue.main.async {
            shared.setup(status: status, customView: customView, hide: hide, interaction: interaction)
        }
    }
    
    /// 全屏自定义view弹出视图
    class func showFullScreen(_ customView: UIView, interaction: Bool = false) {
        DispatchQueue.main.async {
            shared.setup(fullScreenCustomView: customView, hide: false, interaction: interaction)
        }
    }
    
    /// 全屏自定义view弹出视图（带自动隐藏）
    class func showFullScreen(_ customView: UIView, hide: Bool = true, interaction: Bool = false) {
        DispatchQueue.main.async {
            shared.setup(fullScreenCustomView: customView, hide: hide, interaction: interaction)
        }
    }
    
}
