platform :ios, '9.0'

# Ignore all warning from Pods
inhibit_all_warnings!

target "Assay Analysis" do

  use_frameworks!

# pod 'JGProgressHUD', :inhibit_warnings => true
# pod 'Alamofire', '~> 4.0', :inhibit_warnings => true
# pod 'SwiftyDropbox', '~> 4.2', :inhibit_warnings => true
# pod 'OpenCV2', :inhibit_warnings => true
# pod 'TextFieldEffects', :inhibit_warnings => true
#pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
