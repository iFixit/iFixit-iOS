#!/bin/bash

if [ "$1" == "off" ]; then
   echo "iFixit"
   cp /Users/dmpatierno/Code/iOS/iFixit/Graphics/Sites/iFixit/*png /Users/dmpatierno/Code/iOS/iFixit/
   sed -i '.bak' -e 's/com.ifixit.dozuki/com.ifixit.ifixit/g' iFixit-Info.plist
   sed -i '.bak' -e 's/Dozuki/iFixit/g' iFixit-Info.plist
elif [ "$1" == "make" ]; then
   echo "Make"
   cp /Users/dmpatierno/Code/iOS/iFixit/Graphics/Sites/Make/*png /Users/dmpatierno/Code/iOS/iFixit/
else
   echo "Dozuki"
   cp /Users/dmpatierno/Code/iOS/iFixit/Graphics/Sites/Dozuki/*png /Users/dmpatierno/Code/iOS/iFixit/
   sed -i '.bak' -e 's/com.ifixit.ifixit/com.ifixit.dozuki/g' iFixit-Info.plist
   sed -i '.bak' -e 's/iFixit/Dozuki/g' iFixit-Info.plist
fi
