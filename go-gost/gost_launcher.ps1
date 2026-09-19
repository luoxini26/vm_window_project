# GOST v3.3.0 - 局域网安全测试快速启动菜单 (PowerShell 版)
# 右键此文件 → "用 PowerShell 运行" 或在终端输入: .\gost_launcher.ps1

$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

function Show-Menu {
    Clear-Host
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "  GOST v3.3.0 - 局域网安全测试快速启动菜单" -ForegroundColor Yellow
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] 启动基础代理 (SOCKS5+HTTP :8080)" -ForegroundColor Green
    Write-Host " [2] 端口转发 (本地端口 -> 目标IP:端口)" -ForegroundColor Green
    Write-Host " [3] 反向隧道服务端 (控制端/公网IP机器)" -ForegroundColor Green
    Write-Host " [4] 反向隧道客户端 (受控端/内网机器)" -ForegroundColor Green
    Write-Host " [5] SOCKS5 反向代理 (穿透内网)" -ForegroundColor Green
    Write-Host " [6] 使用配置文件启动 (gost.yml)" -ForegroundColor Green
    Write-Host " [7] 查看版本信息" -ForegroundColor Green
    Write-Host " [0] 退出" -ForegroundColor Red
    Write-Host ""
}

function Press-Enter {
    Write-Host "`n按 Enter 返回菜单..." -ForegroundColor Gray -NoNewline
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Check-Gost {
    if (-not (Test-Path ".\gost.exe")) {
        Write-Error "❌ 当前目录未找到 gost.exe"
        Press-Enter
        return $false
    }
    return $true
}

do {
    Show-Menu
    $choice = Read-Host "请选择 [0-7]"

    switch ($choice) {
        '1' {
            if (Check-Gost) {
                Write-Host "`n🚀 启动 SOCKS5+HTTP 代理监听 0.0.0.0:8080" -ForegroundColor Yellow
                Write-Host "🌐 浏览器/工具设置代理: 127.0.0.1:8080" -ForegroundColor Cyan
                Write-Host "⏹  按 Ctrl+C 停止`n" -ForegroundColor Gray
                .\gost.exe -L :8080
                Press-Enter
            }
        }
        '2' {
            if (Check-Gost) {
                $lport = Read-Host "本地监听端口 (如 8080)"
                $target = Read-Host "目标地址 (如 192.168.1.50:3389)"
                Write-Host "`n🔄 启动端口转发 $lport -> $target" -ForegroundColor Yellow
                Write-Host "⏹  按 Ctrl+C 停止`n" -ForegroundColor Gray
                .\gost.exe -L ":$lport/$target"
                Press-Enter
            }
        }
        '3' {
            if (Check-Gost) {
                $lport = Read-Host "隧道监听端口 (如 443)"
                $rport = Read-Host "暴露本地端口 (如 8080)"
                Write-Host "`n🟢 启动中继服务端: wss://:$lport/::$rport" -ForegroundColor Yellow
                Write-Host "⏳ 等待客户端连接..." -ForegroundColor Cyan
                Write-Host "⏹  按 Ctrl+C 停止`n" -ForegroundColor Gray
                .\gost.exe -L "relay+wss://:$lport/::$rport"
                Press-Enter
            }
        }
        '4' {
            if (Check-Gost) {
                $server = Read-Host "服务端地址 (如 1.2.3.4:443)"
                $local = Read-Host "本地转发目标 (如 :3389 或 192.168.1.50:22)"
                Write-Host "`n🔵 启动中继客户端 -> $server (转发 $local)" -ForegroundColor Yellow
                Write-Host "⏹  按 Ctrl+C 停止`n" -ForegroundColor Gray
                .\gost.exe -L $local -F "relay+wss://$server"
                Press-Enter
            }
        }
        '5' {
            if (Check-Gost) {
                $server = Read-Host "服务端地址 (如 1.2.3.4:443)"
                $lport = Read-Host "本地 SOCKS5 端口 (如 1080)"
                Write-Host "`n🟣 启动 SOCKS5 反向代理 -> $server" -ForegroundColor Yellow
                Write-Host "ℹ️  服务端需运行: gost -L relay+wss://:$lport/1080" -ForegroundColor Cyan
                Write-Host "⏹  按 Ctrl+C 停止`n" -ForegroundColor Gray
                .\gost.exe -L "socks5://:$lport" -F "relay+wss://$server"
                Press-Enter
            }
        }
        '6' {
            if (-not (Test-Path ".\gost.yml")) {
                Write-Host "`n📝 未找到 gost.yml，创建示例配置..." -ForegroundColor Yellow
                @"
services:
  - name: proxy
    addr: ":8080"
    handler:
      type: auto
    listener:
      type: tcp
"@ | Set-Content -Path ".\gost.yml" -Encoding utf8
                Write-Host "✅ 已创建 gost.yml，请编辑后重新运行" -ForegroundColor Green
                notepad .\gost.yml
            }
            else {
                Write-Host "`n⚙️ 使用配置文件启动..." -ForegroundColor Yellow
                .\gost.exe -C gost.yml
                Press-Enter
            }
        }
        '7' {
            if (Check-Gost) {
                .\gost.exe -V
                Press-Enter
            }
        }
        '0' {
            Write-Host "`n👋 退出程序" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            exit
        }
        default {
            Write-Warning "`n❌ 无效选择，请输入 0-7"
            Start-Sleep -Seconds 1
        }
    }
} while ($true)