# Arch Linux

The normal Apple iOS build/sign toolchain requires Xcode and the iOS SDK on macOS. Arch can be used for the sideloading stage.

For SideStore on Linux, use the official iloader:
https://github.com/nab138/iloader

SideStore installation:
https://docs.sidestore.io/docs/installation/install

Once you have the signed IPA, copy it to Arch and install it with SideStore/iloader.

The iPhone app declares `audio` and `bluetooth-central` background modes. Apple documents these as background execution modes. Background microphone use still requires user permission and iOS privacy indicators.
