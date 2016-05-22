module.exports = function (page, callback) {

    var current_requests = 0;

    var waitTime = 300,
        maxWait = 5000,
        beenLoadingFor = 0;

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

    function checkStatusOfAssets() {
        if (current_requests >= 1) {
            if (beenLoadingFor > maxWait) {
                // sometimes not all assets will download in an acceptable time - continue anyway.
                callback();
            }
            else {
                beenLoadingFor += waitTime;
                setTimeout(checkStatusOfAssets, waitTime);
            }
        }
        else {
            callback();
        }
    }

    setTimeout(checkStatusOfAssets, waitTime);
}