#!/bin/sh

echo making aristo

cp -v titleImageAristocrat.png ../../titleImageAristocrat.png
cp -v titleImagePepsi.png ../../titleImagePepsi.png
cp -v iFixit-Info.plist ../../iFixit-Info.plist
cp -v Default* ../../
mkdir ../../iFixit/Images.xcassets/AppIcon-3.appiconset
cp -v AppIcon-3.appiconset/* ../../iFixit/Images.xcassets/AppIcon-3.appiconset
cp -R Aristocrat.xcodeproj ../../Aristocrat.xcodeproj
cp -R Aristocrat.xcworkspace ../../Aristocrat.xcworkspace
cp -v Config.m ../../Classes/Config.m
cp -v iFixitAppDelegate.m ../../Classes/iFixitAppDelegate.m
cp -v Podfile ../../Podfile
cp -v Podfile.lock ../../Podfile.lock
rm -rf ../../Pods
cp -R Pods ../../Pods