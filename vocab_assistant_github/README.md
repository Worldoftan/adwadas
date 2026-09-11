Vocab Assistant — M5StickC Plus 2 + iPhone

Included:
- M5StickC Plus 2 PlatformIO firmware
- iPhone Swift source
- Info.plist with microphone/speech permissions and background modes
- Arch Linux / IPA workflow

Flow:
iPhone microphone -> Apple Speech recognition -> exact vocabulary match -> BLE -> M5Stick display.

The project contains the 11 vocabulary words:
optimistic, sensitive, caring, patient, easy-going, sociable, honest, reliable, stubborn, selfish, shy.

Important: I am not providing a pre-signed IPA. iOS apps must be signed for installation. The standard Apple build/sign process uses Xcode on macOS; after signing, the IPA can be sideloaded from Arch using SideStore/iloader.
