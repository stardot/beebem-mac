#!/bin/bash

###############################################################
#
# NOTE: This script is intended to be run manually and assumes
# 		you have already exported a signed application bundle
#		using the Xcode 'Archive' tool. There is probably a
#		far better way to do this but i will do for now.
#
###############################################################


TEMPLATE=Template.dmg.gz
OUTPATH=$HOME/tmp/BeebEmMac_BUILD
OUTPUT=BeebEmMac.dmg
VOLNAME=BeebEm\ Mac
APPBUNDLE=$OUTPATH/Export/BeebEm4a.app

if [ ! -d "$APPBUDLE" ]; then
	echo "Application bundle not found. Export it to the following path and run this script again"
	echo "'$APPBUNDLE'"
	# temporarily disable
	#exit;
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
# TODO - Work out the Xcode way to copy the signed application

# Now detach (unmount) the DMG ready for signing

hdiutil detach "/Volumes/$VOLNAME"

