
Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftEasyBlueToothKit"

  spec.version      = "1.0.6"

  spec.summary      = "swift5 蓝牙封装 ， 版本最低系统支持ios15，swift5"

  
  spec.description  = <<-DESC
  swift5 蓝牙封装 ， 版本最低系统支持ios14，swift5
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftEasyBlueTooth"
  
  spec.license      = "MIT"
  
  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.platform     = :ios, "15.0"

  spec.swift_version = '5.0'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftEasyBlueTooth.git", :tag => spec.version }

  spec.source_files  = "TFYSwiftEasyBlueTooth/TFYSwiftEasyBlueToothKit/*.{swift}"
  
  spec.requires_arc = true

end
