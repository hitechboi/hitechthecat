--// links

local libraryurl = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"
local iconurl = "https://www.image2url.com/r2/default/images/1785368907766-d375b142-01d6-45be-a9fc-ae3e07254a85.jpg"

--// vars

local env = getgenv()
local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local stats = game:GetService("Stats")
local collectionservice = game:GetService("CollectionService")
local tweenservice = game:GetService("TweenService")
local localplayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local source = game:HttpGet(libraryurl .. "?cachebust=" .. tostring(os.time()), true)
local compile, compileerror = loadstring(source, "slimekrew Library")

assert(compile, compileerror)

if env.slimekrewcursedtank then
    pcall(function() env.slimekrewcursedtank:Unload() end)
end

local library = compile()
local toggles = library.Toggles
local options = library.Options
local connections = {}
local disabledconnections = {}
local originals = {}
local espobjects = {}
local trajectorylines = {}
local radarbox
local radartext = {}
local avatar = iconurl
local currentvehicle
local currentconfig
local lastvehiclecheck = 0
local lastespcheck = 0
local lastradarcheck = 0
local fpsframes = 0
local fpstime = 0
local watermark
local settings = {
    nocamerashake = false,
    norecoilzoom = false,
    fovenabled = false,
    fov = 70,
    zoomenabled = false,
    zoom = 36,
    thermal = false,
    noweather = false,
    projectileesp = false,
    missileesp = false,
    trajectory = false,
    trajectorytime = 4,
    trajectorysteps = 32,
    suspension = false,
    stiffness = 1,
    damping = 1,
    rideheight = 0,
    handling = false,
    torque = 1,
    friction = 1,
    steering = 1,
    radar = false,
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

local function notify(text)
    library:Notify({Title = "Cursed Tank", Description = text, Time = 3})
end

local function remember(object, property)
    if not object then return end
    originals[object] = originals[object] or {}
    if originals[object][property] == nil then
        pcall(function() originals[object][property] = object[property] end)
    end
end

local function setproperty(object, property, value)
    if not object then return end
    remember(object, property)
    pcall(function() object[property] = value end)
end

local function setattribute(object, attribute, value)
    if not object then return end
    originals[object] = originals[object] or {}
    local key = "attribute:" .. attribute
    if originals[object][key] == nil then
        local old = object:GetAttribute(attribute)
        originals[object][key] = old == nil and "__nil" or old
    end
    pcall(function() object:SetAttribute(attribute, value) end)
end

local function restoreall()
    for object, values in pairs(originals) do
        if object and object.Parent then
            for property, value in pairs(values) do
                if property:sub(1, 10) == "attribute:" then
                    local attribute = property:sub(11)
                    pcall(function() object:SetAttribute(attribute, value == "__nil" and nil or value) end)
                else
                    pcall(function() object[property] = value end)
                end
            end
        end
    end
    table.clear(originals)
end

local function ownername(vehicle)
    local hullnode = vehicle and vehicle:FindFirstChild("HullNode")
    return hullnode and hullnode:GetAttribute("Owner") or vehicle and vehicle:GetAttribute("Owner")
end

local function islocalvehicle(vehicle)
    if not vehicle or not vehicle:IsA("Model") then return false end
    local owner = ownername(vehicle)
    if owner == localplayer.Name or owner == localplayer.UserId or tostring(owner) == tostring(localplayer.UserId) then return true end
    return vehicle.Name == "Chassis" .. tostring(localplayer) or vehicle.Name == "Chassis" .. localplayer.Name
end

local function findvehicle()
    for _, foldername in ipairs({"Vehicles", "VehiclesSim"}) do
        local folder = workspace:FindFirstChild(foldername)
        if folder then
            for _, vehicle in ipairs(folder:GetChildren()) do
                if islocalvehicle(vehicle) then return vehicle end
            end
        end
    end
end

local function findconfig(vehicle)
    if not vehicle then return end
    local hullstr = vehicle:FindFirstChild("HullStr")
    local hull = vehicle:FindFirstChild("Hull")
    local selected = hull and hullstr and hull:FindFirstChild(hullstr.Value)
    return selected and selected:FindFirstChild("Config") or vehicle:FindFirstChild("Config", true)
end

local function setnumber(folder, names, multiplier, absolute)
    if not folder then return end
    for _, name in ipairs(names) do
        local value = folder:FindFirstChild(name, true)
        if value and (value:IsA("NumberValue") or value:IsA("IntValue")) then
            remember(value, "Value")
            local base = originals[value] and originals[value].Value or value.Value
            pcall(function() value.Value = absolute ~= nil and absolute or base * multiplier end)
        end
    end
end

local function applysuspension()
    if not currentvehicle then return end
    setattribute(currentvehicle, "SuspStiffnessMul", settings.stiffness)
    setattribute(currentvehicle, "SuspDampingMul", settings.damping)
    setattribute(currentvehicle, "SuspRideHeightOff", settings.rideheight)
    if currentconfig then
        setnumber(currentconfig, {"SpringStiffness"}, settings.stiffness)
        setnumber(currentconfig, {"SpringDamping"}, settings.damping)
        local offset = currentconfig:FindFirstChild("SpringLengthOffset", true)
        if offset and (offset:IsA("NumberValue") or offset:IsA("IntValue")) then
            remember(offset, "Value")
            local base = originals[offset] and originals[offset].Value or offset.Value
            pcall(function() offset.Value = base + settings.rideheight end)
        end
    end
end

local function applyhandling()
    if not currentconfig then return end
    setnumber(currentconfig, {"Torque", "EngineTorque", "MaxTorque"}, settings.torque)
    setnumber(currentconfig, {"WheelFriction", "TrackFriction", "Grip"}, settings.friction)
    setnumber(currentconfig, {"SteerSpeed", "SteeringSpeed", "SteerReturn"}, settings.steering)
end

local function setshake(state)
    settings.nocamerashake = state
    local event = replicatedstorage:FindFirstChild("FreeCamShake")
    if event and type(getconnections) == "function" then
        local signal = event:IsA("BindableEvent") and event.Event or event.OnClientEvent
        if signal then
            for _, connection in ipairs(getconnections(signal)) do
                if state and connection.Disable then
                    connection:Disable()
                    disabledconnections[connection] = true
                elseif not state and disabledconnections[connection] and connection.Enable then
                    connection:Enable()
                    disabledconnections[connection] = nil
                end
            end
        end
    end
end

local function setweather(state)
    settings.noweather = state
    local resources = replicatedstorage:FindFirstChild("WeatherResources")
    local modules = resources and resources:FindFirstChild("Modules")
    local handlers = modules and modules:FindFirstChild("PrecipitationHandlers")
    if handlers then
        for _, name in ipairs({"Rain", "Snow", "Hail"}) do
            local module = handlers:FindFirstChild(name)
            if module then pcall(function()
                local handler = require(module)
                if state and handler.Disable then handler:Disable() end
            end) end
        end
    end
    local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
    if clouds then
        if state then
            setproperty(clouds, "Cover", 0)
            setproperty(clouds, "Density", 0)
        elseif originals[clouds] then
            pcall(function()
                clouds.Cover = originals[clouds].Cover or clouds.Cover
                clouds.Density = originals[clouds].Density or clouds.Density
            end)
        end
    end
end

local function ismissile(object)
    local name = object.Name:lower()
    return name:find("atgm", 1, true) ~= nil or name:find("missile", 1, true) ~= nil
        or object:GetAttribute("LaserGuided") ~= nil or object:GetAttribute("TopAttack") ~= nil
        or object:GetAttribute("AccelTime") ~= nil or object:FindFirstChild("MAW") ~= nil
end

local function objectpart(object)
    if object:IsA("BasePart") then return object end
    if object:IsA("Model") then return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true) end
end

local function removeesp(object)
    local data = espobjects[object]
    if not data then return end
    pcall(function() data.highlight:Destroy() end)
    pcall(function() data.billboard:Destroy() end)
    espobjects[object] = nil
end

local function addesp(object)
    if espobjects[object] then return end
    local part = objectpart(object)
    if not part then return end
    local missile = ismissile(object)
    if missile and not settings.missileesp or not missile and not settings.projectileesp then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "SlimekrewProjectileESP"
    highlight.Adornee = object
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = missile and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(235, 235, 235)
    highlight.OutlineColor = highlight.FillColor
    highlight.Parent = object
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SlimekrewProjectileLabel"
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(180, 34)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.Parent = part
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextStrokeTransparency = 0
    label.TextColor3 = highlight.FillColor
    label.Parent = billboard
    espobjects[object] = {highlight = highlight, billboard = billboard, label = label, part = part, missile = missile}
end

local function scanprojectiles()
    local folder = workspace:FindFirstChild("Projectiles")
    if folder then
        for _, object in ipairs(folder:GetChildren()) do addesp(object) end
    end
    for object in pairs(espobjects) do
        if not object.Parent then removeesp(object) end
    end
end

local function updateesp()
    for object, data in pairs(espobjects) do
        if not object.Parent or not data.part.Parent then
            removeesp(object)
        elseif data.missile and not settings.missileesp or not data.missile and not settings.projectileesp then
            removeesp(object)
        else
            local distance = (camera.CFrame.Position - data.part.Position).Magnitude
            local speed = data.part.AssemblyLinearVelocity.Magnitude
            data.label.Text = (data.missile and "Missile" or "Shell") .. " | " .. math.floor(distance + 0.5) .. "m\n" .. math.floor(speed + 0.5) .. " studs/s"
        end
    end
end

local function cleartrajectory()
    for _, line in ipairs(trajectorylines) do pcall(function() line:Remove() end) end
    table.clear(trajectorylines)
end

local function makelines()
    cleartrajectory()
    if type(Drawing) ~= "table" and type(Drawing) ~= "userdata" then return end
    for _ = 1, 64 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        line.Color = Color3.fromRGB(235, 235, 235)
        table.insert(trajectorylines, line)
    end
end

local function closestprojectile()
    local best, bestdistance
    for object, data in pairs(espobjects) do
        if object.Parent and data.part.Parent then
            local distance = (camera.CFrame.Position - data.part.Position).Magnitude
            if not bestdistance or distance < bestdistance then best, bestdistance = data.part, distance end
        end
    end
    return best
end

local function updatetrajectory()
    for _, line in ipairs(trajectorylines) do line.Visible = false end
    if not settings.trajectory then return end
    local part = closestprojectile()
    if not part then return end
    local origin = part.Position
    local velocity = part.AssemblyLinearVelocity
    local gravity = Vector3.new(0, -workspace.Gravity, 0)
    local steps = math.clamp(math.floor(settings.trajectorysteps), 8, #trajectorylines)
    local dt = settings.trajectorytime / steps
    local previous = origin
    for index = 1, steps do
        local time = index * dt
        local position = origin + velocity * time + gravity * 0.5 * time * time
        local ray = workspace:Raycast(previous, position - previous)
        if ray then position = ray.Position end
        local from, fromvisible = camera:WorldToViewportPoint(previous)
        local to, tovisible = camera:WorldToViewportPoint(position)
        local line = trajectorylines[index]
        line.From = Vector2.new(from.X, from.Y)
        line.To = Vector2.new(to.X, to.Y)
        line.Visible = fromvisible or tovisible
        previous = position
        if ray then break end
    end
end

local function findradar()
    if currentvehicle then
        for _, object in ipairs(currentvehicle:GetDescendants()) do
            if object:IsA("Motor6D") and object.Name == "SpinMotor" then return object.Parent end
        end
    end
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Motor6D") and object.Name == "SpinMotor" then return object.Parent end
    end
end

local function makeradar()
    if radarbox then return end
    if type(Drawing) ~= "table" and type(Drawing) ~= "userdata" then return end
    radarbox = Drawing.new("Square")
    radarbox.Size = Vector2.new(245, 92)
    radarbox.Position = Vector2.new(18, 120)
    radarbox.Color = Color3.fromRGB(210, 210, 215)
    radarbox.Filled = true
    radarbox.Transparency = 0.82
    radarbox.Visible = false
    for index = 1, 4 do
        local text = Drawing.new("Text")
        text.Position = Vector2.new(28, 126 + index * 18)
        text.Size = 13
        text.Font = 2
        text.Color = Color3.fromRGB(240, 240, 240)
        text.Outline = true
        text.Visible = false
        radartext[index] = text
    end
end

local function updateradar()
    if not radarbox then return end
    radarbox.Visible = settings.radar
    for _, text in ipairs(radartext) do text.Visible = settings.radar end
    if not settings.radar then return end
    local radar = findradar()
    local target = radar and radar:FindFirstChild("TrackTarget")
    local targetobject = target and target.Value
    radartext[1].Text = "Radar: " .. (radar and radar.Name or "None")
    radartext[2].Text = "Mode: " .. (radar and (radar:GetAttribute("Track") and "Track" or radar:GetAttribute("Search") and "Search" or "Standby") or "Unavailable")
    radartext[3].Text = "Target: " .. (targetobject and targetobject.Name or "None")
    radartext[4].Text = "Spin: " .. tostring(radar and radar:GetAttribute("SpinRate") or 0) .. " | Health: " .. tostring(radar and radar:GetAttribute("Health") or "N/A")
end

--// loading

local loading = library:CreateLoading({Title = "slimekrew", Icon = iconurl, LoadingIcon = "loader-circle", TotalSteps = 3, ShowSidebar = false})
loading:SetMessage("Cursed Tank")
loading:SetDescription("Discovering client systems")
loading:SetCurrentStep(1)
task.wait(1)
loading:SetMessage("Visual systems")
loading:SetDescription("Preparing ESP and trajectory drawings")
loading:SetCurrentStep(2)
task.wait(1)

makelines()
makeradar()

--// window

local window = library:CreateWindow({
    Title = "slimekrew",
    Footer = "cursed tank simulator",
    Icon = iconurl,
    Size = UDim2.fromOffset(840, 510),
    Resizable = false,
    BuiltInSettings = true,
    BuiltInPlayerList = true,
    ProfileFolder = "Potas/cursed-tank/profiles",
    ToggleKeybind = Enum.KeyCode.RightShift,
    NotifySide = "Left",
})

local tabs = {
    main = window:AddTab("Main", "house"),
    visuals = window:AddTab("Visuals", "eye"),
    vehicle = window:AddTab("Vehicle", "car"),
    radar = window:AddTab("Radar", "radio"),
    settings = window:AddTab("Settings", "settings"),
}

tabs.settings:AddLeftTabbox("Menu")

loading:SetMessage("Ready")
loading:SetDescription("10 client systems loaded")
loading:SetCurrentStep(3)
task.wait(1)
loading:Continue()

--// ui

local cameraeffects = tabs.main:AddLeftGroupbox("Camera")
cameraeffects:AddToggle("NoCameraShake", {Text = "No Camera Shake", Callback = setshake})
cameraeffects:AddToggle("NoRecoilZoom", {Text = "No Recoil Zoom", Callback = function(value) settings.norecoilzoom = value end})
cameraeffects:AddToggle("CustomFOV", {Text = "Custom FOV", Callback = function(value) settings.fovenabled = value end})
cameraeffects:AddSlider("FOVValue", {Text = "FOV", Min = 20, Max = 120, Default = 70, Rounding = 0, Callback = function(value) settings.fov = value end})
cameraeffects:AddToggle("CustomZoom", {Text = "Custom Zoom", Callback = function(value) settings.zoomenabled = value end})
cameraeffects:AddSlider("ZoomValue", {Text = "Zoom", Min = 6, Max = 120, Default = 36, Rounding = 0, Callback = function(value) settings.zoom = value end})

local environment = tabs.main:AddRightGroupbox("Environment")
environment:AddToggle("AlwaysThermal", {Text = "Always Thermal", Callback = function(value) settings.thermal = value end})
environment:AddToggle("NoWeather", {Text = "No Weather", Callback = setweather})

local projectiles = tabs.visuals:AddLeftGroupbox("Projectiles")
projectiles:AddToggle("ProjectileESP", {Text = "Projectile ESP", Callback = function(value) settings.projectileesp = value; scanprojectiles() end})
projectiles:AddToggle("MissileESP", {Text = "Missile ESP", Callback = function(value) settings.missileesp = value; scanprojectiles() end})
projectiles:AddToggle("TrajectoryPredictor", {Text = "Trajectory Predictor", Callback = function(value) settings.trajectory = value end})
projectiles:AddSlider("TrajectoryTime", {Text = "Prediction Time", Min = 0.5, Max = 8, Default = 4, Rounding = 1, Callback = function(value) settings.trajectorytime = value end})
projectiles:AddSlider("TrajectorySteps", {Text = "Prediction Steps", Min = 8, Max = 64, Default = 32, Rounding = 0, Callback = function(value) settings.trajectorysteps = value end})

local suspension = tabs.vehicle:AddLeftGroupbox("Suspension")
suspension:AddToggle("SuspensionTuning", {Text = "Suspension Tuning", Callback = function(value) settings.suspension = value; if value then applysuspension() end end})
suspension:AddSlider("SuspensionStiffness", {Text = "Stiffness", Min = 0.5, Max = 2, Default = 1, Rounding = 2, Callback = function(value) settings.stiffness = value; if settings.suspension then applysuspension() end end})
suspension:AddSlider("SuspensionDamping", {Text = "Damping", Min = 0.5, Max = 2, Default = 1, Rounding = 2, Callback = function(value) settings.damping = value; if settings.suspension then applysuspension() end end})
suspension:AddSlider("SuspensionHeight", {Text = "Ride Height", Min = -0.4, Max = 0.4, Default = 0, Rounding = 2, Callback = function(value) settings.rideheight = value; if settings.suspension then applysuspension() end end})

local handling = tabs.vehicle:AddRightGroupbox("Handling")
handling:AddToggle("HandlingTuning", {Text = "Handling Tuning", Callback = function(value) settings.handling = value; if value then applyhandling() end end})
handling:AddSlider("TorqueMultiplier", {Text = "Torque", Min = 0.25, Max = 5, Default = 1, Rounding = 2, Callback = function(value) settings.torque = value; if settings.handling then applyhandling() end end})
handling:AddSlider("FrictionMultiplier", {Text = "Friction", Min = 0.25, Max = 3, Default = 1, Rounding = 2, Callback = function(value) settings.friction = value; if settings.handling then applyhandling() end end})
handling:AddSlider("SteeringMultiplier", {Text = "Steering", Min = 0.25, Max = 4, Default = 1, Rounding = 2, Callback = function(value) settings.steering = value; if settings.handling then applyhandling() end end})
handling:AddButton({Text = "Reapply Vehicle Tuning", Func = function() currentvehicle = findvehicle(); currentconfig = findconfig(currentvehicle); if settings.suspension then applysuspension() end; if settings.handling then applyhandling() end; notify(currentvehicle and "Tuning applied to " .. currentvehicle.Name or "Local vehicle not found") end})

local radar = tabs.radar:AddLeftGroupbox("Radar")
radar:AddToggle("RadarPanel", {Text = "Radar Information Panel", Callback = function(value) settings.radar = value; updateradar() end})
radar:AddButton({Text = "Refresh Radar", Func = updateradar})

watermark = library:AddDraggableLabel({Text = "cursed tank | 0 fps | 0ms", Icon = avatar, IconPosition = "left"})
watermark:SetVisible(false)

--// runtime

connect(runservice.RenderStepped, function(delta)
    camera = workspace.CurrentCamera or camera
    fpsframes += 1
    fpstime += delta
    if settings.fovenabled and camera then camera.FieldOfView = settings.fov end
    if settings.norecoilzoom and shared.recoilZoom then shared.recoilZoom.Value = 0 end
    if settings.zoomenabled then
        shared.zoom = settings.zoom
        if shared.zoomFollow then shared.zoomFollow.Value = settings.zoom end
    end
    if settings.thermal then
        shared.Thermals = true
        shared.BToggle = false
    end
    updatetrajectory()
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
    local now = os.clock()
    if now - lastvehiclecheck >= 1 then
        lastvehiclecheck = now
        local vehicle = findvehicle()
        if vehicle ~= currentvehicle then
            currentvehicle = vehicle
            currentconfig = findconfig(vehicle)
            if vehicle then notify("Local vehicle detected: " .. vehicle.Name) end
        end
        if settings.suspension then applysuspension() end
        if settings.handling then applyhandling() end
    end
    if now - lastespcheck >= 0.2 then
        lastespcheck = now
        scanprojectiles()
        updateesp()
    end
    if now - lastradarcheck >= 0.25 then
        lastradarcheck = now
        updateradar()
    end
end)

--// cleanup

library:OnUnload(function()
    for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
    for connection in pairs(disabledconnections) do pcall(function() if connection.Enable then connection:Enable() end end) end
    for object in pairs(espobjects) do removeesp(object) end
    cleartrajectory()
    if radarbox then pcall(function() radarbox:Remove() end) end
    for _, text in ipairs(radartext) do pcall(function() text:Remove() end) end
    restoreall()
    if env.slimekrewcursedtank == library then env.slimekrewcursedtank = nil end
end)

env.slimekrewcursedtank = library
