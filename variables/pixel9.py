from pathlib import Path

appium_port = 4753  # Must be unique for parallel testing. Never use value 2724!
appium_url = "http://localhost:{0}".format(str(appium_port))

app = "../org.wikipedia_50572.apk"
appActivity = ".DefaultIcon"
AppPackage = "org.wikipedia"
automationName = "uiAutomator2"
bundleId = None
chromedriver_path = None
deviceName = "Pixel_9"
is_emulator = True
is_simulator = False
noSign = True
platformName = "Android"
platformVersion = "16.0"
systemPort = 8203
udid = "emulator-5554"
unicodeKeyboard = True
wdaLocalPort = None
xcodeOrgID = None
xcodeSigningId = None
newCommandTimeout = 240
snapshotMaxDepth = 90
