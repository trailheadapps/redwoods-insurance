# TrailInsurance Salesforce Mobile SDK for iOS Sample Application

TrailInsurance is a fictional end-user mobile application for iOS built using Swift and the Mobile SDK for iOS. The application shows a rich user experience for an end-user on iOS while demonstrating key features of the SDK version 7.0.

## Table of Contents

1. [Prerequisites](#pre)
1. [Source Control Setup](#download)
1. [Salesforce Metadata Setup](#sfMetadata)
1. [Xcode Setup](#xcode)
1. [Additional Resources](#resources)

## Prerequisites <a name="pre"></a>

In order to experience, and experiment with this sample app you'll need:

1. A working installation of Git.
2. An Apple Computer with xCode 10.1 (or possibly higher) installed.
3. If you want to install the sample app on a physical iOS device, you'll need an Apple Developer Account.
4. A Salesforce Scratch Org. (More info on that later)

## Source Control Setup <a name="download"></a>

This project makes use of [git submodules.](https://git-scm.com/book/en/v2/Git-Tools-Submodules), in addition to Xcode build dependencies to incorporate the SDK. This means you must not only clone this repository, but the submodule repositories as well. If you have not yet cloned this repository, this clone command will clone not only this repo, but the submodules as well.

```console
git clone --recurse-submodules git@github.com:trailheadapps/TrailInsurance.git
```

If you've already cloned this repository, please initialize the submodules using this command

```console
git submodule update --init --recursive
```

## Salesforce Metadata Setup <a name="sfMetadata"></a>

The 'Salesforce Org Setup' folder in this repository contains the neccesary metadata to setup a Salesforce Scratch Org for use with this mobile app. To quickly establish your scratch org with this metadata:

> **IMPORTANT**: Because of a current issue in pre-release, make sure your project path doesn't include any of the following folder names: **lwc**, **aura**, **wave**. For example, DO NOT clone this repository in a folder called **/Projects/lwc**.

1. Set up your environment. Follow the steps in the [Quick Start: Salesforce DX](https://trailhead.salesforce.com/en/content/learn/projects/quick-start-salesforce-dx) Trailhead Project. The steps include:

- Sign up for a developer org and enable Dev Hub
- Install the pre-release version of the Salesforce CLI
- Install Visual Studio Code
- Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

2. If you haven't already done so, authenticate with your Spring '19 hub org and provide it with an alias (spring19hub):

```
sfdx force:auth:web:login -d -a spring19hub
```

3. cd to Salesforce Org Setup folder in a command line

4. Create a scratch org and provide it with an alias (trailInsurance):

```
sfdx force:org:create -s -f config/project-scratch-def.json -a trailInsurance
```

5. Push the app to your scratch org:

```
sfdx force:source:push
```

6. Open the scratch org:

```
sfdx force:org:open
```

> Note: The source ships with a valid connected app consumer key. However, if you'd like to use your own, ensure it has the following oAuth scopes:
>
> - Access your basic information (id, profile, email, address, phone)
> - Access and manage your data (api)
>   - Provide access to your data via the Web (web)
>   - Access and manage your Chatter data (chatter_api)
> - Perform requests on your behalf at any time (refresh_token, offline_access)
>
> Once you have established your connected app, copy the consumer key into the TrailIsurance/bootconfig.plist file using Xcode.

## Xcode Setup <a name="xcode"></a>

To load the project in XCode, open the TrailInsurance.xcodeproj file.

This project should build and run on the simulator 'out of the box' if the submodules have been properly initialized. However, if you would like to run this on a physical iOS device, you'll need to specify your Team name in the project's settings.

## Additional Resources <a name="resources"></a>

For more information on the Salesforce Mobile SDK for iOS check out these resources:

1. [Salesforce Mobile SDK Basics](https://trailhead.salesforce.com/en/content/learn/modules/mobile_sdk_introduction)
2. [Native iOS Trailhead Module](https://trailhead.salesforce.com/en/content/learn/modules/mobile_sdk_native_ios)
3. [Get Started with iOS App Development](https://trailhead.salesforce.com/en/content/learn/trails/start-ios-appdev)
4. [Swift Essentials](https://trailhead.salesforce.com/en/content/learn/modules/swift-essentials)
