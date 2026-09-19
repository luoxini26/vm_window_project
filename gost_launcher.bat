@echo off
cd /d "%~dp0"
title GOST 快速启动菜单

:MENU
cls
echo ========================================
echo   GOST v3.3.0 - 局域网安全测试快速启动
echo ========================================
echo.
echo [1] 启动基础代理 (SOCKS5+HTTP :8080)
echo [2] 端口转发 (本地端口 -> 目标IP:端口)
echo [3] 反向隧道服务端 (控制端/公网IP机器)
echo [4] 反向隧道客户端 (受控端/内网机器)
echo [5] SOCKS5 反向代理 (穿透内网)
echo [6] 使用配置文件启动 (gost.yml)
echo [7] 查看版本信息
echo [0] 退出
echo.
set /p CHOICE=请选择 [0-7]: 

if "%CHOICE%"=="1" goto PROXY
if "%CHOICE%"=="2" goto FORWARD
if "%CHOICE%"=="3" goto RELAY_SERVER
if "%CHOICE%"=="4" goto RELAY_CLIENT
if "%CHOICE%"=="5" goto SOCKS_RELAY
if "%CHOICE%"=="6" goto CONFIG
if "%CHOICE%"=="7" goto VERSION
if "%CHOICE%"=="0" goto EXIT

echo 无效选择，按任意键重试...
pause >nul
goto MENU

:PROXY
echo 启动 SOCKS5+HTTP 代理 监听 0.0.0.0:8080
echo 浏览器/工具设置代理: 127.0.0.1:8080
echo 按 Ctrl+C 停止
echo.
gost.exe -L :8080
echo.
echo 程序已退出，按任意键返回菜单...
pause >nul
goto MENU

:FORWARD
set /p LPORT=本地监听端口 (如 8080):
set /p TARGET=目标地址 (如 192.168.1.50:3389):
echo 启动端口转发 %LPORT% -> %TARGET%
echo 按 Ctrl+C 停止
echo.
gost.exe -L :%LPORT%/%TARGET%
echo.
echo 程序已退出，按任意键返回菜单...
pause >nul
goto MENU

:RELAY_SERVER
set /p LPORT=隧道监听端口 (如 443):
set /p RPORT=暴露本地端口 (如 8080):
echo 启动中继服务端 wss://:%LPORT%/:%RPORT%
echo 等待客户端连接...
echo 按 Ctrl+C 停止
echo.
gost.exe -L relay+wss://:%LPORT%/:%RPORT%
echo.
echo 程序已退出，按任意键返回菜单...
pause >nul
goto MENU

:RELAY_CLIENT
set /p SERVER=服务端地址 (如 1.2.3.4:443):
set /p LOCAL=本地转发目标 (如 :3389 或 192.168.1.50:22):
echo 启动中继客户端 -> %SERVER% (转发 %LOCAL%)
echo 按 Ctrl+C 停止
echo.
gost.exe -L %LOCAL% -F relay+wss://%SERVER%
echo.
echo 程序已退出，按任意键返回菜单...
pause >nul
goto MENU

:SOCKS_RELAY
set /p SERVER=服务端地址 (如 1.2.3.4:443):
set /p LPORT=本地 SOCKS5 端口 (如 1080):
echo 启动 SOCKS5 反向代理 -> %SERVER%
echo 服务端需运行: gost -L relay+wss://:%LPORT%/1080
echo 按 Ctrl+C 停止
echo.
gost.exe -L socks5://:%LPORT% -F relay+wss://%SERVER%
echo.
echo 程序已退出，按任意键返回菜单...
pause >nul
goto MENU

:CONFIG
if not exist gost.yml (
    echo 未找到 gost.yml，正在创建示例...
    echo services: > gost.yml
    echo   - name: proxy >> gost.yml
    echo     addr: ":8080" >> gost.yml
    echo     handler: >> gost.yml
    echo       type: auto >> gost.yml
    echo     listener: >> gost.yml
    echo       type: tcp >> gost.yml
    echo 已创建 gost.yml，请编辑后重新运行
    notepad gost.yml
) else (
    echo 使用配置文件启动...
    gost.exe -C gost.yml
)
echo.
echo 按任意键返回菜单...
pause >nul
goto MENU

:VERSION
gost.exe -V
echo.
echo 按任意键返回菜单...
pause >nul
goto MENU

:EXIT
echo 退出程序...
timeout /t 1 /nobreak >nul