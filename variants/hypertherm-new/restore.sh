#!/bin/sh

echo restoring dozuki

git checkout -- ../../iFixit-Info.plist
git checkout -- ../../Podfile
git checkout -- ../../icon*
git checkout -- ../../guides.png
rm ../../GoogleService-Info.plist 
git checkout -- ../../Default*
rm -rf ../../iFixit/Images.xcassets/AppIcon-4.appiconset
git checkout -- ../../Classes/Config.m
git checkout -- ../../Classes/Config.h
git checkout -- ../../Classes/iFixitAppDelegate.m
