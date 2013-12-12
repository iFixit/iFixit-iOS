var fs = require('fs'),
    gm = require('gm'),
    jobs = [],
    configPath = '';

function parseArguments() {
   if (process.argv[2]) {
      configPath = process.argv[2];
   } else {
      console.log('Config file not given. Please supply path to JSON ' +
       'config file. \nFor example: node imageResize.js AppResources.json');
      process.exit(1);
   }
}

// Load up the JSON config file
function loadConfigFile() {
   if (!(jobs = JSON.parse(fs.readFileSync(configPath, 'utf8')))) {
      throw new Error('json file not found');
   }
}

// Generate image sizes
function generateImages() {
   jobs.forEach(function(job) {
      job.resources.forEach(function(resource) {
         gm(job.baseImagePath).resize(resource.dimensions.width, resource.dimensions.height)
         .quality(100).write(resource.name + '.' + resource.extension, function(err) {
            if (err) {
               throw new Error(err);
            } else {
               console.log('Image generated successfully');
            }
         });
      });
   });
}

parseArguments();
loadConfigFile();
generateImages();
