#!/bin/sh

echo making pva

cp -v iFixit-Info.plist ../../iFixit-Info.plist

cp -v CategoryTabBarViewController.m ../../CategoryTabBarViewController.m
cp -v CategoriesViewController.h ../../Classes/CategoriesViewController.h
cp -v CategoriesViewController.m ../../Classes/CategoriesViewController.m
cp -v Config.h ../../Classes/Config.h
cp -v Config.m ../../Classes/Config.m
cp -v iFixitAppDelegate.m ../../Classes/iFixitAppDelegate.m
cp -v Default* ../../
cp -v dozuki.sh ../../
cp -v icon* ../../
cp -v project.pbxproj ../../iFixit.xcodeproj/project.pbxproj
mkdir ../../iFixit/Images.xcassets/AppIcon-3.appiconset
cp -v AppIcon-3.appiconset/* ../../iFixit/Images.xcassets/AppIcon-3.appiconset
cp -v iFixitAPI.m ../../Classes/iFixitAPI.m
