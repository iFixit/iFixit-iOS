#!/usr/bin/env ruby

#####
# This script will create the code needed when someone comes to us and asks for
# a custom iOS app. We still need to make sure image assets are in the correct
# folder and all images are named accordingly. This script takes about 95% of
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
configName = nanoSite = appName = ''

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

####
# Each dictionary in the recipe's array is a 'clump' of code changes
# 'file' == Path to Class file
# 'pattern' == Marker we use to search for, ie: /*EAOConfig*/
# 'ingredient' == Code to replace found pattern
#
# Important: If you have a file that needs multiple 'pattern'(s) that will
# perform multiple replacements, use an array, with the corresponding
# string replacement stored in an array in 'ingredients'.
####
recipes = [
   # Add logo title image, along with resizing logic for portrait/landscape
   { 'file'       => 'Classes/Config.h',
     'pattern'    => /\/\*EAOConfig\*\//,
     'ingredient' => "#{configName},\n" + "\s" * 4 + "/*EAOConfig*/" },

   # Add header logo image for iPads when viewing Guide Intro
   { 'file'       => 'Classes/GuideIntroViewController.m',
     'pattern'    => /\/\*EAOGuideIntro\*\//,
     'ingredient' => "case #{configName}:\n" +
                     "\t" * 4 + "image = [UIImage imageNamed:@\"logo_#{nanoSite}.png\"];\n" +
                     "\t" * 4 + "headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height);\n" +
                     "\t" * 4 + "headerImageLogo.image = image;\n" +
                     "\t" * 4 + "[image release];\n" +
                     "\t" * 4 + "break;\n\t" + "\t" * 2 + "/*EAOGuideIntro*/" },

   # Add config settings such as base url and other options
   { 'file'       => 'Classes/Config.m',
     'pattern'    => /\/\*EAOOptions\*\//,
     'ingredient' => "case #{configName}:\n" +
                     "\t" * 3 + "self.host = @\"#{nanoSite}.dozuki.com\";\n" +
                     "\t" * 3 + "self.baseURL = @\"http://#{nanoSite}.dozuki.com\";\n" +
                     "\t" * 3 + "answersEnabled = NO;\n" +
                     "\t" * 3 + "collectionsEnabled = NO;\n" +
                     "\t" * 3 + "self.store = nil;\n" +
                     "\t" * 3 + "break;\n" + "\t" * 2 + "/*EAOOptions*/" },

   # Add title image logo and resizing logic for title image logo
   { 'file'       => 'Classes/CategoriesViewController.m',
     'pattern'    => [ /\/\*EAOTitle\*\//, /\/\*EAOLandscapeResize\*\//, /\/\*EAOPortraitResize\*\// ],
     'ingredient' => [ "case #{configName}:\n" +
                     "\t" * 4 + "titleImage = [UIImage imageNamed:@\"titleImage#{nanoSite.capitalize}.png\"];\n" +
                     "\t" * 4 + "imageTitle = [[UIImageView alloc] initWithImage:titleImage];\n" +
                     "\t" * 4 + "self.navigationItem.titleView = imageTitle;\n" +
                     "\t" * 4 + "[imageTitle release];\n" +
                     "\t" * 4 + "[titleImage release];\n" + "\t" * 4 + "break;\n" +
                     "\t" * 3 + "/*EAOTitle*/",
                     "case #{configName}:\n" +
                     "\t" * 4 + "frame = self.navigationItem.titleView.frame;\n" +
                     "\t" * 4 + "frame.size.width = 0.0;\n" +
                     "\t" * 4 + "frame.size.height = 0.0;\n" +
                     "\t" * 4 + "self.navigationItem.titleView.frame = frame;\n" + "\t" * 4 +
                     "break;\n" + "\t" * 3 + "/*EAOLandscapeResize*/",
                     "case #{configName}:\n" +
                     "\t" * 4 + "frame = self.navigationItem.titleView.frame;\n" +
                     "\t" * 4 + "frame.size.width = 0.0;\n" +
                     "\t" * 4 + "frame.size.height = 0.0;\n" +
                     "\t" * 4 + "self.navigationItem.titleView.frame = frame;\n" + "\t" * 4 +
                     "break;\n" + "\t" * 3 + "/*EAOPortraitResize*/" ] },

   # Add large background iPad logo and resizing logic for logo
   { 'file'       => 'Classes/DetailIntroViewController.m',
     'pattern'    => [ /\/\*EAOLandscape\*\//, /\/\*EAOPortrait\*\//, /\/\*EAOiPadLogo\*\// ],
     'ingredient' => [ "case #{configName}:\n" +
                     "\t" * 4 + "frame.origin.y = 0.0;\n" +
                     "\t" * 4 + "frame.origin.x = 0.0;\n" +
                     "\t" * 4 + "break;\n\t" + "\t" * 2 +  "/*EAOLandscape*/",
                     "case #{configName}:\n" +
                     "\t" * 4 + "frame.origin.y = 0.0;\n" +
                     "\t" * 4 + "frame.origin.x = 0.0;\n" +
                     "\t" * 4 + "break;\n\t" + "\t" * 2 +  "/*EAOPortrait*/",
                     "case #{configName}:\n" +
                     "\t" * 3 + "image.image = [UIImage imageNamed:@\"#{nanoSite}_logo_transparent.png\"];\n" +
                     "\t" * 3 + "image.frame = CGRectMake(image.frame.origin.x, image.frame.origin.y, 0.0, 0.0);\n" +
                     "\t" * 3 + "image.center = self.view.center;\n" +
                     "\t" * 3 + "text.image = [UIImage imageNamed:@\"detailViewText#{nanoSite.capitalize}.png\"];\n" +
                     "\t" * 3 + "break;\n" + "\t" * 2 + "/*EAOiPadLogo*/" ] },

   # Add code to our bash script that switches between iOS apps
   { 'file'       => 'dozuki.sh',
     'pattern'    => /#EAOPlist/,
     'ingredient' => "elif [ \"$1\" == \"#{nanoSite}\" ]; then\n" +
                     "\s" * 3 + "echo \"#{nanoSite.capitalize}\"\n" +
                     "\s" * 3 + "cp Graphics/Sites/#{nanoSite.capitalize}/*png .\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/com.ifixit.ifixit/com.dozuki.#{nanoSite}/g' iFixit-Info.plist\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/iFixit/#{appName}/g' iFixit-Info.plist\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/>ifixit</>#{nanoSite}</g' iFixit-Info.plist\n" +
                     "\s" * 3 + "sed -i '.bak' -e 's/\\[Config currentConfig\\].dozuki = NO;/\\[Config currentConfig\\].dozuki = YES;/' Classes/iFixitAppDelegate.m\n" +
                     "#EAOPlist"}
]

####
# Search for the correct place to insert new code.
# recipe['file'] => Pointing to path of file to search through
# recipe['pattern'] => Regex Pattern to search for to insert new code
# recipe['ingredient'] => New code to insert
####
def bakeRecipe(recipe)
   if File.file?(recipe['file'])
      fileContents = File.read(recipe['file'])

      # If pattern is an array, we have multiple inserts to do
      if recipe['pattern'].is_a? Array
         for i in 0..(recipe['pattern'].count - 1)
            fileContents.sub!(recipe['pattern'][i], recipe['ingredient'][i])
         end
      else
         fileContents.sub!(recipe['pattern'], recipe['ingredient'])
      end

      File.write(recipe['file'], fileContents)
   else
      puts "Could not find file: #{recipe['file']}, unplug the oven!"
      exit
   end
end

# Let's bake!
recipes.each do |recipe|
   bakeRecipe(recipe)
end

puts "\nRemember: Make sure you have the image assets in the correct path and " +
     "they are named accordingly:\n" +
     "Graphics/Sites/#{nanoSite.capitalize}/\n" +
     "logo_#{nanoSite}.png\n" +
     "titleImage#{nanoSite.capitalize}.png\n" +
     "#{nanoSite}_logo_transparent.png\n" +
     "detailViewText#{nanoSite.capitalize}.png"
