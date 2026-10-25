

<img width="128" height="128" alt="logo" src="https://github.com/user-attachments/assets/e8429fed-37be-427c-b7ab-ae0ad7537983" />


# NotchPrompter for macOS

Super simple-to-use, always-on-top floating text prompter for macOS.
Perfect for quick videos or keeping important text visible while you work.

<a href="https://apps.apple.com/pl/app/notchprompter/id6760967658?mt=12">
  <img src="download.svg" alt="Download on the Mac App Store" width="250">
</a>

## Features
- Always on top
- **Hide from screen recordings** (best effort — not a guarantee on every capture tool)
- Voice activation
- Minimalist design
- Quick options
- Customizable speed, size, font style
- Multi-monitor support
- [Multi-language support](https://simplelocalize.io/suggestions/?id=f1f11f9305dc44a2872b6a154dea6edc)
- Custom position

## Screenshot

<img width="1465" height="780" alt="screen-frame-no-text" src="https://github.com/user-attachments/assets/8fcca82b-2628-4fcf-8b64-28e19474703b" />

## Translations
Translations are made via DeepL, so they might be incorrect in some places, but feel free to [suggest better translations!](https://simplelocalize.io/suggestions/?id=f1f11f9305dc44a2872b6a154dea6edc).


## Build from source (macOS)

NotchPrompter is a native macOS app. It requires **macOS 14 or later** and
Apple's **Xcode Command Line Tools**. It cannot run on Linux.

### Prerequisites

1. Install the Command Line Tools (one-time):

   ```sh
   xcode-select --install
   ```

2. Confirm the Swift toolchain is available:

   ```sh
   swift --version
   ```

### Build and run

The easiest way is to double-click **`Build NotchPrompter.command`** in Finder.
It compiles a release build with SwiftPM, assembles `build/NotchPrompter.app`,
ad-hoc codesigns it locally, zips it, reveals it in Finder, and then opens the
app. The first time, macOS may ask you to confirm opening the file.

Or run it from a terminal:

```sh
./scripts/build-mac.sh
open "build/NotchPrompter.app"
```

The finished bundle is `build/NotchPrompter.app`, and `build/NotchPrompter.zip`
contains the same app for sharing.

### What the build produces

- **Native architecture only** (`arm64` or `x86_64` for the machine it is
  built on — not a universal binary).
- **Unsigned / not notarized**: the bundle is ad-hoc codesigned so it runs
  locally, but it is not signed with a Developer ID and is not notarized.
  If macOS blocks the app on first launch, right-click it in Finder and
  choose **Open**, then confirm.
- The `Info.plist` sets `LSUIElement` (menu bar app), `LSMinimumSystemVersion`
  `14.0`, the microphone usage description used by voice activation, and the
  local bundle id `local.notchprompter.app`.



## Star History

[![Star History Chart](https://star-history.dera.page/svg?repos=jpomykala/NotchPrompter&type=date&legend=top-left)](https://star-history.dera.page/#jpomykala/NotchPrompter&type=date&legend=top-left)
