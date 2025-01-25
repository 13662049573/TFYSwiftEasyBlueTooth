# TFYSwiftEasyBlueTooth

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)
[![CocoaPods](https://img.shields.io/cocoapods/v/TFYSwiftEasyBlueToothKit.svg)](https://cocoapods.org/pods/TFYSwiftEasyBlueToothKit)

TFYSwiftEasyBlueTooth 是一个基于 CoreBluetooth 的 Swift 蓝牙框架，提供了简单易用的 API 来实现 BLE 设备的扫描、连接和通信功能。

## 特性

- 链式调用风格，简洁优雅
- 支持自动重连机制
- 支持多设备同时连接
- 支持后台模式
- 支持读写数据、通知订阅
- 支持设备状态监听
- 支持 RSSI 信号强度读取
- 完整的错误处理机制
- 支持 iOS 13.0+
- Swift 5.0+ 

## 安装

### CocoaPods

```ruby
pod 'TFYSwiftEasyBlueToothKit'
```

## 使用示例

### 初始化

```swift
let manager = TFYSwIFTEasyBlueToothManager.shareInstance
```

### 扫描设备

```swift
// 扫描指定名称的设备
manager.scanDeviceWithName(name: "Device_Name") { peripheral, error in
    if let peripheral = peripheral {
        print("Found device: \(peripheral.name ?? "")")
    }
}

// 使用自定义规则扫描
manager.scanDeviceWithRule({ peripheral in
    return peripheral.name?.contains("Device") ?? false
}) { peripheral, error in
    if let peripheral = peripheral {
        print("Found device: \(peripheral.name ?? "")")
    }
}
```

### 连接设备

```swift
// 连接设备
manager.connectDeviceWithPeripheral(peripheral: peripheral) { peripheral, error in
    if error == nil {
        print("Connected to: \(peripheral?.name ?? "")")
    }
}
```

### 读写数据

```swift
// 写入数据
manager.writeDataWithPeripheral(
    peripheral: peripheral,
    serviceUUID: "SERVICE_UUID",
    writeUUID: "CHARACTERISTIC_UUID",
    data: data
) { data, error in
    if error == nil {
        print("Data written successfully")
    }
}

// 读取数据
manager.readValueWithPeripheral(
    peripheral: peripheral,
    serviceUUID: "SERVICE_UUID",
    readUUID: "CHARACTERISTIC_UUID"
) { data, error in
    if let data = data as? Data {
        print("Read data: \(data.bluehexString())")
    }
}
```

### 监听通知

```swift
manager.notifyDataWithPeripheral(
    peripheral: peripheral,
    serviceUUID: "SERVICE_UUID",
    notifyUUID: "CHARACTERISTIC_UUID",
    notifyValue: true
) { data, error in
    if let data = data as? Data {
        print("Received notification: \(data.bluehexString())")
    }
}
```

## 状态监听

```swift
manager.bluetoothStateChanged = { peripheral, state in
    switch state {
    case .bluetoothStateSystemReadly:
        print("Bluetooth is ready")
    case .bluetoothStateDeviceConnected:
        print("Device connected")
    case .bluetoothStateWriteDataSuccess:
        print("Data written successfully")
    // ... 其他状态
    }
}
```

## 要求

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## 许可证

TFYSwiftEasyBlueTooth 使用 MIT 许可证。详情见 LICENSE 文件。

## 作者

田风有 

## 贡献

欢迎提交 issue 和 pull request。
