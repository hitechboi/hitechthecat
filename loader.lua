--// vars

local libraryurl = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"
local iconurl = "https://www.image2url.com/r2/default/images/1785368907766-d375b142-01d6-45be-a9fc-ae3e07254a85.jpg"
local scripts = {
    [17129858194] = {
        name = "Realm Rampage",
        url = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/realm.lua",
    },
    [122700472919801] = {
        name = "Pantsir",
        url = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/pantsir.lua",
    },
    [91454039647130] = {
        name = "Roxball",
        url = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/roxball.lua",
    },
}
local sleeponmegumi = {
    name = "Sleep on Megumi",
    url = "https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/SleeponMegumi.lua",
}

--// funcs

local function fetch(url)
    local cachebuster = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
    return game:HttpGet(url .. (url:find("?", 1, true) and "&" or "?") .. "cachebust=" .. cachebuster, true)
end

local function compile(source, name)
    local chunk, compileerror = loadstring(source, name)
    assert(chunk, compileerror)
    return chunk
end

--// loader

local target = scripts[game.PlaceId]
if not target and game:GetService("ReplicatedStorage"):FindFirstChild("KillAllEvent") then
    target = sleeponmegumi
end
local library = compile(fetch(libraryurl), "slimekrew Library")()
local loading = library:CreateLoading({
    Title = "slimekrew",
    Icon = iconurl,
    LoadingIcon = "loader-circle",
    LoadingIconTweenTime = 1,
    TotalSteps = 4,
    ShowSidebar = false,
})

loading:SetMessage("Detecting experience")
loading:SetDescription(target and target.name or ("Unsupported place: " .. tostring(game.PlaceId)))
loading:SetCurrentStep(1)
task.wait(0.8)

if not target then
    loading:SetMessage("Unsupported experience")
    loading:SetDescription("No script is registered for this place")
    loading:SetCurrentStep(4)
    task.wait(2)
    loading:Continue()
    return
end

loading:SetMessage("Downloading")
loading:SetDescription(target.name)
loading:SetCurrentStep(2)

local success, source = pcall(fetch, target.url)
if not success then
    loading:SetMessage("Download failed")
    loading:SetDescription(tostring(source))
    task.wait(2)
    loading:Continue()
    return
end

loading:SetMessage("Compiling")
loading:SetDescription(target.name)
loading:SetCurrentStep(3)

local compiled, chunk = pcall(compile, source, target.name)
if not compiled then
    loading:SetMessage("Compile failed")
    loading:SetDescription(tostring(chunk))
    task.wait(2)
    loading:Continue()
    return
end

loading:SetMessage("Launching")
loading:SetDescription(target.name)
loading:SetCurrentStep(4)
task.wait(0.65)
loading:Continue()

local executed, runtimeerror = pcall(chunk)
if not executed then
    library:Notify({
        Title = "Loader",
        Description = tostring(runtimeerror),
        Time = 6,
    })
end
