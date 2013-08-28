#!/usr/bin/env ruby

#####
# This script will create the code needed when someone comes to us and asks for
# a custom iOS app. We still need to make sure image assets are in the correct
# folder and all images are named accordingly.
#
# How it works: We have comments within the iOS app that the script will use as
# markers, to know where to place new addition of code. It essentially uses
# regex to find the marker, adds the new code in the correct place, then writes
# to the given file.
#
# How to add more: Just add a new dictionary in the array, and the script will
# take care of the rest. For more info about the format of new additions, check
# out the comment regarding the recipe array below. Be sure to place the
# correct marker within the iOS mobile app. in the form of /*EAONewMarker*/
#####

puts "Easy App Oven!"
configName = nanoSite = appName = configPrivate = answersEnabled = store = ''

# Ask the user for nanosite
until nanoSite.match(/^[a-z-]+/)
   puts "\nEnter the nanosite (ie: failfactory)"
   nanoSite = gets.chomp
end

# Ask the user for a Config variable name
until configName.match(/^Config\w+/)
   puts "\nEnter a valid variable name for Config variable. IE: ConfigIfixit"
   configName = gets.chomp
end

# Ask user for App Name
puts "\nEnter the App Name:"
appName = gets.chomp

# Ask the user if the nanosite is private
until configPrivate.match(/[y|n]/)
   puts "\nIs the nanosite private? (y/n)"
   configPrivate = gets.chomp
end

configPrivate = configPrivate.eql?('y') ? 'YES' : 'NO'

# Ask the user if the nanosite is private
until answersEnabled.match(/[y|n]/)
   puts "\nDoes the nanosite have answers enabled? (y/n)"
   answersEnabled = gets.chomp
end

answersEnabled = answersEnabled.eql?('y') ? 'YES' : 'NO'

# Ask the user if the nanosite has a store
until store.match(/^[a-z-]+/)
   puts "\nDoes the nanosite have a store? Enter URL for store, other wise enter 'n'"
   store = gets.chomp
end

store = store.eql?('n') ? 'nil' : store

####
# Each object in the recipe's array is a 'clump' of code changes
# :file == Path to Class file
# :pattern == Marker we use to search for, ie: /*EAOConfig*/
# :ingredient == Code to replace found pattern
#
# Important: If you have a file that needs multiple :pattern(s) that will
# perform multiple replacements, use an array, with the corresponding
# string replacement stored in an array in 'ingredients'.
####
recipes = [
   # Add logo title image, along with resizing logic for portrait/landscape
   { :file       => 'Classes/Config.h',
     :pattern    => /\/\*EAOConfig\*\//,
     :ingredient => "#{configName},\n" + "\s" * 4 + "/*EAOConfig*/" },

   # Add header logo image for iPads when viewing Guide Intro
   { :file       => 'Classes/GuideIntroViewController.m',
     :pattern    => /\/\*EAOGuideIntro\*\//,
     :ingredient => "case #{configName}:\n" +
                     "\s" * 16 + "image = [UIImage imageNamed:@\"#{nanoSite}_logo_transparent.png\"];\n" +
                     "\s" * 16 + "headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height);\n" +
                     "\s" * 16 + "headerImageLogo.image = image;\n" +
                     "\s" * 16 + "break;\n" + "\s" * 12 + "/*EAOGuideIntro*/" },

   # Add config settings such as base url and other options
   { :file       => 'Classes/Config.m',
     :pattern    => /\/\*EAOOptions\*\//,
     :ingredient => "case #{configName}:\n" +
                     "\s" * 12 + "self.host = @\"#{nanoSite}.dozuki.com\";\n" +
                     "\s" * 12 + "self.baseURL = @\"http://#{nanoSite}.dozuki.com\";\n" +
                     "\s" * 12 + "answersEnabled = #{answersEnabled};\n" +
                     "\s" * 12 + "collectionsEnabled = NO;\n" +
                     "\s" * 12 + "self.store = @\"#{store}\";\n" +
                     "\s" * 12 + "self.private = #{configPrivate};\n" +
                     "\s" * 12 + "break;\n" + "\s" * 8 + "/*EAOOptions*/" },

   # Add title image logo and resizing logic for title image logo
   { :file       => 'Classes/CategoriesViewController.m',
     :pattern    => [ /\/\*EAOTitle\*\//, /\/\*EAOLandscapeResize\*\//, /\/\*EAOPortraitResize\*\// ],
     :ingredient => [ "case #{configName}:\n" +
                     "\s" * 16 + "titleImage = [UIImage imageNamed:@\"titleImage#{nanoSite.capitalize}.png\"];\n" +
                     "\s" * 16 + "imageTitle = [[UIImageView alloc] initWithImage:titleImage];\n" +
                     "\s" * 16 + "self.navigationItem.titleView = imageTitle;\n" +
                     "\s" * 16 + "break;\n" +
                     "\s" * 12 + "/*EAOTitle*/",
                     "case #{configName}:\n" +
                     "\s" * 16 + "frame = self.navigationItem.titleView.frame;\n" +
                     "\s" * 16 + "frame.size.width = 0.0;\n" +
                     "\s" * 16 + "frame.size.height = 0.0;\n" +
                     "\s" * 16 + "self.navigationItem.titleView.frame = frame;\n" + "\s" * 16 +
                     "break;\n" + "\s" * 12 + "/*EAOLandscapeResize*/",
                     "case #{configName}:\n" +
                     "\s" * 16 + "frame = self.navigationItem.titleView.frame;\n" +
                     "\s" * 16 + "frame.size.width = 0.0;\n" +
                     "\s" * 16 + "frame.size.height = 0.0;\n" +
                     "\s" * 16 + "self.navigationItem.titleView.frame = frame;\n" + "\s" * 16 +
                     "break;\n" + "\s" * 12 + "/*EAOPortraitResize*/" ] },
   # Add large background iPad logo and resizing logic for logo
   { :file       => 'Classes/DetailGridViewController.m',
     :pattern    => [ /\/\*EAOiPadSiteLogo\*\// ],
     :ingredient => [ "case #{configName}:\n" +
                  "\s" * 12 + "self.siteLogo.image = [UIImage imageNamed:@\"#{nanoSite}_logo_transparent.png\"];\n" +
                  "\s" * 12 + "[self.backgroundView addSubview:self.siteLogo];"+
                  "\s" * 12 + "break;\n" + "\s" * 8 + "/*EAOiPadSiteLogo*/" ] },
   # Add code to our bash script that switches between iOS apps
   { :file       => 'dozuki.sh',
     :pattern    => /#EAOPlist/,
     :ingredient => "elif [ \"$1\" == \"#{nanoSite}\" ]; then\n" +
                     "\s" * 3 + "echo \"#{nanoSite.capitalize}\"\n" +
                     "\s" * 3 + "cp Graphics/Sites/#{nanoSite.capitalize}/*png .\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.#{nanoSite}/g' iFixit-Info.plist\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/iFixit/#{appName}/g' iFixit-Info.plist\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/>ifixit</>#{nanoSite}</g' iFixit-Info.plist\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/\\[Config currentConfig\\].dozuki = YES;/\\[Config currentConfig\\].dozuki = NO;/' Classes/iFixitAppDelegate.m\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/\\[Config currentConfig\\].site = ConfigIFixit;/\\[Config currentConfig\\].site = #{configName};/' Classes/iFixitAppDelegate.m\n" +
                     "#EAOPlist"}
]

####
# Search for the correct place to insert new code.
# recipe[:file] => Pointing to path of file to search through
# recipe[:pattern] => Regex Pattern to search for to insert new code
# recipe[:ingredient] => New code to insert
####
def bakeRecipe(recipe)
   if File.file?(recipe[:file])
      fileContents = File.read(recipe[:file])

      # If pattern is an array, we have multiple inserts to do
      if recipe[:pattern].is_a? Array
         # Zip: [[pattern1, ingredient1], [pattern2, ingredient2]]
         recipe[:pattern].zip(recipe[:ingredient]).each do |recipeArray|
            fileContents.sub!(recipeArray[0], recipeArray[1])
         end
      else
         fileContents.sub!(recipe[:pattern], recipe[:ingredient])
      end

      File.write(recipe[:file], fileContents)
   else
      puts "Could not find file: #{recipe[:file]}, unplug the oven!"
      exit 1
   end
end

# Let's bake!
recipes.each do |recipe|
   bakeRecipe(recipe)
end

puts "\nRemember: Make sure you have the image assets in the correct path and " +
     "they are named accordingly:\n" +
     "Graphics/Sites/#{nanoSite.capitalize}/\n" +
     "titleImage#{nanoSite.capitalize}.png\n" +
     "#{nanoSite}_logo_transparent.png\n" +
     "detailViewText#{nanoSite.capitalize}.png"
