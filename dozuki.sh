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
   sed -i '.bak' -e 's/iFixit/Zeal/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>zeal</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigZeal;/' Classes/iFixitAppDelegate.m
elif [ "$1" == "mjtrim" ]; then
   echo "Mjtrim"
   cp Graphics/Sites/Mjtrim/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.mjtrim/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/MJ Trimming/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>mjtrim</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
   sed -i '.bak' -e 's/\[Config currentConfig\].site = ConfigIFixit;/\[Config currentConfig\].site = ConfigMjtrim;/' Classes/iFixitAppDelegate.m
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
fi
