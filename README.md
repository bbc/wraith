# Wraith

[![Build Status](https://secure.travis-ci.org/BBC-News/wraith.png?branch=master)](http://travis-ci.org/BBC-News/wraith)
[![Code Climate](https://codeclimate.com/github/BBC-News/wraith.png)](https://codeclimate.com/github/BBC-News/wraith)

 * Website: http://responsivenews.co.uk
 * Source: http://github.com/bbc-news/wraith

Wraith is a screenshot comparison tool, created by developers at BBC News.


## What is it?

Wraith uses either [PhantomJS](http://phantomjs.org), [CasperJS](http://casperjs.org/) or
[SlimerJS](http://slimerjs.org) to create screen-shots of webpages on different environments
and then creates a diff of the two images, the affected areas are highlighted in
blue

![Photo of BBC News with a
diff](http://bbc-news.github.io/wraith/img/wraith.png)


## Requirements

Imagemagick and PhantomJS are required to use Wraith, install via your favourite package manager. You can also use SlimerJS and CasperJS, CasperJS can be used to target specific selectors. To read our detailed instructions for setup and install, as well as example configs, visit [wraith docs](http://bbc-news.github.io/wraith/index.html)

```sh
brew install phantomjs  
brew install imagemagick
```

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

This assumes that your snap.js and config.yaml are in the folders that were created on setup. To run the setup, create a folder and inside run

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
  wraith setup_casper                       # creates config folder and default config for casper
  wraith setup_folders [config_name]        # create folders for images
```

## Output

After each screenshot is captured, the compare task will run, this will output a diff.png and a data.txt.  The data.txt for each file will show the number of pixels that have changed.  There is a main data.txt which is in the root of the output folder that will combine all of these values to easier view all the pixel changes.

## Gallery

A gallery is available to view each of the images and the respective diff images located in the shots folder once all the images have been compared.

## CasperJS

There is an example [component config file](https://github.com/BBC-News/wraith/blob/master/configs/component.yaml) which indicates how to target a specific selector on a page.  Pass in a label for the shot, path and selector.  This will be handed to CasperJS and will only screenshot that component on the page.  This is faster way to verify smaller changes to specific components during development.  You must install [CasperJS](http://casperjs.org/) to use.

For a quick setup for CasperJS, you can run :

```sh
wraith setup_casper
```

## History usage

In Wraith 2.0 we introduced a new way for using Wraith in development and testing, historical shots.  Rather than capture 2 domains, you capture 1 domain, probably your local copy of the latest code, then later on after development is in progress, run Wraith again to compare.  This makes working against an isolated dev environment much easier as you wont need an internet connection.  

The usage is different in that you need 1 domain in your config and you will need to set a historical shots folder.  You will need to specify a `history_dir` in addition to the `directory` key in your `config.yml` file. An example of this can be found in the [`history.yaml`](https://github.com/BBC-News/wraith/blob/31406956bfc465d087f1d40304630e18dc0f857e/configs/history.yaml#L9-L11) file of the `configs` directory of this repository.  The way this works is that shots are captured as normal with the history command below.  This will create 2 folders with the labels you have specified in the config file, for example, shots and shots_history.  The original shots will be copied into your 'history' folder, then copied back into the shots folder once you have run your latest job.  This workflow will essentially mean your history folder is your baseline, being copied back into the shots folder every time you run the 'latest command'

```sh
wraith history history.yaml
```
After some development, run the latest command
```sh
wraith latest history.yaml
```
You will now be able to run the latest command over and over without having to do clear up.

## Docker
At BBC, we use Docker and AWS in our workflow.  The Dockerfile is in the repo, but you can pull from the registry here`docker pull bbcnews/wraith`.  There is no quick way to get up and running with OSX and no way to use it on Windows.  For a CI environment, it has a really good use case though.  To run, specify your workspace and the command you want.  If you want to use the Ruby AWS-SDK gem to upload your images to s3, it is built into the container.  I recommend writing a simple ruby script that runs once you have completed a Wraith run.

```sh
docker run -d bbcnews/wraith -w /wraith -v path/to/dir:/wraith capture configs/config.yaml
```

## Changelog - updated 2014-10-20
We have combined CasperJS with Wraith to enable component screen shots and comparison.  This allows for developers to check only a small part of a page for regressions allowing for quicker and smaller screenshots.


Notice : We have deprecated the ability to not use labels on URLs in config files and have Wraith create them for you.  Ensure that you update your config with labels before running again.

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
