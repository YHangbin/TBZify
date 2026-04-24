
# TBZify (增强版)

针对 macOS 的 Spotify 桌面客户端管理工具。本项目是 [jetfir3/TBZify](https://github.com/jetfir3/TBZify) 的增强分支。

## 🚀 新功能
- **架构自动识别**：自动判断当前 Mac 是 Apple Silicon (M1/M2/M3) 还是 Intel 芯片。
- **集成版本数据库**：深度接入 [LoaderSpot/table](https://github.com/LoaderSpot/table) 的版本映射库。
- **强化 `-v` 参数**：找回了通过“版本号”直接安装的能力，再也不用手动去翻长长的 `.tbz` 下载地址。
- **智能模糊匹配**：输入 `1.2.24` 脚本会自动匹配数据库中该版本的最新补丁（例如 `1.2.24.756`）。

## 🛠 使用方法

### 一键安装 (推荐)
安装指定版本、开启防自动更新、并清理旧数据：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) --datawipe -v 1.2.24 -bs
```

### 参数说明 (Options)
- `-v [version]` : 通过版本号安装（支持模糊搜索）。
- `-u [URL]`     : 通过直接下载链接安装。
- `-b`           : 屏蔽 Spotify 自动更新。
- `-s`           : 安装完成后保留安装包。
- `-p [path]`    : 指定归档文件/下载的存放路径。
- `-a [path]`    : 设置自定义的 Spotify.app 安装路径。
- `--datawipe`   : 安装前清理 App 数据（缓存、配置等）。
- `--uninstall`  : 彻底卸载 Spotify。
- `-h`           : 显示帮助信息。

---

### 📖 使用示例 (Examples)



#### 0. 安装数据库中的最新版本 
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) -v latest -bs
```

#### 1. 安装特定版本并屏蔽自动更新 (最常用)
输入版本号开头即可，脚本会自动匹配最新补丁并锁定更新文件夹：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) -v 1.2.24 -bs
```

#### 2. 通过指定 URL 安装
如果你有特定的下载链接，可以使用 `-u` 参数：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) -u https://example.com/spotify.tbz
```

#### 3. 安装本地已有的 .tbz 归档
使用 `-p` 参数指定本地文件路径：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) -p ~/Downloads/spotify.tbz
```

#### 4. 仅清理 Spotify 应用数据 (不卸载)
用于修复软件闪退或清除缓存：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) --datawipe
```

#### 5. 彻底卸载 Spotify
包括删除应用程序和所有关联的缓存、配置：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) --uninstall
```

#### 6. 高级组合指令
清理数据、下载到桌面、安装到下载目录、屏蔽更新并保留安装包：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/YHangbin/TBZify/main/tbzify.sh) --datawipe -v 1.2.24 -p ~/Desktop -a ~/Downloads -bs
```

---

## ❓ 常见问题 (FAQ)
**Q: 什么是 .tbz 文件？**
A: TBZ 是经过 Bzip2 压缩的 TAR 归档文件。Spotify 官方使用这种格式分发 macOS 客户端更新包。

**Q: 为什么需要这个脚本？**
A: 因为 Spotify 官方的 `.tbz` 包解压后不是普通的 `.app` 拖拽安装，而是需要替换 `Spotify.app/Contents` 目录，手动操作比较繁琐。且该脚本能一键锁定更新权限，防止版本回升。

## 🔗 致谢
- 原版脚本：[jetfir3](https://github.com/jetfir3/TBZify)。
- 版本数据库：[LoaderSpot](https://github.com/LoaderSpot/table)。
