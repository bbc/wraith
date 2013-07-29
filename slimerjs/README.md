# SlimerJS

SlimerJS is a scriptable browser. It allows you to manipulate a web page
with a Javascript script: opening a webpage, clicking on links, modifying the content...
It is useful to do functional tests, page automaton, network monitoring, screen capture etc.

Go to [http://slimerjs.org] to know more and to access to the documentation


# Install

- Install [Firefox](http://getfirefox.com),
  or [XulRunner](http://ftp.mozilla.org/pub/mozilla.org/xulrunner/releases/19.0.2/runtimes/) (both version 18 or more)
- [Download the latest package](http://download.slimerjs.org/slimerjs-0.5RC1.zip) or
  [the source code of SlimerJS](https://github.com/laurentj/slimerjs/archive/master.zip) if you didn't it yet
- On windows, a .bat is provided, but you can also launch slimer from a "true" console. In this case, you should install
  [Cygwin](http://www.cygwin.com/) or any other unix environment to launch slimerjs. Note
  that some issues are known with Cygwin.
- SlimerJS needs to know where Firefox or XulRunner is stored. It tries to discover
  itself the path but can fail. You must then set the environment variable
  SLIMERJSLAUNCHER, which should contain the full path to the firefox binary:
   - On linux: ```export SLIMERJSLAUNCHER=/usr/bin/firefox```
   - on Windows: ```SET SLIMERJSLAUNCHER="c:\Program Files\Mozilla Firefox\firefox.exe```
   - On windows with cygwin : ```export SLIMERJSLAUNCHER="/cygdrive/c/program files/mozilla firefox/firefox.exe"```
   - On MacOS: ```export SLIMERJSLAUNCHER=/Applications/Firefox.app/Contents/MacOS/firefox```
- You can of course set this variable in your .bashrc, .profile or in the computer
   properties on Windows.

# Launching SlimerJS

Open a terminal and go to the directory of SlimerJS (src/ if you downloaded the source code). Then launch:

```
    ./slimerjs myscript.js
```

In the Windows commands console:

```
    slimerjs.bat myscript.js
```


The given script myscripts.js is then executed in a window. If your script is
short, you probably won't see this window.

You can for example launch some tests if you execute SlimerJS from the source code:

```
    ./slimerjs ../test/initial-tests.js
```

# Launching a headless SlimerJS

There is a tool called xvfb, available on Linux and MacOS. It allows to launch
any "graphical" programs without the need of X-Windows environment. Windows of
the application won't be shown and will be drawn only in memory.

Install it from your prefered repository (```sudo apt-get install xvfb```
with debian/ubuntu).

Then launch SlimerJS like this:

```
    xvfb-run ./slimerjs myscript.js
```

You won't see any windows. If you have any problems with xvfb, see its
documentation.

# Getting help

- Ask your questions on the dedicated [mailing list](https://groups.google.com/forum/#!forum/slimerjs).
- Discuss with us on IRC: channel #slimerjs on irc.mozilla.org.
- Read the faq [on the website](http://slimerjs.org/faq.html).
- Read [the documentation](http://docs.slimerjs.org/current/)
