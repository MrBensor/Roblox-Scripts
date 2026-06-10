local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/MrBensor/Roblox-Scripts/refs/heads/main/GsLib.lua"))()

local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService          = game:GetService("HttpService")
local Lighting             = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local Connections = {}
local Drawings    = {}

local function track(conn)
    table.insert(Connections, conn)
    return conn
end

local function newDrawing(class)
    local d = Drawing.new(class)
    table.insert(Drawings, d)
    return d
end

-- =====================
--      SETTINGS
-- =====================
local Settings = {
    ESPEnabled      = false,
    ESPTeamCheck    = false,
    ESPBoxes        = true,
    ESPNames        = true,
    ESPHealthBar    = true,
    ESPTracers      = false,
    ESPTracerOrigin = "Bottom",
    ESPDistance     = false,
    ESPSkeleton     = false,
    ESPHeadCircle   = false,
    ESPMaxDistance  = 1000,
    ESPColor        = Color3.fromRGB(255, 0, 0),
    ESPColorAlpha   = 1,
    ESPUseTeamColor = false,

    AimbotEnabled   = false,
    AimbotHeld      = false,
    AimbotFOV       = 10,
    AimbotShowFOV   = false,
    AimbotSmoothing = 0,
    AimbotWallcheck = false,
    AimbotBones     = { "Head" },

    FullbrightEnabled    = false,
    FullbrightBrightness = 2,
    FullbrightClockTime  = 14,

    AccentColor = Color3.fromRGB(161, 212, 59),
}

local Bindings = {}

-- =====================
--   BONE DEFINITIONS
-- =====================
-- Skeleton draw connections
local SKELETON = {
    { "Head",          "UpperTorso"    },
    { "UpperTorso",    "LowerTorso"    },
    { "UpperTorso",    "LeftUpperArm"  },
    { "LeftUpperArm",  "LeftLowerArm"  },
    { "LeftLowerArm",  "LeftHand"      },
    { "UpperTorso",    "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand"     },
    { "LowerTorso",    "LeftUpperLeg"  },
    { "LeftUpperLeg",  "LeftLowerLeg"  },
    { "LeftLowerLeg",  "LeftFoot"      },
    { "LowerTorso",    "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot"     },
}
local MAX_BONES = #SKELETON

local AIMABLE_BONES = {
    "Head",
    "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
}

-- =====================
--       THEME
-- =====================
local MyTheme = {
    Accent       = Color3.fromRGB(161, 212, 59),
    Bg           = Color3.fromRGB(19, 18, 18),
    OuterBg      = Color3.fromRGB(6,  5,  5),
    Sidebar      = Color3.fromRGB(15, 14, 14),
    Panel        = Color3.fromRGB(27, 26, 26),
    Elem         = Color3.fromRGB(37, 36, 36),
    ElemHov      = Color3.fromRGB(48, 47, 47),
    Border       = Color3.fromRGB(56, 55, 54),
    BorderDim    = Color3.fromRGB(35, 34, 33),
    IslandBorder = Color3.fromRGB(64, 63, 62),
    Text         = Color3.fromRGB(238, 237, 236),
    Dim          = Color3.fromRGB(228, 227, 226),
    Muted        = Color3.fromRGB(146, 144, 143),
    CheckOff     = Color3.fromRGB(42,  41,  41),
    Font         = Enum.Font.Gotham,
    Bold         = Enum.Font.GothamBold,
    Sz           = 13,
    TopBarColors = {
        Color3.fromRGB(255,  51,  51),
        Color3.fromRGB(255, 140,   0),
        Color3.fromRGB(255, 230,   0),
        Color3.fromRGB( 51, 220,  51),
        Color3.fromRGB( 51, 160, 255),
        Color3.fromRGB(160,  51, 255),
        Color3.fromRGB(255,  51, 180),
    },
}

-- =====================
--       WINDOW
-- =====================
local Window = Lib:CreateWindow({
    Title = "Rivals",
    Size  = Vector2.new(700, 490),
    Theme = MyTheme,
})
Window:SetToggleKey(Enum.KeyCode.Delete)
Lib:Notify({ Title = "Rivals", Text = "Loaded. Delete to toggle.", Duration = 4 })

-- =====================
--        TABS
-- =====================
local ESPTab    = Window:CreateTab({ Name = "ESP"    })
local AimbotTab = Window:CreateTab({ Name = "Aimbot" })
local MiscTab   = Window:CreateTab({ Name = "Misc"   })
local ConfigTab = Window:CreateTab({ Name = "Config" })

-- =====================
--       ESP TAB
-- =====================
local ESPLeft  = ESPTab:CreateGroup({ Name = "Player ESP", Side = "Left"  })
local ESPRight = ESPTab:CreateGroup({ Name = "Options",    Side = "Right" })

local wESPEnabled = ESPLeft:AddToggle({
    Text = "Enable ESP", Default = false,
    Callback = function(v) Settings.ESPEnabled = v end,
})
Bindings[#Bindings+1] = function() wESPEnabled:Set(Settings.ESPEnabled) end

local wESPTeamCheck = ESPLeft:AddToggle({
    Text = "Team Check", Default = false,
    Callback = function(v) Settings.ESPTeamCheck = v end,
})
Bindings[#Bindings+1] = function() wESPTeamCheck:Set(Settings.ESPTeamCheck) end

local wESPBoxes = ESPLeft:AddToggle({
    Text = "Boxes", Default = true,
    Callback = function(v) Settings.ESPBoxes = v end,
})
Bindings[#Bindings+1] = function() wESPBoxes:Set(Settings.ESPBoxes) end

local wESPSkeleton = ESPLeft:AddToggle({
    Text = "Skeleton", Default = false,
    Callback = function(v) Settings.ESPSkeleton = v end,
})
Bindings[#Bindings+1] = function() wESPSkeleton:Set(Settings.ESPSkeleton) end

local wESPNames = ESPLeft:AddToggle({
    Text = "Names", Default = true,
    Callback = function(v) Settings.ESPNames = v end,
})
Bindings[#Bindings+1] = function() wESPNames:Set(Settings.ESPNames) end

local wESPHealthBar = ESPLeft:AddToggle({
    Text = "Health Bar", Default = true,
    Callback = function(v) Settings.ESPHealthBar = v end,
})
Bindings[#Bindings+1] = function() wESPHealthBar:Set(Settings.ESPHealthBar) end

local wESPHeadCircle = ESPLeft:AddToggle({
    Text = "Head Circle", Default = false,
    Callback = function(v) Settings.ESPHeadCircle = v end,
})
Bindings[#Bindings+1] = function() wESPHeadCircle:Set(Settings.ESPHeadCircle) end

local wTracerOrigin
local wESPTracers = ESPLeft:AddToggle({
    Text = "Tracers", Default = false,
    Callback = function(v)
        Settings.ESPTracers = v
        if wTracerOrigin then wTracerOrigin:SetVisible(v) end
    end,
})
Bindings[#Bindings+1] = function() wESPTracers:Set(Settings.ESPTracers) end

wTracerOrigin = ESPLeft:AddDropdown({
    Text    = "Tracer Origin",
    Options = { "Bottom", "Middle", "Top" },
    Callback = function(v) Settings.ESPTracerOrigin = v end,
})
wTracerOrigin:SetVisible(Settings.ESPTracers)
Bindings[#Bindings+1] = function()
    wTracerOrigin:Set(Settings.ESPTracerOrigin)
    wTracerOrigin:SetVisible(Settings.ESPTracers)
end

local wESPDistance = ESPLeft:AddToggle({
    Text = "Distance", Default = false,
    Callback = function(v) Settings.ESPDistance = v end,
})
Bindings[#Bindings+1] = function() wESPDistance:Set(Settings.ESPDistance) end

ESPRight:AddSection("Color")
local wESPColor = ESPRight:AddColorPicker({
    Text    = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c, a)
        Settings.ESPColor      = c
        Settings.ESPColorAlpha = a or 1
    end,
})
Bindings[#Bindings+1] = function() wESPColor:Set(Settings.ESPColor) end

local wESPUseTeamColor = ESPRight:AddToggle({
    Text = "Use Team Colors", Default = false,
    Callback = function(v) Settings.ESPUseTeamColor = v end,
})
Bindings[#Bindings+1] = function() wESPUseTeamColor:Set(Settings.ESPUseTeamColor) end

ESPRight:AddSection("Range")
local wESPMaxDist = ESPRight:AddSlider({
    Text = "Max Distance", Min = 100, Max = 2000, Default = 1000, Suffix = "m",
    Callback = function(v) Settings.ESPMaxDistance = v end,
})
Bindings[#Bindings+1] = function() wESPMaxDist:Set(Settings.ESPMaxDistance) end

-- =====================
--     AIMBOT TAB
-- =====================
local AimbotLeft  = AimbotTab:CreateGroup({ Name = "Aimbot",   Side = "Left"  })
local AimbotRight = AimbotTab:CreateGroup({ Name = "Settings", Side = "Right" })

local wAimbotEnabled = AimbotLeft:AddToggle({
    Text = "Enable Aimbot", Default = false,
    Callback = function(v) Settings.AimbotEnabled = v end,
})
wAimbotEnabled:AddKeybind({ Mode = "Hold", Callback = function(v) Settings.AimbotHeld = v end })
Bindings[#Bindings+1] = function() wAimbotEnabled:Set(Settings.AimbotEnabled) end

AimbotLeft:AddSection("FOV")
local wAimbotFOV = AimbotLeft:AddSlider({
    Text = "FOV", Min = 1, Max = 180, Default = 10, Suffix = "°",
    Callback = function(v) Settings.AimbotFOV = v end,
})
Bindings[#Bindings+1] = function() wAimbotFOV:Set(Settings.AimbotFOV) end

local wAimbotShowFOV = AimbotLeft:AddToggle({
    Text = "Show FOV", Default = false,
    Callback = function(v) Settings.AimbotShowFOV = v end,
})
Bindings[#Bindings+1] = function() wAimbotShowFOV:Set(Settings.AimbotShowFOV) end

AimbotLeft:AddSection("Target")
local wAimbotBones = AimbotLeft:AddDropdown({
    Text    = "Aimbones",
    Multi   = true,
    Options = AIMABLE_BONES,
    Default = { "Head" },
    Callback = function(v) Settings.AimbotBones = v end,
})
Bindings[#Bindings+1] = function() wAimbotBones:Set(Settings.AimbotBones) end

AimbotLeft:AddSection("Smoothing")
local wAimbotSmoothing = AimbotLeft:AddSlider({
    Text = "Smoothing", Min = 0, Max = 100, Default = 0, Suffix = "%",
    Callback = function(v) Settings.AimbotSmoothing = v end,
})
Bindings[#Bindings+1] = function() wAimbotSmoothing:Set(Settings.AimbotSmoothing) end

AimbotLeft:AddSection("Misc")
local wAimbotWallcheck = AimbotLeft:AddToggle({
    Text = "Wallcheck", Default = false,
    Callback = function(v) Settings.AimbotWallcheck = v end,
})
Bindings[#Bindings+1] = function() wAimbotWallcheck:Set(Settings.AimbotWallcheck) end

AimbotRight:AddParagraph({
    Title = "Aimbot",
    Text  = "Hold-Keybind zum Zielen. FOV = Suchradius. Smoothing 0 = sofort, 100 = sehr langsam. Aimbones Multi-Select wählbar.",
})

-- =====================
--       MISC TAB
-- =====================
local MiscLeft  = MiscTab:CreateGroup({ Name = "Visual", Side = "Left"  })
local MiscRight = MiscTab:CreateGroup({ Name = "Info",   Side = "Right" })

local _origLighting = nil

local function applyFullbright(enable)
    Settings.FullbrightEnabled = enable
    if enable then
        if not _origLighting then
            _origLighting = {
                Brightness    = Lighting.Brightness,
                ClockTime     = Lighting.ClockTime,
                FogEnd        = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient       = Lighting.Ambient,
            }
        end
        pcall(function()
            Lighting.Brightness    = Settings.FullbrightBrightness
            Lighting.ClockTime     = Settings.FullbrightClockTime
            Lighting.FogEnd        = 786543
            Lighting.GlobalShadows = false
            Lighting.Ambient       = Color3.fromRGB(178, 178, 178)
        end)
    else
        if _origLighting then
            pcall(function()
                Lighting.Brightness    = _origLighting.Brightness
                Lighting.ClockTime     = _origLighting.ClockTime
                Lighting.FogEnd        = _origLighting.FogEnd
                Lighting.GlobalShadows = _origLighting.GlobalShadows
                Lighting.Ambient       = _origLighting.Ambient
            end)
            _origLighting = nil
        end
    end
end

RunService:BindToRenderStep("GsFullbright", Enum.RenderPriority.Last.Value, function()
    if not Settings.FullbrightEnabled then return end
    pcall(function()
        Lighting.Brightness    = Settings.FullbrightBrightness
        Lighting.ClockTime     = Settings.FullbrightClockTime
        Lighting.FogEnd        = 786543
        Lighting.GlobalShadows = false
        Lighting.Ambient       = Color3.fromRGB(178, 178, 178)
    end)
end)

MiscLeft:AddSection("Fullbright")
local wFullbright = MiscLeft:AddToggle({
    Text = "Fullbright", Default = false,
    Callback = applyFullbright,
})
Bindings[#Bindings+1] = function() wFullbright:Set(Settings.FullbrightEnabled) end

local wFBBrightness = MiscLeft:AddSlider({
    Text = "Brightness", Min = 0, Max = 5, Default = 2, Decimals = 1,
    Callback = function(v)
        Settings.FullbrightBrightness = v
        if Settings.FullbrightEnabled then pcall(function() Lighting.Brightness = v end) end
    end,
})
Bindings[#Bindings+1] = function() wFBBrightness:Set(Settings.FullbrightBrightness) end

local wFBClockTime = MiscLeft:AddSlider({
    Text = "Clock Time", Min = 0, Max = 24, Default = 14, Decimals = 1,
    Callback = function(v)
        Settings.FullbrightClockTime = v
        if Settings.FullbrightEnabled then pcall(function() Lighting.ClockTime = v end) end
    end,
})
Bindings[#Bindings+1] = function() wFBClockTime:Set(Settings.FullbrightClockTime) end

MiscRight:AddParagraph({
    Title = "Fullbright",
    Text  = "Erhellt die Map. Original-Lighting wird beim Deaktivieren wiederhergestellt.",
})

-- =====================
--      CONFIG TAB
-- =====================
local ConfigLeft  = ConfigTab:CreateGroup({ Name = "Saved Configs", Side = "Left"  })
local ConfigRight = ConfigTab:CreateGroup({ Name = "Manage",        Side = "Right" })

local function applyBindings()
    for _, fn in ipairs(Bindings) do pcall(fn) end
end

local CFGS_FOLDER   = "Rivals_Configs"
local AUTOLOAD_FILE = CFGS_FOLDER .. "/autoload.txt"
local function cfgPath(n) return CFGS_FOLDER .. "/" .. n .. ".json" end

local function ensureFolder()
    pcall(function()
        if not isfolder(CFGS_FOLDER) then makefolder(CFGS_FOLDER) end
    end)
end

local function serializeValue(v)
    if typeof(v) == "Color3" then
        return { __c=true, r=math.floor(v.R*255+.5), g=math.floor(v.G*255+.5), b=math.floor(v.B*255+.5) }
    elseif type(v) == "table" then
        local t = {}
        for k2, v2 in pairs(v) do t[k2] = serializeValue(v2) end
        return t
    else
        return v
    end
end

local function deserializeValue(v)
    if type(v) == "table" and v.__c then
        return Color3.fromRGB(v.r, v.g, v.b)
    elseif type(v) == "table" then
        local t = {}
        for k2, v2 in pairs(v) do t[k2] = deserializeValue(v2) end
        return t
    else
        return v
    end
end

local function saveConfig(name)
    ensureFolder()
    local t = {}
    for k, v in pairs(Settings) do t[k] = serializeValue(v) end
    pcall(writefile, cfgPath(name), HttpService:JSONEncode(t))
end

local function loadConfig(name)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(cfgPath(name)))
    end)
    if not ok or not data then return false end
    for k, v in pairs(data) do
        if Settings[k] ~= nil then Settings[k] = deserializeValue(v) end
    end
    return true
end

local function listConfigs()
    ensureFolder()
    local out = {}
    pcall(function()
        for _, path in ipairs(listfiles(CFGS_FOLDER)) do
            local n = path:match("[/\\]([^/\\]+)%.json$") or path:match("^([^/\\]+)%.json$")
            if n then table.insert(out, n) end
        end
    end)
    table.sort(out)
    return out
end

local function getAutoload()
    local ok, v = pcall(readfile, AUTOLOAD_FILE)
    return (ok and v and v ~= "") and v or nil
end

local function setAutoload(name)
    ensureFolder()
    pcall(writefile, AUTOLOAD_FILE, name or "")
end

local selectedCfg  = nil
local cfgNameInput
local autoloadLbl

local cfgListBox = ConfigLeft:AddListBox({ Height = 160 })
cfgListBox.OnSelect = function(name)
    selectedCfg = name
    if cfgNameInput then cfgNameInput:Set(name) end
end

local function refreshCfgList()
    cfgListBox:SetItems(listConfigs())
    local al = getAutoload()
    if autoloadLbl then autoloadLbl:SetText("Autoload: " .. (al or "none")) end
    if al then cfgListBox:SetSelected(al) end
end

ConfigLeft:AddSection("Theme")
local wAccentColor = ConfigLeft:AddColorPicker({
    Text     = "Accent Color",
    Default  = MyTheme.Accent,
    Callback = function(c)
        Settings.AccentColor = c
        Window:SetAccent(c)
    end,
})
Bindings[#Bindings+1] = function()
    if Settings.AccentColor then wAccentColor:Set(Settings.AccentColor) end
end

ConfigRight:AddSection("Config")
cfgNameInput = ConfigRight:AddInput({ Text = "Name", Placeholder = "config name…" })

ConfigRight:AddButton({
    Text = "Save",
    Callback = function()
        local name = cfgNameInput:Get():gsub("^%s+",""):gsub("%s+$","")
        if name == "" then return end
        saveConfig(name); refreshCfgList(); cfgListBox:SetSelected(name)
    end,
})
ConfigRight:AddButton({
    Text = "Load",
    Callback = function()
        if not selectedCfg or selectedCfg == "" then return end
        if loadConfig(selectedCfg) then
            applyBindings()
            Lib:Notify({ Title = "Config", Text = "Loaded: " .. selectedCfg, Duration = 3 })
        end
    end,
})
ConfigRight:AddButton({
    Text = "Save As",
    Callback = function()
        local name = cfgNameInput:Get():gsub("^%s+",""):gsub("%s+$","")
        if name == "" then return end
        saveConfig(name); selectedCfg = name
        refreshCfgList(); cfgListBox:SetSelected(name)
        Lib:Notify({ Title = "Config", Text = "Saved as: " .. name, Duration = 3 })
    end,
})

ConfigRight:AddSection("Autoload")
autoloadLbl = ConfigRight:AddLabel("Autoload: none")
ConfigRight:AddButton({
    Text = "Set Autoload",
    Callback = function()
        local name = selectedCfg or cfgNameInput:Get():gsub("^%s+",""):gsub("%s+$","")
        if not name or name == "" then return end
        setAutoload(name); refreshCfgList()
        Lib:Notify({ Title = "Config", Text = "Autoload: " .. name, Duration = 3 })
    end,
})
ConfigRight:AddButton({
    Text = "Clear Autoload",
    Callback = function() setAutoload(nil); refreshCfgList() end,
})
ConfigRight:AddSection("Script")
ConfigRight:AddLabel("Rivals  v1.0")

local unloadScript
ConfigRight:AddButton({
    Text = "Unload Script",
    Callback = function() if unloadScript then unloadScript() end end,
})

refreshCfgList()

-- =====================
--     HELPER FUNCS
-- =====================
local CHAR_RATIO = 0.35

local function getESPColor(player)
    if Settings.ESPUseTeamColor then
        local ok, col = pcall(function() return player.TeamColor.Color end)
        if ok and col then return col end
    end
    return Settings.ESPColor
end

-- Health aus Players-Attributen, Fallback auf Humanoid
local function getHealth(player)
    local hp    = player:GetAttribute("Health")
    local maxHp = player:GetAttribute("MaxHealth")
    if hp and maxHp then
        return hp, math.max(maxHp, 1)
    end
    local char = workspace:FindFirstChild(player.Name)
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, math.max(hum.MaxHealth, 1) end
    return 100, 100
end

local function isAlive(player)
    local hp, _ = getHealth(player)
    return hp > 0
end

local function calcBox(char)
    local ok, bbCF, bbSz = pcall(function() return char:GetBoundingBox() end)
    if ok and bbCF and bbSz and bbSz.Y > 0.3 then
        local center = bbCF.Position
        local spc    = Camera:WorldToViewportPoint(center)
        local spt    = Camera:WorldToViewportPoint(center + Vector3.new(0, bbSz.Y*0.5, 0))
        local spb    = Camera:WorldToViewportPoint(center - Vector3.new(0, bbSz.Y*0.5, 0))
        if spc.Z > 0 then
            local topY = math.min(spt.Y, spb.Y) - 2
            local botY = math.max(spt.Y, spb.Y) + 2
            local h    = math.max(botY - topY, 4)
            local w    = h * CHAR_RATIO
            return spc.X, spc.X - w/2, topY, w, h, true
        end
    end
    -- fallback: Head + LowerTorso
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("LowerTorso") or char:FindFirstChildWhichIsA("BasePart", true)
    if head and root then
        local sp1 = Camera:WorldToViewportPoint(head.Position)
        local sp2 = Camera:WorldToViewportPoint(root.Position)
        if sp1.Z > 0 then
            local topY = math.min(sp1.Y, sp2.Y) - 10
            local botY = math.max(sp1.Y, sp2.Y) + 22
            local h    = botY - topY
            local w    = h * CHAR_RATIO
            local cx   = (sp1.X + sp2.X) / 2
            return cx, cx - w/2, topY, w, h, true
        end
    end
    return 0, 0, 0, 0, 0, false
end

-- =====================
--     ESP OBJECTS
-- =====================
local ESPObjects = {}

local function newText(size, centered)
    local t = newDrawing("Text")
    t.Visible = false; t.Size = size or 13; t.Center = centered ~= false; t.Outline = true
    return t
end

local function createESP(player)
    if player == LocalPlayer then return end
    local o = {}
    o.Box        = newDrawing("Square")
    o.Name       = newText(13, true)
    o.Distance   = newText(12, true)
    o.HealthBG   = newDrawing("Square")
    o.Health     = newDrawing("Square")
    o.Tracer     = newDrawing("Line")
    o.HeadCircle = newDrawing("Circle")

    o.Box.Visible     = false; o.Box.Filled = false; o.Box.Thickness = 1
    o.HealthBG.Visible = false; o.HealthBG.Filled = true
    o.HealthBG.Color   = Color3.fromRGB(0,0,0); o.HealthBG.Transparency = 0.5
    o.Health.Visible   = false; o.Health.Filled = true
    o.Health.Color     = Color3.fromRGB(0, 255, 0)
    o.Tracer.Visible   = false; o.Tracer.Thickness = 1
    o.HeadCircle.Visible = false; o.HeadCircle.Filled = false
    o.HeadCircle.Thickness = 1; o.HeadCircle.NumSides = 32

    o.Bones = {}
    for i = 1, MAX_BONES do
        local l = newDrawing("Line")
        l.Visible = false; l.Thickness = 1
        o.Bones[i] = l
    end

    ESPObjects[player] = o
end

local function removeESP(player)
    local o = ESPObjects[player]
    if not o then return end
    for _, k in ipairs({"Box","Name","Distance","HealthBG","Health","Tracer","HeadCircle"}) do
        if o[k] then pcall(function() o[k]:Remove() end) end
    end
    for _, l in ipairs(o.Bones) do pcall(function() l:Remove() end) end
    ESPObjects[player] = nil
end

local function hideAll(o)
    o.Box.Visible = false; o.Name.Visible = false; o.Distance.Visible = false
    o.Health.Visible = false; o.HealthBG.Visible = false
    o.Tracer.Visible = false; o.HeadCircle.Visible = false
    for _, l in ipairs(o.Bones) do l.Visible = false end
end

for _, p in pairs(Players:GetPlayers()) do createESP(p) end
track(Players.PlayerAdded:Connect(createESP))
track(Players.PlayerRemoving:Connect(removeESP))

-- =====================
--    FOV CIRCLE
-- =====================
local aimbotFOVCircle = Drawing.new("Circle")
aimbotFOVCircle.Filled    = false
aimbotFOVCircle.Thickness = 1
aimbotFOVCircle.NumSides  = 64
aimbotFOVCircle.Color     = Color3.fromRGB(255, 255, 255)
aimbotFOVCircle.Visible   = false
table.insert(Drawings, aimbotFOVCircle)

track(RunService.RenderStepped:Connect(function()
    if Settings.AimbotShowFOV then
        local vp    = Camera.ViewportSize
        local ratio = math.tan(math.rad(Settings.AimbotFOV * 0.5))
                    / math.tan(math.rad(Camera.FieldOfView * 0.5))
        aimbotFOVCircle.Position = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
        aimbotFOVCircle.Radius   = ratio * (vp.Y * 0.5)
        aimbotFOVCircle.Visible  = true
    else
        aimbotFOVCircle.Visible = false
    end
end))

-- =====================
--    MAIN ESP LOOP
-- =====================
track(RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local o = ESPObjects[player]
        if not o then continue end
        pcall(function()
            local char     = workspace:FindFirstChild(player.Name)
            local root     = char and (
                char:FindFirstChild("LowerTorso") or
                char:FindFirstChildWhichIsA("BasePart", true)
            )
            local alive    = isAlive(player)
            local teamSame = Settings.ESPTeamCheck
                             and LocalPlayer.Team ~= nil and player.Team ~= nil
                             and player.Team == LocalPlayer.Team
            local valid    = Settings.ESPEnabled and char and root and alive and not teamSame

            if not valid then hideAll(o); return end

            local dist  = (Camera.CFrame.Position - root.Position).Magnitude
            local col   = getESPColor(player)
            local trans = Settings.ESPColorAlpha

            -- tracer
            do
                local vp = Camera.ViewportSize
                local oy
                if     Settings.ESPTracerOrigin == "Top"    then oy = 0
                elseif Settings.ESPTracerOrigin == "Middle" then oy = vp.Y / 2
                else                                             oy = vp.Y end
                local ox = vp.X / 2

                if Settings.ESPTracers and dist <= Settings.ESPMaxDistance then
                    local sp   = Camera:WorldToViewportPoint(root.Position)
                    local tx, ty = sp.X, sp.Y
                    if sp.Z <= 0 then
                        local scx, scy = vp.X/2, vp.Y/2
                        local ddx = (vp.X-sp.X)-scx; local ddy = (vp.Y-sp.Y)-scy
                        local dlen = math.sqrt(ddx*ddx+ddy*ddy)
                        if dlen < 0.001 then tx,ty = scx, scy-99999
                        else local s = 99999/dlen; tx,ty = scx+ddx*s, scy+ddy*s end
                    end
                    local dx, dy = tx-ox, ty-oy
                    if math.abs(dx) > 0.001 or math.abs(dy) > 0.001 then
                        local tMax = 1
                        if     dx >  0.001 then tMax = math.min(tMax, (vp.X-ox)/dx)
                        elseif dx < -0.001 then tMax = math.min(tMax, (0-ox)/dx)    end
                        if     dy >  0.001 then tMax = math.min(tMax, (vp.Y-oy)/dy)
                        elseif dy < -0.001 then tMax = math.min(tMax, (0-oy)/dy)    end
                        tMax = math.max(0, math.min(1, tMax))
                        tx = ox + dx*tMax; ty = oy + dy*tMax
                    end
                    o.Tracer.From = Vector2.new(ox,oy); o.Tracer.To = Vector2.new(tx,ty)
                    o.Tracer.Color = col; o.Tracer.Transparency = trans; o.Tracer.Visible = true
                else
                    o.Tracer.Visible = false
                end
            end

            -- head circle
            do
                local head = char:FindFirstChild("Head")
                if Settings.ESPHeadCircle and head and dist <= Settings.ESPMaxDistance then
                    local sp = Camera:WorldToViewportPoint(head.Position)
                    if sp.Z > 0 then
                        local pps = Camera.ViewportSize.Y
                                  / (2 * sp.Z * math.tan(math.rad(Camera.FieldOfView) / 2))
                        o.HeadCircle.Position     = Vector2.new(sp.X, sp.Y)
                        o.HeadCircle.Radius       = math.max(2, 0.4 * pps)
                        o.HeadCircle.Color        = col
                        o.HeadCircle.Transparency = trans
                        o.HeadCircle.Visible      = true
                    else
                        o.HeadCircle.Visible = false
                    end
                else
                    o.HeadCircle.Visible = false
                end
            end

            -- skeleton
            if Settings.ESPSkeleton and dist <= Settings.ESPMaxDistance then
                for i, conn in ipairs(SKELETON) do
                    local pA = char:FindFirstChild(conn[1])
                    local pB = char:FindFirstChild(conn[2])
                    if pA and pB then
                        local sp1 = Camera:WorldToViewportPoint(pA.Position)
                        local sp2 = Camera:WorldToViewportPoint(pB.Position)
                        if sp1.Z > 0 and sp2.Z > 0 then
                            o.Bones[i].From         = Vector2.new(sp1.X, sp1.Y)
                            o.Bones[i].To           = Vector2.new(sp2.X, sp2.Y)
                            o.Bones[i].Color        = col
                            o.Bones[i].Transparency = trans
                            o.Bones[i].Visible      = true
                        else
                            o.Bones[i].Visible = false
                        end
                    else
                        o.Bones[i].Visible = false
                    end
                end
            else
                for _, l in ipairs(o.Bones) do l.Visible = false end
            end

            -- 2D box + name + health + distance
            local cx, bx, by, bw, bh, boxOk = calcBox(char)

            if dist > Settings.ESPMaxDistance or not boxOk then
                o.Box.Visible = false; o.Name.Visible = false
                o.Health.Visible = false; o.HealthBG.Visible = false
                o.Distance.Visible = false
                return
            end

            o.Box.Visible     = Settings.ESPBoxes
            o.Box.Position    = Vector2.new(bx, by)
            o.Box.Size        = Vector2.new(bw, bh)
            o.Box.Color       = col; o.Box.Transparency = trans

            o.Name.Visible    = Settings.ESPNames
            o.Name.Text       = player.Name
            o.Name.Position   = Vector2.new(cx, by - 16)
            o.Name.Color      = col; o.Name.Transparency = 1

            local hp, maxHp = getHealth(player)
            local hpFrac    = math.clamp(hp / maxHp, 0, 1)
            o.HealthBG.Visible      = Settings.ESPHealthBar
            o.HealthBG.Position     = Vector2.new(bx - 6, by)
            o.HealthBG.Size         = Vector2.new(4, bh)
            o.HealthBG.Transparency = trans
            o.Health.Visible        = Settings.ESPHealthBar
            o.Health.Position       = Vector2.new(bx - 6, by + bh * (1 - hpFrac))
            o.Health.Size           = Vector2.new(4, bh * hpFrac)
            o.Health.Transparency   = trans
            o.Health.Color          = Color3.fromRGB(
                math.floor((1 - hpFrac) * 255),
                math.floor(hpFrac * 255),
                0
            )

            local belowY = by + bh + 2
            o.Distance.Visible   = Settings.ESPDistance
            o.Distance.Text      = string.format("%.0fm", dist)
            o.Distance.Position  = Vector2.new(cx, belowY)
            o.Distance.Color     = col; o.Distance.Transparency = 1
        end)
    end
end))

-- =====================
--      AIMBOT
-- =====================
local AIMBOT_STEP = "GsAimbot"

local function aimHasLOS(targetPos, targetChar)
    local params = RaycastParams.new()
    local filter = { workspace.CurrentCamera }
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    params.FilterDescendantsInstances = filter
    params.FilterType  = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, targetPos - Camera.CFrame.Position, params)
    if not result then return true end
    return targetChar ~= nil and result.Instance:IsDescendantOf(targetChar)
end

RunService:BindToRenderStep(AIMBOT_STEP, Enum.RenderPriority.Last.Value - 1, function(dt)
    if not (Settings.AimbotEnabled and Settings.AimbotHeld) then return end

    local vp     = Camera.ViewportSize
    local cx, cy = vp.X * 0.5, vp.Y * 0.5
    local fovPx  = math.tan(math.rad(Settings.AimbotFOV * 0.5))
                 / math.tan(math.rad(Camera.FieldOfView * 0.5))
                 * (vp.Y * 0.5)

    local activeBones = Settings.AimbotBones
    if not activeBones or #activeBones == 0 then activeBones = { "Head" } end

    local bestPos, bestDist = nil, math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.ESPTeamCheck and LocalPlayer.Team and player.Team
           and player.Team == LocalPlayer.Team then continue end
        if not isAlive(player) then continue end

        local char = workspace:FindFirstChild(player.Name)
        if not char then continue end
        local ref = char:FindFirstChild("LowerTorso") or char:FindFirstChildWhichIsA("BasePart", true)
        if not ref then continue end
        if (Camera.CFrame.Position - ref.Position).Magnitude > Settings.ESPMaxDistance then continue end

        for _, boneName in ipairs(activeBones) do
            local part = char:FindFirstChild(boneName)
            if not part then continue end

            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen or sp.Z <= 0 then continue end

            local screenDist = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
            if screenDist >= fovPx or screenDist >= bestDist then continue end
            if Settings.AimbotWallcheck and not aimHasLOS(part.Position, char) then continue end

            bestDist = screenDist
            bestPos  = part.Position
        end
    end

    if bestPos then
        local sp     = Camera:WorldToViewportPoint(bestPos)
        local dx     = sp.X - cx
        local dy     = sp.Y - cy
        local s      = 1 - (Settings.AimbotSmoothing / 100) * 0.9
        local frameS = math.clamp(1 - (1-s)^(dt*60), 0.01, 1)
        mousemoverel(dx * frameS, dy * frameS)
    end
end)

-- =====================
--    MENU STATE
-- =====================
local menuOpen    = false
local MENU_CURSOR = "GsRivalsMenuCursor"
local MENU_SINK   = "GsRivalsMenuSink"

local SINK_INPUTS = {
    Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
    Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.R,
    Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.F, Enum.KeyCode.G,
    Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,
}

local _savedMouseBehavior    = nil
local _savedMouseIconEnabled = nil

local function applyMenuState(open)
    menuOpen = open
    if open then
        pcall(function()
            _savedMouseBehavior    = UserInputService.MouseBehavior
            _savedMouseIconEnabled = UserInputService.MouseIconEnabled
        end)
        RunService:BindToRenderStep(MENU_CURSOR, 2001, function()
            pcall(function()
                UserInputService.MouseBehavior    = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            end)
        end)
        pcall(function()
            ContextActionService:BindAction(MENU_SINK, function()
                return Enum.ContextActionResult.Sink
            end, false, table.unpack(SINK_INPUTS))
        end)
    else
        RunService:UnbindFromRenderStep(MENU_CURSOR)
        pcall(function() ContextActionService:UnbindAction(MENU_SINK) end)
        pcall(function()
            if _savedMouseBehavior    ~= nil then UserInputService.MouseBehavior    = _savedMouseBehavior    end
            if _savedMouseIconEnabled ~= nil then UserInputService.MouseIconEnabled = _savedMouseIconEnabled end
        end)
        _savedMouseBehavior    = nil
        _savedMouseIconEnabled = nil
    end
end

track(UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Delete then
        task.defer(function() applyMenuState(Window.Visible == true) end)
    end
end))
task.defer(function() applyMenuState(Window.Visible == true) end)

-- =====================
--       UNLOAD
-- =====================
unloadScript = function()
    for _, conn in pairs(Connections) do pcall(function() conn:Disconnect() end) end
    Connections = {}
    for _, d in pairs(Drawings) do pcall(function() d:Remove() end) end
    Drawings = {}; ESPObjects = {}
    pcall(function() aimbotFOVCircle:Remove() end)
    RunService:UnbindFromRenderStep("GsFullbright")
    RunService:UnbindFromRenderStep(AIMBOT_STEP)
    RunService:UnbindFromRenderStep(MENU_CURSOR)
    pcall(function() ContextActionService:UnbindAction(MENU_SINK) end)
    if Settings.FullbrightEnabled then applyFullbright(false) end
    applyMenuState(false)
    task.defer(function() pcall(function() Window:Destroy() end) end)
end

-- autoload
do
    local al = getAutoload()
    if al and loadConfig(al) then
        applyBindings()
        Lib:Notify({ Title = "Config", Text = "Autoloaded: " .. al, Duration = 4 })
    end
end
