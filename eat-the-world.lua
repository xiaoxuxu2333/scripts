local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local LocalPlayer = Players.LocalPlayer

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()

local window = UI:NewWindow("吃吃世界")
local main = window:NewSection("功能")

local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function randomTp(character)
    local pos = workspace.Map.Bedrock.Position + Vector3.new(math.random(-workspace.Map.Bedrock.Size.X / 2, workspace.Map.Bedrock.Size.X / 2), 0, math.random(-workspace.Map.Bedrock.Size.X / 2, workspace.Map.Bedrock.Size.X / 2))
    character:MoveTo(pos)
    character:PivotTo(CFrame.new(character:GetPivot().Position, workspace.Map.Bedrock.Position))
end

local function changeMap()
    local args = {
    	{
    		MapTime = -1,
    		Paused = true
    	}
    }
    Events.SetServerSettings:FireServer(unpack(args))
end

local function checkLoaded()
    return (LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("Humanoid")
        and LocalPlayer.Character:FindFirstChild("Size")
        and LocalPlayer.Character:FindFirstChild("Events")
        and LocalPlayer.Character.Events:FindFirstChild("Grab")
        and LocalPlayer.Character.Events:FindFirstChild("Eat")
        and LocalPlayer.Character.Events:FindFirstChild("Sell")
        and LocalPlayer.Character:FindFirstChild("CurrentChunk")) ~= nil
end

local function sizeGrowth(level)
    return math.floor(((level + 0.5) ^ 2 - 0.25) / 2 * 100)
end

main:CreateToggle("自动收", function(enabled)
    autoCollectingCubes = enabled
    
    coroutine.wrap(function()
        LocalPlayer.PlayerScripts.CubeVis.Enabled = false
        while autoCollectingCubes do
            task.wait()
            local root = getRoot()
            
            if root then
                for _, v in workspace:GetChildren() do
                    if v.Name == "Cube" and v:FindFirstChild("Owner") and (v.Owner.Value == LocalPlayer.Name or v.Owner.Value == "") then
                        v.CFrame = root.CFrame
                    end
                end
            end
        end
        LocalPlayer.PlayerScripts.CubeVis.Enabled = true
    end)()
end)

main:CreateToggle("自动刷", function(enabled)
    autofarm = enabled
    
    coroutine.wrap(function()
    	local text = Drawing.new("Text")
    	text.Outline = true
    	text.OutlineColor = Color3.new(0, 0, 0)
    	text.Color = Color3.new(1, 1, 1)
    	text.Center = false
    	text.Position = Vector2.new(64, 64)
    	text.Text = ""
    	text.Size = 24
    	text.Visible = true
    	
    	local startTime = tick()
    	local eatTime = 0
    	local lastEatTime = tick()
        
        local timer = 0
        local sellDebounce = false
        local sellCount = 0
        
        local bedrock = Instance.new("Part")
        bedrock.Anchored = true
        bedrock.Size = Vector3.new(2048, 1, 2048)
        bedrock.Parent = workspace
        
        LocalPlayer.Character:PivotTo(CFrame.new(0, LocalPlayer.Character.Humanoid.HipHeight * 2, 0))
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero
        
        task.wait(0.3)
        
        while autofarm do
            local dt = task.wait()
            
            local ran = tick() - startTime
            local hours = math.floor(ran / 60 / 60)
            local minutes = math.floor(ran / 60)
            local seconds = math.floor(ran)
            
            local eatMinutes = math.floor(eatTime / 60)
            local eatSeconds = math.floor(eatTime)
            
            local secondEarn = sizeGrowth(LocalPlayer.Upgrades.MaxSize.Value) / eatTime
            local minuteEarn = secondEarn * 60
            local hourEarn = minuteEarn * 60
            local dayEarn = hourEarn * 24
            
            text.Text = "吃饱用时：" .. string.format("%i分%i秒", eatMinutes % 60, eatSeconds % 60)
                .. "\n出售次数：" .. sellCount
                .. "\n每秒收益：" .. secondEarn
                .. "\n每分钟收益：" .. minuteEarn
                .. "\n每小时收益：" .. hourEarn
                .. "\n每天收益：" .. dayEarn
                .. "\n已运行：" .. string.format("%i时%i分%i秒", hours, minutes % 60, seconds % 60)
            
            if checkLoaded() then
                LocalPlayer.Character.Events.Eat:FireServer()
                
                if LocalPlayer.Character.CurrentChunk.Value then
                    timer = 0
                else
                    timer += dt
                end
                
                if (LocalPlayer.Character.Size.Value >= LocalPlayer.Upgrades.MaxSize.Value)
                    or timer > 8
                then
                    if timer < 8 then
                        LocalPlayer.Character.Events.Sell:FireServer()
                        
                        if not sellDebounce then
                            local currentEatTime = tick()
                            eatTime = currentEatTime - lastEatTime
                            lastEatTime = currentEatTime
                            
                            sellCount += 1
                        end
                        
                        sellDebounce = true
                    end
                    timer = 0
                    
                    changeMap()
                elseif (LocalPlayer.Character.Size.Value < LocalPlayer.Upgrades.MaxSize.Value) then
                    if sellDebounce then
                        LocalPlayer.Character:PivotTo(CFrame.new(0, LocalPlayer.Character.Humanoid.HipHeight * 2, 0))
                    end
                    
                    sellDebounce = false
                end
                
                LocalPlayer.Character.LocalChunkManager.Enabled = false
            end
        end
        bedrock:Destroy()
        LocalPlayer.Character.LocalChunkManager.Enabled = true
        text:Destroy()
    end)()
    
    coroutine.wrap(function()
        while autofarm do
            local dt = task.wait()
            
            if checkLoaded() then
                if workspace:FindFirstChild("Loading") then
                    LocalPlayer.Character:PivotTo(CFrame.new(0, LocalPlayer.Character.Humanoid.HipHeight * 2, 0))
                end
                
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                LocalPlayer.Character.Events.Grab:FireServer()
                
                for _, v in LocalPlayer.Character:GetDescendants() do
                    if v:IsA("BasePart") then
                        v.LocalTransparencyModifier = 1
                    end
                end
            end
        end
    end)()
    
    blackScreenMode = enabled
    
    coroutine.wrap(function()
        while blackScreenMode do
            task.wait()
            game.Lighting.Brightness = math.huge
            for _,