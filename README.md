<p align="center">
  <img src="https://raw.githubusercontent.com/BBC-News/wraith/master/assets/wraith-logo.png">
</p>

<p align="center">
  <a href="http://travis-ci.org/BBC-News/wraith" target="_blank"><img src="https://secure.travis-ci.org/BBC-News/wraith.png?branch=master"></a>
  <a href="https://rubygems.org/gems/wraith" target="_blank"><img src="https://img.shields.io/gem/v/wraith.svg"></a>
  <a href="https://codeclimate.com/github/BBC-News/wraith" target="_blank"><img src="https://codeclimate.com/github/BBC-News/wraith.png"></a>
</p>

<p align="center">
  Wraith is a screenshot comparison tool, created by developers at BBC News.
  <br>
  <a href="http://bbc-news.github.io/wraith/index.html" target="_blank">Documentation</a> • <a href="http://github.com/bbc-news/wraith" target="_blank">Source</a> • <a href="http://responsivenews.co.uk" target="_blank">Responsive News Website</a>
</p>

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

[ImageMagick](http://www.imagemagick.org/) is required to compare the screenshots.

Wraith also requires at least one of these headless browsers:

* [PhantomJS](http://phantomjs.org)
* [CasperJS](http://casperjs.org/) (which can be used to target specific selectors)
* [SlimerJS](http://slimerjs.org)

## Contributing

If you want to add functionality to this project, pull requests are welcome.

 * Fork a branch based off BBC-News/wraith:master and do all of your changes within it.
 * Make commits of logical units and describe them properly.
 * Check for unnecessary whitespace with git diff --check before committing.
 * If possible, submit tests to your patch / new feature so it can be tested easily.
 * Assure nothing is broken by running all the tests (`bundle exec rspec`).
 * Please ensure that it complies with coding standards.
 * When writing the title of your Pull Request, if you have to pause to add an 'and' anywhere in the title - it should be two pull requests.

**Please raise any issues with this project as a GitHub issue.**

## License

Wraith is available to everyone under the terms of the Apache 2.0 open source license. [Take a look at Wraith's LICENSE file](https://github.com/BBC-News/wraith/blob/master/LICENSE).

## Credits

 * [Dave Blooman](https://twitter.com/dblooman)
 * [John Cleveley](https://twitter.com/jcleveley)
 * [Simon Thulbourn](https://twitter.com/sthulb)
 * [Chris Ashton](https://twitter.com/chrisbashton)

## Selenium-Wraith

Anyone interested in integrating selenium capability with Wraith should check out [Selenium-Wraith](https://github.com/andrewccadman/wraith-selenium) (by Andrew Tekle-Cadman of Future Visible), which was forked from BBC's Wraith on 16/04/14 and adds the following capabilities:

1. Selenium integration, both running locally on a desktop or on a selenium grid
2. Browser to browser screenshot comparison
3. Page component-based comparison
