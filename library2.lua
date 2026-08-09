--// services

local players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
local userinputservice = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local textservice = game:GetService("TextService")

--// vars

local localplayer = players.LocalPlayer
local library = {}
local windows = {}
local connections = {}
local unloadcallbacks = {}
local notifications
local screen
local unloaded = false
local loadingactive = false
local gradients = {}

library.icons = {
    Visuals = 88593793587066,
    Settings = 124830457223467,
    World = 117669948589528,
    Misc = 129792933724961,
    Players = 137741697346265,
    User = 121154699210338,
    Logo = 70449898225811,
}

library.theme = {
    Background = Color3.fromRGB(5, 5, 7),
    Sidebar = Color3.fromRGB(37, 66, 110),
    Surface = Color3.fromRGB(12, 12, 15),
    Surface2 = Color3.fromRGB(18, 18, 23),
    Outline = Color3.fromRGB(42, 43, 51),
    Text = Color3.fromRGB(243, 241, 248),
    Muted = Color3.fromRGB(142, 151, 170),
    GradientStart = Color3.fromRGB(37, 66, 110),
    GradientEnd = Color3.fromRGB(91, 128, 181),
}

library.options = {}
library.profiles = {Default = {}}
library.autoload = nil

--// helpers

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function create(class, properties)
    local object = Instance.new(class)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then object[property] = value end
    end
    if properties and properties.Parent then object.Parent = properties.Parent end
    return object
end

local function tween(object, duration, properties, style, direction)
    local animation = tweenservice:Create(object, TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), properties)
    animation:Play()
    return animation
end

local function corner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 4), Parent = parent})
end

local function stroke(parent, color, transparency)
    return create("UIStroke", {Color = color or library.theme.Outline, Transparency = transparency or 0, Thickness = 1, Parent = parent})
end

local function gradient(parent)
    local object = create("UIGradient", {
        Color = ColorSequence.new(library.theme.GradientStart, library.theme.GradientEnd),
        Rotation = 0,
        Parent = parent,
    })
    table.insert(gradients, object)
    return object
end

connect(runservice.RenderStepped, function()
    local offset = math.sin(os.clock() * 1.35) * 0.65
    for index = #gradients, 1, -1 do
        local object = gradients[index]
        if object.Parent then object.Offset = Vector2.new(offset, 0) else table.remove(gradients, index) end
    end
end)

local activetip
local tiptarget

connect(runservice.RenderStepped, function()
    if activetip then
        local position = userinputservice:GetMouseLocation()
        activetip.Position = UDim2.fromOffset(position.X + 14, position.Y + 12)
    end
end)

local function tooltip(target, value)
    connect(target.MouseEnter, function()
        if not screen then return end
        if activetip then activetip:Destroy() end
        tiptarget = target
        activetip = create("TextLabel", {AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = library.theme.Surface2, Font = Enum.Font.Code, Text = tostring(value), TextColor3 = library.theme.Text, TextSize = 9, TextTransparency = 1, ZIndex = 100, Parent = screen})
        create("UIPadding", {PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = activetip})
        corner(activetip, 4)
        stroke(activetip, library.theme.GradientEnd, 0.25)
        tween(activetip, 0.16, {TextTransparency = 0})
    end)
    connect(target.MouseLeave, function()
        if tiptarget ~= target or not activetip then return end
        local oldtip = activetip
        activetip, tiptarget = nil, nil
        tween(oldtip, 0.12, {TextTransparency = 1, BackgroundTransparency = 1})
        task.delay(0.13, function() if oldtip then oldtip:Destroy() end end)
    end)
end

local function imageid(id)
    id = tonumber(id) or library.icons.Logo
    return "rbxassetid://" .. tostring(id)
end

local function text(parent, value, size, color, alignment)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        Text = value or "",
        TextColor3 = color or library.theme.Text,
        TextSize = size or 12,
        TextXAlignment = alignment or Enum.TextXAlignment.Left,
        Parent = parent,
    })
end

local function canvas(parent, padding)
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, padding or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        Parent = parent,
    })
    return layout
end

local function parentgui()
    local parent
    if type(gethui) == "function" then pcall(function() parent = gethui() end) end
    return parent or localplayer:WaitForChild("PlayerGui")
end

local function ensuregui()
    if screen and screen.Parent then return screen end
    screen = create("ScreenGui", {
        Name = "HitechHub2",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parentgui(),
    })
    notifications = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(260, 400),
        Parent = screen,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notifications,
    })
    return screen
end

local function callback(func, ...)
    if type(func) ~= "function" then return end
    task.spawn(function(...)
        local success, message = pcall(func, ...)
        if not success then warn("library2 callback:", message) end
    end, ...)
end

local function makedraggable(frame, handle)
    local dragging, start, position
    connect(handle.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        start = input.Position
        position = frame.Position
    end)
    connect(userinputservice.InputChanged, function(input)
        if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - start
        frame.Position = UDim2.new(position.X.Scale, position.X.Offset + delta.X, position.Y.Scale, position.Y.Offset + delta.Y)
    end)
    connect(userinputservice.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

--// notifications

function library:Notify(info)
    ensuregui()
    info = type(info) == "table" and info or {Text = tostring(info)}
    local duration = tonumber(info.Duration) or 3
    local holder = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(10, 17, 29),
        BackgroundTransparency = 0.04,
        Size = UDim2.fromOffset(255, 49),
        Parent = notifications,
    })
    corner(holder, 5)
    stroke(holder, Color3.fromRGB(58, 86, 128))
    local scale = create("UIScale", {Scale = 0.9, Parent = holder})
    local icon = create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = imageid(info.Icon or library.icons.Logo),
        ImageColor3 = Color3.new(1, 1, 1),
        Position = UDim2.fromOffset(10, 9),
        Size = UDim2.fromOffset(28, 28),
        Parent = holder,
    })
    corner(icon, 5)
    local title = text(holder, info.Title or "slimekrew", 11)
    title.Position = UDim2.fromOffset(47, 8)
    title.Size = UDim2.new(1, -56, 0, 14)
    local body = text(holder, info.Text or "Notification", 9, Color3.fromRGB(142, 123, 123))
    body.Position = UDim2.fromOffset(47, 23)
    body.Size = UDim2.new(1, -56, 0, 14)
    local bar = create("Frame", {BackgroundColor3 = library.theme.GradientStart, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), Parent = holder})
    gradient(bar)
    holder.BackgroundTransparency = 1
    title.TextTransparency = 1
    body.TextTransparency = 1
    icon.ImageTransparency = 1
    tween(holder, 0.3, {BackgroundTransparency = 0.04})
    tween(scale, 0.35, {Scale = 1}, Enum.EasingStyle.Back)
    tween(title, 0.25, {TextTransparency = 0})
    tween(body, 0.25, {TextTransparency = 0})
    tween(icon, 0.25, {ImageTransparency = 0})
    tween(bar, duration, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        if not holder.Parent then return end
        tween(holder, 0.25, {BackgroundTransparency = 1, Position = UDim2.fromOffset(25, 0)})
        tween(scale, 0.25, {Scale = 0.94})
        tween(title, 0.2, {TextTransparency = 1})
        tween(body, 0.2, {TextTransparency = 1})
        tween(icon, 0.2, {ImageTransparency = 1})
        task.delay(0.27, function() if holder then holder:Destroy() end end)
    end)
    return holder
end

--// loading

function library:CreateLoading(info)
    ensuregui()
    loadingactive = true
    for _, window in ipairs(windows) do window.main.Visible = false end
    info = info or {}
    local overlay = create("Frame", {BackgroundColor3 = Color3.new(), BackgroundTransparency = 0.28, Size = UDim2.fromScale(1, 1), ZIndex = 90, Parent = screen})
    local card = create("Frame", {AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Color3.fromRGB(10, 17, 29), Position = UDim2.new(0.5, 0, 1, -34), Size = UDim2.fromOffset(310, 61), ZIndex = 91, Parent = overlay})
    corner(card, 6)
    stroke(card, Color3.fromRGB(58, 86, 128))
    local icon = create("ImageLabel", {BackgroundTransparency = 1, Image = imageid(info.Icon or library.icons.Logo), ImageColor3 = Color3.new(1, 1, 1), Position = UDim2.fromOffset(14, 11), Size = UDim2.fromOffset(29, 29), ZIndex = 92, Parent = card})
    corner(icon, 5)
    local title = text(card, info.Title or "Loading slimekrew", 11)
    title.Position = UDim2.fromOffset(52, 10)
    title.Size = UDim2.new(1, -64, 0, 15)
    title.ZIndex = 92
    local status = text(card, info.Text or "Preparing interface...", 9, Color3.fromRGB(129, 114, 114))
    status.Position = UDim2.fromOffset(52, 25)
    status.Size = UDim2.new(1, -64, 0, 13)
    status.ZIndex = 92
    local track = create("Frame", {BackgroundColor3 = Color3.fromRGB(18, 31, 51), BorderSizePixel = 0, Position = UDim2.new(0, 14, 1, -12), Size = UDim2.new(1, -28, 0, 3), ZIndex = 92, Parent = card})
    local fill = create("Frame", {BackgroundColor3 = library.theme.GradientStart, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), ZIndex = 93, Parent = track})
    gradient(fill)
    local object = {}
    function object:SetText(value) status.Text = tostring(value) end
    function object:SetProgress(value) tween(fill, 0.35, {Size = UDim2.new(math.clamp(tonumber(value) or 0, 0, 1), 0, 1, 0)}) end
    function object:Close()
        object:SetProgress(1)
        task.delay(0.35, function()
            tween(card, 0.35, {Position = UDim2.new(0.5, 0, 1, 30)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            tween(overlay, 0.35, {BackgroundTransparency = 1})
            task.delay(0.37, function()
                if overlay then overlay:Destroy() end
                loadingactive = false
                for _, window in ipairs(windows) do
                    window.visible = true
                    window.main.Visible = true
                    window.scale.Scale = 0.05
                    tween(window.scale, 0.5, {Scale = 1}, Enum.EasingStyle.Back)
                end
            end)
        end)
    end
    return object
end

--// elements

local elementmethods = {}

function elementmethods:SetVisible(value)
    self.holder.Visible = value == true
end

local function register(section, flag, object, name)
    if flag then library.options[flag] = object end
    table.insert(section.elements, object)
    local subtab = section.subtab
    local tab = subtab and subtab.tab
    local window = tab and tab.window
    if window and name then window:AddSearchEntry(tostring(name), tab, subtab, object) end
    return object
end

local function rowholder(section, height)
    return create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or 22), Parent = section.content})
end

function elementmethods:AddToggle(info)
    info = type(info) == "table" and info or {Text = tostring(info)}
    local holder = rowholder(self, 22)
    local label = text(holder, info.Text or "Toggle", 11, library.theme.Muted)
    local labelgradient = gradient(label)
    labelgradient.Enabled = false
    label.Size = UDim2.new(1, -38, 1, 0)
    local button = create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Color3.fromRGB(27, 26, 36), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(28, 15), Text = "", Parent = holder})
    corner(button, 8)
    stroke(button, Color3.fromRGB(51, 49, 65))
    local dot = create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(118, 113, 128), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(9, 9), Parent = button})
    corner(dot, 9)
    local object = setmetatable({Type = "Toggle", Value = info.Default == true, holder = holder, Callback = info.Callback}, {__index = elementmethods})
    function object:SetValue(value, silent)
        self.Value = value == true
        tween(button, 0.22, {BackgroundColor3 = self.Value and library.theme.GradientEnd or Color3.fromRGB(27, 26, 36)})
        tween(dot, 0.25, {Position = UDim2.new(0, self.Value and 15 or 2, 0.5, 0), BackgroundColor3 = self.Value and Color3.new(1, 1, 1) or Color3.fromRGB(118, 113, 128)}, Enum.EasingStyle.Back)
        if self.Value then
            label.TextTransparency = 1
            labelgradient.Enabled = true
            label.TextColor3 = Color3.new(1, 1, 1)
            tween(label, 0.3, {TextTransparency = 0})
        else
            tween(label, 0.2, {TextTransparency = 1})
            task.delay(0.2, function()
                if not self.Value then
                    labelgradient.Enabled = false
                    label.TextColor3 = library.theme.Muted
                    tween(label, 0.2, {TextTransparency = 0})
                end
            end)
        end
        if not silent then callback(self.Callback, self.Value) end
    end
    connect(button.MouseButton1Click, function() object:SetValue(not object.Value) end)
    tooltip(button, info.Tooltip or ("Toggle " .. (info.Text or "option")))
    object:SetValue(object.Value, true)
    return register(self, info.Flag, object, info.Text)
end

function elementmethods:AddSlider(info)
    info = info or {}
    local minimum, maximum = tonumber(info.Min) or 0, tonumber(info.Max) or 100
    local holder = rowholder(self, 39)
    local label = text(holder, info.Text or "Slider", 10, library.theme.Muted)
    label.Size = UDim2.new(1, -42, 0, 16)
    local output = text(holder, "", 9, library.theme.Muted, Enum.TextXAlignment.Right)
    output.Position = UDim2.new(1, -42, 0, 0)
    output.Size = UDim2.fromOffset(42, 16)
    local track = create("TextButton", {BackgroundColor3 = Color3.fromRGB(32, 32, 43), BorderSizePixel = 0, Position = UDim2.fromOffset(0, 25), Size = UDim2.new(1, 0, 0, 5), Text = "", Parent = holder})
    corner(track, 99)
    local fill = create("Frame", {BackgroundColor3 = library.theme.GradientStart, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = track})
    corner(fill, 99)
    gradient(fill)
    local object = setmetatable({Type = "Slider", Value = tonumber(info.Default) or minimum, holder = holder, Callback = info.Callback}, {__index = elementmethods})
    function object:SetValue(value, silent)
        local rounding = info.Rounding == nil and 0 or info.Rounding
        local multiplier = 10 ^ rounding
        self.Value = math.floor(math.clamp(tonumber(value) or minimum, minimum, maximum) * multiplier + 0.5) / multiplier
        local scale = maximum == minimum and 0 or (self.Value - minimum) / (maximum - minimum)
        tween(fill, 0.2, {Size = UDim2.new(scale, 0, 1, 0)})
        output.Text = tostring(self.Value) .. (info.Suffix or "")
        if not silent then callback(self.Callback, self.Value) end
    end
    local dragging = false
    local function update(input)
        local scale = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        object:SetValue(minimum + (maximum - minimum) * scale)
    end
    connect(track.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input) end end)
    connect(userinputservice.InputChanged, function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
    connect(userinputservice.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    object:SetValue(object.Value, true)
    return register(self, info.Flag, object, info.Text)
end

function elementmethods:AddButton(info)
    info = type(info) == "table" and info or {Text = tostring(info)}
    local holder = rowholder(self, 27)
    local button = create("TextButton", {BackgroundColor3 = library.theme.Surface2, Text = info.Text or "Button", TextColor3 = library.theme.Muted, TextSize = 10, Font = Enum.Font.Code, Size = UDim2.fromScale(1, 1), Parent = holder})
    corner(button, 4)
    stroke(button)
    connect(button.MouseEnter, function() tween(button, 0.18, {TextColor3 = library.theme.Text, BackgroundColor3 = Color3.fromRGB(24, 35, 55)}) end)
    connect(button.MouseLeave, function() tween(button, 0.18, {TextColor3 = library.theme.Muted, BackgroundColor3 = library.theme.Surface2}) end)
    connect(button.MouseButton1Click, function() tween(button, 0.08, {Size = UDim2.new(1, -4, 1, -2), Position = UDim2.fromOffset(2, 1)}); task.delay(0.09, function() tween(button, 0.16, {Size = UDim2.fromScale(1, 1), Position = UDim2.new()}) end); callback(info.Callback) end)
    return register(self, info.Flag, setmetatable({Type = "Button", holder = holder}, {__index = elementmethods}), info.Text)
end

function elementmethods:AddDropdown(info)
    info = info or {}
    local values = info.Values or {"None"}
    local holder = rowholder(self, 42)
    holder.ClipsDescendants = true
    local label = text(holder, info.Text or "Dropdown", 10, library.theme.Muted)
    label.Size = UDim2.new(1, 0, 0, 15)
    local display = create("TextButton", {BackgroundColor3 = Color3.fromRGB(17, 17, 26), Position = UDim2.fromOffset(0, 17), Size = UDim2.new(1, 0, 0, 25), Text = "", Parent = holder})
    corner(display, 4)
    stroke(display)
    local selected = text(display, "", 10, library.theme.Muted)
    selected.Position = UDim2.fromOffset(8, 0)
    selected.Size = UDim2.new(1, -28, 1, 0)
    local arrow = text(display, "⌄", 13, library.theme.Muted, Enum.TextXAlignment.Center)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -6, 0.5, 0)
    arrow.Size = UDim2.fromOffset(16, 16)
    local menu = create("Frame", {BackgroundColor3 = Color3.fromRGB(13, 13, 19), BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.fromOffset(0, 43), Size = UDim2.new(1, 0, 0, 0), Parent = holder})
    local menulayout = create("UIListLayout", {Parent = menu})
    local object = setmetatable({Type = info.Multi and "MultiDropdown" or "Dropdown", Value = info.Multi and {} or info.Default or values[1], Open = false, holder = holder, Callback = info.Callback}, {__index = elementmethods})
    local function displayvalue()
        if info.Multi then
            local active = {}
            for _, value in ipairs(values) do if object.Value[value] then table.insert(active, tostring(value)) end end
            selected.Text = #active > 0 and table.concat(active, ", ") or "---"
        else selected.Text = tostring(object.Value or "---") end
    end
    function object:SetOpen(value)
        self.Open = value == true
        local height = math.min(#values, info.MaxVisible or 5) * 24
        tween(holder, 0.28, {Size = UDim2.new(1, 0, 0, self.Open and 43 + height or 42)})
        tween(menu, 0.3, {Size = UDim2.new(1, 0, 0, self.Open and height or 0), BackgroundTransparency = self.Open and 0 or 1})
        tween(arrow, 0.28, {Rotation = self.Open and 180 or 0}, Enum.EasingStyle.Back)
    end
    function object:SetValue(value, silent)
        if info.Multi then
            self.Value = type(value) == "table" and value or {}
        elseif table.find(values, value) then self.Value = value end
        displayvalue()
        if not silent then callback(self.Callback, self.Value) end
    end
    for _, value in ipairs(values) do
        local option = create("TextButton", {BackgroundColor3 = library.theme.Surface, BackgroundTransparency = 1, Font = Enum.Font.Code, Text = tostring(value), TextColor3 = library.theme.Muted, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 24), Parent = menu})
        create("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = option})
        connect(option.MouseEnter, function() tween(option, 0.15, {BackgroundTransparency = 0, TextColor3 = library.theme.Text}) end)
        connect(option.MouseLeave, function() tween(option, 0.15, {BackgroundTransparency = 1, TextColor3 = library.theme.Muted}) end)
        connect(option.MouseButton1Click, function()
            if info.Multi then object.Value[value] = not object.Value[value] or nil else object.Value = value; object:SetOpen(false) end
            displayvalue()
            callback(object.Callback, object.Value)
        end)
    end
    connect(display.MouseButton1Click, function() object:SetOpen(not object.Open) end)
    if info.Multi then
        local defaults = type(info.Default) == "table" and info.Default or {}
        for _, value in ipairs(defaults) do object.Value[value] = true end
    end
    displayvalue()
    return register(self, info.Flag, object, info.Text)
end

function elementmethods:AddMultiDropdown(info)
    info = info or {}
    info.Multi = true
    return self:AddDropdown(info)
end

function elementmethods:AddLabel(value)
    local holder = rowholder(self, 20)
    local label = text(holder, tostring(value), 10, library.theme.Muted)
    label.Size = UDim2.fromScale(1, 1)
    local object = setmetatable({Type = "Label", holder = holder}, {__index = elementmethods})
    function object:SetText(newvalue) label.Text = tostring(newvalue) end
    return register(self, nil, object, value)
end

--// window

function library:CreateWindow(info)
    ensuregui()
    info = info or {}
    local window = {tabs = {}, active = nil, subtabs = {}, visible = not loadingactive, togglekey = info.ToggleKey or Enum.KeyCode.RightShift}
    local main = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = library.theme.Background, Position = UDim2.fromScale(0.5, 0.5), Size = info.Size or UDim2.fromOffset(760, 470), Visible = not loadingactive, Parent = screen})
    corner(main, 10)
    stroke(main, Color3.fromRGB(58, 86, 128))
    local mainscale = create("UIScale", {Scale = loadingactive and 0.05 or 1, Parent = main})
    local sidebar = create("Frame", {BackgroundColor3 = library.theme.Sidebar, BorderSizePixel = 0, Size = UDim2.new(0, 52, 1, 0), ClipsDescendants = false, Parent = main})
    corner(sidebar, 7)
    local sidecover = create("Frame", {BackgroundColor3 = library.theme.Sidebar, BorderSizePixel = 0, Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 10, 1, 0), Parent = sidebar})
    local topbar = create("Frame", {BackgroundColor3 = Color3.fromRGB(7, 7, 9), BorderSizePixel = 0, Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -52, 0, 48), Parent = main})
    local crumb = text(topbar, info.Title or "slimekrew", 12)
    crumb.Position = UDim2.fromOffset(13, 0)
    crumb.Size = UDim2.fromOffset(150, 48)
    local subbar = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(160, 9), Size = UDim2.new(1, -170, 0, 30), Parent = topbar})
    create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = subbar})
    local pageholder = create("Frame", {BackgroundColor3 = Color3.fromRGB(5, 5, 7), BorderSizePixel = 0, Position = UDim2.fromOffset(52, 48), Size = UDim2.new(1, -52, 1, -48), ClipsDescendants = true, Parent = main})
    local logo = create("ImageButton", {BackgroundTransparency = 1, Image = imageid(info.Icon or library.icons.Logo), Position = UDim2.fromOffset(10, 13), Size = UDim2.fromOffset(32, 32), Parent = sidebar})
    local nav = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(7, 72), Size = UDim2.new(1, -14, 1, -160), Parent = sidebar})
    local navlayout = create("UIListLayout", {HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = nav})
    local navfluid = create("Frame", {BackgroundColor3 = library.theme.GradientStart, BackgroundTransparency = 0.62, BorderSizePixel = 0, Position = UDim2.fromOffset(7, 72), Size = UDim2.fromOffset(38, 38), ZIndex = 0, Parent = sidebar})
    corner(navfluid, 9)
    gradient(navfluid)
    local searchbutton = create("TextButton", {AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Color3.fromRGB(14, 14, 20), Position = UDim2.new(0.5, 0, 1, -52), Size = UDim2.fromOffset(34, 21), Text = "⌕", TextColor3 = library.theme.Muted, TextSize = 11, Font = Enum.Font.Code, Parent = sidebar})
    corner(searchbutton, 4)
    stroke(searchbutton)
    local avatar = create("ImageButton", {AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Image = imageid(info.UserIcon or library.icons.User), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.fromOffset(31, 31), Parent = sidebar})
    corner(avatar, 16)
    stroke(avatar, Color3.new(1, 1, 1), 0.2)
    task.spawn(function()
        local success, result = pcall(players.GetUserThumbnailAsync, players, localplayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        if success then avatar.Image = result end
    end)
    local searchoverlay = create("CanvasGroup", {BackgroundColor3 = Color3.fromRGB(7, 7, 9), BackgroundTransparency = 0, GroupTransparency = 1, Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -52, 0, 48), Visible = false, ZIndex = 20, Parent = main})
    local searchinput = create("TextBox", {BackgroundColor3 = library.theme.Surface2, ClearTextOnFocus = false, Font = Enum.Font.Code, PlaceholderText = "Search controls...", PlaceholderColor3 = library.theme.Muted, Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -52, 0, 36), Text = "", TextColor3 = library.theme.Text, TextSize = 11, ZIndex = 21, Parent = searchoverlay})
    corner(searchinput, 5)
    stroke(searchinput, Color3.fromRGB(76, 41, 41))
    local searchresults = create("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(), Size = UDim2.new(), Visible = false, Parent = searchoverlay})
    local searchclose = create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Code, Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(28, 28), Text = "×", TextColor3 = library.theme.Text, TextSize = 16, ZIndex = 21, Parent = searchoverlay})
    corner(searchclose, 4)
    stroke(searchclose)
    local searchlayout = canvas(searchresults, 5)
    local statusoverlay = create("CanvasGroup", {BackgroundColor3 = Color3.fromRGB(7, 7, 11), BackgroundTransparency = 0.02, GroupTransparency = 1, Position = UDim2.fromOffset(44, 48), Size = UDim2.new(1, -44, 1, -48), Visible = false, ZIndex = 22, Parent = main})
    local statuscard = create("Frame", {AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = library.theme.Surface, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.fromOffset(560, 265), ZIndex = 23, Parent = statusoverlay})
    corner(statuscard, 7)
    stroke(statuscard)
    local statusavatar = create("ImageLabel", {BackgroundTransparency = 1, Image = avatar.Image, Position = UDim2.fromOffset(18, 18), Size = UDim2.fromOffset(55, 55), ZIndex = 24, Parent = statuscard})
    corner(statusavatar, 7)
    local statusname = text(statuscard, localplayer.DisplayName, 16)
    statusname.Position = UDim2.fromOffset(86, 19)
    statusname.Size = UDim2.fromOffset(250, 22)
    statusname.ZIndex = 24
    local statusline = text(statuscard, "Account and session overview", 9, library.theme.Muted)
    statusline.Position = UDim2.fromOffset(86, 43)
    statusline.Size = UDim2.fromOffset(260, 18)
    statusline.ZIndex = 24
    local back = create("TextButton", {AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = library.theme.Surface2, Font = Enum.Font.Code, Position = UDim2.new(1, -18, 0, 22), Size = UDim2.fromOffset(55, 25), Text = "Back", TextColor3 = library.theme.Muted, TextSize = 10, ZIndex = 24, Parent = statuscard})
    corner(back, 4)
    stroke(back)
    local statusgrid = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 90), Size = UDim2.new(1, -36, 0, 105), ZIndex = 24, Parent = statuscard})
    create("UIGridLayout", {CellPadding = UDim2.fromOffset(7, 7), CellSize = UDim2.new(0.5, -4, 0, 49), Parent = statusgrid})
    for _, data in ipairs({{"CURRENT GAME", info.Game or game.Name}, {"EXECUTOR", type(identifyexecutor) == "function" and identifyexecutor() or "Roblox"}, {"RANK", info.Rank or "Member"}, {"ACCESS", info.Access or "Local"}}) do
        local stat = create("Frame", {BackgroundColor3 = library.theme.Surface2, ZIndex = 24, Parent = statusgrid})
        corner(stat, 4)
        stroke(stat)
        local key = text(stat, data[1], 8, library.theme.Muted)
        key.Position = UDim2.fromOffset(8, 5)
        key.Size = UDim2.new(1, -16, 0, 13)
        key.ZIndex = 25
        local value = text(stat, tostring(data[2]), 10)
        value.Position = UDim2.fromOffset(8, 21)
        value.Size = UDim2.new(1, -16, 0, 18)
        value.ZIndex = 25
    end
    local rejoin = create("TextButton", {BackgroundColor3 = library.theme.Surface2, Font = Enum.Font.Code, Position = UDim2.fromOffset(18, 215), Size = UDim2.new(1, -36, 0, 30), Text = "Rejoin", TextColor3 = library.theme.Muted, TextSize = 10, ZIndex = 24, Parent = statuscard})
    corner(rejoin, 4)
    stroke(rejoin)
    task.spawn(function()
        local success, result = pcall(players.GetUserThumbnailAsync, players, localplayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        if success then avatar.Image = result; statusavatar.Image = result end
    end)
    tooltip(logo, info.Title or "slimekrew")
    tooltip(searchbutton, "Search controls")
    tooltip(avatar, "Account status")

    window.main = main
    window.scale = mainscale
    window.sidebar = sidebar
    window.sidecover = sidecover
    window.navfluid = navfluid
    window.crumb = crumb
    window.subbar = subbar
    window.pageholder = pageholder
    window.searchentries = {}
    local sidebarexpanded = false

    local function closeoverlays()
        for _, overlay in ipairs({searchoverlay, statusoverlay}) do
            if overlay.Visible then
                tween(overlay, 0.22, {GroupTransparency = 1})
                task.delay(0.23, function() if overlay.GroupTransparency > 0.95 then overlay.Visible = false end end)
            end
        end
        if searchoverlay.Visible and searchinput.Text ~= "" then
            searchinput.Text = ""
            for _, entry in ipairs(window.searchentries) do entry.object:SetVisible(true) end
        end
    end

    local function openoverlay(overlay)
        closeoverlays()
        overlay.Visible = true
        overlay.GroupTransparency = 1
        tween(overlay, 0.28, {GroupTransparency = 0})
    end

    connect(sidebar.MouseEnter, function()
        sidebarexpanded = true
        tween(sidebar, 0.35, {Size = UDim2.new(0, 72, 1, 0)})
        tween(topbar, 0.35, {Position = UDim2.fromOffset(72, 0), Size = UDim2.new(1, -72, 0, 48)})
        tween(pageholder, 0.35, {Position = UDim2.fromOffset(72, 48), Size = UDim2.new(1, -72, 1, -48)})
        tween(searchbutton, 0.3, {Size = UDim2.fromOffset(50, 21)})
        tween(navfluid, 0.35, {Position = UDim2.fromOffset(17, navfluid.Position.Y.Offset)})
        tween(logo, 0.35, {Position = UDim2.fromOffset(20, 13)})
        tween(searchoverlay, 0.35, {Position = UDim2.fromOffset(72, 0), Size = UDim2.new(1, -72, 0, 48)})
    end)
    connect(sidebar.MouseLeave, function()
        sidebarexpanded = false
        tween(sidebar, 0.35, {Size = UDim2.new(0, 52, 1, 0)})
        tween(topbar, 0.35, {Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -52, 0, 48)})
        tween(pageholder, 0.35, {Position = UDim2.fromOffset(52, 48), Size = UDim2.new(1, -52, 1, -48)})
        tween(searchbutton, 0.3, {Size = UDim2.fromOffset(34, 21)})
        tween(navfluid, 0.35, {Position = UDim2.fromOffset(7, navfluid.Position.Y.Offset)})
        tween(logo, 0.35, {Position = UDim2.fromOffset(10, 13)})
        tween(searchoverlay, 0.35, {Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -52, 0, 48)})
    end)

    function window:SetVisible(value)
        self.visible = value == true
        if self.visible then
            main.Visible = true
            mainscale.Scale = 0.95
            tween(mainscale, 0.35, {Scale = 1}, Enum.EasingStyle.Back)
            tween(main, 0.25, {BackgroundTransparency = 0})
        else
            tween(mainscale, 0.25, {Scale = 0.96})
            tween(main, 0.25, {BackgroundTransparency = 1})
            task.delay(0.26, function() if not window.visible then main.Visible = false end end)
        end
    end

    function window:Toggle() self:SetVisible(not self.visible) end

    function window:AddTab(name, icon)
        local tab = {name = name, subtabs = {}, window = self}
        local button = create("ImageButton", {BackgroundTransparency = 1, Image = imageid(icon or library.icons[name] or library.icons.Misc), ImageTransparency = 0.18, ScaleType = Enum.ScaleType.Fit, Size = UDim2.fromOffset(38, 38), ZIndex = 1, Parent = nav})
        button.LayoutOrder = #self.tabs + 1
        corner(button, 7)
        local glyphs = {Visuals = "◉", Settings = "⚙", World = "◇", Misc = "✦", Players = "♙"}
        local fallback = text(button, glyphs[name] or "◆", 15, Color3.new(1, 1, 1), Enum.TextXAlignment.Center)
        fallback.Size = UDim2.fromScale(1, 1)
        fallback.Font = Enum.Font.GothamBold
        fallback.TextTransparency = 0.15
        fallback.ZIndex = 2
        tooltip(button, name)
        local page = create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = pageholder})
        tab.button, tab.page = button, page
        function tab:AddSubtab(subname)
            local subtab = {name = subname, tab = self, sections = {}}
            local subbutton = create("TextButton", {AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = library.theme.GradientStart, BackgroundTransparency = 1, Font = Enum.Font.Code, Size = UDim2.fromOffset(0, 26), Text = subname, TextColor3 = Color3.new(1, 1, 1), TextSize = 9, Parent = subbar})
            create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = subbutton})
            corner(subbutton, 99)
            gradient(subbutton)
            local suboutline = stroke(subbutton, library.theme.GradientEnd, 1)
            gradient(suboutline)
            local content = create("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Size = UDim2.fromScale(1, 1), Visible = false, Parent = page})
            local columns = create("Frame", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(13, 13), Size = UDim2.new(1, -26, 0, 0), Parent = content})
            create("UIGridLayout", {CellPadding = UDim2.fromOffset(13, 0), CellSize = UDim2.new(0.5, -7, 0, 1000), Parent = columns})
            local left = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Parent = columns})
            local right = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Parent = columns})
            create("UIListLayout", {Padding = UDim.new(0, 13), Parent = left})
            create("UIListLayout", {Padding = UDim.new(0, 13), Parent = right})
            subtab.button, subtab.content, subtab.left, subtab.right = subbutton, content, left, right
            function subtab:AddSection(titlevalue, side)
                local section = setmetatable({elements = {}, subtab = self}, {__index = elementmethods})
                local holder = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = library.theme.Surface, BackgroundTransparency = 0.08, Size = UDim2.new(1, 0, 0, 0), Parent = tostring(side):lower() == "right" and right or left})
                corner(holder, 6)
                stroke(holder)
                local heading = text(holder, tostring(titlevalue), 10)
                heading.Position = UDim2.fromOffset(10, 0)
                heading.Size = UDim2.new(1, -20, 0, 29)
                local line = create("Frame", {BackgroundColor3 = library.theme.GradientStart, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 1), Parent = holder})
                gradient(line)
                local sectioncontent = create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 29), Size = UDim2.new(1, 0, 0, 0), Parent = holder})
                canvas(sectioncontent, 5)
                section.holder, section.content = holder, sectioncontent
                table.insert(self.sections, section)
                return section
            end
            connect(subbutton.MouseButton1Click, function() window:SelectSubtab(tab, subtab) end)
            table.insert(self.subtabs, subtab)
            if window.active == tab and #self.subtabs == 1 then
                subbutton.Visible = true
                window:SelectSubtab(tab, subtab)
            end
            return subtab
        end
        connect(button.MouseButton1Click, function() window:SelectTab(tab) end)
        table.insert(self.tabs, tab)
        if not self.active then self:SelectTab(tab) end
        return tab
    end

    function window:SelectSubtab(tab, subtab)
        for _, item in ipairs(tab.subtabs) do
            item.content.Visible = item == subtab
            tween(item.button, 0.34, {BackgroundTransparency = item == subtab and 0.16 or 1, TextColor3 = Color3.new(1, 1, 1)}, Enum.EasingStyle.Back)
            local itemoutline = item.button:FindFirstChildOfClass("UIStroke")
            if itemoutline then tween(itemoutline, 0.3, {Transparency = item == subtab and 0.08 or 0.7}) end
        end
        crumb.Text = tab.name .. " / " .. subtab.name
    end

    function window:SelectTab(tab, keepoverlay)
        if not keepoverlay then closeoverlays() end
        self.active = tab
        for _, item in ipairs(self.tabs) do
            item.page.Visible = item == tab
            tween(item.button, 0.25, {ImageTransparency = item == tab and 0.08 or 0.42})
            local itemfallback = item.button:FindFirstChildOfClass("TextLabel")
            if itemfallback then tween(itemfallback, 0.25, {TextTransparency = item == tab and 0.05 or 0.42}) end
        end
        tween(navfluid, 0.48, {Position = UDim2.fromOffset(sidebarexpanded and 17 or 7, 72 + (tab.button.LayoutOrder - 1) * 46)}, Enum.EasingStyle.Back)
        for _, child in ipairs(subbar:GetChildren()) do if child:IsA("GuiObject") then child.Visible = false end end
        for index, subtab in ipairs(tab.subtabs) do subtab.button.Visible = true; subtab.button.LayoutOrder = index end
        if tab.subtabs[1] then self:SelectSubtab(tab, tab.subtabs[1]) else crumb.Text = tab.name end
    end

    function window:AddSearchEntry(name, tab, subtab, object)
        table.insert(self.searchentries, {name = name, tab = tab, subtab = subtab, object = object})
    end

    local function rendersearch()
        local query = searchinput.Text:lower()
        local firstmatch
        for _, entry in ipairs(window.searchentries) do
            local match = query == "" or entry.name:lower():find(query, 1, true) ~= nil
            entry.object:SetVisible(match)
            if match and query ~= "" and not firstmatch then firstmatch = entry end
        end
        if firstmatch then window:SelectTab(firstmatch.tab, true); window:SelectSubtab(firstmatch.tab, firstmatch.subtab) end
    end
    connect(searchinput:GetPropertyChangedSignal("Text"), rendersearch)
    connect(searchbutton.MouseButton1Click, function() rendersearch(); openoverlay(searchoverlay); task.delay(0.1, function() searchinput:CaptureFocus() end) end)
    connect(searchclose.MouseButton1Click, function() searchinput.Text = ""; rendersearch(); closeoverlays() end)
    connect(avatar.MouseButton1Click, function() openoverlay(statusoverlay) end)
    connect(back.MouseButton1Click, closeoverlays)
    connect(rejoin.MouseButton1Click, function() library:Notify({Text = "Rejoin requested"}) end)
    connect(userinputservice.InputBegan, function(input, processed)
        if processed or userinputservice:GetFocusedTextBox() then return end
        if input.KeyCode == window.togglekey then window:Toggle() end
    end)
    makedraggable(main, topbar)
    function window:Destroy() library:Unload() end
    table.insert(windows, window)
    return window
end

--// profiles

function library:SaveProfile(name)
    local profile = {}
    for flag, option in pairs(self.options) do
        if option.Type == "Toggle" or option.Type == "Slider" or option.Type == "Dropdown" or option.Type == "MultiDropdown" then profile[flag] = option.Value end
    end
    self.profiles[name or "Default"] = profile
end

function library:LoadProfile(name)
    local profile = self.profiles[name or "Default"]
    if not profile then return false end
    for flag, value in pairs(profile) do
        local option = self.options[flag]
        if option and option.SetValue then option:SetValue(value) end
    end
    return true
end

function library:SetTheme(startcolor, endcolor)
    self.theme.GradientStart = startcolor or self.theme.GradientStart
    self.theme.GradientEnd = endcolor or self.theme.GradientEnd
    if screen then
        for _, object in ipairs(screen:GetDescendants()) do
            if object:IsA("UIGradient") then object.Color = ColorSequence.new(self.theme.GradientStart, self.theme.GradientEnd) end
        end
    end
    for _, window in ipairs(windows) do
        tween(window.sidebar, 0.45, {BackgroundColor3 = self.theme.GradientStart})
        tween(window.sidecover, 0.45, {BackgroundColor3 = self.theme.GradientStart})
        tween(window.navfluid, 0.45, {BackgroundColor3 = self.theme.GradientStart})
    end
end

function library:Destroy()
    self:Unload()
end

function library:OnUnload(func)
    if type(func) == "function" then table.insert(unloadcallbacks, func) end
end

--// cleanup

function library:Unload()
    if unloaded then return end
    unloaded = true
    for _, func in ipairs(unloadcallbacks) do pcall(func) end
    table.clear(unloadcallbacks)
    for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
    table.clear(connections)
    table.clear(windows)
    table.clear(library.options)
    if screen then screen:Destroy() end
    screen = nil
end

return library
