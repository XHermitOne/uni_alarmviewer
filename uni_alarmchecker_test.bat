echo off
del uni_alarmchecker.log
del uni_alarmchecker.mem

echo.
@echo Запуск в: %time%
echo.
uni_alarmchecker.exe
echo.
@echo Останов в: %time%
echo.

type uni_alarmchecker.mem
