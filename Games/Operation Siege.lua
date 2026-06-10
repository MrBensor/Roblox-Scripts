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
    ESPHitbox       = false,
    ESPFilling      = false,

    GadgetESPEnabled     = false,
    GadgetShow           = {},
    GadgetMaxDistance    = 1000,
    GadgetColor          = Color3.fromRGB(0, 255, 255),
    GadgetColorAlpha     = 1,
    GadgetShowDistance   = true,
    GadgetPerItem        = {},
    GadgetItemColors     = {},
    GadgetItemColorAlpha = {},

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
--  GADGET DEFINITIONS
-- =====================
local GADGET_DEFS = {
    {
        Key     = "Drones",
        Label   = "Drone",
        Section = "Drones",
        GetObjects = function()
            local gw = workspace:FindFirstChild("GAME_WORKSPACE")
            local f  = gw and gw:FindFirstChild("Drones")
            if not f then return {} end
            return f:GetChildren()
        end,
    },
    {
        Key     = "Cameras",
        Label   = "Camera",
        Section = "Cameras",
        GetObjects = function()
            local gw = workspace:FindFirstChild("GAME_WORKSPACE")
            local f  = gw and gw:FindFirstChild("Cameras")
            if not f then return {} end
            return f:GetChildren()
        end,
    },
    {
        Key     = "Inferno Canister",
        Label   = "Inferno Canister",
        Section = "Gadgets",
        GetObjects = function()
            local f = workspace:FindFirstChild("Gadgets")
            if not f then return {} end
            local out = {}
            for _, c in ipairs(f:GetChildren()) do
                if c.Name == "Inferno Canister" then table.insert(out, c) end
            end
            return out
        end,
    },
    {
        Key     = "Proximity Sensor",
        Label   = "Proximity Sensor",
        Section = "Gadgets",
        GetObjects = function()
            local f = workspace:FindFirstChild("Gadgets")
            if not f then return {} end
            local out = {}
            for _, c in ipairs(f:GetChildren()) do
                if c.Name == "Proximity Sensor" then table.insert(out, c) end
            end
            return out
        end,
    },
    {
        Key     = "Barbed Wire",
        Label   = "Barbed Wire",
        Section = "Gadgets",
        GetObjects = function()
            local f = workspace:FindFirstChild("Gadgets")
            if not f then return {} end
            local out = {}
            for _, c in ipairs(f:GetChildren()) do
                if c.Name == "Barbed Wire" then table.insert(out, c) end
            end
            return out
        end,
    },
    {
        Key     = "Bomb A",
        Label   = "Bomb A",
        Section = "Objective",
        GetObjects = function()
            local f = workspace:FindFirstChild("Objective")
            if not f then return {} end
            local out = {}
            for _, c in ipairs(f:GetChildren()) do
                if c.Name == "Bomb A" then table.insert(out, c) end
            end
            return out
        end,
    },
    {
        Key     = "Bomb B",
        Label   = "Bomb B",
        Section = "Objective",
        GetObjects = function()
            local f = workspace:FindFirstChild("Objective")
            if not f then return {} end
            local out = {}
            for _, c in ipairs(f:GetChildren()) do
                if c.Name == "Bomb B" then table.insert(out, c) end
            end
            return out
        end,
    },
}

for _, def in ipairs(GADGET_DEFS) do
    Settings.GadgetShow[def.Key]           = Settings.GadgetShow[def.Key]           or false
    Settings.GadgetPerItem[def.Key]        = Settings.GadgetPerItem[def.Key]        or { hitbox = false, filling = false }
    Settings.GadgetItemColors[def.Key]     = Settings.GadgetItemColors[def.Key]     or Color3.fromRGB(0, 255, 255)
    Settings.GadgetItemColorAlpha[def.Key] = Settings.GadgetItemColorAlpha[def.Key] or 1
end

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
    Title = "Operation Siege",
    Size  = Vector2.new(700, 490),
    Theme = MyTheme,
})
Window:SetToggleKey(Enum.KeyCode.Delete)
Lib:Notify({ Title = "Operation Siege", Text = "Loaded. Delete to toggle.", Duration = 4 })

-- =====================
--        TABS
-- =====================
local AimbotTab = Window:CreateTab({ Name = "Aimbot"     })
local ESPTab    = Window:CreateTab({ Name = "ESP"        })
local GadgetTab = Window:CreateTab({ Name = "Gadget ESP" })
local MiscTab   = Window:CreateTab({ Name = "Misc"       })
local ConfigTab = Window:CreateTab({ Name = "Config"     })

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
    Text  = "Hold-Keybind zum Zielen. FOV = Suchradius. Smoothing 0 = sofort, 100 = sehr langsam. Aimbones Multi-Select waehlbar.",
})

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

local wESPHitbox = ESPLeft:AddToggle({
    Text = "Hitbox (Outline)", Default = false,
    Callback = function(v) Settings.ESPHitbox = v end,
})
Bindings[#Bindings+1] = function() wESPHitbox:Set(Settings.ESPHitbox) end

local wESPFilling = ESPLeft:AddToggle({
    Text = "Hitbox (Fill)", Default = false,
    Callback = function(v) Settings.ESPFilling = v end,
})
Bindings[#Bindings+1] = function() wESPFilling:Set(Settings.ESPFilling) end

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
--    GADGET ESP TAB
-- =====================
local GadgetLeft  = GadgetTab:CreateGroup({ Name = "Gadgets",  Side = "Left"  })
local GadgetRight = GadgetTab:CreateGroup({ Name = "Settings", Side = "Right" })

local wGadgetEnabled = GadgetLeft:AddToggle({
    Text = "Enable Gadget ESP", Default = false,
    Callback = function(v) Settings.GadgetESPEnabled = v end,
})
Bindings[#Bindings+1] = function() wGadgetEnabled:Set(Settings.GadgetESPEnabled) end

-- =====================
--  PER-GADGET POPUP
-- =====================
local wGadgetToggles = {}

local function openGadgetPopup(key)
    Window.CloseOverlays()
    local perItem = Settings.GadgetPerItem[key]
    local rows    = {
        { key = "hitbox",  text = "Hitbox"  },
        { key = "filling", text = "Filling" },
    }

    local PAD     = 8
    local HDR_H   = 20
    local SEP_H   = 1
    local ROW_H   = 18
    local ROW_GAP = 2
    local COLOR_H = 18
    local POP_W   = 154
    local POP_H   = 2*PAD + HDR_H + SEP_H + 4 + #rows*(ROW_H+ROW_GAP) + SEP_H + 4 + COLOR_H

    local mouse = UserInputService:GetMouseLocation()
    local ma    = Window.Main.AbsolutePosition
    local ms    = Window.Main.AbsoluteSize
    local px    = math.clamp(mouse.X - ma.X + 6, 4, ms.X - POP_W - 4)
    local py    = math.clamp(mouse.Y - ma.Y - 4, 4, ms.Y - POP_H - 4)

    local catch = Instance.new("TextButton")
    catch.Size = UDim2.fromScale(1,1); catch.BackgroundTransparency = 1
    catch.Text = ""; catch.ZIndex = 55; catch.AutoButtonColor = false
    catch.Parent = Window.Overlay
    catch.MouseButton1Click:Connect(function() Window.CloseOverlays() end)
    catch.MouseButton2Click:Connect(function() Window.CloseOverlays() end)

    local pop = Instance.new("Frame")
    pop.Size = UDim2.fromOffset(POP_W, POP_H)
    pop.Position = UDim2.fromOffset(px, py)
    pop.BackgroundColor3 = MyTheme.Panel
    pop.BorderSizePixel = 0; pop.ZIndex = 70
    pop.Parent = Window.Overlay
    local stroke = Instance.new("UIStroke")
    stroke.Color = MyTheme.IslandBorder; stroke.Thickness = 1
    stroke.Parent = pop

    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, -8, 0, HDR_H)
    hdr.Position = UDim2.fromOffset(PAD, PAD); hdr.BackgroundTransparency = 1; hdr.ZIndex = 71
    hdr.Font = Enum.Font.GothamBold; hdr.TextSize = 12
    hdr.Text = key; hdr.TextColor3 = MyTheme.Text
    hdr.TextXAlignment = Enum.TextXAlignment.Left; hdr.Parent = pop

    local function mkSep(yPos)
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1, -2*PAD, 0, SEP_H)
        s.Position = UDim2.fromOffset(PAD, yPos)
        s.BackgroundColor3 = MyTheme.Border; s.BorderSizePixel = 0; s.ZIndex = 71
        s.Parent = pop
    end
    local sepY = PAD + HDR_H + 2
    mkSep(sepY)

    local function mkPopToggle(k, text, yOff)
        local state = perItem[k] == true
        local sq = Instance.new("Frame")
        sq.Size = UDim2.fromOffset(8, 8)
        sq.Position = UDim2.fromOffset(PAD, yOff + (ROW_H-8)/2)
        sq.BackgroundColor3 = state and MyTheme.Accent or MyTheme.CheckOff
        sq.BorderSizePixel = 0; sq.ZIndex = 72; sq.Parent = pop

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -(PAD + 14), 0, ROW_H)
        lbl.Position = UDim2.fromOffset(PAD + 14, yOff)
        lbl.BackgroundTransparency = 1; lbl.ZIndex = 72
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
        lbl.Text = text; lbl.TextColor3 = state and MyTheme.Text or MyTheme.Dim
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = pop

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, ROW_H)
        btn.Position = UDim2.fromOffset(0, yOff)
        btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 73
        btn.AutoButtonColor = false; btn.Parent = pop
        btn.MouseButton1Click:Connect(function()
            perItem[k] = not perItem[k]
            local v = perItem[k]
            sq.BackgroundColor3 = v and MyTheme.Accent or MyTheme.CheckOff
            lbl.TextColor3      = v and MyTheme.Text   or MyTheme.Dim
        end)
    end

    local rowsY = sepY + SEP_H + 4
    for i, row in ipairs(rows) do
        mkPopToggle(row.key, row.text, rowsY + (i-1)*(ROW_H+ROW_GAP))
    end

    local sep2Y = rowsY + #rows*(ROW_H+ROW_GAP) + 1
    mkSep(sep2Y)

    local colorY = sep2Y + SEP_H + 4
    local colorLbl = Instance.new("TextLabel")
    colorLbl.Size = UDim2.fromOffset(50, ROW_H)
    colorLbl.Position = UDim2.fromOffset(PAD, colorY)
    colorLbl.BackgroundTransparency = 1; colorLbl.ZIndex = 72
    colorLbl.Font = Enum.Font.Gotham; colorLbl.TextSize = 13
    colorLbl.Text = "Color"; colorLbl.TextColor3 = MyTheme.Dim
    colorLbl.TextXAlignment = Enum.TextXAlignment.Left; colorLbl.Parent = pop

    local swatch = Instance.new("TextButton")
    swatch.Size = UDim2.fromOffset(26, 13)
    swatch.Position = UDim2.fromOffset(PAD + 54, colorY + (ROW_H-13)/2)
    swatch.BackgroundColor3 = Settings.GadgetItemColors[key] or Settings.GadgetColor
    swatch.BorderSizePixel = 0; swatch.ZIndex = 73
    swatch.Text = ""; swatch.AutoButtonColor = false
    local swStroke = Instance.new("UIStroke")
    swStroke.Color = Color3.new(0,0,0); swStroke.Thickness = 1
    swStroke.Parent = swatch; swatch.Parent = pop
    swatch.MouseButton1Click:Connect(function()
        Window.CloseOverlays()
        local w = wGadgetToggles[key]
        if w and w.ColorPicker then w.ColorPicker:Open() end
    end)
end

-- Populate gadget toggles grouped by Section
local lastSection = nil
for _, def in ipairs(GADGET_DEFS) do
    if def.Section ~= lastSection then
        GadgetLeft:AddSection(def.Section)
        lastSection = def.Section
    end

    local w = GadgetLeft:AddToggle({
        Text     = def.Label,
        Default  = false,
        Callback = function(v) Settings.GadgetShow[def.Key] = v end,
    })
    wGadgetToggles[def.Key] = w

    w:AddColorPicker({
        Default  = Color3.fromRGB(0, 255, 255),
        Callback = function(c, a)
            Settings.GadgetItemColors[def.Key]     = c
            Settings.GadgetItemColorAlpha[def.Key] = a or 1
        end,
    })

    local gearBtn = Instance.new("TextButton")
    gearBtn.Size               = UDim2.fromOffset(14, 13)
    gearBtn.BackgroundTransparency = 1
    gearBtn.BorderSizePixel    = 0
    gearBtn.Text               = "\xe2\x9a\x99"
    gearBtn.TextSize           = 11
    gearBtn.Font               = Enum.Font.Gotham
    gearBtn.TextColor3         = MyTheme.Muted
    gearBtn.ZIndex             = 5
    gearBtn.LayoutOrder        = 1
    gearBtn.AutoButtonColor    = false
    gearBtn.MouseButton1Click:Connect(function() openGadgetPopup(def.Key) end)
    gearBtn.Parent = w.AddonHolder

    if w.ClickButton then
        w.ClickButton.MouseButton2Click:Connect(function() openGadgetPopup(def.Key) end)
    end

    Bindings[#Bindings+1] = function() w:Set(Settings.GadgetShow[def.Key] == true) end
end

GadgetLeft:AddSection("Labels")
local wGadgetShowDist = GadgetLeft:AddToggle({
    Text = "Show Distance", Default = true,
    Callback = function(v) Settings.GadgetShowDistance = v end,
})
Bindings[#Bindings+1] = function() wGadgetShowDist:Set(Settings.GadgetShowDistance) end

GadgetRight:AddSection("Color")
local wGadgetColor = GadgetRight:AddColorPicker({
    Text    = "Global Color",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(c, a)
        Settings.GadgetColor      = c
        Settings.GadgetColorAlpha = a or 1
    end,
})
Bindings[#Bindings+1] = function() wGadgetColor:Set(Settings.GadgetColor) end

GadgetRight:AddSection("Range")
local wGadgetMaxDist = GadgetRight:AddSlider({
    Text = "Max Distance", Min = 100, Max = 2000, Default = 1000, Suffix = "m",
    Callback = function(v) Settings.GadgetMaxDistance = v end,
})
Bindings[#Bindings+1] = function() wGadgetMaxDist:Set(Settings.GadgetMaxDistance) end

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

RunService:BindToRenderStep("GsSiegeFullbright", Enum.RenderPriority.Last.Value, function()
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

local CFGS_FOLDER   = "OpSiege_Configs"
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
cfgNameInput = ConfigRight:AddInput({ Text = "Name", Placeholder = "config name..." })

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
ConfigRight:AddLabel("Operation Siege  v1.0")

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

local function getHealth(player)
    local hp    = player:GetAttribute("Health")
    local maxHp = player:GetAttribute("MaxHealth")
    if hp and maxHp then return hp, math.max(maxHp, 1) end
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
local ESPObjects       = {}
local PlayerHighlights = {}

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

    o.Box.Visible      = false; o.Box.Filled = false; o.Box.Thickness = 1
    o.HealthBG.Visible = false; o.HealthBG.Filled = true
    o.HealthBG.Color   = Color3.fromRGB(0,0,0); o.HealthBG.Transparency = 0.5
    o.Health.Visible   = false; o.Health.Filled = true
    o.Health.Color     = Color3.fromRGB(0, 255, 0)
    o.Tracer.Visible   = false; o.Tracer.Thickness = 1
    o.HeadCircle.Visible   = false; o.HeadCircle.Filled = false
    o.HeadCircle.Thickness = 1;    o.HeadCircle.NumSides = 32

    o.Bones = {}
    for i = 1, MAX_BONES do
        local l = newDrawing("Line")
        l.Visible = false; l.Thickness = 1
        o.Bones[i] = l
    end

    local hl
    pcall(function()
        hl = Instance.new("Highlight")
        hl.FillTransparency    = 1
        hl.OutlineTransparency = 1
        hl.Enabled             = false
        hl.Parent              = workspace
    end)
    o.Highlight = hl
    if hl then PlayerHighlights[player] = hl end

    ESPObjects[player] = o
end

local function removeESP(player)
    local o = ESPObjects[player]
    if not o then return end
    for _, k in ipairs({"Box","Name","Distance","HealthBG","Health","Tracer","HeadCircle"}) do
        if o[k] then pcall(function() o[k]:Remove() end) end
    end
    for _, l in ipairs(o.Bones) do pcall(function() l:Remove() end) end
    if o.Highlight then pcall(function() o.Highlight:Destroy() end) end
    PlayerHighlights[player] = nil
    ESPObjects[player] = nil
end

local function hideAll(o)
    o.Box.Visible = false; o.Name.Visible = false; o.Distance.Visible = false
    o.Health.Visible = false; o.HealthBG.Visible = false
    o.Tracer.Visible = false; o.HeadCircle.Visible = false
    for _, l in ipairs(o.Bones) do l.Visible = false end
    if o.Highlight then pcall(function() o.Highlight.Enabled = false end) end
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

            -- Highlight (Hitbox / Fill)
            if o.Highlight then
                pcall(function()
                    local needHL = (Settings.ESPHitbox or Settings.ESPFilling) and dist <= Settings.ESPMaxDistance
                    if needHL then
                        o.Highlight.Adornee             = char
                        o.Highlight.OutlineColor        = col
                        o.Highlight.FillColor           = col
                        o.Highlight.OutlineTransparency = Settings.ESPHitbox  and 0   or 1
                        o.Highlight.FillTransparency    = Settings.ESPFilling and 0.5 or 1
                        o.Highlight.Enabled             = true
                    else
                        o.Highlight.Enabled = false
                    end
                end)
            end

            -- Tracer
            do
                local vp = Camera.ViewportSize
                local oy
                if     Settings.ESPTracerOrigin == "Top"    then oy = 0
                elseif Settings.ESPTracerOrigin == "Middle" then oy = vp.Y / 2
                else                                             oy = vp.Y end
                local ox = vp.X / 2

                if Settings.ESPTracers and dist <= Settings.ESPMaxDistance then
                    local sp     = Camera:WorldToViewportPoint(root.Position)
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

            -- Head circle
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

            -- Skeleton
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

            -- Box + name + health + distance
            local cx, bx, by, bw, bh, boxOk = calcBox(char)

            if dist > Settings.ESPMaxDistance or not boxOk then
                o.Box.Visible = false; o.Name.Visible = false
                o.Health.Visible = false; o.HealthBG.Visible = false
                o.Distance.Visible = false
                return
            end

            o.Box.Visible  = Settings.ESPBoxes
            o.Box.Position = Vector2.new(bx, by)
            o.Box.Size     = Vector2.new(bw, bh)
            o.Box.Color    = col; o.Box.Transparency = trans

            o.Name.Visible  = Settings.ESPNames
            o.Name.Text     = player.Name
            o.Name.Position = Vector2.new(cx, by - 16)
            o.Name.Color    = col; o.Name.Transparency = 1

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

            o.Distance.Visible  = Settings.ESPDistance
            o.Distance.Text     = string.format("%.0fm", dist)
            o.Distance.Position = Vector2.new(cx, by + bh + 2)
            o.Distance.Color    = col; o.Distance.Transparency = 1
        end)
    end
end))

-- =====================
--   GADGET ESP LOOP
-- =====================
local GadgetDrawings       = {}
local GadgetHighlights     = {}
local GadgetHighlightCache = {}
local gadgetList           = {}
local gadgetTimer          = 0
local glowThisFrame        = {}

local function getGadgetDrawing(i)
    if not GadgetDrawings[i] then
        local t = newDrawing("Text")
        t.Size = 13; t.Center = true; t.Outline = true; t.Visible = false
        GadgetDrawings[i] = t
    end
    return GadgetDrawings[i]
end

local function getGadgetHighlight(obj, col, outlineT, fillT)
    if not GadgetHighlights[obj] then
        local h
        pcall(function()
            h = Instance.new("Highlight")
            h.FillTransparency    = 1
            h.OutlineTransparency = 1
            h.Enabled             = false
            h.Parent              = workspace
        end)
        if h then GadgetHighlights[obj] = h end
    end
    local h = GadgetHighlights[obj]
    if not h then return end
    local cache = GadgetHighlightCache[h]
    if not cache or cache.col ~= col or cache.outlineT ~= outlineT or cache.fillT ~= fillT then
        pcall(function()
            h.Adornee             = obj
            h.OutlineColor        = col
            h.FillColor           = col
            h.OutlineTransparency = outlineT
            h.FillTransparency    = fillT
            h.Enabled             = true
        end)
        GadgetHighlightCache[h] = { col = col, outlineT = outlineT, fillT = fillT }
    else
        pcall(function() h.Enabled = true end)
    end
end

track(RunService.RenderStepped:Connect(function(dt)
    if not Settings.GadgetESPEnabled then
        for _, t in pairs(GadgetDrawings)   do t.Visible = false end
        for _, h in pairs(GadgetHighlights) do pcall(function() h.Enabled = false end) end
        return
    end

    gadgetTimer = gadgetTimer + dt
    if gadgetTimer > 0.5 then
        gadgetTimer = 0
        gadgetList  = {}
        for _, def in ipairs(GADGET_DEFS) do
            if Settings.GadgetShow[def.Key] then
                pcall(function()
                    for _, obj in ipairs(def.GetObjects()) do
                        table.insert(gadgetList, { Obj = obj, Key = def.Key, Label = def.Label })
                    end
                end)
            end
        end
    end

    local idx = 0
    glowThisFrame = {}

    for _, entry in ipairs(gadgetList) do
        local obj = entry.Obj
        if not obj or not obj.Parent then continue end

        local perItem = Settings.GadgetPerItem[entry.Key] or {}
        local col     = Settings.GadgetItemColors[entry.Key]     or Settings.GadgetColor
        local alp     = Settings.GadgetItemColorAlpha[entry.Key] or Settings.GadgetColorAlpha

        local pos
        pcall(function()
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or obj:GetPivot().Position
            end
        end)
        if not pos then continue end

        local dist = (Camera.CFrame.Position - pos).Magnitude
        if dist > Settings.GadgetMaxDistance then continue end

        if perItem.hitbox or perItem.filling then
            getGadgetHighlight(obj, col, perItem.hitbox and 0 or 1, perItem.filling and 0.5 or 1)
            glowThisFrame[obj] = true
        end

        local sp = Camera:WorldToViewportPoint(pos)
        if sp.Z <= 0 then continue end

        idx = idx + 1
        local t   = getGadgetDrawing(idx)
        local txt = entry.Label
        if Settings.GadgetShowDistance then
            txt = txt .. " [" .. string.format("%.0fm", dist) .. "]"
        end
        t.Text         = txt
        t.Position     = Vector2.new(sp.X, sp.Y - 14)
        t.Color        = col
        t.Transparency = alp
        t.Visible      = true
    end

    for i = idx + 1, #GadgetDrawings do GadgetDrawings[i].Visible = false end

    for obj, h in pairs(GadgetHighlights) do
        if not glowThisFrame[obj] then
            pcall(function() if h.Enabled then h.Enabled = false end end)
        end
    end
end))

-- =====================
--      AIMBOT
-- =====================
local AIMBOT_STEP = "GsSiegeAimbot"

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
local MENU_CURSOR = "GsSiegeMenuCursor"
local MENU_SINK   = "GsSiegeMenuSink"

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
    for _, hl in pairs(PlayerHighlights) do pcall(function() hl:Destroy() end) end
    PlayerHighlights = {}
    for _, hl in pairs(GadgetHighlights) do pcall(function() hl:Destroy() end) end
    GadgetHighlights = {}
    RunService:UnbindFromRenderStep("GsSiegeFullbright")
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
