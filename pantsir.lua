local g=getgenv()
local r="https://raw.githubusercontent.com/hitechboi/hitechthecat/refs/heads/main/Library.lua"
local x="https://www.image2url.com/r2/default/images/1785368907766-d375b142-01d6-45be-a9fc-ae3e07254a85.jpg"
if g.SlimekrewUI then pcall(function()g.SlimekrewUI:Unload()end)g.SlimekrewUI=nil end
pcall(function()
    local h=gethui and gethui() or game:GetService("CoreGui")
    for _,v in ipairs(h:GetChildren())do
        if v.Name=="ObsidianLoading"then v:Destroy()end
    end
end)
local cb=tostring(os.time()).."-"..tostring(math.random(100000,999999))
local s=game:HttpGet(r.."?cachebust="..cb,true)
local c,e=loadstring(s)
assert(c,"UI library compile failed: "..tostring(e))
local l=c()
assert(type(l)=="table","UI library returned "..type(l).." instead of a table")
local function ex()
    for _,f in ipairs({identifyexecutor or false,getexecutorname or false})do
        if type(f)=="function"then
            local ok,n=pcall(f)
            if ok and n and tostring(n)~=""then return tostring(n)end
        end
    end
    return "Unknown"
end
local function stats()
    local fps="Unknown"
    local ok,v=pcall(function()return math.floor(workspace:GetRealPhysicsFPS()+0.5)end)
    if ok and v then fps=tostring(v)end
    local ping="Unknown"
    ok,v=pcall(function()return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()+.5)end)
    if ok and v then ping=tostring(v).."ms"end
    return fps,ping
end
local function a(v)
    local ga=getcustomasset or getsynasset
    if not (writefile and ga) then return "rbxassetid://95236382788593" end
    if makefolder and isfolder and not isfolder("Potas") then makefolder("Potas") end
    local p="Potas/slimekrew.jpg"
    if not isfile or not isfile(p) then
        local ok=pcall(writefile,p,game:HttpGet(v))
        if not ok then return "rbxassetid://95236382788593" end
    end
    local ok,id=pcall(ga,p)
    return ok and id or "rbxassetid://95236382788593"
end
local i=a(x)
local av=i
pcall(function()
    av=game:GetService("Players"):GetUserThumbnailAsync(
        game:GetService("Players").LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size150x150
    )
end)
local gn=game.Name
pcall(function()
    local d=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if d and d.Name and d.Name~=""then gn=d.Name end
end)
l.LiquidGlass=false
l.BlurEnabled=false
l.CornerRadius=12
l.Scheme.BackgroundColor=Color3.fromRGB(27,28,33)
l.Scheme.MainColor=Color3.fromRGB(40,42,48)
l.Scheme.AccentColor=Color3.fromRGB(224,226,230)
l.Scheme.OutlineColor=Color3.fromRGB(76,79,88)
local o=l.Options
local u=l.Toggles
local z=l:CreateLoading({
    Title="slimekrew",
    Icon=i,
    LoadingIcon="loader-circle",
    LoadingIconTweenTime=1,
    TotalSteps=5,
    ShowSidebar=false,
    WindowWidth=360,
    WindowHeight=180,
    ContentWidth=360,
    SidebarWidth=180,
    AutoResizeHeight=false
})
local lf,lp=stats()
z:SetMessage("Starting")
z:SetDescription("Creating window")
z:SetCurrentStep(1)
task.wait(1.5)
z:SetMessage("Executor")
z:SetDescription(ex())
z:SetCurrentStep(2)
task.wait(1.5)
z:SetMessage("Performance")
z:SetDescription(lf.." FPS · "..lp)
z:SetCurrentStep(3)
task.wait(1.5)
local w=l:CreateWindow({
    Title="slimekrew",
    Footer="pantsir",
    Icon=i,
    AutoShow=true,
    Center=true,
    Resizable=false,
    BuiltInSettings=true,
    BuiltInPlayerList=true,
    ProfileFolder="Potas/pantsir/profiles",
    Size=UDim2.fromOffset(840,510),
    CornerRadius=12,
    LiquidGlass=false,
    Blur=false,
    DisableSearch=false,
    GlobalSearch=true,
    ToggleKeybind=Enum.KeyCode.RightShift,
    Animations={
        ToggleWindow=true,
        TabSwitch=true,
        Groupbox=true,
        Dropdown=true,
        KeyPicker=true
    },
    NotifySide="Left",
    ShowCustomCursor=true
})
local t={
    r=w:AddTab("Player","user"),
    t=w:AddTab("Teleport","map-pin"),
    v=w:AddTab("Visuals","eye"),
    s=w:AddTab("Settings","settings")
}
z:SetDescription("Building controls")
z:SetMessage("Experience")
z:SetDescription(gn)
z:SetCurrentStep(4)
task.wait(1.5)
local q=l:AddDraggableLabel({Text="pantsir | "..lf.." fps | "..lp,Icon=av,IconPosition="left"})
q:SetVisible(false)
local mb=t.r:AddLeftTabbox("Movement")
local mv=mb:AddTab("General")
local ms=mb:AddTab("Speed")
local mj=mb:AddTab("Jump")
mv:AddToggle("WalkSpeed",{Text="WalkSpeed",Default=false}):AddKeyPicker("WalkSpeedKey",{Default="V",SyncToggleState=true,Mode="Toggle",Text="WalkSpeed"})
ms:AddSlider("WalkSpeedValue",{Text="WalkSpeed",Default=32,Min=16,Max=200,Rounding=0})
mj:AddToggle("InfiniteJump",{Text="Infinite Jump",Default=false})
local fb=t.r:AddRightTabbox("Freecam")
local fr=fb:AddTab("Camera")
local frr=fb:AddTab("Controls")
fr:AddToggle("Freecam",{Text="Freecam",Default=false}):AddKeyPicker("FreecamKey",{Default="C",SyncToggleState=true,Mode="Toggle",Text="Freecam"})
frr:AddSlider("FreecamSpeed",{Text="Freecam Speed",Default=50,Min=5,Max=300,Rounding=0})
local eb=t.v:AddLeftTabbox("ESP")
local e=eb:AddTab("Players")
local es=eb:AddTab("Style")
local ec=eb:AddTab("Checks")
e:AddToggle("PlayerEsp",{Text="Player ESP",Default=false})
e:AddToggle("PlayerHealthBar",{Text="Health Bar",Default=false})
es:AddDropdown("PlayerBox",{Text="Box Type",Values={"Corner","Box","None"},Default="Corner",Multi=false})
es:AddToggle("PlayerHighlight",{Text="Player Highlight",Default=false}):AddColorPicker("PlayerColor",{Default=Color3.fromRGB(255,70,70),Title="Player Highlight"})
es:AddLabel("Health Bar Color"):AddColorPicker("HealthBarColor",{Default=Color3.fromRGB(100,255,120),Title="Health Bar Color"})
ec:AddToggle("TeamCheck",{Text="Team Check",Default=false})
local xb=t.v:AddRightTabbox("World ESP")
local x=xb:AddTab("Drones")
local xa=xb:AddTab("Anti Air")
local xm=xb:AddTab("Missiles")
x:AddToggle("DroneEsp",{Text="Drone ESP",Default=false})
x:AddToggle("DroneHighlight",{Text="Drone Highlight",Default=false}):AddColorPicker("DroneColor",{Default=Color3.fromRGB(70,170,255),Title="Drone Highlight"})
xa:AddToggle("AAEsp",{Text="Anti Air ESP",Default=false})
xa:AddToggle("AAHighlight",{Text="Anti Air Highlight",Default=false}):AddColorPicker("AAColor",{Default=Color3.fromRGB(255,170,55),Title="Anti Air Highlight"})
xm:AddToggle("MissileEsp",{Text="Missile ESP",Default=false})
xm:AddToggle("MissileHighlight",{Text="Missile Highlight",Default=false}):AddColorPicker("MissileColor",{Default=Color3.fromRGB(255,80,80),Title="Missile Highlight"})
local p=game:GetService("Players")
local n=game:GetService("RunService")
local is=game:GetService("UserInputService")
local cas=game:GetService("ContextActionService")
local stt=game:GetService("Stats")
local y=p.LocalPlayer
local function tp(nm)
    local m=workspace:FindFirstChild("AllMapWithRespawn")
    m=m and m:FindFirstChild("CurrentMap")
    local d=m and m:FindFirstChild("Teleports")
    d=d and d:FindFirstChild("Defenders")
    d=d and d:FindFirstChild(nm)
    local c=y.Character
    if not d or not c then
        l:Notify({Title="Teleport",Description=nm.." destination unavailable",Time=3})
        return
    end
    local cf
    if d:IsA("BasePart")then cf=d.CFrame
    elseif d:IsA("Model")then cf=d:GetPivot()
    elseif d:IsA("Attachment")then cf=d.WorldCFrame end
    if not cf then
        l:Notify({Title="Teleport",Description=nm.." has no usable position",Time=3})
        return
    end
    c:PivotTo(cf+Vector3.new(0,5,0))
    l:Notify({Title="Teleport",Description="Teleported to "..nm,Time=3})
end
local tb=t.t:AddLeftTabbox("Defenders")
local tg=tb:AddTab("Locations")
tg:AddButton({Text="Tor",Func=function()tp("Tor")end})
tg:AddButton({Text="Strela",Func=function()tp("Strela")end})
tg:AddButton({Text="Pantsir",Func=function()tp("Pantsir")end})
local j,b,aa,mi={},{},{},{}
local fo=false
local fsv,fcf,fy,fp
local oh,ows
local h=0
local ft,fc,fps=os.clock(),0,60
local function sh()
    local c=y.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function sf(v)
    if fo==v then return end
    fo=v
    local c=workspace.CurrentCamera
    if v then
        fsv={c.CameraType,c.CameraSubject,c.CFrame,is.MouseBehavior,is.MouseIconEnabled}
        fcf=c.CFrame
        fp,fy=fcf:ToOrientation()
        is.MouseBehavior=Enum.MouseBehavior.LockCenter
        is.MouseIconEnabled=false
        c.CameraType=Enum.CameraType.Scriptable
        cas:BindActionAtPriority("SlimekrewFreecamBlock",function()return Enum.ContextActionResult.Sink end,false,3000,
            Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Q,Enum.KeyCode.E,
            Enum.KeyCode.Space,Enum.KeyCode.LeftShift,Enum.KeyCode.RightShift,Enum.KeyCode.Up,Enum.KeyCode.Down,
            Enum.KeyCode.Left,Enum.KeyCode.Right)
    elseif fsv then
        cas:UnbindAction("SlimekrewFreecamBlock")
        c.CameraType=fsv[1]
        c.CameraSubject=fsv[2]
        c.CFrame=fsv[3]
        is.MouseBehavior=fsv[4]
        is.MouseIconEnabled=fsv[5]
        fsv=nil
    else
        cas:UnbindAction("SlimekrewFreecamBlock")
    end
end
local ij=is.JumpRequest:Connect(function()
    if u.InfiniteJump.Value then
        local h=sh()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end
    end
end)
local function dr(q)
    local v=Drawing.new(q)
    v.Visible=false
    return v
end
local function nt()
    local v={s=dr("Square"),t=dr("Text"),bg=dr("Square"),fg=dr("Square"),l={},a=0}
    v.s.Thickness=1
    v.s.Filled=false
    v.bg.Filled=true
    v.bg.Color=Color3.fromRGB(8,8,10)
    v.fg.Filled=true
    v.t.Center=true
    v.t.Outline=true
    v.t.Size=13
    for i=1,8 do
        v.l[i]=dr("Line")
        v.l[i].Thickness=1
    end
    return v
end
local function wt()
    local v={t=dr("Text"),a=0}
    v.t.Center=true
    v.t.Outline=true
    v.t.Size=13
    return v
end
local function hv(v)
    v.s.Visible=false
    v.t.Visible=false
    v.bg.Visible=false
    v.fg.Visible=false
    for _,d in ipairs(v.l)do d.Visible=false end
    if v.h then v.h:Destroy()v.h=nil end
end
local function hw(v)
    v.t.Visible=false
    if v.h then v.h:Destroy()v.h=nil end
end
local function rm(v)
    if v.s then v.s:Remove()end
    if v.t then v.t:Remove()end
    if v.bg then v.bg:Remove()end
    if v.fg then v.fg:Remove()end
    if v.l then for _,d in ipairs(v.l)do d:Remove()end end
    if v.h then v.h:Destroy()end
end
local function hi(v,a,c,f)
    if not v.h or v.h.Parent~=a then
        if v.h then v.h:Destroy()end
        local d=Instance.new("Highlight")
        d.Name="SlimekrewHighlight"
        d.Adornee=a
        d.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        d.Parent=a
        v.h=d
    end
    v.h.FillColor=c
    v.h.OutlineColor=c
    v.h.FillTransparency=1-.35*f
    v.h.OutlineTransparency=1-f
    v.h.Enabled=f>.01
end
local function fd(v,on,dt)
    local q=on and 1 or 0
    v.a=v.a+(q-v.a)*math.min(dt*8,1)
    if math.abs(v.a-q)<.01 then v.a=q end
    return v.a
end
local function gc(c,s)
    local q=.18+.18*(math.sin(os.clock()*2+s*.012)+1)/2
    return c:Lerp(Color3.new(1,1,1),q)
end
local function pos(a)
    if a:IsA("BasePart")then return a.Position end
    if a:IsA("Model")then
        local q=a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart",true)
        return q and q.Position or a:GetPivot().Position
    end
end
local function vel(a)
    local q
    if a:IsA("BasePart")then q=a
    elseif a:IsA("Model")then q=a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart",true)end
    return q and q.AssemblyLinearVelocity or Vector3.zero
end
local function hit(m)
    local mp=pos(m)
    if not mp then return"Unknown",0 end
    local mv=vel(m)
    local bn,bd,bt,bc
    for d in pairs(b)do
        if d.Parent then
            local dp=pos(d)
            if dp then
                local r=dp-mp
                local rv=vel(d)-mv
                local vv=rv:Dot(rv)
                local t=vv>.01 and math.clamp(-r:Dot(rv)/vv,0,20)or 0
                local miss=(r+rv*t).Magnitude
                local ahead=mv.Magnitude<1 or mv:Dot(r)>0
                if ahead and(not bd or miss<bd)then
                    bd,bt,bc=miss,t,d
                end
            end
        end
    end
    if not bc then return"Unknown",0 end
    local id=tonumber(bc:GetAttribute("OwnerUserId"))
    local op=id and p:GetPlayerByUserId(id)
    bn=op and op.Name or bc:GetAttribute("ModelName")or bc.Name
    local r=pos(bc)-mp
    local rv=vel(bc)-mv
    local close=rv.Magnitude>.01 and r.Magnitude>.01 and math.clamp(-r.Unit:Dot(rv.Unit),0,1)or 0
    local track=1-math.clamp(bd/250,0,1)
    local time=1-math.clamp(bt/20,0,1)
    local speed=math.clamp(mv.Magnitude/300,0,1)
    return tostring(bn),math.floor(math.clamp(track*.65+close*.2+speed*.1+time*.05,0,1)*100+.5)
end
local function box(a,c)
    local q,s=a:GetBoundingBox()
    local mn=Vector2.new(math.huge,math.huge)
    local mx=Vector2.new(-math.huge,-math.huge)
    local z=0
    for i=-1,1,2 do
        for d=-1,1,2 do
            for f=-1,1,2 do
                local v=c:WorldToViewportPoint(q*Vector3.new(s.X*i/2,s.Y*d/2,s.Z*f/2))
                if v.Z>0 then
                    z=z+1
                    mn=Vector2.new(math.min(mn.X,v.X),math.min(mn.Y,v.Y))
                    mx=Vector2.new(math.max(mx.X,v.X),math.max(mx.Y,v.Y))
                end
            end
        end
    end
    if z<2 then return end
    return mn,mx
end
local function ln(v,a,d,c)
    v.From=a
    v.To=d
    v.Color=gc(c,(a.Y+d.Y)/2)
    v.Visible=true
end
local function dp(v,a,d,c,m,f,hp)
    local q=d-a
    local sx,sy=q.X,q.Y
    c=gc(c,a.Y)
    v.t.Text=m
    v.t.Position=Vector2.new(a.X+sx/2,a.Y-15)
    v.t.Color=c
    v.t.Transparency=f
    v.t.Visible=true
    local md=o.PlayerBox.Value
    v.s.Visible=md=="Box"
    if v.s.Visible then
        v.s.Position=a
        v.s.Size=q
        v.s.Color=c
        v.s.Transparency=f
    end
    local bh=math.max(1,sy)
    local show=u.PlayerHealthBar.Value and hp~=nil
    v.bg.Visible=show
    v.fg.Visible=show
    if show then
        hp=math.clamp(hp,0,1)
        v.bg.Position=Vector2.new(a.X-7,a.Y-1)
        v.bg.Size=Vector2.new(5,bh+2)
        v.bg.Transparency=f*.72
        local fh=math.max(1,bh*hp)
        v.fg.Position=Vector2.new(a.X-6,d.Y-fh)
        v.fg.Size=Vector2.new(3,fh)
        v.fg.Color=gc(o.HealthBarColor.Value,a.Y+hp*100)
        v.fg.Transparency=f
    end
    for _,f in ipairs(v.l)do f.Visible=false end
    if md~="Corner"then return end
    local lx=math.min(sx*.25,18)
    local ly=math.min(sy*.25,18)
    for i,d in ipairs(v.l)do
        d.Transparency=f
        d.Color=gc(c,a.Y+i*12)
    end
    ln(v.l[1],a,Vector2.new(a.X+lx,a.Y),c)
    ln(v.l[2],a,Vector2.new(a.X,a.Y+ly),c)
    ln(v.l[3],Vector2.new(d.X,a.Y),Vector2.new(d.X-lx,a.Y),c)
    ln(v.l[4],Vector2.new(d.X,a.Y),Vector2.new(d.X,a.Y+ly),c)
    ln(v.l[5],Vector2.new(a.X,d.Y),Vector2.new(a.X+lx,d.Y),c)
    ln(v.l[6],Vector2.new(a.X,d.Y),Vector2.new(a.X,d.Y-ly),c)
    ln(v.l[7],d,Vector2.new(d.X-lx,d.Y),c)
    ln(v.l[8],d,Vector2.new(d.X,d.Y-ly),c)
end
local function dw(v,a,m,c,cam,hl,f)
    local q=pos(a)
    if not q then hw(v)return end
    local s,on=cam:WorldToViewportPoint(q)
    if not on or s.Z<=0 then v.t.Visible=false else
        v.t.Text=m
        v.t.Position=Vector2.new(s.X,s.Y)
        c=gc(c,s.Y)
        v.t.Color=c
        v.t.Transparency=f
        v.t.Visible=true
    end
    if hl then hi(v,a,c,f)elseif v.h then v.h:Destroy()v.h=nil end
end
local function sync()
    local q={}
    for _,v in ipairs(p:GetPlayers())do
        if v~=y then
            q[v]=true
            if not j[v]then j[v]=nt()end
        end
    end
    for v,d in pairs(j)do if not q[v]then rm(d)j[v]=nil end end
    q={}
    local d=workspace:FindFirstChild("Drones")
    d=d and d:FindFirstChild("SpawnedDrones")
    if d then for _,v in ipairs(d:GetChildren())do q[v]=true if not b[v]then b[v]=wt()end end end
    for v,d in pairs(b)do if not q[v]then rm(d)b[v]=nil end end
    q={}
    local m=workspace:FindFirstChild("AllMapWithRespawn")
    m=m and m:FindFirstChild("CurrentMap")
    m=m and m:FindFirstChild("MapContent")
    m=m and m:FindFirstChild("AntiAirs")
    if m then
        for _,v in ipairs(m:GetChildren())do
            if v:IsA("Model")or v:IsA("BasePart")then
                q[v]=true
                if not aa[v]then aa[v]=wt()end
            end
        end
    end
    for v,d in pairs(aa)do if not q[v]then rm(d)aa[v]=nil end end
    q={}
    if m then
        for _,a in ipairs(m:GetChildren())do
            local f=a:FindFirstChild("SpawnedMissiles")
            if f then
                for _,v in ipairs(f:GetChildren())do
                    if v:IsA("Model")or v:IsA("BasePart")then
                        q[v]=true
                        if not mi[v]then mi[v]=wt()end
                    end
                end
            end
        end
    end
    for v,d in pairs(mi)do if not q[v]then rm(d)mi[v]=nil end end
end
local cn=n.RenderStepped:Connect(function(dt)
    local hh=sh()
    if hh~=oh then
        if oh and oh.Parent and ows then oh.WalkSpeed=ows end
        oh=hh
        ows=hh and hh.WalkSpeed
    end
    if hh then hh.WalkSpeed=u.WalkSpeed.Value and o.WalkSpeedValue.Value or ows end
    fc=fc+1
    local now=os.clock()
    if now-ft>=.5 then
        fps=math.floor(fc/(now-ft)+.5)
        fc=0
        ft=now
        local pn=0
        pcall(function()pn=math.floor(stt.Network.ServerStatsItem["Data Ping"]:GetValue()+.5)end)
        q:SetText("slimekrew | pantsir | "..fps.." fps | "..pn.."ms")
    end
    h=h+dt
    if h>=.75 then h=0 sync()end
    local cam=workspace.CurrentCamera
    if not cam then return end
    for v,d in pairs(j)do
        local c=v.Character
        local same=y.Team~=nil and v.Team==y.Team
        local on=u.PlayerEsp.Value and c~=nil and not(u.TeamCheck.Value and same)
        local f=fd(d,on,dt)
        if f<=0 or not c then hv(d)else
            local a,z=box(c,cam)
            if not a then hv(d)else
                local tc=v.TeamColor and v.TeamColor.Color or Color3.new(1,1,1)
                local tm=v.Team and v.Team.Name or "Neutral"
                local rp=c:FindFirstChild("HumanoidRootPart")
                local ds=rp and math.floor((rp.Position-cam.CFrame.Position).Magnitude*.28+.5)or 0
                local hm=c:FindFirstChildOfClass("Humanoid")
                local hp=hm and hm.MaxHealth>0 and hm.Health/hm.MaxHealth or nil
                dp(d,a,z,tc,v.Name.." | "..tm.." | "..ds.."m",f,hp)
                if u.PlayerHighlight.Value then hi(d,c,gc(o.PlayerColor.Value,a.Y),f)elseif d.h then d.h:Destroy()d.h=nil end
            end
        end
    end
    for v,d in pairs(b)do
        local f=fd(d,u.DroneEsp.Value,dt)
        if f>0 then
            local q=pos(v)
            local ds=q and math.floor((q-cam.CFrame.Position).Magnitude*.28+.5)or 0
            local nm=v:GetAttribute("ModelName")
            if type(nm)~="string"or nm==""then nm=v.Name end
            local id=tonumber(v:GetAttribute("OwnerUserId"))
            local op=id and p:GetPlayerByUserId(id)
            local ow=op and op.Name or(id and tostring(id)or"Unknown")
            dw(d,v,nm.." | "..ds.."m | Owner: "..ow,o.DroneColor.Value,cam,u.DroneHighlight.Value,f)
        else hw(d)end
    end
    for v,d in pairs(aa)do
        local f=fd(d,u.AAEsp.Value,dt)
        if f>0 then
            local q=pos(v)
            local ds=q and math.floor((q-cam.CFrame.Position).Magnitude*.28+.5)or 0
            local seat=v:FindFirstChild("Gunner",true)
            local oc=seat and(seat:IsA("Seat")or seat:IsA("VehicleSeat"))and seat.Occupant
            local pl=oc and p:GetPlayerFromCharacter(oc.Parent)
            local st=oc and("Occupied - "..(pl and pl.Name or oc.Parent.Name))or"Empty"
            dw(d,v,v.Name.." | "..ds.."m | "..st,o.AAColor.Value,cam,u.AAHighlight.Value,f)
        else hw(d)end
    end
    for v,d in pairs(mi)do
        local f=fd(d,u.MissileEsp.Value,dt)
        if f>0 then
            local src=v.Parent and v.Parent.Parent
            local sn=src and src.Name or"Unknown"
            d.ht=(d.ht or 0)-dt
            if d.ht<=0 then d.tn,d.ch=hit(v)d.ht=.1 end
            dw(d,v,sn.."-AntiAir | Target: "..tostring(d.tn or"Unknown").." | Hit chance: "..tostring(d.ch or 0).."%",o.MissileColor.Value,cam,u.MissileHighlight.Value,f)
        else hw(d)end
    end
end)
n:BindToRenderStep("SlimekrewFreecam",Enum.RenderPriority.Camera.Value+50,function(dt)
    sf(u.Freecam.Value)
    if fo then
        local md=is:GetMouseDelta()
        fy=fy-md.X*.0025
        fp=math.clamp(fp-md.Y*.0025,-1.55,1.55)
        local r=CFrame.fromOrientation(fp,fy,0)
        local d=Vector3.new()
        if is:IsKeyDown(Enum.KeyCode.W)then d=d+r.LookVector end
        if is:IsKeyDown(Enum.KeyCode.S)then d=d-r.LookVector end
        if is:IsKeyDown(Enum.KeyCode.D)then d=d+r.RightVector end
        if is:IsKeyDown(Enum.KeyCode.A)then d=d-r.RightVector end
        if is:IsKeyDown(Enum.KeyCode.E)then d=d+Vector3.yAxis end
        if is:IsKeyDown(Enum.KeyCode.Q)then d=d-Vector3.yAxis end
        if d.Magnitude>0 then d=d.Unit*o.FreecamSpeed.Value*dt end
        fcf=CFrame.new(fcf.Position+d)*r
        workspace.CurrentCamera.CFrame=fcf
        workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
        return
    end
end)
sync()
local sb=t.s:AddLeftTabbox("Menu")
local m=sb:AddTab("Interface")
local mn=sb:AddTab("Notifications")
local mt=sb:AddTab("Themes")
local mg=sb:AddTab("Gradient")
local gs,ge=l:GetGradientColors()
mt:AddDropdown("Theme",{Text="Menu Theme",Values=l:GetThemes(),Default=l.ActiveTheme,Callback=function(v)l:SetTheme(v)end})
m:AddToggle("Cursor",{Text="Custom Cursor",Default=l.ShowCustomCursor,Callback=function(v)l.ShowCustomCursor=v end})
m:AddToggle("Overlay",{Text="Watermark",Default=true,Callback=function(v)q:SetVisible(v)end})
mg:AddLabel("Gradient Start"):AddColorPicker("GradientStart",{Default=gs,Title="Gradient Start",Callback=function(v)
    l:SetGradientColors(v,o.GradientEnd and o.GradientEnd.Value or ge)
end})
mg:AddLabel("Gradient End"):AddColorPicker("GradientEnd",{Default=ge,Title="Gradient End",Callback=function(v)
    l:SetGradientColors(o.GradientStart and o.GradientStart.Value or gs,v)
end})
m:AddLabel("Menu Key"):AddKeyPicker("MenuKey",{Default="RightShift",NoUI=true,Text="Menu Key",ChangedCallback=function(k)
    l.ToggleKeybind=k or Enum.KeyCode.RightShift
end})
m:AddButton({Text="Unload",Func=function()l:Unload()end})
mn:AddDropdown("NotifySide",{Text="Notification Side",Values={"Left","Right"},Default="Left",Multi=false,Callback=function(v)l:SetNotifySide(v)end})
local cb=t.s:AddRightTabbox("Configs")
local cm=cb:AddTab("Configs")
local hs=game:GetService("HttpService")
local fd="Potas/pantsir"
local cd=fd.."/configs"
local af=fd.."/autoload.txt"
pcall(function()
    if makefolder then
        if isfolder and not isfolder("Potas")then makefolder("Potas")end
        if isfolder and not isfolder(fd)then makefolder(fd)end
        if isfolder and not isfolder(cd)then makefolder(cd)end
    end
end)
local function cl()
    local a={}
    if listfiles then
        local ok,f=pcall(listfiles,cd)
        if ok then
            for _,p in ipairs(f)do
                local n=p:match("([^/\\]+)%.json$")
                if n then table.insert(a,n)end
            end
        end
    end
    table.sort(a)
    if #a==0 then a[1]="Default"end
    return a
end
local cv=cl()
cm:AddDropdown("ConfigList",{Text="Config",Values=cv,Default=cv[1],Multi=false})
cm:AddInput("ConfigName",{Text="Config name",Default="",Placeholder="Config name",Finished=true})
local cs=cm:AddLabel("Selected: "..cv[1])
local ca=cm:AddLabel("Autoload: None")
local ct=cm:AddLabel("Configs: "..#cv)
local function rf()
    cv=cl()
    o.ConfigList:SetValues(cv)
    if not table.find(cv,o.ConfigList.Value)then o.ConfigList:SetValue(cv[1])end
    cs:SetText("Selected: "..tostring(o.ConfigList.Value))
    ct:SetText("Configs: "..#cv)
end
local function pack(v)
    if typeof(v)=="Color3"then return{__type="Color3",r=v.R,g=v.G,b=v.B}end
    if type(v)=="table"then
        local n={}
        for k,x in pairs(v)do n[k]=pack(x)end
        return n
    end
    return v
end
local function unpackv(v)
    if type(v)=="table"and v.__type=="Color3"then
        return Color3.new(tonumber(v.r)or 1,tonumber(v.g)or 1,tonumber(v.b)or 1)
    end
    if type(v)=="table"then
        local n={}
        for k,x in pairs(v)do n[k]=unpackv(x)end
        return n
    end
    return v
end
local function sd(n)
    if not(writefile and hs)then return false,"filesystem unavailable"end
    n=tostring(n or ""):gsub("[^%w%-%_]","")
    if n==""then return false,"enter a config name"end
    local d={Toggles={},Options={}}
    for k,v in pairs(u)do
        if type(k)=="string"and type(v.Value)=="boolean"then d.Toggles[k]=v.Value end
    end
    for k,v in pairs(o)do
        if type(k)=="string"and not k:find("^Config")then
            local q=typeof(v.Value)
            if q=="string"or q=="number"or q=="boolean"or q=="table"or q=="Color3"then d.Options[k]=pack(v.Value)end
        end
    end
    local ok,e=pcall(writefile,cd.."/"..n..".json",hs:JSONEncode(d))
    if ok then rf()return true,n end
    return false,e
end
local function ld(n)
    if not(readfile and isfile)then return false,"filesystem unavailable"end
    local p=cd.."/"..tostring(n)..".json"
    if not isfile(p)then return false,"config not found"end
    local ok,d=pcall(function()return hs:JSONDecode(readfile(p))end)
    if not ok or type(d)~="table"then return false,"invalid config"end
    for k,v in pairs(d.Toggles or {})do if u[k]then pcall(u[k].SetValue,u[k],v)end end
    for k,v in pairs(d.Options or {})do if o[k]then pcall(o[k].SetValue,o[k],unpackv(v))end end
    cs:SetText("Selected: "..tostring(n))
    return true,n
end
cm:AddButton({Text="Save",Func=function()
    local ok,n=sd(o.ConfigName.Value)
    l:Notify({Title="Configs",Description=ok and("Saved "..n)or tostring(n),Time=3})
end})
cm:AddButton({Text="Load",Func=function()
    local ok,n=ld(o.ConfigList.Value)
    l:Notify({Title="Configs",Description=ok and("Loaded "..n)or tostring(n),Time=3})
end})
cm:AddButton({Text="Set Autoload",Func=function()
    local n=tostring(o.ConfigList.Value)
    local ok=writefile and pcall(writefile,af,n)
    if ok then ca:SetText("Autoload: "..n)end
    l:Notify({Title="Configs",Description=ok and(n.." set to autoload")or"filesystem unavailable",Time=3})
end})
cm:AddButton({Text="Delete",Func=function()
    local n=tostring(o.ConfigList.Value)
    local p=cd.."/"..n..".json"
    local ok=delfile and isfile and isfile(p)and pcall(delfile,p)
    rf()
    l:Notify({Title="Configs",Description=ok and("Deleted "..n)or"config not found",Time=3})
end})
pcall(function()
    if isfile and readfile and isfile(af)then
        local n=readfile(af)
        ca:SetText("Autoload: "..n)
        if table.find(cv,n)then o.ConfigList:SetValue(n)ld(n)end
    end
end)
l.ToggleKeybind=Enum.KeyCode.RightShift
l:OnUnload(function()
    cn:Disconnect()
    ij:Disconnect()
    n:UnbindFromRenderStep("SlimekrewFreecam")
    sf(false)
    if oh and oh.Parent and ows then oh.WalkSpeed=ows end
    for _,v in pairs(j)do rm(v)end
    for _,v in pairs(b)do rm(v)end
    for _,v in pairs(aa)do rm(v)end
    for _,v in pairs(mi)do rm(v)end
end)
l:OnUnload(function()if g.SlimekrewUI==l then g.SlimekrewUI=nil end end)
g.SlimekrewUI=l
z:SetMessage("Ready")
z:SetDescription("have a nice day :D")
z:SetCurrentStep(5)
task.wait(1.5)
z:Continue()
q:SetVisible(true)
l:Notify({Title="slimekrew",Description="loaded have fun :D",Time=4})
