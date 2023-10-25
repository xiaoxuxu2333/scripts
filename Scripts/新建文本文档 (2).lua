local PhysicsService = game:GetService("PhysicsService")
local RequestDestroy = game:GetService("ReplicatedStorage"):WaitForChild("RequestDestroy")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local LocalPlayer = game:GetService("Players").LocalPlayer
local floatingDamageInd = game:GetService("ReplicatedStorage"):WaitForChild("particle"):WaitForChild("floatingDamageInd")
local v20 = {}
local function creatingFloatingMessage_1(p1, p2)
    pcall(function()
        local v33 = p2
        if v33 then
            v33 = LocalPlayer.Character.Head.Position
        end
        p2 = v33
        local v37 = floatingDamageInd:Clone()
        v35 = workspace
        v36 = v35.RayCastIgnore
        v37.Parent = v36
        v35 = v37.BillboardGui
        v36 = v35.TextLabel
        v35 = p1
        v36.Text = v35
        v36 = p2
        v37.Position = v36
        v36 = TweenService
        v34 = v37.BillboardGui
        local v43 = {}
        v43.ExtentsOffsetWorldSpace = Vector3.new(math.random(-50, 50) / 25, 5, math.random(-50, 50) / 25)
        (v36:Create(v34, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v43)):Play()
        local v63 = {}
        v63.TextTransparency = 0
        (TweenService:Create(v37.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v63)):Play()
        local v72 = {}
        v72.TextStrokeTransparency = 0
        (TweenService:Create(v37.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v72)):Play()
        v35 = function()
            wait(0.8)
            local v85 = {}
            v85.TextTransparency = 1
            (TweenService:Create(v37.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v85)):Play()
            local v94 = {}
            v94.TextStrokeTransparency = 1
            (TweenService:Create(v37.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v94)):Play()
            wait(1)
            v37:Destroy()
        end
        spawn(v35)
    end)
end
script.Parent:WaitForChild("async").Event:Connect(function(p4, p5, p6, p7, p8, p9)
    local v130 = (function(p3)
        local v113 = ""
        for v114 = 1, p3, 1 do
            local v120 = math.random(1, 62)
            v113 = v113 .. ("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXYZz1234567890"):sub(v120, v120)
        end
        return v113
    end)(10)
    v20[v130] = p5
    RequestDestroy:FireServer(v130, p4, p5, p6, p7, p8, p9)
end)
local v140 = {}
RequestDestroy.OnClientEvent:Connect(function(p10, p11)
    local v143 = v140
    local v144
    local v145
    for v149, u1 in v143, v144, v145 do
        pcall(function()
            u1:Destroy()
        end)
    end
    v143 = {}
    v140 = v143
    v144 = v20
    local v229 = v144[p11]
    v149 = "Failed to verify"
    v145 = function()
        local v150 = p2
        if v150 then
            v150 = LocalPlayer.Character.Head.Position
        end
        p2 = v150
        local v154 = floatingDamageInd:Clone()
        v152 = workspace
        v153 = v152.RayCastIgnore
        v154.Parent = v153
        v152 = v154.BillboardGui
        v153 = v152.TextLabel
        v152 = p1
        v153.Text = v152
        v153 = p2
        v154.Position = v153
        v153 = TweenService
        v151 = v154.BillboardGui
        local v160 = {}
        v160.ExtentsOffsetWorldSpace = Vector3.new(math.random(-50, 50) / 25, 5, math.random(-50, 50) / 25)
        (v153:Create(v151, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v160)):Play()
        local v180 = {}
        v180.TextTransparency = 0
        (TweenService:Create(v154.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v180)):Play()
        local v189 = {}
        v189.TextStrokeTransparency = 0
        (TweenService:Create(v154.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v189)):Play()
        v152 = function()
            wait(0.8)
            local v202 = {}
            v202.TextTransparency = 1
            (TweenService:Create(v37.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v202)):Play()
            local v211 = {}
            v211.TextStrokeTransparency = 1
            (TweenService:Create(v37.BillboardGui.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v211)):Play()
            wait(1)
            v37:Destroy()
        end
        spawn(v152)
    end
    pcall(v145)
    v20[p11] = nil
end)
workspace.GlobalParts.ChildRemoved:Connect(function(p12)
    local v236 = p12:IsA("BasePart")
    if not v236 then
        v236 = p12.Size.Magnitude
        local v246 = 50
        if v236 > v246 then
            local v238 = p12:Clone()
            v246 = true
            v238.Anchored = v246
            v246 = 1
            v238.Transparency = v246
            v246 = "placeHolder"
            v238.Name = v246
            v246 = v140
            v246[#v140 + 1] = v238
            v246 = PhysicsService
            v246:SetPartCollisionGroup(v238, "antiStuck")
            v238.Parent = workspace.ClientDebris
            delay(2, function()
                local v245 = v238.Parent
                if not v245 then
                    v245 = v238
                    v245:Destroy()
                end
            end)
        end
    end
end)
