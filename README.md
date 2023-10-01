## LUA for iOS and macOS (Intel & Apple Silicon M1) & Catalyst - arm64 / x86_64

Supported version: 5.4.6

This repo provides a universal script for building static LUA library for use in iOS and macOS applications.
The latest supported LUA version is taken from: https://www.lua.org/ftp/lua-5.4.6.tar.gz

## Prerequisites
  1) Xcode must be installed because xcodebuild is used to create xcframeworks
  2) ```xcode-select -p``` must point to Xcode app developer directory (by default e.g. /Applications/Xcode.app/Contents/Developer). If it points to CommandLineTools directory you should execute:
  ```sudo xcode-select --reset``` or ```sudo xcode-select -s /Applications/Xcode.app/Contents/Developer```
  
## How to build?
 - Manually
```
    # clone the repo
    git clone -b 5.4.6 https://github.com/apotocki/lua-iosx
    
    # build libraries
    cd lua-iosx
    scripts/build.sh

    # have fun, the result artifacts will be located in 'frameworks' folder.
```    
 - Use cocoapods. Add the following lines into your project's Podfile:
```
    use_frameworks!
    pod 'lua-iosx', '~> 5.4.6'
    # or optionally more precisely
    # pod 'lua-iosx', :git => 'https://github.com/apotocki/lua-iosx', :tag => '5.4.6.0'
```    
install new dependency:
```
   pod install --verbose
```

## As an advertisement…
The LUA library built by this project is used in my iOS application on the App Store:

[<table align="center" border=0 cellspacing=0 cellpadding=0><tr><td><img src="https://is4-ssl.mzstatic.com/image/thumb/Purple112/v4/78/d6/f8/78d6f802-78f6-267a-8018-751111f52c10/AppIcon-0-1x_U007emarketing-0-10-0-85-220.png/460x0w.webp" width="70"/></td><td><a href="https://apps.apple.com/us/app/potohex/id1620963302">PotoHEX</a><br>HEX File Viewer & Editor</td><tr></table>]()

This app is designed for viewing and editing files at the byte or character level.
  
You can support my open-source development by trying the [App](https://apps.apple.com/us/app/potohex/id1620963302).

Feedback is welcome!
