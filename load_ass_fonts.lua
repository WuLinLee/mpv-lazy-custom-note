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