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

To read our detailed instructions for setup and install, as well as example configs, visit [wraith docs](http://bbc-news.github.io/wraith/index.html)

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

This assumes that your snap.js and config.yaml are in the folders that were created on setup. There are other commands also available, these all expect a config_name to be passed as an option. Wraith will look for the config file at `configs/[config_name].yaml`.

```sh
  wraith capture config_name             # A full Wraith job
  wraith compare_images config_name      # compares images to generate diffs
  wraith crop_images config_name         # crops images to the same height
  wraith folders config_name             # create folders for images
  wraith generate_gallery config_name    # create page for viewing images
  wraith generate_thumbnails config_name # create thumbnails for gallery
  wraith reset_shots config_name         # removes all the files in the shots folder
  wraith save_images config_name         # captures screenshots
  wraith setup                           # creates config folder and default config
```

On Windows before running the rake command you will need to make a small edit to the wraith.rb file.
Locate lines 60 and 70 and switch the commenting as described.


### Using as a gem

Install the gem as described above.
Then:

```ruby
require 'wraith'

def run_wraith
	@config = ('config')
	folders = Wraith::FolderManager.new(@config)
    folders.clear_shots_folder
    folders.create_folders
    spider = Wraith::Spidering.new(@config)
    spider.check_for_paths
    @save_images = Wraith::SaveImages.new(@config)
    @save_images.save_images
    crop = Wraith::CropImages.new(@config)
    crop.crop_images
    compare = Wraith::CompareImages.new(@config)
    compare.compare_images
    thumbs = Wraith::Thumbnails.new(@config)
    thumbs.generate_thumbnails
    gallery = Wraith::GalleryGenerator.new(@save_images.directory)
    gallery.generate_gallery
end
```


## Output

After each screenshot is captured, the compare task will run, this will output a diff.png and a data.txt.  The data.txt for each file will show the number of pixels that have changed.  There is a main data.txt which is in the root of the output folder that will combine all of these values to easier view all the pixel changes.

## Gallery

A gallery is available to view each of the images and the respective diff images located in the shots folder once all the images have been compared.

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

## Changelog - updated 2014-02-09
We have released Wraith as a Ruby Gem!!  There is a new CLI to better interact with Wraith and it's commands.

## License

Wraith is available to everyone under the terms of the Apache 2.0 open source license.
Take a look at the LICENSE file in the code.

## Credits

 * [Dave Blooman](http://twitter.com/dblooman)
 * [John Cleveley](http://twitter.com/jcleveley)
 * [Simon Thulbourn](http://twitter.com/sthulbourn)

