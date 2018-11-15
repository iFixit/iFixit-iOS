#!/bin/sh

echo making hypertherm new

cp -v iFixit-Info.plist ../../iFixit-Info.plist
cp -v Podfile ../../Podfile
cp -v icon* ../../
cp -v guids.png ../../
cp -v GoogleService-Info.plist ../../
cp -v Default* ../../
cp -v icon* ../../
mkdir ../../iFixit/Images.xcassets/AppIcon-4.appiconset
cp -v AppIcon-3.appiconset/* ../../iFixit/Images.xcassets/AppIcon-4.appiconset
cp -v Config.h ../../Classes/Config.h
cp -v Config.m ../../Classes/Config.m
cp -v iFixitAppDelegate.m ../../Classes/iFixitAppDelegate.m
