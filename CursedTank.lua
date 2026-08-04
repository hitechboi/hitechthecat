--// links

local libraryurl = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"

--// vars

local env = getgenv()
local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local stats = game:GetService("Stats")
local userinputservice = game:GetService("UserInputService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local localplayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local source = game:HttpGet(libraryurl .. "?cachebust=" .. tostring(os.time()), true)
local compile, compileerror = loadstring(source, "slimekrew Library")

assert(compile, compileerror)

if env.slimekrewcursedtank then
    pcall(function() env.slimekrewcursedtank:Unload() end)
end

local library = compile()
local icon = library:GetRandomBrandIcon()
local connections = {}
local vehicles = {}
local avatar = icon
local lastscan = 0
local fpsframes = 0
local fpstime = 0
local watermark
local fovcircle
local snapline
local targetbox
local targettexts = {}
local targetlines = {}
local currenttarget
local currenttargetpart
local hudtarget
local hudtargetpart
local oldtrajectory
local trajectorymodule
local targetalpha = 0
local gradientclock = 0
local originalmousebehavior = userinputservice.MouseBehavior
local originalmouseicon = userinputservice.MouseIconEnabled
local settings = {
    vehicleesp = false,
    espteamcheck = false,
    espvisiblecheck = false,
    renderdistance = 3000,
    espcolor = Color3.fromRGB(240, 240, 245),
    enemyhighlight = false,
    enemycolor = Color3.fromRGB(255, 85, 85),
    teamhighlight = false,
    teamcolor = Color3.fromRGB(85, 170, 255),
    fov = false,
    fovsize = 180,
    fovcolor = Color3.fromRGB(235, 235, 240),
    snaplines = false,
    targethud = false,
    silentaim = false,
    silentvisiblecheck = false,
    prediction = true,
    hitparts = {Center = true},
    unlockmouse = false,
}

pcall(function()
    avatar = players:GetUserThumbnailAsync(localplayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)

--// funcs

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function ownername(vehicle)
    local hullnode = vehicle and vehicle:FindFirstChild("HullNode")
    return hullnode and hullnode:GetAttribute("Owner") or vehicle and vehicle:GetAttribute("Owner")
end

local function ownerplayer(vehicle)
    local owner = ownername(vehicle)
    if owner == nil then return end
    if type(owner) == "number" then return players:GetPlayerByUserId(owner) end
    local id = tonumber(owner)
    if id then
        local player = players:GetPlayerByUserId(id)
        if player then return player end
    end
    return players:FindFirstChild(tostring(owner))
end

local function friendly(vehicle)
    local owner = ownerplayer(vehicle)
    return owner and localplayer.Team ~= nil and owner.Team == localplayer.Team
end

local function vehiclepart(vehicle)
    return vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
end

local function rayvisible(part, vehicle)
    if not part or not part.Parent then return false end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    if direction.Magnitude <= 0.01 then return true end

    local parameters = RaycastParams.new()
    parameters.FilterType = Enum.RaycastFilterType.Exclude
    parameters.FilterDescendantsInstances = localplayer.Character and {localplayer.Character} or {}
    parameters.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, parameters)
    return not result or result.Instance:IsDescendantOf(vehicle)
end

local function removevehicle(vehicle)
    local data = vehicles[vehicle]
    if not data then return end
    pcall(function() data.highlight:Destroy() end)
    pcall(function() data.billboard:Destroy() end)
    vehicles[vehicle] = nil
end

local function addvehicle(vehicle)
    if vehicles[vehicle] or not vehicle:IsA("Model") then return end
    local part = vehiclepart(vehicle)
    if not part then return end

    for _, object in ipairs(vehicle:GetDescendants()) do
        if object.Name == "SlimekrewVehicleESP" or object.Name == "SlimekrewVehicleLabel" then
            pcall(function() object:Destroy() end)
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "SlimekrewVehicleESP"
    highlight.Adornee = vehicle
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 1
    highlight.Parent = vehicle

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SlimekrewVehicleLabel"
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Size = UDim2.fromOffset(190, 34)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextTransparency = 1
    label.TextStrokeTransparency = 1
    label.TextColor3 = settings.espcolor
    label.Parent = billboard

    vehicles[vehicle] = {
        part = part,
        highlight = highlight,
        billboard = billboard,
        label = label,
        alpha = 0,
    }
end

local function scanvehicles()
    for _, foldername in ipairs({"Vehicles", "VehiclesSim"}) do
        local folder = workspace:FindFirstChild(foldername)
        if folder then
            for _, vehicle in ipairs(folder:GetChildren()) do addvehicle(vehicle) end
        end
    end
    for vehicle in pairs(vehicles) do
        if not vehicle.Parent then removevehicle(vehicle) end
    end
end

local function clearvehicleesp()
    local cached = {}
    for vehicle in pairs(vehicles) do table.insert(cached, vehicle) end
    for _, vehicle in ipairs(cached) do removevehicle(vehicle) end
    for _, foldername in ipairs({"Vehicles", "VehiclesSim"}) do
        local folder = workspace:FindFirstChild(foldername)
        if folder then
            for _, object in ipairs(folder:GetDescendants()) do
                if object.Name == "SlimekrewVehicleESP" or object.Name == "SlimekrewVehicleLabel" then
                    pcall(function() object:Destroy() end)
                end
            end
        end
    end
end

local function updatevehicles(delta)
    local speed = math.clamp(delta * 9, 0, 1)
    for vehicle, data in pairs(vehicles) do
        if not vehicle.Parent or not data.part.Parent then
            removevehicle(vehicle)
        else
            local distance = (camera.CFrame.Position - data.part.Position).Magnitude
            local teammate = friendly(vehicle)
            local passedvisibility = not settings.espvisiblecheck or rayvisible(data.part, vehicle)
            local shown = settings.vehicleesp and distance <= settings.renderdistance and (not settings.espteamcheck or not teammate) and passedvisibility
            data.alpha += ((shown and 1 or 0) - data.alpha) * speed
            if math.abs(data.alpha - (shown and 1 or 0)) < 0.01 then data.alpha = shown and 1 or 0 end

            local highlightenabled = teammate and settings.teamhighlight or not teammate and settings.enemyhighlight
            local highlightcolor = teammate and settings.teamcolor or settings.enemycolor
            data.label.Text = vehicle.Name .. " [" .. math.floor(distance + 0.5) .. "m]\n" .. tostring(ownername(vehicle) or "Unknown")
            data.label.TextColor3 = settings.espcolor
            data.label.TextTransparency = 1 - data.alpha
            data.label.TextStrokeTransparency = 1 - data.alpha * 0.65
            data.billboard.Enabled = data.alpha > 0.01
            data.highlight.Enabled = data.alpha > 0.01 and highlightenabled
            data.highlight.FillColor = highlightcolor
            data.highlight.OutlineColor = highlightcolor
            data.highlight.FillTransparency = 1 - data.alpha * 0.18
            data.highlight.OutlineTransparency = 1 - data.alpha
        end
    end
end

local hitpartnames = {"Center", "Engine", "Ammo", "Turret"}

local function targetparts(vehicle)
    local parts = {}
    local added = {}
    if not vehicle then return parts end

    local function add(part)
        if part and part:IsA("BasePart") and not added[part] then
            added[part] = true
            table.insert(parts, part)
        end
    end

    for _, name in ipairs(hitpartnames) do
        if settings.hitparts[name] then
            if name == "Center" then
                add(vehicle.PrimaryPart or vehicle:FindFirstChild("HullNode", true) or vehicle:FindFirstChildWhichIsA("BasePart", true))
            else
                local wanted = name:lower()
                for _, object in ipairs(vehicle:GetDescendants()) do
                    if object:IsA("BasePart") and object.Name:lower():find(wanted, 1, true) then add(object) end
                end
            end
        end
    end

    return parts
end

local function predictdirection(origin, speed, gravity, shootervelocity)
    local part = currenttargetpart
    if not part or type(speed) ~= "number" or speed <= 0 then return end
    local targetposition = part.Position
    local targetvelocity = part.AssemblyLinearVelocity
    local ownvelocity = typeof(shootervelocity) == "Vector3" and shootervelocity or Vector3.zero
    local time = (targetposition - origin).Magnitude / speed
    if settings.prediction then
        for _ = 1, 3 do
            local future = targetposition + (targetvelocity - ownvelocity) * time
            time = (future - origin).Magnitude / speed
        end
        targetposition += (targetvelocity - ownvelocity) * time
        if type(gravity) == "number" then targetposition += Vector3.new(0, gravity * time * time * 0.5, 0) end
    end
    local offset = targetposition - origin
    return offset.Magnitude > 0 and offset.Unit or nil
end

local function hooksilentaim()
    if oldtrajectory or type(hookfunction) ~= "function" then return end
    local modules = replicatedstorage:FindFirstChild("VehicleModuleScripts")
    local module = modules and modules:FindFirstChild("Trajectory")
    if not module then return end
    local success, result = pcall(require, module)
    if not success or type(result) ~= "table" or type(result.Trajectory) ~= "function" then return end
    trajectorymodule = result
    local replacement
    replacement = function(...)
        local arguments = {...}
        if settings.silentaim and currenttarget and currenttarget.Parent then
            local direction = predictdirection(arguments[4], arguments[3], arguments[6], arguments[7])
            if direction then arguments[2] = direction end
        end
        return oldtrajectory(table.unpack(arguments))
    end
    oldtrajectory = hookfunction(result.Trajectory, replacement)
end

local function makedrawings()
    if type(Drawing) ~= "table" and type(Drawing) ~= "userdata" then return end
    fovcircle = Drawing.new("Circle")
    fovcircle.Filled = false
    fovcircle.Thickness = 1
    fovcircle.NumSides = 80
    fovcircle.Transparency = 0.7

    snapline = Drawing.new("Line")
    snapline.Thickness = 1
    snapline.Transparency = 0.85

    targetbox = Drawing.new("Square")
    targetbox.Filled = true
    targetbox.Color = Color3.fromRGB(20, 21, 25)
    targetbox.Size = Vector2.new(210, 58)
    targetbox.Transparency = 0.88

    for _ = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        targetlines[#targetlines + 1] = line
    end

    for index = 1, 3 do
        local text = Drawing.new("Text")
        text.Size = 13
        text.Font = 2
        text.Color = Color3.fromRGB(240, 240, 245)
        text.Outline = true
        targettexts[index] = text
    end
end

local function findtarget()
    if not settings.fov then return end
    local center = userinputservice:GetMouseLocation()
    local bestvehicle
    local bestpart
    local bestscreen = settings.fovsize
    for vehicle, data in pairs(vehicles) do
        if vehicle.Parent and data.part.Parent and not friendly(vehicle) then
            local distance = (camera.CFrame.Position - data.part.Position).Magnitude
            if distance <= settings.renderdistance then
                for _, part in ipairs(targetparts(vehicle)) do
                    local point, onscreen = camera:WorldToViewportPoint(part.Position)
                    if onscreen and point.Z > 0 then
                        local screen = (Vector2.new(point.X, point.Y) - center).Magnitude
                        local passedvisibility = not settings.silentvisiblecheck or rayvisible(part, vehicle)
                        if screen <= bestscreen and passedvisibility then
                            bestvehicle = vehicle
                            bestpart = part
                            bestscreen = screen
                        end
                    end
                end
            end
        end
    end
    return bestvehicle, bestpart
end

local function updatetargeting(delta)
    if not fovcircle then return end
    gradientclock += delta
    local viewport = camera.ViewportSize
    local center = userinputservice:GetMouseLocation()
    fovcircle.Position = center
    fovcircle.Radius = settings.fovsize
    fovcircle.Color = settings.fovcolor
    fovcircle.Visible = settings.fov

    currenttarget, currenttargetpart = findtarget()
    if currenttarget and currenttargetpart then
        hudtarget = currenttarget
        hudtargetpart = currenttargetpart
    end
    local displaytarget = currenttarget or hudtarget
    local displaypart = currenttargetpart or hudtargetpart
    local data = displaytarget and vehicles[displaytarget]
    local currentdata = currenttarget and vehicles[currenttarget]
    local point, onscreen
    if currentdata and currenttargetpart then point, onscreen = camera:WorldToViewportPoint(currenttargetpart.Position) end
    local hastarget = currentdata and currenttargetpart and onscreen and point.Z > 0

    snapline.Visible = settings.snaplines and settings.fov and hastarget or false
    if snapline.Visible then
        snapline.From = center
        snapline.To = Vector2.new(point.X, point.Y)
        snapline.Color = settings.fovcolor
    end

    local showtarget = settings.targethud and settings.fov and hastarget or false
    targetalpha += ((showtarget and 1 or 0) - targetalpha) * math.clamp(delta * 10, 0, 1)
    if math.abs(targetalpha - (showtarget and 1 or 0)) < 0.01 then targetalpha = showtarget and 1 or 0 end
    targetbox.Visible = targetalpha > 0.01
    for _, text in ipairs(targettexts) do text.Visible = targetbox.Visible end
    for _, line in ipairs(targetlines) do line.Visible = targetbox.Visible end
    if targetbox.Visible and data and data.part.Parent and displaypart and displaypart.Parent then
        local scale = 0.9 + targetalpha * 0.1
        local size = Vector2.new(210 * scale, 58 * scale)
        local position = Vector2.new(viewport.X / 2 - size.X / 2, 42 + (1 - targetalpha) * 10)
        targetbox.Size = size
        local distance = (camera.CFrame.Position - data.part.Position).Magnitude
        targetbox.Position = position
        targetbox.Transparency = targetalpha * 0.88
        targettexts[1].Position = position + Vector2.new(10, 8)
        targettexts[2].Position = position + Vector2.new(10, 25)
        targettexts[3].Position = position + Vector2.new(10, 42)
        for _, text in ipairs(targettexts) do text.Transparency = targetalpha end
        targettexts[1].Text = "Part: " .. displaypart.Name
        targettexts[2].Text = "Vehicle: " .. displaytarget.Name
        targettexts[3].Text = "Distance: " .. math.floor(distance + 0.5) .. "m"
        local phase = (math.sin(gradientclock * 2) + 1) * 0.5
        local first = settings.fovcolor:Lerp(settings.espcolor, phase)
        local second = settings.espcolor:Lerp(settings.fovcolor, phase)
        local x, y = position.X, position.Y
        local w, h = size.X, size.Y
        local points = {
            {Vector2.new(x, y), Vector2.new(x + w, y), first},
            {Vector2.new(x + w, y), Vector2.new(x + w, y + h), second},
            {Vector2.new(x + w, y + h), Vector2.new(x, y + h), first},
            {Vector2.new(x, y + h), Vector2.new(x, y), second},
        }
        for index, line in ipairs(targetlines) do
            line.From = points[index][1]
            line.To = points[index][2]
            line.Color = points[index][3]
            line.Transparency = targetalpha
        end
    elseif targetbox.Visible then
        targetalpha = 0
        targetbox.Visible = false
        for _, text in ipairs(targettexts) do text.Visible = false end
        for _, line in ipairs(targetlines) do line.Visible = false end
    end
    if targetalpha == 0 then
        hudtarget = nil
        hudtargetpart = nil
    end
end

--// loading

local loading = library:CreateLoading({Title = "slimekrew", Icon = icon, LoadingIcon = "loader-circle", TotalSteps = 2, ShowSidebar = false})
loading:SetMessage("Cursed Tank")
loading:SetDescription("Preparing vehicle targeting")
loading:SetCurrentStep(1)
task.wait(1)
makedrawings()
scanvehicles()
hooksilentaim()
loading:SetMessage("Ready")
loading:SetDescription("Vehicle systems loaded")
loading:SetCurrentStep(2)
task.wait(1)

--// window

local window = library:CreateWindow({
    Title = "slimekrew",
    Footer = "cursed tank simulator",
    Icon = icon,
    Size = UDim2.fromOffset(840, 510),
    Resizable = false,
    Blur = false,
    BuiltInSettings = true,
    BuiltInPlayerList = true,
    ProfileFolder = "Potas/cursed-tank/profiles",
    ToggleKeybind = Enum.KeyCode.RightShift,
    NotifySide = "Left",
})

local tabs = {
    main = window:AddTab("Main", "house"),
    visuals = window:AddTab("Visuals", "eye"),
    misc = window:AddTab("Misc", "wrench"),
    settings = window:AddTab("Settings", "settings"),
}

tabs.settings:AddLeftTabbox("Menu")
loading:Continue()

--// ui

local targetingbox = tabs.main:AddLeftTabbox("Targeting")
local silentaim = targetingbox:AddTab("Silent Aim")
local targeting = targetingbox:AddTab("FOV")
silentaim:AddToggle("SilentAim", {Text = "Silent Aim", Callback = function(value) settings.silentaim = value; if value then hooksilentaim() end end})
silentaim:AddToggle("SilentVisibleCheck", {Text = "Visible Check", Callback = function(value) settings.silentvisiblecheck = value end})
silentaim:AddToggle("SilentPrediction", {Text = "Trajectory Prediction", Default = true, Callback = function(value) settings.prediction = value end})
silentaim:AddMultiDropdown("SilentHitParts", {Text = "Hit Parts", Values = hitpartnames, Default = {"Center"}, Callback = function(value) settings.hitparts = value end})
targeting:AddToggle("TargetFOV", {Text = "FOV", Callback = function(value) settings.fov = value end})
targeting:AddSlider("TargetFOVSize", {Text = "FOV Size", Min = 25, Max = 600, Default = 180, Rounding = 0, Callback = function(value) settings.fovsize = value end})
targeting:AddLabel("FOV Color"):AddColorPicker("TargetFOVColor", {Default = settings.fovcolor, Title = "FOV Color", Callback = function(value) settings.fovcolor = value end})
targeting:AddToggle("TargetSnaplines", {Text = "Snaplines", Callback = function(value) settings.snaplines = value end})
targeting:AddToggle("TargetHUD", {Text = "Target HUD", Callback = function(value) settings.targethud = value end})

local espbox = tabs.visuals:AddLeftTabbox("Vehicle ESP")
local esp = espbox:AddTab("ESP")
local highlights = espbox:AddTab("Highlights")
esp:AddToggle("VehicleESP", {Text = "Vehicle ESP", Callback = function(value) settings.vehicleesp = value end})
esp:AddToggle("VehicleESPTeamCheck", {Text = "Team Check", Callback = function(value) settings.espteamcheck = value end})
esp:AddToggle("VehicleESPVisibleCheck", {Text = "Visible Check", Callback = function(value) settings.espvisiblecheck = value end})
esp:AddSlider("VehicleESPDistance", {Text = "Render Distance", Min = 100, Max = 10000, Default = 3000, Rounding = 0, Suffix = "m", Callback = function(value) settings.renderdistance = value end})
esp:AddLabel("ESP Color"):AddColorPicker("VehicleESPColor", {Default = settings.espcolor, Title = "ESP Color", Callback = function(value) settings.espcolor = value end})
highlights:AddToggle("EnemyHighlight", {Text = "Enemy Highlight", Callback = function(value) settings.enemyhighlight = value end}):AddColorPicker("EnemyHighlightColor", {Default = settings.enemycolor, Title = "Enemy Highlight", Callback = function(value) settings.enemycolor = value end})
highlights:AddToggle("TeamHighlight", {Text = "Team Highlight", Callback = function(value) settings.teamhighlight = value end}):AddColorPicker("TeamHighlightColor", {Default = settings.teamcolor, Title = "Team Highlight", Callback = function(value) settings.teamcolor = value end})

local utilitybox = tabs.misc:AddLeftTabbox("Utility")
local utility = utilitybox:AddTab("Mouse")
utility:AddToggle("UnlockMouse", {Text = "Unlock Mouse", Callback = function(value)
    settings.unlockmouse = value
    if not value then
        userinputservice.MouseBehavior = originalmousebehavior
        userinputservice.MouseIconEnabled = originalmouseicon
    end
end})

watermark = library:AddDraggableLabel({Text = "cursed tank | 0 fps | 0ms", Icon = avatar, IconPosition = "left"})
watermark:SetVisible(false)

--// runtime

connect(runservice.RenderStepped, function(delta)
    camera = workspace.CurrentCamera or camera
    fpsframes += 1
    fpstime += delta
    updatevehicles(delta)
    updatetargeting(delta)
    if settings.unlockmouse then
        userinputservice.MouseBehavior = Enum.MouseBehavior.Default
        userinputservice.MouseIconEnabled = true
    end
    if fpstime >= 0.5 then
        local fps = math.floor(fpsframes / fpstime + 0.5)
        local ping = 0
        pcall(function() ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
        watermark:SetText("cursed tank | " .. fps .. " fps | " .. ping .. "ms")
        fpsframes = 0
        fpstime = 0
    end
end)

connect(runservice.Heartbeat, function()
    if os.clock() - lastscan >= 0.5 then
        lastscan = os.clock()
        scanvehicles()
    end
end)

--// cleanup

library:OnUnload(function()
    for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
    clearvehicleesp()
    userinputservice.MouseBehavior = originalmousebehavior
    userinputservice.MouseIconEnabled = originalmouseicon
    if oldtrajectory and trajectorymodule and type(hookfunction) == "function" then
        pcall(function() hookfunction(trajectorymodule.Trajectory, oldtrajectory) end)
    end
    for _, drawing in ipairs({fovcircle, snapline, targetbox}) do pcall(function() drawing:Remove() end) end
    for _, text in ipairs(targettexts) do pcall(function() text:Remove() end) end
    for _, line in ipairs(targetlines) do pcall(function() line:Remove() end) end
    if env.slimekrewcursedtank == library then env.slimekrewcursedtank = nil end
end)

env.slimekrewcursedtank = library
