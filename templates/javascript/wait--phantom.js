// ######################################################
// This is an example module provided by Wraith.
// Feel free to amend for your own requirements.
// ######################################################
module.exports = function (phantom, ready) {
    // make Wraith wait a bit longer before taking the screenshot
    setTimeout(ready, 2000); // you MUST call the ready() callback for Wraith to continue
}