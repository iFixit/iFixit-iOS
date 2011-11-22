#!/bin/bash

if [ "$1" == "off" ]; then
   echo "iFixit"
   cp /Users/dmpatierno/Code/iOS/iFixit/Graphics/Sites/iFixit/*png /Users/dmpatierno/Code/iOS/iFixit/
elif [ "$1" == "make" ]; then
   echo "Make"
   cp /Users/dmpatierno/Code/iOS/iFixit/Graphics/Sites/Make/*png /Users/dmpatierno/Code/iOS/iFixit/
else
   echo "Dozuki"
   cp /Users/dmpatierno/Code/iOS/iFixit/Graphics/Sites/Dozuki/*png /Users/dmpatierno/Code/iOS/iFixit/
fi
