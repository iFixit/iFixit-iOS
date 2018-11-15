#!/bin/sh

echo restoring dozuki

# image restore
git checkout -- ../../Default*
git checkout -- ../../Default-568h@2x.png
git checkout -- ../../Default-Landscape.png
git checkout -- ../../Default-Landscape@2x.png
git checkout -- ../../Default-Landscape@2x~ipad.png
git checkout -- ../../Default-Landscape~ipad.png
git checkout -- ../../Default-Portrait@2x~ipad.png
git checkout -- ../../Default-Portrait~ipad.png
git checkout -- ../../Default.png
git checkout -- ../../Default@2x.png
rm ../../Default-667h@2x.png
rm ../../Default-Landscape-736h@3x.png
rm ../../Default-Portrait-736h@3x.png
rm ../../Default-Portrait.png
rm ../../Default-Portrait@2x.png
rm ../../iFixit/Images.xcassets/AppIcon-3.appiconset/Icon-App-Aristo-1024x1024.png
git checkout -- ../../iFixit/Images.xcassets/AppIcon-3.appiconset

# configuration files
git checkout -- ../../iFixit-Info.plist
git checkout -- ../../Classes/Config.m
git checkout -- ../../Classes/iFixitAppDelegate.m

#extra
git checkout -- ../../Podfile
git checkout -- ../../Podfile.lock
rm -rf ../../Pods
git checkout -- ../../Pods
