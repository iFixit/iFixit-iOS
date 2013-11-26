var fs = require('fs'),
    gm = require('gm'),
    baseIconPath = 'icon1024.png', // Path for base icon image
    baseIconImage = gm(baseIconPath),
    resourcePath = 'AppIconResources.json'; // Path where resource info is

// Load up the resource list we wish to make from JSON
var resources = JSON.parse(require('fs').readFileSync(resourcePath,
 'utf8'));

if (!resources) {
   throw new Error('json file not found');
}

// Generate image sizes
for (var i = 0; i < resources.length; i++) {
   var resource = resources[i];

   baseIconImage.resize(resource.dimensions.width, resource.dimensions.height)
   .noProfile().write(resource.name + '.' +  resource.extension, function(err) {
      if (err) {
         throw new Error(err);
      } else {
         console.log('Image generated successfully');
      }
   });
}

