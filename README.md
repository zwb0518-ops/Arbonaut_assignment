# Mobile Test Automation Framework (Robot Framework + Appium)

This repository contains an Android UI automation framework for the Wikipedia app.  
It is built with Robot Framework for readable, business-level test cases and Appium for device automation.

## 1) How to Run

Prerequisites:

- Android Studio installed (required when running tests on an Android Emulator).
- At least one Android Virtual Device (AVD) created in Android Studio, matching your device config in `variables/pixel9.py`.
- Appium available on your machine (for example, installed globally with npm).

### Platform notes ###

* This workspace is mainly used on **macOS**.
* Windows can work, but some scripts may need adjustments (shell and path handling).
* If running on Windows, prefer **WSL2** or **Git Bash** for better compatibility.

Install dependencies:

```bash
pip install -r requirements.txt
```

Run tests with launcher script:

```bash
bash start.sh
```

Use `test_launcher.py` directly (advanced usage):

`start.sh` is a thin wrapper around `libraries/test_launcher.py`. Use the launcher directly when you want custom tags, dry runs, or different startup modes.

Required arguments:

- `--config-file`: path to device/environment config (example: `variables/pixel9.py`)

Common optional arguments:

- `--app-path`: APK file path (absolute or relative). If omitted, the launcher falls back to the `app` variable defined in the config file (e.g., `pixel9.py`). If no app path is found, the test will use the app already installed on device/emulator.
- `--mode`: `start`, `stop`, or `startandstop` (default).
- `--include`: run only tests with given Robot tags.
- `--exclude`: skip tests with given Robot tags.
- `--dryrun`: validate tests without executing Appium actions.

Examples:

```bash
# Full run (same behavior as start.sh)
python3 libraries/test_launcher.py \
  --config-file variables/pixel9.py \
  --app-path org.wikipedia_50572.apk \
  --mode startandstop

# Run only smoke tests
python3 libraries/test_launcher.py \
  --config-file variables/pixel9.py \
  --app-path org.wikipedia_50572.apk \
  --mode startandstop \
  --include smoke

# Start Appium + emulator and keep them running (do not stop at end)
python3 libraries/test_launcher.py \
  --config-file variables/pixel9.py \
  --app-path org.wikipedia_50572.apk \
  --mode start

# Stop existing Appium/emulator session for the config
python3 libraries/test_launcher.py \
  --config-file variables/pixel9.py \
  --mode stop

# Validate suite structure and tags without running tests
python3 libraries/test_launcher.py \
  --config-file variables/pixel9.py \
  --mode startandstop \
  --dryrun
```

Outputs are generated under `reports/` and Robot output files (`output.xml`, `log.html`, `report.html`).

## 2) Framework Structure and Design Decisions

### Directory structure

```text
ab_assignment/
|- test_cases/wikipedia_test/
|  |- wikipedia_test.robot                    # Main suite with test scenarios
|  |- resources/
|     |- wikipedia_home.robot                 # Home screen locators + actions
|     |- wikipedia_search.robot               # Search screen locators + actions
|     |- wikipedia_article.robot              # Article screen locators + validations
|     |- appium_keywords.robot                # Shared interaction/wait/retry keywords
|     |- suite_setup.robot                    # Suite-level setup
|     |- test_setup.robot                     # Per-test app startup and capabilities
|     |- test_teardown.robot                  # Per-test cleanup and diagnostics
|- libraries/
|  |- AppiumKeywords.py                       # Custom Python keywords used by Robot
|  |- test_launcher.py                        # Launcher for Appium + emulator + test run
|- variables/
|  |- test_variables.py                       # Common test data and timeout constants
|  |- pixel9.py                               # Device/environment-specific capabilities
|- start.sh                                   # Entry point for local run
|- requirements.txt                           # Python dependencies
|- reports/                                   # Test and Appium logs
```

### Key design decisions

- Keep tests readable and intent-focused in `wikipedia_test.robot`, while moving UI details into resource files.
- Separate reusable interaction logic (`appium_keywords.robot`) from page/screen-specific logic (`wikipedia_*.robot`).
- Keep device and environment configuration externalized in variable files (`pixel9.py`) so the same suite can run on different devices with minimal changes.
- Use a launcher script (`test_launcher.py`) to standardize startup/shutdown of emulator, Appium, and Robot execution.

## 3) Design Pattern(s) Used and Rationale

### Pattern: Keyword-Driven + Layered Screen Objects (Robot-style Page Object)

The framework uses a layered keyword design that is conceptually similar to Page Object Model:

- Layer 1: Test scenarios in `wikipedia_test.robot` (business flow).
- Layer 2: Screen/resource keywords in `wikipedia_home.robot`, `wikipedia_search.robot`, `wikipedia_article.robot` (UI intent).
- Layer 3: Shared utility keywords in `appium_keywords.robot` (waits, clicks, input, swipe-retry).
- Layer 4: Python custom extensions in `AppiumKeywords.py` for capabilities not cleanly handled directly in Robot keywords.

### Why this pattern

- Improves maintainability: locator or interaction changes are localized.
- Improves readability: test cases remain concise and scenario-focused.
- Improves reusability: common actions and synchronization are centralized.
- Supports scaling: additional screens can be added as new resource files without changing existing test flow design.

## 4) Locator Strategy

Locator strategy follows stability-first priority:

1. `id=` locators as default first choice (e.g., `id=org.wikipedia:id/search_src_text`).
2. Android UIAutomator selectors (`android=new UiSelector().text(...)`) for dynamic/result-list content where resource IDs are not ideal.
3. XPath only where necessary (used minimally, e.g., article title resource-id lookup).

### Rationale

- `id` locators are typically fastest and least brittle.
- UIAutomator text selectors are useful for result verification in lists with variable rendering.
- XPath is intentionally limited because it tends to be more fragile and slower in mobile UI automation.

## 5) Waits and Test Stability Approach

Stability is handled through explicit synchronization and defensive utility keywords:

- Centralized wait helpers in `appium_keywords.robot`, such as:
  - `Wait Until Element Is Enabled And Visible`
  - `Press Element`
  - `Check That Page Contains Element`
  - `Check That Page Contains Text`
- Retry pattern via `Wait Until Keyword Succeeds` for transient enablement timing.
- Swipe-retry loops (`Swipe Until Element Is Found ...`) with bounded attempts instead of unbounded scrolling.
- Conditional interaction for intermittent popups (`Press Element If Present`) to reduce flaky failures.
- Shared timeout constants in `variables/test_variables.py` to keep timing consistent across suites.
- Environment/session stability measures in setup:
  - App is launched and home screen is verified at the beginning of each test (ensures clean state).
  - Appium timeout is set at suite setup.
  - Android `waitForIdleTimeout` is reset during test setup via custom Python keyword.
- Failure diagnostics in teardown:
  - Screenshot on failure.
  - Page source logged for debugging.

## 6) Improvements With More Time

If expanded further, I would prioritize:

1. CI pipeline integration:
	Automate runs in GitHub Actions/Jenkins with artifact publishing and environment matrix.
2. Test data strategy:
	Move to structured test data files (YAML/JSON) for easier scenario expansion and localization testing.
3. Parallel execution:
	Scale to multiple emulators/devices with isolated ports and per-device capability profiles.
4. Multi-language and multi-environment support:
    Externalize locale and environment configuration (for example, QA/Staging/Prod + EN/FI) and run the same suite through a configuration matrix.

