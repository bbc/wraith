// modules
var system = require('system'),
    page   = require('webpage').create(),
    helper = require('./_helper.js')(system.args[2]);

// command line arguments
var url = system.args[1],
    dimensions = helper.dimensions,
    image_name = system.args[3],
    _selector  = system.args[4],
    globalBeforeCaptureJS = system.args[5],
    pathBeforeCaptureJS   = system.args[6],
    dimensionsProcessed   = 0,
    currentDimensions     = dimensions,
    documentHeight        = 1500;

if (helper.takingMultipleScreenshots(dimensions)) {
    currentDimensions = dimensions[0];
    image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
}

// set up default `page` object
require('./phantom-helpers/default_settings.js')(page, currentDimensions);

// functions
var waitForPageToLoad        = require('./phantom-helpers/wait_for_page_to_load.js'),
    handleBeforeCaptureHooks = require('./phantom-helpers/handle_before_captures.js');

page.open(url, function(status) {
    if (status !== 'success') {
        exit_phantom('Error with page ' + url);
    }
    waitForPageToLoad(page, function markPageAsLoaded() {

        // dynamic height calculation not possible in the following situations:
        // * `resize` mode
        // * non-JavaScript mode
        documentHeight = page.evaluate(function () {
            return document.body.offsetHeight;
        }) || false;

        if (!documentHeight) {
            documentHeight = 1500;
            console.log('Could not dynamically determine document height.');
        }

        handleBeforeCaptureHooks({
            config_level_js: globalBeforeCaptureJS,
            path_level_js: pathBeforeCaptureJS,
            on_completion: captureImage
        });
    });
});

function captureImage() {
    takeScreenshot();

    dimensionsProcessed++;
    if (helper.takingMultipleScreenshots(dimensions) && dimensionsProcessed < dimensions.length) {
        currentDimensions = dimensions[dimensionsProcessed];

        if (currentDimensions.viewportHeight) {
            console.log('Resizing ' + url + ' to: ' + currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight);
        }
        else {
            currentDimensions.viewportHeight = 1500;
            console.log('Resizing ' + url + ' to width: ' + currentDimensions.viewportWidth);
        }

        image_name = helper.replaceImageNameWithDimensions(image_name, currentDimensions);
        resizeAndCaptureImage();
    } else {
        exit_phantom();
    }
}

function resizeAndCaptureImage() {
    console.log('Resizing to: ' + currentDimensions.viewportWidth + 'x' + currentDimensions.viewportHeight);
    page.viewportSize = {
        width:  currentDimensions.viewportWidth,
        height: currentDimensions.viewportHeight
    };
    setTimeout(captureImage, 1500); // give page time to re-render properly
}

function takeScreenshot() {
    console.log('Snapping ' + url + ' at: ' + currentDimensions.viewportWidth + 'x' + documentHeight);
    page.clipRect = {
        top:    0,
        left:   0,
        height: documentHeight,
        width:  currentDimensions.viewportWidth
    };
    page.render(image_name);
}

function exit_phantom(message) {
    if (message) {
        console.log(message);
    }
    // prevent CI from failing from 'Unsafe JavaScript attempt to access frame with URL about:blank from frame with URL' errors. See https://github.com/n1k0/casperjs/issues/1068
    setTimeout(function() {
        phantom.exit();
    }, 30);
}