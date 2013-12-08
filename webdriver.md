Webdriver on devices
======

In order to use devices with Wraith, you need to [download the drivers and the Android SDK](http://developer.android.com/sdk/index.html)

On a Mac, install via homebrew
```
brew install android-sdk
```

Use the following commands on android, make sure to enable USB debugging and to allow connections, this will appear on the device as a prompt.

1.Discover device ID

    adb devices

2.Download app, then install webdriver [app](http://code.google.com/p/selenium/downloads/list) via command line 

    adb -s "deviceID" -e install -r android-server-2.xxxxx.apk    

3.Port forward device

    adb -s "deviceID" forward tcp:8080 tcp:8080    

4.Set both devices in config to android

5.Edit wraith.rb and comment out window sizing in web_runner task

6.Run webdriver command

    rake webdriver
