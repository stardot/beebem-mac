#!/bin/bash

###############################################################
#
# NOTE: This script is intended to be run manually and assumes
# 		you have already exported a signed application bundle
#		using the Xcode 'Archive' tool. There is probably a
#		far better way to do this but it will do for now.
#
###############################################################

# Get code signing details from config file
arr=($(grep "DEVELOPMENT_TEAM_ID" "../Config/CodeSign.xcconfig"))
DEVELOPMENT_TEAM_ID=${arr[2]}

line=$(grep "DEVELOPMENT_TEAM_NAME" "../Config/CodeSign.xcconfig")
DEVELOPMENT_TEAM_NAME="${line##*= }"

TEMPLATE=Template.dmg.gz
OUTPATH=$HOME/tmp/BeebEmMac_BUILD
OUTPUT=Temp.dmg
FINAL=BeebEmMac.dmg
VOLNAME=BeebEmMac
APPBUNDLE=$OUTPATH/Export/BeebEm4.app

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SRC_PATH="$SCRIPT_PATH/../Src"

if [ ! -d "$APPBUNDLE" ]; then
	echo "Application bundle not found. Export it to the following path and run this script again"
	echo "'$APPBUNDLE'"
	exit 1;
fi

echo "Creating install DMG from template"

if [ -e "$OUTPATH/$OUTPUT" ]; then
	rm "$OUTPATH/$OUTPUT"
fi

cp $TEMPLATE $OUTPUT.gz
mv $OUTPUT.gz $OUTPATH
gunzip $OUTPATH/$OUTPUT

echo "Mounting DMG"
hdiutil attach $OUTPATH/$OUTPUT

echo "Copying support files"
cp -R ../UserData/* "/Volumes/$VOLNAME/BeebEmMac/"

echo "Copying signed application"
cp -R "$APPBUNDLE" "/Volumes/$VOLNAME/BeebEmMac/"

echo "Copying current source"
cp -R "$SRC_PATH" "/Volumes/$VOLNAME/BeebEmMac/"

xattr -cr "/Volumes/$VOLNAME/BeebEmMac"

# Now detach (unmount) the DMG ready for signing
hdiutil detach "/Volumes/$VOLNAME"

# Compress DMG and make it read-only
echo "Compressing final DMG"
hdiutil convert -format UDZO -o "$OUTPATH/$FINAL" "$OUTPATH/$OUTPUT" -imagekey zlib-level=9

# Remove extended attributes before signing
xattr -cr "$OUTPATH/$FINAL"

# Sign DMG
echo "Signing DMG with team ID: $DEVELOPMENT_TEAM_ID"
codesign -s "Developer ID Application: $DEVELOPMENT_TEAM_NAME ($DEVELOPMENT_TEAM_ID)" "$OUTPATH/$FINAL"

# Clean up
echo "Cleaning temporary files"
rm "$OUTPATH/$OUTPUT"
