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


page.viewportSize = { width: view_port_width, height: 9000};
page.settings = { loadImages: true, javascriptEnabled: true };

//if you want to see video clips in the story, uncomment the setting below.
//page.settings.userAgent = 'Chrome',

//if using test or int, uncomment the header below as mashery will allow you to point to live data
page.customHeaders = {

     'X-Candy-OVERRIDE': 'https://api.live.bbc.co.uk/'
 
 };

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
