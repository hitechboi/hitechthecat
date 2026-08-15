--// links

local libraryurl = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"

--// vars

local env = getgenv()
local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local stats = game:GetService("Stats")
local userinputservice = game:GetService("UserInputService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local collectionservice = game:GetService("CollectionService")
local starterplayer = game:GetService("StarterPlayer")
local localplayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local fetched, source = pcall(game.HttpGet, game, libraryurl .. "?cachebust=" .. tostring(os.time()), true)

assert(fetched and type(source) == "string" and #source > 0, "failed to download slimekrew library: " .. tostring(source))

local compile, compileerror = loadstring(source, "slimekrew Library")

assert(compile, compileerror)

if env.slimekrewcursedtank then
    pcall(function() env.slimekrewcursedtank:Unload() end)
end

local library = compile()
local icon = library:GetRandomBrandIcon()
local connections = {}
local vehicles = {}
local shelltrails = {}
local avatar = icon
local lastscan = 0
local fpsframes = 0
local fpstime = 0
local watermark
local fovcircle
local snapline
local predictioncircle
local targetbox
local targettexts = {}
local targetlines = {}
local currenttarget
local currenttargetpart
local currenttargetacceleration = Vector3.zero
local predictedpoint
local trajectorycache
local gunstates = {}
local lastgunscan = 0
local hudtarget
local hudtargetpart
local oldtrajectory
local trajectorymodule
local targetalpha = 0
local gradientclock = 0
local originalmousebehavior = userinputservice.MouseBehavior
local originalmouseicon = userinputservice.MouseIconEnabled
local originalcameramode = localplayer.CameraMode
local originalmouselockoption = starterplayer.EnableMouseLockOption
local originalmouseoverride
pcall(function() originalmouseoverride = userinputservice.OverrideMouseIconBehavior end)
local mousebinding = "slimekrewcursedtankmouse"
local mouseearlybinding = "slimekrewcursedtankmouseearly"
local mousemodal = Instance.new("TextButton")
mousemodal.Name = "UnlockMouseModal"
mousemodal.BackgroundTransparency = 1
mousemodal.Active = true
mousemodal.AutoButtonColor = false
mousemodal.Modal = false
mousemodal.Size = UDim2.fromScale(0, 0)
mousemodal.Text = ""
mousemodal.Visible = true
mousemodal.ZIndex = -999
mousemodal.Parent = library.ScreenGui
local settings = {
    vehicleesp = false,
    vehicledisplays = {Highlight = true, Name = true, Distance = true},
    espteamcheck = false,
    espvisiblecheck = false,
    renderdistance = 3000,
    espvisiblecolor = Color3.fromRGB(80, 220, 120),
    espblockedcolor = Color3.fromRGB(235, 75, 75),
    fov = false,
    fovsize = 180,
    fovcolor = Color3.fromRGB(235, 235, 240),
    fovgradient = false,
    snaplines = false,
    targethud = false,
    silentaim = false,
    silentvisiblecheck = false,
    predictionmarker = false,
    shelltrail = false,
    shelltrailcolor = Color3.fromRGB(255, 60, 60),
    refinement = 3,
    nospread = false,
    reload = false,
    reloadmult = 2,
    nooverheat = false,
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

local function applymouseunlock()
    if not settings.unlockmouse then return end
    mousemodal.Modal = true
    pcall(function() localplayer.CameraMode = Enum.CameraMode.Classic end)
    pcall(function() starterplayer.EnableMouseLockOption = false end)
    userinputservice.MouseBehavior = Enum.MouseBehavior.Default
    userinputservice.MouseIconEnabled = true
    pcall(function() userinputservice.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow end)
end

local function setmouseunlock(value)
    settings.unlockmouse = value == true
    pcall(runservice.UnbindFromRenderStep, runservice, mousebinding)
    pcall(runservice.UnbindFromRenderStep, runservice, mouseearlybinding)
    mousemodal.Modal = settings.unlockmouse
    if settings.unlockmouse then
        applymouseunlock()
        runservice:BindToRenderStep(mouseearlybinding, Enum.RenderPriority.First.Value, applymouseunlock)
        runservice:BindToRenderStep(mousebinding, Enum.RenderPriority.Last.Value + 100, applymouseunlock)
    else
        pcall(function() localplayer.CameraMode = originalcameramode end)
        pcall(function() starterplayer.EnableMouseLockOption = originalmouselockoption end)
        userinputservice.MouseBehavior = originalmousebehavior
        userinputservice.MouseIconEnabled = originalmouseicon
        if originalmouseoverride then pcall(function() userinputservice.OverrideMouseIconBehavior = originalmouseoverride end) end
    end
end

connect(userinputservice:GetPropertyChangedSignal("MouseBehavior"), function()
    if settings.unlockmouse and userinputservice.MouseBehavior ~= Enum.MouseBehavior.Default then
        task.defer(applymouseunlock)
    end
end)

local function parentmenu()
    local screengui = library and library.ScreenGui
    if not screengui then return end
    local parent
    if type(gethui) == "function" then
        local success, result = pcall(gethui)
        if success and typeof(result) == "Instance" then parent = result end
    end
    if parent then
        pcall(function()
            if type(protectgui) == "function" then protectgui(screengui) end
            screengui.Parent = parent
        end)
    elseif not screengui.Parent then
        screengui.Parent = localplayer:WaitForChild("PlayerGui")
    end
end

parentmenu()
connect(localplayer.CharacterAdded, function()
    task.defer(parentmenu)
end)

local function ownername(vehicle)
    local hullnode = vehicle and vehicle:FindFirstChild("HullNode")
    local owner = hullnode and hullnode:GetAttribute("Owner") or vehicle and vehicle:GetAttribute("Owner")
    local ownervalue = vehicle and vehicle:FindFirstChild("Owner")
    if owner == nil and ownervalue and ownervalue:IsA("ObjectValue") and ownervalue.Value then
        return ownervalue.Value.Name
    end
    if owner == nil and ownervalue and ownervalue:IsA("StringValue") then
        return ownervalue.Value
    end
    if owner == nil and vehicle and vehicle.Name:sub(1, 7) == "Chassis" then
        return vehicle.Name:sub(8)
    end
    return owner
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
    local serverteam = vehicle and vehicle:GetAttribute("team")
    if vehicle and vehicle:GetAttribute("Server") and serverteam and localplayer.Team then
        return serverteam == localplayer.Team.Name
    end
    local owner = ownerplayer(vehicle)
    return owner and localplayer.Team ~= nil and owner.Team == localplayer.Team
end

local function vehiclepart(vehicle)
    return vehicle:FindFirstChild("HullNode") or vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
end

local function isvehicle(vehicle)
    return vehicle:IsA("Model") and (vehicle:FindFirstChild("HullNode") ~= nil or vehicle:GetAttribute("Server") == true)
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

local function removeshelltrail(projectile)
    local trail = shelltrails[projectile]
    if trail then pcall(function() trail:Destroy() end) end
    shelltrails[projectile] = nil
    if projectile and projectile.Parent then
        for _, name in ipairs({"SlimekrewTrailStart", "SlimekrewTrailEnd"}) do
            local attachment = projectile:FindFirstChild(name)
            if attachment then pcall(function() attachment:Destroy() end) end
        end
    end
end

local function addshelltrail(projectile)
    if not settings.shelltrail or shelltrails[projectile] or not projectile:IsA("BasePart") then return end
    if not collectionservice:HasTag(projectile, "own") then return end

    local start = Instance.new("Attachment")
    start.Name = "SlimekrewTrailStart"
    start.Position = Vector3.new(-math.max(projectile.Size.X, projectile.Size.Y) * 0.35, 0, projectile.Size.Z * 0.5)
    start.Parent = projectile

    local finish = Instance.new("Attachment")
    finish.Name = "SlimekrewTrailEnd"
    finish.Position = Vector3.new(math.max(projectile.Size.X, projectile.Size.Y) * 0.35, 0, projectile.Size.Z * 0.5)
    finish.Parent = projectile

    local trail = Instance.new("Trail")
    trail.Name = "SlimekrewShellTrail"
    trail.Attachment0 = start
    trail.Attachment1 = finish
    trail.Color = ColorSequence.new(settings.shelltrailcolor)
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Lifetime = 0.35
    trail.MinLength = 0.05
    trail.FaceCamera = true
    trail.LightEmission = 1
    trail.Parent = projectile
    shelltrails[projectile] = trail
end

local function watchprojectile(projectile)
    task.spawn(function()
        for _ = 1, 20 do
            if not projectile.Parent or library.Unloaded then return end
            if collectionservice:HasTag(projectile, "own") then
                addshelltrail(projectile)
                return
            end
            task.wait(0.05)
        end
    end)
end

local function updateshelltrails()
    for projectile, trail in pairs(shelltrails) do
        if not settings.shelltrail or not projectile.Parent or not trail.Parent then
            removeshelltrail(projectile)
        else
            trail.Color = ColorSequence.new(settings.shelltrailcolor)
        end
    end
    if settings.shelltrail then
        local folder = workspace:FindFirstChild("Projectiles")
        if folder then
            for _, projectile in ipairs(folder:GetChildren()) do addshelltrail(projectile) end
        end
    end
end

local function removevehicle(vehicle)
    local data = vehicles[vehicle]
    if not data then return end
    pcall(function() data.highlight:Destroy() end)
    pcall(function() data.billboard:Destroy() end)
    pcall(function() data.distancebillboard:Destroy() end)
    if data.box then pcall(function() data.box:Remove() end) end
    vehicles[vehicle] = nil
end

local function addvehicle(vehicle)
    if vehicles[vehicle] or not isvehicle(vehicle) then return end
    local part = vehiclepart(vehicle)
    if not part then return end

    for _, object in ipairs(vehicle:GetDescendants()) do
        if object.Name == "SlimekrewVehicleESP" or object.Name == "SlimekrewVehicleLabel" or object.Name == "SlimekrewVehicleDistance" then
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
    billboard.Size = UDim2.fromOffset(1, 1)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.fromScale(0.5, 0.5)
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextTransparency = 1
    label.TextStrokeTransparency = 1
    label.TextColor3 = settings.espvisiblecolor
    label.Parent = billboard

    label.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
    label.BackgroundTransparency = 1

    local labelpadding = Instance.new("UIPadding")
    labelpadding.PaddingLeft = UDim.new(0, 6)
    labelpadding.PaddingRight = UDim.new(0, 6)
    labelpadding.PaddingTop = UDim.new(0, 2)
    labelpadding.PaddingBottom = UDim.new(0, 2)
    labelpadding.Parent = label

    local distancebillboard = Instance.new("BillboardGui")
    distancebillboard.Name = "SlimekrewVehicleDistance"
    distancebillboard.Adornee = part
    distancebillboard.AlwaysOnTop = true
    distancebillboard.Enabled = false
    distancebillboard.Size = UDim2.fromOffset(1, 1)
    distancebillboard.StudsOffset = Vector3.new(0, 2.25, 0)
    distancebillboard.Parent = part

    local distancelabel = Instance.new("TextLabel")
    distancelabel.AnchorPoint = Vector2.new(0.5, 0.5)
    distancelabel.Position = UDim2.fromScale(0.5, 0.5)
    distancelabel.AutomaticSize = Enum.AutomaticSize.XY
    distancelabel.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
    distancelabel.BackgroundTransparency = 1
    distancelabel.Size = UDim2.fromScale(1, 1)
    distancelabel.Font = Enum.Font.Code
    distancelabel.TextSize = 12
    distancelabel.TextTransparency = 1
    distancelabel.TextStrokeTransparency = 1
    distancelabel.TextColor3 = settings.espvisiblecolor
    distancelabel.Parent = distancebillboard

    local distancepadding = Instance.new("UIPadding")
    distancepadding.PaddingLeft = UDim.new(0, 6)
    distancepadding.PaddingRight = UDim.new(0, 6)
    distancepadding.PaddingTop = UDim.new(0, 2)
    distancepadding.PaddingBottom = UDim.new(0, 2)
    distancepadding.Parent = distancelabel

    local box
    if type(Drawing) == "table" or type(Drawing) == "userdata" then
        pcall(function()
            box = Drawing.new("Square")
            box.Filled = false
            box.Thickness = 1
            box.Transparency = 1
            box.Visible = false
        end)
    end

    vehicles[vehicle] = {
        part = part,
        highlight = highlight,
        billboard = billboard,
        label = label,
        distancebillboard = distancebillboard,
        distancelabel = distancelabel,
        box = box,
        alpha = 0,
        velocity = part.AssemblyLinearVelocity,
        acceleration = Vector3.zero,
        motionclock = os.clock(),
    }
end

local function displayenabled(name)
    return settings.vehicledisplays[name] == true
end

local function screenbounds(part)
    local pivot, size = part.CFrame, part.Size
    local half = size * 0.5
    local minimum = Vector2.new(math.huge, math.huge)
    local maximum = Vector2.new(-math.huge, -math.huge)
    local visible = false
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local world = pivot:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
                local point = camera:WorldToViewportPoint(world)
                if point.Z > 0 then
                    visible = true
                    minimum = Vector2.new(math.min(minimum.X, point.X), math.min(minimum.Y, point.Y))
                    maximum = Vector2.new(math.max(maximum.X, point.X), math.max(maximum.Y, point.Y))
                end
            end
        end
    end
    if not visible then return end
    return minimum, maximum
end

local function scanvehicles()
    local folder = workspace:FindFirstChild("Vehicles")
    if folder then
        for _, vehicle in ipairs(folder:GetChildren()) do addvehicle(vehicle) end
    end
    for vehicle in pairs(vehicles) do
        if not vehicle.Parent then removevehicle(vehicle) end
    end
end

local function clearvehicleesp()
    local cached = {}
    for vehicle in pairs(vehicles) do table.insert(cached, vehicle) end
    for _, vehicle in ipairs(cached) do removevehicle(vehicle) end
    local folder = workspace:FindFirstChild("Vehicles")
    if folder then
        for _, object in ipairs(folder:GetDescendants()) do
            if object.Name == "SlimekrewVehicleESP" or object.Name == "SlimekrewVehicleLabel" or object.Name == "SlimekrewVehicleDistance" then
                pcall(function() object:Destroy() end)
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
            local isvisible = not settings.espvisiblecheck or rayvisible(data.part, vehicle)
            local shown = settings.vehicleesp and distance <= settings.renderdistance and (not settings.espteamcheck or not teammate)
            local now = os.clock()
            local motiondelta = now - data.motionclock
            if motiondelta >= 0.05 then
                local velocity = data.part.AssemblyLinearVelocity
                local acceleration = (velocity - data.velocity) / motiondelta
                if acceleration.Magnitude > 250 then acceleration = acceleration.Unit * 250 end
                data.acceleration = data.acceleration:Lerp(acceleration, math.clamp(motiondelta * 8, 0, 1))
                data.velocity = velocity
                data.motionclock = now
            end
            data.alpha += ((shown and 1 or 0) - data.alpha) * speed
            if math.abs(data.alpha - (shown and 1 or 0)) < 0.01 then data.alpha = shown and 1 or 0 end

            local espcolor = settings.espvisiblecheck and (isvisible and settings.espvisiblecolor or settings.espblockedcolor) or settings.espvisiblecolor
            local highlightcolor = espcolor
            data.label.Text = tostring(ownername(vehicle) or vehicle.Name)
            data.label.TextColor3 = espcolor
            data.label.TextTransparency = 1 - data.alpha
            data.label.TextStrokeTransparency = 1 - data.alpha * 0.65
            data.label.BackgroundTransparency = 1 - data.alpha * 0.5
            data.billboard.Enabled = data.alpha > 0.01 and displayenabled("Name")
            data.distancelabel.Text = math.floor(distance + 0.5) .. "m"
            data.distancelabel.TextColor3 = espcolor
            data.distancelabel.TextTransparency = 1 - data.alpha
            data.distancelabel.TextStrokeTransparency = 1 - data.alpha * 0.65
            data.distancelabel.BackgroundTransparency = 1 - data.alpha * 0.5
            data.distancebillboard.Enabled = data.alpha > 0.01 and displayenabled("Distance")
            data.highlight.Enabled = data.alpha > 0.01 and displayenabled("Highlight")
            data.highlight.FillColor = highlightcolor
            data.highlight.OutlineColor = highlightcolor
            data.highlight.FillTransparency = 1 - data.alpha * 0.18
            data.highlight.OutlineTransparency = 1 - data.alpha
            if data.box then
                if data.alpha > 0.01 and displayenabled("Box") then
                    local minimum, maximum = screenbounds(data.part)
                    data.box.Visible = minimum ~= nil
                    if data.box.Visible then
                        data.box.Position = minimum
                        data.box.Size = maximum - minimum
                        data.box.Color = highlightcolor
                        data.box.Transparency = data.alpha
                    end
                else
                    data.box.Visible = false
                end
            end
        end
    end
end

local function partdestroyed(part, vehicle)
    if vehicle:GetAttribute("Dead") == true then return true end
    local object = part
    while object and object ~= vehicle do
        local health = object:GetAttribute("Health")
        if type(health) == "number" and health <= 0 then return true end
        local assigned = object:FindFirstChild("AssignedTo")
        local component = assigned and assigned:IsA("ObjectValue") and assigned.Value
        local componenthealth = component and component:GetAttribute("Health")
        if type(componenthealth) == "number" and componenthealth <= 0 then return true end
        object = object.Parent
    end
    return false
end

local hitpartnames = {"Center", "Engine", "Ammo", "Turret"}

local function targetparts(vehicle)
    local parts = {}
    local added = {}
    if not vehicle then return parts end

    local function add(part)
        if part and part:IsA("BasePart") and not added[part] and not partdestroyed(part, vehicle) then
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
    if not part or typeof(origin) ~= "Vector3" or type(speed) ~= "number" or speed <= 0 then return end

    local offset = part.Position - origin
    local ownvelocity = typeof(shootervelocity) == "Vector3" and shootervelocity or Vector3.zero
    local relativevelocity = part.AssemblyLinearVelocity - ownvelocity
    local acceleration = currenttargetacceleration
    local drop = type(gravity) == "number" and math.abs(gravity) or 0
    local totalacceleration = acceleration + Vector3.new(0, drop, 0)

    local function displacement(time)
        return offset + relativevelocity * time + totalacceleration * time * time * 0.5
    end

    local function errorat(time)
        return displacement(time).Magnitude - speed * time
    end

    local directtime = offset.Magnitude / speed
    local maxtime = math.clamp(directtime * 4 + 2, 2, 30)
    local steps = 48 + settings.refinement * 16
    local previous = 0
    local previouserror = errorat(previous)
    local low
    local high
    for index = 1, steps do
        local time = maxtime * index / steps
        local currenterror = errorat(time)
        if previouserror >= 0 and currenterror <= 0 then
            low = previous
            high = time
            break
        end
        previous = time
        previouserror = currenterror
    end

    if not low then
        predictedpoint = nil
        return
    end

    for _ = 1, 5 + settings.refinement * 3 do
        local middle = (low + high) * 0.5
        if errorat(middle) > 0 then
            low = middle
        else
            high = middle
        end
    end

    local time = (low + high) * 0.5
    local aimoffset = displacement(time)
    predictedpoint = part.Position + part.AssemblyLinearVelocity * time + acceleration * time * time * 0.5
    return aimoffset.Magnitude > 0 and aimoffset.Unit or nil
end

local function scangunstates()
    table.clear(gunstates)
    if type(getgc) ~= "function" then return end
    local success, objects = pcall(getgc, true)
    if not success or type(objects) ~= "table" then return end
    for _, object in ipairs(objects) do
        if type(object) == "table" and type(rawget(object, "gunCaliber")) == "number" then
            if rawget(object, "ReloadTime") ~= nil or type(rawget(object, "overheatGuns")) == "table" then
                table.insert(gunstates, object)
            end
        end
    end
end

local function updategunmods(delta)
    if not settings.reload and not settings.nooverheat then return end
    if os.clock() - lastgunscan >= 1 then
        lastgunscan = os.clock()
        scangunstates()
    end
    for index = #gunstates, 1, -1 do
        local state = gunstates[index]
        if type(state) ~= "table" then
            table.remove(gunstates, index)
        else
            if settings.reload and type(rawget(state, "reloading")) == "number" and state.reloading > 0 then
                state.reloading = math.max(state.reloading - delta * (settings.reloadmult - 1), 0)
            end
            if settings.nooverheat then
                if type(rawget(state, "heatRot")) == "number" then state.heatRot = 0 end
                if rawget(state, "overHeated") ~= nil then state.overHeated = false end
                local guns = rawget(state, "overheatGuns")
                if type(guns) == "table" then
                    for _, heat in pairs(guns) do
                        if type(heat) == "table" then
                            heat[1] = 0
                            heat[2] = false
                        end
                    end
                end
            end
        end
    end
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
        local gunbrick = arguments[12]
        if settings.nospread and typeof(gunbrick) == "Instance" and gunbrick:IsA("BasePart") then
            arguments[2] = gunbrick.CFrame.LookVector
        end
        if settings.silentaim and currenttarget and currenttarget.Parent then
            local direction = predictdirection(arguments[4], arguments[3], arguments[6], arguments[7])
            if direction then arguments[2] = direction end
            local chassis = arguments[1]
            local origin = arguments[4]
            if typeof(chassis) == "Instance" and chassis:IsA("Model") and typeof(origin) == "Vector3" then
                trajectorycache = {
                    chassis = chassis,
                    localorigin = chassis:GetPivot():PointToObjectSpace(origin),
                    speed = arguments[3],
                    gravity = arguments[6],
                }
            end
        end
        local results = table.pack(pcall(oldtrajectory, table.unpack(arguments)))
        if not results[1] then error(results[2], 0) end
        return table.unpack(results, 2, results.n)
    end
    oldtrajectory = hookfunction(result.Trajectory, replacement)
end

local function makedrawings()
    if type(Drawing) ~= "table" and type(Drawing) ~= "userdata" then return end
    local success = pcall(function()
        fovcircle = Drawing.new("Circle")
        fovcircle.Filled = false
        fovcircle.Thickness = 1
        fovcircle.NumSides = 80
        fovcircle.Transparency = 0.7

        snapline = Drawing.new("Line")
        snapline.Thickness = 1
        snapline.Transparency = 0.85

        predictioncircle = Drawing.new("Circle")
        predictioncircle.Filled = false
        predictioncircle.Thickness = 2
        predictioncircle.NumSides = 24
        predictioncircle.Radius = 6
        predictioncircle.Transparency = 0.9
        predictioncircle.Visible = false

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
    end)
    if not success then
        for _, drawing in ipairs({fovcircle, snapline, predictioncircle, targetbox}) do pcall(function() drawing:Remove() end) end
        for _, text in ipairs(targettexts) do pcall(function() text:Remove() end) end
        for _, line in ipairs(targetlines) do pcall(function() line:Remove() end) end
        fovcircle = nil
        snapline = nil
        predictioncircle = nil
        targetbox = nil
        table.clear(targettexts)
        table.clear(targetlines)
    end
end

local function findtarget()
    if not settings.fov and not settings.silentaim then return end
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
    gradientclock += delta
    local viewport = camera.ViewportSize
    local center = userinputservice:GetMouseLocation()

    currenttarget, currenttargetpart = findtarget()
    local targetdata = currenttarget and vehicles[currenttarget]
    currenttargetacceleration = targetdata and targetdata.acceleration or Vector3.zero
    predictedpoint = nil
    if currenttargetpart and trajectorycache and trajectorycache.chassis.Parent then
        local chassis = trajectorycache.chassis
        local origin = chassis:GetPivot():PointToWorldSpace(trajectorycache.localorigin)
        local hullnode = chassis:FindFirstChild("HullNode")
        local velocity = hullnode and hullnode.AssemblyLinearVelocity or Vector3.zero
        predictdirection(origin, trajectorycache.speed, trajectorycache.gravity, velocity)
    end
    if not fovcircle or not snapline or not targetbox then return end
    fovcircle.Position = center
    fovcircle.Radius = settings.fovsize
    local fovdrawcolor = settings.fovcolor
    if settings.fovgradient then
        local hue, saturation, value = settings.fovcolor:ToHSV()
        local finish = Color3.fromHSV((hue + 0.18) % 1, math.max(saturation, 0.55), value)
        fovdrawcolor = settings.fovcolor:Lerp(finish, (math.sin(gradientclock * 2.4) + 1) * 0.5)
    end
    fovcircle.Color = fovdrawcolor
    fovcircle.Visible = settings.fov
    if predictioncircle then
        local markerpoint, markervisible
        if predictedpoint then markerpoint, markervisible = camera:WorldToViewportPoint(predictedpoint) end
        predictioncircle.Visible = settings.predictionmarker and settings.silentaim and predictedpoint ~= nil and markervisible and markerpoint.Z > 0 or false
        if predictioncircle.Visible then
            predictioncircle.Position = Vector2.new(markerpoint.X, markerpoint.Y)
            predictioncircle.Color = fovdrawcolor
        end
    end
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
        snapline.Color = fovdrawcolor
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
        local first = settings.fovcolor:Lerp(settings.espvisiblecolor, phase)
        local second = settings.espvisiblecolor:Lerp(settings.fovcolor, phase)
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
local modificationsbox = tabs.main:AddRightTabbox("Modifications")
local modifications = modificationsbox:AddTab("Weapon")
local fovtoggle
silentaim:AddToggle("SilentAim", {Text = "Silent Aim", Callback = function(value)
    settings.silentaim = value
    if value then
        hooksilentaim()
        if fovtoggle and not settings.fov then fovtoggle:SetValue(true) end
    end
end})
silentaim:AddToggle("SilentVisibleCheck", {Text = "Visible Check", Callback = function(value) settings.silentvisiblecheck = value end})
silentaim:AddToggle("PredictionMarker", {Text = "Prediction Marker", Callback = function(value) settings.predictionmarker = value end})
silentaim:AddToggle("TargetHUD", {Text = "Target HUD", Callback = function(value) settings.targethud = value end})
silentaim:AddToggle("ShellTrail", {Text = "Shell Trail", Callback = function(value)
    settings.shelltrail = value
    updateshelltrails()
end}):AddColorPicker("ShellTrailColor", {Default = settings.shelltrailcolor, Title = "Shell Trail", Callback = function(value)
    settings.shelltrailcolor = value
    updateshelltrails()
end})
silentaim:AddSlider("TrajectoryRefinement", {Text = "Trajectory Refinement", Min = 1, Max = 6, Default = 3, Rounding = 0, Tooltip = "Higher values spend more work refining acceleration, lead, and projectile drop.", Callback = function(value) settings.refinement = value end})
silentaim:AddMultiDropdown("SilentHitParts", {Text = "Hit Parts", Values = hitpartnames, Default = {"Center"}, Callback = function(value) settings.hitparts = value end})
modifications:AddToggle("NoSpread", {Text = "No Spread", Callback = function(value) settings.nospread = value; if value then hooksilentaim() end end})
modifications:AddToggle("ReloadMultiplier", {Text = "Reload Multiplier", Tooltip = "Accelerates the primary client reload timer.", Callback = function(value) settings.reload = value end})
    :AddSlider("ReloadMultiplierValue", {Text = "Multiplier", Min = 1, Max = 10, Default = 2, Rounding = 1, Suffix = "x", Callback = function(value) settings.reloadmult = value end})
modifications:AddToggle("NoOverheat", {Text = "No Overheat", Callback = function(value) settings.nooverheat = value end})
fovtoggle = targeting:AddToggle("TargetFOV", {Text = "FOV", Callback = function(value) settings.fov = value end})
targeting:AddSlider("TargetFOVSize", {Text = "FOV Size", Min = 25, Max = 600, Default = 180, Rounding = 0, Callback = function(value) settings.fovsize = value end})
targeting:AddLabel("FOV Color"):AddColorPicker("TargetFOVColor", {
    Default = settings.fovcolor,
    Title = "FOV Color",
    Gradient = {
        Index = "TargetFOVColorGradient",
        Text = "Animated Gradient",
        Default = false,
        Callback = function(value) settings.fovgradient = value end,
    },
    Callback = function(value) settings.fovcolor = value end,
})
targeting:AddToggle("TargetSnaplines", {Text = "Snaplines", Callback = function(value) settings.snaplines = value end})

local visualsbox = tabs.visuals:AddLeftTabbox("Vehicle Visuals")
local visuals = visualsbox:AddTab("Visuals")
visuals:AddToggle("VehicleESP", {Text = "Vehicle Visuals", Callback = function(value) settings.vehicleesp = value end})
visuals:AddMultiDropdown("VehicleDisplays", {Text = "Displays", Values = {"Highlight", "Name", "Box", "Distance"}, Default = {"Highlight", "Name", "Distance"}, Callback = function(value) settings.vehicledisplays = value end})
visuals:AddToggle("VehicleESPTeamCheck", {Text = "Team Check", Callback = function(value) settings.espteamcheck = value end})
visuals:AddToggle("VehicleESPVisibleCheck", {Text = "Visible Check", Callback = function(value) settings.espvisiblecheck = value end})
visuals:AddSlider("VehicleESPDistance", {Text = "Render Distance", Min = 100, Max = 10000, Default = 3000, Rounding = 0, Suffix = "m", Callback = function(value) settings.renderdistance = value end})
visuals:AddLabel("ESP Color")
    :AddColorPicker("VehicleESPVisibleColor", {Default = settings.espvisiblecolor, Title = "Visible ESP", Callback = function(value) settings.espvisiblecolor = value end})
    :AddColorPicker("VehicleESPBlockedColor", {Default = settings.espblockedcolor, Title = "Not Visible ESP", Callback = function(value) settings.espblockedcolor = value end})

local utilitybox = tabs.misc:AddLeftTabbox("Utility")
local utility = utilitybox:AddTab("Mouse")
utility:AddToggle("UnlockMouse", {Text = "Unlock Mouse", Callback = function(value)
    setmouseunlock(value)
end})

watermark = library:AddDraggableLabel({Text = "cursed tank | 0 fps | 0ms", Icon = avatar, IconPosition = "left"})
watermark:SetVisible(false)

local projectiles = workspace:FindFirstChild("Projectiles")
if projectiles then
    connect(projectiles.ChildAdded, watchprojectile)
    connect(projectiles.ChildRemoved, removeshelltrail)
end

--// runtime

connect(runservice.RenderStepped, function(delta)
    camera = workspace.CurrentCamera or camera
    fpsframes += 1
    fpstime += delta
    updatevehicles(delta)
    updatetargeting(delta)
    if fpstime >= 0.5 then
        local fps = math.floor(fpsframes / fpstime + 0.5)
        local ping = 0
        pcall(function() ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
        watermark:SetText("cursed tank | " .. fps .. " fps | " .. ping .. "ms")
        fpsframes = 0
        fpstime = 0
    end
end)

connect(runservice.Heartbeat, function(delta)
    updategunmods(delta)
    if os.clock() - lastscan >= 0.5 then
        lastscan = os.clock()
        scanvehicles()
    end
end)

--// cleanup

library:OnUnload(function()
    settings.unlockmouse = false
    pcall(runservice.UnbindFromRenderStep, runservice, mousebinding)
    pcall(runservice.UnbindFromRenderStep, runservice, mouseearlybinding)
    if mousemodal then mousemodal.Modal = false; mousemodal:Destroy() end
    for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
    clearvehicleesp()
    settings.shelltrail = false
    updateshelltrails()
    userinputservice.MouseBehavior = originalmousebehavior
    userinputservice.MouseIconEnabled = originalmouseicon
    pcall(function() localplayer.CameraMode = originalcameramode end)
    pcall(function() starterplayer.EnableMouseLockOption = originalmouselockoption end)
    if originalmouseoverride then pcall(function() userinputservice.OverrideMouseIconBehavior = originalmouseoverride end) end
    if oldtrajectory and trajectorymodule and type(hookfunction) == "function" then
        pcall(function() hookfunction(trajectorymodule.Trajectory, oldtrajectory) end)
    end
    for _, drawing in ipairs({fovcircle, snapline, predictioncircle, targetbox}) do pcall(function() drawing:Remove() end) end
    for _, text in ipairs(targettexts) do pcall(function() text:Remove() end) end
    for _, line in ipairs(targetlines) do pcall(function() line:Remove() end) end
    if env.slimekrewcursedtank == library then env.slimekrewcursedtank = nil end
end)

env.slimekrewcursedtank = library
