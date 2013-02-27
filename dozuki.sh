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
elif [ "$1" == "haas2" ]; then
   echo "Haas2"
   cp Graphics/Sites/Haas2/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.haas2/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/HAAS/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>haas2</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
#EAOPlist
else
   echo "Dozuki"
   cp Graphics/Sites/Dozuki/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.dozuki/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Dozuki/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>dozuki</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = NO;/\[Config currentConfig\].dozuki = YES;/' Classes/iFixitAppDelegate.m
fi
