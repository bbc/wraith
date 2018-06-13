const DEFAULT_HEIGHT = 1500;
    
module.exports = function (commandLineDimensions) {
    
    commandLineDimensions = '' + commandLineDimensions; // cast to string

    function getWidthAndHeight(dimensions) {
        dimensions = /(\d*)x?((\d*))?/i.exec(dimensions);
        return {
            'viewportWidth':  parseInt(dimensions[1]),
            'viewportHeight': parseInt(dimensions[2] || 0)
        };
    }

    var multipleDimensions = commandLineDimensions.split(','),
        dimensionsToPass;

    if (multipleDimensions.length > 1) {
        dimensionsToPass = multipleDimensions.map(function (cliDimensions) {
            return getWidthAndHeight(cliDimensions);
        });
    }
    else {
        dimensionsToPass = getWidthAndHeight(commandLineDimensions);
    }

    return {
        dimensions: dimensionsToPass,
        takingMultipleScreenshots: function (dimensions) {
          return dimensions.length && dimensions.length > 1;
        },
        replaceImageNameWithDimensions: function (image_name, currentDimensions) {
            // shots/clickable_guide__after_click/MULTI_casperjs_english.png
            // ->
            // shots/clickable_guide__after_click/1024x359_casperjs_english.png
            var dirs = image_name.split('/'),
                filename = dirs[dirs.length - 1],
                filenameParts = filename.split('_'),
                newFilename,
                viewportHeight = (
                  currentDimensions.viewportHeight === 0
                  ? DEFAULT_HEIGHT
                  : currentDimensions.viewportHeight
                );

            filenameParts[0] = currentDimensions.viewportWidth + 'x' + viewportHeight;
            dirs.pop(); // remove MULTI_casperjs_english.png
            newFilename = dirs.join('/') + '/' + filenameParts.join('_');
            return newFilename;
        },
        getViewportSize: function(currentDimensions) {
            return {
                width: currentDimensions.viewportWidth,
                height: (
                    currentDimensions.viewportHeight === 0
                    ? DEFAULT_HEIGHT
                    : currentDimensions.viewportHeight
                )
            };
        }
    }
}