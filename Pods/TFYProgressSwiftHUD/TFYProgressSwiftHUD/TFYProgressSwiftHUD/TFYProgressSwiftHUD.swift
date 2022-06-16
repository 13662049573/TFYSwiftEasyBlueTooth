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

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
public class TFYProgressSwiftHUD: UIView {
    ///基本容器
    private var viewBackground:UIView?
    private var toolbarHUD:UIToolbar?
    private var labelStatus:UILabel?
    
    private var viewProgress:ProgressView?///自定义容器
    private var viewAnimation:UIView?///动画容器
    private var viewAnimatedIcon:UIView?///小图片动画容器
    private var staticImageView:UIImageView?///图片容器

    private var timer:Timer?///定时器
    ///动画类型
    private var animationType = AnimationType.systemActivityIndicator
    ///颜色默认设置
    private var colorBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    private var colorHUD = UIColor.black
    private var colorStatus = UIColor.white
    private var colorAnimation = UIColor.white
    private var colorProgress = UIColor.white

    ///默认图片设置
    private var fontStatus = UIFont.boldSystemFont(ofSize: 24)
    private var imageSuccess = UIImage.checkmark.withTintColor(UIColor.systemGreen,renderingMode: .alwaysOriginal)
    private var imageError = UIImage.remove.withTintColor(UIColor.systemRed,renderingMode: .alwaysOriginal)
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
    }
    
    private func setup(status:String? = nil , progress:CGFloat? = nil, animatedIcon:AnimatedIcon? = nil,staticImage:UIImage? = nil,hide:Bool,interaction:Bool) {
        
        setupNotifications()
        setupBackground(interaction)
        setupToolbar()
        setupLabel(status)
    
        if (progress == nil) && (animatedIcon == nil) && (staticImage == nil) { setupAnimation()                }
        if (progress != nil) && (animatedIcon == nil) && (staticImage == nil) { setupProgress(progress)            }
        if (progress == nil) && (animatedIcon != nil) && (staticImage == nil) { setupAnimatedIcon(animatedIcon)    }
        if (progress == nil) && (animatedIcon == nil) && (staticImage != nil) { setupStaticImage(staticImage)    }

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

        labelStatus?.removeFromSuperview();            labelStatus = nil
        toolbarHUD?.removeFromSuperview();            toolbarHUD = nil
        viewBackground?.removeFromSuperview();        viewBackground = nil

        timer?.invalidate()
        timer = nil
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
            KeyWindows()?.addSubview(viewBackground!)
        }
        viewBackground?.backgroundColor = interaction ? .clear : colorBackground
        viewBackground?.isUserInteractionEnabled = (interaction == false)
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
    }
    ///添加进度条容器
    private func setupProgress(_ progress: CGFloat?) {

        viewAnimation?.removeFromSuperview()
        viewAnimatedIcon?.removeFromSuperview()
        staticImageView?.removeFromSuperview()

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

        if (staticImageView == nil) {
            staticImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        }

        if (staticImageView?.superview == nil) {
            toolbarHUD?.addSubview(staticImageView!)
        }

        staticImageView?.image = staticImage
        staticImageView?.contentMode = .scaleAspectFit
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

        toolbarHUD?.bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let centerX = width/2
        var centerY = height/2

        if (labelStatus?.text != nil) { centerY = 55 }

        viewProgress?.center = CGPoint(x: centerX, y: centerY)
        viewAnimation?.center = CGPoint(x: centerX, y: centerY)
        viewAnimatedIcon?.center = CGPoint(x: centerX, y: centerY)
        staticImageView?.center = CGPoint(x: centerX, y: centerY)
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
        
        let mainWindow = UIApplication.shared.windows.first ?? UIWindow()
        let screen = mainWindow.bounds
        let center = CGPoint(x: screen.size.width/2, y: (screen.size.height - heightKeyboard)/2)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .allowUserInteraction, animations: {
            self.toolbarHUD?.center = center
            self.viewBackground?.frame = screen
        }, completion: nil)
    }
    
    ///获取最合适的容器高度
    private func keyboardHeight() -> CGFloat {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
           let inputSetContainerView = NSClassFromString("UIInputSetContainerView"),
           let inputSetHostView = NSClassFromString("UIInputSetHostView"){
            
            for window in UIApplication.shared.windows {
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
        return 0
    }
}

public func KeyWindows() -> UIWindow? {
    var keyWindow:UIWindow?
    if #available(iOS 13.0, *) {
        keyWindow = UIApplication.shared.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows.first
    } else {
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            keyWindow = window
        } else {
            for window in UIApplication.shared.windows where window.windowLevel == .normal && !window.isHidden {
                keyWindow = window
            }
            keyWindow = UIApplication.shared.windows.first
        }
    }
    return keyWindow
}

@available(iOS 13.0, *)
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


@available(iOS 13.0, *)
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
    
}
