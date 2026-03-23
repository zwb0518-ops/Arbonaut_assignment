*** Settings ***
Library    OperatingSystem

Resource    ./appium_keywords.robot

Variables   ../../../variables/test_variables.py


*** Variables ***
${ARTICLE_TITLE}                           //*[@resource-id='pcs-edit-section-title-description']


*** Keywords ***    

Verify Opened Article Details
    Check That Page Contains Element    ${ARTICLE_TITLE}    ${THIRTY_SECONDS_DELAY}
    ${article_title}=    Get Text    ${ARTICLE_TITLE}
    Should Be Equal    ${article_title}    Country in northern Europe
    Check That Page Contains Text    This article is about the country. For other uses, see   ${THIRTY_SECONDS_DELAY}