@echo off

SET SLIMERJSLAUNCHER=%SLIMERJSLAUNCHER%
REM % ~ d[rive] p[ath] 0[script name] is the absolute path to this bat file, without quotes, always.
REM ~ strips quotes from the argument
SET SLIMERDIR=%~dp0
REM %* is every argument passed to this script.
SET __SLIMER_ARGS=%*
SET LISTVAR=

SET CREATETEMP=Y

REM check arguments
FOR %%A IN (%*) DO (

    if ["%%A"]==["/?"] (
        call :helpMessage
        pause
        exit 0
    )
    if /I ["%%A"]==["--help"] (
        call :helpMessage
        pause
        exit 0
    )
    if /I ["%%A"]==["-h"] (
        call :helpMessage
        pause
        exit 0
    )
    if /I ["%%A"]==["-reset-profile"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["-profile"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["-p"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["-createprofile"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["-profilemanager"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["--reset-profile"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["--profile"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["--p"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["--createprofile"] (
        SET CREATETEMP=
    )
    if /I ["%%A"]==["--profilemanager"] (
        SET CREATETEMP=
    )
)

if not exist %SLIMERJSLAUNCHER% (
    if exist "%SLIMERDIR%\xulrunner\xulrunner.exe" (
        SET SLIMERJSLAUNCHER="%SLIMERDIR%\xulrunner\xulrunner.exe"
    )
)
if not exist %SLIMERJSLAUNCHER% (
    call :findFirefox
)
if not exist %SLIMERJSLAUNCHER% (
    echo SLIMERJSLAUNCHER environment variable is missing or the path is invalid.
    echo Set it with the path to Firefox or xulrunner.
    echo The current value of SLIMERJSLAUNCHER is: %SLIMERJSLAUNCHER%
    REM %% escapes the percent sign so it displays literally
    echo SET SLIMERJSLAUNCHER="%%programfiles%%\Mozilla Firefox\firefox.exe"
    echo SET SLIMERJSLAUNCHER="%%programfiles%%\XULRunner\xulrunner.exe"
    pause
    exit 1
)


SETLOCAL EnableDelayedExpansion

REM store environment variable into LISTVAR for SlimerJS
FOR /F "usebackq delims==" %%i IN (`set`) DO set LISTVAR=!LISTVAR!,%%i

REM let's create a temporary dir for the profile, if needed
if ["%CREATETEMP%"]==[""] (
   SET PROFILEDIR=
   SET PROFILE=-purgecaches
   goto callexec
)
:createdirname
SET PROFILEDIR=%Temp%\slimerjs-!Random!!Random!!Random!
IF EXIST "%PROFILEDIR%" (
    GOTO createdirname
)
mkdir %PROFILEDIR%

SET PROFILE=-profile %PROFILEDIR%

:callexec
REM Firefox console output is done to NUL or something like that.
REM So we have to redirect output to a file and then output this file
REM FIXME: This solution is not optimal, since we cannot see messages at realtime
REM FIXME: an other solution to redirect directly to the console ?
set TMPFILE=%TMP%\slimer-output-%RANDOM%.tmp

%SLIMERJSLAUNCHER% -app "%SLIMERDIR%application.ini" %PROFILE% -no-remote -envs "%LISTVAR%" %__SLIMER_ARGS% >%TMPFILE% 2>&1

if ["%CREATETEMP%"]==["Y"] (
     rmdir /S /Q %PROFILEDIR%
)
TYPE %TMPFILE%
DEL %TMPFILE%
ENDLOCAL

goto :eof


:helpMessage
REM in echo statements the escape character is ^
REM escape < > | and &
REM the character % is escaped by doubling it to %%
REM if delayed variable expansion is turned on then the character ! needs to be escaped as ^^!
	echo   Available options are:
	echo.
REM    echo   --config=^<filename^>                Load the given configuration file
REM    echo                                      (JSON formated)
REM    echo   --debug=[yes^|no]                   Prints additional warning and debug message
REM    echo                                      (default is no)
REM    echo   --disk-cache=[yes^|no]              Enables disk cache (default is no).
    echo   --help or -h                       Show this help
REM    echo   --ignore-ssl-errors=[yes^|no]       Ignores SSL errors (default is no).
    echo   --load-images=[yes^|no]            Loads all inlined images (default is yes)
    echo   --local-storage-quota=^<number^>   Sets the maximum size of the offline
    echo                                      local storage (in KB)
REM    echo   --local-to-remote-url-access=[yes^|no] Allows local content to access remote
REM    echo                                         URL (default is no)
REM    echo   --max-disk-cache-size=^<number^>     Limits the size of the disk cache (in KB)
REM    echo   --output-encoding=^<enc^>            Sets the encoding for the terminal output
REM    echo                                      (default is 'utf8')
REM    echo   --remote-debugger-port=^<number^>    Starts the script in a debug harness and
REM    echo                                      listens on the specified port
REM    echo   --remote-debugger-autorun=[yes^|no] Runs the script in the debugger immediately
REM    echo                                      (default is no)
REM    echo   --proxy=^<proxy url^>                Sets the proxy server
REM    echo   --proxy-auth=^<username:password^>   Provides authentication information for the
REM    echo                                      proxy
REM    echo   --proxy-type=[http^|socks5^|none]    Specifies the proxy type (default is http)
REM    echo   --script-encoding=^<enc^>            Sets the encoding used for the starting
REM    echo                                      script (default is utf8)
REM    echo   --web-security=[yes^|no]            Enables web security (default is yes)
REM    echo   --ssl-protocol=[SSLv3^|SSLv2^|TLSv1^|any]  Sets the SSL protocol
    echo   --version or v                     Prints out SlimerJS version
REM    echo   --webdriver or --wd or -w          Starts in 'Remote WebDriver mode' (embedded
REM    echo                                      GhostDriver) '127.0.0.1:8910'
REM    echo   --webdriver=[^<IP^>:]^<PORT^>          Starts in 'Remote WebDriver mode' in the
REM    echo                                      specified network interface
REM    echo   --webdriver-logfile=^<file^>         File where to write the WebDriver's Log
REM    echo                                      (default 'none') (NOTE: needs '--webdriver')
REM    echo   --webdriver-loglevel=[ERROR^|WARN^|INFO^|DEBUG^|] WebDriver Logging Level
REM    echo                                  (default is 'INFO') (NOTE: needs '--webdriver')
REM    echo   --webdriver-selenium-grid-hub=^<url^> URL to the Selenium Grid HUB (default is
REM    echo                                       'none') (NOTE: needs '--webdriver')
    echo   --error-log-file=<file>            Log all javascript errors in a file
    echo   -jsconsole                         Open a window to view all javascript errors
    echo                                        during the execution
    echo.
    echo *** About profiles: see details of these Mozilla options at
    echo https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options#User_Profile
    echo.
    echo   --createprofile name               Create a new profile and exit
    echo   -P name                            Use the specified profile to execute the script
    echo   -profile path                      Use the profile stored in the specified
    echo                                      directory, to execute the script
    echo By default, SlimerJS use a temporary profile
    echo.
goto :eof


:findFirefox
if exist "%programfiles%\Mozilla Firefox\firefox.exe" (
    SET SLIMERJSLAUNCHER="%programfiles%\Mozilla Firefox\firefox.exe"
)
if exist "%programfiles% (x86)\Mozilla Firefox\firefox.exe" (
    SET SLIMERJSLAUNCHER="%programfiles% (x86)\Mozilla Firefox\firefox.exe"
)
echo SLIMERJSLAUNCHER is set to %SLIMERJSLAUNCHER%
goto :eof
