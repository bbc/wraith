module.exports = function (config) {

  // config
  var systemArgs        = config.systemArgs,
      javascriptEnabled = config.javascriptEnabled;

  // modules
  var page   = require('webpage').create(),
      helper = require('./_helper.js')(systemArgs[2]);

  // command line arguments
  var url = systemArgs[1],
      dimensions = helper.dimensions,
      image_name = systemArgs[3],
      selector   = systemArgs[4],
      globalBeforeCaptureJS = systemArgs[5],
      pathBeforeCaptureJS = systemArgs[6],
      dimensionsProcessed = 0,
      currentDimensions;

  globalBeforeCaptureJS = globalBeforeCaptureJS === 'false' ? false : globalBeforeCaptureJS;
  pathBeforeCaptureJS   = pathBeforeCaptureJS === 'false' ? false : pathBeforeCaptureJS;

  var current_requests = 0;
  var last_request_timeout;
  var final_timeout;

  if (helper.takingMultipleScreenshots(dimensions)) {
    currentDimensions = dimensions[0];
    image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
  }
  else {
    currentDimensions = dimensions;
  }

  page.viewportSize = { width: currentDimensions.viewportWidth, height: currentDimensions.viewportHeight};
  page.settings = { loadImages: true, javascriptEnabled: javascriptEnabled };

  // If you want to use additional phantomjs commands, place them here
  page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.17';

  page.onResourceRequested = function(req) {
    current_requests += 1;
  };

  page.onResourceReceived = function(res) {
    if (res.stage === 'end') {
      current_requests -= 1;
      debounced_render();
    }
  };

  page.open(url, function(status) {
    if (status !== 'success') {
      console.log('Error with page ' + url);
      phantom.exit();
    }
  });

  function runSetupJavaScriptThenCaptureImage() {
    if (globalBeforeCaptureJS) {
      require(globalBeforeCaptureJS)(page);
    }
    if (pathBeforeCaptureJS) {
      require(pathBeforeCaptureJS)(page);
    }
    captureImage();
  }

  function captureImage() {

    console.log('Snapping ' + url + ' at: ' + currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight);
    page.clipRect = {
      top: 0,
      left: 0,
      height: currentDimensions.viewportHeight,
      width: currentDimensions.viewportWidth
    };
    page.render(image_name);

    dimensionsProcessed++;
    if (helper.takingMultipleScreenshots(dimensions) && dimensionsProcessed < dimensions.length) {
      currentDimensions = dimensions[dimensionsProcessed];
      image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
      setTimeout(captureImage, 1000);
    }
    else {
      phantom.exit();
    }
  }

  function debounced_render() {
    clearTimeout(last_request_timeout);
    clearTimeout(final_timeout);

    // If there's no more ongoing resource requests, wait for 1 second before
    // rendering, just in case the page kicks off another request
    if (current_requests < 1) {
      clearTimeout(final_timeout);
      last_request_timeout = setTimeout(runSetupJavaScriptThenCaptureImage, 1000);
    }

    // Sometimes, straggling requests never make it back, in which
    // case, timeout after 5 seconds and render the page anyway
    final_timeout = setTimeout(runSetupJavaScriptThenCaptureImage, 5000);
  }

}