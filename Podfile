# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PinkBookTest' do
  # Comment the next line if you don't want to use dynamic frameworks
  pod 'YPImagePicker'
  use_frameworks!
  
  # Pods for PinkBookTest
  # 横划tab
  pod 'XLPagerTabStrip', '~> 9.0'
  # 瀑布流
  pod 'CHTCollectionViewWaterfallLayout'
  # 加载提示
  pod 'MBProgressHUD', '~> 1.2.0'
  # 图片预览
  pod 'SKPhotoBrowser'
  #pod 'KMPlaceholderTextView', '~> 1.4.0'
  pod 'AMapLocation'
  pod 'AMapSearch'
 
  
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
  installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
           end
      end
    end
end
