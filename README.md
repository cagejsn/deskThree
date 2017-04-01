
# Desk

## Installation


1. `git clone --recursive [this repo]` into your desired directory (--recursive download all git submodules with project)
2. Download the MyScript iOS developer SDK from their [site](https://developer.myscript.com/) (must have an account) and move the unzipped file `MyScript_ATK-ios-2.2` into `deskThree/deskThree`
3. cd to deskThree/
4. run `carthage update`. If you do not already have carthage install it by running `homebrew install carthage`.


## FAQ


*Mixpanel is not found when building the project*

Mixpanel is a git submodule and is not installed. Install it in your current project by running `git submodule update --init --recursive`

*MyScript cannot be used or you receive a MyScript certificate related error*

Ensure your BundleID matches: `desk.deskThreeUT1`

