@echo off
cd /d "%~dp0"
title Sliver C2 v1.7.7 - 快速启动菜单

:MENU
cls
echo ========================================
echo   Sliver C2 v1.7.7 - 快速启动菜单
echo ========================================
echo.
echo [1] 启动团队服务器 (前台/调试模式)
echo [2] 启动团队服务器 (后台守护进程)
echo [3] 连接控制台 (首次需密码)
echo [4] 导入配置文件连接 (免密)
echo [5] 生成新操作员配置
echo [6] 查看版本信息
echo [7] 备份数据目录
echo [0] 退出
echo.
set /p CHOICE=请选择 [0-7]: 

if "%CHOICE%"=="1" goto SERVER_FG
if "%CHOICE%"=="2" goto SERVER_BG
if "%CHOICE%"=="3" goto CLIENT_CONNECT
if "%CHOICE%"=="4" goto CLIENT_IMPORT
if "%CHOICE%"=="5" goto NEW_OPERATOR
if "%CHOICE%"=="6" goto VERSION
if "%CHOICE%"=="7" goto BACKUP
if "%CHOICE%"=="0" goto EXIT

echo 无效选择，按任意键重试...
pause >nul
goto MENU

:SERVER_FG
echo.
echo 启动团队服务器 (前台，日志直接显示)
echo 监听: 0.0.0.0:31337
echo 首次运行会显示 operator 密码，请务必记录！
echo 按 Ctrl+C 停止
echo.
.\sliver-server.exe daemon --lhost 0.0.0.0 --lport 31337
echo.
echo 服务端已停止，按任意键返回菜单...
pause >nul
goto MENU

:SERVER_BG
echo.
echo 启动团队服务器 (后台守护进程)
echo 监听: 0.0.0.0:31337
echo 日志写入 data/sliver.log
echo.
start /b "" .\sliver-server.exe daemon --lhost 0.0.0.0 --lport 31337
timeout /t 2 /nobreak >nul
echo 服务端已在后台启动。
echo 首次运行请查看 data/sliver.log 获取 operator 密码
echo.
pause >nul
goto MENU

:CLIENT_CONNECT
set /p SERVER_IP=服务器IP [默认 127.0.0.1]: 
if "%SERVER_IP%"=="" set SERVER_IP=127.0.0.1
set /p SERVER_PORT=服务器端口 [默认 31337]: 
if "%SERVER_PORT%"=="" set SERVER_PORT=31337
set /p USERNAME=用户名 [默认 operator]: 
if "%USERNAME%"=="" set USERNAME=operator
set /p PASSWORD=密码 (首次运行服务端显示的密码): 
echo.
echo 连接到 %SERVER_IP%:%SERVER_PORT% ...
.\sliver-client.exe --connect %SERVER_IP%:%SERVER_PORT% --username %USERNAME% --password %PASSWORD%
echo.
echo 会话结束，按任意键返回菜单...
pause >nul
goto MENU

:CLIENT_IMPORT
if not exist data\operator.cfg (
    echo 未找到 data/operator.cfg，请先用选项 [3] 连接一次生成配置
    pause >nul
    goto MENU
)
echo 导入配置文件并启动控制台...
.\sliver-client.exe import --source data\operator.cfg
.\sliver-client.exe console
echo.
echo 会话结束，按任意键返回菜单...
pause >nul
goto MENU

:NEW_OPERATOR
set /p OP_NAME=新操作员用户名: 
if "%OP_NAME%"=="" (
    echo 用户名不能为空
    pause >nul
    goto MENU
)
echo 生成操作员配置: %OP_NAME%.cfg
.\sliver-server.exe operator --name %OP_NAME% --lhost 0.0.0.0 --lport 31337 --save .\%OP_NAME%.cfg
echo.
echo 已生成 %OP_NAME%.cfg，分发给队友即可使用
echo 队友使用方法: sliver-client.exe import --source %OP_NAME%.cfg ^&^& sliver-client.exe console
pause >nul
goto MENU

:VERSION
.\sliver-server.exe version
.\sliver-client.exe version
pause >nul
goto MENU

:BACKUP
set BACKUP_NAME=sliver_backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_NAME=%BACKUP_NAME: =0%
if not exist data (
    echo data 目录不存在
    pause >nul
    goto MENU
)
echo 正在备份 data 目录到 %BACKUP_NAME%.zip ...
powershell -Command "Compress-Archive -Path '.\data\*' -DestinationPath '.\%BACKUP_NAME%.zip' -Force"
if %errorlevel% equ 0 (
    echo 备份完成: %BACKUP_NAME%.zip
) else (
    echo 备份失败
)
pause >nul
goto MENU

:EXIT
echo 退出...
timeout /t 1 /nobreak >nul