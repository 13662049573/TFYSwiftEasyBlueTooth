# 🎨 TFYProgressSwiftHUD

[![Version](https://img.shields.io/cocoapods/v/TFYProgressSwiftHUD.svg?style=flat)](https://cocoapods.org/pods/TFYProgressSwiftHUD)
[![License](https://img.shields.io/cocoapods/l/TFYProgressSwiftHUD.svg?style=flat)](https://cocoapods.org/pods/TFYProgressSwiftHUD)
[![Platform](https://img.shields.io/cocoapods/p/TFYProgressSwiftHUD.svg?style=flat)](https://cocoapods.org/pods/TFYProgressSwiftHUD)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-14.0+-green.svg)](https://developer.apple.com/xcode/)

<div align="center">
  <img src="https://img.shields.io/badge/Made%20with-Swift-red.svg" alt="Made with Swift">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
  <img src="https://img.shields.io/badge/Platform-iOS-lightgrey.svg" alt="Platform">
</div>

---

## ✨ 简介

**TFYProgressSwiftHUD** 是一个功能强大、设计优雅的 Swift HUD（Heads Up Display）库，专为现代 iOS 应用设计。提供丰富的动画效果、灵活的定制选项和简洁易用的 API，让您的应用拥有专业级的用户反馈体验。

### 🎯 核心优势

- 🚀 **高性能** - 基于 Core Animation 的流畅动画
- 🎨 **丰富动画** - 11种精美加载动画 + 3种状态动画
- 🌙 **深色模式** - 完美支持系统外观切换
- 📱 **设备适配** - iPhone/iPad 完美适配
- ⚡ **简单易用** - 一行代码即可使用
- 🔧 **高度可定制** - 颜色、字体、动画类型随心配置

---

## 🎪 功能特性

### 🎨 动画效果
| 动画类型 | 描述 | 适用场景 |
|---------|------|----------|
| 🔄 系统活动指示器 | 经典旋转加载 | 通用加载 |
| ⭕ 水平圆脉冲 | 三个圆点脉冲 | 网络请求 |
| 📊 线条缩放 | 五条线缩放 | 数据处理 |
| ⭕ 单圆脉冲 | 单个圆脉冲 | 轻量级加载 |
| ⭕⭕⭕ 多圆脉冲 | 多个圆脉冲 | 复杂操作 |
| 🌊 单圆缩放波纹 | 波纹扩散效果 | 文件上传 |
| 🌊🌊🌊 多圆缩放波纹 | 多层波纹 | 视频处理 |
| 💫 圆形旋转淡入淡出 | 旋转+透明度 | 图片处理 |
| 📈 线条旋转淡入淡出 | 线条旋转 | 数据同步 |
| 🎯 圆形旋转追逐 | 追逐动画 | 游戏加载 |
| 🎨 圆形描边旋转 | 描边旋转 | 艺术类应用 |

### 🎪 状态图标
- ✅ **成功图标** - 优雅的勾选动画
- ❌ **失败图标** - 清晰的错误提示
- ➕ **添加图标** - 友好的添加确认

### 🏷️ 系统图标集成
支持19种SF Symbols图标，包括：
- ❤️ 爱心、📄 文档、🔖 书签
- 🌙 月亮、⭐ 星星、⚠️ 警告
- 🚩 旗帜、💬 消息、❓ 问题
- ⚡ 闪电、🔀 随机、⏏️ 弹出
- 💳 卡片、🔄 旋转、👍 点赞
- 👎 点踩、🤚 隐私、🛒 购物车、🔍 搜索

---

## 📱 系统要求

- **iOS**: 15.0+
- **Swift**: 5.0+
- **Xcode**: 14.0+
- **CocoaPods**: 1.0+

---

## 🚀 快速安装

### CocoaPods

```ruby
# Podfile
pod 'TFYProgressSwiftHUD'
```

```bash
# 终端执行
pod install
```

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/13662049573/TFYProgressSwiftHUD.git", from: "2.1.3")
]
```

---

## 🎯 快速开始

### 基础使用

```swift
import TFYProgressSwiftHUD

// 显示加载动画
TFYProgressSwiftHUD.show("请稍等...")

// 显示成功提示
TFYProgressSwiftHUD.showSuccess("操作成功!")

// 显示错误提示
TFYProgressSwiftHUD.showError("发生错误")

// 显示进度
TFYProgressSwiftHUD.showProgress(0.5, "加载中...")

// 隐藏HUD
TFYProgressSwiftHUD.dismiss()
```

### 高级用法

```swift
// 自定义动画类型
TFYProgressSwiftHUD.animationType = .circleRotateChase

// 使用系统图标
TFYProgressSwiftHUD.show("已收藏!", icon: .bookmark)

// 自定义视图
let customView = createCustomAnimationView()
TFYProgressSwiftHUD.show("自定义动画", customView: customView)

// 全屏自定义视图
let fullScreenView = createFullScreenView()
TFYProgressSwiftHUD.showFullScreen(fullScreenView)
```

---

## 🎨 自定义配置

### 颜色定制

```swift
// 背景颜色
TFYProgressSwiftHUD.colorBackground = UIColor.black.withAlphaComponent(0.3)

// HUD颜色
TFYProgressSwiftHUD.colorHUD = UIColor.systemGray6

// 文字颜色
TFYProgressSwiftHUD.colorStatus = UIColor.label

// 动画颜色
TFYProgressSwiftHUD.colorAnimation = UIColor.systemBlue

// 进度条颜色
TFYProgressSwiftHUD.colorProgress = UIColor.systemGreen
```

### 字体定制

```swift
// 设置字体
TFYProgressSwiftHUD.fontStatus = UIFont.boldSystemFont(ofSize: 18)

// 使用系统字体
TFYProgressSwiftHUD.fontStatus = UIFont.systemFont(ofSize: 16, weight: .medium)
```

### 图标定制

```swift
// 自定义成功图标
TFYProgressSwiftHUD.imageSuccess = UIImage(named: "custom-success")

// 自定义错误图标
TFYProgressSwiftHUD.imageError = UIImage(named: "custom-error")
```

---

## 📚 API 参考

### 显示方法

```swift
// 基础显示
TFYProgressSwiftHUD.show(_ status: String?, interaction: Bool = true)

// 带图标的显示
TFYProgressSwiftHUD.show(_ status: String?, icon: AlertIcon, interaction: Bool = true)

// 动画图标显示
TFYProgressSwiftHUD.show(_ status: String?, icon animatedIcon: AnimatedIcon, interaction: Bool = true)

// 成功/错误显示
TFYProgressSwiftHUD.showSuccess(_ status: String?, image: UIImage? = nil, interaction: Bool = true)
TFYProgressSwiftHUD.showError(_ status: String?, image: UIImage? = nil, interaction: Bool = true)

// 状态显示
TFYProgressSwiftHUD.showSucceed(_ status: String?, interaction: Bool = true)
TFYProgressSwiftHUD.showFailed(_ status: String?, interaction: Bool = true)
TFYProgressSwiftHUD.showAdded(_ status: String?, interaction: Bool = true)

// 进度显示
TFYProgressSwiftHUD.showProgress(_ progress: CGFloat, interaction: Bool = false)
TFYProgressSwiftHUD.showProgress(_ status: String?, _ progress: CGFloat, interaction: Bool = false)

// 自定义视图
TFYProgressSwiftHUD.show(_ status: String?, customView: UIView, interaction: Bool = true)
TFYProgressSwiftHUD.showFullScreen(_ customView: UIView, interaction: Bool = false)

// 隐藏
TFYProgressSwiftHUD.dismiss()
```

### 枚举类型

```swift
// 动画类型
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

// 动画图标
public enum AnimatedIcon {
    case succeed
    case failed
    case added
}

// 系统图标
public enum AlertIcon {
    case heart, doc, bookmark, moon, star
    case exclamation, flag, message, question
    case bolt, shuffle, eject, card, rotate
    case like, dislike, privacy, cart, search
}
```

---

## 🎬 使用示例

### 网络请求示例

```swift
func fetchUserData() {
    // 显示加载
    TFYProgressSwiftHUD.show("获取用户信息...")
    
    // 模拟网络请求
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        // 请求成功
        TFYProgressSwiftHUD.showSuccess("获取成功!")
        
        // 或者请求失败
        // TFYProgressSwiftHUD.showError("网络错误")
    }
}
```

### 文件上传示例

```swift
func uploadFile() {
    var progress: CGFloat = 0
    
    // 显示进度
    TFYProgressSwiftHUD.showProgress(progress, "上传中...")
    
    // 模拟上传进度
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
        progress += 0.01
        TFYProgressSwiftHUD.showProgress(progress, "上传中...")
        
        if progress >= 1.0 {
            timer.invalidate()
            TFYProgressSwiftHUD.showSuccess("上传完成!")
        }
    }
}
```

### 自定义动画示例

```swift
func showCustomAnimation() {
    // 创建自定义动画视图
    let customView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    // 添加动画效果
    let animation = CABasicAnimation(keyPath: "transform.rotation")
    animation.toValue = NSNumber(value: Double.pi * 2)
    animation.duration = 1
    animation.repeatCount = .infinity
    
    customView.layer.add(animation, forKey: "rotation")
    
    // 显示自定义动画
    TFYProgressSwiftHUD.show("自定义动画", customView: customView)
}
```

---

## 🔧 高级功能

### 深色模式支持

库自动适配系统外观变化，支持深色模式：

```swift
// 自动适配系统外观
// 无需额外配置，库会自动处理
```

### 键盘适配

自动处理键盘显示/隐藏事件：

```swift
// 自动适配键盘
// 无需额外配置
```

### 设备方向适配

自动处理设备方向变化：

```swift
// 自动适配设备方向
// 无需额外配置
```

---

## 🐛 故障排除

### 常见问题

**Q: 动画不显示？**
A: 确保在主线程调用，检查iOS版本是否支持。

**Q: 颜色不生效？**
A: 确保在显示HUD之前设置颜色属性。

**Q: 自定义视图不显示？**
A: 确保自定义视图有正确的frame和内容。

### 调试技巧

```swift
// 开启调试模式
#if DEBUG
    print("TFYProgressSwiftHUD Debug: \(message)")
#endif
```

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. Fork 这个项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

### 开发环境

```bash
# 克隆项目
git clone https://github.com/13662049573/TFYProgressSwiftHUD.git

# 安装依赖
pod install

# 打开项目
open TFYProgressSwiftHUD.xcworkspace
```

---

## 📄 许可证

本项目基于 **MIT** 许可证开源。详见 [LICENSE](LICENSE) 文件。

---

## 👨‍💻 作者

**田风有** - [GitHub](https://github.com/13662049573)

- 📧 Email: 420144542@qq.com
- 🌐 Website: [GitHub Profile](https://github.com/13662049573)

---

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

- [CocoaPods](https://cocoapods.org/) - 依赖管理
- [Lottie](https://github.com/airbnb/lottie-ios) - 动画支持
- [SF Symbols](https://developer.apple.com/sf-symbols/) - 系统图标

---

<div align="center">
  <sub>Built with ❤️ by 田风有</sub>
</div>
