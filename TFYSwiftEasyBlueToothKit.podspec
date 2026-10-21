
Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftEasyBlueToothKit"

  spec.version      = "1.2.1"

  spec.summary      = "swift5 蓝牙封装 ， 版本最低系统支持 iOS 16，swift5"

  
  spec.description  = <<-DESC
  基于 CoreBluetooth 的 Swift 蓝牙封装：扫描、连接、读写特征值、通知订阅、断线自动重连与超时控制，最低支持 iOS 16。
  A Swift wrapper around CoreBluetooth for scanning, connecting, reading/writing characteristics, notifications, auto-reconnect and timeouts (iOS 16+).
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftEasyBlueTooth"
  
  spec.license      = "MIT"
  
  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.platform     = :ios, "16.0"

  spec.swift_version = '5.0'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftEasyBlueTooth.git", :tag => spec.version }

  spec.source_files  = "TFYSwiftEasyBlueTooth/TFYSwiftEasyBlueToothKit/*.{swift}"
  
  spec.requires_arc = true

end
