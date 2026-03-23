*** Settings ***
Library    AppiumLibrary

*** Keywords ***
Custom Suite Teardown
    Run Keyword And Ignore Error    Close All Applications

Custom Test Teardown
    Run Keyword If Test Failed    Capture Page Screenshot
    ${source}=    Get Source
    Log    ${source}

    Close Application