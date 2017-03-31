
# Desk

## Installation


1. `git clone --recursive [this repo]` into your desired directory (--recursive download all git submodules with project)
2. Download the MyScript iOS developer SDK from their [site](https://developer.myscript.com/) (must have an account) and move the unzipped file `MyScript_ATK-ios-2.2` into root directory (`deskThree/deskThree`)
3. Run `carthage update` in the root directory (with carthage installed)


## FAQ

*How do I install Carthage?*

`brew update && brew install carthage`

*Mixpanel is not found when building the project*

Mixpanel is a git submodule and is not installed. Install it in your current project by running `git submodule update --init --recursive`

*MyScript cannot be used or you receive a MyScript certificate related error*

Ensure your BundleID matches: `desk.deskThreeUT1`


*A library is not detected by Xcode*

This could be caused by a couple things:
1. Have you installed github submodules? Run `git submodule update --init --recursive`
2. Are the Carthage packages added to deskThree.xcodeproj->General Tab->Embedded Binaries? If you do not see and or see some missing, in Xcode, click on deskThree.xcodeproj->General->Embedded Binaries. Then, in finder, go to `deskThree/deskThree/Carthage/Build/iOS/` and drag all of the [libraries].framework (e.g. Zip.framework) into the Embedded Binaries
