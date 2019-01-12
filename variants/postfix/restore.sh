#!/bin/sh

echo restoring dozuki

git checkout -- ../../icon*
git checkout -- ../../Default*
git checkout -- ../../Default-*
git checkout -- ../../iFixit
git checkout -- ../../iFixit.xcworkspace
git checkout -- ../../iFixit.xcodeproj
git checkout -- ../../iFixit-Info.plist
git checkout -- ../../dozuki.sh
git checkout -- ../../Classes
git checkout -- ../../Podfile
git checkout -- ../../Classes/iFixitAppDelegate.m
git checkout -- ../../Classes/iFixitAppDelegate.m
git checkout -- ../../Classes/Config.m
git checkout -- ../../Classes/iFixitAppDelegate.m
git checkout -- ../../Classes/iFixitAppDelegate.m
git checkout -- ../../Classes/Config.m
git checkout -- ../../Classes/CategoriesViewController.m
git checkout -- ../../Classes/Config.h
git checkout -- ../../Classes/iFixitAPI.m
git checkout -- ../../Default-*

rm -rf ../../Postmix.xcodeproj/
rm -rf ../../Default-Portrait-736h\@3x.png
rm -rf ../../Default-Portrait.png
rm -rf ../../Default-Portrait@
rm -rf ../../Default-Portrait@2x.png
rm -rf ../../Default-667h@2x.png
rm -rf ../../Default-Landscape-736h@3x.png