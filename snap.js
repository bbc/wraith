var system = require('system');
var page = require('webpage').create();
var fs = require('fs');

if (system.args.length === 2) {
    console.log('Usage: snap.js <some URL> <target image name>');
    phantom.exit();
}

var url = system.args[1];
var image_name = system.args[2];

page.customHeaders = {
    'X-Candy-OVERRIDE': 'https://api.live.bbc.co.uk/'
};

page.open(url, function(status) {
  if (status === 'success') {
    window.setTimeout(function() {
      console.log('Snapping ' + url);
      page.render(image_name);
      phantom.exit();
    }, 3000);
  } else {
    console.log('Error with page ' + url);
    phantom.exit();
  }
});


