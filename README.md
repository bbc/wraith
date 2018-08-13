![Wraith logo](https://raw.githubusercontent.com/BBC-News/wraith/master/assets/wraith-logo.png)

[![build status](https://secure.travis-ci.org/BBC-News/wraith.png?branch=master)](http://travis-ci.org/BBC-News/wraith)
[![rubygems version](https://img.shields.io/gem/v/wraith.svg)](https://rubygems.org/gems/wraith)
[![codeclimate report](https://codeclimate.com/github/BBC-News/wraith.png)](https://codeclimate.com/github/BBC-News/wraith)

Wraith is a screenshot comparison tool, created by developers at BBC News.

[Documentation](http://bbc-news.github.io/wraith/) • [Source](http://github.com/bbc-news/wraith) • [Responsive News Website](http://responsivenews.co.uk)

## What is it?

Wraith uses a headless browser to create screenshots of webpages on different environments (or at different moments in time) and then creates a diff of the two images; the affected areas are highlighted in blue.

![Photo of BBC News with a diff](http://bbc-news.github.io/wraith/img/wraith.png)

## Documentation

For instructions on how to install, set up and use Wraith and all of its features, [visit the Wraith documentation](http://bbc-news.github.io/wraith/index.html).

A brief overview of how Wraith works is provided below.

## Wraith modes

There are several ways in which Wraith can be used:

1. Comparison of 2 domains (`wraith capture`). There are also some specialist options within this mode:
    * Spidering 2 domains for changes (`wraith capture` when no `paths` property is provided in the configuration file)
    * Running several comparisons at once (`wraith multi_capture`)
2. Comparing the same domain over time (`wraith history`, then `wraith latest`)

Whichever mode you decide to run Wraith in, the process it follows is generally the same:

* takes screenshots of your webpages
* runs a comparison task across them
* outputs a diff PNG file comparing the two images, and a data.txt file which contains the percentage of pixels that have changed
* packages all of this up into a gallery.html, ready for you to view
* if any screenshot's diff is above the threshold you specified in your configuration file, the task exits with a system error code (useful for CI)
* the failed screenshot will also be highlighted in the gallery

## Requirements

[ImageMagick](http://www.imagemagick.org/) is required to compare the screenshots and crop images.

Wraith also requires at least one of these headless browsers:

* [PhantomJS](http://phantomjs.org)
* [CasperJS](http://casperjs.org/) (which can be used to target specific selectors)
* [SlimerJS](http://slimerjs.org)
* [Chrome](https://askubuntu.com/questions/510056/how-to-install-google-chrome/510063) (Currently using Selenium WebDriver + Chromedriver for Chrome; Can target specific selectors)

## Contributing

Please read [how to contribute to Wraith](https://github.com/BBC-News/wraith/blob/master/.github/CONTRIBUTING.md).

## License

Wraith is available to everyone under the terms of the Apache 2.0 open source license. [Take a look at Wraith's LICENSE file](https://github.com/BBC-News/wraith/blob/master/LICENSE).

## Credits

 * [Dave Blooman](https://twitter.com/dblooman)
 * [John Cleveley](https://twitter.com/jcleveley)
 * [Simon Thulbourn](https://twitter.com/sthulb)
 * [Chris Ashton](https://twitter.com/chrisbashton)

## Selenium-Wraith

Anyone interested in integrating selenium capability with Wraith should check out [Selenium-Wraith](https://github.com/mathew-hall/wraith-selenium) (maintained by Mathew Hall), which was forked from BBC's Wraith on 16/04/14 and adds the following capabilities:

1. Selenium integration, both running locally on a desktop or on a selenium grid
2. Browser to browser screenshot comparison
3. Page component-based comparison
