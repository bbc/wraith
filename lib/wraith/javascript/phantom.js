// modules
var system = require('system'),
    page   = require('webpage').create(),
    helper = require('./_helper.js')(system.args[2]);

// command line arguments
var url        = system.args[1],
    dimensions = helper.dimensions,
    image_name = system.args[3],
    selector   = system.args[4],
    globalBeforeCaptureJS = system.args[5],
    pathBeforeCaptureJS = system.args[6],
    platform = system.args[7],
    dimensionsProcessed = 0,
    currentDimensions;

globalBeforeCaptureJS = globalBeforeCaptureJS === 'false' ? false : globalBeforeCaptureJS;
pathBeforeCaptureJS   = pathBeforeCaptureJS === 'false' ? false : pathBeforeCaptureJS;

var current_requests = 0;
var last_request_timeout;
var final_timeout;

var setupJavaScriptRan = false;

var waitTime = 300,
    maxWait = 5000,
    beenLoadingFor = 0;

if (helper.takingMultipleScreenshots(dimensions)) {
  currentDimensions = dimensions[0];
  image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
}
else {
  currentDimensions = dimensions;
}

page.settings = { loadImages: true, javascriptEnabled: true};
if (platform === 'mobile') {
  // Set as Safari browser, ref: https://developers.whatismybrowser.com/useragents/parse/288310-safari-ios-iphone-webkit
  page.settings.userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_1 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/14A403 Safari/602.1";
} else {
  page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.17';
}

page.onError = function(msg, trace) {
  // suppress JS errors from Wraith output
  // http://stackoverflow.com/a/19538646
};

page.onResourceRequested = function(req) {
  current_requests += 1;
};

page.onResourceReceived = function(res) {
  if (res.stage === 'end') {
    current_requests -= 1;
  }
};

console.log('Loading ' + url + ' at dimensions: ' + currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight);
page.viewportSize = { width: currentDimensions.viewportWidth, height: currentDimensions.viewportHeight};

page.open(url, function(status) {
  if (status !== 'success') {
    console.log('Error with page ' + url);
    phantom.exit();
  }

  setTimeout(checkStatusOfAssets, waitTime);
});


function checkStatusOfAssets() {
  if (current_requests >= 1) {

    if (beenLoadingFor > maxWait) {
      // sometimes not all assets will download in an acceptable time - continue anyway.
      markPageAsLoaded();
    }
    else {
      beenLoadingFor += waitTime;
      setTimeout(checkStatusOfAssets, waitTime);
    }
  }
  else {
    markPageAsLoaded();
  }
}

function markPageAsLoaded() {
  if (!setupJavaScriptRan) {
    runSetupJavaScriptThen(captureImage);
  }
  else {
    captureImage();
  }
}


function runSetupJavaScriptThen(callback) {
  setupJavaScriptRan = true;
  if (globalBeforeCaptureJS && pathBeforeCaptureJS) {
    require(globalBeforeCaptureJS)(page, function thenExecuteOtherBeforeCaptureFile() {
      require(pathBeforeCaptureJS)(page, callback);
    });
  }
  else if (globalBeforeCaptureJS) {
    require(globalBeforeCaptureJS)(page, callback);
  }
  else if (pathBeforeCaptureJS) {
    require(pathBeforeCaptureJS)(page, callback);
  }
  else {
    callback();
  }
}

function captureImage() {
  takeScreenshot();

  dimensionsProcessed++;
  if (helper.takingMultipleScreenshots(dimensions) && dimensionsProcessed < dimensions.length) {
    currentDimensions = dimensions[dimensionsProcessed];
    image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
    setTimeout(resizeAndCaptureImage, waitTime);
  }
  else {
    exit_phantom();
  }
}

function resizeAndCaptureImage() {
  console.log('Resizing ' + url + ' to: ' + currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight);
  page.viewportSize = { width: currentDimensions.viewportWidth, height: currentDimensions.viewportHeight};
  setTimeout(captureImage, 5000); // give page time to re-render properly
}

function takeScreenshot() {
  console.log('Snapping ' + url + ' at: ' + currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight);
  page.clipRect = {
    top: 0,
    left: 0,
    height: currentDimensions.viewportHeight,
    width: currentDimensions.viewportWidth
  };
  page.render(image_name);
}

function exit_phantom() {
  // prevent CI from failing from 'Unsafe JavaScript attempt to access frame with URL about:blank from frame with URL' errors. See https://github.com/n1k0/casperjs/issues/1068
  setTimeout(function(){
    phantom.exit();
  }, 30);
}
