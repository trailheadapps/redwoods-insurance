# Redwoods Car Insurance - A Salesforce Mobile SDK for iOS Sample Application

[![Github Workflow](<https://github.com/trailheadapps/redwoods-insurance/workflows/Salesforce%20DX%20(scratch%20org)/badge.svg?branch=master>)](https://github.com/trailheadapps/redwoods-insurance/actions?query=workflow%3A%22Salesforce+DX+%28scratch+org%29%22) [![codecov](https://codecov.io/gh/trailheadapps/redwoods-insurance/branch/master/graph/badge.svg)](https://codecov.io/gh/trailheadapps/redwoods-insurance)

Redwoods Car Insurance is a fictional end-user mobile application for iOS built using Swift and the Mobile SDK for iOS. The application shows a rich user experience for an end-user on iOS while demonstrating key features of the SDK version 7.0.

## Table of Contents

1. [Prerequisites](#pre)
1. [Source Control Setup](#download)
1. [Salesforce Metadata Setup](#sfMetadata)
1. [Salesforce Manual Setup](#sfManual)
1. [Xcode Setup](#xcode)
1. [Additional Resources](#resources)

## Prerequisites <a name="pre"></a>

In order to experience, and experiment with this sample app you'll need:

1. A working installation of Git.
1. An Apple Computer with Xcode 10.1 (or possibly higher) installed.
1. If you want to install the sample app on a physical iOS device, you'll need an Apple Developer Account.
1. A Salesforce Scratch Org. (More info on that later)

## Source Control Setup <a name="download"></a>

This project makes use of [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), in addition to Xcode build dependencies to incorporate the SDK. This means you must not only clone this repository, but the submodule repositories as well. If you have not yet cloned this repository, this clone command will clone not only this repo, but the submodules as well.

```
git clone --recurse-submodules https://github.com/trailheadapps/redwoods-insurance.git
```

If you've already cloned this repository, please initialize the submodules using this command

```
git submodule update --init --recursive
```

## Salesforce Metadata Setup <a name="sfMetadata"></a>

The `redwoods-insurance-salesforce` folder in this repository contains _most of_ the neccesary metadata to setup a Salesforce Scratch Org for use with this mobile app. However, there are several manual steps you must accomplish using the Salesforce UI to finalize your scratch org with this metadata:

1. Set up your environment. Follow the steps in the [Quick Start: Salesforce DX](https://trailhead.salesforce.com/en/content/learn/projects/quick-start-salesforce-dx) Trailhead Project.

1. If you haven't already done so, authenticate with your dev hub org and provide it with an alias (devHub):

    ```
    sfdx auth:web:login -d -a devHub
    ```

1. cd to Salesforce Org Setup folder in a command line:

    ```
    cd redwoods-insurance-salesforce
    ```

1. Create a scratch org and provide it with an alias (redwoods-insurance):

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a redwoods-insurance
    ```

1. Push the app to your scratch org:

    ```
    sfdx force:source:push
    ```

1. Create a new Role named `redwoods-insuranceAdjuster`:

    ```
    sfdx force:data:record:create -s userRole -v Name='redwoods-insuranceAdjuster'
    ```

    > _Take note of the UserRoleId that's returned_, it will start with '00E'.

1. Find the default users' ID and assign that user the new Role:

    ```
    sfdx force:user:display
    ```

    > _Identify the users' Id_, it will start with '005':

1. Set the default User's Role to the newly created role:

    ```
    sfdx force:data:record:update -s user -i <<<USER-ID>>> -v "userRoleId=<<<USER-ROLE-ID>>>"
    ```

1. Assign the **redwoods_insurance_mobile** permission set to the default user:

    ```
    sfdx force:user:permset:assign -n redwoods_insurance_mobile
    ```

1. Open your new scratch org, to the communities setup page in a web browser:

    ```
    sfdx force:org:open -p /lightning/setup/SetupNetworks/home
    ```

## Manual steps you must take in your org <a name="sfManual"></a>

The mobile application is configured to allow only Customer Community Login users to log in. You'll need to manually setup, activate and publish a community through the UI.

1. Create the Community:
    1. If opening the org didn't take you to the 'All Communities' setup page, navigate there via Setup -> Feature Settings -> Communities -> All Communities.
    1. Click the 'New Community' Button.
    1. Select the 'Customer Account Portal' experience.
    1. Click 'Get Started'.
    1. When prompted, enter 'Redwoods Car Insurance' as the name.
    1. Click 'Create'.
    1. Allow the community wizard to finish.
1. Adding a Profile for community users:
    1. In the upper left-hand menu, select 'Salesforce Setup' which will open in a new tab/window.
    1. Using either the menu, or the quick find bar, navigate to Profiles:
        1. Click 'New Profile'.
        1. Select _'Customer Community Login User'_ as the profile to clone from.
        1. Give the profile the name 'redwoods_insurance_mobileUser'.
        1. Click 'Save'.
        1. On the newly created profile screen, click the 'Edit' button.
        1. Under 'Administrative Permissions' find the checkbox labeled: 'API Enabled' and check it.
        1. Click 'Save'.
1. Add the profile to your Community:
    1. Navigate to your original tab -- where you're configuring your community -- and using the menu on the left, click 'Administration'.
    1. Using the menu on the left hand side of the screen, select 'Members'
    1. On the members page, use the drop down to select 'Customer' from the list of available profile groups. _If you do not see 'redwoods_insurance_mobileUser' listed, please ensure you created the profile as a clone of 'Customer Community Login User' profile._
    1. Select 'redwoods_insurance_mobileUser' on the left side, and click the 'Add' button.
    1. Scroll to the bottom of the page and click 'Save'
1. Activate the Community:
    1. Using the menu on the left, click 'Settings'.
    1. You'll see the URL of your community listed just above an 'Activate Community' button. _Copy that url_ as you'll need it later.
    1. Click the 'Activate Community' button.
1. Publish the Community:
    1. Using the drop-down menu in the upper left, click on the 'Builder' workspace.
    1. Click the 'Publish' button in the upper right of the Community Builder.
    1. Click 'Publish' to confirm.
1. Create a Community User:
    1. From the Builder screen, click the upper left drop down menu, and select 'Salesforce Setup'.
    1. Using the App Launcher, select 'Service'.
    1. Click on the 'Accounts' tab, and create a new account. Populate the information as you see fit.
    1. From your newly created Account's detail page, click 'New' button on the Contacts related list view.
    1. Create a new contact.
    1. From the Account detail page, click on the name of your newly created contact to navigate to the Contact detail page.
    1. Click the disclosure icon in the upper right of the contact's Highlights Panel, and select 'Enable Customer User'.
    1. Make sure to fill in an email address you can check, as you'll need to verify your user's email before you can login.
    1. Select _'Customer Community Login'_ as the User License.
    1. Select _'redwoods_insurance_mobileUser'_ as the Profile.
    1. Populate all other required fields.
    1. Click 'Save', and click 'OK' to acknowledge that the user will recieve an email.
1. Finalize your Customer Community Login User:
    1. You'll soon recieve an email from Salesforce welcoming your user to the community. Click the provided link to verify your email and set your user's password.
1. Assign your new Customer Community Login User the 'Redwoods-Insurance Mobile' permission set:
    1. Navigate to Setup -> Users -> Permission Sets.
    1. Click on 'Redwoods-Insurance Mobile'.
    1. Click on 'Manage Assignments'.
    1. Click on 'Add Assignment'.
    1. Click the checkbox next to your Redwoods-Insurance Mobile' username.
    1. Click 'Assign'.
    1. Click 'Done'.

## iOS App Setup

> _Note_: Salesforce Communities Users can only authenticate to the community they're part of. Thus, when writing apps with the Salesforce mobile SDK for iOS it's best practice to manually set the login host for your application as part of your build.

1. Open the file `info.plist` found in the 'Supporting Files' group in Xcode.
1. Locate the key `SFDCOAuthLoginHost`, which by default says `login.salesforce.com`. Edit the default value, replacing it with the community url you copied down earlier. Please note, while the community url likely starts with `https://` **DO NOT** include the `https://` portion of the URL in this `plist` value.

> Note: The source ships with a valid connected app consumer key. However, if you'd like to use your own, ensure it has the following oAuth scopes:
>
> -   Access your basic information (id, profile, email, address, phone)
> -   Access and manage your data (api)
>     -   Provide access to your data via the Web (web)
>     -   Access and manage your Chatter data (chatter_api)
> -   Perform requests on your behalf at any time (refresh_token, offline_access)
>
> Once you have established your connected app, copy the consumer key into the TrailIsurance/bootconfig.plist file using Xcode.

## Xcode Setup <a name="xcode"></a>

To load the project in Xcode, open the redwoods-insurance.xcodeproj file.

This project should build and run on the simulator 'out of the box' if the submodules have been properly initialized. However, if you would like to run this on a physical iOS device, you'll need to specify your Team name in the project's settings.

> Note: If you're running this in the simulator, and everything seems really slow, check to ensure you've not accidentally toggled 'Slow Animations' in the Debug menu of the simulator app. It's hotkey is `Cmd-t`, so it can be accidentally toggled fairly easily.

## Additional Resources <a name="resources"></a>

For more information on the Salesforce Mobile SDK for iOS check out these resources:

1. [Salesforce Mobile SDK Basics](https://trailhead.salesforce.com/en/content/learn/modules/mobile_sdk_introduction)
1. [Native iOS Trailhead Module](https://trailhead.salesforce.com/en/content/learn/modules/mobile_sdk_native_ios)
1. [Get Started with iOS App Development](https://trailhead.salesforce.com/en/content/learn/trails/start-ios-appdev)
1. [Swift Essentials](https://trailhead.salesforce.com/en/content/learn/modules/swift-essentials)
