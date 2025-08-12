source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'

target 'TFYSwiftEasyBlueTooth' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'TFYProgressSwiftHUD'

  # Pods for TFYSwiftEasyBlueTooth

  target 'TFYSwiftEasyBlueToothTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TFYSwiftEasyBlueToothUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
