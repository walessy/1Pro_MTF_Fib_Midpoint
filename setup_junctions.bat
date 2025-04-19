cd /d "%~dp0"
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ===================================================
ECHO MT4 Strategy Component Mapping Tool
ECHO ===================================================
ECHO.

:: ----------------------------------------------
:: Get Current Folder Name
:: ----------------------------------------------
FOR %%F IN ("%CD%") DO (
  SET "CurrentFolder=%%~nxF"
)
ECHO Strategy: %CurrentFolder%
ECHO.

:: ----------------------------------------------
:: Define base paths
:: ----------------------------------------------
SET "SourceBase=C:\Projects\MetaTraderComponants\%CurrentFolder%"
SET "TargetBase=C:\Projects\OLD\Mt4 20241003\2 AP2\Signal\Instance1\MQL4"

:: ----------------------------------------------
:: Ensure source folders exist
:: ----------------------------------------------
SET "IncludeSource=%SourceBase%\common\include"
SET "IndicatorsSource=%SourceBase%\mt4\indicators"

IF NOT EXIST "%IncludeSource%" (
  ECHO Creating missing include source folder: %IncludeSource%
  MKDIR "%IncludeSource%"
  IF ERRORLEVEL 1 (
    ECHO Failed to create include source folder.
    GOTO :Error
  )
)

IF NOT EXIST "%IndicatorsSource%" (
  ECHO Creating missing indicators source folder: %IndicatorsSource%
  MKDIR "%IndicatorsSource%"
  IF ERRORLEVEL 1 (
    ECHO Failed to create indicators source folder.
    GOTO :Error
  )
)

:: ----------------------------------------------
:: Map MT4 Include Folder
:: ----------------------------------------------
SET "IncludeTarget=%TargetBase%\Include\%CurrentFolder%"

ECHO Creating include junction...
ECHO Source: %IncludeSource%
ECHO Target: %IncludeTarget%

:: Create parent directory if needed
FOR %%F IN ("%IncludeTarget%\.") DO SET "ParentDir=%%~dpF"
IF NOT EXIST "!ParentDir!" (
  ECHO Creating parent directory: !ParentDir!
  MKDIR "!ParentDir!"
  IF ERRORLEVEL 1 (
    ECHO Failed to create parent directory.
    GOTO :Error
  )
)

:: Remove existing junction if it exists
IF EXIST "%IncludeTarget%" (
  ECHO Removing existing include junction...
  RMDIR "%IncludeTarget%"
  IF ERRORLEVEL 1 (
    ECHO Failed to remove existing include junction.
    GOTO :Error
  )
)

:: Create the junction
MKLINK /J "%IncludeTarget%" "%IncludeSource%"
IF ERRORLEVEL 1 (
  ECHO Failed to create include junction.
  GOTO :Error
)
ECHO Include junction created successfully.
ECHO.

:: ----------------------------------------------
:: Map MT4 Indicators Folder
:: ----------------------------------------------
SET "IndicatorsTarget=%TargetBase%\Indicators\%CurrentFolder%"

ECHO Creating indicators junction...
ECHO Source: %IndicatorsSource%
ECHO Target: %IndicatorsTarget%

:: Create parent directory if needed
FOR %%F IN ("%IndicatorsTarget%\.") DO SET "ParentDir=%%~dpF"
IF NOT EXIST "!ParentDir!" (
  ECHO Creating parent directory: !ParentDir!
  MKDIR "!ParentDir!"
  IF ERRORLEVEL 1 (
    ECHO Failed to create parent directory.
    GOTO :Error
  )
)

:: Remove existing junction if it exists
IF EXIST "%IndicatorsTarget%" (
  ECHO Removing existing indicators junction...
  RMDIR "%IndicatorsTarget%"
  IF ERRORLEVEL 1 (
    ECHO Failed to remove existing indicators junction.
    GOTO :Error
  )
)

:: Create the junction
MKLINK /J "%IndicatorsTarget%" "%IndicatorsSource%"
IF ERRORLEVEL 1 (
  ECHO Failed to create indicators junction.
  GOTO :Error
)
ECHO Indicators junction created successfully.
ECHO.

:: ----------------------------------------------
:: Success Message
:: ----------------------------------------------
ECHO ===================================================
ECHO Setup completed successfully!
ECHO ===================================================
ECHO.
ECHO The following junctions were created:
ECHO.
ECHO 1. MT4 Include Folder:
ECHO    Link: %IncludeTarget%
ECHO    Points to: %IncludeSource%
ECHO.
ECHO 2. MT4 Indicators Folder:
ECHO    Link: %IndicatorsTarget%
ECHO    Points to: %IndicatorsSource%
ECHO.
ECHO These junctions allow you to develop in the source folders
ECHO while changes are immediately available in MT4.
ECHO.
PAUSE
ENDLOCAL
EXIT /B 0

:: ----------------------------------------------
:: Error Handling
:: ----------------------------------------------
:Error
ECHO.
ECHO ===================================================
ECHO Setup failed!
ECHO ===================================================
ECHO.
ECHO Please check the error message above and try again.
ECHO If you still encounter issues, consider:
ECHO  - Running the script as Administrator
ECHO  - Checking that all paths exist
ECHO  - Ensuring you have write permissions to the target locations
ECHO.
PAUSE
ENDLOCAL
EXIT /B 1