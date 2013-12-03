var fs = require('fs'),
    gm = require('gm'),
    baseImagePath = '',
    configPath = '',
    resources = [];

function parseArguments() {
   if (process.argv[2]) {
      configPath = process.argv[2];
   } else {
      console.log('Config file not given. Please supply path to JSON ' +
       'config file. \nFor example: node imageResize.js AppIconResources.json');
      process.exit(1);
   }
}

// Load up the JSON config file
function loadConfigFile() {
   var config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

   if (!config) {
      throw new Error('json file not found');
   }

   baseImagePath = config.baseImagePath;
   resources = config.resources;
}

// Generate image sizes
function generateImages() {

   for (var i = 0; i < resources.length; i++) {
      var resource = resources[i];

      gm(baseImagePath).resize(resource.dimensions.width, resource.dimensions.height)
      .quality(100).write(resource.name + '.' + resource.extension, function(err) {
         if (err) {
            throw new Error(err);
         } else {
            console.log('Image generated successfully');
         }
      });
   }
}

parseArguments();
loadConfigFile();
generateImages();
