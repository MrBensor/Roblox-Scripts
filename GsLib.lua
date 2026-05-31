--[[
    GsLib v2 – GameSense/Skeet-style UI Framework for Roblox executors
    ───────────────────────────────────────────────────────────────────
    Keine Cheat-Logik. Reines GUI-Framework.

    local Lib    = loadstring(readfile("GsLib.lua"))()
    local Window = Lib:CreateWindow({ Title="...", Accent=Color3..., Size=Vector2... })
    Lib:Notify({ Title="ESP", Text="Enabled", Duration=3 })

    local Tab = Window:CreateTab({ Name="Visuals", Icon=0 })   -- Icon = optional asset id
    local G   = Tab:CreateGroup({ Name="Player ESP", Side="Left" })

    G:AddSection("Category")
    local t = G:AddToggle({ Text="Enable", Default=false, Callback=function(v) end })
    t:AddColorPicker({ Default=Color3.new(1,0,0), Callback=function(c,a) end })
    t:AddKeybind({ Default=Enum.KeyCode.E, Callback=function(active) end })
    G:AddSlider({ Text="FOV", Min=0, Max=180, Default=90, Suffix="°", Callback=function(v) end })
    G:AddDropdown({ Text="Mode", Options={"A","B"}, Default="A", Callback=function(v) end })
    G:AddDropdown({ Text="Flags", Options={"X","Y"}, Multi=true, Callback=function(t) end })
    G:AddColorPicker({ Text="Color", Default=Color3.new(1,0,0), Callback=function(c,a) end })
    G:AddKeybind({ Text="Bind", Default=Enum.KeyCode.F, Callback=function(active) end })
    G:AddButton({ Text="Click", Callback=function() end })
    G:AddLabel("Text here")
    G:AddParagraph({ Title="Title", Text="Multi\nLine..." })
    G:AddInput({ Text="Name", Placeholder="...", Callback=function(s) end })

    Window:SetToggleKey(Enum.KeyCode.Insert)
    Window:Destroy()
]]

local UIS     = game:GetService("UserInputService")
local Tween   = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

-- ══════════════════════════════════════════
--   THEME
-- ══════════════════════════════════════════
local Theme = {
    Accent      = Color3.fromRGB(180, 90, 255),
    Bg          = Color3.fromRGB(22, 22, 26),
    Sidebar     = Color3.fromRGB(15, 15, 18),
    Panel       = Color3.fromRGB(28, 28, 33),
    Elem        = Color3.fromRGB(36, 36, 42),
    ElemHov     = Color3.fromRGB(46, 46, 54),
    Border      = Color3.fromRGB(48, 48, 56),
    BorderDim   = Color3.fromRGB(30, 30, 36),
    Text        = Color3.fromRGB(210, 210, 215),
    Dim         = Color3.fromRGB(128, 128, 138),
    Muted       = Color3.fromRGB(78, 78, 90),
    CheckOff    = Color3.fromRGB(40, 40, 50),
    Font        = Enum.Font.Gotham,
    Bold        = Enum.Font.GothamBold,
    Sz          = 13,
}

-- ══════════════════════════════════════════
--   HELPERS
-- ══════════════════════════════════════════
local function New(class, props, children)
    local o = Instance.new(class)
    if props then
        for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    end
    if children then for _, c in ipairs(children) do c.Parent = o end end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Pad(t, b, l, r, parent)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b),
        PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r),
        Parent = parent,
    })
end

local function Stroke(color, thick, parent)
    return New("UIStroke", {
        Color = color, Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function Corner(r, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function List(dir, pad, halign, valign, parent)
    return New("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, pad or 0),
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = valign or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function getParent()
    local ok, v = pcall(function() return gethui() end)
    if ok and typeof(v) == "Instance" then return v end
    ok, v = pcall(function() return game:GetService("CoreGui") end)
    if ok then return v end
    return LP:WaitForChild("PlayerGui")
end

local function protect(g)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(g) end end)
end

local function tw(inst, time, props)
    Tween:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quad), props):Play()
end

-- ══════════════════════════════════════════
--   NOTIFICATIONS  (independiente ScreenGui)
-- ══════════════════════════════════════════
local NotifGui = New("ScreenGui", {
    Name = "GsLib_Notif",
    ResetOnSpawn = false,
    DisplayOrder = 10000,
    IgnoreGuiInset = true,
})
protect(NotifGui)
NotifGui.Parent = getParent()

local NotifHolder = New("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -12, 1, -12),
    Size = UDim2.fromOffset(280, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Parent = NotifGui,
})
List(Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Right,
     Enum.VerticalAlignment.Bottom, NotifHolder)

local Library = {}
Library.__index = Library

function Library:Notify(o)
    o = o or {}
    local dur    = o.Duration or 4
    local toast  = New("Frame", {
        Size = UDim2.fromOffset(280, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = NotifHolder,
    })
    Corner(3, toast)
    Stroke(Theme.Accent, 1, toast)
    -- left accent bar
    New("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = toast,
    })
    local inner = New("Frame", {
        Size = UDim2.new(1, -14, 0, 0),
        Position = UDim2.fromOffset(10, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = toast,
    })
    Pad(8, 8, 0, 0, inner)
    List(Enum.FillDirection.Vertical, 3, Enum.HorizontalAlignment.Left,
         Enum.VerticalAlignment.Top, inner)
    if o.Title and o.Title ~= "" then
        New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Theme.Bold, TextSize = 13,
            Text = o.Title, TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = inner,
        })
    end
    if o.Text and o.Text ~= "" then
        New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Theme.Font, TextSize = 12,
            Text = o.Text, TextColor3 = Theme.Dim,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = inner,
        })
    end
    tw(toast, 0.18, { BackgroundTransparency = 0 })
    task.delay(dur, function()
        tw(toast, 0.18, { BackgroundTransparency = 1 })
        task.delay(0.2, function() pcall(function() toast:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════
--   COLORPICKER  (popup)
-- ══════════════════════════════════════════
local function mountColorPicker(holder, o, Win)
    o = o or {}
    local col    = o.Default or Color3.new(1, 1, 1)
    local alpha  = (o.Alpha ~= nil) and (o.Alpha) or nil
    local h, s, v = Color3.toHSV(col)

    local swatch = New("TextButton", {
        Size = UDim2.fromOffset(22, 12),
        BackgroundColor3 = col,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        Parent = holder,
    })
    Corner(2, swatch)
    Stroke(Color3.fromRGB(0,0,0), 1, swatch)

    local function rebuild()
        col = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = col
        if o.Callback then pcall(o.Callback, col, alpha) end
    end

    local function openPopup()
        Win.CloseOverlays()
        local h2 = (alpha ~= nil) and 152 or 136
        local pop = New("Frame", {
            Size = UDim2.fromOffset(180, h2),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0, ZIndex = 70, Parent = Win.Overlay,
        })
        Corner(3, pop)
        Stroke(Theme.Accent, 1, pop)

        local ap  = swatch.AbsolutePosition
        local mp  = Win.Main.AbsolutePosition
        local px  = ap.X - mp.X - 154
        if px < 0 then px = ap.X - mp.X end
        pop.Position = UDim2.fromOffset(px, ap.Y - mp.Y + 14)

        -- SV box
        local sv = New("ImageButton", {
            Size = UDim2.fromOffset(140, 120), Position = UDim2.fromOffset(8, 8),
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 71, Parent = pop,
        })
        New("UIGradient", {
            Color = ColorSequence.new(Color3.new(1,1,1)),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1),
            }), Parent = sv,
        })
        New("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0),
            }),
            Parent = New("Frame", {
                Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.new(0,0,0),
                BorderSizePixel = 0, ZIndex = 72, Parent = sv,
            }),
        })
        local cur = New("Frame", {
            Size = UDim2.fromOffset(6,6), AnchorPoint = Vector2.new(.5,.5),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0, ZIndex = 73, Parent = sv,
        })
        Corner(3, cur)
        Stroke(Color3.new(0,0,0), 1, cur)
        local function updateCur() cur.Position = UDim2.new(s, 0, 1 - v, 0) end
        updateCur()

        -- Hue
        local hueBar = New("ImageButton", {
            Size = UDim2.fromOffset(14, 120), Position = UDim2.fromOffset(156, 8),
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 71, Parent = pop,
        })
        New("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
            }), Parent = hueBar,
        })
        local hueCur = New("Frame", {
            Size = UDim2.fromOffset(16,3), AnchorPoint = Vector2.new(.5,.5),
            Position = UDim2.new(.5,0,h,0),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 72, Parent = hueBar,
        })
        Stroke(Color3.new(0,0,0), 1, hueCur)

        local svD, hD = false, false
        local function svUp(p)
            s = math.clamp((p.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            updateCur(); rebuild()
        end
        local function hUp(p)
            h = math.clamp((p.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
            hueCur.Position = UDim2.new(.5, 0, h, 0)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            rebuild()
        end
        sv.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then svD=true; svUp(i.Position) end
        end)
        hueBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then hD=true; hUp(i.Position) end
        end)
        local mc = UIS.InputChanged:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            if svD then svUp(i.Position) end
            if hD  then hUp(i.Position) end
        end)
        local ec = UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then svD=false; hD=false end
        end)
        pop.Destroying:Connect(function()
            pcall(function() mc:Disconnect() end)
            pcall(function() ec:Disconnect() end)
        end)

        if alpha ~= nil then
            local ab = New("Frame", {
                Size = UDim2.fromOffset(162, 8), Position = UDim2.fromOffset(8, 134),
                BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 71, Parent = pop,
            })
            Corner(2, ab)
            local af = New("Frame", {
                Size = UDim2.new(alpha,0,1,0), BackgroundColor3 = Color3.new(0,0,0),
                BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 72, Parent = ab,
            })
            local ab2 = New("TextButton", {
                Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=73, Parent=ab,
            })
            local aD = false
            local function aUp(p)
                alpha = math.clamp((p.X - ab.AbsolutePosition.X) / ab.AbsoluteSize.X, 0, 1)
                af.Size = UDim2.new(alpha,0,1,0); rebuild()
            end
            ab2.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then aD=true; aUp(i.Position) end
            end)
            local c1 = UIS.InputChanged:Connect(function(i)
                if aD and i.UserInputType == Enum.UserInputType.MouseMovement then aUp(i.Position) end
            end)
            local c2 = UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then aD=false end
            end)
            pop.Destroying:Connect(function()
                pcall(function() c1:Disconnect() end)
                pcall(function() c2:Disconnect() end)
            end)
        end
    end

    swatch.MouseButton1Click:Connect(function()
        if #Win.Overlay:GetChildren() > 0 then Win.CloseOverlays() else openPopup() end
    end)

    local P = {}
    function P:Set(c) h,s,v = Color3.toHSV(c); rebuild() end
    function P:Get() return col, alpha end
    return P
end

-- ══════════════════════════════════════════
--   KEYBIND
-- ══════════════════════════════════════════
local function mountKeybind(holder, o, Win)
    o = o or {}
    local key      = o.Default
    local mode     = o.Mode or "Toggle"
    local active   = false
    local listening = false

    local function kName(k)
        if not k then return "none" end
        if typeof(k) == "EnumItem" then
            return k.Name:gsub("MouseButton","mouse"):lower()
        end
        return tostring(k):lower()
    end

    local lbl = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = Theme.Font, TextSize = 11,
        Text = "[" .. kName(key) .. "]",
        TextColor3 = Theme.Dim,
        Parent = holder,
    })

    local function refresh() lbl.Text = "[" .. (listening and "..." or kName(key)) .. "]" end

    New("TextButton", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="",
        Parent = lbl,
    }).MouseButton1Click:Connect(function() listening=true; refresh() end)

    local function matches(i)
        return (typeof(key)=="EnumItem" and key.EnumType==Enum.KeyCode and i.KeyCode==key)
            or (i.UserInputType == key)
    end

    local c1 = UIS.InputBegan:Connect(function(i, gpe)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                key = (i.KeyCode == Enum.KeyCode.Escape) and nil or i.KeyCode
            elseif i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.MouseButton2 then
                key = i.UserInputType
            end
            listening=false; refresh(); return
        end
        if gpe or not key then return end
        if matches(i) then
            if mode=="Toggle" then
                active = not active
                if o.Callback then pcall(o.Callback, active) end
            elseif mode=="Hold" then
                active=true
                if o.Callback then pcall(o.Callback, true) end
            end
        end
    end)
    local c2 = UIS.InputEnded:Connect(function(i)
        if key and matches(i) and mode=="Hold" then
            active=false
            if o.Callback then pcall(o.Callback, false) end
        end
    end)
    table.insert(Win.Conns, c1)
    table.insert(Win.Conns, c2)

    local K = {}
    function K:Set(k) key=k; refresh() end
    function K:Get() return key, mode, active end
    function K:IsActive() return mode=="Always" or active end
    return K
end

-- ══════════════════════════════════════════
--   CREATE WINDOW
-- ══════════════════════════════════════════
function Library:CreateWindow(opts)
    opts = opts or {}
    if opts.Accent then Theme.Accent = opts.Accent end
    local title  = opts.Title  or "gamesense"
    local sz     = opts.Size   or Vector2.new(720, 510)

    local Win   = { Tabs={}, ActiveTab=nil, ToggleKey=opts.ToggleKey or Enum.KeyCode.Insert,
                    Visible=true, Conns={} }

    local gui = New("ScreenGui", {
        Name = "GsLib_" .. math.random(1000,9999),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999, IgnoreGuiInset = true,
    })
    protect(gui)
    gui.Parent  = getParent()
    Win.Gui     = gui

    -- Main
    local main = New("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(sz.X, sz.Y),
        Position = UDim2.new(.5, -sz.X/2, .5, -sz.Y/2),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = gui,
    })
    Corner(4, main)
    Stroke(Color3.fromRGB(55,55,65), 1, main)
    Win.Main = main

    -- top accent line
    New("Frame", {
        Size = UDim2.new(1,0,0,1), BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0, ZIndex = 2, Parent = main,
    })

    -- Sidebar
    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 54, 1, 0),
        BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = main,
    })
    -- right border of sidebar
    New("Frame", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0),
        Size = UDim2.new(0,1,1,0), BackgroundColor3 = Theme.BorderDim,
        BorderSizePixel = 0, Parent = sidebar,
    })
    -- title at very top of sidebar (drag area)
    local sideTitle = New("Frame", {
        Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Parent = sidebar,
    })
    New("TextLabel", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        Font = Theme.Bold, TextSize = 11,
        Text = title:upper():sub(1,5),
        TextColor3 = Theme.Accent, Parent = sideTitle,
    })
    local tabList = New("Frame", {
        Size = UDim2.new(1,0,1,-36), Position = UDim2.fromOffset(0,36),
        BackgroundTransparency = 1, Parent = sidebar,
    })
    List(Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center,
         Enum.VerticalAlignment.Top, tabList)

    -- Content area
    local content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1,-55,1,0), Position = UDim2.fromOffset(55,0),
        BackgroundTransparency = 1, Parent = main,
    })
    Win.Content = content

    -- Overlay for popups
    local overlay = New("Frame", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=50, Parent=main,
    })
    Win.Overlay = overlay
    function Win.CloseOverlays()
        for _, c in ipairs(overlay:GetChildren()) do c:Destroy() end
    end

    -- Drag (sidebar header + content top)
    do
        local drag, ds, sp = false, nil, nil
        local function startDrag(i)
            drag=true; ds=i.Position; sp=main.Position
        end
        sideTitle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(i) end
        end)
        local mc = UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            end
        end)
        local ec = UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
        end)
        table.insert(Win.Conns, mc); table.insert(Win.Conns, ec)
    end

    -- Toggle key
    table.insert(Win.Conns, UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Win.ToggleKey then
            Win.Visible = not Win.Visible
            main.Visible = Win.Visible
            if not Win.Visible then Win.CloseOverlays() end
        end
    end))

    function Win:SetToggleKey(k) Win.ToggleKey = k end
    function Win:Toggle(s)
        if s == nil then s = not Win.Visible end
        Win.Visible = s; main.Visible = s
        if not s then Win.CloseOverlays() end
    end
    function Win:Destroy()
        for _, c in ipairs(Win.Conns) do pcall(function() c:Disconnect() end) end
        pcall(function() gui:Destroy() end)
    end

    -- Tab selection
    local function selectTab(tab)
        for _, t in ipairs(Win.Tabs) do
            t.Page.Visible = (t == tab)
            -- sidebar button: accent bar wenn aktiv
            t.SideBar.BackgroundColor3 = (t == tab) and Theme.Accent or Color3.fromRGB(0,0,0)
            t.SideBar.BackgroundTransparency = (t == tab) and 0 or 1
            t.Btn.TextColor3 = (t == tab) and Theme.Text or Theme.Dim
        end
        Win.ActiveTab = tab
        Win.CloseOverlays()
    end

    -- ─── CreateTab ───────────────────────────────────
    function Win:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Name or "Tab"
        local Tab = { Win = Win }

        -- sidebar button
        local btnFrame = New("Frame", {
            Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1, Parent = tabList,
        })
        -- accent bar on left edge (active indicator)
        local acBar = New("Frame", {
            Size = UDim2.new(0,2,1,0), BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0, BackgroundTransparency = 1, Parent = btnFrame,
        })
        -- hover bg
        local hovBg = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundColor3 = Theme.Elem,
            BackgroundTransparency = 1, BorderSizePixel = 0, Parent = btnFrame,
        })
        -- icon or abbrev
        local iconFrame = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Parent = btnFrame,
        })
        if tabOpts.Icon and tabOpts.Icon ~= 0 then
            New("ImageLabel", {
                AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
                Size = UDim2.fromOffset(22,22), BackgroundTransparency = 1,
                Image = "rbxassetid://" .. tabOpts.Icon,
                ImageColor3 = Theme.Dim, Parent = iconFrame,
            })
        else
            New("TextLabel", {
                Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
                Font = Theme.Bold, TextSize = 11,
                Text = name:upper():sub(1,4),
                TextColor3 = Theme.Dim, Parent = iconFrame,
            })
        end
        local btn = New("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=btnFrame,
        })
        Tab.Btn    = iconFrame:FindFirstChildOfClass("TextLabel") or iconFrame:FindFirstChildOfClass("ImageLabel")
        Tab.SideBar = acBar

        -- tooltip on hover
        btn.MouseEnter:Connect(function()
            tw(hovBg, .1, { BackgroundTransparency = 0.85 })
            if Tab.Btn then Tab.Btn.TextColor3 = Theme.Text end
        end)
        btn.MouseLeave:Connect(function()
            tw(hovBg, .1, { BackgroundTransparency = 1 })
            if Win.ActiveTab ~= Tab and Tab.Btn then Tab.Btn.TextColor3 = Theme.Dim end
        end)
        btn.MouseButton1Click:Connect(function() selectTab(Tab) end)

        -- page (two columns)
        local page = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency=1,
            Visible=false, Parent=content,
        })
        Tab.Page = page

        local function makeCol(xScale, xOff)
            local col = New("ScrollingFrame", {
                Size = UDim2.new(.5,-5,1,-8),
                Position = UDim2.new(xScale, xOff, 0, 6),
                BackgroundTransparency=1, BorderSizePixel=0,
                ScrollBarThickness=3, ScrollBarImageColor3=Theme.Accent,
                CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
                Parent=page,
            })
            List(Enum.FillDirection.Vertical, 7, Enum.HorizontalAlignment.Left,
                 Enum.VerticalAlignment.Top, col)
            return col
        end
        Tab.Left  = makeCol(0,   4)
        Tab.Right = makeCol(.5,  2)

        if not Win.ActiveTab then selectTab(Tab) end
        table.insert(Win.Tabs, Tab)

        -- ─── CreateGroup ─────────────────────────────
        function Tab:CreateGroup(groupOpts)
            groupOpts = groupOpts or {}
            local parentCol = (groupOpts.Side == "Right") and Tab.Right or Tab.Left
            local G = {}

            local box = New("Frame", {
                Size = UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=Theme.Panel, BorderSizePixel=0, Parent=parentCol,
            })
            Corner(3, box)
            Stroke(Theme.BorderDim, 1, box)
            -- accent top line
            New("Frame", {
                Size=UDim2.new(1,0,0,1), BackgroundColor3=Theme.Accent,
                BorderSizePixel=0, ZIndex=2, Parent=box,
            })
            New("TextLabel", {
                Size=UDim2.new(1,-12,0,22), Position=UDim2.fromOffset(8,4),
                BackgroundTransparency=1, Font=Theme.Bold, TextSize=12,
                Text=(groupOpts.Name or "Group"):upper(),
                TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left,
                Parent=box,
            })
            local body = New("Frame", {
                Size=UDim2.new(1,0,0,0), Position=UDim2.fromOffset(0,27),
                AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Parent=box,
            })
            List(Enum.FillDirection.Vertical, 5, Enum.HorizontalAlignment.Left,
                 Enum.VerticalAlignment.Top, body)
            Pad(0, 8, 8, 8, body)

            -- helper: row frame
            local function row(h)
                return New("Frame", {
                    Size=UDim2.new(1,0,0,h or 17), BackgroundTransparency=1, Parent=body,
                })
            end

            -- addon holder (right-aligned, for inline colorpicker/keybind)
            local function addonHolder(parent)
                local h = New("Frame", {
                    AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                    BackgroundTransparency=1, Parent=parent,
                })
                List(Enum.FillDirection.Horizontal, 5,
                     Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, h)
                return h
            end

            -- ═══ SECTION ════════════════════════════
            function G:AddSection(text)
                local r = row(20)
                New("TextLabel", {
                    Size=UDim2.new(1,0,.5,0), BackgroundTransparency=1,
                    Font=Theme.Bold, TextSize=11,
                    Text=(text or ""):upper(), TextColor3=Theme.Accent,
                    TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                New("Frame", {
                    AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0),
                    Size=UDim2.new(1,0,0,1), BackgroundColor3=Theme.BorderDim,
                    BorderSizePixel=0, Parent=r,
                })
            end

            -- ═══ TOGGLE ═════════════════════════════
            -- KEY visual: small solid filled square (8x8, sharp corners)
            function G:AddToggle(o)
                o = o or {}
                local T2 = { Value = o.Default or false }
                local r = row(17)

                -- THE square indicator
                local sq = New("Frame", {
                    Size=UDim2.fromOffset(8,8), Position=UDim2.fromOffset(0,4),
                    BackgroundColor3 = T2.Value and Theme.Accent or Theme.CheckOff,
                    BorderSizePixel=0, Parent=r,
                })
                -- NO corner radius – sharp GameSense squares

                local lbl2 = New("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.fromOffset(14,0),
                    Size=UDim2.new(1,-14,1,0), Font=Theme.Font, TextSize=Theme.Sz,
                    Text=o.Text or "Toggle",
                    TextColor3 = T2.Value and Theme.Text or Theme.Dim,
                    TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })

                local addons = addonHolder(r)

                New("TextButton", {
                    Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=r,
                }).MouseButton1Click:Connect(function()
                    T2:Set(not T2.Value)
                end)

                function T2:Set(vv)
                    T2.Value = vv
                    -- instant color swap – no fade, matches the "clearly on/off" look
                    sq.BackgroundColor3 = vv and Theme.Accent or Theme.CheckOff
                    lbl2.TextColor3     = vv and Theme.Text or Theme.Dim
                    if o.Callback then pcall(o.Callback, vv) end
                end
                function T2:Get() return T2.Value end

                if o.Default then T2:Set(true) end

                function T2:AddColorPicker(co)
                    mountColorPicker(addons, co or {}, Win); return T2
                end
                function T2:AddKeybind(ko)
                    mountKeybind(addons, ko or {}, Win); return T2
                end

                return T2
            end

            -- ═══ SLIDER ═════════════════════════════
            function G:AddSlider(o)
                o = o or {}
                local mn, mx  = o.Min or 0, o.Max or 100
                local dec     = o.Decimals or 0
                local S = { Value = math.clamp(o.Default or mn, mn, mx) }

                local r = row(28)
                local top = New("Frame", {Size=UDim2.new(1,0,0,13), BackgroundTransparency=1, Parent=r})
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Slider",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=top,
                })
                local valLbl = New("TextLabel", {
                    BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0),
                    Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,48,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, TextColor3=Theme.Text,
                    TextXAlignment=Enum.TextXAlignment.Right, Parent=top,
                })
                local track = New("Frame", {
                    Size=UDim2.new(1,0,0,3), Position=UDim2.fromOffset(0,18),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0, Parent=r,
                })
                Corner(2, track)
                local fill = New("Frame", {
                    Size=UDim2.fromScale(0,1), BackgroundColor3=Theme.Accent,
                    BorderSizePixel=0, Parent=track,
                })
                Corner(2, fill)

                local function fmt(vv)
                    if dec>0 then return string.format("%."..dec.."f",vv)..(o.Suffix or "") end
                    return tostring(math.floor(vv))..(o.Suffix or "")
                end
                function S:Set(vv)
                    vv = math.clamp(vv, mn, mx)
                    if dec==0 then vv = math.floor(vv+.5) end
                    S.Value = vv
                    fill.Size = UDim2.fromScale((vv-mn)/(mx-mn), 1)
                    valLbl.Text = fmt(vv)
                    if o.Callback then pcall(o.Callback, vv) end
                end
                function S:Get() return S.Value end

                local drag = false
                local function upd(x)
                    local rel = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
                    S:Set(mn + (mx-mn)*rel)
                end
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(i.Position.X) end
                end)
                local mc = UIS.InputChanged:Connect(function(i)
                    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end
                end)
                local ec = UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
                end)
                table.insert(Win.Conns, mc); table.insert(Win.Conns, ec)
                S:Set(S.Value)
                return S
            end

            -- ═══ DROPDOWN ═══════════════════════════
            function G:AddDropdown(o)
                o = o or {}
                local multi = o.Multi == true
                local D = { Options = o.Options or {} }
                D.Value = multi and {} or (o.Default or (D.Options[1] or ""))
                if multi and type(o.Default)=="table" then
                    for _, d in ipairs(o.Default) do D.Value[d]=true end
                end

                local r = row(32)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,11),
                    Font=Theme.Font, TextSize=11, Text=o.Text or "Dropdown",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local boxBtn = New("TextButton", {
                    Size=UDim2.new(1,0,0,16), Position=UDim2.fromOffset(0,14),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0, Text="",
                    AutoButtonColor=false, Parent=r,
                })
                Corner(2, boxBtn)
                Stroke(Theme.BorderDim, 1, boxBtn)
                local sel = New("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.fromOffset(5,0),
                    Size=UDim2.new(1,-18,1,0), Font=Theme.Font, TextSize=Theme.Sz,
                    TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Left,
                    TextTruncate=Enum.TextTruncate.AtEnd, Parent=boxBtn,
                })
                New("TextLabel", {
                    BackgroundTransparency=1, AnchorPoint=Vector2.new(1,.5),
                    Position=UDim2.new(1,-4,.5,0), Size=UDim2.fromOffset(10,10),
                    Font=Theme.Bold, TextSize=11, Text="▾", TextColor3=Theme.Dim, Parent=boxBtn,
                })

                local function display()
                    if multi then
                        local list = {}
                        for _, opt in ipairs(D.Options) do
                            if D.Value[opt] then table.insert(list, opt) end
                        end
                        sel.Text = #list>0 and table.concat(list,", ") or "none"
                    else
                        sel.Text = tostring(D.Value)
                    end
                end
                local function fire()
                    if not o.Callback then return end
                    if multi then
                        local list={}
                        for _,opt in ipairs(D.Options) do if D.Value[opt] then table.insert(list,opt) end end
                        pcall(o.Callback, list)
                    else
                        pcall(o.Callback, D.Value)
                    end
                end
                local function buildList()
                    Win.CloseOverlays()
                    local lf = New("Frame", {
                        BackgroundColor3=Theme.Panel, BorderSizePixel=0,
                        ZIndex=60, AutomaticSize=Enum.AutomaticSize.Y, Parent=overlay,
                    })
                    Corner(3, lf)
                    Stroke(Theme.Accent, 1, lf)
                    List(Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Left,
                         Enum.VerticalAlignment.Top, lf)
                    local ap = boxBtn.AbsolutePosition
                    local mp = main.AbsolutePosition
                    lf.Position = UDim2.fromOffset(ap.X-mp.X, ap.Y-mp.Y+boxBtn.AbsoluteSize.Y+2)
                    lf.Size     = UDim2.fromOffset(boxBtn.AbsoluteSize.X, 0)

                    for _, opt in ipairs(D.Options) do
                        local ob = New("TextButton", {
                            Size=UDim2.new(1,0,0,18), BackgroundColor3=Theme.Panel,
                            BorderSizePixel=0, AutoButtonColor=false,
                            Font=Theme.Font, TextSize=Theme.Sz, Text="  "..opt,
                            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=61, Parent=lf,
                        })
                        local function refOpt()
                            local on = multi and D.Value[opt] or (D.Value==opt)
                            ob.TextColor3 = on and Theme.Accent or Theme.Dim
                            ob.BackgroundColor3 = on and Theme.Elem or Theme.Panel
                        end
                        refOpt()
                        ob.MouseEnter:Connect(function() ob.BackgroundColor3=Theme.ElemHov end)
                        ob.MouseLeave:Connect(function() refOpt() end)
                        ob.MouseButton1Click:Connect(function()
                            if multi then D.Value[opt]=not D.Value[opt]; refOpt(); display(); fire()
                            else D.Value=opt; display(); fire(); Win.CloseOverlays() end
                        end)
                    end
                end
                boxBtn.MouseButton1Click:Connect(function()
                    if #overlay:GetChildren()>0 then Win.CloseOverlays() else buildList() end
                end)
                function D:Set(vv)
                    if multi then D.Value={}
                        if type(vv)=="table" then for _,d in ipairs(vv) do D.Value[d]=true end end
                    else D.Value=vv end
                    display(); fire()
                end
                function D:Get() return D.Value end
                function D:SetOptions(opts2) D.Options=opts2 or {}; display() end
                display()
                return D
            end

            -- ═══ COLORPICKER standalone ═════════════
            function G:AddColorPicker(o)
                o = o or {}
                local r = row(17)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,-28,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Color",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local h2 = New("Frame", {
                    AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                    BackgroundTransparency=1, Parent=r,
                })
                List(Enum.FillDirection.Horizontal, 0,
                     Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, h2)
                return mountColorPicker(h2, o, Win)
            end

            -- ═══ KEYBIND standalone ═════════════════
            function G:AddKeybind(o)
                o = o or {}
                local r = row(17)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,-60,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Keybind",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local h2 = New("Frame", {
                    AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                    BackgroundTransparency=1, Parent=r,
                })
                List(Enum.FillDirection.Horizontal, 0,
                     Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, h2)
                return mountKeybind(h2, o, Win)
            end

            -- ═══ BUTTON ═════════════════════════════
            function G:AddButton(o)
                o = o or {}
                local r = row(20)
                local btn2 = New("TextButton", {
                    Size=UDim2.fromScale(1,1), BackgroundColor3=Theme.Elem,
                    BorderSizePixel=0, AutoButtonColor=false,
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Button",
                    TextColor3=Theme.Text, Parent=r,
                })
                Corner(2, btn2)
                Stroke(Theme.BorderDim, 1, btn2)
                btn2.MouseEnter:Connect(function() tw(btn2,.1,{BackgroundColor3=Theme.ElemHov}) end)
                btn2.MouseLeave:Connect(function() tw(btn2,.1,{BackgroundColor3=Theme.Elem}) end)
                btn2.MouseButton1Click:Connect(function() if o.Callback then pcall(o.Callback) end end)
                local Btn = {}
                function Btn:SetText(t) btn2.Text=t end
                return Btn
            end

            -- ═══ LABEL ══════════════════════════════
            function G:AddLabel(o)
                local r = row(14)
                local t = (type(o)=="string") and o or (o and o.Text or "")
                local lbl3 = New("TextLabel", {
                    Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
                    Font=Theme.Font, TextSize=Theme.Sz, Text=t,
                    TextColor3=Theme.Muted, TextXAlignment=Enum.TextXAlignment.Left,
                    RichText=true, TextWrapped=true, Parent=r,
                })
                local L = {}
                function L:SetText(s) lbl3.Text=s end
                return L
            end

            -- ═══ PARAGRAPH ══════════════════════════
            function G:AddParagraph(o)
                o = o or {}
                local r = New("Frame", {
                    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundTransparency=1, Parent=body,
                })
                List(Enum.FillDirection.Vertical, 2,
                     Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, r)
                if o.Title and o.Title ~= "" then
                    New("TextLabel", {
                        Size=UDim2.new(1,0,0,14), BackgroundTransparency=1,
                        Font=Theme.Bold, TextSize=12, Text=o.Title,
                        TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                    })
                end
                local bodyLbl = New("TextLabel", {
                    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundTransparency=1, Font=Theme.Font, TextSize=12,
                    Text=o.Text or "", TextColor3=Theme.Dim,
                    TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=r,
                })
                local P2 = {}
                function P2:SetText(s) bodyLbl.Text=s end
                return P2
            end

            -- ═══ INPUT / TEXTBOX ════════════════════
            function G:AddInput(o)
                o = o or {}
                local r = row(32)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,12),
                    Font=Theme.Font, TextSize=11, Text=o.Text or "Input",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local box = New("TextBox", {
                    Size=UDim2.new(1,0,0,16), Position=UDim2.fromOffset(0,14),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0,
                    Font=Theme.Font, TextSize=Theme.Sz,
                    PlaceholderText=o.Placeholder or "",
                    Text=o.Default or "", TextColor3=Theme.Text,
                    PlaceholderColor3=Theme.Muted,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    ClearTextOnFocus=o.ClearOnFocus==true, Parent=r,
                })
                Corner(2, box)
                Stroke(Theme.BorderDim, 1, box)
                Pad(0,0,5,5,box)
                box.FocusLost:Connect(function()
                    if o.Callback then pcall(o.Callback, box.Text) end
                    if o.ClearOnFocus then box.Text="" end
                end)
                local I = {}
                function I:Get() return box.Text end
                function I:Set(t) box.Text=t end
                return I
            end

            return G
        end -- CreateGroup

        return Tab
    end -- CreateTab

    return Win
end -- CreateWindow

return Library
--[[
    GsLib v2 – GameSense/Skeet-style UI Framework for Roblox executors
    ───────────────────────────────────────────────────────────────────
    Keine Cheat-Logik. Reines GUI-Framework.

    local Lib    = loadstring(readfile("GsLib.lua"))()
    local Window = Lib:CreateWindow({ Title="...", Accent=Color3..., Size=Vector2... })
    Lib:Notify({ Title="ESP", Text="Enabled", Duration=3 })

    local Tab = Window:CreateTab({ Name="Visuals", Icon=0 })   -- Icon = optional asset id
    local G   = Tab:CreateGroup({ Name="Player ESP", Side="Left" })

    G:AddSection("Category")
    local t = G:AddToggle({ Text="Enable", Default=false, Callback=function(v) end })
    t:AddColorPicker({ Default=Color3.new(1,0,0), Callback=function(c,a) end })
    t:AddKeybind({ Default=Enum.KeyCode.E, Callback=function(active) end })
    G:AddSlider({ Text="FOV", Min=0, Max=180, Default=90, Suffix="°", Callback=function(v) end })
    G:AddDropdown({ Text="Mode", Options={"A","B"}, Default="A", Callback=function(v) end })
    G:AddDropdown({ Text="Flags", Options={"X","Y"}, Multi=true, Callback=function(t) end })
    G:AddColorPicker({ Text="Color", Default=Color3.new(1,0,0), Callback=function(c,a) end })
    G:AddKeybind({ Text="Bind", Default=Enum.KeyCode.F, Callback=function(active) end })
    G:AddButton({ Text="Click", Callback=function() end })
    G:AddLabel("Text here")
    G:AddParagraph({ Title="Title", Text="Multi\nLine..." })
    G:AddInput({ Text="Name", Placeholder="...", Callback=function(s) end })

    Window:SetToggleKey(Enum.KeyCode.Insert)
    Window:Destroy()
]]

local UIS     = game:GetService("UserInputService")
local Tween   = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

-- ══════════════════════════════════════════
--   THEME
-- ══════════════════════════════════════════
local Theme = {
    Accent      = Color3.fromRGB(180, 90, 255),
    Bg          = Color3.fromRGB(22, 22, 26),
    Sidebar     = Color3.fromRGB(15, 15, 18),
    Panel       = Color3.fromRGB(28, 28, 33),
    Elem        = Color3.fromRGB(36, 36, 42),
    ElemHov     = Color3.fromRGB(46, 46, 54),
    Border      = Color3.fromRGB(48, 48, 56),
    BorderDim   = Color3.fromRGB(30, 30, 36),
    Text        = Color3.fromRGB(210, 210, 215),
    Dim         = Color3.fromRGB(128, 128, 138),
    Muted       = Color3.fromRGB(78, 78, 90),
    CheckOff    = Color3.fromRGB(40, 40, 50),
    Font        = Enum.Font.Gotham,
    Bold        = Enum.Font.GothamBold,
    Sz          = 13,
}

-- ══════════════════════════════════════════
--   HELPERS
-- ══════════════════════════════════════════
local function New(class, props, children)
    local o = Instance.new(class)
    if props then
        for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    end
    if children then for _, c in ipairs(children) do c.Parent = o end end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Pad(t, b, l, r, parent)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b),
        PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r),
        Parent = parent,
    })
end

local function Stroke(color, thick, parent)
    return New("UIStroke", {
        Color = color, Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function Corner(r, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function List(dir, pad, halign, valign, parent)
    return New("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, pad or 0),
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = valign or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function getParent()
    local ok, v = pcall(function() return gethui() end)
    if ok and typeof(v) == "Instance" then return v end
    ok, v = pcall(function() return game:GetService("CoreGui") end)
    if ok then return v end
    return LP:WaitForChild("PlayerGui")
end

local function protect(g)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(g) end end)
end

local function tw(inst, time, props)
    Tween:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quad), props):Play()
end

-- ══════════════════════════════════════════
--   NOTIFICATIONS  (independiente ScreenGui)
-- ══════════════════════════════════════════
local NotifGui = New("ScreenGui", {
    Name = "GsLib_Notif",
    ResetOnSpawn = false,
    DisplayOrder = 10000,
    IgnoreGuiInset = true,
})
protect(NotifGui)
NotifGui.Parent = getParent()

local NotifHolder = New("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -12, 1, -12),
    Size = UDim2.fromOffset(280, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Parent = NotifGui,
})
List(Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Right,
     Enum.VerticalAlignment.Bottom, NotifHolder)

local Library = {}
Library.__index = Library

function Library:Notify(o)
    o = o or {}
    local dur    = o.Duration or 4
    local toast  = New("Frame", {
        Size = UDim2.fromOffset(280, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = NotifHolder,
    })
    Corner(3, toast)
    Stroke(Theme.Accent, 1, toast)
    -- left accent bar
    New("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = toast,
    })
    local inner = New("Frame", {
        Size = UDim2.new(1, -14, 0, 0),
        Position = UDim2.fromOffset(10, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = toast,
    })
    Pad(8, 8, 0, 0, inner)
    List(Enum.FillDirection.Vertical, 3, Enum.HorizontalAlignment.Left,
         Enum.VerticalAlignment.Top, inner)
    if o.Title and o.Title ~= "" then
        New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Theme.Bold, TextSize = 13,
            Text = o.Title, TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = inner,
        })
    end
    if o.Text and o.Text ~= "" then
        New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Theme.Font, TextSize = 12,
            Text = o.Text, TextColor3 = Theme.Dim,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = inner,
        })
    end
    tw(toast, 0.18, { BackgroundTransparency = 0 })
    task.delay(dur, function()
        tw(toast, 0.18, { BackgroundTransparency = 1 })
        task.delay(0.2, function() pcall(function() toast:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════
--   COLORPICKER  (popup)
-- ══════════════════════════════════════════
local function mountColorPicker(holder, o, Win)
    o = o or {}
    local col    = o.Default or Color3.new(1, 1, 1)
    local alpha  = (o.Alpha ~= nil) and (o.Alpha) or nil
    local h, s, v = Color3.toHSV(col)

    local swatch = New("TextButton", {
        Size = UDim2.fromOffset(22, 12),
        BackgroundColor3 = col,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        Parent = holder,
    })
    Corner(2, swatch)
    Stroke(Color3.fromRGB(0,0,0), 1, swatch)

    local function rebuild()
        col = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = col
        if o.Callback then pcall(o.Callback, col, alpha) end
    end

    local function openPopup()
        Win.CloseOverlays()
        local h2 = (alpha ~= nil) and 152 or 136
        local pop = New("Frame", {
            Size = UDim2.fromOffset(180, h2),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0, ZIndex = 70, Parent = Win.Overlay,
        })
        Corner(3, pop)
        Stroke(Theme.Accent, 1, pop)

        local ap  = swatch.AbsolutePosition
        local mp  = Win.Main.AbsolutePosition
        local px  = ap.X - mp.X - 154
        if px < 0 then px = ap.X - mp.X end
        pop.Position = UDim2.fromOffset(px, ap.Y - mp.Y + 14)

        -- SV box
        local sv = New("ImageButton", {
            Size = UDim2.fromOffset(140, 120), Position = UDim2.fromOffset(8, 8),
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 71, Parent = pop,
        })
        New("UIGradient", {
            Color = ColorSequence.new(Color3.new(1,1,1)),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1),
            }), Parent = sv,
        })
        New("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0),
            }),
            Parent = New("Frame", {
                Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.new(0,0,0),
                BorderSizePixel = 0, ZIndex = 72, Parent = sv,
            }),
        })
        local cur = New("Frame", {
            Size = UDim2.fromOffset(6,6), AnchorPoint = Vector2.new(.5,.5),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0, ZIndex = 73, Parent = sv,
        })
        Corner(3, cur)
        Stroke(Color3.new(0,0,0), 1, cur)
        local function updateCur() cur.Position = UDim2.new(s, 0, 1 - v, 0) end
        updateCur()

        -- Hue
        local hueBar = New("ImageButton", {
            Size = UDim2.fromOffset(14, 120), Position = UDim2.fromOffset(156, 8),
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 71, Parent = pop,
        })
        New("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
            }), Parent = hueBar,
        })
        local hueCur = New("Frame", {
            Size = UDim2.fromOffset(16,3), AnchorPoint = Vector2.new(.5,.5),
            Position = UDim2.new(.5,0,h,0),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 72, Parent = hueBar,
        })
        Stroke(Color3.new(0,0,0), 1, hueCur)

        local svD, hD = false, false
        local function svUp(p)
            s = math.clamp((p.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            updateCur(); rebuild()
        end
        local function hUp(p)
            h = math.clamp((p.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
            hueCur.Position = UDim2.new(.5, 0, h, 0)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            rebuild()
        end
        sv.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then svD=true; svUp(i.Position) end
        end)
        hueBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then hD=true; hUp(i.Position) end
        end)
        local mc = UIS.InputChanged:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            if svD then svUp(i.Position) end
            if hD  then hUp(i.Position) end
        end)
        local ec = UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then svD=false; hD=false end
        end)
        pop.Destroying:Connect(function()
            pcall(function() mc:Disconnect() end)
            pcall(function() ec:Disconnect() end)
        end)

        if alpha ~= nil then
            local ab = New("Frame", {
                Size = UDim2.fromOffset(162, 8), Position = UDim2.fromOffset(8, 134),
                BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 71, Parent = pop,
            })
            Corner(2, ab)
            local af = New("Frame", {
                Size = UDim2.new(alpha,0,1,0), BackgroundColor3 = Color3.new(0,0,0),
                BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 72, Parent = ab,
            })
            local ab2 = New("TextButton", {
                Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=73, Parent=ab,
            })
            local aD = false
            local function aUp(p)
                alpha = math.clamp((p.X - ab.AbsolutePosition.X) / ab.AbsoluteSize.X, 0, 1)
                af.Size = UDim2.new(alpha,0,1,0); rebuild()
            end
            ab2.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then aD=true; aUp(i.Position) end
            end)
            local c1 = UIS.InputChanged:Connect(function(i)
                if aD and i.UserInputType == Enum.UserInputType.MouseMovement then aUp(i.Position) end
            end)
            local c2 = UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then aD=false end
            end)
            pop.Destroying:Connect(function()
                pcall(function() c1:Disconnect() end)
                pcall(function() c2:Disconnect() end)
            end)
        end
    end

    swatch.MouseButton1Click:Connect(function()
        if #Win.Overlay:GetChildren() > 0 then Win.CloseOverlays() else openPopup() end
    end)

    local P = {}
    function P:Set(c) h,s,v = Color3.toHSV(c); rebuild() end
    function P:Get() return col, alpha end
    return P
end

-- ══════════════════════════════════════════
--   KEYBIND
-- ══════════════════════════════════════════
local function mountKeybind(holder, o, Win)
    o = o or {}
    local key      = o.Default
    local mode     = o.Mode or "Toggle"
    local active   = false
    local listening = false

    local function kName(k)
        if not k then return "none" end
        if typeof(k) == "EnumItem" then
            return k.Name:gsub("MouseButton","mouse"):lower()
        end
        return tostring(k):lower()
    end

    local lbl = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = Theme.Font, TextSize = 11,
        Text = "[" .. kName(key) .. "]",
        TextColor3 = Theme.Dim,
        Parent = holder,
    })

    local function refresh() lbl.Text = "[" .. (listening and "..." or kName(key)) .. "]" end

    New("TextButton", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="",
        Parent = lbl,
    }).MouseButton1Click:Connect(function() listening=true; refresh() end)

    local function matches(i)
        return (typeof(key)=="EnumItem" and key.EnumType==Enum.KeyCode and i.KeyCode==key)
            or (i.UserInputType == key)
    end

    local c1 = UIS.InputBegan:Connect(function(i, gpe)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                key = (i.KeyCode == Enum.KeyCode.Escape) and nil or i.KeyCode
            elseif i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.MouseButton2 then
                key = i.UserInputType
            end
            listening=false; refresh(); return
        end
        if gpe or not key then return end
        if matches(i) then
            if mode=="Toggle" then
                active = not active
                if o.Callback then pcall(o.Callback, active) end
            elseif mode=="Hold" then
                active=true
                if o.Callback then pcall(o.Callback, true) end
            end
        end
    end)
    local c2 = UIS.InputEnded:Connect(function(i)
        if key and matches(i) and mode=="Hold" then
            active=false
            if o.Callback then pcall(o.Callback, false) end
        end
    end)
    table.insert(Win.Conns, c1)
    table.insert(Win.Conns, c2)

    local K = {}
    function K:Set(k) key=k; refresh() end
    function K:Get() return key, mode, active end
    function K:IsActive() return mode=="Always" or active end
    return K
end

-- ══════════════════════════════════════════
--   CREATE WINDOW
-- ══════════════════════════════════════════
function Library:CreateWindow(opts)
    opts = opts or {}
    if opts.Accent then Theme.Accent = opts.Accent end
    local title  = opts.Title  or "gamesense"
    local sz     = opts.Size   or Vector2.new(720, 510)

    local Win   = { Tabs={}, ActiveTab=nil, ToggleKey=opts.ToggleKey or Enum.KeyCode.Insert,
                    Visible=true, Conns={} }

    local gui = New("ScreenGui", {
        Name = "GsLib_" .. math.random(1000,9999),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999, IgnoreGuiInset = true,
    })
    protect(gui)
    gui.Parent  = getParent()
    Win.Gui     = gui

    -- Main
    local main = New("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(sz.X, sz.Y),
        Position = UDim2.new(.5, -sz.X/2, .5, -sz.Y/2),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = gui,
    })
    Corner(4, main)
    Stroke(Color3.fromRGB(55,55,65), 1, main)
    Win.Main = main

    -- top accent line
    New("Frame", {
        Size = UDim2.new(1,0,0,1), BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0, ZIndex = 2, Parent = main,
    })

    -- Sidebar
    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 54, 1, 0),
        BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = main,
    })
    -- right border of sidebar
    New("Frame", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0),
        Size = UDim2.new(0,1,1,0), BackgroundColor3 = Theme.BorderDim,
        BorderSizePixel = 0, Parent = sidebar,
    })
    -- title at very top of sidebar (drag area)
    local sideTitle = New("Frame", {
        Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Parent = sidebar,
    })
    New("TextLabel", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        Font = Theme.Bold, TextSize = 11,
        Text = title:upper():sub(1,5),
        TextColor3 = Theme.Accent, Parent = sideTitle,
    })
    local tabList = New("Frame", {
        Size = UDim2.new(1,0,1,-36), Position = UDim2.fromOffset(0,36),
        BackgroundTransparency = 1, Parent = sidebar,
    })
    List(Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center,
         Enum.VerticalAlignment.Top, tabList)

    -- Content area
    local content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1,-55,1,0), Position = UDim2.fromOffset(55,0),
        BackgroundTransparency = 1, Parent = main,
    })
    Win.Content = content

    -- Overlay for popups
    local overlay = New("Frame", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=50, Parent=main,
    })
    Win.Overlay = overlay
    function Win.CloseOverlays()
        for _, c in ipairs(overlay:GetChildren()) do c:Destroy() end
    end

    -- Drag (sidebar header + content top)
    do
        local drag, ds, sp = false, nil, nil
        local function startDrag(i)
            drag=true; ds=i.Position; sp=main.Position
        end
        sideTitle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(i) end
        end)
        local mc = UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            end
        end)
        local ec = UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
        end)
        table.insert(Win.Conns, mc); table.insert(Win.Conns, ec)
    end

    -- Toggle key
    table.insert(Win.Conns, UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Win.ToggleKey then
            Win.Visible = not Win.Visible
            main.Visible = Win.Visible
            if not Win.Visible then Win.CloseOverlays() end
        end
    end))

    function Win:SetToggleKey(k) Win.ToggleKey = k end
    function Win:Toggle(s)
        if s == nil then s = not Win.Visible end
        Win.Visible = s; main.Visible = s
        if not s then Win.CloseOverlays() end
    end
    function Win:Destroy()
        for _, c in ipairs(Win.Conns) do pcall(function() c:Disconnect() end) end
        pcall(function() gui:Destroy() end)
    end

    -- Tab selection
    local function selectTab(tab)
        for _, t in ipairs(Win.Tabs) do
            t.Page.Visible = (t == tab)
            -- sidebar button: accent bar wenn aktiv
            t.SideBar.BackgroundColor3 = (t == tab) and Theme.Accent or Color3.fromRGB(0,0,0)
            t.SideBar.BackgroundTransparency = (t == tab) and 0 or 1
            t.Btn.TextColor3 = (t == tab) and Theme.Text or Theme.Dim
        end
        Win.ActiveTab = tab
        Win.CloseOverlays()
    end

    -- ─── CreateTab ───────────────────────────────────
    function Win:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Name or "Tab"
        local Tab = { Win = Win }

        -- sidebar button
        local btnFrame = New("Frame", {
            Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1, Parent = tabList,
        })
        -- accent bar on left edge (active indicator)
        local acBar = New("Frame", {
            Size = UDim2.new(0,2,1,0), BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0, BackgroundTransparency = 1, Parent = btnFrame,
        })
        -- hover bg
        local hovBg = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundColor3 = Theme.Elem,
            BackgroundTransparency = 1, BorderSizePixel = 0, Parent = btnFrame,
        })
        -- icon or abbrev
        local iconFrame = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Parent = btnFrame,
        })
        if tabOpts.Icon and tabOpts.Icon ~= 0 then
            New("ImageLabel", {
                AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
                Size = UDim2.fromOffset(22,22), BackgroundTransparency = 1,
                Image = "rbxassetid://" .. tabOpts.Icon,
                ImageColor3 = Theme.Dim, Parent = iconFrame,
            })
        else
            New("TextLabel", {
                Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
                Font = Theme.Bold, TextSize = 11,
                Text = name:upper():sub(1,4),
                TextColor3 = Theme.Dim, Parent = iconFrame,
            })
        end
        local btn = New("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=btnFrame,
        })
        Tab.Btn    = iconFrame:FindFirstChildOfClass("TextLabel") or iconFrame:FindFirstChildOfClass("ImageLabel")
        Tab.SideBar = acBar

        -- tooltip on hover
        btn.MouseEnter:Connect(function()
            tw(hovBg, .1, { BackgroundTransparency = 0.85 })
            if Tab.Btn then Tab.Btn.TextColor3 = Theme.Text end
        end)
        btn.MouseLeave:Connect(function()
            tw(hovBg, .1, { BackgroundTransparency = 1 })
            if Win.ActiveTab ~= Tab and Tab.Btn then Tab.Btn.TextColor3 = Theme.Dim end
        end)
        btn.MouseButton1Click:Connect(function() selectTab(Tab) end)

        -- page (two columns)
        local page = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency=1,
            Visible=false, Parent=content,
        })
        Tab.Page = page

        local function makeCol(xScale, xOff)
            local col = New("ScrollingFrame", {
                Size = UDim2.new(.5,-5,1,-8),
                Position = UDim2.new(xScale, xOff, 0, 6),
                BackgroundTransparency=1, BorderSizePixel=0,
                ScrollBarThickness=3, ScrollBarImageColor3=Theme.Accent,
                CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
                Parent=page,
            })
            List(Enum.FillDirection.Vertical, 7, Enum.HorizontalAlignment.Left,
                 Enum.VerticalAlignment.Top, col)
            return col
        end
        Tab.Left  = makeCol(0,   4)
        Tab.Right = makeCol(.5,  2)

        if not Win.ActiveTab then selectTab(Tab) end
        table.insert(Win.Tabs, Tab)

        -- ─── CreateGroup ─────────────────────────────
        function Tab:CreateGroup(groupOpts)
            groupOpts = groupOpts or {}
            local parentCol = (groupOpts.Side == "Right") and Tab.Right or Tab.Left
            local G = {}

            local box = New("Frame", {
                Size = UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=Theme.Panel, BorderSizePixel=0, Parent=parentCol,
            })
            Corner(3, box)
            Stroke(Theme.BorderDim, 1, box)
            -- accent top line
            New("Frame", {
                Size=UDim2.new(1,0,0,1), BackgroundColor3=Theme.Accent,
                BorderSizePixel=0, ZIndex=2, Parent=box,
            })
            New("TextLabel", {
                Size=UDim2.new(1,-12,0,22), Position=UDim2.fromOffset(8,4),
                BackgroundTransparency=1, Font=Theme.Bold, TextSize=12,
                Text=(groupOpts.Name or "Group"):upper(),
                TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left,
                Parent=box,
            })
            local body = New("Frame", {
                Size=UDim2.new(1,0,0,0), Position=UDim2.fromOffset(0,27),
                AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Parent=box,
            })
            List(Enum.FillDirection.Vertical, 5, Enum.HorizontalAlignment.Left,
                 Enum.VerticalAlignment.Top, body)
            Pad(0, 8, 8, 8, body)

            -- helper: row frame
            local function row(h)
                return New("Frame", {
                    Size=UDim2.new(1,0,0,h or 17), BackgroundTransparency=1, Parent=body,
                })
            end

            -- addon holder (right-aligned, for inline colorpicker/keybind)
            local function addonHolder(parent)
                local h = New("Frame", {
                    AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                    BackgroundTransparency=1, Parent=parent,
                })
                List(Enum.FillDirection.Horizontal, 5,
                     Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, h)
                return h
            end

            -- ═══ SECTION ════════════════════════════
            function G:AddSection(text)
                local r = row(20)
                New("TextLabel", {
                    Size=UDim2.new(1,0,.5,0), BackgroundTransparency=1,
                    Font=Theme.Bold, TextSize=11,
                    Text=(text or ""):upper(), TextColor3=Theme.Accent,
                    TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                New("Frame", {
                    AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0),
                    Size=UDim2.new(1,0,0,1), BackgroundColor3=Theme.BorderDim,
                    BorderSizePixel=0, Parent=r,
                })
            end

            -- ═══ TOGGLE ═════════════════════════════
            -- KEY visual: small solid filled square (8x8, sharp corners)
            function G:AddToggle(o)
                o = o or {}
                local T2 = { Value = o.Default or false }
                local r = row(17)

                -- THE square indicator
                local sq = New("Frame", {
                    Size=UDim2.fromOffset(8,8), Position=UDim2.fromOffset(0,4),
                    BackgroundColor3 = T2.Value and Theme.Accent or Theme.CheckOff,
                    BorderSizePixel=0, Parent=r,
                })
                -- NO corner radius – sharp GameSense squares

                local lbl2 = New("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.fromOffset(14,0),
                    Size=UDim2.new(1,-14,1,0), Font=Theme.Font, TextSize=Theme.Sz,
                    Text=o.Text or "Toggle",
                    TextColor3 = T2.Value and Theme.Text or Theme.Dim,
                    TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })

                local addons = addonHolder(r)

                New("TextButton", {
                    Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=r,
                }).MouseButton1Click:Connect(function()
                    T2:Set(not T2.Value)
                end)

                function T2:Set(vv)
                    T2.Value = vv
                    -- instant color swap – no fade, matches the "clearly on/off" look
                    sq.BackgroundColor3 = vv and Theme.Accent or Theme.CheckOff
                    lbl2.TextColor3     = vv and Theme.Text or Theme.Dim
                    if o.Callback then pcall(o.Callback, vv) end
                end
                function T2:Get() return T2.Value end

                if o.Default then T2:Set(true) end

                function T2:AddColorPicker(co)
                    mountColorPicker(addons, co or {}, Win); return T2
                end
                function T2:AddKeybind(ko)
                    mountKeybind(addons, ko or {}, Win); return T2
                end

                return T2
            end

            -- ═══ SLIDER ═════════════════════════════
            function G:AddSlider(o)
                o = o or {}
                local mn, mx  = o.Min or 0, o.Max or 100
                local dec     = o.Decimals or 0
                local S = { Value = math.clamp(o.Default or mn, mn, mx) }

                local r = row(28)
                local top = New("Frame", {Size=UDim2.new(1,0,0,13), BackgroundTransparency=1, Parent=r})
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Slider",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=top,
                })
                local valLbl = New("TextLabel", {
                    BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0),
                    Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,48,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, TextColor3=Theme.Text,
                    TextXAlignment=Enum.TextXAlignment.Right, Parent=top,
                })
                local track = New("Frame", {
                    Size=UDim2.new(1,0,0,3), Position=UDim2.fromOffset(0,18),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0, Parent=r,
                })
                Corner(2, track)
                local fill = New("Frame", {
                    Size=UDim2.fromScale(0,1), BackgroundColor3=Theme.Accent,
                    BorderSizePixel=0, Parent=track,
                })
                Corner(2, fill)

                local function fmt(vv)
                    if dec>0 then return string.format("%."..dec.."f",vv)..(o.Suffix or "") end
                    return tostring(math.floor(vv))..(o.Suffix or "")
                end
                function S:Set(vv)
                    vv = math.clamp(vv, mn, mx)
                    if dec==0 then vv = math.floor(vv+.5) end
                    S.Value = vv
                    fill.Size = UDim2.fromScale((vv-mn)/(mx-mn), 1)
                    valLbl.Text = fmt(vv)
                    if o.Callback then pcall(o.Callback, vv) end
                end
                function S:Get() return S.Value end

                local drag = false
                local function upd(x)
                    local rel = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
                    S:Set(mn + (mx-mn)*rel)
                end
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(i.Position.X) end
                end)
                local mc = UIS.InputChanged:Connect(function(i)
                    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end
                end)
                local ec = UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
                end)
                table.insert(Win.Conns, mc); table.insert(Win.Conns, ec)
                S:Set(S.Value)
                return S
            end

            -- ═══ DROPDOWN ═══════════════════════════
            function G:AddDropdown(o)
                o = o or {}
                local multi = o.Multi == true
                local D = { Options = o.Options or {} }
                D.Value = multi and {} or (o.Default or (D.Options[1] or ""))
                if multi and type(o.Default)=="table" then
                    for _, d in ipairs(o.Default) do D.Value[d]=true end
                end

                local r = row(32)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,11),
                    Font=Theme.Font, TextSize=11, Text=o.Text or "Dropdown",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local boxBtn = New("TextButton", {
                    Size=UDim2.new(1,0,0,16), Position=UDim2.fromOffset(0,14),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0, Text="",
                    AutoButtonColor=false, Parent=r,
                })
                Corner(2, boxBtn)
                Stroke(Theme.BorderDim, 1, boxBtn)
                local sel = New("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.fromOffset(5,0),
                    Size=UDim2.new(1,-18,1,0), Font=Theme.Font, TextSize=Theme.Sz,
                    TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Left,
                    TextTruncate=Enum.TextTruncate.AtEnd, Parent=boxBtn,
                })
                New("TextLabel", {
                    BackgroundTransparency=1, AnchorPoint=Vector2.new(1,.5),
                    Position=UDim2.new(1,-4,.5,0), Size=UDim2.fromOffset(10,10),
                    Font=Theme.Bold, TextSize=11, Text="▾", TextColor3=Theme.Dim, Parent=boxBtn,
                })

                local function display()
                    if multi then
                        local list = {}
                        for _, opt in ipairs(D.Options) do
                            if D.Value[opt] then table.insert(list, opt) end
                        end
                        sel.Text = #list>0 and table.concat(list,", ") or "none"
                    else
                        sel.Text = tostring(D.Value)
                    end
                end
                local function fire()
                    if not o.Callback then return end
                    if multi then
                        local list={}
                        for _,opt in ipairs(D.Options) do if D.Value[opt] then table.insert(list,opt) end end
                        pcall(o.Callback, list)
                    else
                        pcall(o.Callback, D.Value)
                    end
                end
                local function buildList()
                    Win.CloseOverlays()
                    local lf = New("Frame", {
                        BackgroundColor3=Theme.Panel, BorderSizePixel=0,
                        ZIndex=60, AutomaticSize=Enum.AutomaticSize.Y, Parent=overlay,
                    })
                    Corner(3, lf)
                    Stroke(Theme.Accent, 1, lf)
                    List(Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Left,
                         Enum.VerticalAlignment.Top, lf)
                    local ap = boxBtn.AbsolutePosition
                    local mp = main.AbsolutePosition
                    lf.Position = UDim2.fromOffset(ap.X-mp.X, ap.Y-mp.Y+boxBtn.AbsoluteSize.Y+2)
                    lf.Size     = UDim2.fromOffset(boxBtn.AbsoluteSize.X, 0)

                    for _, opt in ipairs(D.Options) do
                        local ob = New("TextButton", {
                            Size=UDim2.new(1,0,0,18), BackgroundColor3=Theme.Panel,
                            BorderSizePixel=0, AutoButtonColor=false,
                            Font=Theme.Font, TextSize=Theme.Sz, Text="  "..opt,
                            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=61, Parent=lf,
                        })
                        local function refOpt()
                            local on = multi and D.Value[opt] or (D.Value==opt)
                            ob.TextColor3 = on and Theme.Accent or Theme.Dim
                            ob.BackgroundColor3 = on and Theme.Elem or Theme.Panel
                        end
                        refOpt()
                        ob.MouseEnter:Connect(function() ob.BackgroundColor3=Theme.ElemHov end)
                        ob.MouseLeave:Connect(function() refOpt() end)
                        ob.MouseButton1Click:Connect(function()
                            if multi then D.Value[opt]=not D.Value[opt]; refOpt(); display(); fire()
                            else D.Value=opt; display(); fire(); Win.CloseOverlays() end
                        end)
                    end
                end
                boxBtn.MouseButton1Click:Connect(function()
                    if #overlay:GetChildren()>0 then Win.CloseOverlays() else buildList() end
                end)
                function D:Set(vv)
                    if multi then D.Value={}
                        if type(vv)=="table" then for _,d in ipairs(vv) do D.Value[d]=true end end
                    else D.Value=vv end
                    display(); fire()
                end
                function D:Get() return D.Value end
                function D:SetOptions(opts2) D.Options=opts2 or {}; display() end
                display()
                return D
            end

            -- ═══ COLORPICKER standalone ═════════════
            function G:AddColorPicker(o)
                o = o or {}
                local r = row(17)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,-28,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Color",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local h2 = New("Frame", {
                    AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                    BackgroundTransparency=1, Parent=r,
                })
                List(Enum.FillDirection.Horizontal, 0,
                     Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, h2)
                return mountColorPicker(h2, o, Win)
            end

            -- ═══ KEYBIND standalone ═════════════════
            function G:AddKeybind(o)
                o = o or {}
                local r = row(17)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,-60,1,0),
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Keybind",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local h2 = New("Frame", {
                    AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                    BackgroundTransparency=1, Parent=r,
                })
                List(Enum.FillDirection.Horizontal, 0,
                     Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, h2)
                return mountKeybind(h2, o, Win)
            end

            -- ═══ BUTTON ═════════════════════════════
            function G:AddButton(o)
                o = o or {}
                local r = row(20)
                local btn2 = New("TextButton", {
                    Size=UDim2.fromScale(1,1), BackgroundColor3=Theme.Elem,
                    BorderSizePixel=0, AutoButtonColor=false,
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Button",
                    TextColor3=Theme.Text, Parent=r,
                })
                Corner(2, btn2)
                Stroke(Theme.BorderDim, 1, btn2)
                btn2.MouseEnter:Connect(function() tw(btn2,.1,{BackgroundColor3=Theme.ElemHov}) end)
                btn2.MouseLeave:Connect(function() tw(btn2,.1,{BackgroundColor3=Theme.Elem}) end)
                btn2.MouseButton1Click:Connect(function() if o.Callback then pcall(o.Callback) end end)
                local Btn = {}
                function Btn:SetText(t) btn2.Text=t end
                return Btn
            end

            -- ═══ LABEL ══════════════════════════════
            function G:AddLabel(o)
                local r = row(14)
                local t = (type(o)=="string") and o or (o and o.Text or "")
                local lbl3 = New("TextLabel", {
                    Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
                    Font=Theme.Font, TextSize=Theme.Sz, Text=t,
                    TextColor3=Theme.Muted, TextXAlignment=Enum.TextXAlignment.Left,
                    RichText=true, TextWrapped=true, Parent=r,
                })
                local L = {}
                function L:SetText(s) lbl3.Text=s end
                return L
            end

            -- ═══ PARAGRAPH ══════════════════════════
            function G:AddParagraph(o)
                o = o or {}
                local r = New("Frame", {
                    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundTransparency=1, Parent=body,
                })
                List(Enum.FillDirection.Vertical, 2,
                     Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, r)
                if o.Title and o.Title ~= "" then
                    New("TextLabel", {
                        Size=UDim2.new(1,0,0,14), BackgroundTransparency=1,
                        Font=Theme.Bold, TextSize=12, Text=o.Title,
                        TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                    })
                end
                local bodyLbl = New("TextLabel", {
                    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundTransparency=1, Font=Theme.Font, TextSize=12,
                    Text=o.Text or "", TextColor3=Theme.Dim,
                    TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=r,
                })
                local P2 = {}
                function P2:SetText(s) bodyLbl.Text=s end
                return P2
            end

            -- ═══ INPUT / TEXTBOX ════════════════════
            function G:AddInput(o)
                o = o or {}
                local r = row(32)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,12),
                    Font=Theme.Font, TextSize=11, Text=o.Text or "Input",
                    TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                local box = New("TextBox", {
                    Size=UDim2.new(1,0,0,16), Position=UDim2.fromOffset(0,14),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0,
                    Font=Theme.Font, TextSize=Theme.Sz,
                    PlaceholderText=o.Placeholder or "",
                    Text=o.Default or "", TextColor3=Theme.Text,
                    PlaceholderColor3=Theme.Muted,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    ClearTextOnFocus=o.ClearOnFocus==true, Parent=r,
                })
                Corner(2, box)
                Stroke(Theme.BorderDim, 1, box)
                Pad(0,0,5,5,box)
                box.FocusLost:Connect(function()
                    if o.Callback then pcall(o.Callback, box.Text) end
                    if o.ClearOnFocus then box.Text="" end
                end)
                local I = {}
                function I:Get() return box.Text end
                function I:Set(t) box.Text=t end
                return I
            end

            return G
        end -- CreateGroup

        return Tab
    end -- CreateTab

    return Win
end -- CreateWindow

return Library
