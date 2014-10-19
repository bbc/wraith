var system = require('system');
var page = require('webpage').create();
var fs = require('fs');
var casper = require("casper").create();

var url = casper.cli.get(0);
var view_port_width = casper.cli.get(1);
var image_name = casper.cli.get(2);
var selector = casper.cli.get(3);

casper.options.waitTimeout = 1000;
casper.start(url, function() {
  this.viewport(view_port_width, 1500);
  this.captureSelector(image_name, selector);
  console.log('Snapping ' + url + ' at width ' + view_port_width);
});

casper.run();
