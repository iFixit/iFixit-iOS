#!/bin/sh

echo making aristo

# images
cp -v Default* ../../
mkdir ../../iFixit/Images.xcassets/AppIcon-3.appiconset
cp -v AppIcon-3.appiconset/* ../../iFixit/Images.xcassets/AppIcon-3.appiconset

# config code
cp -v Config.m ../../Classes/Config.m
cp -v iFixitAppDelegate.m ../../Classes/iFixitAppDelegate.m

# plist
cp -v iFixit-Info.plist ../../iFixit-Info.plist

#extra
cp -v Podfile ../../Podfile
cp -v Podfile.lock ../../Podfile.lock
rm -rf ../../Pods
cp -R Pods ../../Pods
cp openproj.sh ../../
cp byebye.sh ../../
cd ../../
source ./openproj.sh
