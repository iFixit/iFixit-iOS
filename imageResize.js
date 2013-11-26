var fs = require('fs'),
    gm = require('gm'),
    resources = require('AppIconResources.js').resources,
    baseIconPath = 'icon1024.png', // Path for base icon image
    baseIconImage = gm(baseIconPath);

// Generate image sizes
for (var i = 0; i < resources.length; i++) {
   var resource = resources[i];

   baseIconImage.resize(resource.dimensions.width, resource.dimensions.height)
   .noProfile().write((resource.name + '.' + resource.extension), function(err) {
      if (err) {
         throw new Error(err);
      } else {
         console.log('Image generated successfully');
      }
   });
}

