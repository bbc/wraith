var system = require('system');
var page = require('webpage').create();
var fs = require('fs');

if (system.args.length === 3) {
    console.log('Usage: snap.js <some URL> <view port width> <target image name>');
    phantom.exit();
}

var url = system.args[1];
var image_name = system.args[3];
var view_port_width = system.args[2];

page.viewportSize = { width: view_port_width, height: 1500};
page.settings = { loadImages: true, javascriptEnabled: true };

//if you want to use additional phantomjs commands, place them here
page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.17',

//You can place custom headers here, example below.
// page.customHeaders = {

//      'X-Candy-OVERRIDE': 'https://api.live.bbc.co.uk/'
 
//  };

page.open(url, function(status) {
  if (status === 'success') {
    window.setTimeout(function() {
      console.log('Snapping ' + url + ' at width ' + view_port_width);
      page.render(image_name);
      phantom.exit();
    }, 3000);
  } else {
    console.log('Error with page ' + url);
    phantom.exit();
  }
});
