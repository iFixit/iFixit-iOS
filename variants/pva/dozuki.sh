#!/bin/bash

if [ "$1" == "off" ]; then
   echo "iFixit"
   cp Graphics/Sites/iFixit/*png .
   sed -i '.bak' -e 's/com.dozuki.dozuki/com.ifixit.ifixit/g' iFixit-Info.plist
   sed -i '.bak' -e 's/Dozuki/iFixit/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>dozuki</>ifixit</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
elif [ "$1" == "make" ]; then
   echo "Make"
   cp Graphics/Sites/Make/*png .
# Need to manually fix up iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
elif [ "$1" == "zeal" ]; then
   echo "Zeal"
   cp Graphics/Sites/Zeal/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.zeal/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Zeal Support/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>zeal</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigZeal;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/zeal/g' Classes/iFixitAPI.m
elif [ "$1" == "mjtrim" ]; then
   echo "Mjtrim"
   cp Graphics/Sites/Mjtrim/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.mjtrim/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Project DIY/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>mjtrim</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigMjtrim;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/mjtrim/g' Classes/iFixitAPI.m
elif [ "$1" == "accustream" ]; then
   echo "Accustream"
   cp Graphics/Sites/Accustream/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.hypertherm/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Hypertherm/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>accustream</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigAccustream;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/accustream/g' Classes/iFixitAPI.m
elif [ "$1" == "magnoliamedical" ]; then
   echo "Magnoliamedical"
   cp Graphics/Sites/Magnoliamedical/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.magnoliamedical/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Magnolia/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>magnoliamedical</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigMagnolia;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/magnoliamedical/g' Classes/iFixitAPI.m
elif [ "$1" == "comcast" ]; then
   echo "Comcast"
   cp Graphics/Sites/Comcast/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.comcast/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Comcast/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>comcast</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigComcast;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/comcast/g' Classes/iFixitAPI.m
elif [ "$1" == "dripassist" ]; then
   echo "Dripassist"
   cp Graphics/Sites/Dripassist/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.dripassist/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/DripAssistant/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>dripassist</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigDripAssist;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/dripassist/g' Classes/iFixitAPI.m
elif [ "$1" == "pva" ]; then
   echo "Pva"
   cp Graphics/Sites/Pva/*png .
   sed -i '.bak' -e 's/com.dozuki.dozuki/com.dozuki.pva/g' iFixit-Info.plist
   sed -i '.bak' -e 's/Dozuki/PVA Support/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>dozuki</>pva</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigDozuki;/\[Config currentConfig\].site = ConfigPva;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/dozuki/pva/g' Classes/iFixitAPI.m
elif [ "$1" == "oscaro" ]; then
   echo "Oscaro"
   cp Graphics/Sites/Oscaro/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.oscaro/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Oscaro Tutoriels/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>oscaro</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigOscaro;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/oscaro/g' Classes/iFixitAPI.m
elif [ "$1" == "techtitanhq" ]; then
   echo "Techtitanhq"
   cp Graphics/Sites/Techtitanhq/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.techtitanhq/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/TechTitanHQ/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>techtitanhq</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigTechtitanhq;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/techtitanhq/g' Classes/iFixitAPI.m
#EAOPlist
else
   echo "Dozuki"
   cp Graphics/Sites/Dozuki/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.dozuki/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Dozuki/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>dozuki</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = NO;/\[Config currentConfig\].dozuki = YES;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\<true\/\> \<\!\-\-UIStatusBar\-\-\>/\<false\/\>/' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigDozuki;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/ifixit/dozuki/g' Classes/iFixitAPI.m
fi
