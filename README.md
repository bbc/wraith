# Wraith

## How it works
Wraith uses PhantomJS or SlimmerJS to take screenshots of two chosen environments, such as a sandbox or localhost and another environment, such as a live site.  Once the two environments have been captured, imagemagick will output a diff image with highlighted changes to show any CSS changes.  This allows for regression testing of front end changes across multiple sites using multiple resolutions.  
Below is an example of 2 BBC News pages compared with the differences coloured blue

![Example](https://github.com/BBC-News/wraith/raw/master/320_diff.png)

## Requirements
You will need PhantomJS or SlimmerJS and Imagemagick
<pre><code>PhantomJS
brew install phantomjs
gem install phantomjs
[PhantomJS Source](http://phantomjs.org/)
</pre></code>

<pre><code>Imagemagick
brew install imagemagick
port install ImageMagick
sudo apt-get install imagemagick
[Imagemagick binaries](http://www.imagemagick.org/script/binary-releases.php)
</pre></code>

<pre><code>[SlimmerJS](http://slimerjs.org/)
If you have firefox installed, all files needed are already in repo
</pre></code>

## Which browser to use
We built this tool for use with PhantomJS, it is fast and headless, making testing quicker.  SlimmerJS is Geeko based browser, whereas PhantomJS is a webkit browser, this making Slimmer a Firefox type browser and Phantom a Safari type browser.  Slimmer may be more suited to your needs, or perhaps you want to be as thorough as possible in testing, either way, the support is available by uncommenting an option in the Rakefile.  By default, the browser used will be Phantom as it is headless out of the box, Slimmer is not.  

## Installation
On a Mac, I recommend home-brew for installation, it is much easier and quicker to get up and running.  Install both imagemagick and phantomJS and you'll be ready to go.  

For Ubuntu, you can use apt-get for imagemagick and Rubygems for phantomJS. For imagemagick on other Linux, download your binary package from the ImageMagick website and follow installation instructions.  You can also download phantomJS as a stand alone package from the website.

SlimmerJS is included, but you must also have an installation of Firefox to use the included lightweight Slimmer files, otherwise you will need to download the SlimmerJS standalone edition.  If you have a copy of Firefox installed, you may have to enter the following command into terminal in order to enable SlimmerJS.

<pre><code>Linux : export SLIMERJSLAUNCHER=/usr/bin/firefox
OSX : export SLIMERJSLAUNCHER=/Applications/Firefox.app/Contents/MacOS/firefox</pre></code>


## Configuration

### Snap.js
Wraith has several options that you can configure, these are set in the config.yaml file and snap.js.  As Wraith uses PhantomJS or SlimmerJS, you can refer to the API to use any command when taking screenshots.  Javascript is on by default, but can be disabled by setting false on page.settings in snap.js.  Both browsers has the ability to use custom page headers, I have included an example header in snap JS for our API override.

###Config.yaml
The main configuration is in config.yaml, this is where the domains, folder labels, screen widths and paths are set.  The domains going to be different for most, but for most it will probably be a local instance, localhost, sandbox and a live environment.  The folder labels will set what the name of the folders are in the shots directory.  Screen widths can be any pixel width, the height is actually set in snap.js, but is set to 5000px, so should cater for most length web pages.  The more widths you set, the longer the process will take.  The paths are the URL's of the pages you want to snap, they must be the same for both domains.

### Shots folder
Once the Rakefile is run, it will remove any previous images in the shots folder, this is because images will become stale after time.  We think this is the best approach, rather than use a baseline image over many months, live environments should be considered the baseline.

## Running the test
When you have configured your image test, run <pre><code>rake</pre></code> in terminal.

## Output
Each pages screenshots will save to an individual folder per domain, so all pages and domains will be separate for review.  Each diff will be appended with the same file name convention as the captured images.  

To aid in speed, there is also a text file called data.txt that will show the file names and the pixel difference.  This means for every changed pixel it will increment in one.  This helps to identify the big issues first, allowing for more targeted reviewing of the diff images.

## License
Wraith is available to everyone under the terms of the Apache 2.0 open source licence. Take a look at the LICENSE file in the code.