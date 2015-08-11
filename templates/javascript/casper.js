var system = require('system');
var page = require('webpage').create();
var fs = require('fs');
var casper = require("casper").create();

var url = casper.cli.get(0);
var view_port_width = casper.cli.get(1);
var image_name = casper.cli.get(2);
var selector = casper.cli.get(3);
var globalBeforeCaptureJS = casper.cli.get(4);
var pathBeforeCaptureJS = casper.cli.get(5);

function snap() {
  if (selector == undefined) {
    this.capture(image_name);
  }
  else {
    this.captureSelector(image_name, selector);
  }
  console.log('Snapping ' + url + ' at width ' + view_port_width);
}

casper.start();
casper.open(url);
casper.viewport(view_port_width, 1500);
casper.then(function() {
  if (globalBeforeCaptureJS) {
    require('./' + globalBeforeCaptureJS)(this);
  }
});
casper.then(function() {
  if (pathBeforeCaptureJS) {
    require('./' + pathBeforeCaptureJS)(this);
  }
});
// waits for all images to download before taking screenshots
// (broken images are a big cause of Wraith failures!)
// Credit: http://reff.it/8m3HYP
casper.waitFor(function() {
  return this.evaluate(function() {
    var images = document.getElementsByTagName('img');
    return Array.prototype.every.call(images, function(i) { return i.complete; });
  });
}, function then () {
  snap.bind(this)();
});

casper.run();
