local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Values = LocalPlayer:WaitForChild("Values")
local LocalPlot = Values:WaitForChild("Plot").Value
local Objects = LocalPlot:WaitForChild("Objects")
local Character = LocalPlayer.Character

local WorldSpawn = workspace:WaitForChild("WorldSpawn")
local Grabable = workspace:WaitForChild("Grabable")

local GrabableConnection = nil
local CurrentOre = "Sandstone"
local CurrentPlayer = LocalPlayer.Name
local Mineables = {}
local isShaking = {}
local Playerst = {}
local WhitelistedOre = {
	"Grass",
	"Sunstone",
	"Dirt",
	"Morganite",
	"Moonstone",
}

function Place(objName, cframe, base)
	local args = {
		[1] = objName,
		[2] = cframe,
		[3] = base
	}
		
	local obj = game:GetService("ReplicatedStorage").Events.Place:InvokeServer(unpack(args))
			
	return obj
end

function Move(obj, cframe, base)
	local args = {
	    [1] = obj,
	    [2] = {
	        [1] = obj.Name,
	        [2] = cframe,
	        [3] = base
	    }
	}
	
	local obj = game:GetService("ReplicatedStorage").Events.Move:InvokeServer(unpack(args))
	
	return obj
end
		
function Delete(obj)
	local args = {
		[1] = obj
	}
	
	local obj = game:GetService("ReplicatedStorage").Events.Delete:InvokeServer(unpack(args))
		
	return obj
end

function Grab(obj, t)
	local args = {
		[1] = obj,
		[2] = t
	}

	local any = game:GetService("ReplicatedStorage").Events.Grab:InvokeServer(unpack(args))

	return any
end

function Finish(base, obj, ...)
	local t = {}

	for i, v in table.pack(...) do
		t[i] = {v}
	end

	local args = {
		[1] = obj.Name,
		[2] = t,
		[3] = base,
		[4] = nil,
		[5] = obj
	}

	local any = game:GetService("ReplicatedStorage").Events.Finish:InvokeServer(unpack(args))

	return any
end

for _, v in ReplicatedStorage:WaitForChild("Mineables"):GetChildren() do
	table.insert(Mineables, v.Name)
end

for _, v in Players:GetPlayers() do
	table.insert(Playerst, v.Name)
end

local Material = loadstring(game:HttpGet("https://pastebin.com/raw/HXQd1X17"))()

local UI = Material.Load({
    Title = "ref科技",
    Style = 1,
    SizeX = 250,
    SizeY = 290,
    Theme = "Dark",
})

local OreTab = UI.New{
   Title = "矿物"
}

OreTab.Toggle{
	Text = "自动挖",
	Callback = function(value)
		autoRefine = value
		
		if autoRefine then
			for _, v in Character:GetDescendants() do
				if v:IsA("BasePart") then
					v.Anchored = true
				end
			end
			
			GrabableConnection = Grabable.ChildAdded:Connect(function(child)
				task.wait()
				
				if child.Name == "MaterialPart" and child:WaitForChild("Owner").Value == LocalPlayer then
					local MatInd = child:WaitForChild("Configuration"):WaitForChild("Data"):WaitForChild("MatInd").Value
					
					if MatInd == "Sandstone" or MatInd == "Raw Oddius" or MatInd == "Raw Cloudnite" then
						table.insert(isShaking, child)
						child.Part:PivotTo(CurrentPlayer.Values.Plot.Value.Objects:FindFirstChild("Advance Furnace"):GetPivot() * CFrame.new(0, 0, -7))
						child.Part:GetPropertyChangedSignal("Material"):Wait()
						if autoShaker then
							child.Part:PivotTo(CurrentPlayer.Values.Plot.Value.Objects:FindFirstChild("Sandbed Shaker"):GetPivot())
							child.Part:GetPropertyChangedSignal("Size"):Wait()
							table.remove(isShaking, table.find(isShaking, child))
						else
							child.Part.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -8)
							table.remove(isShaking, table.find(isShaking, child))
						end
					elseif MatInd == "Raw Sunstone" or MatInd == "Raw Volcanium" then
						table.insert(isShaking, child)
						child.Part:PivotTo(CurrentPlayer.Values.Plot.Value.Objects:FindFirstChild("Atom-8 Furnace"):GetPivot() * CFrame.new(0, 0, -7))
						child.Part:GetPropertyChangedSignal("Material"):Wait()
						table.remove(isShaking, table.find(isShaking, child))
						child.Part.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -8)
					else
						child.Part.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -8)
					end
				end
			end)
			
			while autoRefine and task.wait() do
				for i, v in WorldSpawn:GetChildren() do
					local RockString = v:WaitForChild("RockString").Value
					if RockString == CurrentOre then
						for _, v in v:GetDescendants() do
							if v.Name == "Part" then
								v.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)	
							end
						end
					end
				end
				
				coroutine.resume(coroutine.create(function()
					Character:FindFirstChildOfClass("Tool"):Activate()
				end))
			end
			
			for _, v in Character:GetDescendants() do
				if v:IsA("BasePart") then
					v.Anchored = false
				end
			end
		else
			if GrabableConnection then
				GrabableConnection:Disconnect()
			end
		end
	end,
	Enabled = autoSellOres
}

OreTab.Toggle{
	Text = "自动筛",
	Callback = function(value)
		autoShaker = value
	end,
	Enabled = autoShaker
}

OreTab.Toggle{
	Text = "自动卖",
	Callback = function(value)
		autoSellOres = value
		
		while autoSellOres and task.wait() do
			local counter = game:GetService("Workspace").Map.Sellary.Counter.Counter
	       	local tempOres = {}

			for _, v in Grabable:GetChildren() do
				if v.Name == "MaterialPart" and v:FindFirstChild("Owner") then
					if v.Owner.Value == LocalPlayer then
						if not table.find(WhitelistedOre, v.Configuration.Data.MatInd.Value) and not table.find(isShaking, v) then
							table.insert(tempOres, v)
						end
					end
				end
			end

			Grab(tempOres[1], tempOres)

			for _, v in tempOres do
				local part = v.Part
				part.Position = counter.Position
			end
	   
			task.wait(0.5)
			workspace.Map.Sellary.Keeper.IPart.Interact:FireServer()
			task.wait(2)
	       
			local yesButton = LocalPlayer.PlayerGui.UserGui.Dialog.Yes
	   
			for _, v in pairs(getconnections(yesButton.MouseButton1Click)) do
				v:Fire()
			end
		end
	end,
	Enabled = autoSellOres
}

OreTab.Button{
	Text = "卖不下可以点这个(需要别针1x1)",
	Callback = function()
		for _, v in Grabable:GetChildren() do
			if v.Name == "MaterialPart" and v:FindFirstChild("Owner") then
				if v.Owner.Value == LocalPlayer then
					if not table.find(WhitelistedOre, v.Configuration.Data.MatInd.Value) then
						coroutine.wrap(function()
							Place("Pin 1x1", v:GetPivot(), LocalPlot)
						end)()
					end
				end
			end
		end
		
		for _, v in Objects:GetChildren() do
			if v.Name == "Pin 1x1" then
				coroutine.wrap(function()
					Delete(v)
				end)()
			end
		end
	end
}

OreTab.Dropdown{
	Text = "矿",
	Callback = function(value)
		CurrentOre = value
	end,
	Options = Mineables,
	Menu = {}
}

OreTab.Dropdown{
	Text = "给",
	Callback = function(value)
		CurrentPlayer = Players[value]	
	end,
	Options = Playerst,
	Menu = {}
}