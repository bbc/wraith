module.exports = function (hooks) {

    var setupJavaScriptRan    = false,
        globalBeforeCaptureJS = hooks.config_level_js === 'false' ? false : hooks.config_level_js,
        pathBeforeCaptureJS   = hooks.path_level_js   === 'false' ? false : hooks.path_level_js,
        callback              = hooks.on_completion;

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

    runSetupJavaScriptThen(callback);
}