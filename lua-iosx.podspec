Pod::Spec.new do |s|
    s.name         = "lua-iosx"
    s.version      = "5.4.6.0"
    s.summary      = "LUA XCFramework for macOS and iOS, including both arm64 and x86_64 builds for macOS, Mac Catalyst and Simulator."
    s.homepage     = "https://github.com/apotocki/lua-iosx"
    s.license      = "MIT"
    s.author       = { "Alexander Pototskiy" => "alex.a.potocki@gmail.com" }
    s.social_media_url = "https://www.linkedin.com/in/alexander-pototskiy"
    s.ios.deployment_target = "13.4"
    s.osx.deployment_target = "11.0"
    s.osx.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.ios.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.static_framework = true
    s.prepare_command = "sh scripts/build.sh"
    s.source       = { :git => "https://github.com/apotocki/lua-iosx.git", :tag => "#{s.version}", :submodules => "true" }
    s.source_files = "frameworks/Headers/*.{h}"
    s.header_mappings_dir = "frameworks/Headers"
    s.public_header_files = "frameworks/Headers/*.{h,hpp}"
    s.vendored_frameworks = "frameworks/lua.xcframework"
end
