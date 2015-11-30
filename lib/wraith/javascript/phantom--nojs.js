var system = require('system');

// @TODO - make a javascript_disabled property in YAML, and pass via command line
require('./_phantom__common.js')({
  systemArgs:        system.args,
  javascriptEnabled: false
});