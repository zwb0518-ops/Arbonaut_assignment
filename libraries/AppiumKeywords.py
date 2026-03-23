import appium
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
import time

@keyword(name="Set Android Idle Timeout")
def set_android_idle_timeout(idle_timeout):

    idle_timeout = int(idle_timeout)
    appiumLib = BuiltIn().get_library_instance('AppiumLibrary')
    driver = appiumLib._current_application()  
    driver.update_settings({"waitForIdleTimeout": idle_timeout})

@keyword(name="Clear Browser History")
def clear_browser_history():

    appiumLib = BuiltIn().get_library_instance('AppiumLibrary')
    driver = appiumLib._current_application()  
    driver.delete_all_cookies()

@keyword(name='Swipe By Percent Custom') 
def swipe_by_percent_custom(x_start_percent, y_start_percent, x_end_percent, y_end_percent, duration=1000):
    
    x_start_percent = int(x_start_percent)
    y_start_percent = int(y_start_percent)
    x_end_percent = int(x_end_percent)
    y_end_percent = int(y_end_percent)

    appiumLib = BuiltIn().get_library_instance('AppiumLibrary')
    driver = appiumLib._current_application()

    window_size = driver.get_window_size()
    width = window_size["width"]
    height = window_size["height"]

    x_start = int(width   * x_start_percent / 100.0)
    y_start = int(height  * y_start_percent / 100.0)
    x_end   = int(width  * x_end_percent   / 100.0)
    y_end   = int(height  * y_end_percent   / 100.0)

    driver.swipe(x_start, y_start, x_end, y_end, duration)