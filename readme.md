# mpv-lazy custom笔记

## 📁 文件位置设置总览

```
E:\mpv-lazy\
├── font for mpv\                              ← 字体库（参考）
│   ├── 华康圆体W7-A.ttf
│   ├── FZLanTingYuan-DB-GBK.ttf
│   ├── FOT-SeuratProN-B.otf
│   └── ...（所有字体平铺，无子文件夹）
│
├── flash-font-ass-Windows-msvc-x86_64\        ← flash-font 程序
│   └── flash-font-ass.exe
│
│
└── mpv-lazy\
    └── portable_config\
        ├── mpv.conf                           ← 主配置!
        ├── input_uosc.conf                    ← 快捷键!
        ├── script-opts.conf                   ← 脚本选项
        ├── profiles.conf                      ← 自动预设
        │
        ├── scripts\                           ← 脚本文件夹
        │   ├── sub_export.lua                 ← 导出字幕脚本（下载导入）!!!!!!
        │   └── load_ass_fonts.lua             ← flash-font 加载脚本（新建）!!!!!!!
        │
        │
        └── fonts\                             ← 只留 mpv 自带三个（参考）
            ├── LXGWWenKaiMonoLite-Regular.ttf
            ├── MaterialIconsRound-Regular.otf
            └── uosc_textures.ttf
```

---

## 功能1：导出字幕（sub_export.lua）

**脚本位置**：`E:\mpv-lazy\mpv-lazy\portable_config\scripts\sub_export.lua`

下载 `sub_export.lua`：  
https://github.com/dyphire/mpv-scripts/blob/main/sub_export.lua

放入 `portable_config\scripts\` 文件夹（没有就新建）。

在 `mpv.conf` 末尾添加一行：

```ini
#script-opts=sub_export-ffmpeg_path="E:\\LosslessCut-win-x64\\resources\\ffmpeg.exe"
script-opts=sub_export-ffmpeg_path="E:\\ffmpeg-gs\\ffmpeg.exe"
#取决于你的ffmpeg.exe路径在哪里没有就弄一个
```

用法：按 `` ` `` 键打开控制台，输入：

```
script-message-to sub_export export-selected-subtitles
```

---

## 功能2：移动字幕位置加开关弹幕（快捷键）

**配置位置**：`E:\mpv-lazy\mpv-lazy\portable_config\input_uosc.conf`

在 `input_uosc.conf` 末尾添加：

```ini
#Ctrl+x add sub-pos -1       # 字幕下移（备用，未启用）
#Ctrl+z add sub-pos +1       # 字幕上移（备用，未启用）
#Shift+x add sub-scale -0.1  # 字幕缩小（备用，未启用）
#Shift+z add sub-scale +0.1  # 字幕放大（备用，未启用）

Ctrl+z add sub-pos -1       # 字幕下移
Ctrl+x add sub-pos +1       # 字幕上移
Shift+z add sub-scale -0.1  # 字幕缩小
Shift+x add sub-scale +0.1  # 字幕放大
```

---

# flash-font 配置

## 1. 字体库

**位置**：`E:\mpv-lazy\font for mpv`

```
E:\mpv-lazy\font for mpv\
├── 华康圆体W7-A.ttf
├── FZLanTingYuan-DB-GBK.ttf
├── FOT-SeuratProN-B.otf
└── ...（所有字体平铺，无子文件夹）
```

所有字体平铺放进去，**不要建子文件夹**。

## 2. 初始化

**程序位置**：`E:\mpv-lazy\flash-font-ass-Windows-msvc-x86_64\flash-font-ass.exe`

在 PowerShell 中运行：

```powershell
& "E:\mpv-lazy\flash-font-ass-Windows-msvc-x86_64\flash-font-ass.exe" init
```

提示路径时输入：

```
E:\mpv-lazy\font for mpv
```

通知选择：`No`

## 3. mpv 插件

**文件位置**：`E:\mpv-lazy\mpv-lazy\portable_config\scripts\load_ass_fonts.lua`

在 `portable_config\scripts\` 下新建 `load_ass_fonts.lua`，把下面内容**整段复制**进去，**不用改任何东西**：

```lua
-- mpv Auto ASS Font Loader
-- flash-font-ass 路径已写死，直接复制即可用

local msg = require 'mp.msg'

local EXE = "E:/mpv-lazy/flash-font-ass-Windows-msvc-x86_64/flash-font-ass.exe"

local processed_subs = {}

local function load_fonts_for_subtitle(sub_path)
    if not sub_path or not sub_path:lower():match("%.ass$") then
        return
    end
    if processed_subs[sub_path] then
        return
    end

    msg.info("Detected external ASS subtitle, loading fonts: " .. sub_path)

    local result = mp.command_native({
        name = "subprocess",
        args = { EXE, "load", "--subtitle", sub_path },
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
    })

    if result.status == 0 then
        msg.info("flash-font-ass executed successfully for: " .. sub_path)
        processed_subs[sub_path] = true
    else
        msg.error("flash-font-ass failed with exit code: " .. tostring(result.status))
        if result.stderr and result.stderr ~= "" then
            msg.error("Error output: " .. result.stderr)
        end
    end
end

-- 场景 A：打开文件时自动加载（播放前执行）
mp.add_hook("on_preloaded", 50, function()
    local tracks = mp.get_property_native("track-list")
    if not tracks then return end
    for _, track in ipairs(tracks) do
        if track.type == "sub" and track["external-filename"] then
            load_fonts_for_subtitle(track["external-filename"])
        end
    end
end)

-- 场景 B：播放中手动加载/切换字幕
mp.observe_property("current-tracks/sub/external-filename", "string", function(name, sub_path)
    if sub_path then
        load_fonts_for_subtitle(sub_path)
    end
end)

-- 新文件加载时清空缓存
mp.register_event("file-loaded", function()
    processed_subs = {}
end)
```

## 4. 重启 mpv

全部改完后

---

## 📌 路径速查

| 用途           | 完整路径                                                     |
| -------------- | ------------------------------------------------------------ |
| flash-font exe | `E:\mpv-lazy\flash-font-ass-Windows-msvc-x86_64\flash-font-ass.exe` |
| 字体库         | `E:\mpv-lazy\font for mpv`                                   |
| mpv 配置       | `E:\mpv-lazy\mpv-lazy\portable_config\`                      |
| mpv 脚本       | `E:\mpv-lazy\mpv-lazy\portable_config\scripts\`              |
| 新建 lua       | `E:\mpv-lazy\mpv-lazy\portable_config\scripts\load_ass_fonts.lua` |
| 快捷键配置     | `E:\mpv-lazy\mpv-lazy\portable_config\input_uosc.conf`       |
| 主配置         | `E:\mpv-lazy\mpv-lazy\portable_config\mpv.conf`              |



## mpv.conf 字幕设置 

**原来的（参考）**

```
 sub-font = "LXGW WenKai Mono Lite"
 sub-font-size = 44
 sub-scale-signs = yes
 sub-outline-size = 4
 sub-blur = 1
 sub-color = "#FFFFFF"
 sub-use-margins = yes
```



**改后的**

```
 sub-font = "LXGW WenKai Mono Lite"
 sub-font-size = 44
 sub-scale-signs = yes
 sub-bold = yes
 sub-color = "#FFFFFF"
 sub-outline-size = 0.5
 sub-outline-color = "#000000"
 sub-shadow-offset = 0.5
 sub-back-color = "#000000"
 sub-use-margins = yes
```



## mpv-lazy  custom 设置

**1. 删两个旧脚本**

```
E:\mpv-lazy\mpv-lazy\portable_config\scripts\auto_load_fonts.js
E:\mpv-lazy\mpv-lazy\portable_config\scripts\auto_sub_fonts_dir.lua
```



**2. 注释 `script-opts.conf` 里两行**

打开：

```
E:\mpv-lazy\mpv-lazy\portable_config\script-opts.conf
```



搜：

```
script-opts-append = auto_load_fonts-compatible_mode=no
script-opts-append = auto_load_fonts-compatible_dir=~~/.fonts
```

前面各加 `#`



**3.`input_uosc.conf`里改成**

```
 Alt+z                 script-binding recentmenu/open                       #! 工具 > 最近播放记录
 z                 add sub-delay -0.1                                    #! 播放 > 字幕预载 100ms
```



# External Player 配置

## 1. 装 Tampermonkey

浏览器扩展装 Tampermonkey。

## 2. 装脚本

- 打开 `E:\mpv-lazy\mpv-lazy\external_player.js`
- 全选复制
- Tampermonkey → 添加新脚本 → 粘贴 → 保存

## 3. 注册协议

- 管理员运行 `E:\mpv-lazy\mpv-lazy\url-scheme-handler.exe`
- 点 `+ Add to Registry`
- 点 `+`，名称填 `MPV`，路径选 `mpv.exe`
- 保存

## 4. 验证

刷新 B站/YouTube，左下角出现面板，点播放。



## watch_later

路径：`E:\mpv-lazy\mpv-lazy\portable_config\_cache\watch_later`

删除里面的文件会丢失：

- 播放进度
- 音轨选择
- 视频轨选择
- 字幕选择


## uosc_danmaku 弹幕增强扩展 2026.10.12

## 安装位置

将 [WuLinLee/my_uosc_danmaku](https://github.com/WuLinLee/my_uosc_danmaku)内的 portable_config 文件夹解压覆盖到：
E:\mpv-lazy\mpv-lazy\

## 相关链接

https://github.com/dyphire/mpv-scripts/blob/main/sub_export.lua

https://github.com/Tony15246/uosc_danmaku （原始上游 不是luoxue03/mpv-lazy-2026-custom的uosc_danmaku）

https://github.com/WuLinLee/my_uosc_danmaku （我自己替换luoxue03/mpv-lazy-2026-custom的弹幕增强扩展）

https://github.com/luoxue03/mpv-lazy-2026-custom （最重要）

https://github.com/luoxue03/external-player （非原始上游）


https://github.com/WuLinLee/danmaku-anywhere （和WuLinLee/my_uosc_danmaku有一点关系 与mpv无关）

https://github.com/naganohara-yoshino/flash-font

