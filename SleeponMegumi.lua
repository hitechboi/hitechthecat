--// vars

local environment = getgenv()
local replicatedstorage = game:GetService("ReplicatedStorage")
local libraryurl = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"
local source = game:HttpGet(libraryurl .. "?cachebust=" .. tostring(os.time()), true)
local compile, compileerror = loadstring(source)

assert(compile, "slimekrew library failed: " .. tostring(compileerror))

if environment.slimekrewsleeponmegumi then
    pcall(function()
        environment.slimekrewsleeponmegumi:Unload()
    end)
end

local library = compile()
local window = library:CreateWindow({
    Title = "slimekrew",
    Footer = "sleep on megumi",
    BuiltInSettings = true,
    BuiltInPlayerList = true,
    ProfileFolder = "Potas/sleep-on-megumi/profiles",
    ToggleKeybind = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(840, 510),
    Resizable = false,
})
local maintab = window:AddTab("Main", "house")
local mainbox = maintab:AddLeftGroupbox("Main")
local settingstab = window:AddTab("Settings", "settings")

settingstab:AddLeftTabbox("Menu")

--// ui

mainbox:AddButton({
    Text = "Kill All",
    Func = function()
        replicatedstorage:WaitForChild("KillAllEvent"):FireServer()
    end,
})

--// cleanup

library.ToggleKeybind = Enum.KeyCode.RightShift
library:OnUnload(function()
    if environment.slimekrewsleeponmegumi == library then
        environment.slimekrewsleeponmegumi = nil
    end
end)

environment.slimekrewsleeponmegumi = library
