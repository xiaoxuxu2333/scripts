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

main:CreateToggle("自动收", function(enabled)
    autoCollectingCubes = enabled
    
    coroutine.wrap(function()
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
    	text.Size = 50
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
        
        while autofarm do
            local dt = task.wait()
            
            local ran = tick() - startTime
            local hours = math.floor(ran / 60 / 60)
            local minutes = math.floor(ran / 60)
            local seconds = math.floor(ran)
            
            local eatMinutes = math.floor(eatTime / 60)
            local eatSeconds = math.floor(eatTime)
            
            text.Text = "吃饱用时：" .. string.format("%i分%i秒", eatMinutes % 60, eatSeconds % 60)
                .. "\n出售次数：" .. sellCount
                .. "\n已运行：" .. string.format("%i时%i分%i秒", hours, minutes % 60, seconds % 60)
            
            if checkLoaded() then
                if workspace:FindFirstChild("Loading") then
                    LocalPlayer.Character:PivotTo(CFrame.new(0, LocalPlayer.Character.Humanoid.HipHeight * 2, 0))
                end
                
                if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air and not workspace:FindFirstChild("Loading") then
                    LocalPlayer.Character.Events.Grab:FireServer(nil, true)
                end
                LocalPlayer.Character.Events.Eat:FireServer()
                
                if LocalPlayer.Character.CurrentChunk.Value then
                    timer = 0
                else
                    timer += dt
                end
                
                if (LocalPlayer.Character.Size.Value >= LocalPlayer.Upgrades.MaxSize.Value)
                    or timer > 5
                then
                    if timer < 5 then
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
end)

main:CreateToggle("自动吃", function(enabled)
    autoeat = enabled
    
    coroutine.wrap(function()
        while autoeat do
            local dt = task.wait()
            
            if checkLoaded() then
                if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air and not workspace:FindFirstChild("Loading") then
                    LocalPlayer.Character.Events.Grab:FireServer()
                end
                LocalPlayer.Character.Events.Eat:FireServer()
            end
        end
    end)()
end)

main:CreateToggle("自动抛", function(enabled)
    autoeat = enabled
    
    coroutine.wrap(function()
        while autoeat do
            local dt = task.wait()
            
            if checkLoaded()
                and not workspace:FindFirstChild("Loading")
            then
                LocalPlayer.Character:PivotTo(workspace.Map.Bedrock.CFrame + Vector3.new(0, workspace.Map.Bedrock.Size.Y / 2, 0) + Vector3.new(0, LocalPlayer.Character.Humanoid.HipHeight * 2, 0))
                if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air and not workspace:FindFirstChild("Loading") then
                    LocalPlayer.Character.Events.Grab:FireServer()
                end
                changeMap()
                wait(1.5)
                LocalPlayer.Character.Events.Eat:FireServer()
                wait(0.1)
                LocalPlayer.Character.Events.Eat:FireServer()
                wait(0.1)
                LocalPlayer.Character.Events.Throw:FireServer()
            end
        end
    end)()
end)

main:CreateToggle("自动升大小", function(enabled)
    autoUpgradeSize = enabled
    
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeSize do
            task.wait(1)
            local args = {
            	"MaxSize"
            }
            Events.PurchaseEvent:FireServer(unpack(args))
        end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

main:CreateToggle("自动升移速", function(enabled)
    autoUpgradeSpd = enabled
    
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeSpd do
            task.wait(1)
            local args = {
            	"Speed"
            }
            Events.PurchaseEvent:FireServer(unpack(args))
        end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

main:CreateToggle("自动升乘数", function(enabled)
    autoUpgradeMulti = enabled
    
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeMulti do
            task.wait(1)
            local args = {
            	"Multiplier"
            }
            Events.PurchaseEvent:FireServer(unpack(args))
        end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

main:CreateToggle("自动升吃速", function(enabled)
    autoUpgradeEat = enabled
    
    coroutine.wrap(function()
        game.CoreGui.PurchasePromptApp.Enabled = false
        while autoUpgradeEat do
            task.wait(1)
            local args = {
            	"EatSpeed"
            }
            Events.PurchaseEvent:FireServer(unpack(args))
        end
        game.CoreGui.PurchasePromptApp.Enabled = true
    end)()
end)

main:CreateToggle("自动领", function(enabled)
    autoClaimRewards = enabled
    
    coroutine.wrap(function()
        while autoClaimRewards do
            task.wait(1)
            for _, reward in LocalPlayer.TimedRewards:GetChildren() do
                local args = {
                	reward
                }
                Events.RewardEvent:FireServer(unpack(args))
            end
            
            Events.SpinEvent:FireServer()
        end
    end)()
end)

main:CreateToggle("移除地图", function(enabled)
    keepRemoveMap = enabled
    
    coroutine.wrap(function()
        while keepRemoveMap do
            task.wait()
            -- if workspace.Map:FindFirstChild("Buildings") then
                -- workspace.Map.Buildings:Destroy()
            -- end
            -- if workspace.Map:FindFirstChild("Fragmentable") then
                -- workspace.Map.Fragmentable:Destroy()
            -- end
            if workspace:FindFirstChild("Chunks") then
                workspace.Chunks:Destroy()
            end
            if workspace:FindFirstChild("Map") then
                workspace.Map:Destroy()
            end
        end
    end)()
end)

main:CreateToggle("黑屏模式", function(enabled)
    blackScreenMode = enabled
    
    coroutine.wrap(function()
        while blackScreenMode do
            task.wait()
            game.Lighting.Brightness = math.huge
        end
        game.Lighting.Brightness = 2
    end)()
end)

-- local args = {
	-- "Mega"
-- }
-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RequestTeleport"):FireServer(unpack(args))

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SpinEvent"):FireServer()

-- Purchases: MaxSize, Speed, Multiplier, EatSpeed