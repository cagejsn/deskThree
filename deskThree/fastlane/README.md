fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools/fastlane.zip">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>
# Available Actions
## iOS
### ios increment
```
fastlane ios increment
```

### ios certs
```
fastlane ios certs
```
Updating provisioning profiles.
### ios bump_patch
```
fastlane ios bump_patch
```
Increment the app version patch
### ios bump_minor
```
fastlane ios bump_minor
```
Increment the app version minor
### ios bump_major
```
fastlane ios bump_major
```
Increment the app version major
### ios build_app
```
fastlane ios build_app
```
Fetching provisioning profiles and building the app
### ios bumpAndTag
```
fastlane ios bumpAndTag
```

### ios beta
```
fastlane ios beta
```
Build and upload a new build to Apple TestFlight
### ios release
```
fastlane ios release
```
Build and upload the app to the App Store

----

## Android
### android alpha
```
fastlane android alpha
```
Submit a new Alpha Build to Google Play Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
