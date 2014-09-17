# Wraith

[![Build Status](https://secure.travis-ci.org/BBC-News/wraith.png?branch=master)](http://travis-ci.org/BBC-News/wraith)
[![Code Climate](https://codeclimate.com/github/BBC-News/wraith.png)](https://codeclimate.com/github/BBC-News/wraith)

 * Website: http://responsivenews.co.uk
 * Source: http://github.com/bbc-news/wraith

Wraith is a screenshot comparison tool, created by developers at BBC News.


## What is it?

Wraith uses either [PhantomJS](http://phantomjs.org) or
[SlimerJS](http://slimerjs.org) to create screen-shots of different environments
and then creates a diff of the two images, the affected areas are highlighted in
blue

![Photo of BBC News with a
diff](http://bbc-news.github.io/wraith/img/320_diff.png)


## Requirements

Imagemagick and PhantomJS are required to use Wraith, install via your favourite package manager.  To read our detailed instructions for setup and install, as well as example configs, visit [wraith docs](http://bbc-news.github.io/wraith/index.html)

## Installation

Open terminal and run

    gem install wraith

You can then run the following to create a template snap.js and config file:

    wraith setup

Alternatively you can clone the repo.

    git clone https://github.com/BBC-News/wraith
    cd wraith
    bundle install

## Using Wraith
You can type `wraith` into terminal to bring up the list of commands, but the one to start Wraith is

```sh
wraith capture config_name
```

This assumes that your snap.js and config.yaml are in the folders that were created on setup. To run the setup, create a directory and inside run

```sh
wraith setup
```

### CLI

There are other commands also available, these all expect a config_name to be passed as an option. Wraith will look for the config file at `configs/[config_name].yaml`.  

```sh
  wraith capture [config_name]              # A full Wraith job
  wraith compare_images [config_name]       # compares images to generate diffs
  wraith crop_images [config_name]          # crops images to the same height
  wraith generate_gallery [config_name]     # create page for viewing images
  wraith generate_thumbnails [config_name]  # create thumbnails for gallery
  wraith history [config_name]              # Setup a baseline set of shots
  wraith latest [config_name]               # Capture new shots to compare with baseline
  wraith multi_capture [filelist]           # A Batch of Wraith Jobs
  wraith reset_shots [config_name]          # removes all the files in the shots folder
  wraith save_images [config_name]          # captures screenshots
  wraith setup                              # creates config folder and default config
  wraith setup_folders [config_name]        # create folders for images
```

## Output

After each screenshot is captured, the compare task will run, this will output a diff.png and a data.txt.  The data.txt for each file will show the number of pixels that have changed.  There is a main data.txt which is in the root of the output folder that will combine all of these values to easier view all the pixel changes.

## Gallery

A gallery is available to view each of the images and the respective diff images located in the shots folder once all the images have been compared.

## History usage

In Wraith 1.4, we introduced a new way for using Wraith in development and testing, historical shots.  Rather than capture 2 domains, you capture 1 domain, probably your local copy of the latest code, then later on after development is in progress, run Wraith again to compare.  This makes working against an isolated dev environment much easier as you wont need an internet connection.  

The usage is different in that you need 2 config files with unique labels for the domains, examples can be found in the configs repo on Github.  You will also need to set a new directory in your 'latest shots' config as all the original shots taken will be copied into this folder.  Finally, setting the name of the original shots folder in the latest config will be needed to compare against.

```sh
wraith history history_shots.yaml
```
After some development, run the latest command
```sh
wraith latest latest_shots.yaml
```
You will now be able to run the latest command over and over without having to do clear up.

## Contributing

If you want to add functionality to this project, pull requests are welcome.

 * Create a branch based off master and do all of your changes with in it.
 * If you have to pause to add a 'and' anywhere in the title, it should be two pull requests.
 * Make commits of logical units and describe them properly
 * Check for unnecessary whitespace with git diff --check before committing.
 * If possible, submit tests to your patch / new feature so it can be tested easily.
 * Assure nothing is broken by running all the test
 * Please ensure that it complies with coding standards.

**Please raise any issues with this project as a GitHub issue.**

## Changelog - updated 2014-05-14
We have updated Wraith some bug fixes and more importantly, parallel support.  This will now enable use of all your CPU cores for faster Wraith runs.  There is error handling in place to ensure if an image fails to capture, it will try again 5 times, if that fails, it will put an holding image in place.  This should solve all the issues with images not capturing and failing to crop/compare.  Big thanks to [Matt Senior](https://github.com/mattsenior) for doing the work.

## License

Wraith is available to everyone under the terms of the Apache 2.0 open source license.
Take a look at the LICENSE file in the code.

## Credits

 * [Dave Blooman](http://twitter.com/dblooman)
 * [John Cleveley](http://twitter.com/jcleveley)
 * [Simon Thulbourn](http://twitter.com/sthulbourn)

## Selenium-Wraith

Anyone interested in integrating selenium capability with Wraith should check out
Selenium-Wraith by Andrew Tekle-Cadman of Future Visible.

Selenium-Wraith was forked from the BBC repo on 16/04/14 and adds the following capabilities to Wraith

1. Selenium integration, both running locally on a desktop or on a selenium grid
2. Browser to browser screenshot comparison
3. Page component-based comparison

You can check out Andrew's Project on GitHub here:

https://github.com/andrewccadman/wraith-selenium
