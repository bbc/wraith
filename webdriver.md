Webdriver on devices
======

In order to use devices with Wraith, you need the drivers and the Android SDK

```
bundle install  
brew install android-sdk

```

Use the following commands on android, make sure to enable USB debugging and to allow connections, this will appear on the device as a prompt.


    adb devices  
    
This will show you the device ID

    adb -s "deviceID" -e install -r android-server-2.xxxxx.apk    

link to [apk](http://code.google.com/p/selenium/downloads/list) 
  
    adb -s "deviceID" forward tcp:8080 tcp:8080    

port forward device

Run webdriver command

    rake webdriver