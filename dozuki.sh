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
elif [ "$1" == "crucial" ]; then
   echo "Crucial"
   cp Graphics/Sites/Crucial/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.crucial/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Crucial/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>crucial</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = YES;/\[Config currentConfig\].dozuki = NO;/' Classes/iFixitAppDelegate.m
else
   echo "Dozuki"
   cp Graphics/Sites/Dozuki/*png .
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.dozuki/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Dozuki/g' iFixit-Info.plist
   sed -i '.bak' -e 's/>ifixit</>dozuki</g' iFixit-Info.plist
   sed -i '.bak' -e 's/\[Config currentConfig\].dozuki = NO;/\[Config currentConfig\].dozuki = YES;/' Classes/iFixitAppDelegate.m
fi
