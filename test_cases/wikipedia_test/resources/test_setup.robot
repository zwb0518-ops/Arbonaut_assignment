*** Settings ***
Library    AppiumLibrary
Library    ../../../libraries/AppiumKeywords.py

Resource    ./wikipedia_home.robot

Variables  ../../../variables/test_variables.py
Variables  ../../../variables/pixel9.py

*** Keywords ***
Custom Test Setup
    Open App
    # Resetting idle timeout to default just in case that this is not reset automatically between tests by default.
    Run Keyword    Set Android Idle Timeout    5000
    Home Screen Is Visible


Open App
    Run Keyword if   '${app}'!='${None}'    Open Android App
    Run Keyword if   '${app}'=='${None}'    Open Installed Android App

Open Installed Android App
    Open Application    ${appium_url}
    ...                 appActivity=${appActivity}
    ...                 appPackage=${appPackage}
    ...                 automationName=${automationName}
    ...                 deviceName=${deviceName}
    ...                 noSign=${noSign}
    ...                 platformName=${platformName}
    ...                 platformVersion=${platformVersion}
    ...                 systemPort=${systemPort}
    ...                 udid=${udid}
    ...                 unicodeKeyboard=${unicodeKeyboard}
    ...                 adbExecTimeout=40000
    ...                 newCommandTimeout=${newCommandTimeout}
    ...                 chromedriverExecutable=${chromedriver_path}

Open Android App
    Open Application    ${appium_url}
    ...                 app=${app}
    ...                 appActivity=${appActivity}
    ...                 appPackage=${appPackage}
    ...                 automationName=${automationName}
    ...                 deviceName=${deviceName}
    ...                 noSign=${noSign}
    ...                 platformName=${platformName}
    ...                 platformVersion=${platformVersion}
    ...                 systemPort=${systemPort}
    ...                 udid=${udid}
    ...                 unicodeKeyboard=${unicodeKeyboard}
    ...                 adbExecTimeout=40000  
    ...                 newCommandTimeout=${newCommandTimeout}
    ...                 chromedriverExecutable=${chromedriver_path}

Open And Clear Chrome History
    Open Application    ${appium_url}
    ...                 alias=mobileChrome
    ...                 browserName=Chrome
    ...                 automationName=${automationName}
    ...                 deviceName=${deviceName}
    ...                 platformName=${platformName}
    ...                 platformVersion=${platformVersion}
    ...                 systemPort=${systemPort}
    ...                 udid=${udid}
    ...                 adbExecTimeout=150000
    ...                 chromedriverExecutable=${chromedriver_path}
    Clear Browser History
    Close Application