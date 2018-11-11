#!/bin/sh

echo making zeal
cp -v iFixit-Info.plist ../../iFixit-Info.plist
cp -v Config.m ../../Classes/Config.m
cp -v iFixitAppDelegate.m ../../Classes/iFixitAppDelegate.m

cp -v Default* ../../
cp -v dozuki.sh ../../
cp -v icon* ../../
cp -v project.pbxproj ../../iFixit.xcodeproj/project.pbxproj
mkdir ../../iFixit/Images.xcassets/AppIcon-3.appiconset
cp -v AppIcon-3.appiconset/* ../../iFixit/Images.xcassets/AppIcon-3.appiconset