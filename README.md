# Snappysnaps
===========

## Requirements
<pre><code>PhantomJS - brew install phantomjs
imagemagick - brew install imagemagick
</pre></code>
## How it works
SnappySnaps uses PhantomJS to take screenshots of two chosen environments, such as a sandbox and live.  Once the two environments have been captured, imagemagick will output a diff image to show any CSS changes.  This allows for regression testing of front end changes across multiple sites using multiple resolutions.  

## Configuration

### Snap.js
SnappySnaps has several options that you can configure, these are set in the rake file and snap.js.  As SnappySnaps uses PhantomJS, you can refer to the API to use any command when taking screenshots.  Javascript is on by default, but can be disabled by setting false on page.settings in snap.js.  Snap.js also includes a X-Candy override for Stage API, this allows for comparison of live data between stage and live by default.  Environments can be set in the Rakefile.
### Rake
The Rakefile sets the base domain and the compare domain, these have several options, int, test, stage, live and sandboxs.  Sandbox, stage and live can access the live API, whereas int and test will access mashery and use that API.  You will need to configure the API header in snap.js in order to ensure the correct API is being used.  Any domain can be entered if do desired, e.g comparing someone else's sandbox.  Simply create a new domain in the Rakefile and post the URL of the sandbox, there is an example in the Rakefile.
The resolution is fixed at 9000px long in order to ensure no boundary issues in the compare.  Any number of widths can be entered, though this will increase time to capture images.  If 9000 is too big, this can be changed in snap.js


## Running the test
When you have configured your image test, run "rake" in terminal.

## Output
Each pages screenshots will save to an individual folder per domain, so all pages and domains will be separate for review.  Each diff will be appended with the same file name convention as the captured images.  
