--// vars

local environment = getgenv()
local replicatedstorage = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")
local stats = game:GetService("Stats")
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
local watermark = library:AddDraggableLabel({
    Text = "slimekrew | sleep on megumi | 0 fps | 0ms",
    IconPosition = "left",
})
local performanceframes = 0
local performanceelapsed = 0
local performanceconnection = runservice.RenderStepped:Connect(function(deltatime)
    performanceframes += 1
    performanceelapsed += deltatime
    if performanceelapsed < 0.5 then return end

    local currentfps = math.floor(performanceframes / performanceelapsed + 0.5)
    local currentping = 0
    pcall(function()
        currentping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
    end)
    watermark:SetText("slimekrew | sleep on megumi | " .. currentfps .. " fps | " .. currentping .. "ms")
    performanceframes = 0
    performanceelapsed = 0
end)

watermark:SetVisible(false)

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
    if performanceconnection then
        performanceconnection:Disconnect()
        performanceconnection = nil
    end
    if environment.slimekrewsleeponmegumi == library then
        environment.slimekrewsleeponmegumi = nil
    end
end)

environment.slimekrewsleeponmegumi = library
