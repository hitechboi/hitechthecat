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

local settingspage = window:AddTab("Settings", library.icons.Settings)
local interface = settingspage:AddSubtab("Interface")
local interfacesection = interface:AddSection("Interface", "Left")
interfacesection:AddButton({Text = "Save Default Profile", Callback = function()
    library:SaveProfile("Default")
    library:Notify({Text = "Default profile saved"})
end})
interfacesection:AddButton({Text = "Load Default Profile", Callback = function()
    library:LoadProfile("Default")
    library:Notify({Text = "Default profile loaded"})
end})
interfacesection:AddButton({Text = "Unload", Callback = function()
    library:Unload()
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
