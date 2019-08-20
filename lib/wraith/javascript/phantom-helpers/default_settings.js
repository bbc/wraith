module.exports = function (page, currentDimensions) {
    page.settings = { loadImages: true, javascriptEnabled: true};
    page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.17';

    var height = 1500;

    if (currentDimensions.viewportHeight) {
        height = currentDimensions.viewportHeight;
        console.log('Loading ' + url + ' at dimensions: ' + currentDimensions.viewportWidth + 'x' + height);
    }
    else {
        console.log('Loading ' + url + ' at width: ' + currentDimensions.viewportWidth);
    }

    page.viewportSize = {
        width:  currentDimensions.viewportWidth,
        // what matters is the clipRect, not the viewport height.
        // And if it DOES matter, users can set it explicitly.
        height: height
    };

}