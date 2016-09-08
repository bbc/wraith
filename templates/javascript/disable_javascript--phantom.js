// ######################################################
// This is an example module provided by Wraith.
// Feel free to amend for your own requirements.
// ######################################################
module.exports = function (phantom, ready, url) {
    // disable JavaScript
    phantom.settings.javascriptEnabled = false;

    // reload the page without JS enabled
    phantom.open(phantom.url, function () {
        setTimeout(ready, 5000);
    });
}
