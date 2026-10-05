Pod::Spec.new do |s|
    s.name         = "lua-iosx"
    s.version      = "5.5.1.2"
    s.summary      = "Lua XCFramework for macOS, iOS, watchOS, tvOS, and visionOS, including Mac Catalyst and simulators."
    s.homepage     = "https://github.com/apotocki/lua-iosx"
    s.license      = "MIT"
    s.author       = { "Alexander Pototskiy" => "alex.a.potocki@gmail.com" }
    s.social_media_url = "https://www.linkedin.com/in/alexander-pototskiy"
    s.ios.deployment_target = "15.0"
    s.osx.deployment_target = "12.0"
    s.tvos.deployment_target = "15.0"
    s.watchos.deployment_target = "11.0"
    s.visionos.deployment_target = "1.0"
    s.ios.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.osx.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.tvos.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.watchos.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.visionos.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.ios.user_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.osx.user_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.tvos.user_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.watchos.user_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.visionos.user_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.static_framework = true
    s.prepare_command = "sh scripts/build.sh"
    s.source       = { :git => "https://github.com/apotocki/lua-iosx.git", :tag => "#{s.version}" }

    s.header_mappings_dir = "frameworks/Headers"
    s.public_header_files = "frameworks/Headers/**/*.{h,hpp}"
    s.source_files = "frameworks/Headers/**/*.{h,hpp}"
    s.vendored_frameworks = "frameworks/lua.xcframework"
end
