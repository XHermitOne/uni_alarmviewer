echo off
del uni_alarmchecker.log
del uni_alarmchecker.mem

echo.
@echo ����� �: %time%
echo.
uni_alarmchecker.exe --debug
echo.
@echo ��⠭�� �: %time%
echo.

type uni_alarmchecker.mem
