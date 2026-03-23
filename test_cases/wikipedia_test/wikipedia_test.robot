*** Settings ***
Library     AppiumLibrary
Library     ../../libraries/AppiumKeywords.py


Resource    ./resources/wikipedia_home.robot
Resource    ./resources/wikipedia_search.robot
Resource    ./resources/wikipedia_article.robot
Resource    ./resources/appium_keywords.robot
Resource    ./resources/suite_setup.robot
Resource    ./resources/test_setup.robot
Resource    ./resources/test_teardown.robot

Variables    ../../variables/test_variables.py


Suite Setup      Custom Suite Setup
Suite Teardown   Custom Suite Teardown
Test Setup       Custom Test Setup
Test Teardown    Custom Test Teardown

Test Timeout    45 minutes
Force Tags      all


*** Test Cases ***

WT-001 Launch Wikipedia And Show Home Screen
    [Documentation]    Launch the Wikipedia app and verify that the landing screen becomes visible.
    [Tags]    WT-001
    Verify Wiki Games Card Is Visible

WT-002 Search Valid Query And Verify Results
    [Documentation]    Positive scenario: search for a valid topic and verify the search results.
    [Tags]    WT-002
    Open Search 
    Search For Query And Verify Results    ${VALID_QUERY}

WT-003 Verify Article Content Is Loaded
    [Documentation]    Positive scenario: validate article title/content visibility and basic scroll behavior.
    [Tags]    WT-003
    Open Search
    Search For Query And Verify Results    ${VALID_QUERY}
    Open Search Result
    Verify Opened Article Details

WT-004 Search Invalid Query Shows No Results
    [Documentation]    Negative scenario: a non-existent term should show no-results state.
    [Tags]    WT-004
    Open Search
    Search Invalid Query Should Show No Results    ${INVALID_QUERY}    ${THIRTY_SECONDS_DELAY}

WT-005 Search Special Characters Shows No Results
    [Documentation]    Negative scenario: special-character search input should show no-results state.
    [Tags]    WT-005
    Open Search
    Search Invalid Query Should Show No Results    ${SPECIAL_CHAR_QUERY}    ${THIRTY_SECONDS_DELAY}

WT-006 Long Search Input Is Handled
    [Documentation]    Edge scenario: long search input should not crash or leave the app unusable.
    [Tags]    WT-006
    Open Search
    Long Search Input Should Be Handled Safely    ${LONG_QUERY}    ${THIRTY_SECONDS_DELAY}
