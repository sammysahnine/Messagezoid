# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'messagezoid' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for messagezoid

pod 'Firebase/Core'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase'
pod 'Firebase/Storage'
pod 'MessageKit'
pod 'Firebase/Analytics'
pod 'SDWebImage'
pod 'CryptoSwift'
pod 'SwiftyRSA'

post_install do |installer| 
  installer.pods_project.build_configurations.each do |config|
    if config.name == 'Release'
      config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
    end    
  end
end

end
