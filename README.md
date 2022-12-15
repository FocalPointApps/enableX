# enx_flutter_plugin


This Enx Flutter plugin is a wrapper for [EnableX Video SDK](https://developer.enablex.io/api/)which allows you to implement real-time communication (RTC) channels such as audio, video and text chat services in their applications. It provides a simple set of APIs that can be invoked in the user application to integrate RTC services.



## Usage

To use this plugin, add `enx_flutter_plugin` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started

* Refer to the [EnableX GitHub Repository](https://github.com/EnableX/One-to-One-Video-Calling-Open-Source-flutter-Application) for a One-to-One Video Calling Sample Application using enx_flutter_plugin. 



## Device Permissions

You require a physical Device to run the application as a simulator/emulator does not support playing video or publishing a local Stream.

EnableX Video SDK requires camera and microphone permission to start video call. Learn how to add Device Permissions in Android and iOS platforms as shown below:

### Android

Open the *AndroidManifest.xml* file and add the required device permissions.

```xml
..
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
..
```

### iOS

Open the *info.plist* file and add:

- Privacy - Microphone Usage Description and add a note in the Value column.
- Privacy - Camera Usage Description and add a note in the Value column.

Your application can still run the voice call when it is switched to the background if the background mode is enabled. Select the app target in Xcode, click the **Capabilities** tab, enable **Background Modes**, and check **Audio, AirPlay, and Picture in Picture**.


### Black Screen Issue in iOS

EnableX Video SDK uses `PlatformView` so you need to set `io.flutter.embedded_views_preview` to `YES` in your *info.plist* to avoid the black screen issue.


### Android 
Please add below line

Goto android =>build.gradle

within buildscript
jcenter()


within allproject section


jcenter()
flatDir {
dirs 'src/main/libs'
dirs project(':enx_flutter_plugin').file('libs')
}

### iOS
Note  need to go to your
pod library -> Target -> enx_flutter_plugin -> scroll all the way done and go to VALID_ARCHS -> and remove armv7.
Clean your project (prefer to clean drive data) and rebuild.







