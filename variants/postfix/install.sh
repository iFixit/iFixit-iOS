#!/bin/sh

echo making postfix
cp -v iFixit-Info.plist ../../iFixit-Info.plist
cp -v CategoriesViewController.m ../../Classes/CategoriesViewController.m
cp -v Config.h ../../Classes/Config.h
cp -v Config.m ../../Classes/Config.m
cp -v iFixitAppDelegate.m ../../Classes/iFixitAppDelegate.m
cp -v iFixitAPI.h ../../Classes/iFixitAPI.h
cp -v iFixitAPI.m ../../Classes/iFixitAPI.m
cp -v iPhoneDeviceViewController.m ../../Classes/iPhoneDeviceViewController.m
cp -v iPhoneDeviceViewController.xib ../../Classes/iPhoneDeviceViewController.xib
cp -v BookmarksViewController.m ../../Classes/BookmarksViewController.m
cp -v DetailGridViewController.m ../../Classes/DetailGridViewController.m
cp -v GuideIntroViewController.m ../../Classes/GuideIntroViewController.m
cp -v CategoryTabBarViewController.m ../../CategoryTabBarViewController.m
cp -v CategoriesViewController.h ../../Classes/CategoriesViewController.h
cp -v CategoriesViewController.m ../../Classes/CategoriesViewController.m
cp -v Default* ../../
cp -v dozuki.sh ../../
cp -v icon* ../../
cp -v LoginViewController.m ../../Classes/LoginViewController.m
cp -v project.pbxproj ../../iFixit.xcodeproj/project.pbxproj
mkdir ../../iFixit/Images.xcassets/AppIcon-2.appiconset
mkdir ../../Postmix.xcodeproj
cp -v AppIcon-2.appiconset/* ../../iFixit/Images.xcassets/AppIcon-2.appiconset
cp -v contents.xcworkspacedata ../../iFixit.xcworkspace/contents.xcworkspacedata
cp -v iPhoneDeviceViewController.h ../../Classes/iPhoneDeviceViewController.h
