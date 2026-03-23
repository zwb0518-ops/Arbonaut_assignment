*** Settings ***
Library    OperatingSystem

Resource    ./appium_keywords.robot
Resource    ./wikipedia_home.robot

Variables   ../../../variables/test_variables.py


*** Variables ***
${SEARCH_INPUT}                            id=org.wikipedia:id/search_src_text
${SEARCH_RESULT_ITEM1}                     android=new UiSelector().text("Country in northern Europe")
${SEARCH_RESULT_ITEM2}                     android=new UiSelector().text("Finland\u2013Russia relations")


*** Keywords ***

Search For Query And Verify Results
    [Arguments]  ${query}    ${timeout}=${THIRTY_SECONDS_DELAY}
    ${max_swipes}=    Convert To Integer    5
    Fill Text To    ${SEARCH_INPUT}    ${query}
    Check That Page Contains Text    ${query}    ${timeout}
    Check That Page Contains Element    ${SEARCH_RESULT_ITEM1}    ${timeout}
    Check That Page Contains Text    Men's association football team    ${timeout}
    Swipe Until Element Is Found By Direction    ${SEARCH_RESULT_ITEM2}    ${max_swipes}    up
    Swipe Until Element Is Found By Direction    ${SEARCH_RESULT_ITEM1}    ${max_swipes}    down

Open Search Result
    Press Element    ${SEARCH_RESULT_ITEM1}
    Dismiss Start Screen Popup If Present    ${FIVE_SECONDS_DELAY}

Search Invalid Query Should Show No Results
    [Arguments]     ${query}     ${timeout}=${THIRTY_SECONDS_DELAY}
    Fill Text To    ${SEARCH_INPUT}    ${query}
    Check That Page Contains Text    No results    ${timeout}

Long Search Input Should Be Handled Safely
    [Arguments]     ${query}     ${timeout}=${THIRTY_SECONDS_DELAY}
    Fill Text To    ${SEARCH_INPUT}    ${query}
    Check That Page Contains Text    Search request is longer than the maximum allowed length.    ${timeout}