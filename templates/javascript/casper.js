var system = require('system');
var page = require('webpage').create();
var fs = require('fs');
var casper = require("casper").create();

var url = casper.cli.get(0);
var view_port_width = casper.cli.get(1);
var image_name = casper.cli.get(2);
var selector = casper.cli.get(3);

casper.start(url, function() {
  this.viewport(view_port_width, 1500).then(function(){
    this.wait(2000, function() {
      if (selector == undefined) {
        this.capture(image_name);
      }
      else {
        this.captureSelector(image_name, selector);
      }
      console.log('Snapping ' + url + ' at width ' + view_port_width);
    });
  });
});

casper.run();
