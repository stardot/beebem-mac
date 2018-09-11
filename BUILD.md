# Building BeebEm For Mac

M White - 09/2018

- [Introduction](#introduction)
- [Preparing The Environment](#preparing-the-environment)
- [Prepare Code Signing](#prepare-code-signing)
- [Building](#building)
- [Creating The Installer](#creating-the-installer)  
  - [Creating and exporting the archive](#creating-and-exporting-the-archive)
  - [Building the DMG installer](#building-the-dmg-installer)

## Introduction

BeebEm for Mac has been updated to build on High Sierra using current (v9.4) Xcode but it may not be
entirely intuitive how to initially get things working, especially when it comes to code signing
the resulting application. If all you want to do is run the application then there is no need to
worry about any of the following and you should instead just download the installer bundle like you
would any other Mac application.

## Preparing The Environment

NOTE: **YOU WILL NEED TO REPEAT THIS PROCESS EVERY TIME XCODE UPDATES**

BeebEm for Mac is a 32bit application built using the Carbon API and as such requires the SDK
from 10.6 in order to build. Apple does not officially support or ship old SDKs with Xcode so we need
to set this up ourselves. You will need to obtain a copy of the SDK from somewhere - google is your
friend here but be careful since it looks like not all SDK copies out in the wild are complete and
of course if you don't know or trust the source then it could perceivably contain malware?

Once you have your SDK, copy it somewhere convenient on your disk.

Next, find your copy of Xcode in Finder and using "Show Contents" locate the following folder:

```bash
Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
```

By default you will find a single folder called "MacOSX.sdk" and a symbolic link called "MacOSX10.13.sdk"
pointing to ths folder. All we need to do is create a new symbolic link in this location called
"MacOSX10.6.sdk" which points to the location of our 10.6 SDK.

There is one more step we need to take. Since around Xcode 7, we also need to modify the minimum SDK
version that Xcode will allow. Find the following file:

```bash
Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Info.plist
```

Now locate the setting 'MinimumSDKVersion' on or around line 90 and change the String value to be 10.6

That's all there is to it. The Xcode project already has that SDK selected but if you wanted to
change the SDK for any target 10.6 will now appear in the list. You can repeat this for any other
SDK you may wish to install.

## Prepare Code Signing

In order to properly build and deploy the application, code signing your distribution is now unavoidable.
Even if you are a sole developer you will have a "Team ID" from Apple. It might just have your own
name as the name of the team. The application needs to be signed with this ID but of course we don't
want to disclose details about this ID when we check our source into code control systems. Xcode has
a means to customise settings using external files and we can use that to get around this.

In the 'Config' folder you will find a number of 'xcconfig' files. One for each target and one for the
project. You should not need to change anything in these but there is a fourth config file that will
be missing from your local copy called 'CodeSign.xcconfig'. You will however find an example file.
Copy this file and remove the example extension, then edit it and fill out the two required fields.

The ID you need to populate is the one from your "Mac Developer ID" identity and should be something
like a 10 digit alpha-numeric code.

In order for code signing to work properly **you will need a valid paid-up Apple developer subscription**
but note that onely one person needs to perform the release, not all developers. Also, at this time
the end user will still receive a warning when installing the application due to it not being 64 bit.
Currently this is unavoidable due to the use of the Carbon API.

## Building

You should now be ready to build, debug and otherwise work on the project. At the time of writing
the compiler emits around 30 warnings, most of which are purely semantic and can be ignored. These
may be "fixed" in a future release.

At this point if the build fails something is wrong, most likely in your build settings / targets or
perhaps I have missed something in this document.

## Creating The Installer

Creating a release is a two-step process. Firstly you must create and export an archive of the aplication
bundle (the .app folder), then you need to create the DMG for distribution.

### Creating and exporting the archive

There is more than one way to go about this and in the future it may be automated but for now take
the following steps:

- If you do not yet have an archive to export go to 'Archive' from the 'Project' menu. This will build your project and open the Organiser at the Archives tab
- If you already had an archive then it can be reached using the Organise option on the Window menu
- In the organiser select the archive you wish to export and click the Export button
- Select "Developer ID" as the method of distribution. Xcode will then analyse the solution
- You should be able to leave "Automatically manage signing" selected
- Xcode will then talk to Apple's servers to verify your signature and if all goes well you will reach a summary page from which we finally do the export
- When prompted ensure you export to the following path. This is important for the next step:  
  - '~/tmp/BeebEmMac_BUILD/Export'
- Xcode will create the app bundle and a couple of supporting files in this folder.

Code signing for the **Application** is now complete - we will sign the entire DMG in the next step.

### Building the DMG installer

For this final step there is a somewhat crude bash script supplied with the project. Open a terminal
and navigate to the Install folder. From there simply execute:

```bash
./create_dmg.sh
```

The script will take the template disk image from the install folder, decompress it, mount it, add
the new application to it along with the sources and other user data files, unmount the image, re-compress
it and finally sign it for distribution. The resulting DMG file will be located in the folder

```bash
'~/tmp/BeebEmMac_BUILD'
```

Before running the script again you must ensure the image is not mounted and that it has been deleted
from this folder or the script will abort and / or fail.

The resulting DMG can be zipped and used for distribution. Note that the application cannot be submitted
to the App Store in it's current state for multiple reasons but all being well the end user should
not receive any scary warnings when installing the application. Sadly the "This application was
downloaded from the internet" and the "This application needs to be updated" cannot be avoided at this
time but the user should be fairly familier with those messages.

[GO TO TOP](#building-beebem-for-mac)