*** Settings ***
Library    OperatingSystem

Resource    ./appium_keywords.robot

Variables   ../../../variables/test_variables.py


*** Variables ***
${HOME_TITLE}                              id=org.wikipedia:id/main_toolbar_wordmark
${ONBOARDING_SKIP_BUTTON}                  id=org.wikipedia:id/fragment_onboarding_skip_button
${START_SCREEN_POPUP_CLOSE_BUTTON}         id=org.wikipedia:id/closeButton
${HOME_SEARCH_CONTAINER}                   id=org.wikipedia:id/search_container
${HOME_WIKI_GAMES_CARD_HEADER}             id=org.wikipedia:id/viewWikiGamesCardHeader

*** Keywords ***

Dismiss Start Screen Popup If Present
    [Arguments]    ${timeout}=${FIVE_SECONDS_DELAY}
    Press Element If Present    ${START_SCREEN_POPUP_CLOSE_BUTTON}    ${timeout}

Home Screen Is Visible
    Press Element    ${ONBOARDING_SKIP_BUTTON}
    Dismiss Start Screen Popup If Present    ${FIVE_SECONDS_DELAY}
    Check That Page Contains Element   ${HOME_TITLE}   ${THIRTY_SECONDS_DELAY}

Open Search
    Press Element    ${HOME_SEARCH_CONTAINER}

Verify Wiki Games Card Is Visible
    Check That Page Contains Element   ${HOME_WIKI_GAMES_CARD_HEADER}   ${THIRTY_SECONDS_DELAY}    