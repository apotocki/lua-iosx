
## Lua 5.5.1 for Apple Platforms

> **Lua is now available through [otok](https://otok-dev.github.io/)**, which builds it from source on your machine for the platforms of your app: see [Using otok](https://github.com/apotocki/lua-iosx/blob/main/README.md#using-otok-recommended) in the `main` branch. otok provides the current versions of Lua; this branch keeps the build scripts of Lua 5.5.1.

This branch contains build scripts for producing the Lua static library packaged as an XCFramework for Apple platforms, based on the **upstream Lua 5.5.1 release**.

The Lua source code is fetched from the official Lua website:

[https://www.lua.org/ftp/](https://www.lua.org/ftp/)

using the release archive `lua-5.5.1.tar.gz`.

---

## Supported Platforms

Lua is built for:

* iOS / iOS Simulator
* watchOS / watchOS Simulator
* tvOS / tvOS Simulator
* visionOS / visionOS Simulator
* macOS
* Mac Catalyst

Both Intel (`x86_64`) and Apple Silicon (`arm64`) architectures are supported where applicable.

---

## Prerequisites

1. **Install Xcode**
   Xcode is required because `xcodebuild` is used to create XCFrameworks.

2. **Verify Xcode Developer Directory**
   The `xcode-select -p` command must point to the Xcode developer directory (for example `/Applications/Xcode.app/Contents/Developer`).
   If it points to the Command Line Tools directory, reset it using one of the following commands:

   ```bash
   sudo xcode-select --reset
   ```
   or

   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```

3. **Install Required SDKs**
   To build for tvOS, watchOS, visionOS, and their simulators, make sure the corresponding SDKs are installed in:

   ```
   /Applications/Xcode.app/Contents/Developer/Platforms
   ```

---

## Build Manually

```bash
# clone the repository at the required Lua version
git clone -b 5.5.1 https://github.com/apotocki/lua-iosx

# build libraries
cd lua-iosx
scripts/build.sh

# build artifacts will be located in the `frameworks` directory
```

---

## Selecting Platforms and Architectures

Running `build.sh` without arguments builds the XCFramework for iOS, macOS, and Catalyst. If the corresponding SDKs are installed, it also builds for watchOS, tvOS, visionOS, and all available simulators.

The simulator architecture (`arm64` or `x86_64`) is selected automatically based on the host system.

To build a specific set of platforms and architectures, use the `-p` option. For example:

```bash
scripts/build.sh -p=ios,iossim-x86_64
# builds the XCFramework only for iOS devices and iOS Simulator (x86_64)
```

Supported values for the `-p` option:

```text
macosx,macosx-arm64,macosx-x86_64,macosx-both,
ios,iossim,iossim-arm64,iossim-x86_64,iossim-both,
catalyst,catalyst-arm64,catalyst-x86_64,catalyst-both,
xros,xrossim,xrossim-arm64,xrossim-x86_64,xrossim-both,
tvos,tvossim,tvossim-arm64,tvossim-x86_64,tvossim-both,
watchos,watchossim,watchossim-arm64,watchossim-x86_64,watchossim-both
```

The `-both` suffix builds for both `arm64` and `x86_64` architectures. Platform names without an architecture suffix (for example `macosx`, `iossim`) build only for the current host architecture.

---

## Rebuild Option

To force a clean rebuild without reusing artifacts from previous builds, use the `--rebuild` option:

```bash
scripts/build.sh -p=ios,iossim-x86_64 --rebuild
```

---

## Build Using CocoaPods

Add the following to your `Podfile`:

```ruby
use_frameworks!
pod 'lua-iosx', '~> 5.5.1', :source => 'https://github.com/apotocki/cocoapods-specs.git'
# or pin to a specific tag
# tags are formatted as <lua_version>.<package_patch>, e.g. 5.5.1.4
# pod 'lua-iosx', :git => 'https://github.com/apotocki/lua-iosx', :tag => '5.5.1.4'
```

New versions are published to the [apotocki/cocoapods-specs](https://github.com/apotocki/cocoapods-specs) spec repo, because CocoaPods Trunk becomes read-only on December 2, 2026; `:source` makes CocoaPods take the pod from there.

Then install the dependency:

```bash
pod install --verbose
```

---

## Support

Support is provided via **GitHub Issues**.

When reporting a problem, please include:

* Lua version: 5.5.1
* Target platform(s)
* Build command and environment details

---

## License

This repository contains build scripts for Lua.

Precompiled artifacts published via GitHub Releases are subject to the upstream Lua license terms: Lua is distributed under the MIT license.

---

## As an advertisement…

Please check out my applications:

<table align="center" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>
      <a href="https://apps.apple.com/us/app/potohex/id1620963302">
        <img src="https://is4-ssl.mzstatic.com/image/thumb/Purple112/v4/78/d6/f8/78d6f802-78f6-267a-8018-751111f52c10/AppIcon-0-1x_U007emarketing-0-10-0-85-220.png/460x0w.webp" width="70" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/us/app/potohex/id1620963302">PotoHEX</a><br />
      HEX File Viewer &amp; Editor<br />
      iOS &middot; App Store
    </td>
  </tr>
  <tr>
    <td>
      <a href="https://play.google.com/store/apps/details?id=com.potohex">
        <img src="https://play-lh.googleusercontent.com/we6L4zSvYH6K8K19sN7A1aS2Mlkp2kxWN-QSna0vHJEioxFB-dfMGUBUG2m6Bg-VqLaX50_PcgdyJd45A4z8ew=s140" width="70" />
      </a>
    </td>
    <td>
      <a href="https://play.google.com/store/apps/details?id=com.potohex">Otok Hex</a><br />
      HEX File Viewer<br />
      Android &middot; Google Play
    </td>
  </tr>
</table>

PotoHEX is designed for viewing and editing files at the byte or character level, calculating hashes, encoding/decoding data, and compressing/decompressing selected byte ranges.

Otok Hex lets you inspect any file's bytes in hex and text on Android, with Wi-Fi access to the files from your PC.

If you find this project useful, you can support my open-source work by trying [PotoHEX](https://apps.apple.com/us/app/potohex/id1620963302) on the App Store or [Otok Hex](https://play.google.com/store/apps/details?id=com.potohex) on Google Play.

---

Feedback is welcome!
