*** Settings ***
Library     AppiumLibrary

Resource    ../resources/appium_keywords.robot


*** Keywords ***
Custom Suite Setup
    Set Library Search Order    AppiumLibrary    appium_keywords
    Set Appium Timeout    10s