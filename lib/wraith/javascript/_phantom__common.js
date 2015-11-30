module.exports = function (config) {

  // modules
  var page = require('webpage').create();

  // config
  var systemArgs        = config.systemArgs,
      javascriptEnabled = config.javascriptEnabled;

  // command line arguments
  var url = systemArgs[1],
      dimensions = require('./_getDimensions.js')(systemArgs[2]),
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

  if (takingMultipleScreenshots()) {
    currentDimensions = dimensions[0];
    image_name = replaceImageNameWithDimensions(image_name, currentDimensions);
  }
  else {
    currentDimensions = dimensions;
  }

  page.viewportSize = { width: currentDimensions.viewportWidth, height: currentDimensions.viewportHeight};
  page.settings = { loadImages: true, javascriptEnabled: javascriptEnabled };

  // If you want to use additional phantomjs commands, place them here
  page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.17';

  // You can place custom headers here, example below.
  // page.customHeaders = {

  //      'X-Candy-OVERRIDE': 'https://api.live.bbc.co.uk/'

  //  };

  // If you want to set a cookie, just add your details below in the following way.

  // phantom.addCookie({
  //     'name': 'ckns_policy',
  //     'value': '111',
  //     'domain': '.bbc.co.uk'
  // });
  // phantom.addCookie({
  //     'name': 'locserv',
  //     'value': '1#l1#i=6691484:n=Oxford+Circus:h=e@w1#i=8:p=London@d1#1=l:2=e:3=e:4=2@n1#r=40',
  //     'domain': '.bbc.co.uk'
  // });

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

  function takingMultipleScreenshots() {
    return dimensions.length && dimensions.length > 1;
  }

  function replaceImageNameWithDimensions(image_name, currentDimensions) {
    // shots/clickable_guide__after_click/MULTI_casperjs_english.png
    // ->
    // shots/clickable_guide__after_click/1024x359_casperjs_english.png
    var dirs = image_name.split('/'),
        filename = dirs[dirs.length - 1],
        filenameParts = filename.split('_'),
        newFilename;

    filenameParts[0] = currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight;
    dirs.pop(); // remove MULTI_casperjs_english.png
    newFilename = dirs.join('/') + '/' + filenameParts.join('_');
    return newFilename;
  }

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
    if (takingMultipleScreenshots() && dimensionsProcessed < dimensions.length) {
      currentDimensions = dimensions[dimensionsProcessed];
      image_name = replaceImageNameWithDimensions(image_name, currentDimensions);
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