# 🔵 TFYSwiftEasyBlueTooth

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)
[![CocoaPods](https://img.shields.io/cocoapods/v/TFYSwiftEasyBlueToothKit.svg)](https://cocoapods.org/pods/TFYSwiftEasyBlueToothKit)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)

<div align="center">
  <img src="https://img.shields.io/badge/Bluetooth-BLE-0082FC?style=for-the-badge&logo=bluetooth&logoColor=white" alt="Bluetooth BLE">
  <img src="https://img.shields.io/badge/Swift-5.0+-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 5.0+">
  <img src="https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS 15.0+">
</div>

## 📖 简介

**TFYSwiftEasyBlueTooth** 是一个基于 CoreBluetooth 的现代化 Swift 蓝牙框架，专为 iOS 开发者设计。它提供了简洁优雅的 API，让蓝牙设备开发变得简单高效。

### 🎯 设计理念

- **简单易用**: 链式调用风格，减少样板代码
- **功能完整**: 覆盖蓝牙开发的所有核心功能
- **稳定可靠**: 完善的错误处理和状态管理
- **性能优化**: 高效的线程管理和内存使用

## ✨ 核心特性

### 🔍 设备扫描
- **智能扫描**: 支持按名称、UUID、自定义规则扫描
- **批量扫描**: 一次性扫描多个设备
- **实时更新**: 扫描过程中实时回调设备状态变化
- **信号强度**: 支持 RSSI 信号强度读取

### 🔗 连接管理
- **自动重连**: 智能的断线重连机制
- **多设备支持**: 同时连接多个蓝牙设备
- **连接状态**: 完整的连接状态监听
- **超时控制**: 可配置的连接超时时间

### 📡 数据通信
- **读写操作**: 支持特征值的读写操作
- **通知订阅**: 支持通知和指示特征
- **批量操作**: 支持批量读写操作
- **数据转换**: 内置十六进制数据转换工具

### 🛡️ 错误处理
- **完整错误码**: 详细的错误状态定义
- **异常恢复**: 自动处理各种异常情况
- **调试友好**: 详细的错误信息输出

### ⚡ 性能优化
- **异步处理**: 所有操作都是异步执行
- **线程安全**: 完善的线程安全保护
- **内存管理**: 优化的内存使用和释放
- **后台支持**: 支持后台蓝牙操作

## 🚀 快速开始

### 📦 安装

#### CocoaPods
```ruby
pod 'TFYSwiftEasyBlueToothKit'
```

#### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/your-repo/TFYSwiftEasyBlueTooth.git", from: "1.0.0")
]
```

### 🔧 基本使用

#### 1. 初始化管理器
```swift
import TFYSwiftEasyBlueToothKit

// 获取单例管理器
let manager = TFYSwIFTEasyBlueToothManager.shareInstance

// 设置状态监听
manager.bluetoothStateChanged = { peripheral, state in
    switch state {
    case .bluetoothStateSystemReadly:
        print("✅ 蓝牙系统就绪")
    case .bluetoothStateDeviceFounded:
        print("🔍 发现设备: \(peripheral?.name ?? "")")
    case .bluetoothStateDeviceConnected:
        print("🔗 设备连接成功: \(peripheral?.name ?? "")")
    case .bluetoothStateServiceFounded:
        print("📋 发现服务")
    case .bluetoothStateCharacterFounded:
        print("🔧 发现特征")
    case .bluetoothStateNotifySuccess:
        print("📡 通知订阅成功")
    case .bluetoothStateReadSuccess:
        print("📖 读取数据成功")
    case .bluetoothStateWriteDataSuccess:
        print("✍️ 写入数据成功")
    case .bluetoothStateDestory:
        print("❌ 设备断开连接")
    }
}
```

#### 2. 扫描设备
```swift
// 按设备名称扫描
manager.scanDeviceWithName(name: "MyDevice") { peripheral, error in
    if let peripheral = peripheral {
        print("🎯 找到设备: \(peripheral.name ?? "")")
        print("📱 设备ID: \(peripheral.identifierString ?? "")")
        print("📶 信号强度: \(peripheral.RSSI ?? 0)")
    } else if let error = error {
        print("❌ 扫描错误: \(error.localizedDescription)")
    }
}

// 使用自定义规则扫描
manager.scanDeviceWithRule({ peripheral in
    // 自定义扫描规则
    return peripheral.name?.contains("BLE") ?? false
}) { peripheral, error in
    if let peripheral = peripheral {
        print("🎯 找到符合规则的设备: \(peripheral.name ?? "")")
    }
}

// 扫描所有设备
manager.scanAllDeviceWithRule({ peripheral in
    return peripheral.RSSI?.intValue ?? 0 > -80 // 信号强度大于-80
}) { deviceArray, error in
    print("📱 找到 \(deviceArray.count) 个设备")
    deviceArray.forEach { device in
        print("- \(device.name ?? ""): \(device.RSSI ?? 0)")
    }
}
```

#### 3. 连接设备
```swift
// 连接设备
manager.connectDeviceWithPeripheral(peripheral: peripheral) { peripheral, error in
    if error == nil {
        print("✅ 连接成功: \(peripheral?.name ?? "")")
    } else {
        print("❌ 连接失败: \(error?.localizedDescription ?? "")")
    }
}

// 通过设备ID连接
manager.connectDeviceWithIdentifier(identifier: "DEVICE-UUID") { peripheral, error in
    if error == nil {
        print("✅ 通过ID连接成功")
    }
}
```

#### 4. 数据读写
```swift
// 写入数据
let data = "Hello BLE".data(using: .utf8)!
manager.writeDataWithPeripheral(
    peripheral: peripheral,
    serviceUUID: "1800",
    writeUUID: "2A00",
    data: data
) { data, error in
    if error == nil {
        print("✅ 数据写入成功")
    } else {
        print("❌ 写入失败: \(error?.localizedDescription ?? "")")
    }
}

// 读取数据
manager.readValueWithPeripheral(
    peripheral: peripheral,
    serviceUUID: "1800",
    readUUID: "2A00"
) { data, error in
    if let data = data as? Data {
        print("📖 读取数据: \(data.bluehexString())")
        print("📝 文本内容: \(String(data: data, encoding: .utf8) ?? "")")
    }
}
```

#### 5. 监听通知
```swift
// 订阅通知
manager.notifyDataWithPeripheral(
    peripheral: peripheral,
    serviceUUID: "1800",
    notifyUUID: "2A00",
    notifyValue: true
) { data, error in
    if let data = data as? Data {
        print("📡 收到通知: \(data.bluehexString())")
    }
}
```

## 🛠️ 高级功能

### 配置管理器选项
```swift
// 创建自定义配置
let options = TFYSwiftEasyManagerOptions(
    queue: DispatchQueue.global(qos: .userInitiated),
    managerDictionary: [CBCentralManagerOptionShowPowerAlertKey: true],
    scanOptions: [CBCentralManagerScanOptionAllowDuplicatesKey: true],
    scanServiceArray: [CBUUID(string: "1800")],
    connectOptions: [
        CBConnectPeripheralOptionNotifyOnConnectionKey: true,
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
        CBConnectPeripheralOptionNotifyOnNotificationKey: true
    ]
)

// 设置扫描超时时间
options.scanTimeOut = 30 // 30秒
options.connectTimeOut = 10 // 10秒
options.autoConnectAfterDisconnect = true // 自动重连

// 应用配置
manager.managerOptions = options
```

### 设备状态监控
```swift
// 监听设备连接状态
peripheral.connectCallback = { peripheral, error, type in
    switch type {
    case .deviceConnectTypeSuccess:
        print("✅ 设备连接成功")
    case .deviceConnectTypeFaild:
        print("❌ 设备连接失败")
    case .deviceConnectTypeFaildTimeout:
        print("⏰ 设备连接超时")
    case .deviceConnectTypeDisConnect:
        print("🔌 设备断开连接")
    }
}

// 读取RSSI信号强度
peripheral.readRSSI { peripheral, RSSI, error in
    if error == nil {
        print("📶 信号强度: \(RSSI)")
    }
}
```

### 数据转换工具
```swift
// 字符串转十六进制数据
let hexString = "48656C6C6F" // "Hello"
let data = hexString.blueheadecimal()

// 数据转十六进制字符串
let data = "Hello".data(using: .utf8)!
let hexString = data.bluehexString() // "48656C6C6F"

// 字节数组操作
let bytes = data.toByteArray()
let newData = Data.fromByteArray(bytes)
```

## 📋 错误处理

### 错误状态定义
```swift
switch errorState {
case .bluetoothErrorStateNoReadly:
    print("❌ 蓝牙未开启")
case .bluetoothErrorStateNoDevice:
    print("🔍 未找到设备")
case .bluetoothErrorStateConnectError:
    print("🔗 连接失败")
case .bluetoothErrorStateDisconnect:
    print("🔌 设备断开")
case .bluetoothErrorStateWriteError:
    print("✍️ 写入失败")
case .bluetoothErrorStateReadError:
    print("📖 读取失败")
case .bluetoothErrorStateNotifyError:
    print("📡 通知订阅失败")
default:
    print("❓ 未知错误")
}
```

## 🔧 配置选项

### 管理器配置
| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `scanTimeOut` | Int | NSIntegerMax | 扫描超时时间 |
| `connectTimeOut` | Int | 5 | 连接超时时间 |
| `autoConnectAfterDisconnect` | Bool | true | 断开后自动重连 |
| `managerQueue` | DispatchQueue | nil | 管理器运行队列 |

### 扫描配置
| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `scanOptions` | [String: Any] | 允许重复 | 扫描选项 |
| `scanServiceArray` | [CBUUID] | nil | 指定服务UUID |
| `scanTimeOut` | Int | NSIntegerMax | 扫描超时 |

## 📱 系统要求

- **iOS**: 15.0+
- **Swift**: 5.0+
- **Xcode**: 12.0+
- **部署目标**: iOS 15.0+

## 🔒 权限配置

在 `Info.plist` 中添加蓝牙权限描述：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>此应用需要蓝牙权限来连接设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>此应用需要蓝牙权限来连接设备</string>
```

## 📄 许可证

TFYSwiftEasyBlueTooth 使用 [MIT 许可证](LICENSE)。

## 👨‍💻 作者

**田风有** - [GitHub](https://github.com/tianfengyou)

## 🤝 贡献

我们欢迎所有形式的贡献！

1. Fork 这个项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

## 📞 支持

如果你遇到任何问题或有建议，请：

- 📧 发送邮件到: [your-email@example.com]
- 🐛 提交 Issue: [GitHub Issues](https://github.com/your-repo/TFYSwiftEasyBlueTooth/issues)
- 💬 加入讨论: [GitHub Discussions](https://github.com/your-repo/TFYSwiftEasyBlueTooth/discussions)

## ⭐ 如果这个项目对你有帮助，请给我们一个星标！

---

<div align="center">
  <p>Made with ❤️ by 田风有</p>
  <p>如果这个项目对你有帮助，请给我们一个 ⭐</p>
</div>
