--[[
    GsLib v2 – GameSense/Skeet-style UI Framework for Roblox executors
    Modified for Operation One: legend-style group headers, no small corners,
    slider +/- buttons, floating value label, white section text.
]]

local UIS        = game:GetService("UserInputService")
local Tween      = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local LP         = Players.LocalPlayer

local ThemeDefaults = {
    Accent      = Color3.fromRGB(150, 150, 160),
    Bg          = Color3.fromRGB(20, 20, 22),
    OuterBg     = Color3.fromRGB(5, 5, 7),
    Sidebar     = Color3.fromRGB(14, 14, 16),
    Panel       = Color3.fromRGB(26, 26, 28),
    Elem        = Color3.fromRGB(34, 34, 36),
    ElemHov     = Color3.fromRGB(44, 44, 46),
    Border      = Color3.fromRGB(50, 50, 55),
    BorderDim   = Color3.fromRGB(28, 28, 32),
    IslandBorder= Color3.fromRGB(58, 58, 66),
    Text        = Color3.fromRGB(200, 200, 200),
    Dim         = Color3.fromRGB(110, 110, 115),
    Muted       = Color3.fromRGB(70, 70, 75),
    CheckOff    = Color3.fromRGB(38, 38, 42),
    Font        = Enum.Font.Gotham,
    Bold        = Enum.Font.GothamBold,
    Sz          = 13,
    TopBarColors = {
        Color3.fromRGB(120, 120, 140),
        Color3.fromRGB(90,  90, 110),
    },
}

local Theme = {}

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

-- black outline on text labels for contrast (numbers, values, etc.)
local function TextStroke(label, thick)
    return New("UIStroke", {
        Color = Color3.new(0, 0, 0), Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Round,
        Parent = label,
    })
end

-- r < 3: no corner (buttons, sliders, dropdowns stay sharp)
-- r >= 3: keep corner (group boxes, popups, window)
local function Corner(r, parent)
    if r < 3 then return end
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
--   NOTIFICATIONS
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
    Stroke(Theme.IslandBorder, 1, toast)
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
--   COLORPICKER
-- ══════════════════════════════════════════
local function mountColorPicker(holder, o, Win)
    o = o or {}
    local col    = o.Default or Color3.new(1, 1, 1)
    local alpha  = (o.Alpha ~= nil) and (o.Alpha) or nil
    local h, s, v = Color3.toHSV(col)

    local swatch = New("TextButton", {
        Size = UDim2.fromOffset(26, 13),
        BackgroundColor3 = col,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        Parent = holder,
    })
    Stroke(Color3.fromRGB(0,0,0), 1, swatch)

    local function rebuild()
        col = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = col
        if o.Callback then pcall(o.Callback, col, alpha) end
    end

    -- layout constants
    local PAD, SVW, SVH, GAP, HUEW = 8, 150, 128, 8, 14
    local popW = PAD + SVW + GAP + HUEW + PAD

    local function openPopup()
        Win.CloseOverlays()
        local popH = PAD + SVH + (alpha ~= nil and 18 or 0) + PAD

        -- click-outside catcher closes the popup
        New("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, ZIndex = 55, Parent = Win.Overlay,
        }).MouseButton1Click:Connect(function() Win.CloseOverlays() end)

        local pop = New("Frame", {
            Size = UDim2.fromOffset(popW, popH),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0, ZIndex = 70, Parent = Win.Overlay,
        })
        Stroke(Theme.IslandBorder, 1, pop)  -- neutral border, no green, no rounding

        -- position: open left of the swatch, clamped fully inside the window
        local ap = swatch.AbsolutePosition
        local mp = Win.Main.AbsolutePosition
        local ms = Win.Main.AbsoluteSize
        local px = ap.X - mp.X + swatch.AbsoluteSize.X - popW
        px = math.clamp(px, 4, math.max(4, ms.X - popW - 4))
        local py = ap.Y - mp.Y + swatch.AbsoluteSize.Y + 4
        py = math.clamp(py, 4, math.max(4, ms.Y - popH - 4))
        pop.Position = UDim2.fromOffset(px, py)

        -- ── SV (shade) field ──────────────────────
        -- Three layers: base (hue) → white overlay fading right (saturation) → black overlay fading down (value)
        local sv = New("ImageButton", {
            Size = UDim2.fromOffset(SVW, SVH), Position = UDim2.fromOffset(PAD, PAD),
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),  -- base hue colour
            BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 71, Parent = pop,
        })
        -- saturation axis: white (left, S=0) → transparent (right, reveals hue base)
        New("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = New("Frame", {
                Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0, ZIndex = 72, Parent = sv,
            }),
        })
        -- value axis: transparent (top, V=1) → black (bottom, V=0)
        New("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
            }),
            Parent = New("Frame", {
                Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.new(0,0,0),
                BorderSizePixel = 0, ZIndex = 73, Parent = sv,
            }),
        })
        local cur = New("Frame", {
            Size = UDim2.fromOffset(6,6), AnchorPoint = Vector2.new(.5,.5),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0, ZIndex = 74, Parent = sv,  -- above both overlays
        })
        Corner(3, cur)
        Stroke(Color3.new(0,0,0), 1, cur)
        local function updateCur() cur.Position = UDim2.new(s, 0, 1 - v, 0) end
        updateCur()

        -- ── hue bar (red → … → red) ───────────────
        local hueBar = New("ImageButton", {
            Size = UDim2.fromOffset(HUEW, SVH), Position = UDim2.fromOffset(PAD + SVW + GAP, PAD),
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
            Size = UDim2.fromOffset(HUEW+4,3), AnchorPoint = Vector2.new(.5,.5),
            Position = UDim2.new(.5,0,h,0),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 72, Parent = hueBar,
        })
        Stroke(Color3.new(0,0,0), 1, hueCur)

        -- ── alpha (transparency) bar — only if Alpha was supplied ──
        local alphaFrame, alphaCur
        local function refreshAlphaColor()
            if alphaFrame then alphaFrame.BackgroundColor3 = Color3.fromHSV(h, s, v) end
        end
        if alpha ~= nil then
            local ab = New("ImageButton", {
                Size = UDim2.fromOffset(SVW + GAP + HUEW, 10),
                Position = UDim2.fromOffset(PAD, PAD + SVH + 8),
                BackgroundColor3 = Color3.fromRGB(20,20,20),
                BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 71, Parent = pop,
            })
            alphaFrame = New("Frame", {
                Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromHSV(h,s,v),
                BorderSizePixel = 0, ZIndex = 72, Parent = ab,
            })
            New("UIGradient", {     -- left transparent → right opaque
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0),
                }), Parent = alphaFrame,
            })
            alphaCur = New("Frame", {
                Size = UDim2.fromOffset(3, 14), AnchorPoint = Vector2.new(.5,.5),
                Position = UDim2.new(alpha,0,.5,0),
                BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 73, Parent = ab,
            })
            Stroke(Color3.new(0,0,0), 1, alphaCur)

            local aD = false
            local function aUp(p)
                alpha = math.clamp((p.X - ab.AbsolutePosition.X) / ab.AbsoluteSize.X, 0, 1)
                alphaCur.Position = UDim2.new(alpha,0,.5,0); rebuild()
            end
            ab.InputBegan:Connect(function(i)
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

        local svD, hD = false, false
        local function svUp(p)
            s = math.clamp((p.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            updateCur(); refreshAlphaColor(); rebuild()
        end
        local function hUp(p)
            h = math.clamp((p.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
            hueCur.Position = UDim2.new(.5, 0, h, 0)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            refreshAlphaColor(); rebuild()
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
    for k, v in pairs(ThemeDefaults) do Theme[k] = v end
    if opts.Accent then Theme.Accent = opts.Accent end
    if opts.Theme  then
        for k, v in pairs(opts.Theme) do Theme[k] = v end
    end
    local title  = opts.Title  or "gamesense"
    local sz     = opts.Size   or Vector2.new(720, 510)

    local Win   = { Tabs={}, ActiveTab=nil, ToggleKey=opts.ToggleKey or Enum.KeyCode.Insert,
                    Visible=true, Conns={}, Accents={} }

    -- every accent-coloured element registers a closure here; SetAccent re-runs them
    -- so a single accent variable drives the whole UI and is changeable at runtime.
    local function regAccent(fn) table.insert(Win.Accents, fn); pcall(fn) end

    local gui = New("ScreenGui", {
        Name = "GsLib_" .. math.random(1000,9999),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999, IgnoreGuiInset = true,
    })
    protect(gui)
    gui.Parent  = getParent()
    Win.Gui     = gui

    local outerBorder = New("Frame", {
        Name = "OuterBorder",
        Size = UDim2.fromOffset(sz.X + 10, sz.Y + 10),
        Position = UDim2.new(.5, -sz.X/2 - 5, .5, -sz.Y/2 - 5),
        BackgroundColor3 = Theme.OuterBg,
        BorderSizePixel = 0,
        Parent = gui,
    })
    Stroke(Theme.Border, 2, outerBorder)
    Win.OuterBorder = outerBorder

    local main = New("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(sz.X, sz.Y),
        Position = UDim2.new(.5, -sz.X/2, .5, -sz.Y/2),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
        ClipsDescendants = true, Active = true, Parent = gui,
    })
    Stroke(Theme.Border, 2, main)
    Win.Main = main

    local rainbowBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 2, Parent = main,
    })
    do
        local cols = Theme.TopBarColors
        local pts  = {}
        for i, c in ipairs(cols) do
            pts[i] = ColorSequenceKeypoint.new((i - 1) / math.max(#cols - 1, 1), c)
        end
        New("UIGradient", { Color = ColorSequence.new(pts), Parent = rainbowBar })
    end

    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 54, 1, 0),
        BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = main,
    })
    local sidebarBorder = New("Frame", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0),
        Size = UDim2.new(0,1,1,0), BackgroundColor3 = Theme.BorderDim,
        BorderSizePixel = 0, ZIndex = 1, Parent = sidebar,
    })
    Win._SidebarBorder = sidebarBorder
    local sideTitle = New("Frame", {
        Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Parent = sidebar,
    })
    local sideTitleLbl = New("TextLabel", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        Font = Theme.Bold, TextSize = 11,
        Text = title:upper():sub(1,5),
        TextColor3 = Theme.Accent, Parent = sideTitle,
    })
    regAccent(function() sideTitleLbl.TextColor3 = Theme.Accent end)
    local tabList = New("Frame", {
        Size = UDim2.new(1,0,1,-36), Position = UDim2.fromOffset(0,36),
        BackgroundTransparency = 1, ZIndex = 2, Parent = sidebar,
    })
    List(Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center,
         Enum.VerticalAlignment.Top, tabList)

    local content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1,-55,1,0), Position = UDim2.fromOffset(55,0),
        BackgroundTransparency = 1, Parent = main,
    })
    Win.Content = content

    local overlay = New("Frame", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=50, Parent=main,
    })
    Win.Overlay = overlay
    function Win.CloseOverlays()
        for _, c in ipairs(overlay:GetChildren()) do c:Destroy() end
    end

    local function syncBorder(mainPos)
        outerBorder.Position = UDim2.new(
            mainPos.X.Scale, mainPos.X.Offset - 5,
            mainPos.Y.Scale, mainPos.Y.Offset - 5
        )
    end

    do
        local drag, ds, sp = false, nil, nil
        -- drag from anywhere on the window. Buttons, dropdowns, text boxes and the
        -- slider track are interactive (they sink the click) so they never start a drag,
        -- and we ignore drags while a popup (dropdown / colorpicker) is open.
        -- Exposed so the scrolling columns can hook it too (a ScrollingFrame may sink
        -- the click before it bubbles up to Main).
        local function startDrag(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
               and not drag and #overlay:GetChildren() == 0 then
                drag=true; ds=i.Position; sp=main.Position
            end
        end
        Win._startDrag = startDrag
        main.InputBegan:Connect(startDrag)
        local mc = UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                local newPos = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
                main.Position = newPos
                syncBorder(newPos)
            end
        end)
        local ec = UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
        end)
        table.insert(Win.Conns, mc); table.insert(Win.Conns, ec)
    end

    table.insert(Win.Conns, UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Win.ToggleKey then
            Win.Visible = not Win.Visible
            main.Visible = Win.Visible
            outerBorder.Visible = Win.Visible
            if not Win.Visible then Win.CloseOverlays() end
        end
    end))

    function Win:SetToggleKey(k) Win.ToggleKey = k end
    function Win:Toggle(s)
        if s == nil then s = not Win.Visible end
        Win.Visible = s
        main.Visible = s
        outerBorder.Visible = s
        if not s then Win.CloseOverlays() end
    end
    local selectTab  -- forward declaration (SetAccent refreshes the active tab)
    function Win:SetAccent(c)
        Theme.Accent = c
        for _, fn in ipairs(Win.Accents) do pcall(fn) end
        if Win.ActiveTab then selectTab(Win.ActiveTab) end
    end
    function Win:Destroy()
        for _, c in ipairs(Win.Conns) do pcall(function() c:Disconnect() end) end
        pcall(function() gui:Destroy() end)
    end

    function selectTab(tab)
        for _, t in ipairs(Win.Tabs) do
            local active = (t == tab)
            t.Page.Visible = active
            t.SideBar.BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(0,0,0)
            t.SideBar.BackgroundTransparency = active and 0 or 1
            if t.Btn then t.Btn.TextColor3 = active and Theme.Text or Theme.Dim end
            t.ActiveBg.BackgroundTransparency = active and 0 or 1
            t.BorderCover.BackgroundColor3 = active and Theme.Bg or Theme.BorderDim
            t.TopLine.BackgroundTransparency = active and 0 or 1
            t.BotLine.BackgroundTransparency = active and 0 or 1
        end
        Win.ActiveTab = tab
        Win.CloseOverlays()
    end

    function Win:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Name or "Tab"
        local Tab = { Win = Win }

        local btnFrame = New("Frame", {
            Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1, Parent = tabList,
        })
        local activeBg = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundColor3 = Theme.Bg,
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Parent = btnFrame,
        })
        Tab.ActiveBg = activeBg
        local acBar = New("Frame", {
            Size = UDim2.new(0,2,1,0), BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 3, Parent = btnFrame,
        })
        local hovBg = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundColor3 = Theme.Elem,
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2, Parent = btnFrame,
        })
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
        local borderCover = New("Frame", {
            AnchorPoint      = Vector2.new(1, 0),
            Position         = UDim2.new(1, 0, 0, 0),
            Size             = UDim2.new(0, 1, 1, 0),
            BackgroundColor3 = Theme.BorderDim,
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = btnFrame,
        })
        Tab.BorderCover = borderCover

        local topLine = New("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Theme.BorderDim,
            BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 4, Parent = btnFrame,
        })
        local botLine = New("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.BorderDim,
            BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = 4, Parent = btnFrame,
        })
        Tab.TopLine = topLine
        Tab.BotLine = botLine

        local btn = New("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=btnFrame,
        })
        Tab.Btn     = iconFrame:FindFirstChildOfClass("TextLabel") or iconFrame:FindFirstChildOfClass("ImageLabel")
        Tab.SideBar = acBar

        btn.MouseEnter:Connect(function()
            tw(hovBg, .12, { BackgroundTransparency = 0.82 })
            if Win.ActiveTab ~= Tab and Tab.Btn then
                tw(Tab.Btn, .12, { TextColor3 = Theme.Text })
            end
        end)
        btn.MouseLeave:Connect(function()
            tw(hovBg, .12, { BackgroundTransparency = 1 })
            if Win.ActiveTab ~= Tab and Tab.Btn then
                tw(Tab.Btn, .12, { TextColor3 = Theme.Dim })
            end
        end)
        btn.MouseButton1Click:Connect(function() selectTab(Tab) end)

        local page = New("Frame", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency=1,
            Visible=false, Parent=content,
        })
        Tab.Page = page

        local function makeCol(xScale, xOff)
            local col = New("ScrollingFrame", {
                Size = UDim2.new(.5, -14, 1, -18),
                Position = UDim2.new(xScale, xOff, 0, 10),
                BackgroundTransparency=1, BorderSizePixel=0,
                ScrollBarThickness=3, ScrollBarImageColor3=Theme.Accent,
                ScrollingDirection=Enum.ScrollingDirection.Y,
                CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
                Parent=page,
            })
            regAccent(function() col.ScrollBarImageColor3 = Theme.Accent end)
            -- top room so the headers sit on the border without being clipped; left/right
            -- room so the island side borders aren't cut off by the scroll clip
            Pad(10, 10, 2, 4, col)
            List(Enum.FillDirection.Vertical, 9, Enum.HorizontalAlignment.Left,
                 Enum.VerticalAlignment.Top, col)

            -- scroll arrows (left of the scrollbar): ▲ at top, ▼ at bottom
            local arrowLayer = New("Frame", {
                Size = col.Size, Position = col.Position,
                BackgroundTransparency=1, ZIndex=8, Parent=page,
            })
            local function arrow(sym, anchorY, posY)
                local a = New("TextLabel", {
                    AnchorPoint=Vector2.new(1,anchorY), Position=UDim2.new(1,-1,posY,0),
                    Size=UDim2.fromOffset(9,9), BackgroundTransparency=1,
                    Font=Theme.Bold, TextSize=10, Text=sym,
                    TextColor3=Color3.new(1,1,1), Visible=false, ZIndex=9, Parent=arrowLayer,
                })
                TextStroke(a, 1)
                return a
            end
            local upArrow   = arrow("▲", 0, 0)
            local downArrow = arrow("▼", 1, 1)
            local function refreshArrows()
                local maxScroll = col.AbsoluteCanvasSize.Y - col.AbsoluteWindowSize.Y
                upArrow.Visible   = maxScroll > 1 and col.CanvasPosition.Y > 1
                downArrow.Visible = maxScroll > 1 and col.CanvasPosition.Y < (maxScroll - 1)
            end
            col:GetPropertyChangedSignal("CanvasPosition"):Connect(refreshArrows)
            col:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(refreshArrows)
            col:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(refreshArrows)
            task.defer(refreshArrows)

            -- let dragging start from empty space inside the column too (skip the
            -- scrollbar strip on the right edge)
            col.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                   and (i.Position.X - col.AbsolutePosition.X) < (col.AbsoluteSize.X - 8) then
                    Win._startDrag(i)
                end
            end)
            return col
        end
        Tab.Left  = makeCol(0,  12)
        Tab.Right = makeCol(.5,  8)

        table.insert(Win.Tabs, Tab)
        if not Win.ActiveTab then selectTab(Tab) end

        -- ─── CreateGroup ─────────────────────────────
        function Tab:CreateGroup(groupOpts)
            groupOpts = groupOpts or {}
            local parentCol = (groupOpts.Side == "Right") and Tab.Right or Tab.Left
            local G = {}

            -- sharp island (no rounding, no UIStroke); border is drawn as 1px frames
            local box = New("Frame", {
                Size = UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=Theme.Panel, BorderSizePixel=0, Parent=parentCol,
            })

            -- island header: plain text sitting on the top border, no background box
            local header = New("TextLabel", {
                AnchorPoint=Vector2.new(0,0.5),
                Size=UDim2.new(0,0,0,14), Position=UDim2.new(0,11,0,0),
                AutomaticSize=Enum.AutomaticSize.X,
                BackgroundTransparency=1, Font=Theme.Bold, TextSize=12,
                Text=(groupOpts.Name or "Group"):upper(),
                TextColor3=Color3.new(1,1,1), TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=4, Parent=box,
            })

            -- 1px border on all four sides; the top line has a gap where the header sits
            local bc = Theme.IslandBorder
            New("Frame", { Size=UDim2.new(0,1,1,0), Position=UDim2.new(0,0,0,0),
                BackgroundColor3=bc, BorderSizePixel=0, ZIndex=2, Parent=box })            -- left
            New("Frame", { Size=UDim2.new(0,1,1,0), AnchorPoint=Vector2.new(1,0),
                Position=UDim2.new(1,0,0,0), BackgroundColor3=bc, BorderSizePixel=0, ZIndex=2, Parent=box }) -- right
            New("Frame", { Size=UDim2.new(1,0,0,1), AnchorPoint=Vector2.new(0,1),
                Position=UDim2.new(0,0,1,0), BackgroundColor3=bc, BorderSizePixel=0, ZIndex=2, Parent=box }) -- bottom
            New("Frame", { Size=UDim2.new(0,7,0,1), Position=UDim2.new(0,0,0,0),
                BackgroundColor3=bc, BorderSizePixel=0, ZIndex=2, Parent=box })            -- top stub (left of header)
            local topRight = New("Frame", { Size=UDim2.new(1,-30,0,1), AnchorPoint=Vector2.new(1,0),
                Position=UDim2.new(1,0,0,0), BackgroundColor3=bc, BorderSizePixel=0, ZIndex=2, Parent=box }) -- top (right of header)
            local function updateTop()
                topRight.Size = UDim2.new(1, -(11 + header.AbsoluteSize.X + 4), 0, 1)
            end
            header:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTop)
            task.defer(updateTop)

            local body = New("Frame", {
                Size=UDim2.new(1,0,0,0), Position=UDim2.fromOffset(0,10),
                AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Parent=box,
            })
            List(Enum.FillDirection.Vertical, 5, Enum.HorizontalAlignment.Left,
                 Enum.VerticalAlignment.Top, body)
            Pad(0, 8, 8, 8, body)

            local function row(h)
                return New("Frame", {
                    Size=UDim2.new(1,0,0,h or 17), BackgroundTransparency=1, Parent=body,
                })
            end

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
            -- simple white label, no underline
            function G:AddSection(text)
                local r = row(16)
                New("TextLabel", {
                    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                    Font=Theme.Bold, TextSize=11,
                    Text=(text or ""):upper(), TextColor3=Color3.new(1,1,1),
                    TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
            end

            -- ═══ TOGGLE ═════════════════════════════
            function G:AddToggle(o)
                o = o or {}
                local T2 = { Value = o.Default or false }
                local r = row(17)

                local sq = New("Frame", {
                    Size=UDim2.fromOffset(8,8), Position=UDim2.fromOffset(0,4),
                    BackgroundColor3 = T2.Value and Theme.Accent or Theme.CheckOff,
                    BorderSizePixel=0, Parent=r,
                })

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
                    sq.BackgroundColor3 = vv and Theme.Accent or Theme.CheckOff
                    lbl2.TextColor3     = vv and Theme.Text or Theme.Dim
                    if o.Callback then pcall(o.Callback, vv) end
                end
                function T2:Get() return T2.Value end

                if o.Default then T2:Set(true) end
                regAccent(function() if T2.Value then sq.BackgroundColor3 = Theme.Accent end end)

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

                local r = row(34)
                -- name only (the value lives ON the slider, nowhere else)
                New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,0,13),
                    Font=Theme.Font, TextSize=Theme.Sz, Text=o.Text or "Slider",
                    TextColor3=Color3.new(1,1,1), TextXAlignment=Enum.TextXAlignment.Left, Parent=r,
                })
                -- minus: bare symbol, no box, a bit darker, vertically centred on the track
                local minusBtn = New("TextButton", {
                    AnchorPoint=Vector2.new(0,0.5),
                    Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,0,0,24),
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Text="-", Font=Theme.Bold, TextSize=16, TextColor3=Color3.fromRGB(120,120,130),
                    AutoButtonColor=false, Parent=r,
                })
                -- track is a TextButton so it reliably sinks the click — pulling the slider
                -- never drags the whole window
                local track = New("TextButton", {
                    Size=UDim2.new(1,-32,0,8), Position=UDim2.fromOffset(16,20),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0, Text="",
                    AutoButtonColor=false, Parent=r,
                })
                local fill = New("Frame", {
                    Size=UDim2.fromScale(0,1), BackgroundColor3=Theme.Accent,
                    BorderSizePixel=0, Parent=track,
                })
                regAccent(function() fill.BackgroundColor3 = Theme.Accent end)
                -- value label sitting ON the slider, moving with the fill endpoint:
                -- starts just below the top edge and runs down past the bottom edge
                local trackLbl = New("TextLabel", {
                    BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0),
                    Position=UDim2.new(0,0,0,1), Size=UDim2.fromOffset(48,14),
                    Font=Theme.Bold, TextSize=12, TextColor3=Color3.new(1,1,1),
                    ZIndex=6, Parent=track,
                })
                TextStroke(trackLbl, 1.5)
                -- plus: bare symbol, no box, a bit darker, vertically centred on the track
                local plusBtn = New("TextButton", {
                    AnchorPoint=Vector2.new(1,0.5),
                    Size=UDim2.new(0,14,0,14), Position=UDim2.new(1,0,0,24),
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Text="+", Font=Theme.Bold, TextSize=16, TextColor3=Color3.fromRGB(120,120,130),
                    AutoButtonColor=false, Parent=r,
                })

                local function fmt(vv)
                    if dec>0 then return string.format("%."..dec.."f",vv)..(o.Suffix or "") end
                    return tostring(math.floor(vv))..(o.Suffix or "")
                end
                function S:Set(vv)
                    vv = math.clamp(vv, mn, mx)
                    if dec==0 then vv = math.floor(vv+.5) end
                    S.Value = vv
                    local rel = (vv-mn)/(mx-mn)
                    fill.Size = UDim2.fromScale(rel, 1)
                    trackLbl.Text = fmt(vv)
                    trackLbl.Position = UDim2.new(math.clamp(rel,0.12,0.88),0,0,1)
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
                local _bs = dec>0 and (0.1^dec) or 1
                minusBtn.MouseButton1Click:Connect(function() S:Set(S.Value - _bs) end)
                plusBtn.MouseButton1Click:Connect(function()  S:Set(S.Value + _bs) end)
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
                -- closed field: no border, no rounding, a touch lower under the label
                local boxBtn = New("TextButton", {
                    Size=UDim2.new(1,0,0,16), Position=UDim2.fromOffset(0,15),
                    BackgroundColor3=Theme.Elem, BorderSizePixel=0, Text="",
                    AutoButtonColor=false, Parent=r,
                })
                local sel = New("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.fromOffset(6,0),
                    Size=UDim2.new(1,-22,1,0), Font=Theme.Font, TextSize=Theme.Sz,
                    TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Left,
                    TextTruncate=Enum.TextTruncate.AtEnd, Parent=boxBtn,
                })
                -- down arrow on the right
                New("TextLabel", {
                    BackgroundTransparency=1, AnchorPoint=Vector2.new(1,.5),
                    Position=UDim2.new(1,-5,.5,0), Size=UDim2.fromOffset(10,10),
                    Font=Theme.Bold, TextSize=10, Text="▼", TextColor3=Theme.Dim, Parent=boxBtn,
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
                    -- click-outside catcher closes the dropdown
                    New("TextButton", {
                        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="",
                        AutoButtonColor=false, ZIndex=55, Parent=overlay,
                    }).MouseButton1Click:Connect(function() Win.CloseOverlays() end)
                    -- list: slightly darker than the button, no rounding, no green outline
                    local lf = New("Frame", {
                        BackgroundColor3=Theme.Panel, BorderSizePixel=0,
                        ZIndex=60, AutomaticSize=Enum.AutomaticSize.Y, Parent=overlay,
                    })
                    List(Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Left,
                         Enum.VerticalAlignment.Top, lf)
                    local ap = boxBtn.AbsolutePosition
                    local mp = main.AbsolutePosition
                    lf.Position = UDim2.fromOffset(ap.X-mp.X, ap.Y-mp.Y+boxBtn.AbsoluteSize.Y+3)
                    lf.Size     = UDim2.fromOffset(boxBtn.AbsoluteSize.X, 0)

                    for _, opt in ipairs(D.Options) do
                        local ob = New("TextButton", {
                            Size=UDim2.new(1,0,0,20), BackgroundColor3=Theme.Panel,
                            BorderSizePixel=0, AutoButtonColor=false,
                            Font=Theme.Font, TextSize=Theme.Sz, Text="  "..opt,
                            TextColor3=Theme.Dim, TextXAlignment=Enum.TextXAlignment.Left,
                            ZIndex=61, Parent=lf,
                        })
                        local function refOpt()
                            local on = multi and D.Value[opt] or (D.Value==opt)
                            ob.Font            = Theme.Font
                            ob.TextColor3      = on and Theme.Accent or Theme.Dim
                            ob.BackgroundColor3= Theme.Panel
                        end
                        refOpt()
                        -- hover: bolder, whiter, darker background (darker than the island)
                        ob.MouseEnter:Connect(function()
                            ob.Font = Theme.Bold
                            ob.TextColor3 = Color3.new(1,1,1)
                            ob.BackgroundColor3 = Theme.Bg
                        end)
                        ob.MouseLeave:Connect(refOpt)
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
                function D:SetVisible(vis) r.Visible = vis end  -- collapses in the list layout when hidden
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

            -- ═══ LISTBOX ════════════════════════════
            function G:AddListBox(o)
                o = o or {}
                local boxH   = o.Height or 130
                local sel    = nil
                local items  = {}
                local rows   = {}

                local container = New("Frame", {
                    Size = UDim2.new(1, 0, 0, boxH),
                    BackgroundColor3 = Theme.Panel,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = body,
                })
                Stroke(Theme.IslandBorder, 1, container)  -- sharp box (config tab allows boxes)

                local scroll = New("ScrollingFrame", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = container,
                })
                regAccent(function() scroll.ScrollBarImageColor3 = Theme.Accent end)
                List(Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Left,
                     Enum.VerticalAlignment.Top, scroll)

                local empty = New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Font = Theme.Font, TextSize = 11,
                    Text = "no configs saved",
                    TextColor3 = Theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = scroll,
                })

                local L = {}
                L.OnSelect = nil

                local function applyRowStyle(row, name)
                    local on = (name == sel)
                    row.TextColor3 = on and Theme.Text or Theme.Dim
                    row.BackgroundColor3 = on and Theme.Accent or Theme.Panel
                    row.BackgroundTransparency = on and 0.72 or 1
                end

                local function buildRows()
                    for _, r in ipairs(rows) do r:Destroy() end
                    rows = {}
                    empty.Visible = (#items == 0)
                    for _, name in ipairs(items) do
                        local row = New("TextButton", {
                            Size = UDim2.new(1, 0, 0, 18),
                            BorderSizePixel = 0,
                            Font = Theme.Font, TextSize = Theme.Sz,
                            Text = "  " .. name,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            Parent = scroll,
                        })
                        applyRowStyle(row, name)
                        local n = name
                        row.MouseEnter:Connect(function()
                            if n ~= sel then tw(row, .08, { BackgroundTransparency = 0.88 }) end
                        end)
                        row.MouseLeave:Connect(function()
                            if n ~= sel then tw(row, .08, { BackgroundTransparency = 1 }) end
                        end)
                        row.MouseButton1Click:Connect(function()
                            sel = n
                            for i, r in ipairs(rows) do applyRowStyle(r, items[i]) end
                            if L.OnSelect then pcall(L.OnSelect, n) end
                        end)
                        table.insert(rows, row)
                    end
                end
                buildRows()

                function L:SetItems(list)
                    items = list or {}
                    if sel and not table.find(items, sel) then sel = nil end
                    buildRows()
                end
                function L:GetSelected() return sel end
                function L:SetSelected(name)
                    if table.find(items, name) then
                        sel = name
                        for i, r in ipairs(rows) do applyRowStyle(r, items[i]) end
                    end
                end
                function L:ClearSelection()
                    sel = nil
                    for i, r in ipairs(rows) do applyRowStyle(r, items[i]) end
                end
                return L
            end

            return G
        end -- CreateGroup

        return Tab
    end -- CreateTab

    return Win
end -- CreateWindow

return Library
