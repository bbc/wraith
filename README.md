# Snappysnaps

## Requirements
<pre><code>PhantomJS - brew install phantomjs
imagemagick - brew install imagemagick
</pre></code>
## How it works
SnappySnaps uses PhantomJS to take screenshots of two chosen environments, such as a sandbox or localhost and another environment.  Once the two environments have been captured, imagemagick will output a diff image to show any CSS changes.  This allows for regression testing of front end changes across multiple sites using multiple resolutions.  
### Shots folder
Once the Rakefile is run, it will remove any previous images in the shots folder, this is because images will become stale after time.  We think this is the best approach, rather than use a baseline image over many months, live environments should be considered the baseline.

## Configuration

### Snap.js
SnappySnaps has several options that you can configure, these are set in the config.yaml file and snap.js.  As SnappySnaps uses PhantomJS, you can refer to the API to use any command when taking screenshots.  Javascript is on by default, but can be disabled by setting false on page.settings in snap.js.  PhantomJS has the ability to use custom page headers, I have included an example header in snap JS for our API override.

##Config.yaml
The main configuration is in config.yaml, this is where the domains, folder labels, screen widths and paths are set.  The domains going to be different for most, but for most it will probably be a local instance, localhost, sandbox and a live environment.  The folder labels will set what the name of the folders are in the shots directory.  Screen widths can be any pixel width, the height is actually set in snap.js, but is set to 5000px, so should cater for most length web pages.  The more widths you set, the longer the process will take.  The paths are the URL's of the pages you want to snap, they must be the same for both domains.

## Running the test
When you have configured your image test, run "rake" in terminal.

## Output
Each pages screenshots will save to an individual folder per domain, so all pages and domains will be separate for review.  Each diff will be appended with the same file name convention as the captured images.  
