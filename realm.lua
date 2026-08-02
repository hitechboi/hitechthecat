--// vars

local environment = getgenv()
local libraryurl = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"
local iconurl = "https://www.image2url.com/r2/default/images/1785368907766-d375b142-01d6-45be-a9fc-ae3e07254a85.jpg"
local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local coregui = game:GetService("CoreGui")
local replicatedstorage = game:GetService("ReplicatedStorage")
local httpservice = game:GetService("HttpService")
local localplayer = players.LocalPlayer
local folderpath = "Potas/realm-rampage"
local configpath = folderpath .. "/configs"
local autoloadpath = folderpath .. "/autoload.txt"
local preloadedtheme = "Default"
local nodashcooldown = false
local fastm1 = false
local nostun = false
local autodomainclash = false
local activeclashvalue
local clashgeneration = 0
local clashconnection
local clashdestroyconnection
local fastm1multiplier = 3
local dashconnection
local m1connection
local playerdescendantconnection
local characteraddedconnection
local characterdescendantconnection
local animationconnection
local espconnection
local playeraddedconnection
local playerremovingconnection
local espenabled = false
local espfade = 0
local espboxtype = "None"
local esphealthdisplay = "Health Bar"
local esphighlight = false
local espstunnedstate = false
local selfesp = false
local espobjects = {}
local comboanimations = {}
local changedtracks = setmetatable({}, { __mode = "k" })
local originalworkspaceattribute = workspace:GetAttribute("NoDashCooldowns")
local originalplayerattribute = localplayer:GetAttribute("NoDashCooldowns")
local originalworkspaceattackspeed = workspace:GetAttribute("AttackSpeedMult")
local originalplayerattackspeed = localplayer:GetAttribute("AttackSpeedMult")

if environment.potasrealmui then
    pcall(function()
        environment.potasrealmui:Unload()
    end)
    environment.potasrealmui = nil
end

local cachebuster = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local librarysource = game:HttpGet(libraryurl .. "?cachebust=" .. cachebuster, true)
local librarychunk, compileerror = loadstring(librarysource)

assert(librarychunk, "UI library compile failed: " .. tostring(compileerror))

local library = librarychunk()

assert(type(library) == "table", "UI library returned " .. type(library))

--// funcs

local function detectexecutor()
    local detectors = {
        identifyexecutor or false,
        getexecutorname or false,
    }

    for _, detector in ipairs(detectors) do
        if type(detector) == "function" then
            local success, executorname = pcall(detector)

            if success and executorname and tostring(executorname) ~= "" then
                return tostring(executorname)
            end
        end
    end

    return "Unknown"
end

local function getperformance()
    local framerate = "Unknown"
    local ping = "Unknown"
    local success, result = pcall(function()
        return math.floor(workspace:GetRealPhysicsFPS() + 0.5)
    end)

    if success then
        framerate = tostring(result)
    end

    success, result = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    end)

    if success then
        ping = tostring(result)
    end

    return framerate, ping
end

local function resolveasset(url)
    local getasset = getcustomasset or getsynasset
    local fallbackasset = "rbxassetid://95236382788593"

    if not (writefile and getasset) then
        return fallbackasset
    end

    pcall(function()
        if makefolder and isfolder and not isfolder("Potas") then
            makefolder("Potas")
        end
    end)

    local assetpath = "Potas/slimekrew.jpg"

    if not isfile or not isfile(assetpath) then
        local success = pcall(writefile, assetpath, game:HttpGet(url))

        if not success then
            return fallbackasset
        end
    end

    local success, assetid = pcall(getasset, assetpath)
    return success and assetid or fallbackasset
end

local function isdashcooldown(instance)
    local name = instance.Name:lower()
    local parentname = instance.Parent and instance.Parent.Name:lower() or ""

    if name:find("dash", 1, true) and (name:find("cooldown", 1, true) or parentname:find("cooldown", 1, true)) then
        return true
    end

    if name == "cooldown" then
        for attributename, attributevalue in pairs(instance:GetAttributes()) do
            if tostring(attributename):lower():find("dash", 1, true)
                or tostring(attributevalue):lower():find("dash", 1, true)
            then
                return true
            end
        end
    end

    return false
end

local function cleardashcooldowns()
    local character = localplayer.Character
    local containers = { localplayer }

    if character then
        table.insert(containers, character)
    end

    for _, container in ipairs(containers) do
        for _, descendant in ipairs(container:GetDescendants()) do
            if isdashcooldown(descendant) then
                pcall(descendant.Destroy, descendant)
            end
        end
    end
end

local function setnodashcooldown(enabled)
    nodashcooldown = enabled

    if enabled then
        workspace:SetAttribute("NoDashCooldowns", true)
        localplayer:SetAttribute("NoDashCooldowns", true)
        cleardashcooldowns()

        if not dashconnection then
            local elapsed = 0

            dashconnection = runservice.Heartbeat:Connect(function(deltatime)
                if not nodashcooldown then
                    return
                end

                elapsed += deltatime

                if elapsed < 0.5 then
                    return
                end

                elapsed = 0
                workspace:SetAttribute("NoDashCooldowns", true)
                localplayer:SetAttribute("NoDashCooldowns", true)
            end)
        end
    else
        workspace:SetAttribute("NoDashCooldowns", originalworkspaceattribute)
        localplayer:SetAttribute("NoDashCooldowns", originalplayerattribute)

    end
end

local function loadcomboanimations()
    local replicatedstorage = game:GetService("ReplicatedStorage")
    local modules = replicatedstorage:FindFirstChild("Modules")
    local informationmodule = modules and modules:FindFirstChild("CharacterInformation")

    if not informationmodule then
        return
    end

    local success, characterinformation = pcall(require, informationmodule)

    if not success or type(characterinformation) ~= "table" then
        return
    end

    local function addanimations(animations)
        if type(animations) ~= "table" then
            return
        end

        for _, animationid in pairs(animations) do
            local normalizedid = tostring(animationid):match("%d+")

            if normalizedid then
                comboanimations[normalizedid] = true
            end
        end
    end

    for _, characterdata in pairs(characterinformation) do
        if type(characterdata) == "table" then
            addanimations(characterdata.ComboAnims)

            if type(characterdata.AwakeningData) == "table" then
                addanimations(characterdata.AwakeningData.ComboAnims)
            end
        end
    end
end

local function ism1cooldown(instance)
    local name = instance.Name:lower()
    local parentname = instance.Parent and instance.Parent.Name:lower() or ""
    local ism1 = name:find("m1", 1, true) or name:find("combo", 1, true)
    local iscooldown = name:find("cooldown", 1, true) or parentname:find("cooldown", 1, true)

    if ism1 and iscooldown then
        return true
    end

    if name == "cooldown" then
        for attributename, attributevalue in pairs(instance:GetAttributes()) do
            local attribute = tostring(attributename):lower() .. " " .. tostring(attributevalue):lower()

            if attribute:find("m1", 1, true) or attribute:find("combo", 1, true) then
                return true
            end
        end
    end

    return false
end

local function clearidentifiedm1cooldowns()
    local character = localplayer.Character
    local containers = { localplayer }

    if character then
        table.insert(containers, character)
    end

    for _, container in ipairs(containers) do
        for _, descendant in ipairs(container:GetDescendants()) do
            if ism1cooldown(descendant) then
                pcall(descendant.Destroy, descendant)
            end
        end
    end
end

local function iscomboanimation(track)
    local animation = track.Animation
    local animationid = animation and animation.AnimationId:match("%d+")

    if animationid and comboanimations[animationid] then
        return true
    end

    local trackname = track.Name:lower()
    return trackname:find("m1", 1, true) ~= nil or trackname:find("combo", 1, true) ~= nil
end

local function applyfastm1()
    workspace:SetAttribute("AttackSpeedMult", fastm1multiplier)
    localplayer:SetAttribute("AttackSpeedMult", fastm1multiplier)

    local character = localplayer.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildWhichIsA("Animator")

    if not animator then
        return
    end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if iscomboanimation(track) then
            changedtracks[track] = true
            track:AdjustSpeed(math.max(1, fastm1multiplier - 0.25))
        end
    end
end

local function setfastm1(enabled)
    fastm1 = enabled

    if enabled then
        clearidentifiedm1cooldowns()
        applyfastm1()

        if not m1connection then
            local elapsed = 0

            m1connection = runservice.Heartbeat:Connect(function(deltatime)
                if not fastm1 then
                    return
                end

                elapsed += deltatime

                if elapsed < 0.5 then
                    return
                end

                elapsed = 0
                applyfastm1()
            end)
        end
    else
        workspace:SetAttribute("AttackSpeedMult", originalworkspaceattackspeed)
        localplayer:SetAttribute("AttackSpeedMult", originalplayerattackspeed)

        for track in pairs(changedtracks) do
            if track then
                pcall(track.AdjustSpeed, track, 1)
            end
        end

        table.clear(changedtracks)
    end
end

loadcomboanimations()

local function isstunstate(instance)
    local name = instance.Name:lower()
    return name == "freeze" or name == "stun" or name == "stunned"
end

local function clearstuns(character)
    if not character then
        return
    end

    for _, descendant in ipairs(character:GetDescendants()) do
        if isstunstate(descendant) then
            pcall(descendant.Destroy, descendant)
        end
    end
end

local function setnostun(enabled)
    nostun = enabled

    if enabled then
        clearstuns(localplayer.Character)
    end
end

local function sendkey(keycode, virtualkey)
    if type(keypress) == "function" and type(keyrelease) == "function" then
        keypress(virtualkey)
        task.wait(0.015)
        keyrelease(virtualkey)
        return true
    end

    local success, virtualinputmanager = pcall(game.GetService, game, "VirtualInputManager")

    if success and virtualinputmanager then
        virtualinputmanager:SendKeyEvent(true, keycode, false, game)
        task.wait(0.015)
        virtualinputmanager:SendKeyEvent(false, keycode, false, game)
        return true
    end

    return false
end

local function sendspace()
    return sendkey(Enum.KeyCode.Space, 0x20)
end

local function stopdomainclash()
    clashgeneration += 1
    activeclashvalue = nil

    if clashdestroyconnection then
        clashdestroyconnection:Disconnect()
        clashdestroyconnection = nil
    end
end

local function startdomainclash(clashvalue)
    stopdomainclash()
    activeclashvalue = clashvalue
    local generation = clashgeneration

    clashdestroyconnection = clashvalue.Destroying:Connect(function()
        stopdomainclash()
    end)

    task.spawn(function()
        local supported = true

        while autodomainclash and activeclashvalue == clashvalue and clashvalue.Parent and generation == clashgeneration do
            if not sendspace() then
                supported = false
                break
            end

            task.wait(0.035)
        end

        if not supported then
            autodomainclash = false

            library:Notify({
                Title = "Domain Clash",
                Description = "Executor input simulation is unavailable",
                Time = 4,
            })
        end
    end)
end

local function setupdomainclash()
    local panelreplication = replicatedstorage:FindFirstChild("PanelReplication")

    if not panelreplication or not panelreplication:IsA("RemoteEvent") then
        return
    end

    clashconnection = panelreplication.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" or not data.ClashData or data.ClashWinner then
            return
        end

        local character = localplayer.Character

        if character and table.find(data.ClashData, character) and data.ClashValue then
            if autodomainclash then
                startdomainclash(data.ClashValue)
            else
                activeclashvalue = data.ClashValue
            end
        end
    end)
end

local function handleaddedinstance(instance)
    if nodashcooldown and isdashcooldown(instance) then
        pcall(instance.Destroy, instance)
        return
    end

    if fastm1 and ism1cooldown(instance) then
        pcall(instance.Destroy, instance)
        return
    end

    if nostun and isstunstate(instance) then
        pcall(instance.Destroy, instance)
    end
end

local function bindanimationtracker(character)
    if animationconnection then
        animationconnection:Disconnect()
        animationconnection = nil
    end

    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildWhichIsA("Animator")

    if animator then
        animationconnection = animator.AnimationPlayed:Connect(function(track)
            if fastm1 and iscomboanimation(track) then
                changedtracks[track] = true
                track:AdjustSpeed(math.max(1, fastm1multiplier - 0.25))
            end
        end)
    end
end

local function bindcharacter(character)
    if characterdescendantconnection then
        characterdescendantconnection:Disconnect()
        characterdescendantconnection = nil
    end

    if not character then
        return
    end

    characterdescendantconnection = character.DescendantAdded:Connect(function(instance)
        handleaddedinstance(instance)

        if instance:IsA("Animator") then
            bindanimationtracker(character)
        end
    end)

    bindanimationtracker(character)

    if nostun then
        clearstuns(character)
    end
end


playerdescendantconnection = localplayer.DescendantAdded:Connect(handleaddedinstance)
characteraddedconnection = localplayer.CharacterAdded:Connect(bindcharacter)
bindcharacter(localplayer.Character)

local function getgradientsequence()
    local startcolor, endcolor = library:GetGradientColors()

    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, startcolor),
        ColorSequenceKeypoint.new(0.25, startcolor:Lerp(endcolor, 0.5)),
        ColorSequenceKeypoint.new(0.5, endcolor),
        ColorSequenceKeypoint.new(0.75, startcolor:Lerp(endcolor, 0.5)),
        ColorSequenceKeypoint.new(1, startcolor),
    })
end

local function createline(parent)
    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.BackgroundColor3 = Color3.new(1, 1, 1)
    line.Visible = false
    line.ZIndex = 3
    line.Parent = parent

    local gradient = Instance.new("UIGradient")
    gradient.Color = getgradientsequence()
    gradient.Offset = Vector2.new(-1, 0)
    gradient.Parent = line

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(10, 10, 12)
    stroke.Thickness = 1
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = line

    return line, gradient, stroke
end

local function createespobject(player)
    if (player == localplayer and not selfesp) or espobjects[player] then
        return
    end

    local container = Instance.new("Frame")
    container.Name = player.Name
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Size = UDim2.fromScale(1, 1)
    container.Parent = environment.potasrealmesp

    local lines = {}
    local gradients = {}
    local strokes = {}

    for index = 1, 8 do
        lines[index], gradients[index], strokes[index] = createline(container)
    end

    local information = Instance.new("TextLabel")
    information.BackgroundTransparency = 1
    information.Font = Enum.Font.Code
    information.TextColor3 = Color3.new(1, 1, 1)
    information.TextStrokeColor3 = Color3.new(0, 0, 0)
    information.TextStrokeTransparency = 0.25
    information.TextSize = 13
    information.TextXAlignment = Enum.TextXAlignment.Center
    information.ZIndex = 4
    information.Parent = container

    local informationgradient = Instance.new("UIGradient")
    informationgradient.Color = getgradientsequence()
    informationgradient.Parent = information

    local healthbackground = Instance.new("Frame")
    healthbackground.BorderSizePixel = 0
    healthbackground.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    healthbackground.ZIndex = 3
    healthbackground.Parent = container

    local healthfill = Instance.new("Frame")
    healthfill.AnchorPoint = Vector2.new(0, 1)
    healthfill.Position = UDim2.fromScale(0, 1)
    healthfill.BorderSizePixel = 0
    healthfill.BackgroundColor3 = Color3.new(1, 1, 1)
    healthfill.ZIndex = 4
    healthfill.Parent = healthbackground

    local healthgradient = Instance.new("UIGradient")
    healthgradient.Color = ColorSequence.new(Color3.fromRGB(255, 70, 70), Color3.fromRGB(90, 255, 140))
    healthgradient.Rotation = -90
    healthgradient.Parent = healthfill

    local healthtext = Instance.new("TextLabel")
    healthtext.BackgroundTransparency = 1
    healthtext.Font = Enum.Font.Code
    healthtext.TextColor3 = Color3.new(1, 1, 1)
    healthtext.TextStrokeColor3 = Color3.new(0, 0, 0)
    healthtext.TextStrokeTransparency = 0.25
    healthtext.TextSize = 12
    healthtext.TextXAlignment = Enum.TextXAlignment.Left
    healthtext.ZIndex = 4
    healthtext.Parent = container

    local stunnedindicator = Instance.new("Frame")
    stunnedindicator.BorderSizePixel = 0
    stunnedindicator.BackgroundColor3 = Color3.fromRGB(55, 220, 90)
    stunnedindicator.Size = UDim2.fromOffset(8, 8)
    stunnedindicator.ZIndex = 5
    stunnedindicator.Parent = container

    local stunnedcorner = Instance.new("UICorner")
    stunnedcorner.CornerRadius = UDim.new(1, 0)
    stunnedcorner.Parent = stunnedindicator

    local stunnedoutline = Instance.new("UIStroke")
    stunnedoutline.Color = Color3.fromRGB(15, 15, 18)
    stunnedoutline.Thickness = 1
    stunnedoutline.Transparency = 0.2
    stunnedoutline.Parent = stunnedindicator

    espobjects[player] = {
        container = container,
        lines = lines,
        gradients = gradients,
        strokes = strokes,
        information = information,
        informationgradient = informationgradient,
        healthbackground = healthbackground,
        healthfill = healthfill,
        healthgradient = healthgradient,
        healthtext = healthtext,
        stunnedindicator = stunnedindicator,
        stunnedoutline = stunnedoutline,
        highlight = nil,
    }
end

local function removeespobject(player)
    local object = espobjects[player]

    if not object then
        return
    end

    if object.highlight then
        object.highlight:Destroy()
    end

    object.container:Destroy()
    espobjects[player] = nil
end

local function setline(line, x, y, width, height, transparency)
    line.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
    line.Size = UDim2.fromOffset(math.max(1, math.floor(width)), math.max(1, math.floor(height)))
    line.BackgroundTransparency = transparency
    line.Visible = true
end

local function getcharacterbounds(character, camera)
    local success, boundingcframe, boundingsize = pcall(character.GetBoundingBox, character)

    if not success then
        return
    end

    local halfsize = boundingsize * 0.5
    local minimumx, minimumy = math.huge, math.huge
    local maximumx, maximumy = -math.huge, -math.huge
    local visible = false

    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local corner = boundingcframe * Vector3.new(halfsize.X * x, halfsize.Y * y, halfsize.Z * z)
                local screenposition, onscreen = camera:WorldToViewportPoint(corner)

                if screenposition.Z > 0 then
                    visible = visible or onscreen
                    minimumx = math.min(minimumx, screenposition.X)
                    minimumy = math.min(minimumy, screenposition.Y)
                    maximumx = math.max(maximumx, screenposition.X)
                    maximumy = math.max(maximumy, screenposition.Y)
                end
            end
        end
    end

    if not visible or minimumx == math.huge then
        return
    end

    return minimumx, minimumy, maximumx, maximumy
end

local function hideespobject(object)
    for _, line in ipairs(object.lines) do
        line.Visible = false
    end

    object.information.Visible = false
    object.healthbackground.Visible = false
    object.healthtext.Visible = false
    object.stunnedindicator.Visible = false

    if object.highlight then
        object.highlight.Enabled = false
    end
end

local function updateespobject(player, object, camera, transparency, gradientoffset, accentcolor)
    local character = player.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local rootpart = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or humanoid.Health <= 0 or not rootpart then
        hideespobject(object)
        return
    end

    local minimumx, minimumy, maximumx, maximumy = getcharacterbounds(character, camera)

    if not minimumx then
        hideespobject(object)
        return
    end

    local width = maximumx - minimumx
    local height = maximumy - minimumy
    local cornerwidth = math.max(4, width * 0.25)
    local cornerheight = math.max(4, height * 0.25)
    local lines = object.lines

    if espboxtype == "None" then
        for index = 1, 8 do
            lines[index].Visible = false
        end
    elseif espboxtype == "Box" then
        setline(lines[1], minimumx, minimumy, width, 2, transparency)
        setline(lines[2], minimumx, maximumy - 2, width, 2, transparency)
        setline(lines[3], minimumx, minimumy, 2, height, transparency)
        setline(lines[4], maximumx - 2, minimumy, 2, height, transparency)

        for index = 5, 8 do
            lines[index].Visible = false
        end
    else
        setline(lines[1], minimumx, minimumy, cornerwidth, 2, transparency)
        setline(lines[2], maximumx - cornerwidth, minimumy, cornerwidth, 2, transparency)
        setline(lines[3], minimumx, maximumy - 2, cornerwidth, 2, transparency)
        setline(lines[4], maximumx - cornerwidth, maximumy - 2, cornerwidth, 2, transparency)
        setline(lines[5], minimumx, minimumy, 2, cornerheight, transparency)
        setline(lines[6], maximumx - 2, minimumy, 2, cornerheight, transparency)
        setline(lines[7], minimumx, maximumy - cornerheight, 2, cornerheight, transparency)
        setline(lines[8], maximumx - 2, maximumy - cornerheight, 2, cornerheight, transparency)
    end

    for _, gradient in ipairs(object.gradients) do
        gradient.Offset = gradientoffset
    end

    for _, stroke in ipairs(object.strokes) do
        stroke.Transparency = transparency
    end

    local distance = (camera.CFrame.Position - rootpart.Position).Magnitude
    object.information.Text = player.Name .. " | " .. math.floor(distance + 0.5) .. "m"
    object.information.Position = UDim2.fromOffset(minimumx - 40, minimumy - 18)
    object.information.Size = UDim2.fromOffset(width + 80, 16)
    object.information.TextTransparency = transparency
    object.information.TextStrokeTransparency = 0.25 + transparency * 0.75
    object.information.Visible = true
    object.informationgradient.Offset = gradientoffset

    local healthratio = math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0, 1)
    object.healthbackground.Position = UDim2.fromOffset(minimumx - 6, minimumy)
    object.healthbackground.Size = UDim2.fromOffset(3, height)
    object.healthbackground.BackgroundTransparency = 0.25 + transparency * 0.75
    object.healthbackground.Visible = esphealthdisplay == "Health Bar"
    object.healthfill.Size = UDim2.fromScale(1, healthratio)
    local healthcolor = healthratio <= 0.25 and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(55, 220, 90)
    object.healthfill.BackgroundColor3 = healthcolor
    object.healthgradient.Color = ColorSequence.new(healthcolor)
    object.healthfill.BackgroundTransparency = transparency

    object.healthtext.Text = math.floor(humanoid.Health + 0.5) .. " HP"
    object.healthtext.Position = UDim2.fromOffset(maximumx + 5, minimumy)
    object.healthtext.Size = UDim2.fromOffset(70, 16)
    object.healthtext.TextTransparency = transparency
    object.healthtext.TextStrokeTransparency = 0.25 + transparency * 0.75
    object.healthtext.Visible = esphealthdisplay == "Health Text"

    local stunned = character:FindFirstChild("Freeze") ~= nil
        or character:FindFirstChild("Ragdoll") ~= nil
        or character:FindFirstChild("InTimestop") ~= nil

    object.stunnedindicator.Position = UDim2.fromOffset(minimumx + width * 0.5 - 4, minimumy - 30)
    object.stunnedindicator.BackgroundColor3 = stunned
        and Color3.fromRGB(255, 65, 65)
        or Color3.fromRGB(55, 220, 90)
    object.stunnedindicator.BackgroundTransparency = transparency
    object.stunnedoutline.Transparency = 0.2 + transparency * 0.8
    object.stunnedindicator.Visible = espstunnedstate

    if esphighlight then
        if not object.highlight or object.highlight.Parent ~= character then
            if object.highlight then
                object.highlight:Destroy()
            end

            object.highlight = Instance.new("Highlight")
            object.highlight.Name = "PotasESP"
            object.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            object.highlight.Parent = character
        end

        object.highlight.FillColor = accentcolor
        object.highlight.OutlineColor = accentcolor
        object.highlight.FillTransparency = 0.65 + transparency * 0.35
        object.highlight.OutlineTransparency = transparency
        object.highlight.Enabled = true
    elseif object.highlight then
        object.highlight.Enabled = false
    end
end

local function setupesp()
    local existing = environment.potasrealmesp

    if existing then
        existing:Destroy()
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "PotasRealmESP"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 50

    local success, hiddenui = pcall(function()
        return gethui and gethui()
    end)

    screen.Parent = success and hiddenui or coregui
    environment.potasrealmesp = screen

    for _, player in ipairs(players:GetPlayers()) do
        createespobject(player)
    end

    playeraddedconnection = players.PlayerAdded:Connect(createespobject)
    playerremovingconnection = players.PlayerRemoving:Connect(removeespobject)

    local colorcheckelapsed = 0
    local renderelapsed = 0
    local currentstart, currentend = library:GetGradientColors()

    espconnection = runservice.RenderStepped:Connect(function(deltatime)
        renderelapsed += deltatime

        if renderelapsed < 1 / 30 then
            return
        end

        deltatime = renderelapsed
        renderelapsed = 0
        local targetfade = espenabled and 1 or 0
        espfade += math.clamp(targetfade - espfade, -deltatime * 5, deltatime * 5)

        if espfade <= 0 and not espenabled then
            for _, object in pairs(espobjects) do
                hideespobject(object)
            end
            return
        end

        colorcheckelapsed += deltatime

        if colorcheckelapsed >= 0.2 then
            colorcheckelapsed = 0
            local newstart, newend = library:GetGradientColors()

            if newstart ~= currentstart or newend ~= currentend then
                currentstart, currentend = newstart, newend
                local sequence = getgradientsequence()

                for _, object in pairs(espobjects) do
                    for _, gradient in ipairs(object.gradients) do
                        gradient.Color = sequence
                    end

                    object.informationgradient.Color = sequence
                end
            end
        end

        local duration = math.max(0.1, library.GradientCycleDuration or 4)
        local started = library.GradientCycleStarted or os.clock()
        local phase = ((os.clock() - started) % duration) / duration
        local horizontaloffset = -math.cos(phase * math.pi * 2)
        local gradientoffset = Vector2.new(horizontaloffset, 0)
        local accentamount = (horizontaloffset + 1) * 0.5
        local accentcolor = currentstart:Lerp(currentend, accentamount)
        local transparency = 1 - math.clamp(espfade, 0, 1)
        local camera = workspace.CurrentCamera

        if not camera then
            return
        end

        for player, object in pairs(espobjects) do
            updateespobject(player, object, camera, transparency, gradientoffset, accentcolor)
        end
    end)
end

setupesp()
setupdomainclash()

--// library

local icon = resolveasset(iconurl)
local avatar = icon

pcall(function()
    avatar = players:GetUserThumbnailAsync(
        localplayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size150x150
    )
end)

library.LiquidGlass = false
library.BlurEnabled = false
library.CornerRadius = 12
library.Scheme.BackgroundColor = Color3.fromRGB(27, 28, 33)
library.Scheme.MainColor = Color3.fromRGB(40, 42, 48)
library.Scheme.AccentColor = Color3.fromRGB(224, 226, 230)
library.Scheme.OutlineColor = Color3.fromRGB(76, 79, 88)

pcall(function()
    if not (isfile and readfile and isfile(autoloadpath)) then
        return
    end

    local configname = readfile(autoloadpath)
    local filepath = configpath .. "/" .. tostring(configname) .. ".json"

    if not isfile(filepath) then
        return
    end

    local configdata = httpservice:JSONDecode(readfile(filepath))
    local appearance = configdata.Appearance or configdata.Options or {}
    local themename = appearance.Theme

    if type(themename) == "string" and library:SetTheme(themename) then
        preloadedtheme = themename
    end

    local function decodecolor(value)
        if type(value) == "table" and value.__type == "Color3" then
            return Color3.new(
                tonumber(value.red or value.r) or 1,
                tonumber(value.green or value.g) or 1,
                tonumber(value.blue or value.b) or 1
            )
        end

        return nil
    end

    local startcolor = decodecolor(appearance.GradientStart)
    local endcolor = decodecolor(appearance.GradientEnd)

    if startcolor or endcolor then
        local currentstart, currentend = library:GetGradientColors()
        library:SetGradientColors(startcolor or currentstart, endcolor or currentend)
    end
end)

local options = library.Options
local toggles = library.Toggles
--// loading

local loading = library:CreateLoading({
    Title = "slimekrew",
    Icon = icon,
    LoadingIcon = "loader-circle",
    LoadingIconTweenTime = 1,
    TotalSteps = 4,
    ShowSidebar = false,
    WindowWidth = 360,
    WindowHeight = 180,
    ContentWidth = 360,
    AutoResizeHeight = false,
})

local framerate, ping = getperformance()

loading:SetMessage("Starting")
loading:SetDescription("Creating window")
loading:SetCurrentStep(1)
task.wait(1.2)

loading:SetMessage("Executor")
loading:SetDescription(detectexecutor())
loading:SetCurrentStep(2)
task.wait(1.2)

loading:SetMessage("Performance")
loading:SetDescription(framerate .. " FPS · " .. ping)
loading:SetCurrentStep(3)
task.wait(1.2)

--// window

local window = library:CreateWindow({
    Title = "slimekrew",
    Footer = "realm rampage",
    Icon = icon,
    AutoShow = true,
    Center = true,
    Resizable = false,
    BuiltInSettings = true,
    BuiltInPlayerList = true,
    ProfileFolder = "Potas/realm-rampage/profiles",
    Size = UDim2.fromOffset(840, 510),
    CornerRadius = 12,
    LiquidGlass = false,
    Blur = false,
    DisableSearch = false,
    GlobalSearch = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Animations = {
        ToggleWindow = true,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true,
    },
    NotifySide = "Left",
    ShowCustomCursor = true,
})

local tabs = {
    main = window:AddTab("Main", "house"),
    visuals = window:AddTab("Visuals", "eye"),
    settings = window:AddTab("Settings", "settings"),
}

loading:SetMessage("Experience")
loading:SetDescription("Realm Rampage")
loading:SetCurrentStep(4)
task.wait(1.2)
loading:Continue()

local watermark = library:AddDraggableLabel({
    Text = "realm rampage | " .. framerate .. " fps | " .. ping,
    Icon = avatar,
    IconPosition = "left",
})

watermark:SetVisible(false)

--// main

local movementtabbox = tabs.main:AddLeftTabbox("Movement")
local movementtab = movementtabbox:AddTab("Movement")

movementtab:AddToggle("NoDashCooldown", {
    Text = "No Dash Cooldown",
    Default = false,
    Callback = function(value)
        setnodashcooldown(value)
        library:Notify({
            Title = "Movement",
            Description = value and "No dash cooldown enabled" or "No dash cooldown disabled",
            Time = 3,
        })
    end,
})

local combattabbox = tabs.main:AddRightTabbox("Combat")
local combattab = combattabbox:AddTab("Combat")

local fastm1toggle = combattab:AddToggle("FastM1", {
    Text = "Fast M1",
    Default = false,
    Callback = function(value)
        setfastm1(value)
        library:Notify({
            Title = "Combat",
            Description = value and "Fast M1 enabled" or "Fast M1 disabled",
            Time = 3,
        })
    end,
})

combattab:AddToggle("NoStun", {
    Text = "No Stun",
    Default = false,
    Callback = function(value)
        setnostun(value)
        library:Notify({
            Title = "Combat",
            Description = value and "No stun enabled" or "No stun disabled",
            Time = 3,
        })
    end,
})

combattab:AddToggle("AutoDomainClash", {
    Text = "Auto Domain Clash",
    Default = false,
    Callback = function(value)
        autodomainclash = value

        if value and activeclashvalue and activeclashvalue.Parent then
            startdomainclash(activeclashvalue)
        elseif not value then
            stopdomainclash()
        end

        library:Notify({
            Title = "Domain Clash",
            Description = value and "Automatic Space input enabled" or "Automatic Space input disabled",
            Time = 3,
        })
    end,
})

fastm1toggle:AddSlider("FastM1Multiplier", {
    Text = "Speed",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Compact = true,
    Callback = function(value)
        fastm1multiplier = value

        if fastm1 then
            applyfastm1()
        end
    end,
})

--// visuals

local playeresptabbox = tabs.visuals:AddLeftTabbox("Player ESP")
local playeresptab = playeresptabbox:AddTab("Player ESP")

playeresptab:AddToggle("PlayerESP", {
    Text = "Player ESP",
    Default = false,
    Callback = function(value)
        espenabled = value
    end,
})

playeresptab:AddToggle("SelfESP", {
    Text = "Self ESP",
    Default = false,
    Callback = function(value)
        selfesp = value

        if value then
            createespobject(localplayer)
        else
            removeespobject(localplayer)
        end
    end,
})

playeresptab:AddDropdown("ESPBoxType", {
    Text = "Box Type",
    Values = { "None", "Corner", "Box" },
    Default = "None",
    Multi = false,
    Callback = function(value)
        espboxtype = value
    end,
})

playeresptab:AddDropdown("ESPHealthDisplay", {
    Text = "Health Display",
    Values = { "Health Bar", "Health Text", "None" },
    Default = "Health Bar",
    Multi = false,
    Callback = function(value)
        esphealthdisplay = value
    end,
})

playeresptab:AddToggle("ESPHighlight", {
    Text = "Player Highlight",
    Default = false,
    Callback = function(value)
        esphighlight = value
    end,
})

playeresptab:AddToggle("ESPStunnedState", {
    Text = "Stunned State",
    Default = false,
    Callback = function(value)
        espstunnedstate = value
    end,
})

--// settings

local settingstabbox = tabs.settings:AddLeftTabbox("Menu")
local interfacetab = settingstabbox:AddTab("Interface")
local notificationtab = settingstabbox:AddTab("Notifications")
local gradientstart, gradientend = library:GetGradientColors()
local themes = library:GetThemes()

interfacetab:AddToggle("Cursor", {
    Text = "Custom Cursor",
    Default = library.ShowCustomCursor,
    Callback = function(value)
        library.ShowCustomCursor = value
    end,
})

interfacetab:AddToggle("Watermark", {
    Text = "Watermark",
    Default = false,
    Callback = function(value)
        watermark:SetVisible(value)
    end,
})

interfacetab:AddDropdown("Theme", {
    Text = "Theme",
    Values = themes,
    Default = preloadedtheme,
    Multi = false,
    Callback = function(value)
        if library:SetTheme(value) then
            local newstart, newend = library:GetGradientColors()

            if options.GradientStart then
                options.GradientStart:SetValue(newstart)
            end

            if options.GradientEnd then
                options.GradientEnd:SetValue(newend)
            end
        end
    end,
})

interfacetab:AddLabel("Gradient Start"):AddColorPicker("GradientStart", {
    Default = gradientstart,
    Title = "Gradient Start",
    Callback = function(value)
        local finish = options.GradientEnd and options.GradientEnd.Value or gradientend
        library:SetGradientColors(value, finish)
    end,
})

interfacetab:AddLabel("Gradient End"):AddColorPicker("GradientEnd", {
    Default = gradientend,
    Title = "Gradient End",
    Callback = function(value)
        local start = options.GradientStart and options.GradientStart.Value or gradientstart
        library:SetGradientColors(start, value)
    end,
})

interfacetab:AddLabel("Menu Key"):AddKeyPicker("MenuKey", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu Key",
    ChangedCallback = function(value)
        library.ToggleKeybind = value or Enum.KeyCode.RightShift
    end,
})

interfacetab:AddButton({
    Text = "Unload",
    Func = function()
        library:Unload()
    end,
})

notificationtab:AddDropdown("NotifySide", {
    Text = "Notification Side",
    Values = { "Left", "Right" },
    Default = "Left",
    Multi = false,
    Callback = function(value)
        library:SetNotifySide(value)
    end,
})

--// configs

local configtabbox = tabs.settings:AddRightTabbox("Configs")
local configtab = configtabbox:AddTab("Configs")
pcall(function()
    if makefolder then
        if isfolder and not isfolder("Potas") then
            makefolder("Potas")
        end

        if isfolder and not isfolder(folderpath) then
            makefolder(folderpath)
        end

        if isfolder and not isfolder(configpath) then
            makefolder(configpath)
        end
    end
end)

local function getconfigs()
    local confignames = {}

    if listfiles then
        local success, files = pcall(listfiles, configpath)

        if success then
            for _, filepath in ipairs(files) do
                local configname = filepath:match("([^/\\]+)%.json$")

                if configname then
                    table.insert(confignames, configname)
                end
            end
        end
    end

    table.sort(confignames)

    if #confignames == 0 then
        confignames[1] = "Default"
    end

    return confignames
end

local configlist = getconfigs()

configtab:AddDropdown("ConfigList", {
    Text = "Config",
    Values = configlist,
    Default = configlist[1],
    Multi = false,
})

configtab:AddInput("ConfigName", {
    Text = "Config name",
    Default = "",
    Placeholder = "Config name",
    Finished = true,
})

local selectedlabel = configtab:AddLabel("Selected: " .. configlist[1])
local autoloadlabel = configtab:AddLabel("Autoload: None")
local configcountlabel = configtab:AddLabel("Configs: " .. #configlist)

local function refreshconfigs()
    configlist = getconfigs()
    options.ConfigList:SetValues(configlist)

    if not table.find(configlist, options.ConfigList.Value) then
        options.ConfigList:SetValue(configlist[1])
    end

    selectedlabel:SetText("Selected: " .. tostring(options.ConfigList.Value))
    configcountlabel:SetText("Configs: " .. #configlist)
end

local function packvalue(value)
    if typeof(value) == "Color3" then
        return {
            __type = "Color3",
            red = value.R,
            green = value.G,
            blue = value.B,
        }
    end

    if type(value) == "table" then
        local packed = {}

        for key, nestedvalue in pairs(value) do
            packed[key] = packvalue(nestedvalue)
        end

        return packed
    end

    return value
end

local function unpackvalue(value)
    if type(value) == "table" and value.__type == "Color3" then
        return Color3.new(
            tonumber(value.red or value.r) or 1,
            tonumber(value.green or value.g) or 1,
            tonumber(value.blue or value.b) or 1
        )
    end

    if type(value) == "table" then
        local unpacked = {}

        for key, nestedvalue in pairs(value) do
            unpacked[key] = unpackvalue(nestedvalue)
        end

        return unpacked
    end

    return value
end

local function saveconfig(configname)
    if not writefile then
        return false, "filesystem unavailable"
    end

    configname = tostring(configname or ""):gsub("[^%w%-_]", "")

    if configname == "" then
        return false, "enter a config name"
    end

    local configdata = {
        Toggles = {},
        Options = {},
        Appearance = {
            Theme = options.Theme and options.Theme.Value or library.ActiveTheme,
            GradientStart = packvalue(select(1, library:GetGradientColors())),
            GradientEnd = packvalue(select(2, library:GetGradientColors())),
        },
    }

    for name, toggle in pairs(toggles) do
        if type(name) == "string" and type(toggle.Value) == "boolean" then
            configdata.Toggles[name] = toggle.Value
        end
    end

    for name, option in pairs(options) do
        if type(name) == "string" and not name:find("^Config") then
            local valuetype = typeof(option.Value)

            if valuetype == "string"
                or valuetype == "number"
                or valuetype == "boolean"
                or valuetype == "table"
                or valuetype == "Color3"
            then
                configdata.Options[name] = packvalue(option.Value)
            end
        end
    end

    local filepath = configpath .. "/" .. configname .. ".json"
    local success, saveerror = pcall(writefile, filepath, httpservice:JSONEncode(configdata))

    if success then
        refreshconfigs()
        return true, configname
    end

    return false, saveerror
end

local function loadconfig(configname)
    local filepath = configpath .. "/" .. tostring(configname) .. ".json"

    if not (readfile and isfile and isfile(filepath)) then
        return false, "config not found"
    end

    local success, configdata = pcall(function()
        return httpservice:JSONDecode(readfile(filepath))
    end)

    if not success or type(configdata) ~= "table" then
        return false, "invalid config"
    end

    local appearance = configdata.Appearance or {}

    if appearance.Theme and options.Theme then
        pcall(options.Theme.SetValue, options.Theme, appearance.Theme)
    end

    if appearance.GradientStart and options.GradientStart then
        pcall(options.GradientStart.SetValue, options.GradientStart, unpackvalue(appearance.GradientStart))
    end

    if appearance.GradientEnd and options.GradientEnd then
        pcall(options.GradientEnd.SetValue, options.GradientEnd, unpackvalue(appearance.GradientEnd))
    end

    for name, value in pairs(configdata.Toggles or {}) do
        if toggles[name] then
            pcall(toggles[name].SetValue, toggles[name], value)
        end
    end

    if configdata.Options and configdata.Options.Theme and options.Theme then
        pcall(options.Theme.SetValue, options.Theme, unpackvalue(configdata.Options.Theme))
    end

    for name, value in pairs(configdata.Options or {}) do
        if name ~= "Theme" and options[name] then
            pcall(options[name].SetValue, options[name], unpackvalue(value))
        end
    end

    selectedlabel:SetText("Selected: " .. tostring(configname))
    return true, configname
end

configtab:AddButton({
    Text = "Save",
    Func = function()
        local success, result = saveconfig(options.ConfigName.Value)
        library:Notify({
            Title = "Configs",
            Description = success and ("Saved " .. result) or tostring(result),
            Time = 3,
        })
    end,
})

configtab:AddButton({
    Text = "Load",
    Func = function()
        local success, result = loadconfig(options.ConfigList.Value)
        library:Notify({
            Title = "Configs",
            Description = success and ("Loaded " .. result) or tostring(result),
            Time = 3,
        })
    end,
})

configtab:AddButton({
    Text = "Set Autoload",
    Func = function()
        local configname = tostring(options.ConfigList.Value)
        local success = writefile and pcall(writefile, autoloadpath, configname)

        if success then
            autoloadlabel:SetText("Autoload: " .. configname)
        end

        library:Notify({
            Title = "Configs",
            Description = success and (configname .. " set to autoload") or "filesystem unavailable",
            Time = 3,
        })
    end,
})

configtab:AddButton({
    Text = "Delete",
    Func = function()
        local configname = tostring(options.ConfigList.Value)
        local filepath = configpath .. "/" .. configname .. ".json"
        local success = delfile and isfile and isfile(filepath) and pcall(delfile, filepath)

        refreshconfigs()
        library:Notify({
            Title = "Configs",
            Description = success and ("Deleted " .. configname) or "config not found",
            Time = 3,
        })
    end,
})

--// cleanup

pcall(function()
    if isfile and readfile and isfile(autoloadpath) then
        local configname = readfile(autoloadpath)
        autoloadlabel:SetText("Autoload: " .. configname)

        if table.find(configlist, configname) then
            options.ConfigList:SetValue(configname)
            loadconfig(configname)
        end
    end
end)

library.ToggleKeybind = Enum.KeyCode.RightShift

library:OnUnload(function()
    setnodashcooldown(false)
    setfastm1(false)
    setnostun(false)
    autodomainclash = false
    stopdomainclash()

    if clashconnection then
        clashconnection:Disconnect()
        clashconnection = nil
    end

    if dashconnection then
        dashconnection:Disconnect()
        dashconnection = nil
    end

    if m1connection then
        m1connection:Disconnect()
        m1connection = nil
    end

    if playerdescendantconnection then
        playerdescendantconnection:Disconnect()
        playerdescendantconnection = nil
    end

    if characteraddedconnection then
        characteraddedconnection:Disconnect()
        characteraddedconnection = nil
    end

    if characterdescendantconnection then
        characterdescendantconnection:Disconnect()
        characterdescendantconnection = nil
    end

    if animationconnection then
        animationconnection:Disconnect()
        animationconnection = nil
    end

    if espconnection then
        espconnection:Disconnect()
        espconnection = nil
    end

    if playeraddedconnection then
        playeraddedconnection:Disconnect()
        playeraddedconnection = nil
    end

    if playerremovingconnection then
        playerremovingconnection:Disconnect()
        playerremovingconnection = nil
    end

    if environment.potasrealmesp then
        environment.potasrealmesp:Destroy()
        environment.potasrealmesp = nil
    end

    table.clear(espobjects)

    environment.potasrealmui = nil
end)

environment.potasrealmui = library

library:Notify({
    Title = "Realm Rampage",
    Description = "Loaded",
    Time = 3,
})
