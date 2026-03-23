*** Settings ***
Documentation      Keywords for the common Setup for all test suites


Library    String
Library    AppiumLibrary
Library    ../../../libraries/AppiumKeywords.py
Variables  ../../../variables/test_variables.py

*** Keywords ***

Wait Until Element Is Enabled And Visible
    [Documentation]    Verifies that page contains given element and that the element is both visible and enabled.
    [Arguments]  ${locator}  ${timeout}=${THIRTY_SECONDS_DELAY}
    Wait Until Page Contains Element   ${locator}   ${timeout}
    Wait Until Keyword Succeeds    5x    ${TEN_SECONDS_DELAY}    Element Should Be Enabled    ${locator}
    Wait Until Element Is Visible      ${locator}   ${timeout}


Press Element
    [Documentation]    Checks that page contains given element, the element is visible and enabled.
    ...                Then finally clicks the element.
    ...                Each check before the actual click uses the given timeout.
    [Arguments]  ${locator}  ${timeout}=${THIRTY_SECONDS_DELAY}
    Wait Until Element Is Enabled And Visible    ${locator}   ${timeout}
    Click Element    ${locator}

Press Element If Present
    [Documentation]    Clicks an element only if it appears within the given timeout to handle ads popups.
    [Arguments]  ${locator}  ${timeout}=${FIVE_SECONDS_DELAY}
    ${is_present}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${locator}    ${timeout}
    Run Keyword If    ${is_present}    Press Element    ${locator}    ${timeout}

Check That Page Contains Element
    [Documentation]    Verifies that page contains given element.
    ...                If element is not found within time limit, the keyword will fail.
    [Arguments]  ${element}  ${timeout}=${THIRTY_SECONDS_DELAY}
    Wait Until Page Contains Element   ${element}   ${timeout}

Check That Page Contains Text
    [Documentation]    Verifies that page contains given text anywhere on the page.
    ...                If the text is not found within time limit, the keyword will fail.
    [Arguments]  ${text}  ${timeout}=${THIRTY_SECONDS_DELAY}
    Wait Until Page Contains           ${text}      ${timeout}

Fill Text To
    [Documentation]    Inputs the given text to given element using Input Text Appium keyword.
    [Arguments]  ${field}  ${text}  ${timeout}=${THIRTY_SECONDS_DELAY}
    Check That Page Contains Element   ${field}  ${timeout}
    Input Text  ${field}  ${text}

Swipe Until Element Is Found By Direction
    [Documentation]    Swipes the screen to given direction until element is found.
    ...                Each swipe is nearly the size of the entire screen.
    [Arguments]    ${element}  ${max_swipes}  ${direction}

    ${start_x}=    Set Variable If
    ...           '${direction}'=='down'     50
    ...           '${direction}'=='left'     90
    ...           '${direction}'=='right'    10
    ...           '${direction}'=='up'       50

    ${end_x}=    Set Variable If
    ...           '${direction}'=='down'     50
    ...           '${direction}'=='left'     10
    ...           '${direction}'=='right'    90
    ...           '${direction}'=='up'       50

    ${start_y}=    Set Variable If
    ...           '${direction}'=='down'     20
    ...           '${direction}'=='left'     50
    ...           '${direction}'=='right'    50
    ...           '${direction}'=='up'       90

    ${end_y}=    Set Variable If
    ...           '${direction}'=='down'     90
    ...           '${direction}'=='left'     50
    ...           '${direction}'=='right'    50
    ...           '${direction}'=='up'       10

    Swipe Until Element Is Found By Percentages  ${element}  ${max_swipes}  ${start_x}  ${start_y}  ${end_x}  ${end_y}

Check That Page Contains Element And Is Enabled
    [Documentation]    Verifies that page contains given element and that the element is enabled.
    [Arguments]  ${element}  ${timeout}=${THIRTY_SECONDS_DELAY}
    Check That Page Contains Element   ${element}   ${timeout}
    Wait Until Keyword Succeeds    5x    ${TEN_SECONDS_DELAY}    Element Should Be Enabled    ${element}
    Wait Until Element Is Visible      ${element}   ${timeout}

Swipe Until Element Is Found By Percentages
    [Documentation]    Swipes the screen until the given element is found
    [Arguments]    ${element}  ${max_swipes}  ${start_x}  ${start_y}  ${end_x}  ${end_y}
    ${max_swipes}=    Convert To Integer    ${max_swipes}

    # Trying to find element by swiping.
    FOR    ${i}    IN RANGE    ${max_swipes}
        ${status}  ${value}=     Run Keyword And Ignore Error
        ...                      Check That Page Contains Element And Is Enabled  ${element}  ${TEN_SECONDS_DELAY}
        IF    '${status}'=='PASS'
            RETURN
        ELSE
            Swipe By Percent Custom    ${start_x}  ${start_y}  ${end_x}  ${end_y}
            Sleep   1s    # To allow swipe to end before we check for element's existance
        END
    END
    Fail    Element ${element} not found with Max Swipes
