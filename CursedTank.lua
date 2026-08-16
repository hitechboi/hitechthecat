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
local runtimeclock = {vehicle = 0, gun = 0, repair = 0}
local watermark
local fovcircle
local snapline
local predictioncircle
local targetbox
local targettexts = {}
local targetlines = {}
local targetframe
local targetstrokegradient
local targetrailgradient
local targetscale
local targetguitexts = {}
local targettextgradients = {}
local currenttarget
local currenttargetpart
local currenttargetoffset = Vector3.zero
local currenttargetacceleration = Vector3.zero
local currentaccelerationconfidence = 0
local predictedpoint
local trajectorycache
local gunstates = {}
local lastgunscan = 0
local shakeoriginals = setmetatable({}, {__mode = "k"})
local creworiginals = setmetatable({}, {__mode = "k"})
local repairhooks = {}
local hudtarget
local hudtargetpart
local hudtargetoffset = Vector3.zero
local oldtrajectory
local trajectorymodule
local oldnamecall
local trajectoryscript
local trajectorythreads = setmetatable({}, {__mode = "k"})
local runtrajectory
local targetalpha = 0
local gradientclock = 0
local solverstatus = "idle"
local solvertime
local solverdistance
local solverrange
local solverdropscale
local solverquality
local solverconfidence
local solvertarget
local solverpart
local solverlatency
local solverjitter = 0
local latencyvalue = 0
local latencyclock = 0
local latencysuccessclock = 0
local lastvisualsolve = 0
local visualtarget
local visualpart
local visualoffset = Vector3.zero
local gunstatus = "not scanned"
local gundiscovery = "none"
local ammovolleys = 0
local reservecorrections = 0
local clipcorrections = 0
local lastammovolley
local ammosyncerror
local lasttargetchange = 0
local recoiloriginals = setmetatable({}, {__mode = "k"})
local ammooriginals = setmetatable({}, {__mode = "k"})
local cliporiginals = setmetatable({}, {__mode = "k"})
local volleyoriginals = setmetatable({}, {__mode = "k"})
local ammowatchers = setmetatable({}, {__mode = "k"})
local mainammooriginal
local mainammoowner
local mainammotable
local updatevolleyhooks
local refreshammowatchers
local findtarget
local originalmousebehavior = userinputservice.MouseBehavior
local originalmouseicon = userinputservice.MouseIconEnabled
local originalmouseoverride
local mousebindname = "slimekrewcursedtankmouse"
local mouselooking = false
local vehicleoriginals = setmetatable({}, {__mode = "k"})
local cachedvehiclephysics
local lastvehiclephysicsscan = 0
local lastrepairattempt = 0
pcall(function() originalmouseoverride = userinputservice.OverrideMouseIconBehavior end)
local settings = {
    vehicleesp = false,
    vehicledisplays = {Highlight = true, Name = true, Distance = true, ["Text Background"] = true},
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
    snaplinecolor = Color3.fromRGB(235, 235, 240),
    targethud = false,
    silentaim = false,
    silentvisiblecheck = false,
    targethysteresis = true,
    targetlock = false,
    predictionmarker = false,
    predictionstrength = 0.8,
    predictiondiagnostics = false,
    predictioncolor = Color3.fromRGB(80, 220, 255),
    predictionradius = 5,
    shelltrail = false,
    shelltrailcolor = Color3.fromRGB(255, 60, 60),
    shelltraillifetime = 0.35,
    shelltrailwidth = 0.9,
    shelltrailtransparency = 0.05,
    damagereticles = false,
    impactmarker = false,
    advancedhud = false,
    nosmoke = false,
    refinement = 5,
    adaptiverefinement = true,
    accelerationprediction = true,
    angularprediction = true,
    groundstabilization = true,
    latencyprediction = true,
    nospread = false,
    multiprojectiles = false,
    projectilecount = 2,
    terrainpenetration = false,
    componentpassthrough = false,
    homingshells = false,
    mainammo = false,
    mainclip = false,
    secondaryammo = false,
    reload = false,
    reloadmult = 2,
    noreload = false,
    rapidfire = false,
    rapidfirerate = 10,
    norecoil = false,
    nooverheat = false,
    nocamerashake = false,
    norecoilzoom = false,
    repairmovement = false,
    autorepair = false,
    fastrepair = false,
    hitparts = {Ammo = true, Engine = true, Crew = true},
    targetpriority = "Screen",
    targetfallback = true,
    crewcondition = false,
    unlockmouse = false,
    espinterval = 0.08,
    vehiclespeed = false,
    vehiclespeedmult = 1,
    vehicleacceleration = false,
    vehicleaccelerationmult = 1,
    vehiclereverse = false,
    vehiclereversemult = 1,
    vehiclebrake = false,
    vehiclebrakemult = 1,
    vehiclesteering = false,
    vehiclesteeringmult = 1,
    vehiclegrip = false,
    vehiclegripmult = 1,
    vehicledrag = false,
    vehicledragmult = 1,
    vehiclefly = false,
    vehicleflyspeed = 100,
    vehicleflyverticalspeed = 65,
    vehicleflyacceleration = 5,
    vehicleflyhover = true,
}

pcall(function()
    avatar = players:GetUserThumbnailAsync(localplayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)

--[[
Final Rule
If you find yourself making an assumption, stop and ask for clarification rather than guessing.
]]

--// funcs

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function finitenumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function finitevector(value)
    return typeof(value) == "Vector3" and finitenumber(value.X) and finitenumber(value.Y) and finitenumber(value.Z)
end

local function wraptext(value, limit)
    local lines = {}
    local current = ""
    for word in tostring(value):gmatch("%S+") do
        while #word > limit do
            if #current > 0 then
                table.insert(lines, current)
                current = ""
            end
            table.insert(lines, word:sub(1, limit))
            word = word:sub(limit + 1)
        end
        if #current == 0 then
            current = word
        elseif #current + #word + 1 <= limit then
            current ..= " " .. word
        else
            table.insert(lines, current)
            current = word
        end
    end
    if #current > 0 then table.insert(lines, current) end
    return table.concat(lines, "\n"), math.max(#lines, 1)
end

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

runtimeclock.vehiclefrompart = function(part)
    local folder = workspace:FindFirstChild("Vehicles")
    local object = part
    while object and object.Parent and object.Parent ~= folder do object = object.Parent end
    return folder and object and object.Parent == folder and object or nil
end

local function rayvisiblefrom(origin, part, vehicle, point, ignored)
    if not part or not part.Parent then return false end
    local destination = typeof(point) == "Vector3" and point or part.Position
    local direction = destination - origin
    if direction.Magnitude <= 0.01 then return true end

    local parameters = RaycastParams.new()
    parameters.FilterType = Enum.RaycastFilterType.Exclude
    local excluded = localplayer.Character and {localplayer.Character} or {}
    if typeof(ignored) == "Instance" then table.insert(excluded, ignored) end
    parameters.FilterDescendantsInstances = excluded
    parameters.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, parameters)
    return not result or result.Instance:IsDescendantOf(vehicle)
end

local function rayvisible(part, vehicle)
    return rayvisiblefrom(camera.CFrame.Position, part, vehicle)
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
    if settings.multiprojectiles then
        local active = 0
        for current, trail in pairs(shelltrails) do
            if current.Parent and trail.Parent then active += 1 end
        end
        if active >= 8 then return end
    end

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
        NumberSequenceKeypoint.new(0, settings.shelltrailtransparency),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Lifetime = settings.shelltraillifetime
    trail.WidthScale = NumberSequence.new(settings.shelltrailwidth)
    trail.MinLength = 0.05
    trail.FaceCamera = true
    trail.LightEmission = 1
    trail.Parent = projectile
    shelltrails[projectile] = trail
end

local function watchprojectile(projectile)
    if not settings.shelltrail then return end
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
            trail.Lifetime = settings.shelltraillifetime
            trail.WidthScale = NumberSequence.new(settings.shelltrailwidth)
            trail.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, settings.shelltrailtransparency),
                NumberSequenceKeypoint.new(1, 1),
            })
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
    vehicles[vehicle] = nil
    local reusable = pcall(function()
        data.highlight.Enabled = false
        data.highlight.Adornee = nil
        data.highlight.Parent = nil
        data.billboard.Enabled = false
        data.billboard.Adornee = nil
        data.billboard.Parent = nil
        data.distancebillboard.Enabled = false
        data.distancebillboard.Adornee = nil
        data.distancebillboard.Parent = nil
        data.label.Text = ""
        data.distancelabel.Text = ""
        if data.box then data.box.Visible = false end
    end)
    runtimeclock.vehicleesppool = runtimeclock.vehicleesppool or {}
    if reusable and #runtimeclock.vehicleesppool < 40 and not library.Unloaded then
        table.insert(runtimeclock.vehicleesppool, data)
        return
    end
    pcall(function() data.highlight:Destroy() end)
    pcall(function() data.billboard:Destroy() end)
    pcall(function() data.distancebillboard:Destroy() end)
    if data.box then pcall(function() data.box:Remove() end) end
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

    local pooled = runtimeclock.vehicleesppool and table.remove(runtimeclock.vehicleesppool)
    if pooled then
        pooled.part = part
        pooled.alpha = 0
        pooled.velocity = part.AssemblyLinearVelocity
        pooled.rawvelocity = part.AssemblyLinearVelocity
        pooled.acceleration = Vector3.zero
        pooled.rawacceleration = Vector3.zero
        pooled.accelerationconfidence = 0
        pooled.motionclock = os.clock()
        pooled.targetparts = nil
        pooled.nextpartscan = 0
        pooled.espclock = 0
        pooled.espcolor = settings.espvisiblecolor
        pooled.visible = true
        pooled.rendered = false
        pooled.displayname = nil
        pooled.nextnamescan = 0
        pooled.hudmodules = nil
        pooled.nexthudmodulescan = 0
        pooled.highlight.Adornee = vehicle
        pooled.highlight.FillTransparency = 1
        pooled.highlight.OutlineTransparency = 1
        pooled.highlight.Enabled = false
        pooled.highlight.Parent = vehicle
        pooled.billboard.Adornee = part
        pooled.billboard.Enabled = false
        pooled.billboard.Parent = part
        pooled.distancebillboard.Adornee = part
        pooled.distancebillboard.Enabled = false
        pooled.distancebillboard.Parent = part
        pooled.label.Text = ""
        pooled.label.TextTransparency = 1
        pooled.label.BackgroundTransparency = 1
        pooled.distancelabel.Text = ""
        pooled.distancelabel.TextTransparency = 1
        pooled.distancelabel.BackgroundTransparency = 1
        if pooled.box then pooled.box.Visible = false; pooled.box.Transparency = 1 end
        vehicles[vehicle] = pooled
        return
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
    billboard.Size = UDim2.fromOffset(220, 42)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.fromScale(0.5, 0.5)
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.Size = UDim2.fromOffset(0, 0)
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
    distancebillboard.StudsOffset = Vector3.new(0, -5.5, 0)
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
        rawvelocity = part.AssemblyLinearVelocity,
        acceleration = Vector3.zero,
        rawacceleration = Vector3.zero,
        accelerationconfidence = 0,
        motionclock = os.clock(),
        targetparts = nil,
        nextpartscan = 0,
        espclock = 0,
        espcolor = settings.espvisiblecolor,
        visible = true,
    }
end

local function displayenabled(name)
    return settings.vehicledisplays[name] == true
end

local function screenbounds(object)
    local pivot
    local size
    if object:IsA("Model") then
        pivot, size = object:GetBoundingBox()
    elseif object:IsA("BasePart") then
        pivot, size = object.CFrame, object.Size
    else
        return
    end
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
    local needtarget = settings.silentaim or settings.homingshells or settings.snaplines or settings.targethud or settings.predictionmarker
    for vehicle, data in pairs(vehicles) do
        if not vehicle.Parent or not data.part.Parent then
            removevehicle(vehicle)
        else
            if not settings.vehicleesp and not needtarget and data.alpha == 0 then
                if data.rendered then
                    data.billboard.Enabled = false
                    data.distancebillboard.Enabled = false
                    data.highlight.Enabled = false
                    if data.box then data.box.Visible = false end
                    data.rendered = false
                end
                continue
            end
            local distance = (camera.CFrame.Position - data.part.Position).Magnitude
            local shown = settings.vehicleesp and distance <= settings.renderdistance
            if shown and settings.espteamcheck then shown = not friendly(vehicle) end
            local now = os.clock()
            local motiondelta = now - data.motionclock
            if motiondelta >= 0.05 then
                local velocity = data.part.AssemblyLinearVelocity
                if finitevector(velocity) and finitevector(data.rawvelocity) and finitevector(data.rawacceleration) then
                    local acceleration = (velocity - data.rawvelocity) / math.max(motiondelta, 1 / 240)
                    if acceleration.Magnitude > 120 then acceleration = acceleration.Unit * 120 end
                    local jerk = (acceleration - data.rawacceleration).Magnitude / math.max(motiondelta, 1 / 240)
                    local sampleconfidence = math.clamp(1 - jerk / 800, 0, 1)
                    data.velocity = finitevector(data.velocity) and data.velocity:Lerp(velocity, math.clamp(motiondelta * 10, 0, 1)) or velocity
                    data.acceleration = finitevector(data.acceleration) and data.acceleration:Lerp(acceleration, math.clamp(motiondelta * 5, 0, 1)) or acceleration
                    data.accelerationconfidence += (sampleconfidence - data.accelerationconfidence) * math.clamp(motiondelta * 4, 0, 1)
                    data.rawvelocity = velocity
                    data.rawacceleration = acceleration
                else
                    data.velocity = finitevector(velocity) and velocity or Vector3.zero
                    data.rawvelocity = data.velocity
                    data.acceleration = Vector3.zero
                    data.rawacceleration = Vector3.zero
                    data.accelerationconfidence = 0
                end
                data.motionclock = now
            end
            data.alpha += ((shown and 1 or 0) - data.alpha) * speed
            if math.abs(data.alpha - (shown and 1 or 0)) < 0.01 then data.alpha = shown and 1 or 0 end

            data.espclock += delta
            if data.espclock >= settings.espinterval then
                data.espclock = 0
                if shown and settings.espvisiblecheck then data.visible = rayvisible(data.part, vehicle) else data.visible = true end
            end

            local targetcolor = settings.espvisiblecheck and (data.visible and settings.espvisiblecolor or settings.espblockedcolor) or settings.espvisiblecolor
            data.espcolor = data.espcolor:Lerp(targetcolor, math.clamp(delta * 8, 0, 1))
            local espcolor = data.espcolor
            local highlightcolor = espcolor
            if data.alpha == 0 and not shown then
                if data.rendered then
                    data.billboard.Enabled = false
                    data.distancebillboard.Enabled = false
                    data.highlight.Enabled = false
                    if data.box then data.box.Visible = false end
                    data.rendered = false
                end
                continue
            end
            data.rendered = true
            if not data.displayname or now >= (data.nextnamescan or 0) then
                data.displayname = tostring(ownername(vehicle) or vehicle.Name)
                data.nextnamescan = now + 1
            end
            local lines = {}
            if displayenabled("Name") then table.insert(lines, data.displayname) end
            if displayenabled("Distance") then table.insert(lines, math.floor(distance + 0.5) .. "m") end
            data.label.Text = table.concat(lines, "\n")
            data.label.TextColor3 = espcolor
            data.label.TextTransparency = 1 - data.alpha
            data.label.TextStrokeTransparency = 1
            data.label.BackgroundTransparency = displayenabled("Text Background") and 1 - data.alpha * 0.5 or 1
            data.billboard.Enabled = data.alpha > 0.01 and #lines > 0
            data.distancelabel.Text = math.floor(distance + 0.5) .. "m"
            data.distancelabel.TextColor3 = espcolor
            data.distancelabel.TextTransparency = 1 - data.alpha
            data.distancelabel.TextStrokeTransparency = 1
            data.distancelabel.BackgroundTransparency = displayenabled("Text Background") and 1 - data.alpha * 0.5 or 1
            data.distancebillboard.Enabled = false
            data.highlight.Enabled = data.alpha > 0.01 and displayenabled("Highlight")
            data.highlight.FillColor = highlightcolor
            data.highlight.OutlineColor = highlightcolor
            data.highlight.FillTransparency = 1 - data.alpha * 0.18
            data.highlight.OutlineTransparency = 1 - data.alpha
            if data.box then
                if data.alpha > 0.01 and displayenabled("Box") then
                    local hull = vehicle:FindFirstChild("Hull", true) or vehicle:FindFirstChild("HullNode", true) or data.part
                    local minimum, maximum = screenbounds(hull)
                    data.box.Visible = minimum ~= nil
                    if data.box.Visible then
                        data.box.Position = minimum
                        data.box.Size = maximum - minimum
                        data.box.Color = espcolor
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
        if object:GetAttribute("Destroyed") == true or object:GetAttribute("Broken") == true then return true end
        local assigned = object:FindFirstChild("AssignedTo")
        local component = assigned and assigned:IsA("ObjectValue") and assigned.Value
        local componenthealth = component and component:GetAttribute("Health")
        if type(componenthealth) == "number" and componenthealth <= 0 then return true end
        if component and (component:GetAttribute("Destroyed") == true or component:GetAttribute("Broken") == true) then return true end
        object = object.Parent
    end
    return false
end

local function copyraycastparams(source)
    local params = RaycastParams.new()
    if typeof(source) ~= "RaycastParams" then return params end
    for _, property in ipairs({"CollisionGroup", "FilterType", "IgnoreWater", "RespectCanCollide", "BruteForceAllSlow"}) do
        pcall(function() params[property] = source[property] end)
    end
    params.FilterDescendantsInstances = source.FilterDescendantsInstances
    return params
end

local function hooktrajectoryraycast()
    if oldnamecall or type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then return end
    local replacement
    replacement = function(self, ...)
        local method = getnamecallmethod()
        local caller
        if type(getcallingscript) == "function" then pcall(function() caller = getcallingscript() end) end
        local thread = coroutine.running()
        local context = thread and trajectorythreads[thread]
        local fromtrajectory = context ~= nil or caller == trajectoryscript or typeof(caller) == "Instance" and caller.Name == "Trajectory"
        if method == "Raycast" and self == workspace and fromtrajectory and (settings.terrainpenetration or settings.componentpassthrough or settings.damagereticles) then
            local arguments = table.pack(...)
            local params = copyraycastparams(arguments[3])
            if params.FilterType == Enum.RaycastFilterType.Exclude then
                local filtered = table.clone(params.FilterDescendantsInstances)
                if settings.terrainpenetration then table.insert(filtered, workspace.Terrain) end
                if settings.componentpassthrough and context and type(context.passed) == "table" then
                    for part in pairs(context.passed) do table.insert(filtered, part) end
                end
                params.FilterDescendantsInstances = filtered
                arguments[3] = params
            end
            local origin = arguments[1]
            local direction = arguments[2]
            local result = oldnamecall(self, table.unpack(arguments, 1, arguments.n))
            if (settings.terrainpenetration or settings.componentpassthrough and context) and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                local remaining = direction.Magnitude
                local unit = remaining > 0 and direction.Unit
                local attempts = 0
                while result and unit and attempts < 16 and (
                    settings.terrainpenetration and result.Instance == workspace.Terrain
                    or settings.componentpassthrough and context and context.passed[result.Instance]
                ) do
                    local travelled = (result.Position - origin).Magnitude + 0.1
                    remaining -= travelled
                    if remaining <= 0 then return nil end
                    origin = result.Position + unit * 0.1
                    result = oldnamecall(self, origin, unit * remaining, params)
                    attempts += 1
                end
            end
            local vehiclesfolder = workspace:FindFirstChild("Vehicles")
            local hit = result and result.Instance
            if context and typeof(direction) == "Vector3" then
                local travelled = result and (result.Position - arguments[1]).Magnitude or direction.Magnitude
                context.remaining = math.max((context.remaining or 50000) - travelled, 0)
            end
            if settings.damagereticles and context and result and not context.hitmarked then
                local hitvehicle = runtimeclock.vehiclefrompart(hit)
                local ownvehicle = context.arguments and context.arguments[1]
                if hitvehicle and hitvehicle ~= ownvehicle then
                    context.hitmarked = true
                    if runtimeclock.showdamagereticle then runtimeclock.showdamagereticle(result, hitvehicle) end
                end
            end
            if settings.componentpassthrough and context and context.remaining > 0 and hit and vehiclesfolder and hit:IsDescendantOf(vehiclesfolder) and not context.passed[hit] and context.continuations < 24 then
                context.passed[hit] = true
                local nextarguments = table.create(context.arguments.n)
                for index = 1, context.arguments.n do nextarguments[index] = context.arguments[index] end
                nextarguments.n = context.arguments.n
                local directionunit = typeof(direction) == "Vector3" and direction.Magnitude > 0 and direction.Unit
                if directionunit then
                    nextarguments[4] = result.Position + directionunit * 0.1
                    local nextcontext = {
                        arguments = nextarguments,
                        passed = context.passed,
                        continuations = context.continuations + 1,
                        remaining = context.remaining,
                        hitmarked = context.hitmarked,
                    }
                    task.defer(function() runtrajectory(nextarguments, nextcontext, false) end)
                end
            end
            return result
        end
        return oldnamecall(self, ...)
    end
    local callback = type(newcclosure) == "function" and newcclosure(replacement) or replacement
    local success, original = pcall(hookmetamethod, game, "__namecall", callback)
    if success and type(original) == "function" then oldnamecall = original end
end

local hitpartnames = {"Ammo", "Engine", "Crew", "Turret", "Tracks", "Transmission", "Fuel"}

local function partcategory(part, vehicle)
    local object = part
    local visited = {}
    while object and not visited[object] do
        visited[object] = true
        local lower = object.Name:lower()
        if lower:find("ammo", 1, true) or lower:find("rack", 1, true) then return "Ammo" end
        if lower:find("engine", 1, true) or lower:find("motor", 1, true) then return "Engine" end
        if lower:find("track", 1, true) then return "Tracks" end
        if lower:find("trans", 1, true) or lower:find("gearbox", 1, true) then return "Transmission" end
        if lower:find("fuel", 1, true) then return "Fuel" end
        if lower:find("turret", 1, true) or lower:find("mantlet", 1, true) or lower:find("breech", 1, true) or lower:find("gunmount", 1, true) or lower:find("gun mount", 1, true) then return "Turret" end
        for _, name in ipairs({"crew", "driver", "gunner", "loader", "commander"}) do
            if lower:find(name, 1, true) then return "Crew" end
        end
        local assigned = object:FindFirstChild("AssignedTo")
        object = assigned and assigned:IsA("ObjectValue") and assigned.Value or object.Parent
        if object == vehicle then break end
    end
end

local function moduleinfo(part)
    local assigned = part and part:FindFirstChild("AssignedTo")
    local module = assigned and assigned:IsA("ObjectValue") and assigned.Value or part
    if typeof(module) ~= "Instance" then return end
    local health = tonumber(module:GetAttribute("Health")) or tonumber(part:GetAttribute("Health"))
    local total = tonumber(module:GetAttribute("TotalHealth")) or tonumber(module:GetAttribute("MaxHealth")) or tonumber(part:GetAttribute("TotalHealth")) or tonumber(part:GetAttribute("MaxHealth")) or health
    return module, health, total
end

local function selectedmodules(vehicle)
    local modules = {}
    local added = {}
    for _, object in ipairs(vehicle:GetDescendants()) do
        if object:IsA("BasePart") then
            local module, health, total = moduleinfo(object)
            if module and not added[module] and (health ~= nil or total ~= nil) then
                added[module] = true
                table.insert(modules, {name = module.Name, health = health, total = total, category = partcategory(object, vehicle) or "Module"})
            end
        end
    end

    table.sort(modules, function(a, b) return a.name:lower() < b.name:lower() end)
    return modules
end

local function parthealthratio(part, vehicle)
    local object = part
    local visited = {}
    while object and object ~= vehicle and not visited[object] do
        visited[object] = true
        local health = object:GetAttribute("Health")
        local total = object:GetAttribute("TotalHealth")
        if type(health) == "number" and type(total) == "number" and total > 0 then
            return math.clamp(health / total, 0, 1), true
        end
        local assigned = object:FindFirstChild("AssignedTo")
        object = assigned and assigned:IsA("ObjectValue") and assigned.Value or object.Parent
    end
    return 1, false
end

local function targetparts(vehicle, data)
    local now = os.clock()
    if data and data.targetparts and now < data.nextpartscan then
        local valid = true
        for _, part in ipairs(data.targetparts) do
            if not part.Parent or partdestroyed(part, vehicle) then
                valid = false
                break
            end
        end
        if valid then return data.targetparts end
    end
    local parts = {}
    local added = {}
    if not vehicle then return parts end

    local function add(part)
        if part and part:IsA("BasePart") and part.CanQuery and not added[part] and not partdestroyed(part, vehicle) then
            added[part] = true
            table.insert(parts, part)
        end
    end

    for _, object in ipairs(vehicle:GetDescendants()) do
        if object:IsA("BasePart") then
            local category = partcategory(object, vehicle)
            if category and settings.hitparts[category] then add(object) end
        end
    end

    if #parts == 0 and settings.targetfallback and data then
        add(data.part)
    end

    if data then
        data.targetparts = parts
        data.nextpartscan = now + 1.5
    end
    return parts
end

local function invalidatetargetparts()
    for _, data in pairs(vehicles) do
        data.targetparts = nil
        data.nextpartscan = 0
    end
end

local function disconnectammowatchers()
    for object, watchers in pairs(ammowatchers) do
        for _, connection in pairs(watchers) do pcall(function() connection:Disconnect() end) end
        ammowatchers[object] = nil
    end
end

local function watchammosignal(object, key, signal, callback)
    if typeof(object) ~= "Instance" or not signal or type(callback) ~= "function" then return end
    local watchers = ammowatchers[object]
    if not watchers then
        watchers = {}
        ammowatchers[object] = watchers
    end
    if watchers[key] then return end
    watchers[key] = signal:Connect(callback)
end

local function activeammotable(state)
    local function fromfunction(callback)
        if type(callback) ~= "function" or type(getfenv) ~= "function" then return end
        local success, environment = pcall(getfenv, callback)
        local value = success and type(environment) == "table" and rawget(environment, "shared")
        return type(value) == "table" and value or nil
    end
    if type(state) == "table" then
        return fromfunction(rawget(state, "fireGun")) or fromfunction(rawget(state, "accountVolley"))
    end
    local fallback
    for _, current in ipairs(gunstates) do
        local value = activeammotable(current)
        if value then
            fallback = fallback or value
            local chassis = type(current) == "table" and rawget(current, "chassis")
            if typeof(chassis) == "Instance" and (ownerplayer(chassis) == localplayer or ownername(chassis) == localplayer.Name) then
                return value
            end
        end
    end
    return fallback or shared
end

local function restoremainammo()
    local ammo = mainammotable or activeammotable()
    if mainammooriginal ~= nil and type(ammo) == "table" and type(ammo.currentammo) == "number" then
        ammo.currentammo = mainammooriginal
    end
    mainammooriginal = nil
    mainammoowner = nil
    mainammotable = nil
end

local function activechassis()
    local fallback
    for _, state in ipairs(gunstates) do
        local chassis = type(state) == "table" and rawget(state, "chassis")
        if typeof(chassis) == "Instance" and chassis.Parent then
            local owner = ownername(chassis)
            fallback = fallback or chassis
            if ownerplayer(chassis) == localplayer or owner == localplayer.Name then
                local label = rawget(state, "ammotextlbl")
                if typeof(label) == "Instance" and label.Parent then return chassis end
            end
        end
    end
    return fallback
end

local function mainammocapacity()
    local ammo = mainammotable or activeammotable()
    local brought = tonumber(ammo.ammobrought)
    local original = tonumber(mainammooriginal)
    local current = tonumber(ammo.currentammo)
    return math.max(brought or 0, original or 0, current or 0, 1)
end

local function updatemainammo()
    local ammo = activeammotable()
    if not settings.mainammo or type(ammo.currentammo) ~= "number" then return end
    local owner = activechassis()
    if ammo ~= mainammotable then
        mainammotable = ammo
        mainammoowner = owner
        mainammooriginal = ammo.currentammo
    elseif owner and owner ~= mainammoowner then
        mainammoowner = owner
        mainammooriginal = ammo.currentammo
    end
    if mainammooriginal == nil then mainammooriginal = ammo.currentammo end
    mainammotable = ammo
    local capacity = mainammocapacity()
    if ammo.currentammo ~= capacity then reservecorrections += 1 end
    ammo.currentammo = capacity
    for _, state in ipairs(gunstates) do
        local label = type(state) == "table" and rawget(state, "ammotextlbl")
        if typeof(label) == "Instance" and label:IsA("TextLabel") then
            label.Text = "Ammo: " .. tostring(ammo.currentammo) .. "/" .. tostring(capacity)
            watchammosignal(label, "maintext", label:GetPropertyChangedSignal("Text"), function()
                if not settings.mainammo or type(ammo.currentammo) ~= "number" then return end
                local desired = "Ammo: " .. tostring(ammo.currentammo) .. "/" .. tostring(mainammocapacity())
                if label.Text ~= desired then label.Text = desired end
            end)
        end
    end
end

local function restoresecondaryammo()
    for object, value in pairs(ammooriginals) do
        if object.Parent then pcall(function() object:SetAttribute("Ammo", value) end) end
        ammooriginals[object] = nil
    end
end

local function restoremainclip()
    for state, value in pairs(cliporiginals) do
        if type(state) == "table" then state.currentClip = value end
        cliporiginals[state] = nil
    end
end

local function restorevolleyhook(state)
    local hook = volleyoriginals[state]
    if type(state) == "table" and type(hook) == "table" then
        if hook.mode == "closure" and type(hookfunction) == "function" and type(hook.target) == "function" and type(hook.original) == "function" then
            pcall(hookfunction, hook.target, hook.original)
        elseif hook.mode == "table" and rawget(state, "accountVolley") == hook.replacement then
            state.accountVolley = hook.original
        end
    end
    volleyoriginals[state] = nil
end

local function restorevolleyhooks()
    for state in pairs(volleyoriginals) do restorevolleyhook(state) end
end

local function restoreammo()
    restoremainammo()
    restoremainclip()
    restoresecondaryammo()
end

local function predictionlatency()
    if not settings.latencyprediction then
        solverlatency = 0
        solverjitter = 0
        return 0
    end
    local now = os.clock()
    if now - latencyclock >= 0.25 then
        local success, ping = pcall(function()
            return stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if success and type(ping) == "number" and ping >= 0 then
            local scale = math.clamp(0.35 + ping / 500, 0.35, 0.8)
            local sample = math.clamp(ping / 1000 * scale, 0, 0.5)
            if latencysuccessclock == 0 then
                latencyvalue = sample
                solverjitter = 0
            else
                local difference = math.abs(sample - latencyvalue)
                solverjitter += (difference - solverjitter) * 0.25
                latencyvalue += (sample - latencyvalue) * 0.5
            end
            latencysuccessclock = now
        elseif latencysuccessclock == 0 or now - latencysuccessclock > 2 then
            latencyvalue *= 0.9
            solverjitter = math.max(solverjitter, 0.05)
        end
        latencyclock = now
    end
    solverlatency = latencyvalue
    return latencyvalue
end

local function projectilerange(shell)
    if typeof(shell) ~= "Instance" then return 50000 end
    local maxrange = shell:FindFirstChild("MaxRange")
    local value = maxrange and tonumber(maxrange.Value)
    return value and value > 0 and value * 3570 or 50000
end

local function predictdirection(origin, speed, gravity, inheritedvelocity, maxrange)
    local part = currenttargetpart
    predictedpoint = nil
    solvertarget = nil
    solverpart = nil
    solverstatus = "invalid"
    solvertime = nil
    solverdistance = nil
    solverrange = finitenumber(maxrange) and maxrange or nil
    solverdropscale = nil
    solverquality = nil
    solverconfidence = nil
    if not part or not finitevector(origin) or not finitenumber(speed) or speed <= 0 then return end

    local aimposition = part.CFrame:PointToWorldSpace(currenttargetoffset)
    local offset = aimposition - origin
    solverdistance = offset.Magnitude
    local inherited = finitevector(inheritedvelocity) and inheritedvelocity or Vector3.zero
    local root = part.AssemblyRootPart or currenttarget and vehiclepart(currenttarget)
    local measuredvelocity = finitevector(part.AssemblyLinearVelocity) and part.AssemblyLinearVelocity or Vector3.zero
    local rootvelocity = root and root.AssemblyLinearVelocity
    local rawvelocity = finitevector(rootvelocity) and rootvelocity or measuredvelocity
    local targetvelocity = rawvelocity
    local rootangularvelocity = root and root.AssemblyAngularVelocity
    local angularvelocity = settings.angularprediction and finitevector(rootangularvelocity) and rootangularvelocity or Vector3.zero
    local airvehicle = currenttarget and (
        currenttarget:GetAttribute("Plane") == true
        or currenttarget:GetAttribute("Heli") == true
        or currenttarget:GetAttribute("Helicopter") == true
        or currenttarget:GetAttribute("Aircraft") == true
        or root and (
            root:GetAttribute("Plane") == true
            or root:GetAttribute("Heli") == true
            or root:GetAttribute("Helicopter") == true
            or root:GetAttribute("Aircraft") == true
        )
    )
    if settings.groundstabilization and not airvehicle then
        targetvelocity = Vector3.new(targetvelocity.X, math.clamp(targetvelocity.Y, -5, 5), targetvelocity.Z)
        angularvelocity = Vector3.new(0, angularvelocity.Y, 0)
    end
    if angularvelocity.Magnitude > 3 then angularvelocity = angularvelocity.Unit * 3 end
    local center = root and root.AssemblyCenterOfMass or aimposition
    local rotationaloffset = aimposition - center
    local accelerationconfidence = math.clamp(tonumber(currentaccelerationconfidence) or 0, 0, 1)
    local validacceleration = finitevector(currenttargetacceleration) and currenttargetacceleration or Vector3.zero
    local targetacceleration = settings.accelerationprediction and validacceleration * accelerationconfidence or Vector3.zero
    if settings.groundstabilization and not airvehicle then
        targetacceleration = Vector3.new(targetacceleration.X, 0, targetacceleration.Z)
    end
    if targetacceleration.Magnitude > 40 then targetacceleration = targetacceleration.Unit * 40 end
    local predictionstrength = math.clamp(tonumber(settings.predictionstrength) or 0.8, 0.25, 1.25)

    local function accelerationoffset(time)
        local duration = math.max(time, 0)
        return targetacceleration * (duration * duration * 0.5)
    end

    local function targetdisplacement(time)
        local displacement = targetvelocity * time + accelerationoffset(time)
        local rotation = angularvelocity.Magnitude * time
        if rotation ~= 0 and rotationaloffset.Magnitude > 0 then
            local rotated = CFrame.fromAxisAngle(angularvelocity.Unit, rotation):VectorToWorldSpace(rotationaloffset)
            displacement += rotated - rotationaloffset
        end
        return displacement * predictionstrength
    end

    local latency = predictionlatency()
    local dropdistance = math.clamp(offset.Magnitude / 3000, 0, 1)
    local dropscale = (dropdistance * dropdistance * (3 - 2 * dropdistance)) * 0.1
    solverdropscale = dropscale
    local drop = finitenumber(gravity) and math.max(gravity, 0) * dropscale or 0

    local function requiredoffset(time)
        return offset + targetdisplacement(latency + time) - inherited * time + Vector3.new(0, drop * time * time * 0.5, 0)
    end

    local function travelerror(time)
        return requiredoffset(time).Magnitude - speed * time
    end

    local directtime = (offset + targetdisplacement(latency)).Magnitude / speed
    local desiredtime = math.clamp(directtime * 3 + 1, 1, 20)
    local rangetime = finitenumber(maxrange) and math.max(maxrange, 0) / speed or 20
    local maxtime = math.min(desiredtime, rangetime)
    local rangelimited = rangetime < desiredtime
    if maxtime <= 0 then
        solverstatus = "out of range"
        solverconfidence = 0
        return
    end
    local refinement = math.clamp(math.floor(tonumber(settings.refinement) or 5), 1, 14)
    if settings.adaptiverefinement then
        local extra = math.floor(offset.Magnitude / 900 + targetvelocity.Magnitude / 60 + targetacceleration.Magnitude / 25)
        refinement = math.clamp(refinement + extra, 1, 14)
    end
    solverquality = refinement
    local steps = 160 + refinement * 16
    local previous = 0
    local previouserror = travelerror(0)
    local low
    local high

    for index = 1, steps do
        local sampletime = maxtime * index / steps
        local sampleerror = travelerror(sampletime)
        if previouserror > 0 and sampleerror <= 0 then
            low = previous
            high = sampletime
            break
        end
        previous = sampletime
        previouserror = sampleerror
    end

    if not low then
        solverstatus = rangelimited and "out of range" or "unreachable"
        solverconfidence = 0
        predictedpoint = nil
        return nil
    end

    for _ = 1, 24 + refinement do
        local middle = (low + high) * 0.5
        if travelerror(middle) > 0 then
            low = middle
        else
            high = middle
        end
    end

    local time = (low + high) * 0.5
    local aimoffset = requiredoffset(time)
    local direction = aimoffset.Magnitude > 0 and aimoffset.Unit or nil
    if not direction then return end

    solverstatus = "solved"
    solvertime = time
    local motionrisk = targetacceleration.Magnitude * time * time * 0.5
        + targetvelocity.Magnitude * latency
        + angularvelocity.Magnitude * time * rotationaloffset.Magnitude
    local trajectoryconfidence = math.clamp(1 - motionrisk / math.max(part.Size.Magnitude * 3 + 10, 10), 0, 1)
    local accelerationreliability = settings.accelerationprediction and (0.5 + accelerationconfidence * 0.5) or 1
    local networkreliability = 1 - math.clamp(solverjitter / 0.15, 0, 0.5)
    solverconfidence = trajectoryconfidence * accelerationreliability * networkreliability
    local predicttime = time + latency
    predictedpoint = aimposition + targetdisplacement(predicttime)
    solvertarget = currenttarget
    solverpart = part
    return direction
end

local function validgunstate(object)
    if type(object) ~= "table" or type(rawget(object, "gunCaliber")) ~= "number" then return false end
    if type(rawget(object, "gunBrickTbl")) ~= "table" or type(rawget(object, "accountVolley")) ~= "function" then return false end
    local chassis = rawget(object, "chassis")
    if typeof(chassis) ~= "Instance" or not chassis.Parent then return false end
    return true
end

local function ownedchassis()
    local folder = workspace:FindFirstChild("Vehicles")
    if not folder then return end
    local character = localplayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local seat = humanoid and humanoid.SeatPart
    if seat then
        local object = seat
        while object and object.Parent ~= folder do object = object.Parent end
        if object and object.Parent == folder then return object end
    end
    local fallback
    for _, chassis in ipairs(folder:GetChildren()) do
        local owner = ownername(chassis)
        if ownerplayer(chassis) == localplayer or owner == localplayer.Name then return chassis end
        if owner == nil and chassis:FindFirstChild("GunStr") then fallback = fallback or chassis end
    end
    return fallback
end

local function restorevehiclephysics(physics, original)
    if type(physics) ~= "table" or type(original) ~= "table" then return end
    if original.maxspeed then physics.MAX_SPEED = original.maxspeed end
    if original.maxreversespeed then physics.MAX_REVERSE_SPEED = original.maxreversespeed end
    if original.driveforce then physics.DRIVE_FORCE = original.driveforce end
    if original.enginepower then physics.enginePower = original.enginepower end
    if original.brakeforce then physics.BRAKE_FORCE = original.brakeforce end
    if original.turnspeed then physics.TURN_SPEED = original.turnspeed end
    if original.tankmaxyaw then physics.TANK_MAX_YAW = original.tankmaxyaw end
    if original.steerfactor then physics.STEER_FACTOR = original.steerfactor end
    if original.tiregrip then physics.TIRE_GRIP = original.tiregrip end
    if original.rollingresist then physics.ROLLING_RESIST = original.rollingresist end
end

local function restorevehiclemods()
    for physics, original in pairs(vehicleoriginals) do
        restorevehiclephysics(physics, original)
        vehicleoriginals[physics] = nil
    end
end

local function findvehiclephysics()
    local direct = rawget(shared, "_qhassisV5Physics")
    if type(direct) == "table" and tonumber(rawget(direct, "MAX_SPEED")) and tonumber(rawget(direct, "DRIVE_FORCE")) then
        cachedvehiclephysics = direct
        return direct
    end
    if type(cachedvehiclephysics) == "table" and tonumber(rawget(cachedvehiclephysics, "MAX_SPEED")) and tonumber(rawget(cachedvehiclephysics, "DRIVE_FORCE")) then return cachedvehiclephysics end
    if type(getgc) ~= "function" or os.clock() - lastvehiclephysicsscan < 5 then return end
    lastvehiclephysicsscan = os.clock()
    local chassis = ownedchassis()
    local success, objects = pcall(getgc, true)
    if not success or type(objects) ~= "table" then success, objects = pcall(getgc) end
    if not success or type(objects) ~= "table" then return end
    for _, object in ipairs(objects) do
        if type(object) == "table" and tonumber(rawget(object, "MAX_SPEED")) and tonumber(rawget(object, "DRIVE_FORCE")) then
            local body = rawget(object, "body")
            if typeof(body) == "Instance" and body:IsA("BasePart") and (not chassis or body:IsDescendantOf(chassis)) then
                cachedvehiclephysics = object
                return object
            end
        end
    end
end

local function updatevehiclemods(delta)
    delta = tonumber(delta) or 0
    if not settings.vehiclespeed and not settings.vehicleacceleration and not settings.vehiclereverse and not settings.vehiclebrake and not settings.vehiclesteering and not settings.vehiclegrip and not settings.vehicledrag and not settings.vehiclefly then
        restorevehiclemods()
        return
    end
    local needsphysics = settings.vehiclespeed or settings.vehicleacceleration or settings.vehiclereverse or settings.vehiclebrake or settings.vehiclesteering or settings.vehiclegrip or settings.vehicledrag
    local physics = needsphysics and findvehiclephysics() or nil
    for cached, original in pairs(vehicleoriginals) do
        if cached ~= physics then
            restorevehiclephysics(cached, original)
            vehicleoriginals[cached] = nil
        end
    end
    local speedmult = settings.vehiclespeed and settings.vehiclespeedmult or 1
    local accelerationmult = settings.vehicleacceleration and settings.vehicleaccelerationmult or 1
    local reversemult = settings.vehiclereverse and settings.vehiclereversemult or 1
    local brakemult = settings.vehiclebrake and settings.vehiclebrakemult or 1
    local steeringmult = settings.vehiclesteering and settings.vehiclesteeringmult or 1
    local gripmult = settings.vehiclegrip and settings.vehiclegripmult or 1
    local dragmult = settings.vehicledrag and settings.vehicledragmult or 1
    if type(physics) == "table" then
        local original = vehicleoriginals[physics]
        if not original then
            original = {
                maxspeed = tonumber(rawget(physics, "MAX_SPEED")),
                maxreversespeed = tonumber(rawget(physics, "MAX_REVERSE_SPEED")),
                driveforce = tonumber(rawget(physics, "DRIVE_FORCE")),
                enginepower = tonumber(rawget(physics, "enginePower")),
                brakeforce = tonumber(rawget(physics, "BRAKE_FORCE")),
                turnspeed = tonumber(rawget(physics, "TURN_SPEED")),
                tankmaxyaw = tonumber(rawget(physics, "TANK_MAX_YAW")),
                steerfactor = tonumber(rawget(physics, "STEER_FACTOR")),
                tiregrip = tonumber(rawget(physics, "TIRE_GRIP")),
                rollingresist = tonumber(rawget(physics, "ROLLING_RESIST")),
            }
            vehicleoriginals[physics] = original
        end
        if original.maxspeed then physics.MAX_SPEED = original.maxspeed * speedmult end
        if original.maxreversespeed then physics.MAX_REVERSE_SPEED = original.maxreversespeed * reversemult end
        if original.driveforce then physics.DRIVE_FORCE = original.driveforce * accelerationmult end
        if original.enginepower then physics.enginePower = original.enginepower * accelerationmult end
        if original.brakeforce then physics.BRAKE_FORCE = original.brakeforce * brakemult end
        if original.turnspeed then physics.TURN_SPEED = original.turnspeed * steeringmult end
        if original.tankmaxyaw then physics.TANK_MAX_YAW = original.tankmaxyaw * steeringmult end
        if original.steerfactor then physics.STEER_FACTOR = original.steerfactor * steeringmult end
        if original.tiregrip then physics.TIRE_GRIP = original.tiregrip * gripmult end
        if original.rollingresist then physics.ROLLING_RESIST = original.rollingresist * dragmult end
    end
    if delta <= 0 then return end
    local chassis = ownedchassis()
    local hull = chassis and (chassis:FindFirstChild("HullNode", true) or chassis.PrimaryPart)
    if not hull or not hull:IsA("BasePart") then
        runtimeclock.flyhull = nil
        runtimeclock.flyvelocity = nil
        runtimeclock.flyaltitude = nil
        return
    end
    if settings.vehiclefly then
        if runtimeclock.flyhull ~= hull then
            runtimeclock.flyhull = hull
            runtimeclock.flyvelocity = hull.AssemblyLinearVelocity
            runtimeclock.flyaltitude = hull.Position.Y
        end
        local forward = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        forward = Vector3.new(forward.X, 0, forward.Z)
        right = Vector3.new(right.X, 0, right.Z)
        if forward.Magnitude > 0 then forward = forward.Unit end
        if right.Magnitude > 0 then right = right.Unit end
        local direction = Vector3.zero
        if userinputservice:IsKeyDown(Enum.KeyCode.W) then direction += forward end
        if userinputservice:IsKeyDown(Enum.KeyCode.S) then direction -= forward end
        if userinputservice:IsKeyDown(Enum.KeyCode.D) then direction += right end
        if userinputservice:IsKeyDown(Enum.KeyCode.A) then direction -= right end
        if direction.Magnitude > 1 then direction = direction.Unit end
        local vertical = 0
        if userinputservice:IsKeyDown(Enum.KeyCode.Space) then vertical += 1 end
        if userinputservice:IsKeyDown(Enum.KeyCode.LeftControl) then vertical -= 1 end
        if vertical ~= 0 then runtimeclock.flyaltitude = hull.Position.Y end
        local speed = settings.vehicleflyspeed
        local targetvertical = vertical * settings.vehicleflyverticalspeed
        if vertical == 0 and settings.vehicleflyhover then
            targetvertical = math.clamp((runtimeclock.flyaltitude - hull.Position.Y) * 2.4, -settings.vehicleflyverticalspeed, settings.vehicleflyverticalspeed)
        end
        local targetvelocity = direction * speed + Vector3.yAxis * targetvertical
        local response = 1 - math.exp(-math.max(settings.vehicleflyacceleration, 0.1) * delta)
        runtimeclock.flyvelocity = (runtimeclock.flyvelocity or hull.AssemblyLinearVelocity):Lerp(targetvelocity, math.clamp(response, 0, 1))
        hull.AssemblyLinearVelocity = runtimeclock.flyvelocity
        return
    end
    runtimeclock.flyhull = nil
    runtimeclock.flyvelocity = nil
    runtimeclock.flyaltitude = nil
    local throttle = tonumber(rawget(shared, "throttle")) or 0
    local seat = chassis:FindFirstChildWhichIsA("VehicleSeat", true)
    if math.abs(throttle) < 0.01 and seat then throttle = seat.ThrottleFloat end
    if math.abs(throttle) < 0.01 then
        if userinputservice:IsKeyDown(Enum.KeyCode.W) then throttle = 1 end
        if userinputservice:IsKeyDown(Enum.KeyCode.S) then throttle = -1 end
    end
    if math.abs(throttle) < 0.01 then return end
    local forward = hull.CFrame.LookVector
    local velocity = hull.AssemblyLinearVelocity
    local basemax = type(physics) == "table" and vehicleoriginals[physics] and vehicleoriginals[physics].maxspeed or 95
    if speedmult <= 1.01 and accelerationmult <= 1.01 then return end
    local desired = math.min(math.max(basemax, 25), 70) * speedmult * math.sign(throttle)
    local current = velocity:Dot(forward)
    local response = math.clamp(delta * (1.25 + accelerationmult * 0.75), 0, 1)
    hull.AssemblyLinearVelocity = velocity + forward * (desired - current) * response
end

runtimeclock.restorenosmoke = function()
    for object, original in pairs(runtimeclock.smokeoriginals or {}) do
        if object.Parent then
            pcall(function()
                object.Enabled = original.enabled
                if object:IsA("ParticleEmitter") then object.Lifetime = original.lifetime end
            end)
        end
    end
    runtimeclock.smokeoriginals = nil
    if runtimeclock.gunfireparticles and runtimeclock.gunfireparticles.Parent then runtimeclock.gunfireparticles.Value = runtimeclock.gunfireparticlevalue end
    if runtimeclock.gunfirelights and runtimeclock.gunfirelights.Parent then runtimeclock.gunfirelights.Value = runtimeclock.gunfirelightvalue end
    runtimeclock.gunfireparticles = nil
    runtimeclock.gunfirelights = nil
end

runtimeclock.suppresssmoke = function(root)
    if not settings.nosmoke or not root then return end
    runtimeclock.smokeoriginals = runtimeclock.smokeoriginals or setmetatable({}, {__mode = "k"})
    for _, object in ipairs(root:GetDescendants()) do
        local name = object.Name:lower()
        local effect = name == "muzzlesmoke" or name == "aftersmoke" or name == "muzzlefire" or name == "muzzlesparks" or name == "muzzleflash" or name == "barrelsparks" or name == "ejectsmoke"
        if effect and (object:IsA("ParticleEmitter") or object:IsA("Smoke") or object:IsA("Fire")) then
            if not runtimeclock.smokeoriginals[object] then
                runtimeclock.smokeoriginals[object] = {enabled = object.Enabled, lifetime = object:IsA("ParticleEmitter") and object.Lifetime or nil}
            end
            object.Enabled = false
            if object:IsA("ParticleEmitter") then object.Lifetime = NumberRange.new(0) end
        end
    end
end

runtimeclock.updatenosmoke = function(rescan)
    if not settings.nosmoke then runtimeclock.restorenosmoke(); return end
    local particles = rawget(shared, "GunfireParticles")
    local lights = rawget(shared, "GunfireLights")
    if typeof(particles) == "Instance" and particles:IsA("NumberValue") then
        if runtimeclock.gunfireparticles ~= particles then
            runtimeclock.gunfireparticles = particles
            runtimeclock.gunfireparticlevalue = particles.Value
        end
        particles.Value = 0
    end
    if typeof(lights) == "Instance" and lights:IsA("BoolValue") then
        if runtimeclock.gunfirelights ~= lights then
            runtimeclock.gunfirelights = lights
            runtimeclock.gunfirelightvalue = lights.Value
        end
        lights.Value = false
    end
    if rescan then runtimeclock.suppresssmoke(workspace:FindFirstChild("Vehicles")) end
end

local function spoofrepairstop(chassis)
    local hull = chassis and (chassis:FindFirstChild("HullNode", true) or chassis.PrimaryPart)
    if not hull or not hull:IsA("BasePart") then return end
    local velocity = hull.AssemblyLinearVelocity
    local angularvelocity = hull.AssemblyAngularVelocity
    hull.AssemblyLinearVelocity = Vector3.zero
    hull.AssemblyAngularVelocity = Vector3.zero
    task.delay(0.4, function()
        if hull.Parent and not settings.vehiclefly then
            hull.AssemblyLinearVelocity = velocity
            hull.AssemblyAngularVelocity = angularvelocity
        end
    end)
end

local function pressrepair()
    spoofrepairstop(ownedchassis())
    if type(keypress) == "function" and type(keyrelease) == "function" then
        keypress(0x46)
        task.delay(0.08, function() keyrelease(0x46) end)
        return
    end
    pcall(function()
        local input = game:GetService("VirtualInputManager")
        input:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.delay(0.08, function() input:SendKeyEvent(false, Enum.KeyCode.F, false, game) end)
    end)
end

local function updateautorepair()
    if not settings.autorepair or shared.repairing or os.clock() - lastrepairattempt < 1 then return end
    local chassis = ownedchassis()
    if not chassis then return end
    lastrepairattempt = os.clock()
    pressrepair()
end

local function updatefastrepair()
    if not settings.fastrepair then return end
    local chassis = ownedchassis()
    if not chassis then return end
    if chassis:GetAttribute("RepairTimeLeft") ~= nil then chassis:SetAttribute("RepairTimeLeft", 0) end
end

--[[ removed round changer
local function refreshrounds()
    local main = availablerounds("main")
    local secondary = availablerounds("secondary")
    local mainsignature = table.concat(main, "\0")
    local secondarysignature = table.concat(secondary, "\0")
    if runtimeclock.rounddropdown and runtimeclock.roundsignature ~= mainsignature then
        runtimeclock.roundsignature = mainsignature
        runtimeclock.rounddropdown:SetValues(main)
    end
    if runtimeclock.secondaryrounddropdown and runtimeclock.secondaryroundsignature ~= secondarysignature then
        runtimeclock.secondaryroundsignature = secondarysignature
        runtimeclock.secondaryrounddropdown:SetValues(secondary)
    end
    if not table.find(main, settings.selectedround) then settings.selectedround = main[1] end
    if not table.find(secondary, settings.selectedsecondaryround) then settings.selectedsecondaryround = secondary[1] end
    if runtimeclock.rounddropdown then runtimeclock.rounddropdown:SetValue(settings.selectedround) end
    if runtimeclock.secondaryrounddropdown then runtimeclock.secondaryrounddropdown:SetValue(settings.selectedsecondaryround) end
end

local function updateroundchanger()
    if not settings.roundchanger then return end
    local chassis = ownedchassis()
    local function configshells(object, depth)
        if typeof(object) ~= "Instance" then return end
        local current = object
        for _ = 0, depth or 0 do
            local config = current:FindFirstChild("Config")
            local shells = config and config:FindFirstChild("Shells")
            if shells then return shells end
            current = current.Parent
            if not current then break end
        end
    end
    local function reorder(container, name)
        local selected = container and container:FindFirstChild(name)
        if not selected or not selected:IsA("Folder") or container:FindFirstChildWhichIsA("Folder") == selected then return end
        runtimeclock.secondaryroundorders = runtimeclock.secondaryroundorders or setmetatable({}, {__mode = "k"})
        if not runtimeclock.secondaryroundorders[container] then
            runtimeclock.secondaryroundorders[container] = {}
            for _, shell in ipairs(container:GetChildren()) do
                if shell:IsA("Folder") then table.insert(runtimeclock.secondaryroundorders[container], shell) end
            end
        end
        local others = {}
        for _, shell in ipairs(container:GetChildren()) do
            if shell:IsA("Folder") and shell ~= selected then shell.Parent = nil; table.insert(others, shell) end
        end
        selected.Parent = nil
        selected.Parent = container
        for _, shell in ipairs(others) do shell.Parent = container end
    end
    for _, state in ipairs(gunstates) do
        if type(state) == "table" and (not chassis or rawget(state, "chassis") == chassis) then
            if settings.selectedround ~= "None" then
                local shell
                local gunmodel = rawget(state, "gunModel")
                local container = configshells(gunmodel, 1)
                shell = container and container:FindFirstChild(settings.selectedround)
                if not shell then
                    local guns = rawget(state, "gunBrickTbl")
                    if type(guns) == "table" then
                        for gunbrick in pairs(guns) do
                            container = configshells(gunbrick, 3)
                            shell = container and container:FindFirstChild(settings.selectedround)
                            if shell then break end
                        end
                    end
                end
                if shell and shell:IsA("Folder") then
                    local shellvalue = rawget(state, "shellVal")
                    if shared.SelectedShell ~= shell.Name or rawget(state, "selectShell") ~= shell or typeof(shellvalue) == "Instance" and shellvalue.Value ~= shell.Name then
                        local shells = rawget(state, "shellsTable")
                        local index = type(shells) == "table" and table.find(shells, shell) or nil
                        state.keyNum = index or rawget(state, "keyNum") or 1
                        local numbernames = rawget(state, "numberNames")
                        state.keyName = index and type(numbernames) == "table" and numbernames[index] or rawget(state, "keyName")
                        state.selectShell = shell
                        state.pendingsel = nil
                        shared.SelectedShell = shell.Name
                        if typeof(shellvalue) == "Instance" and shellvalue:IsA("StringValue") then shellvalue.Value = shell.Name end
                        local shellchange = rawget(state, "shellchange")
                        if type(shellchange) == "function" then pcall(shellchange) end
                    end
                end
            end
            if settings.selectedsecondaryround ~= "None" then
                local guns = rawget(state, "secondaryGunBrickTbl")
                if type(guns) == "table" then
                    for gunbrick in pairs(guns) do
                        reorder(configshells(gunbrick, 2), settings.selectedsecondaryround)
                    end
                end
                local missiles = rawget(state, "secondaryMissileTbl")
                if type(missiles) == "table" then
                    for _, missile in pairs(missiles) do reorder(configshells(missile, 1), settings.selectedsecondaryround) end
                end
            end
        end
    end
end

]]
runtimeclock.restorerecoil = function()
    for object, value in pairs(runtimeclock.recoilvalues or {}) do
        if object.Parent then pcall(function() object.Value = value end) end
    end
    for state, value in pairs(runtimeclock.recoilstates or {}) do
        if type(state) == "table" then state.recoilForce = value end
    end
    if runtimeclock.sharedrecoillength ~= nil then shared.RecoilLength = runtimeclock.sharedrecoillength end
    runtimeclock.recoilvalues = nil
    runtimeclock.recoilstates = nil
    runtimeclock.sharedrecoillength = nil
    runtimeclock.recoilchassis = nil
end

runtimeclock.updaterecoil = function(rescan)
    if not settings.norecoil then return end
    local chassis = ownedchassis()
    if not chassis then return end
    if runtimeclock.recoilchassis ~= chassis then
        runtimeclock.restorerecoil()
        runtimeclock.recoilchassis = chassis
        rescan = true
    end
    runtimeclock.recoilvalues = runtimeclock.recoilvalues or setmetatable({}, {__mode = "k"})
    runtimeclock.recoilstates = runtimeclock.recoilstates or setmetatable({}, {__mode = "k"})
    if rescan then
        for _, object in ipairs(chassis:GetDescendants()) do
            if object:IsA("NumberValue") and (object.Name == "RecoilForce" or object.Name == "RecoilLength") then
                if runtimeclock.recoilvalues[object] == nil then runtimeclock.recoilvalues[object] = object.Value end
            end
        end
    end
    for _, state in ipairs(gunstates) do
        if type(state) == "table" and rawget(state, "chassis") == chassis and type(rawget(state, "recoilForce")) == "number" then
            if runtimeclock.recoilstates[state] == nil then runtimeclock.recoilstates[state] = state.recoilForce end
            state.recoilForce = 0
        end
    end
    if runtimeclock.sharedrecoillength == nil and type(shared.RecoilLength) == "number" then runtimeclock.sharedrecoillength = shared.RecoilLength end
    if type(shared.RecoilLength) == "number" then shared.RecoilLength = 0 end
    for object in pairs(runtimeclock.recoilvalues) do
        if object.Parent and object.Value ~= 0 then pcall(function() object.Value = 0 end) end
    end
end

local function directgunmodule(chassis)
    if typeof(chassis) ~= "Instance" or not chassis.Parent then return end
    local gunstr = chassis:FindFirstChild("GunStr")
    local guns = chassis:FindFirstChild("Gun")
    local selected
    if gunstr then pcall(function() selected = gunstr.Value end) end
    local gun = type(selected) == "string" and guns and guns:FindFirstChild(selected)
    local config = gun and gun:FindFirstChild("Config")
    local module = config and config:FindFirstChild("GunControls")
    return module and module:IsA("ModuleScript") and module or nil
end

local function scangunstates()
    lastgunscan = os.clock()
    table.clear(gunstates)
    gunstatus = "scanning"
    local seen = {}
    local sources = {direct = 0, mobile = 0, loaded = 0, gc = 0}
    local errors = {}
    local function add(object, source)
        if validgunstate(object) and not seen[object] then
            seen[object] = true
            table.insert(gunstates, object)
            sources[source] += 1
        end
    end
    local module = directgunmodule(ownedchassis())
    if module then
        local success, result = pcall(require, module)
        if success then add(result, "direct") else table.insert(errors, "direct require") end
    else
        table.insert(errors, "direct module")
    end
    local firemain = #gunstates == 0 and type(shared.mobileWire) == "table" and shared.mobileWire.fireMain
    if #gunstates == 0 and type(firemain) == "function" then
        if type(getupvalues) == "function" then
            local success, values = pcall(getupvalues, firemain)
            if success and type(values) == "table" then
                for _, value in pairs(values) do add(value, "mobile") end
            else
                table.insert(errors, "mobile upvalues")
            end
        elseif type(debug) == "table" and type(debug.getupvalue) == "function" then
            for index = 1, 32 do
                local success, first, second = pcall(debug.getupvalue, firemain, index)
                if not success or first == nil then break end
                add(second ~= nil and second or first, "mobile")
            end
        else
            table.insert(errors, "upvalues unavailable")
        end
    elseif #gunstates == 0 then
        table.insert(errors, "mobile fire")
    end
    if #gunstates == 0 and type(getloadedmodules) == "function" then
        local success, modules = pcall(getloadedmodules)
        if success and type(modules) == "table" then
            for _, loaded in ipairs(modules) do
                if typeof(loaded) == "Instance" and loaded:IsA("ModuleScript") and loaded.Name == "GunControls" then
                    local loadedok, result = pcall(require, loaded)
                    if loadedok then add(result, "loaded") end
                end
            end
        else
            table.insert(errors, "loaded modules")
        end
    end
    if #gunstates == 0 and type(getgc) == "function" then
        local success, objects = pcall(getgc, true)
        if not success or type(objects) ~= "table" then success, objects = pcall(getgc) end
        if success and type(objects) == "table" then
            for _, object in ipairs(objects) do add(object, "gc") end
        else
            table.insert(errors, "getgc")
        end
    elseif #gunstates == 0 then
        table.insert(errors, "getgc unavailable")
    end
    gundiscovery = "direct " .. tostring(sources.direct) .. " | mobile " .. tostring(sources.mobile) .. " | loaded " .. tostring(sources.loaded) .. " | gc " .. tostring(sources.gc)
    if #errors > 0 then gundiscovery ..= " | " .. table.concat(errors, ", ") end
    gunstatus = #gunstates > 0 and tostring(#gunstates) .. " state(s) | " .. gundiscovery or "no compatible state | " .. gundiscovery
    if updatevolleyhooks then updatevolleyhooks() end
    if refreshammowatchers then refreshammowatchers() end
end

local function updatemainclips()
    if not settings.mainclip then return end
    local ammo = activeammotable()
    if type(ammo.currentammo) == "number" then
        local owner = activechassis()
        if ammo ~= mainammotable then
            mainammotable = ammo
            mainammoowner = owner
            mainammooriginal = ammo.currentammo
        elseif owner and owner ~= mainammoowner then
            mainammoowner = owner
            mainammooriginal = ammo.currentammo
        end
        if mainammooriginal == nil then mainammooriginal = ammo.currentammo end
        mainammotable = ammo
        ammo.currentammo = mainammocapacity()
    end
    for _, state in ipairs(gunstates) do
        local clip = type(state) == "table" and tonumber(rawget(state, "clip"))
        if clip and clip > 0 then
            if cliporiginals[state] == nil then cliporiginals[state] = tonumber(rawget(state, "currentClip")) or clip end
            if state.currentClip ~= clip then clipcorrections += 1 end
            state.currentClip = clip
            local label = rawget(state, "clipTextLabel")
            if typeof(label) == "Instance" and label:IsA("TextLabel") then
                label.Text = tostring(clip) .. "/" .. tostring(clip)
                watchammosignal(label, "cliptext", label:GetPropertyChangedSignal("Text"), function()
                    if not settings.mainclip then return end
                    local desired = tostring(clip) .. "/" .. tostring(clip)
                    if label.Text ~= desired then label.Text = desired end
                end)
            end
            local ammolabel = rawget(state, "ammotextlbl")
            if typeof(ammolabel) == "Instance" and ammolabel:IsA("TextLabel") then
                local desired = "Ammo: " .. tostring(ammo.currentammo) .. "/" .. tostring(tonumber(ammo.ammobrought) or ammo.currentammo)
                if ammolabel.Text ~= desired then ammolabel.Text = desired end
                watchammosignal(ammolabel, "maintext", ammolabel:GetPropertyChangedSignal("Text"), function()
                    if not settings.mainclip or type(ammo.currentammo) ~= "number" then return end
                    local text = "Ammo: " .. tostring(ammo.currentammo) .. "/" .. tostring(tonumber(ammo.ammobrought) or ammo.currentammo)
                    if ammolabel.Text ~= text then ammolabel.Text = text end
                end)
            end
        end
    end
end

local function installvolleyhook(state)
    if type(state) ~= "table" then return end
    local existing = volleyoriginals[state]
    if type(existing) == "table" then
        local current = rawget(state, "accountVolley")
        if existing.mode == "closure" and current == existing.target or existing.mode == "table" and current == existing.replacement then return end
        restorevolleyhook(state)
    end
    local original = rawget(state, "accountVolley")
    if type(original) ~= "function" then return end
    local replacement
    local calloriginal
    replacement = function(amount)
        local ammo = activeammotable(state)
        local desiredreserve
        if settings.mainammo and type(ammo.currentammo) == "number" then
            desiredreserve = mainammocapacity()
        elseif settings.mainclip and type(ammo.currentammo) == "number" then
            desiredreserve = math.max(mainammocapacity(), ammo.currentammo + math.max(tonumber(amount) or 0, 0))
        end
        if desiredreserve then
            if ammo.currentammo ~= desiredreserve then reservecorrections += 1 end
            ammo.currentammo = desiredreserve
        end
        local success, result = pcall(calloriginal, amount)
        if desiredreserve then ammo.currentammo = desiredreserve end
        if settings.mainclip then
            local clip = tonumber(rawget(state, "clip"))
            if clip and clip > 0 then
                if state.currentClip ~= clip then clipcorrections += 1 end
                state.currentClip = clip
            end
        end
        local clip = tonumber(rawget(state, "clip"))
        local cliplabel = rawget(state, "clipTextLabel")
        if settings.mainclip and clip and typeof(cliplabel) == "Instance" and cliplabel:IsA("TextLabel") then
            cliplabel.Text = tostring(clip) .. "/" .. tostring(clip)
        end
        local ammolabel = rawget(state, "ammotextlbl")
        if (settings.mainammo or settings.mainclip) and typeof(ammolabel) == "Instance" and ammolabel:IsA("TextLabel") then
            ammolabel.Text = "Ammo: " .. tostring(ammo.currentammo) .. "/" .. tostring(tonumber(ammo.ammobrought) or ammo.currentammo)
        end
        ammovolleys += 1
        lastammovolley = os.clock()
        ammosyncerror = success and nil or tostring(result)
        if not success then error(result, 0) end
    end
    if type(hookfunction) == "function" then
        local success, hooked = pcall(hookfunction, original, replacement)
        if success and type(hooked) == "function" then
            calloriginal = hooked
            volleyoriginals[state] = {mode = "closure", target = original, original = hooked, replacement = replacement}
            return
        end
    end
    calloriginal = original
    volleyoriginals[state] = {mode = "table", original = original, replacement = replacement}
    state.accountVolley = replacement
end

local function maintainsecondarygun(gun)
    if not settings.secondaryammo or typeof(gun) ~= "Instance" or not gun.Parent or gun:GetAttribute("Ammo") == nil then return end
    if ammooriginals[gun] == nil then ammooriginals[gun] = gun:GetAttribute("Ammo") end
    if (tonumber(gun:GetAttribute("Ammo")) or 0) < 999999 then gun:SetAttribute("Ammo", 999999) end
    watchammosignal(gun, "secondaryammo", gun:GetAttributeChangedSignal("Ammo"), function()
        if settings.secondaryammo and gun.Parent and (tonumber(gun:GetAttribute("Ammo")) or 0) < 999999 then
            gun:SetAttribute("Ammo", 999999)
        end
    end)
end

updatevolleyhooks = function()
    if settings.mainammo or settings.mainclip then
        local current = {}
        for _, state in ipairs(gunstates) do current[state] = true end
        for state in pairs(volleyoriginals) do
            if not current[state] then restorevolleyhook(state) end
        end
        for _, state in ipairs(gunstates) do installvolleyhook(state) end
    elseif next(volleyoriginals) then
        restorevolleyhooks()
    end
    local hooked = 0
    local closurehooks = 0
    for _, hook in pairs(volleyoriginals) do
        hooked += 1
        if hook.mode == "closure" then closurehooks += 1 end
    end
    if #gunstates > 0 then gunstatus = tostring(#gunstates) .. " state(s) | " .. tostring(hooked) .. " ammo hook(s), " .. tostring(closurehooks) .. " closure | " .. gundiscovery end
end

refreshammowatchers = function()
    disconnectammowatchers()
    if settings.mainammo then updatemainammo() end
    if settings.mainclip then updatemainclips() end
    if settings.secondaryammo then
        for _, state in ipairs(gunstates) do
            local guns = rawget(state, "secondaryGunBrickTbl")
            if type(guns) == "table" then
                for gunbrick in pairs(guns) do maintainsecondarygun(typeof(gunbrick) == "Instance" and gunbrick.Parent) end
            end
            local missiles = rawget(state, "secondaryMissileTbl")
            if type(missiles) == "table" then
                for _, missile in pairs(missiles) do maintainsecondarygun(missile) end
            end
        end
    end
end

local function setcrewcondition(value)
    settings.crewcondition = value
    if value and #gunstates == 0 and os.clock() - lastgunscan >= 0.5 then scangunstates() end
    local numeric = {"loaderMult", "gunnerMult", "driverMult", "commanderMult", "breechMult", "engineMult", "transMult", "radioMult", "hzMult", "vtMult", "multCannon", "leftTrackDestroyedMult", "rightTrackDestroyedMult", "DestroTorque"}
    local contexts = {shared}
    for _, state in ipairs(gunstates) do
        local context = activeammotable(state)
        if type(context) == "table" and not table.find(contexts, context) then table.insert(contexts, context) end
    end
    local modules = replicatedstorage:FindFirstChild("VehicleModuleScripts")
    local qhassis = modules and modules:FindFirstChild("QhassisV5")
    for _, name in ipairs({"Physics", "Controls"}) do
        local module = qhassis and qhassis:FindFirstChild(name)
        local success, result = false, nil
        if module then success, result = pcall(require, module) end
        local callback = success and type(result) == "table" and (result.step or result.stepHullAim)
        if type(callback) == "function" and type(getfenv) == "function" then
            local environment
            pcall(function() environment = getfenv(callback) end)
            local context = type(environment) == "table" and rawget(environment, "shared")
            if type(context) == "table" and not table.find(contexts, context) then table.insert(contexts, context) end
        end
    end
    if value then
        for _, context in ipairs(contexts) do
            local originals = creworiginals[context]
            if not originals then
                originals = {}
                creworiginals[context] = originals
            end
            for _, key in ipairs(numeric) do
                if originals[key] == nil then originals[key] = {value = context[key]} end
                local original = tonumber(originals[key].value) or 1
                context[key] = math.max(original, 1)
            end
            if originals.canCannonFire == nil then originals.canCannonFire = {value = context.canCannonFire} end
            context.canCannonFire = true
        end
    else
        for context, originals in pairs(creworiginals) do
            for key, original in pairs(originals) do context[key] = original.value end
            creworiginals[context] = nil
        end
    end
end

local function emptyshake()
end

local function restorecamerashake()
    for module, original in pairs(shakeoriginals) do
        if type(module) == "table" and type(original) == "function" then module.ShakeCam = original end
        shakeoriginals[module] = nil
    end
end

local function restorerecoilzoom()
    for value, original in pairs(recoiloriginals) do
        if typeof(value) == "Instance" and value.Parent and type(original) == "number" then value.Value = original end
        recoiloriginals[value] = nil
    end
end

local function updatecamerashake(state)
    local module = type(state) == "table" and rawget(state, "shakeModule")
    if type(module) ~= "table" or type(module.ShakeCam) ~= "function" then return end
    if not shakeoriginals[module] then shakeoriginals[module] = module.ShakeCam end
    if module.ShakeCam ~= emptyshake then module.ShakeCam = emptyshake end
end

local function setrepairmovement(value)
    settings.repairmovement = value
    runtimeclock.repairhook = 0
end

local function installrepairhook(module, key)
    if type(module) ~= "table" or type(module[key]) ~= "function" or type(hookfunction) ~= "function" then return end
    for _, hook in ipairs(repairhooks) do
        if hook.target == module[key] then return end
    end
    local target = module[key]
    local calloriginal
    local replacement = function(controller, ...)
        local chassis = type(controller) == "table" and rawget(controller, "_chassis")
        local owned = typeof(chassis) == "Instance" and chassis.Parent and (
            ownerplayer(chassis) == localplayer
            or ownername(chassis) == localplayer.Name
            or chassis == activechassis()
        )
        if not settings.repairmovement or not owned then return calloriginal(controller, ...) end
        local context = shared
        if type(getfenv) == "function" then
            local environment
            pcall(function() environment = getfenv(target) end)
            local candidate = type(environment) == "table" and rawget(environment, "shared")
            if type(candidate) == "table" then context = candidate end
        end
        local repairing = context.repairing
        local otherrepairing = context.otherRepairing
        local drivermult = context.driverMult
        local transmult = context.transMult
        local enginemult = context.engineMult
        local engine = chassis:FindFirstChild("EngineOn")
        local enginevalue = engine and engine:IsA("BoolValue") and engine.Value
        local playergui = localplayer:FindFirstChild("PlayerGui")
        local notification = playergui and playergui:FindFirstChild("ownNotif")
        local repairlabel = notification and notification:FindFirstChild("UnOtherRepairLabel")
        if repairlabel then repairlabel.Name = "SlimekrewRepairStatus" end
        context.repairing = false
        context.otherRepairing = 0
        context.driverMult = math.max(tonumber(drivermult) or 1, 1)
        context.transMult = math.max(tonumber(transmult) or 1, 1)
        context.engineMult = math.max(tonumber(enginemult) or 1, 1)
        if engine and engine:IsA("BoolValue") then engine.Value = true end
        local results = table.pack(pcall(calloriginal, controller, ...))
        context.repairing = repairing
        context.otherRepairing = otherrepairing
        context.driverMult = drivermult
        context.transMult = transmult
        context.engineMult = enginemult
        if engine and engine.Parent and enginevalue ~= nil then engine.Value = enginevalue end
        if repairlabel and repairlabel.Parent then repairlabel.Name = "UnOtherRepairLabel" end
        if not results[1] then error(results[2], 0) end
        return table.unpack(results, 2, results.n)
    end
    local success, original = pcall(hookfunction, target, replacement)
    if success and type(original) == "function" then
        calloriginal = original
        table.insert(repairhooks, {target = target, original = original})
    end
end

local function installrepairhooks()
    local modules = replicatedstorage:FindFirstChild("VehicleModuleScripts")
    local qhassis = modules and modules:FindFirstChild("QhassisV5")
    if not qhassis then return end
    for _, entry in ipairs({{"Physics", "step"}, {"Controls", "stepHullAim"}}) do
        local module = qhassis:FindFirstChild(entry[1])
        local success, result = false, nil
        if module then success, result = pcall(require, module) end
        if success then installrepairhook(result, entry[2]) end
    end
end

local function restorerepairhooks()
    if type(hookfunction) ~= "function" then return end
    for _, hook in ipairs(repairhooks) do pcall(hookfunction, hook.target, hook.original) end
    table.clear(repairhooks)
end

local function updaterepairmovement()
    if not settings.repairmovement or #repairhooks >= 2 then return end
    local now = os.clock()
    if now - (runtimeclock.repairhook or 0) < 2 then return end
    runtimeclock.repairhook = now
    installrepairhooks()
end

local function updategunmods(delta)
    if not settings.reload and not settings.noreload and not settings.norecoil and not settings.nooverheat and not settings.crewcondition and not settings.nocamerashake and not settings.norecoilzoom and not settings.mainammo and not settings.mainclip and not settings.secondaryammo then return end
    local needgunstates = settings.reload or settings.noreload or settings.norecoil or settings.nooverheat or settings.nocamerashake or settings.mainammo or settings.mainclip or settings.secondaryammo or settings.crewcondition
    if needgunstates and #gunstates == 0 and os.clock() - lastgunscan >= 1 then
        scangunstates()
    end
    local stateschanged = false
    for index = #gunstates, 1, -1 do
        local state = gunstates[index]
        local chassis = type(state) == "table" and rawget(state, "chassis")
        if type(state) ~= "table" or typeof(chassis) ~= "Instance" or not chassis.Parent or not validgunstate(state) then
            restorevolleyhook(state)
            table.remove(gunstates, index)
            stateschanged = true
        else
            if settings.secondaryammo then
                local guns = rawget(state, "secondaryGunBrickTbl")
                if type(guns) == "table" then
                    for gunbrick in pairs(guns) do
                        local gun = typeof(gunbrick) == "Instance" and gunbrick.Parent
                        maintainsecondarygun(gun)
                    end
                end
                local missiles = rawget(state, "secondaryMissileTbl")
                if type(missiles) == "table" then
                    for _, missile in pairs(missiles) do maintainsecondarygun(missile) end
                end
            end
            if settings.mainammo or settings.mainclip then installvolleyhook(state) end
            if settings.reload and type(rawget(state, "reloading")) == "number" and state.reloading > 0 then
                state.reloading = math.max(state.reloading - delta * (settings.reloadmult - 1), 0)
            end
            if settings.noreload and type(rawget(state, "reloading")) == "number" then state.reloading = -1 end
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
            if settings.nocamerashake then updatecamerashake(state) end
        end
    end
    if stateschanged then refreshammowatchers() end
    updatemainclips()
    if settings.mainammo then
        updatemainammo()
    elseif mainammooriginal ~= nil then
        restoremainammo()
    end
    if not settings.mainammo and not settings.mainclip and next(volleyoriginals) then restorevolleyhooks() end
    if settings.norecoil then runtimeclock.updaterecoil(false) end
    if settings.norecoilzoom then
        local value = shared.recoilZoom
        if typeof(value) == "Instance" and value:IsA("NumberValue") then
            if recoiloriginals[value] == nil then recoiloriginals[value] = value.Value end
            value.Value = 0
        end
    end
    if settings.crewcondition then
        runtimeclock.crew = (runtimeclock.crew or 0) + delta
        if runtimeclock.crew >= 0.5 then
            runtimeclock.crew = 0
            setcrewcondition(true)
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
    trajectoryscript = module
    runtrajectory = function(arguments, context)
        if library.Unloaded then return end
        local thread = coroutine.running()
        if thread then trajectorythreads[thread] = context end
        local results = table.pack(pcall(oldtrajectory, table.unpack(arguments, 1, arguments.n)))
        if thread then trajectorythreads[thread] = nil end
        if not results[1] then error(results[2], 0) end
        return table.unpack(results, 2, results.n)
    end
    local replacement
    replacement = function(...)
        local arguments = table.pack(...)
        local gunbrick = arguments[12]
        local shell = arguments[11]
        local range = projectilerange(shell)
        local category = arguments[14]
        local shouldaim = settings.silentaim or settings.homingshells and category == "Main"
        if settings.nospread and typeof(gunbrick) == "Instance" and gunbrick:IsA("BasePart") then
            arguments[2] = gunbrick.CFrame.LookVector
        end
        if shouldaim and type(findtarget) == "function" then
            currenttarget, currenttargetpart, currenttargetoffset = findtarget(arguments[4], arguments[1])
            currenttargetoffset = currenttargetoffset or Vector3.zero
            local targetdata = currenttarget and vehicles[currenttarget]
            currenttargetacceleration = targetdata and targetdata.acceleration or Vector3.zero
            currentaccelerationconfidence = targetdata and targetdata.accelerationconfidence or 0
        end
        local validtarget = currenttarget and currenttarget.Parent and currenttargetpart and currenttargetpart.Parent
            and not partdestroyed(currenttargetpart, currenttarget)
        if shouldaim and validtarget then
            local inherited = typeof(arguments[7]) == "Vector3" and arguments[7] or Vector3.zero
            if settings.silentaim then
                inherited = Vector3.zero
                arguments[7] = inherited
            end
            local guided = category == "Main" and settings.homingshells or category == "Missile" and typeof(shell) == "Instance" and (
                shell:GetAttribute("Homing") == true
                or shell:GetAttribute("RadarCue") == true
                or shell:FindFirstChild("ATGMType") ~= nil
                or typeof(gunbrick) == "Instance" and gunbrick:GetAttribute("irlock") == true
            )
            local direction
            if guided and currenttargetpart and typeof(arguments[4]) == "Vector3" then
                direction = predictdirection(arguments[4], arguments[3], arguments[6], inherited, range)
                local aimposition = currenttargetpart.CFrame:PointToWorldSpace(currenttargetoffset)
                local ownsresult = solvertarget == currenttarget and solverpart == currenttargetpart
                local targetpoint = ownsresult and predictedpoint or aimposition
                local offset = targetpoint - arguments[4]
                if solverstatus ~= "out of range" then
                    if category ~= "Main" then
                        arguments[15] = currenttargetpart
                        arguments[16] = currenttargetpart.CFrame:ToObjectSpace(CFrame.new(aimposition))
                    end
                    solverstatus = category == "Main" and "guided launch" or "guided"
                    solverdistance = offset.Magnitude
                    predictedpoint = targetpoint
                end
            else
                direction = predictdirection(arguments[4], arguments[3], arguments[6], inherited, range)
            end
            if direction then arguments[2] = direction end
            local chassis = arguments[1]
            local origin = arguments[4]
            if typeof(chassis) == "Instance" and chassis:IsA("Model") and typeof(origin) == "Vector3" then
                trajectorycache = {
                    chassis = chassis,
                    localorigin = chassis:GetPivot():PointToObjectSpace(origin),
                    speed = arguments[3],
                    gravity = arguments[6],
                    inheritedvelocity = inherited,
                    guided = guided,
                    range = range,
                    clock = os.clock(),
                }
            end
        end
        local configured = math.clamp(math.floor(tonumber(settings.projectilecount) or 0), 0, 20)
        local count = settings.multiprojectiles and arguments[14] == "Main" and math.max(configured, 1) or 1
        local context = {arguments = arguments, passed = {}, continuations = 0, remaining = range}
        local results = table.pack(runtrajectory(arguments, context))
        if settings.advancedhud and not context.hitmarked and runtimeclock.showmiss then runtimeclock.showmiss() end
        for _ = 2, count do
            if settings.componentpassthrough then
                task.spawn(runtrajectory, arguments, {arguments = arguments, passed = {}, continuations = 0, remaining = range})
            else
                task.spawn(oldtrajectory, table.unpack(arguments, 1, arguments.n))
            end
        end
        return table.unpack(results, 1, results.n)
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
        predictioncircle.NumSides = 36
        predictioncircle.Radius = settings.predictionradius
        predictioncircle.Transparency = 0.9
        predictioncircle.Visible = false

        runtimeclock.impactmarker = Drawing.new("Circle")
        runtimeclock.impactmarker.Filled = true
        runtimeclock.impactmarker.NumSides = 24
        runtimeclock.impactmarker.Radius = 4
        runtimeclock.impactmarker.Transparency = 0.9
        runtimeclock.impactmarker.Visible = false

        runtimeclock.damagereticlelines = {}
        for _ = 1, 4 do
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Visible = false
            table.insert(runtimeclock.damagereticlelines, line)
        end

        targetbox = Drawing.new("Square")
        targetbox.Filled = true
        targetbox.Color = Color3.fromRGB(20, 21, 25)
        targetbox.Size = Vector2.new(240, 108)
        targetbox.Transparency = 0.88

        for _ = 1, 4 do
            local line = Drawing.new("Line")
            line.Thickness = 1
            targetlines[#targetlines + 1] = line
        end

        for index = 1, 6 do
            local text = Drawing.new("Text")
            text.Size = 13
            text.Font = 2
            text.Color = Color3.fromRGB(240, 240, 245)
            text.Outline = true
            targettexts[index] = text
        end

        targetframe = Instance.new("CanvasGroup")
        targetframe.Name = "TargetHUD"
        targetframe.AnchorPoint = Vector2.new(0, 0.5)
        targetframe.BackgroundColor3 = Color3.new(1, 1, 1)
        targetframe.BackgroundTransparency = 0
        targetframe.Position = UDim2.new(0, 18, 0.5, 0)
        targetframe.Size = UDim2.fromOffset(252, 154)
        targetframe.GroupTransparency = 1
        targetframe.Visible = false
        targetframe.ZIndex = 40
        targetframe.Parent = library.ScreenGui
        targetscale = Instance.new("UIScale")
        targetscale.Scale = 0.94
        targetscale.Parent = targetframe
        local backgroundgradient = Instance.new("UIGradient")
        backgroundgradient.Color = ColorSequence.new(Color3.fromRGB(7, 9, 15), Color3.fromRGB(20, 25, 38))
        backgroundgradient.Rotation = 18
        backgroundgradient.Parent = targetframe
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = targetframe
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.2
        stroke.Transparency = 0.08
        stroke.Parent = targetframe
        targetstrokegradient = Instance.new("UIGradient")
        targetstrokegradient.Color = ColorSequence.new(library.GradientStartColor, library.GradientEndColor)
        targetstrokegradient.Parent = stroke
        local rail = Instance.new("Frame")
        rail.BackgroundColor3 = Color3.new(1, 1, 1)
        rail.BorderSizePixel = 0
        rail.Position = UDim2.fromOffset(4, 7)
        rail.Size = UDim2.fromOffset(2, 18)
        rail.ZIndex = 42
        rail.Parent = targetframe
        local railcorner = Instance.new("UICorner")
        railcorner.CornerRadius = UDim.new(1, 0)
        railcorner.Parent = rail
        targetrailgradient = Instance.new("UIGradient")
        targetrailgradient.Color = ColorSequence.new(Color3.fromRGB(41, 103, 255), Color3.fromRGB(83, 205, 255))
        targetrailgradient.Rotation = 90
        targetrailgradient.Parent = rail
        local header = Instance.new("Frame")
        header.BackgroundTransparency = 1
        header.BorderSizePixel = 0
        header.Size = UDim2.new(1, 0, 0, 32)
        header.ZIndex = 41
        header.Parent = targetframe
        local divider = Instance.new("Frame")
        divider.BackgroundColor3 = Color3.fromRGB(55, 57, 66)
        divider.BorderSizePixel = 0
        divider.Position = UDim2.new(0, 0, 1, -1)
        divider.Size = UDim2.new(1, 0, 0, 1)
        divider.ZIndex = 42
        divider.Parent = header
        for index = 1, 40 do
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Code
            label.TextColor3 = Color3.fromRGB(238, 239, 244)
            label.TextSize = index == 1 and 14 or 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Position = index == 1 and UDim2.fromOffset(11, 0) or UDim2.fromOffset(11, 35 + (index - 2) * 18)
            label.Size = UDim2.new(1, -22, 0, index == 1 and 32 or 18)
            label.ZIndex = 43
            label.Parent = index == 1 and header or targetframe
            local gradient = Instance.new("UIGradient")
            gradient.Enabled = false
            gradient.Parent = label
            targetguitexts[index] = label
            targettextgradients[index] = gradient
        end
    end)
    if not success then
        for _, drawing in ipairs({fovcircle, snapline, predictioncircle, runtimeclock.impactmarker, targetbox}) do pcall(function() drawing:Remove() end) end
        for _, drawing in ipairs(runtimeclock.damagereticlelines or {}) do pcall(function() drawing:Remove() end) end
        for _, text in ipairs(targettexts) do pcall(function() text:Remove() end) end
        for _, line in ipairs(targetlines) do pcall(function() line:Remove() end) end
        fovcircle = nil
        snapline = nil
        predictioncircle = nil
        runtimeclock.impactmarker = nil
        runtimeclock.damagereticlelines = nil
        targetbox = nil
        if targetframe then targetframe:Destroy() end
        targetframe = nil
        table.clear(targettexts)
        table.clear(targetlines)
        table.clear(targetguitexts)
        table.clear(targettextgradients)
    end
end

runtimeclock.showdamagereticle = function(result, vehicle)
    if not result then return end
    runtimeclock.impactposition = result.Position
    runtimeclock.impactvehicle = vehicle
    runtimeclock.impactpart = partcategory(result.Instance, vehicle) or result.Instance.Name
    runtimeclock.impactstatus = "HIT"
    runtimeclock.impactclock = os.clock()
    runtimeclock.damagereticleuntil = os.clock() + 0.42
    if os.clock() - (runtimeclock.lastimpactnotify or 0) >= 0.2 then
        runtimeclock.lastimpactnotify = os.clock()
        library:Notify({
            Title = "Shell Hit",
            Description = tostring(ownername(vehicle) or vehicle.Name) .. " | " .. tostring(runtimeclock.impactpart),
            Time = 2.5,
        })
    end
end

runtimeclock.showmiss = function()
    runtimeclock.impactposition = nil
    runtimeclock.impactvehicle = nil
    runtimeclock.impactpart = nil
    runtimeclock.impactstatus = "MISS"
    runtimeclock.impactclock = os.clock()
end

runtimeclock.updatedamagereticle = function(delta)
    local lines = runtimeclock.damagereticlelines
    if not lines then return end
    local point, onscreen
    if runtimeclock.impactposition then point, onscreen = camera:WorldToViewportPoint(runtimeclock.impactposition) end
    local showing = settings.advancedhud and os.clock() < (runtimeclock.damagereticleuntil or 0) and onscreen and point.Z > 0
    local target = showing and 1 or 0
    runtimeclock.damagereticlealpha = (runtimeclock.damagereticlealpha or 0) + (target - (runtimeclock.damagereticlealpha or 0)) * math.clamp(delta * (showing and 24 or 10), 0, 1)
    local alpha = runtimeclock.damagereticlealpha
    local center = showing and Vector2.new(point.X, point.Y) or runtimeclock.damagereticleposition or camera.ViewportSize * 0.5
    if showing then runtimeclock.damagereticleposition = center end
    local spread = 5 + (1 - alpha) * 5
    local length = 7
    local points = {
        {Vector2.new(-spread - length, -spread - length), Vector2.new(-spread, -spread)},
        {Vector2.new(spread + length, -spread - length), Vector2.new(spread, -spread)},
        {Vector2.new(-spread - length, spread + length), Vector2.new(-spread, spread)},
        {Vector2.new(spread + length, spread + length), Vector2.new(spread, spread)},
    }
    local startcolor = library.GradientStartColor or Color3.new(1, 1, 1)
    local endcolor = library.GradientEndColor or startcolor
    local phase = (math.sin(gradientclock * 2.2) + 1) * 0.5
    for index, line in ipairs(lines) do
        line.From = center + points[index][1]
        line.To = center + points[index][2]
        line.Color = startcolor:Lerp(endcolor, (phase + index * 0.18) % 1)
        line.Transparency = alpha
        line.Visible = alpha > 0.01
    end
end

findtarget = function(origin, ignored)
    if not settings.fov and not settings.silentaim and not settings.homingshells then return end
    local center = userinputservice:GetMouseLocation()
    local visibilityorigin = finitevector(origin) and origin or camera.CFrame.Position

    local function candidate(vehicle, data, part, margin)
        if not vehicle or not data or not part or not part.Parent or not vehicle.Parent or not data.part.Parent or friendly(vehicle) then return end
        if partdestroyed(part, vehicle) then return end
        if (camera.CFrame.Position - data.part.Position).Magnitude > settings.renderdistance then return end
        local aimoffset = Vector3.zero
        local aimposition = part.Position
        local point, onscreen = camera:WorldToViewportPoint(aimposition)
        if settings.silentvisiblecheck and not rayvisiblefrom(visibilityorigin, part, vehicle, aimposition, ignored) then
            local half = part.Size * 0.45
            local offsets = {
                Vector3.new(half.X, 0, 0),
                Vector3.new(-half.X, 0, 0),
                Vector3.new(0, half.Y, 0),
                Vector3.new(0, -half.Y, 0),
                Vector3.new(0, 0, half.Z),
                Vector3.new(0, 0, -half.Z),
            }
            local bestdistance = math.huge
            local found = false
            for _, offset in ipairs(offsets) do
                local world = part.CFrame:PointToWorldSpace(offset)
                local sample, visible = camera:WorldToViewportPoint(world)
                local distance = visible and sample.Z > 0 and (Vector2.new(sample.X, sample.Y) - center).Magnitude or math.huge
                if distance < bestdistance and rayvisiblefrom(visibilityorigin, part, vehicle, world, ignored) then
                    aimoffset = offset
                    aimposition = world
                    point = sample
                    onscreen = visible
                    bestdistance = distance
                    found = true
                end
            end
            if not found then return end
        end
        if not onscreen or point.Z <= 0 then return end
        local screen = (Vector2.new(point.X, point.Y) - center).Magnitude
        if screen > settings.fovsize * (margin or 1) then return end
        local category = partcategory(part, vehicle)
        local priority = settings.targetpriority == "Lowest Health" and parthealthratio(part, vehicle) or 0
        if settings.targetpriority ~= "Screen" and settings.targetpriority ~= "Lowest Health" and category ~= settings.targetpriority then
            priority = 1
        end
        local edge = camera:WorldToViewportPoint(aimposition + camera.CFrame.RightVector * part.Size.Magnitude * 0.5)
        local projectedradius = math.abs(edge.X - point.X)
        local score = screen - math.clamp(projectedradius * 0.15, 0, 12)
        return screen, priority, score, aimoffset
    end

    local currentdata = currenttarget and vehicles[currenttarget]
    local currentscreen, currentpriority, currentscore, currentoffset = candidate(currenttarget, currentdata, currenttargetpart, 1.15)
    if settings.targetlock and currentscreen then return currenttarget, currenttargetpart, currentoffset end

    if settings.targetlock and currenttarget and currentdata and currenttarget.Parent and currentdata.part.Parent and not friendly(currenttarget) then
        local lockedpart
        local lockedoffset
        local lockedscore = settings.fovsize
        local lockedpriority = math.huge
        for _, part in ipairs(targetparts(currenttarget, currentdata)) do
            local screen, priority, score, offset = candidate(currenttarget, currentdata, part, 1.15)
            if screen and (priority < lockedpriority or priority == lockedpriority and score <= lockedscore) then
                lockedpart = part
                lockedoffset = offset
                lockedscore = score
                lockedpriority = priority
            end
        end
        if lockedpart then
            if lockedpart ~= currenttargetpart then lasttargetchange = os.clock() end
            return currenttarget, lockedpart, lockedoffset
        end
    end

    local bestvehicle
    local bestpart
    local bestoffset
    local bestscore = settings.fovsize
    local bestpriority = math.huge
    for vehicle, data in pairs(vehicles) do
        if vehicle.Parent and data.part.Parent and not friendly(vehicle) then
            for _, part in ipairs(targetparts(vehicle, data)) do
                local screen, priority, score, offset = candidate(vehicle, data, part)
                if screen and (priority < bestpriority or priority == bestpriority and score <= bestscore) then
                    bestvehicle = vehicle
                    bestpart = part
                    bestoffset = offset
                    bestscore = score
                    bestpriority = priority
                end
            end
        end
    end

    if settings.targethysteresis and currentscreen and bestvehicle then
        local threshold = math.max(3, currentscreen * 0.15)
        local prioritymargin = settings.targetpriority == "Lowest Health" and 0.05 or 0
        local challengerisbetter = bestpriority < currentpriority - prioritymargin or math.abs(bestpriority - currentpriority) <= prioritymargin and bestscore < currentscore - threshold
        if not challengerisbetter or os.clock() - lasttargetchange < 0.2 then return currenttarget, currenttargetpart, currentoffset end
    end
    if bestvehicle ~= currenttarget or bestpart ~= currenttargetpart then lasttargetchange = os.clock() end
    return bestvehicle, bestpart, bestoffset
end

local function updatetargeting(delta)
    gradientclock += delta
    local viewport = camera.ViewportSize
    local center = userinputservice:GetMouseLocation()
    local needtarget = settings.silentaim or settings.homingshells or settings.snaplines or settings.targethud or settings.predictionmarker
    if not settings.fov and not needtarget and targetalpha <= 0 then
        currenttarget = nil
        currenttargetpart = nil
        if fovcircle then fovcircle.Visible = false end
        if snapline then snapline.Visible = false end
        if predictioncircle then predictioncircle.Visible = false end
        if runtimeclock.impactmarker then runtimeclock.impactmarker.Visible = false end
        if targetbox then targetbox.Visible = false end
        if targetframe then targetframe.Visible = false end
        return
    end

    runtimeclock.target = (runtimeclock.target or 1) + delta
    if needtarget and (runtimeclock.target >= 1 / 12 or currenttargetpart and not currenttargetpart.Parent) then
        currenttarget, currenttargetpart, currenttargetoffset = findtarget()
        currenttargetoffset = currenttargetoffset or Vector3.zero
        runtimeclock.target = 0
    elseif not needtarget and currenttarget then
        currenttarget = nil
        currenttargetpart = nil
        currenttargetoffset = Vector3.zero
    end
    local targetdata = currenttarget and vehicles[currenttarget]
    currenttargetacceleration = targetdata and targetdata.acceleration or Vector3.zero
    currentaccelerationconfidence = targetdata and targetdata.accelerationconfidence or 0
    if not currenttargetpart then
        predictedpoint = nil
        solvertarget = nil
        solverpart = nil
        visualtarget = nil
        visualpart = nil
        visualoffset = Vector3.zero
        solverstatus = "idle"
        solvertime = nil
        solverdistance = nil
        solverrange = nil
        solverdropscale = nil
        solverquality = nil
        solverconfidence = nil
    end
    if trajectorycache and (not trajectorycache.chassis.Parent or os.clock() - trajectorycache.clock > 2) then
        trajectorycache = nil
    end
    local wantsvisualsolve = settings.predictionmarker or settings.targethud
    local targetchanged = currenttarget ~= visualtarget or currenttargetpart ~= visualpart or currenttargetoffset ~= visualoffset
    if currenttargetpart and trajectorycache and wantsvisualsolve and (targetchanged or os.clock() - lastvisualsolve >= 0.08) then
        local chassis = trajectorycache.chassis
        local origin = chassis:GetPivot():PointToWorldSpace(trajectorycache.localorigin)
        if trajectorycache.guided then
            predictdirection(origin, trajectorycache.speed, trajectorycache.gravity, trajectorycache.inheritedvelocity, trajectorycache.range)
            if predictedpoint then
                solverstatus = "guided"
                solverdistance = (currenttargetpart.CFrame:PointToWorldSpace(currenttargetoffset) - origin).Magnitude
            end
        else
            predictdirection(origin, trajectorycache.speed, trajectorycache.gravity, trajectorycache.inheritedvelocity, trajectorycache.range)
        end
        lastvisualsolve = os.clock()
        visualtarget = currenttarget
        visualpart = currenttargetpart
        visualoffset = currenttargetoffset
    elseif currenttargetpart and not trajectorycache and wantsvisualsolve then
        predictedpoint = nil
        solvertarget = nil
        solverpart = nil
        solverstatus = "awaiting shot"
        solvertime = nil
        solverdistance = nil
        solverrange = nil
        solverdropscale = nil
        solverquality = nil
        solverconfidence = nil
    end
    if not fovcircle or not snapline or not targetbox then return end
    fovcircle.Position = center
    fovcircle.Radius = settings.fovsize
    local fovdrawcolor = settings.fovcolor
    if settings.fovgradient then
        local startcolor = library.GradientStartColor or settings.fovcolor
        local endcolor = library.GradientEndColor or startcolor
        local duration = math.max(tonumber(library.GradientCycleDuration) or 4, 0.1)
        local phase = (math.sin(gradientclock * math.pi * 2 / duration - math.pi / 2) + 1) * 0.5
        fovdrawcolor = startcolor:Lerp(endcolor, phase)
    end
    fovcircle.Color = fovdrawcolor
    fovcircle.Visible = settings.fov
    if predictioncircle then
        local markerpoint, markervisible
        if predictedpoint then markerpoint, markervisible = camera:WorldToViewportPoint(predictedpoint) end
        local ownsresult = solvertarget == currenttarget and solverpart == currenttargetpart
        predictioncircle.Visible = settings.predictionmarker and settings.silentaim and ownsresult and predictedpoint ~= nil and markervisible and markerpoint.Z > 0 or false
        if predictioncircle.Visible then
            predictioncircle.Position = Vector2.new(markerpoint.X, markerpoint.Y)
            predictioncircle.Color = settings.predictioncolor
            predictioncircle.Radius = settings.predictionradius
        end
        if runtimeclock.impactmarker then
            local impactrecent = runtimeclock.impactposition and os.clock() - (runtimeclock.impactclock or 0) < 2
            local impactpoint = impactrecent and runtimeclock.impactposition or predictedpoint
            if impactpoint then markerpoint, markervisible = camera:WorldToViewportPoint(impactpoint) end
            runtimeclock.impactmarker.Visible = settings.advancedhud and (impactrecent or ownsresult) and impactpoint ~= nil and markervisible and markerpoint.Z > 0 or false
            if runtimeclock.impactmarker.Visible then
                local startcolor = library.GradientStartColor or settings.predictioncolor
                local endcolor = library.GradientEndColor or startcolor
                runtimeclock.impactmarker.Position = Vector2.new(markerpoint.X, markerpoint.Y)
                runtimeclock.impactmarker.Color = startcolor:Lerp(endcolor, (math.sin(gradientclock * 2) + 1) * 0.5)
            end
        end
    end
    if currenttarget and currenttargetpart then
        hudtarget = currenttarget
        hudtargetpart = currenttargetpart
        hudtargetoffset = currenttargetoffset
    end
    local displaytarget = currenttarget or hudtarget
    local displaypart = currenttargetpart or hudtargetpart
    local displayoffset = currenttargetpart and currenttargetoffset or hudtargetoffset
    local data = displaytarget and vehicles[displaytarget]
    local currentdata = currenttarget and vehicles[currenttarget]
    local point, onscreen
    if currentdata and currenttargetpart then
        point, onscreen = camera:WorldToViewportPoint(currenttargetpart.CFrame:PointToWorldSpace(displayoffset))
    end
    local hastarget = currentdata and currenttargetpart and onscreen and point.Z > 0

    snapline.Visible = settings.snaplines and settings.fov and hastarget or false
    if snapline.Visible then
        snapline.From = center
        snapline.To = Vector2.new(point.X, point.Y)
        snapline.Color = settings.snaplinecolor
    end

    local showtarget = settings.targethud and settings.fov and hastarget or false
    local targetspeed = showtarget and 9 or 12
    targetalpha += ((showtarget and 1 or 0) - targetalpha) * math.clamp(delta * targetspeed, 0, 1)
    if math.abs(targetalpha - (showtarget and 1 or 0)) < 0.01 then targetalpha = showtarget and 1 or 0 end
    targetbox.Visible = false
    for _, text in ipairs(targettexts) do text.Visible = false end
    for _, line in ipairs(targetlines) do line.Visible = false end
    if targetframe then
        local visualalpha = targetalpha * targetalpha * (3 - 2 * targetalpha)
        targetframe.Visible = targetalpha > 0.001
        targetframe.GroupTransparency = 1 - visualalpha
        targetframe.Position = UDim2.new(0, 18 - (1 - visualalpha) * 18, 0.5, (1 - visualalpha) * 8)
        if targetscale then targetscale.Scale = 0.9 + visualalpha * 0.1 end
    end
    if targetframe and targetframe.Visible and data and data.part.Parent and displaypart and displaypart.Parent then
        local fontcolor = Color3.fromRGB(242, 243, 247)
        local impactrecent = os.clock() - (runtimeclock.impactclock or 0) < 2
        local confirmedimpact = impactrecent and runtimeclock.impactstatus == "HIT" and runtimeclock.impactvehicle == displaytarget
        local missedimpact = impactrecent and runtimeclock.impactstatus == "MISS"
        local impactready = predictedpoint and solvertarget == displaytarget and solverpart == displaypart
        local impacttext = confirmedimpact and ("HIT · " .. tostring(runtimeclock.impactpart or "Vehicle")) or missedimpact and "MISS" or impactready and "Predicted" or "Awaiting shot"
        local entries = {
            {text = "Mossad Agent Detector", gradient = "blue"},
            {text = displaytarget.Name, color = fontcolor},
            {text = "Owner: " .. tostring(ownername(displaytarget) or "Unknown"), color = Color3.fromRGB(190, 192, 200)},
            {text = "Target: " .. displaypart.Name, gradient = "blue"},
            {text = "Impact: " .. impacttext, gradient = confirmedimpact and "green" or missedimpact and "red" or impactready and "blue" or "red"},
            {text = "Estimated travel: " .. (solvertime and string.format("%.2fs", solvertime) or "--"), color = Color3.fromRGB(190, 192, 200)},
            {text = "Modules", gradient = "blue"},
        }
        if not data.hudmodules or os.clock() >= (data.nexthudmodulescan or 0) then
            data.hudmodules = selectedmodules(displaytarget)
            data.nexthudmodulescan = os.clock() + 1.25
        end
        for _, module in ipairs(data.hudmodules) do
            if #entries >= #targetguitexts then break end
            local current = module.health and math.max(math.floor(module.health + 0.5), 0) or "?"
            local maximum = module.total and math.max(math.floor(module.total + 0.5), 0) or "?"
            table.insert(entries, {text = "    " .. module.name .. ": " .. tostring(current) .. "/" .. tostring(maximum), gradient = module.health ~= nil and module.health <= 0 and "red" or "green"})
        end
        if #entries == 7 then table.insert(entries, {text = "    No selected modules", color = Color3.fromRGB(190, 192, 200)}) end
        if settings.predictiondiagnostics then
            table.insert(entries, {text = "Trajectory: " .. solverstatus .. (solvertime and string.format(" | %.2fs", solvertime) or ""), color = Color3.fromRGB(190, 192, 200)})
        end
        local visiblecount = math.min(#entries, #targetguitexts)
        targetframe.Size = UDim2.fromOffset(252, math.max(86, 40 + (visiblecount - 1) * 16))
        for index, label in ipairs(targetguitexts) do
            local entry = entries[index]
            label.Visible = entry ~= nil
            if entry then
                label.Text = entry.text
                local gradient = targettextgradients[index]
                gradient.Enabled = entry.gradient ~= nil
                if entry.gradient == "blue" then
                    gradient.Color = ColorSequence.new(Color3.fromRGB(48, 112, 255), Color3.fromRGB(91, 210, 255))
                elseif entry.gradient == "green" then
                    gradient.Color = ColorSequence.new(Color3.fromRGB(48, 212, 116), Color3.fromRGB(135, 255, 190))
                elseif entry.gradient == "red" then
                    gradient.Color = ColorSequence.new(Color3.fromRGB(255, 62, 82), Color3.fromRGB(255, 148, 158))
                end
                label.TextColor3 = entry.gradient and Color3.new(1, 1, 1) or entry.color or fontcolor
                if index > 1 then label.Position = UDim2.fromOffset(11, 34 + (index - 2) * 16) end
            end
        end
        if targetstrokegradient then
            targetstrokegradient.Color = ColorSequence.new(library.GradientStartColor, library.GradientEndColor)
            targetstrokegradient.Offset = Vector2.new(-math.cos(gradientclock * 1.5), 0)
        end
        local gradientoffset = Vector2.new(math.sin(gradientclock * 1.65), 0)
        if targetrailgradient then targetrailgradient.Offset = gradientoffset end
        for _, gradient in ipairs(targettextgradients) do
            if gradient.Enabled then gradient.Offset = gradientoffset end
        end
    end
    if targetalpha == 0 then
        hudtarget = nil
        hudtargetpart = nil
        hudtargetoffset = Vector3.zero
    end
end

--// loading

do
local loading = library:CreateLoading({Title = "slimekrew", Icon = icon, LoadingIcon = "loader-circle", TotalSteps = 2, ShowSidebar = false})
loading:SetMessage("Cursed Tank")
loading:SetDescription("Preparing vehicle targeting")
loading:SetCurrentStep(1)
task.wait(1)
local setupsuccess, setuperror = pcall(function()
    makedrawings()
    hooksilentaim()
end)
if not setupsuccess then
    warn("Cursed Tank targeting setup failed: " .. tostring(setuperror))
end
loading:SetMessage("Ready")
loading:SetDescription(setupsuccess and "Vehicle systems loaded" or "Loaded with targeting setup warnings")
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
    vehicle = window:AddTab("Vehicle", "car"),
    visuals = window:AddTab("Visuals", "eye"),
    misc = window:AddTab("Misc", "wrench"),
    settings = window:AddTab("Settings", "settings"),
}

tabs.settings:AddLeftTabbox("Menu")
loading:Continue()

--// ui

do
local targetingbox = tabs.main:AddLeftTabbox("Targeting")
local silentaim = targetingbox:AddTab("Silent Aim")
local targeting = targetingbox:AddTab("FOV")
local modificationsbox = tabs.main:AddRightTabbox("Modifications")
local modifications = modificationsbox:AddTab("Ballistics")
local fovtoggle
silentaim:AddToggle("SilentAim", {Text = "Silent Aim", Callback = function(value)
    settings.silentaim = value
    if value then
        settings.targethysteresis = true
        settings.accelerationprediction = true
        settings.angularprediction = true
        settings.groundstabilization = true
        settings.latencyprediction = true
        settings.adaptiverefinement = true
        hooksilentaim()
        if fovtoggle and not settings.fov then fovtoggle:SetValue(true) end
    end
end})
silentaim:AddToggle("SilentVisibleCheck", {Text = "Visible Check", Callback = function(value) settings.silentvisiblecheck = value end})
silentaim:AddToggle("TargetLock", {Text = "Target Lock", Tooltip = "Keeps the current valid target until it leaves the expanded FOV or becomes obstructed.", Callback = function(value) settings.targetlock = value end})
    :AddKeyPicker("TargetLockKey", {Default = "T", SyncToggleState = true, Mode = "Toggle", Text = "Target Lock"})
silentaim:AddToggle("PredictionVisualizer", {Text = "Prediction Visualizer Circle", Tooltip = "Shows the predicted future target position used for motion lead.", Callback = function(value) settings.predictionmarker = value end})
    :AddColorPicker("PredictionVisualizerColor", {Default = settings.predictioncolor, Title = "Prediction Visualizer", Callback = function(value) settings.predictioncolor = value end})
silentaim:AddToggle("ShellTrail", {Text = "Shell Trail", Callback = function(value)
    settings.shelltrail = value
    updateshelltrails()
end}):AddColorPicker("ShellTrailColor", {Default = settings.shelltrailcolor, Title = "Shell Trail", Callback = function(value)
    settings.shelltrailcolor = value
    updateshelltrails()
end})
silentaim:AddSlider("TrajectoryRefinement", {Text = "Trajectory Refinement", Min = 1, Max = 8, Default = 5, Rounding = 0, Tooltip = "Higher values use more samples when solving moving-target interception and projectile drop.", Callback = function(value) settings.refinement = value end})
silentaim:AddSlider("PredictionStrength", {Text = "Prediction Strength", Min = 0.25, Max = 1.25, Default = 0.8, Rounding = 2, Suffix = "x", Tooltip = "Scales target motion lead without changing ballistic drop or shooter-velocity compensation.", Callback = function(value) settings.predictionstrength = value end})
silentaim:AddMultiDropdown("SilentHitParts", {Text = "Hit Parts", Values = hitpartnames, Default = {"Ammo", "Engine", "Crew"}, Callback = function(value) settings.hitparts = value; invalidatetargetparts() end})
silentaim:AddToggle("TargetFallback", {Text = "Fallback to Hull", Tooltip = "Uses the vehicle hull only when no enabled, intact component is available.", Callback = function(value) settings.targetfallback = value; invalidatetargetparts() end})
silentaim:AddDropdown("TargetPriority", {Text = "Target Priority", Values = {"Screen", "Ammo", "Engine", "Crew", "Turret", "Lowest Health"}, Default = "Screen", Callback = function(value) settings.targetpriority = value end})
silentaim:AddToggle("AdvancedHUD", {Text = "Advanced HUD", Tooltip = "Combines the Target HUD, confirmed impact marker, hit reticles, notifications, and trajectory details.", Callback = function(value)
    settings.advancedhud = value
    settings.targethud = value
    settings.impactmarker = value
    settings.damagereticles = value
    settings.predictiondiagnostics = value
    if value then
        hooksilentaim()
        hooktrajectoryraycast()
    else
        runtimeclock.damagereticleuntil = 0
    end
end})
modifications:AddToggle("NoSpread", {Text = "No Spread", Callback = function(value) settings.nospread = value; if value then hooksilentaim() end end})
modifications:AddToggle("MultiProjectileShells", {Text = "Multi-Projectile Shells", Tooltip = "Runs multiple main-shell trajectories for each cannon shot.", Callback = function(value)
    settings.multiprojectiles = value
    if value then hooksilentaim() end
end})
    :AddSlider("ProjectileCount", {Text = "Projectiles Per Shot", Min = 0, Max = 20, Default = 2, Rounding = 0, Tooltip = "Zero uses the normal single projectile without duplication.", Callback = function(value) settings.projectilecount = value end})
modifications:AddToggle("TerrainPenetration", {Text = "Ignore Terrain", Tooltip = "Excludes workspace terrain from main trajectory raycasts while retaining vehicle and constructed-object collisions.", Callback = function(value)
    settings.terrainpenetration = value
    if value then hooktrajectoryraycast(); hooksilentaim() end
end})
modifications:AddToggle("ComponentPassthrough", {Text = "Component Passthrough", Tooltip = "Registers a vehicle-component hit, then continues the shell beyond that component with loop and range limits.", Callback = function(value)
    settings.componentpassthrough = value
    if value then hooktrajectoryraycast(); hooksilentaim() end
end})
modifications:AddToggle("HomingShells", {Text = "Lightweight Main Guidance", Tooltip = "Applies one predicted launch direction to main shells without continuous homing or per-frame target metadata.", Callback = function(value)
    settings.homingshells = value
    if value then
        hooksilentaim()
        if fovtoggle and not settings.fov then fovtoggle:SetValue(true) end
    end
end})
modifications = modificationsbox:AddTab("Ammo")
modifications:AddToggle("InfiniteAmmo", {Text = "Infinite Ammo", Tooltip = "Maintains main reserve, main clip, secondary-gun, and equipped missile ammunition.", Callback = function(value)
    settings.mainammo = value
    settings.mainclip = value
    settings.secondaryammo = value
    if value then
        reservecorrections = 0
        clipcorrections = 0
        ammovolleys = 0
        lastammovolley = nil
        scangunstates()
        updatevolleyhooks()
        updatemainammo()
        updatemainclips()
    else
        restoremainammo()
        restoremainclip()
        restoresecondaryammo()
        restorevolleyhooks()
    end
    refreshammowatchers()
end})
modifications:AddToggle("RapidFire", {Text = "Rapid Fire", Tooltip = "Repeatedly readies the main cannon at the selected firing rate while fire is held.", Callback = function(value)
    settings.rapidfire = value
    runtimeclock.rapid = 0
    if value then scangunstates() end
end}):AddSlider("RapidFireRate", {Text = "Fire Rate", Min = 2, Max = 30, Default = 10, Rounding = 0, Suffix = " shots/s", Callback = function(value)
    settings.rapidfirerate = value
end})
modifications:AddToggle("NoReload", {Text = "No Reload", Tooltip = "Keeps the active main cannon in its native ready state.", Callback = function(value)
    settings.noreload = value
    if value then scangunstates() end
end})
modifications:AddToggle("ReloadMultiplier", {Text = "Main Reload Multiplier", Tooltip = "Accelerates the local main-cannon reload timer.", Callback = function(value)
    settings.reload = value
    if value then scangunstates() end
end})
    :AddSlider("ReloadMultiplierValue", {Text = "Multiplier", Min = 1, Max = 10, Default = 2, Rounding = 1, Suffix = "x", Callback = function(value) settings.reloadmult = value end})
modifications:AddToggle("NoOverheat", {Text = "No Overheat", Callback = function(value) settings.nooverheat = value end})
modifications = modificationsbox:AddTab("Others")
modifications:AddToggle("NoCameraShake", {Text = "No Camera Shake", Callback = function(value)
    settings.nocamerashake = value
    if value then scangunstates() else restorecamerashake() end
end})
modifications:AddToggle("NoRecoil", {Text = "No Recoil", Tooltip = "Suppresses main and secondary weapon impulse and barrel recoil locally.", Callback = function(value)
    settings.norecoil = value
    settings.norecoilzoom = value
    if value then
        scangunstates()
        runtimeclock.updaterecoil(true)
    else
        runtimeclock.restorerecoil()
        restorerecoilzoom()
    end
end})
modifications:AddToggle("BypassCrewCondition", {Text = "Bypass Crew Conditions", Callback = setcrewcondition})
fovtoggle = targeting:AddToggle("TargetFOV", {Text = "FOV", Callback = function(value) settings.fov = value end})
fovtoggle:AddColorPicker("TargetFOVColor", {
    Default = settings.fovcolor,
    Title = "FOV Color",
    Gradient = {Index = "TargetFOVColorGradient", Text = "Animated Gradient", Default = false, Callback = function(value) settings.fovgradient = value end},
    Callback = function(value) settings.fovcolor = value end,
})
targeting:AddSlider("TargetFOVSize", {Text = "FOV Size", Min = 25, Max = 600, Default = 180, Rounding = 0, Callback = function(value) settings.fovsize = value end})
targeting:AddToggle("TargetSnaplines", {Text = "Snaplines", Callback = function(value) settings.snaplines = value end})
end

do
local vehiclebox = tabs.vehicle:AddLeftTabbox("Vehicle")
local vehiclemovement = vehiclebox:AddTab("Movement")
vehiclemovement:AddToggle("VehicleSpeedMultiplier", {Text = "Vehicle Speed", Tooltip = "Multiplies the locally-owned chassis speed.", Callback = function(value)
    settings.vehiclespeed = value
    updatevehiclemods()
end}):AddSlider("VehicleSpeedMultiplierValue", {Text = "Multiplier", Min = 1, Max = 2.5, Default = 1, Rounding = 2, Suffix = "x", Callback = function(value)
    settings.vehiclespeedmult = value
    updatevehiclemods()
end})
vehiclemovement:AddToggle("VehicleAccelerationMultiplier", {Text = "Acceleration Multiplier", Tooltip = "Multiplies local drive force and applies a network-owned chassis fallback.", Callback = function(value)
    settings.vehicleacceleration = value
    updatevehiclemods()
end}):AddSlider("VehicleAccelerationMultiplierValue", {Text = "Multiplier", Min = 1, Max = 2, Default = 1, Rounding = 2, Suffix = "x", Callback = function(value)
    settings.vehicleaccelerationmult = value
    updatevehiclemods()
end})
vehiclemovement:AddToggle("VehicleReverseMultiplier", {Text = "Reverse Speed", Tooltip = "Multiplies the native reverse-speed limit.", Callback = function(value)
    settings.vehiclereverse = value
    updatevehiclemods()
end}):AddSlider("VehicleReverseMultiplierValue", {Text = "Multiplier", Min = 1, Max = 2.5, Default = 1, Rounding = 2, Suffix = "x", Callback = function(value)
    settings.vehiclereversemult = value
    updatevehiclemods()
end})

vehiclemovement = vehiclebox:AddTab("Handling")
vehiclemovement:AddToggle("VehicleBrakeMultiplier", {Text = "Brake Power", Tooltip = "Multiplies Qhassis BRAKE_FORCE.", Callback = function(value)
    settings.vehiclebrake = value
    updatevehiclemods()
end}):AddSlider("VehicleBrakeMultiplierValue", {Text = "Multiplier", Min = 0.25, Max = 3, Default = 1, Rounding = 2, Suffix = "x", Callback = function(value)
    settings.vehiclebrakemult = value
    updatevehiclemods()
end})
vehiclemovement:AddToggle("VehicleSteeringMultiplier", {Text = "Steering Speed", Tooltip = "Multiplies the steering and tank yaw limits.", Callback = function(value)
    settings.vehiclesteering = value
    updatevehiclemods()
end}):AddSlider("VehicleSteeringMultiplierValue", {Text = "Multiplier", Min = 0.25, Max = 6, Default = 1, Rounding = 2, Suffix = "x", Callback = function(value)
    settings.vehiclesteeringmult = value
    updatevehiclemods()
end})
vehiclemovement:AddToggle("VehicleGripMultiplier", {Text = "Traction", Tooltip = "Multiplies tire grip used by the suspension solver.", Callback = function(value)
    settings.vehiclegrip = value
    updatevehiclemods()
end}):AddSlider("VehicleGripMultiplierValue", {Text = "Multiplier", Min = 0.25, Max = 3, Default = 1, Rounding = 2, Suffix = "x", Callback = function(value)
    settings.vehiclegripmult = value
    updatevehiclemods()
end})
vehiclemovement:AddToggle("VehicleDragMultiplier", {Text = "Rolling Resistance", Tooltip = "Adjusts rolling resistance. Lower values coast farther; higher values slow down sooner.", Callback = function(value)
    settings.vehicledrag = value
    updatevehiclemods()
end}):AddSlider("VehicleDragMultiplierValue", {Text = "Multiplier", Min = 0, Max = 2, Default = 1, Rounding = 2, Suffix = "x", Callback = function(value)
    settings.vehicledragmult = value
    updatevehiclemods()
end})

vehiclemovement = vehiclebox:AddTab("Flight")
runtimeclock.vehicleflytoggle = vehiclemovement:AddToggle("VehicleFly", {Text = "VFly", Tooltip = "Arm VFly here, then press V to activate it. WASD moves and Space/Control changes altitude.", Callback = function(value)
    settings.vehiclefly = value
    if not value then
        runtimeclock.flyhull = nil
        runtimeclock.flyvelocity = nil
        runtimeclock.flyaltitude = nil
    end
end})
runtimeclock.vehicleflytoggle:AddKeyPicker("VehicleFlyKey", {Default = "V", SyncToggleState = true, Mode = "Toggle", Text = "VFly"})
runtimeclock.vehicleflytoggle:AddSlider("VehicleFlySpeed", {Text = "Fly Speed", Min = 25, Max = 300, Default = 100, Rounding = 0, Suffix = " studs/s", Callback = function(value)
    settings.vehicleflyspeed = value
end})
vehiclemovement:AddSlider("VehicleFlyVerticalSpeed", {Text = "Vertical Speed", Min = 20, Max = 180, Default = 65, Rounding = 0, Suffix = " studs/s", Callback = function(value) settings.vehicleflyverticalspeed = value end})
vehiclemovement:AddSlider("VehicleFlyAcceleration", {Text = "Flight Response", Min = 1, Max = 12, Default = 5, Rounding = 1, Suffix = "x", Callback = function(value) settings.vehicleflyacceleration = value end})
vehiclemovement:AddToggle("VehicleFlyHover", {Text = "Altitude Hold", Default = true, Tooltip = "Holds the current altitude when neither vertical key is pressed.", Callback = function(value)
    settings.vehicleflyhover = value
    runtimeclock.flyaltitude = runtimeclock.flyhull and runtimeclock.flyhull.Position.Y or nil
end})

local vehiclerepair = vehiclebox:AddTab("Repair")
vehiclerepair:AddToggle("AutoRepair", {Text = "Auto Repair", Tooltip = "Uses the normal repair action when damaged vehicle modules are detected.", Callback = function(value)
    settings.autorepair = value
end})
vehiclerepair:AddToggle("AutoRepairNoStun", {Text = "Auto Repair No Stun", Tooltip = "Removes the local movement stop while repairing. Server checks may still cancel a moving repair.", Callback = function(value)
    setrepairmovement(value)
    if not value then restorerepairhooks() end
end})
vehiclerepair:AddToggle("FastRepair", {Text = "Fast Repair", Tooltip = "Experimental: reduces replicated client repair timers. The server may retain its normal timer.", Callback = function(value)
    settings.fastrepair = value
end})
end

do
local visualsbox = tabs.visuals:AddLeftTabbox("Vehicle Visuals")
local visuals = visualsbox:AddTab("Visuals")
visuals:AddToggle("VehicleESP", {Text = "Vehicle Visuals", Callback = function(value)
    settings.vehicleesp = value
    if value then scanvehicles() end
end})
visuals:AddMultiDropdown("VehicleDisplays", {Text = "Displays", Values = {"Highlight", "Name", "Box", "Distance", "Text Background"}, Default = {"Highlight", "Name", "Distance", "Text Background"}, Callback = function(value) settings.vehicledisplays = value end})
visuals:AddToggle("VehicleESPTeamCheck", {Text = "Team Check", Callback = function(value) settings.espteamcheck = value end})
visuals:AddToggle("VehicleESPVisibleCheck", {Text = "Visible Check", Callback = function(value) settings.espvisiblecheck = value end})
visuals:AddSlider("VehicleESPDistance", {Text = "Render Distance", Min = 100, Max = 10000, Default = 3000, Rounding = 0, Suffix = "m", Callback = function(value) settings.renderdistance = value end})
visuals:AddSlider("VehicleESPUpdateRate", {Text = "Update Interval", Min = 0.04, Max = 0.25, Default = 0.08, Rounding = 2, Suffix = "s", Tooltip = "Higher values reduce ESP rendering cost.", Callback = function(value) settings.espinterval = value end})
visuals:AddLabel("ESP Color")
    :AddColorPicker("VehicleESPVisibleColor", {Default = settings.espvisiblecolor, Title = "Visible ESP", Callback = function(value) settings.espvisiblecolor = value end})
    :AddColorPicker("VehicleESPBlockedColor", {Default = settings.espblockedcolor, Title = "Not Visible ESP", Callback = function(value) settings.espblockedcolor = value end})
end

local utilitybox = tabs.misc:AddLeftTabbox("Utility")
local utility = utilitybox:AddTab("Mouse")
utility:AddToggle("UnlockMouse", {Text = "Unlock Mouse", Tooltip = "Frees the cursor. Hold right mouse to capture it and rotate the vehicle camera.", Callback = function(value)
    settings.unlockmouse = value
    mouselooking = false
    userinputservice.MouseIconEnabled = value or originalmouseicon
    if value then
        userinputservice.MouseBehavior = Enum.MouseBehavior.Default
        pcall(function() userinputservice.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow end)
    else
        userinputservice.MouseBehavior = originalmousebehavior
        if originalmouseoverride then pcall(function() userinputservice.OverrideMouseIconBehavior = originalmouseoverride end) end
    end
end})

utility = utilitybox:AddTab("Effects")
utility:AddToggle("NoSmoke", {Text = "No Smoke", Tooltip = "Suppresses local muzzle smoke, flashes, sparks, and gunfire lights.", Callback = function(value)
    settings.nosmoke = value
    runtimeclock.updatenosmoke(value)
end})

connect(userinputservice.InputBegan, function(input)
    if settings.unlockmouse and input.UserInputType == Enum.UserInputType.MouseButton2 then mouselooking = true end
    if settings.repairmovement and input.KeyCode == Enum.KeyCode.F then spoofrepairstop(ownedchassis()) end
end)

connect(userinputservice.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then mouselooking = false end
end)
end

watermark = library:AddDraggableLabel({Text = "cursed tank | 0 fps | 0ms", Icon = avatar, IconPosition = "left"})
watermark:SetVisible(false)

local watchedprojectiles
local watchedvehicles

runtimeclock.fixcamera = function(force)
    local current = workspace.CurrentCamera
    if current then camera = current else return end
    local character = localplayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local subject
    pcall(function() subject = current.CameraSubject end)
    local invalidsubject = subject == nil or typeof(subject) == "Instance" and not subject:IsDescendantOf(workspace)
    if force or invalidsubject then
        pcall(function()
            current.CameraType = Enum.CameraType.Custom
            current.CameraSubject = humanoid
        end)
    end
end

local function watchprojectiles(folder)
    if folder == watchedprojectiles then return end
    watchedprojectiles = folder
    connect(folder.ChildAdded, watchprojectile)
    connect(folder.ChildRemoved, removeshelltrail)
    updateshelltrails()
end

local function watchvehicles(folder)
    if folder == watchedvehicles then return end
    watchedvehicles = folder
    connect(folder.ChildAdded, function(vehicle)
        task.delay(0.5, function()
            if not vehicle.Parent then return end
            if settings.vehicleesp or settings.silentaim or settings.homingshells or settings.snaplines or settings.targethud or settings.predictionmarker then addvehicle(vehicle) end
            local hullnode = vehicle:FindFirstChild("HullNode")
            local owner = hullnode and hullnode:GetAttribute("Owner")
            if vehicle == ownedchassis() or owner == localplayer.Name or ownerplayer(vehicle) == localplayer then
                table.clear(gunstates)
                scangunstates()
                runtimeclock.fixcamera(true)
            end
            if settings.nosmoke then runtimeclock.suppresssmoke(vehicle) end
        end)
    end)
    connect(folder.ChildRemoved, function(vehicle)
        if vehicle == mainammoowner or ownerplayer(vehicle) == localplayer or ownername(vehicle) == localplayer.Name then
            table.clear(gunstates)
            task.defer(scangunstates)
        end
    end)
end

local projectiles = workspace:FindFirstChild("Projectiles")
if projectiles then
    watchprojectiles(projectiles)
end

local vehiclefolder = workspace:FindFirstChild("Vehicles")
if vehiclefolder then
    watchvehicles(vehiclefolder)
end

connect(workspace.ChildAdded, function(child)
    if child.Name == "Projectiles" then watchprojectiles(child) end
    if child.Name == "Vehicles" then watchvehicles(child) end
end)

connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    camera = workspace.CurrentCamera or camera
    task.defer(runtimeclock.fixcamera, false)
end)

connect(localplayer.CharacterAdded, function()
    disconnectammowatchers()
    restoremainammo()
    restoremainclip()
    restorevolleyhooks()
    table.clear(gunstates)
    gunstatus = "respawn rescan"
    task.delay(1, scangunstates)
    task.delay(0.75, runtimeclock.fixcamera, true)
end)

--// runtime

connect(runservice.PreSimulation, function()
    updaterepairmovement()
end)

pcall(function()
    runservice:UnbindFromRenderStep(mousebindname)
    runservice:BindToRenderStep(mousebindname, Enum.RenderPriority.Last.Value + 100, function()
        if not settings.unlockmouse then return end
        if mouselooking then
            userinputservice.MouseBehavior = Enum.MouseBehavior.LockCenter
            userinputservice.MouseIconEnabled = false
            pcall(function() userinputservice.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide end)
        else
            userinputservice.MouseBehavior = Enum.MouseBehavior.Default
            userinputservice.MouseIconEnabled = true
            pcall(function() userinputservice.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow end)
        end
    end)
end)

connect(runservice.RenderStepped, function(delta)
    camera = workspace.CurrentCamera or camera
    fpsframes += 1
    fpstime += delta
    runtimeclock.vehicle += delta
    if runtimeclock.vehicle >= math.max(settings.espinterval, 0.05) then
        local active = settings.vehicleesp or settings.silentaim or settings.homingshells or settings.snaplines or settings.targethud or settings.predictionmarker
        if active or next(vehicles) then
            updatevehicles(runtimeclock.vehicle)
            runtimeclock.visualidle = active and 0 or (runtimeclock.visualidle or 0) + runtimeclock.vehicle
            if not active and runtimeclock.visualidle >= 1 then clearvehicleesp(); runtimeclock.visualidle = 0 end
        end
        runtimeclock.vehicle = 0
    end
    updatetargeting(delta)
    runtimeclock.updatedamagereticle(delta)
    if settings.unlockmouse and not mouselooking then
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

connect(runservice.Heartbeat, function(delta)
    if settings.rapidfire then
        runtimeclock.rapid = (runtimeclock.rapid or 0) + delta
        local interval = 1 / math.max(settings.rapidfirerate, 1)
        if runtimeclock.rapid >= interval then
            runtimeclock.rapid %= interval
            if #gunstates == 0 and os.clock() - lastgunscan >= 1 then scangunstates() end
            local chassis = ownedchassis()
            for _, state in ipairs(gunstates) do
                if type(state) == "table" and (not chassis or rawget(state, "chassis") == chassis) and type(rawget(state, "reloading")) == "number" then
                    state.reloading = -1
                end
            end
        end
    end
    runtimeclock.gun += delta
    if runtimeclock.gun >= 0.05 then
        updategunmods(runtimeclock.gun)
        runtimeclock.gun = 0
    end
    if settings.vehiclespeed or settings.vehicleacceleration or settings.vehiclereverse or settings.vehiclebrake or settings.vehiclesteering or settings.vehiclegrip or settings.vehicledrag or settings.vehiclefly or next(vehicleoriginals) then
        updatevehiclemods(delta)
    end
    updateautorepair()
    runtimeclock.repair += delta
    if runtimeclock.repair >= 0.2 then
        updatefastrepair()
        runtimeclock.repair = 0
    end
    if (settings.vehicleesp or settings.silentaim or settings.homingshells or settings.snaplines or settings.targethud or settings.predictionmarker) and os.clock() - lastscan >= 6 then
        lastscan = os.clock()
        scanvehicles()
    end
    if settings.nosmoke then
        runtimeclock.smokeclock = (runtimeclock.smokeclock or 0) + delta
        if runtimeclock.smokeclock >= 0.35 then
            runtimeclock.smokeclock = 0
            runtimeclock.updatenosmoke(false)
        end
    end
end)

--// cleanup

library:OnUnload(function()
    for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
    clearvehicleesp()
    for _, data in ipairs(runtimeclock.vehicleesppool or {}) do
        pcall(function() data.highlight:Destroy() end)
        pcall(function() data.billboard:Destroy() end)
        pcall(function() data.distancebillboard:Destroy() end)
        if data.box then pcall(function() data.box:Remove() end) end
    end
    runtimeclock.vehicleesppool = nil
    restorecamerashake()
    restorerecoilzoom()
    disconnectammowatchers()
    restorevolleyhooks()
    restoreammo()
    runtimeclock.restorerecoil()
    runtimeclock.restorenosmoke()
    restorevehiclemods()
    setrepairmovement(false)
    restorerepairhooks()
    setcrewcondition(false)
    settings.shelltrail = false
    updateshelltrails()
    userinputservice.MouseBehavior = originalmousebehavior
    userinputservice.MouseIconEnabled = originalmouseicon
    if originalmouseoverride then pcall(function() userinputservice.OverrideMouseIconBehavior = originalmouseoverride end) end
    pcall(function() runservice:UnbindFromRenderStep(mousebindname) end)
    if oldnamecall and type(hookmetamethod) == "function" then
        pcall(function() hookmetamethod(game, "__namecall", oldnamecall) end)
        oldnamecall = nil
    end
    if oldtrajectory and trajectorymodule and type(hookfunction) == "function" then
        pcall(function() hookfunction(trajectorymodule.Trajectory, oldtrajectory) end)
    end
    for _, drawing in ipairs({fovcircle, snapline, predictioncircle, runtimeclock.impactmarker, targetbox}) do pcall(function() drawing:Remove() end) end
    for _, drawing in ipairs(runtimeclock.damagereticlelines or {}) do pcall(function() drawing:Remove() end) end
    for _, text in ipairs(targettexts) do pcall(function() text:Remove() end) end
    for _, line in ipairs(targetlines) do pcall(function() line:Remove() end) end
    if targetframe then pcall(function() targetframe:Destroy() end) end
    if env.slimekrewcursedtank == library then env.slimekrewcursedtank = nil end
end)

env.slimekrewcursedtank = library
