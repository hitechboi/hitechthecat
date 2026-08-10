--// links

local libraryurl = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/library2.lua"

--// services

local players = game:GetService("Players")
local userinputservice = game:GetService("UserInputService")
local runservice = game:GetService("RunService")

--// vars

local localplayer = players.LocalPlayer
local source = game:HttpGet(libraryurl .. "?cachebust=" .. tostring(os.time()), true)
local compile, compileerror = loadstring(source, "slimekrew library2")

assert(compile, compileerror)

local library = compile()
local loading = library:CreateLoading({Title = "Loading slimekrew", Text = "Preparing baseplate template"})
local settings = {
    fov = false,
    fovvalue = 90,
    walkspeed = false,
    walkspeedvalue = 32,
    infinitejump = false,
}
local runtimeconnections = {}

--// funcs

local function humanoid()
    local character = localplayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function applywalkspeed()
    local target = humanoid()
    if target then target.WalkSpeed = settings.walkspeed and settings.walkspeedvalue or 16 end
end

--// loading

loading:SetProgress(0.35)
loading:SetText("Creating interface...")

local window = library:CreateWindow({
    Title = "slimekrew baseplate",
    Icon = library.icons.Logo,
    ToggleKey = Enum.KeyCode.RightShift,
})

local main = window:AddTab("Misc", library.icons.Misc)
local movement = main:AddSubtab("Movement")
local camera = main:AddSubtab("Camera")

local movementsection = movement:AddSection("Player Movement", "Left")
movementsection:AddToggle({Text = "WalkSpeed", Flag = "WalkSpeed", Callback = function(value)
    settings.walkspeed = value
    applywalkspeed()
end})
movementsection:AddSlider({Text = "WalkSpeed Value", Flag = "WalkSpeedValue", Min = 16, Max = 200, Default = 32, Callback = function(value)
    settings.walkspeedvalue = value
    applywalkspeed()
end})
movementsection:AddToggle({Text = "Infinite Jump", Flag = "InfiniteJump", Callback = function(value)
    settings.infinitejump = value
end})

local camerasection = camera:AddSection("Camera", "Left")
camerasection:AddToggle({Text = "Custom FOV", Flag = "CustomFOV", Callback = function(value)
    settings.fov = value
end})
camerasection:AddSlider({Text = "FOV", Flag = "FOVValue", Min = 40, Max = 120, Default = 90, Callback = function(value)
    settings.fovvalue = value
end})
camerasection:AddButton({Text = "Reset Camera", Callback = function()
    settings.fovvalue = 70
    workspace.CurrentCamera.FieldOfView = 70
    library.options.FOVValue:SetValue(70, true)
    library:Notify({Text = "Camera reset"})
end})

local visualspage = window:AddTab("Visuals", library.icons.Visuals)
local visualsgeneral = visualspage:AddSubtab("General")
visualsgeneral:AddSection("Visuals", "Left"):AddLabel("Add visual features here")

local worldpage = window:AddTab("World", library.icons.World)
local worldgeneral = worldpage:AddSubtab("General")
worldgeneral:AddSection("World", "Left"):AddLabel("Add world features here")

local playerspage = window:AddTab("Players", library.icons.Players)
local playersgeneral = playerspage:AddSubtab("Player List")
playersgeneral:AddSection("Players", "Left"):AddLabel("Player controls appear here")

local settingspage = window:AddTab("Settings", library.icons.Settings)
local interface = settingspage:AddSubtab("Interface")
local profiles = settingspage:AddSubtab("Profiles")
local themes = settingspage:AddSubtab("Themes")
local interfacesection = interface:AddSection("Interface", "Left")
interfacesection:AddLabel("Menu Key: RightShift")
interfacesection:AddButton({Text = "Unload", Callback = function()
    library:Destroy()
end})
local notificationsection = interface:AddSection("Notifications", "Right")
notificationsection:AddSlider({Text = "Duration", Flag = "NotificationDuration", Min = 1, Max = 10, Default = 3, Suffix = "s"})
notificationsection:AddButton({Text = "Test Notification", Callback = function()
    library:Notify({Text = "Notification preview", Duration = library.options.NotificationDuration.Value})
end})

local profilesection = profiles:AddSection("Profiles", "Left")
profilesection:AddDropdown({Text = "Selected Profile", Flag = "SelectedProfile", Values = {"Default", "Legit", "Performance"}, Default = "Default"})
profilesection:AddButton({Text = "Save Profile", Callback = function()
    local name = library.options.SelectedProfile.Value
    library:SaveProfile(name)
    library:Notify({Text = name .. " profile saved"})
end})
profilesection:AddButton({Text = "Load Profile", Callback = function()
    local name = library.options.SelectedProfile.Value
    library:LoadProfile(name)
    library:Notify({Text = name .. " profile loaded"})
end})
profilesection:AddButton({Text = "Set Autoload", Callback = function()
    library.autoload = library.options.SelectedProfile.Value
    library:Notify({Text = library.autoload .. " set to autoload"})
end})

local themesection = themes:AddSection("Theme Presets", "Left")
themesection:AddDropdown({Text = "Theme", Flag = "MenuTheme", Values = {"Silver", "Graphite", "Midnight"}, Default = "Silver", Callback = function(value)
    if value == "Silver" then
        library:SetTheme(Color3.fromRGB(255, 255, 255), Color3.fromRGB(142, 147, 158))
    elseif value == "Midnight" then
        library:SetTheme(Color3.fromRGB(20, 35, 67), Color3.fromRGB(73, 104, 166))
    else
        library:SetTheme(Color3.fromRGB(210, 214, 224), Color3.fromRGB(94, 100, 114))
    end
end})
local studiocolor = {sr = 255, sg = 255, sb = 255, er = 142, eg = 147, eb = 158}
local function applystudio()
    library:SetTheme(Color3.fromRGB(studiocolor.sr, studiocolor.sg, studiocolor.sb), Color3.fromRGB(studiocolor.er, studiocolor.eg, studiocolor.eb))
end
local studio = themes:AddSection("Advanced Theme Studio", "Right")
studio:AddToggle({Text = "Animated Gradients", Flag = "AnimatedGradients", Default = true, Callback = function(value) library:SetGradientsEnabled(value) end})
studio:AddSlider({Text = "Animation Speed", Flag = "GradientSpeed", Min = 1, Max = 50, Default = 14, Callback = function(value) library:SetGradientSpeed(value / 10) end})
studio:AddSlider({Text = "Corner Radius", Flag = "CornerRadius", Min = 0, Max = 18, Default = 6, Callback = function(value) library:SetCornerRadius(value) end})
studio:AddSlider({Text = "Start Red", Flag = "ThemeStartRed", Min = 0, Max = 255, Default = 255, Callback = function(value) studiocolor.sr = value; applystudio() end})
studio:AddSlider({Text = "Start Green", Flag = "ThemeStartGreen", Min = 0, Max = 255, Default = 255, Callback = function(value) studiocolor.sg = value; applystudio() end})
studio:AddSlider({Text = "Start Blue", Flag = "ThemeStartBlue", Min = 0, Max = 255, Default = 255, Callback = function(value) studiocolor.sb = value; applystudio() end})
studio:AddSlider({Text = "End Red", Flag = "ThemeEndRed", Min = 0, Max = 255, Default = 142, Callback = function(value) studiocolor.er = value; applystudio() end})
studio:AddSlider({Text = "End Green", Flag = "ThemeEndGreen", Min = 0, Max = 255, Default = 147, Callback = function(value) studiocolor.eg = value; applystudio() end})
studio:AddSlider({Text = "End Blue", Flag = "ThemeEndBlue", Min = 0, Max = 255, Default = 158, Callback = function(value) studiocolor.eb = value; applystudio() end})

local legacysection = profiles:AddSection("Quick Actions", "Right")
legacysection:AddButton({Text = "Save Default Profile", Callback = function()
    library:SaveProfile("Default")
    library:Notify({Text = "Default profile saved"})
end})
legacysection:AddButton({Text = "Load Default Profile", Callback = function()
    library:LoadProfile("Default")
    library:Notify({Text = "Default profile loaded"})
end})

loading:SetProgress(0.8)
loading:SetText("Connecting features...")

table.insert(runtimeconnections, userinputservice.JumpRequest:Connect(function()
    if settings.infinitejump then
        local target = humanoid()
        if target then target:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

table.insert(runtimeconnections, runservice.RenderStepped:Connect(function()
    local cameraobject = workspace.CurrentCamera
    if cameraobject then cameraobject.FieldOfView = settings.fov and settings.fovvalue or 70 end
    if settings.walkspeed then applywalkspeed() end
end))

table.insert(runtimeconnections, localplayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    applywalkspeed()
end))

library:OnUnload(function()
    for _, connection in ipairs(runtimeconnections) do connection:Disconnect() end
    local target = humanoid()
    if target then target.WalkSpeed = 16 end
    local cameraobject = workspace.CurrentCamera
    if cameraobject then cameraobject.FieldOfView = 70 end
end)

loading:SetProgress(1)
loading:SetText("Ready")
task.wait(0.4)
loading:Close()
library:Notify({Text = "Baseplate template loaded"})
