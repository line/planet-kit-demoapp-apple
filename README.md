# LINE Planet Call for iOS and macOS
 
LINE Planet Call is a demo app for LINE Planet, a cloud-based real-time communications platform as a service (CPaaS).
 
LINE Planet Call showcases the key features of LINE Planet, including 1-to-1 and group call functionalities. It can help you understand how to integrate LINE Planet into your services and enhance productivity when you implement your own app.
 
## Features
 
LINE Planet Call provides the following features:
  
- **1-to-1 call**
  - Make a 1-to-1 audio/video call
  - Cancel a 1-to-1 audio/video call
  - End a 1-to-1 audio/video call
- **Group call**
  - Pre-check the camera and mic before a group call
  - Create a group video call room
  - Join a group video call room
  - Leave a group video call room
- **Basic features**
  - Mute/unmute the mic
  - Enable/disable the camera
  - Switch between the front and back cameras (iOS)
  - Select the camera source (macOS)
  - Provide talker information
  - Display the participant's name
 
## Prerequisites
 
Before getting started with LINE Planet Call, do the following:
  
- Make sure that your system meets the system requirements. ([iOS](https://docs.lineplanet.me/overview/specification/planetkit-system-requirements#ios), [macOS](https://docs.lineplanet.me/overview/specification/planetkit-system-requirements#macos)).
- Install Xcode 15 or higher.
 

## How to build project

### 1. Download source code

Clone this repository, or download this repository and unzip the files.

### 2. Open the project in Xcode

Open the Xcode project **planet-kit-demoapp-apple.xcodeproj** with Xcode.


### 3. Build the app in Xcode

1. Set the build scheme to **planet-kit-demoapp-apple**.

2. Configure the run destination to a iOS device or a Mac device.

3. Build the project.


## Launch LINE Planet Call

> Note: The microphone and camera does not work on the iOS simulator. If possible, use a physical device to run the iOS app.

To run the app on the iOS simulator or a physical device in Xcode:

1. (iOS) Connect your iOS device to Xcode or prepare an iOS simulator.

2. Set the build scheme to **planet-kit-demoapp-apple**.

3. Configure the run destination to the desired device.

4. Run the project.

The app will build and run on the selected device.

## Limitations

In LINE Planet Call, each call is limited to a maximum duration of five minutes. After five minutes, the call will automatically end with the disconnect reason `.maxCallTimeExceeded`.

## Issues and inquiries

Please file any issues or inquiries you have to our representative or [dl\_planet\_help@linecorp.com](mailto:dl_planet_help@linecorp.com). 
Your opinions are always welcome.

## FAQ

You can find answers to our frequently asked questions in the [FAQ](https://docs.lineplanet.me/help/faq) section.