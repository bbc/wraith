module.exports = function (dimensions) {
    // remove quotes from dimensions string
    dimensions = dimensions.replace(/'/gi, '');

    function getWidthAndHeight(dimensions) {
        dimensions = /(\d*)x?((\d*))?/i.exec(dimensions);
        return {
            'viewportWidth':  parseInt(dimensions[1]),
            'viewportHeight': parseInt(dimensions[2] || 1500)
        };
    }

    var multipleDimensions = dimensions.split(',');

    if (multipleDimensions.length > 1) {
        dimensions = multipleDimensions.map(function (dimensions) {
            return getWidthAndHeight(dimensions);
        });
    }
    else {
        dimensions = getWidthAndHeight(dimensions);
    }

    return {
        dimensions: dimensions,
        takingMultipleScreenshots: function () {
          return dimensions.length && dimensions.length > 1;
        },
        replaceImageNameWithDimensions: function (image_name, currentDimensions) {
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
    }
}