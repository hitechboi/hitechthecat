local g=getgenv()
local ps=game:GetService("Players")
local rs=game:GetService("ReplicatedStorage")
local is=game:GetService("UserInputService")
local st=game:GetService("Stats")
local lp=ps.LocalPlayer
local url="https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"
local img="https://www.image2url.com/r2/default/images/1785368907766-d375b142-01d6-45be-a9fc-ae3e07254a85.jpg"
if g.RoxballUI then pcall(function()g.RoxballUI:Unload()end)g.RoxballUI=nil end
if _G.pk then pcall(function()_G.pk:Disconnect()end)_G.pk=nil end
local src=game:HttpGet(url.."?t="..os.time())
src=src:gsub("SafeParentUI%(UI, gethui%)",'SafeParentUI(UI, Library.LocalPlayer:WaitForChild("PlayerGui", math.huge))')
local f,e=loadstring(src)
assert(f,"UI library compile failed: "..tostring(e))
local l=f()
local function asset(v)
    local ga=getcustomasset or getsynasset
    if not(writefile and ga)then return"rbxassetid://95236382788593"end
    pcall(function()if makefolder and isfolder and not isfolder("Potas")then makefolder("Potas")end end)
    local pth="Potas/roxball.jpg"
    if not isfile or not isfile(pth)then
        local ok=pcall(writefile,pth,game:HttpGet(v))
        if not ok then return"rbxassetid://95236382788593"end
    end
    local ok,id=pcall(ga,pth)
    return ok and id or"rbxassetid://95236382788593"
end
local ic=asset(img)
local av=ic
pcall(function()av=ps:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)end)
local function ex()
    for _,v in ipairs({identifyexecutor or false,getexecutorname or false})do
        if type(v)=="function"then
            local ok,n=pcall(v)
            if ok and n and tostring(n)~=""then return tostring(n)end
        end
    end
    return"Unknown"
end
local function stats()
    local fps="Unknown"
    local ping="Unknown"
    pcall(function()fps=tostring(math.floor(workspace:GetRealPhysicsFPS()+.5))end)
    pcall(function()ping=st.Network.ServerStatsItem["Data Ping"]:GetValueString()end)
    return fps,ping
end
l.LiquidGlass=false
l.BlurEnabled=false
l.Scheme.BackgroundColor=Color3.fromRGB(27,28,33)
l.Scheme.MainColor=Color3.fromRGB(40,42,48)
l.Scheme.AccentColor=Color3.fromRGB(224,226,230)
l.Scheme.OutlineColor=Color3.fromRGB(76,79,88)
local ld=l:CreateLoading({
    Title="slimekrew",
    Icon=ic,
    LoadingIcon="loader-circle",
    LoadingIconTweenTime=1,
    TotalSteps=3,
    ShowSidebar=false,
    WindowWidth=320,
    WindowHeight=88,
    AutoResizeHeight=false
})
local fps,ping=stats()
ld:SetMessage("Executor")
ld:SetDescription(ex())
ld:SetCurrentStep(1)
task.wait(1)
ld:SetMessage("Performance")
ld:SetDescription(fps.." FPS · "..ping)
ld:SetCurrentStep(2)
local w=l:CreateWindow({
    Title="slimekrew",
    Footer="roxball",
    Icon=ic,
    Size=UDim2.fromOffset(840,510),
    AutoShow=true,
    Center=true,
    Resizable=true,
    CornerRadius=2,
    LiquidGlass=false,
    Blur=false,
    DisableSearch=false,
    GlobalSearch=true,
    ToggleKeybind=Enum.KeyCode.RightShift,
    NotifySide="Left",
    ShowCustomCursor=true,
    Animations={ToggleWindow=true,TabSwitch=true,Groupbox=true,Dropdown=true,KeyPicker=true}
})
local bt=w:AddTab("Ball","circle")
local se=w:AddTab("Settings","settings")
local p=300
local s=48
local d=50
local hk=Enum.KeyCode.CapsLock
local sk=Enum.KeyCode.Space
local enabled=true
local rm=require(rs:WaitForChild("Project"):WaitForChild("Network"):WaitForChild("Remotes"))
local kb=rm.KickBall:Client()
local function root()
    local c=lp.Character or lp.CharacterAdded:Wait()
    return c:WaitForChild("HumanoidRootPart")
end
local function ball()
    local r=root()
    local b
    local near=d
    for _,v in ipairs(workspace:GetDescendants())do
        if v:IsA("BasePart")and v.Name=="Ball"then
            local m=(v.Position-r.Position).Magnitude
            if m<=near then b=v near=m end
        end
    end
    return b
end
local function dir()
    local v=workspace.CurrentCamera.CFrame.LookVector
    v=Vector3.new(v.X,0,v.Z)
    return v.Magnitude==0 and Vector3.new(0,0,1)or v.Unit
end
local function hit(n)
    if not enabled then return end
    local b=ball()
    if b then kb:Fire(b,dir(),n)end
end
local kl=bt:AddLeftTabbox("Kicking")
local kh=kl:AddTab("Hard Kick")
local kd=kl:AddTab("Dribble")
local br=bt:AddRightTabbox("Ball")
local rg=br:AddTab("Detection")
kh:AddToggle("KickEnabled",{Text="Kick Controls",Default=true,Callback=function(v)enabled=v end})
kh:AddSlider("KickPower",{Text="Kick Power",Default=p,Min=1,Max=500,Rounding=0,Callback=function(v)p=v end})
kh:AddLabel("Hard Kick Key"):AddKeyPicker("HardKickKey",{Default="CapsLock",NoUI=true,Text="Hard Kick",ChangedCallback=function(v)if v then hk=v end end})
kh:AddButton({Text="Kick",Func=function()hit(p)end})
kd:AddSlider("DribblePower",{Text="Dribble Power",Default=s,Min=1,Max=250,Rounding=0,Callback=function(v)s=v end})
kd:AddLabel("Dribble Key"):AddKeyPicker("DribbleKey",{Default="Space",NoUI=true,Text="Dribble",ChangedCallback=function(v)if v then sk=v end end})
kd:AddButton({Text="Dribble",Func=function()hit(s)end})
rg:AddSlider("BallDistance",{Text="Search Distance",Default=d,Min=5,Max=250,Rounding=0,Callback=function(v)d=v end})
local wm=l:AddDraggableLabel({Text="roxball | "..fps.." fps | "..ping,Icon=av,IconPosition="left"})
local sb=se:AddLeftTabbox("Menu")
local si=sb:AddTab("Interface")
local sn=sb:AddTab("Notifications")
si:AddToggle("Cursor",{Text="Custom Cursor",Default=l.ShowCustomCursor,Callback=function(v)l.ShowCustomCursor=v end})
si:AddToggle("Watermark",{Text="Watermark",Default=true,Callback=function(v)wm:SetVisible(v)end})
si:AddLabel("Menu Key"):AddKeyPicker("MenuKey",{Default="RightShift",NoUI=true,Text="Menu Key",ChangedCallback=function(v)l.ToggleKeybind=v or Enum.KeyCode.RightShift end})
si:AddButton({Text="Unload",Func=function()l:Unload()end})
sn:AddDropdown("NotifySide",{Text="Notification Side",Values={"Left","Right"},Default="Left",Multi=false,Callback=function(v)l:SetNotifySide(v)end})
l.ToggleKeybind=Enum.KeyCode.RightShift
local con=is.InputBegan:Connect(function(v,gp)
    if gp or is:GetFocusedTextBox()or not enabled then return end
    if v.KeyCode==hk then hit(p)elseif v.KeyCode==sk then hit(s)end
end)
l:OnUnload(function()
    if con then con:Disconnect()end
    if g.RoxballUI==l then g.RoxballUI=nil end
end)
g.RoxballUI=l
ld:SetMessage("Ready")
ld:SetDescription("Controls loaded")
ld:SetCurrentStep(3)
task.wait(1)
ld:Continue()
wm:SetVisible(true)
l:Notify({Title="roxball",Description="Controls loaded",Time=3})
