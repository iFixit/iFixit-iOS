var fs = require('fs'),
    gm = require('gm'),
    baseIconPath = 'icon1024.png',
    baseIconImage = gm(baseIconPath),
    // iOS resource list
    resourceList = [
       // App icons
       { name : 'icon57.png', dimensions  : { width : 57, height : 57 } },
       { name : 'icon114.png', dimensions : { width : 114, height : 114 } },
       { name : 'icon120.png', dimensions : { width : 120, height : 120 } },
       { name : 'icon72.png', dimensions  : { width : 72, height : 72 } },
       { name : 'icon144.png', dimensions : { width : 144, height : 144 } },
       { name : 'icon76.png', dimensions  : { width : 76, height : 76 } },
       { name : 'icon152.png', dimensions : { width : 152, height : 152 } },
       // Spotlight
       { name : 'icon29.png', dimensions  : { width : 29, height : 29 } },
       { name : 'icon58.png', dimensions  : { width : 58, height : 58 } },
       { name : 'icon80.png', dimensions  : { width : 80, height : 80 } },
       { name : 'icon50.png', dimensions  : { width : 50, height : 50 } },
       { name : 'icon100.png', dimensions : { width : 100, height : 100 } },
       { name : 'icon40.png', dimensions  : { width : 40, height : 40 } }
   ];

// Generate image sizes
for (var i = 0; i < resourceList.length; i++) {
   var resource = resourceList[i];

   baseIconImage
   .resize(resource.dimensions.width, resource.dimensions.height)
   .noProfile()
   .write(resource.name, function(err) {
      if (err) {
         console.log('error: ' + err);
         return;
      }
   });
}

console.log('Images generated successfully');
