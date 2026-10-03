# lua-iosx

## Overview

`lua-iosx` is a build and distribution project that produces the **Lua static library packaged as an XCFramework** for Apple platforms.

This repository **does not contain Lua source code**. The source code is fetched from the official Lua website:

[https://www.lua.org/ftp/](https://www.lua.org/ftp/)

using the corresponding release archive (for example `lua-5.5.1.tar.gz`).

---

## Supported Lua Versions

Supported Lua 5.5.x upstream versions: [5.5.1](https://github.com/apotocki/lua-iosx/tree/5.5.1)

Supported Lua 5.4.x upstream versions: [5.4.6](https://github.com/apotocki/lua-iosx/tree/5.4.6), [5.4.5](https://github.com/apotocki/lua-iosx/tree/5.4.5), [5.4.4](https://github.com/apotocki/lua-iosx/tree/5.4.4)


Use the appropriate **Git tag or branch** to select the desired Lua version.

### Versioning Policy

Branches correspond to official Lua versions.
Tags use the format `<lua_version>.<package_patch>` (e.g. `5.5.1.1`), where `package_patch` is this repository’s packaging/build revision for that upstream version.

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
# clone the repository
git clone https://github.com/apotocki/lua-iosx

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
pod 'lua-iosx', '~> 5.5.1'
# or pin to a specific tag
# pod 'lua-iosx', :git => 'https://github.com/apotocki/lua-iosx', :tag => '5.5.1.1'
```

Then install the dependency:

```bash
pod install --verbose
```

---

## Contributions

Build outputs in this repository are generated from internal templates, so pull requests that directly modify generated files cannot be accepted. Please use **GitHub Issues** to report build problems or discuss changes, and include the Lua version, target platform(s), and build command.

---

## License

This repository contains build scripts for Lua.

Precompiled artifacts published via GitHub Releases are subject to the upstream Lua license terms: Lua is distributed under the MIT license.

---

## As an advertisement…

Please check out my iOS application on the App Store:

<table align="center" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>
      <a href="https://apps.apple.com/us/app/potohex/id1620963302">
        <img src="https://is4-ssl.mzstatic.com/image/thumb/Purple112/v4/78/d6/f8/78d6f802-78f6-267a-8018-751111f52c10/AppIcon-0-1x_U007emarketing-0-10-0-85-220.png/460x0w.webp" width="70" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/us/app/potohex/id1620963302">PotoHEX</a><br />
      HEX File Viewer &amp; Editor
    </td>
  </tr>
</table>

PotoHEX is designed for viewing and editing files at the byte or character level, calculating hashes, encoding/decoding data, and compressing/decompressing selected byte ranges.

If you find this project useful, you can support my open-source work by trying the [App](https://apps.apple.com/us/app/potohex/id1620963302).

---

Feedback is welcome!
