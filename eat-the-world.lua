local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local LocalPlayer = Players.LocalPlayer

local UILib = getgenv().UILibCache or loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))
getgenv().UILibCache = UILib

local UI = UILib()
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

local function teleportPos()
    LocalPlayer.Character:PivotTo(CFrame.new(0, LocalPlayer.Character.Humanoid.HipHeight * 2, -100) * CFrame.Angles(0, math.rad(-90), 0))
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
        bedrock.Size = Vector3.new(256, 1, 256)
        bedrock.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        bedrock.Parent = workspace

        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero
        
        local map, chunks = workspace:FindFirstChild("Map"), workspace:FindFirstChild("Chunks")
        if map and chunks then
            map.Parent, chunks.Parent = nil, nil
        end

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
            
            text.Text = "EatTime: " .. string.format("%im%is", eatMinutes % 60, eatSeconds % 60)
                .. "\nSellCount: " .. sellCount
                .. "\nSecondEarn: " .. secondEarn
                .. "\nMinuteEarn: " .. minuteEarn
                .. "\nHourEarn: " .. hourEarn
                .. "\nDayEarn: " .. dayEarn
                .. "\nRan: " .. string.format("%ih%im%is", hours, minutes % 60, seconds % 60)
            
            if checkLoaded() then
                LocalPlayer.Character.Events.Grab:FireServer()
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
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
                    sellDebounce = false
                end
                
                LocalPlayer.Character.LocalChunkManager.Enabled = false

                -- if workspace:FindFirstChild("Loading") then
                --     teleportPos()
                -- end
                local r = (ran * -10) / 32 % 128
                local x = math.cos(ran) * r
                local z = math.sin(ran) * r
                
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, LocalPlayer.Character.HumanoidRootPart.Position.Y, z) * CFrame.Angles(0, math.atan2(x, z), 0)
            end
        end
        if map and chunks then
            map.Parent, chunks.Parent = workspace, workspace
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

main:CreateToggle("取消锚固", function(enabled)
    keepUnanchor = enabled
    
    coroutine.wrap(function()
        while keepUnanchor do
            task.wait()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end)()
end)


-- local args = {
	-- "Mega"
-- }
-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RequestTeleport"):FireServer(unpack(args))

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SpinEvent"):FireServer()

-- Purchases: MaxSize, Speed, Multiplier, EatSpeed

--[[

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-07-20 07:47:16
-- Luau version 6, Types version 3
-- Time taken: 0.005614 seconds

local module_8 = {
	GamePasses = {
		["Eat Players"] = 720768665;
		Magnet = 730280015;
		["Explosive Chunks"] = 733742262;
	};
	DevProducts = {
		["Small Cube Pack"] = 1760706156;
		["Medium Cube Pack"] = 1760707045;
		["Large Cube Pack"] = 1760707972;
		["Giant Cube Pack"] = 1760709729;
		["Max Size"] = 1760728424;
		["Small Token Pack"] = 1805507066;
		["Medium Token Pack"] = 1805507931;
		["Large Token Pack"] = 1805509180;
		["Giant Token Pack"] = 1805509730;
		["Starter Pack"] = 1942042820;
		["Holiday Pack 2024"] = 2678435873;
		["Rainbow Pack"] = 2839548304;
	};
	CubePacks = {
		["Small Cube Pack"] = 60000;
		["Medium Cube Pack"] = 150000;
		["Large Cube Pack"] = 600000;
		["Giant Cube Pack"] = 2000000;
	};
	TokenPacks = {
		["Small Token Pack"] = 3;
		["Medium Token Pack"] = 5;
		["Large Token Pack"] = 15;
		["Giant Token Pack"] = 50;
	};
	Bundles = {
		["Starter Pack"] = {
			Tokens = 10;
			Cubes = 150000;
		};
		["Holiday Pack 2024"] = {
			Tokens = 50;
			Cubes = 2000000;
		};
		["Rainbow Pack"] = {
			Tokens = 50;
			Cubes = 2000000;
		};
	};
	LimitedPurchases = {
		["Starter Pack"] = 1;
		["Holiday Pack 2024"] = 0;
		["Rainbow Pack"] = 1;
	};
	Events = {
		["Money Rain"] = {
			name = "Money Rain";
			price = 3;
			image = "rbxassetid://17099910913";
			description = "Rains money from the sky!";
			message = "It's raining money!";
			duration = 60;
		};
		Robot = {
			name = "Money Rain";
			price = 5;
			image = "rbxassetid://17099910828";
			description = "Summon a robot to destroy the map!";
			message = "A robot is attacking!";
			duration = 60;
		};
		Nuke = {
			name = "Money Rain";
			price = 10;
			image = "rbxassetid://17099911657";
			description = "Destroys most of the map!";
			message = "A NUKE IS FALLING! RUN AWAY FROM THE CENTER!";
			duration = 30;
		};
		["Big Food"] = {
			name = "Money Rain";
			price = nil;
			image = "rbxassetid://13902932122";
			description = "Rains giant food that gives extra size!";
			duration = 30;
		};
		Skeletons = {
			name = "Money Rain";
			price = 5;
			image = "rbxassetid://17099910709";
			description = "Summon skeletons to destroy the map!";
			message = "Skeletons are attacking!";
			duration = 60;
		};
		["Low Gravity"] = {
			name = "Low Gravity";
			price = 1;
			image = "rbxassetid://17099910598";
			description = "Make everything float!";
			message = "Low gravity!";
			duration = 40;
		};
	};
}
local tbl = {}
local tbl_3 = {
	price = 10;
	description = "98% chance to get a random color nametag, 2% chance to get a GLOWING color nametag!";
	decal = "rbxassetid://110003088413698";
	possibilities = {"Green", "Cyan", "Purple", "Pink", "Blue", "Orange", "Red", "Yellow", "Glowing Green", "Glowing Cyan", "Glowing Purple", "Glowing Pink", "Glowing Red", "Glowing Yellow"};
}
local function getCrate() -- Line 143
	local module_3 = {"Green", "Cyan", "Purple", "Pink", "Blue", "Orange", "Red", "Yellow"}
	local module_2 = {"Glowing Green", "Glowing Cyan", "Glowing Purple", "Glowing Pink", "Glowing Red", "Glowing Yellow"}
	if 0.98 < math.random() then
		return module_2[math.random(1, #module_2)]
	end
	return module_3[math.random(1, #module_3)]
end
tbl_3.getCrate = getCrate
tbl["Color Crate"] = tbl_3
local tbl_2 = {
	price = 25;
	description = "80% chance to get a common nametag, 18% chance to get an uncommon nametag, 2% chance to get a RARE nametag!";
	color = Color3.new(1, 0.905882, 0.752941);
	possibilities = {"Draw Four", "Velvet", "Mysterious", "Sketchbook", "Viscount", "Lolcats", "3D Movie", "Fruit Salad", "Bubblegum"};
}
local function getCrate() -- Line 185
	local module_6 = {"Draw Four", "Velvet", "Mysterious", "Sketchbook", "Viscount"}
	local module_4 = {"Lolcats", "3D Movie", "Fruit Salad"}
	local module_7 = {"Bubblegum"}
	local seed_2 = math.random()
	if 0.98 < seed_2 then
		return module_7[math.random(1, #module_7)]
	end
	if 0.8 < seed_2 then
		return module_4[math.random(1, #module_4)]
	end
	return module_6[math.random(1, #module_6)]
end
tbl_2.getCrate = getCrate
tbl["Standard Crate"] = tbl_2
tbl["Digital Crate"] = {
	price = 25;
	description = "80% chance to get a common nametag, 18% chance to get an uncommon nametag, 2% chance to get a RARE nametag!";
	decal = "rbxassetid://118112669619148";
	possibilities = {"Vaporwave", "Nostalgia", "Relaxed", "Solar", "Neon", "Wireframe", "Futuristic", "Glitchcore"};
	getCrate = function() -- Line 219, Named "getCrate"
		local module = {"Vaporwave", "Nostalgia", "Relaxed"}
		local module_9 = {"Solar", "Neon", "Wireframe"}
		local module_5 = {"Futuristic", "Glitchcore"}
		local seed = math.random()
		if 0.98 < seed then
			return module_5[math.random(1, #module_5)]
		end
		if 0.8 < seed then
			return module_9[math.random(1, #module_9)]
		end
		return module[math.random(1, #module)]
	end;
}
module_8.Crates = tbl
module_8.Nametags = {
	Green = {
		description = "";
		rarity = 1;
	};
	Cyan = {
		description = "";
		rarity = 1;
	};
	Purple = {
		description = "";
		rarity = 1;
	};
	Pink = {
		description = "";
		rarity = 1;
	};
	Blue = {
		description = "";
		rarity = 1;
	};
	Orange = {
		description = "";
		rarity = 1;
	};
	Red = {
		description = "";
		rarity = 1;
	};
	Yellow = {
		description = "";
		rarity = 1;
	};
	["Glowing Green"] = {
		description = "";
		rarity = 3;
	};
	["Glowing Cyan"] = {
		description = "";
		rarity = 3;
	};
	["Glowing Purple"] = {
		description = "";
		rarity = 3;
	};
	["Glowing Pink"] = {
		description = "";
		rarity = 3;
	};
	["Glowing Orange"] = {
		description = "";
		rarity = 3;
	};
	["Glowing Red"] = {
		description = "";
		rarity = 3;
	};
	["Glowing Yellow"] = {
		description = "";
		rarity = 3;
	};
	["Draw Four"] = {
		description = "";
		rarity = 1;
	};
	Velvet = {
		description = "";
		rarity = 1;
	};
	Mysterious = {
		description = "";
		rarity = 1;
	};
	Sketchbook = {
		description = "";
		rarity = 1;
	};
	Viscount = {
		description = "";
		rarity = 1;
	};
	Diary = {
		description = "";
		rarity = 1;
	};
	Lolcats = {
		description = "";
		rarity = 2;
	};
	["3D Movie"] = {
		description = "";
		rarity = 2;
	};
	["Fruit Salad"] = {
		description = "";
		rarity = 2;
	};
	Bubblegum = {
		description = "";
		rarity = 3;
	};
	Vaporwave = {
		description = "";
		rarity = 1;
	};
	Nostalgia = {
		description = "";
		rarity = 1;
	};
	Relaxed = {
		description = "";
		rarity = 1;
	};
	Solar = {
		description = "";
		rarity = 2;
	};
	Neon = {
		description = "";
		rarity = 2;
	};
	Wireframe = {
		description = "";
		rarity = 2;
	};
	Futuristic = {
		description = "";
		rarity = 3;
	};
	Glitchcore = {
		description = "";
		rarity = 3;
	};
	["Candy Cane"] = {
		description = "Awarded to players who completed the 2024 Holiday Quest!";
		rarity = 4;
	};
	["Festive Gold"] = {
		description = "Awarded to players who purchased the 2024 Holiday Pack!";
		rarity = 5;
	};
	Rainbow = {
		description = "Awarded to players who purchased the Rainbow Pack!";
		rarity = 5;
	};
	["Token Hunter"] = {
		description = "Awarded to players who completed The Hunt: Mega Edition quest!";
		rarity = 4;
	};
}
local tbl_4 = {}
local tbl_6 = {
	name = "Maximum Size";
	order = 1;
	initial = 0.5;
	maxLevel = 10;
	image = "rbxassetid://17151582981";
	color = Color3.new(0.596078, 1, 0.698039);
}
local function priceFunction(arg1) -- Line 407
	return math.floor(arg1 ^ 3 / 2) * 20
end
tbl_6.priceFunction = priceFunction
local function growthFunction(arg1) -- Line 412
	return math.floor(((arg1 + 0.5) ^ 2 - 0.25) / 2 * 100)
end
tbl_6.growthFunction = growthFunction
tbl_4.MaxSize = tbl_6
local tbl_7 = {
	name = "Walk Speed";
	order = 2;
	initial = 0.5;
	maxLevel = 10;
	image = "rbxassetid://17137197155";
	color = Color3.new(0.439216, 0.541176, 1);
}
local function priceFunction(arg1) -- Line 425
	return math.floor((arg1 * 3) ^ 3 / 200) * 1000
end
tbl_7.priceFunction = priceFunction
local function growthFunction(arg1) -- Line 431
	return math.floor(arg1 * 2 + 10)
end
tbl_7.growthFunction = growthFunction
tbl_4.Speed = tbl_7
local tbl_5 = {
	name = "Size Multiplier";
	order = 3;
	initial = 0.5;
	maxLevel = 10;
	image = "rbxassetid://17137197010";
	color = Color3.new(1, 0.384314, 0.396078);
}
local function priceFunction(arg1) -- Line 445
	return math.floor((arg1 * 10) ^ 3 / 200) * 1000
end
tbl_5.priceFunction = priceFunction
local function growthFunction(arg1) -- Line 451
	return math.floor(arg1)
end
tbl_5.growthFunction = growthFunction
tbl_4.Multiplier = tbl_5
tbl_4.EatSpeed = {
	name = "Eat Speed";
	order = 4;
	initial = 0.5;
	maxLevel = 10;
	image = "rbxassetid://16676559094";
	color = Color3.new(1, 0.854902, 0.521569);
	priceFunction = function(arg1) -- Line 465, Named "priceFunction"
		return math.floor((arg1 * 10) ^ 3 / 200) * 2000
	end;
	growthFunction = function(arg1) -- Line 471, Named "growthFunction"
		return math.floor((1 + (arg1 - 1) * 0.2) * 10) / 10
	end;
}
module_8.Upgrades = tbl_4
module_8.Tools = {}
module_8.Descriptions = {
	["Eat Players"] = "Eat players smaller than you to steal their size!";
	Magnet = "Automatically collect money!";
	["Explosive Chunks"] = "Anything you throw explodes on impact, dealing more damage!";
}
return module_8

]]

-- local values = {}
-- local conn conn = game.Players.LocalPlayer.Character.Size.Changed:Connect(function(value)
    -- if value <= 1 then
        -- conn:Disconnect()
        -- toclipboard(table.concat(values, "\n"))
    -- end
    -- table.insert(values, value)
    -- print(value)
-- end)

-- function calculateGiantSize(multiplier, index)
    -- local baseValue = 0.88 * index + 0.015 * index^2 + 0.001 * index^3
    -- return tonumber(string.format("%.2f", baseValue * (multiplier / 45)))
-- end

-- local data = ([[
-- 0
-- 1.8
-- 3.6
-- 4.95
-- 5.8500000000000005
-- 7.2
-- 9
-- 9.9
-- 10.8
-- 12.15
-- 13.05
-- 14.4
-- 15.75
-- 17.1
-- 18.450000000000003
-- 20.250000000000004
-- 21.600000000000005
-- 22.500000000000004
-- 23.850000000000005
-- 25.650000000000006
-- 26.550000000000004
-- 27.900000000000006
-- 28.800000000000004
-- 30.600000000000005
-- 31.500000000000004
-- 32.85
-- 34.2
-- 35.550000000000004
-- 36.900000000000006
-- 38.25000000000001
-- 39.150000000000006
-- 40.95
-- 42.300000000000004
-- 43.650000000000006
-- 45.45
-- 46.35
-- 47.25
-- 48.15
-- 49.05
-- 50.849999999999994
-- 52.64999999999999
-- 54.44999999999999
-- 56.249999999999986
-- 58.04999999999998
-- 59.84999999999998
-- 61.64999999999998
-- 62.99999999999998
-- 64.79999999999998
-- 66.59999999999998
-- 68.39999999999998
-- 69.29999999999998
-- 71.09999999999998
-- 72.44999999999997
-- 73.34999999999998
-- 75.14999999999998
-- 76.49999999999997
-- 78.29999999999997
-- 79.64999999999996
-- 80.99999999999996
-- 82.34999999999995
-- 84.14999999999995
-- 85.49999999999994
-- 86.39999999999995
-- 87.29999999999995
-- 88.19999999999996
-- 89.09999999999997
-- 89.99999999999997
-- 91.79999999999997
-- 93.59999999999997
-- 94.94999999999996
-- 96.74999999999996
-- 98.54999999999995
-- 99.44999999999996
-- 101.24999999999996
-- 102.59999999999995
-- 104.39999999999995
-- 105.74999999999994
-- 107.09999999999994
-- 108.44999999999993
-- 109.79999999999993
-- 110.69999999999993
-- 112.04999999999993
-- 113.39999999999992
-- 114.74999999999991
-- 115.64999999999992
-- 116.54999999999993
-- 117.89999999999992
-- 119.24999999999991
-- 120.14999999999992
-- 121.04999999999993
-- 122.84999999999992
-- 124.64999999999992
-- 125.54999999999993
-- 127.34999999999992
-- 129.14999999999992
-- 130.04999999999993
-- 131.84999999999994
-- 133.19999999999993
-- 134.09999999999994
-- 135.44999999999993
-- 136.79999999999993
-- 138.14999999999992
-- 139.94999999999993
-- 141.74999999999994
-- 143.54999999999995
-- 144.44999999999996
-- 145.79999999999995
-- 147.59999999999997
-- 148.94999999999996
-- 150.29999999999995
-- 152.09999999999997
-- 152.99999999999997
-- 154.79999999999998
-- 156.6
-- 158.4
-- 159.75
-- 161.1
-- 162
-- 163.8
-- 165.60000000000002
-- 166.95000000000002
-- 167.85000000000002
-- 168.75000000000003
-- 170.55000000000004
-- 171.90000000000003
-- 172.80000000000004
-- 174.60000000000005
-- 175.50000000000006
-- 176.85000000000005
-- 178.20000000000005
-- 179.10000000000005
-- 180.90000000000006
-- 182.25000000000006
-- 183.60000000000005
-- 184.50000000000006
-- 185.85000000000005
-- 187.20000000000005
-- 188.10000000000005
-- 189.00000000000006
-- 190.80000000000007
-- 192.15000000000006
-- 193.50000000000006
-- 194.40000000000006
-- 195.30000000000007
-- 197.10000000000008
-- 198.9000000000001
-- 200.7000000000001
-- 201.6000000000001
-- 202.5000000000001]]):split("\n")


