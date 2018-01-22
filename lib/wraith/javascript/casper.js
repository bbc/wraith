// modules
var system = require('system'),
    casper = require('casper').create(),
    helper = requireRelative('_helper.js')(casper.cli.get(1));

// command line arguments
var url = casper.cli.get(0),
    dimensions = helper.dimensions,
    image_name = casper.cli.get(2),
    selector = casper.cli.get(3),
    globalBeforeCaptureJS = casper.cli.get(4),
    pathBeforeCaptureJS = casper.cli.get(5),
    platform = casper.cli.get(6),
    dimensionsProcessed = 0,
    currentDimensions;

// functions
function requireRelative(file) {
  // PhantomJS will automatically `require` relatively, but CasperJS needs some extra help. Hence this function.
  // 'templates/javascript/casper.js' -> 'templates/javascript'
  var currentFilePath = system.args[3].split('/');
  currentFilePath.pop();
  var fs = require('fs');
  currentFilePath = fs.absolute(currentFilePath.join('/'));
  return require(currentFilePath + '/' + file);
}
function snap() {
  console.log('Snapping ' + url + ' at: ' + currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight);

  if (!selector) {
    this.capture(image_name);
  }
  else {
    this.captureSelector(image_name, selector);
  }

  dimensionsProcessed++;
  if (helper.takingMultipleScreenshots(dimensions) && dimensionsProcessed < dimensions.length) {
    currentDimensions = dimensions[dimensionsProcessed];
    image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
    casper.viewport(currentDimensions.viewportWidth, currentDimensions.viewportHeight);
    casper.wait(300, function then () {
      snap.bind(this)();
    });
  }
}

if (helper.takingMultipleScreenshots(dimensions)) {
  currentDimensions = dimensions[0];
  image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
}
else {
  currentDimensions = dimensions;
}

if (platform === 'mobile') {
  // Set as Safari browser, ref: https://developers.whatismybrowser.com/useragents/parse/288310-safari-ios-iphone-webkit
  casper.userAgent("Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_1 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/14A403 Safari/602.1");
}

// Casper can now do its magic
casper.start();
casper.open(url);
casper.viewport(currentDimensions.viewportWidth, currentDimensions.viewportHeight);
casper.then(function() {
  var self = this;
  if (globalBeforeCaptureJS && pathBeforeCaptureJS) {
    require(globalBeforeCaptureJS)(self, function thenExecuteOtherBeforeCaptureFile() {
      require(pathBeforeCaptureJS)(self, captureImage);
    });
  }
  else if (globalBeforeCaptureJS) {
    require(globalBeforeCaptureJS)(self, captureImage);
  }
  else if (pathBeforeCaptureJS) {
    require(pathBeforeCaptureJS)(self, captureImage);
  }
  else {
    captureImage();
  }
});

function captureImage() {
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
}

casper.run();
