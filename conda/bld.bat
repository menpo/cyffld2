robocopy %RECIPE_DIR%\.. . /E /NFL /NDL

"%PYTHON%" setup.py install --single-version-externally-managed --record=%TEMP%record.txt

rem This is a bit ugly, but since neither conda, nor Windows maintains runtime
rem paths well on Windows, we need to copy the DLLs next to our
rem compiled library. I have renamed some of the copies so that
rem they match what is expected according to dependency walker.
copy "%LIBRARY_BIN%\libfftw3f-3.dll" "%SP_DIR%\cyffld2\libfftw3f-3.dll"
copy "%LIBRARY_BIN%\libxml2.dll" "%SP_DIR%\cyffld2\libxml2.dll"
copy "%LIBRARY_BIN%\zlib.dll" "%SP_DIR%\cyffld2\zlib1.dll"

rem Apparently libxml2 expects differently named DLLs for ICONV
rem between 32-bit and 64-bit.
if %ARCH%==32 (
    copy "%LIBRARY_BIN%\libiconv.dll" "%SP_DIR%\cyffld2\iconv.dll"
)
if %ARCH%==64 (
    copy "%LIBRARY_BIN%\libiconv.dll" "%SP_DIR%\cyffld2\libiconv-2.dll"
)

if errorlevel 1 exit 1
