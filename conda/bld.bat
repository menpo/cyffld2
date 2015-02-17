robocopy %RECIPE_DIR%\.. . /E /NFL /NDL

"%PYTHON%" setup.py install --single-version-externally-managed --record=%TEMP%record.txt

rem This is a bit ugly, but since neither conda, nor Windows maintains runtime
rem paths well on Windows, we need to copy the dlls next to our
rem compiled library. I have renamed some of the copies so that
rem they match what is expected according to dependancy walker.
rem Unfortunately, at the time of writing, libfftw is built with
rem mingw and causes a segfault :(
xcopy "%LIBRARY_BIN%\libfftw3*.dll" "%SP_DIR%\cyffld2"
copy "%LIBRARY_BIN%\libxml2.dll" "%SP_DIR%\cyffld2\libxml2.dll"
copy "%LIBRARY_BIN%\libiconv.dll" "%SP_DIR%\cyffld2\iconv.dll"
copy "%LIBRARY_BIN%\zlib.dll" "%SP_DIR%\cyffld2\zlib1.dll"

if errorlevel 1 exit 1
