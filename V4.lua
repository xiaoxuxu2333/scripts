local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ParryAttempt = Remotes:WaitForChild("ParryAttempt")

local Maid = (function()
	local source = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/devSparkle/Maid/main/src/MaidClass.lua"))()
	if not source then
		return (function()
			--!nonstrict
			--// Initialization
			
			--[=[
				@class Maid
			]=]
			local Maid = {}
			Maid.__index = Maid
			
			--[=[
				@within Maid
				@type MaidTask () -> () | Instance | RBXScriptConnection | Maid | thread
				
				`MaidTask` describes all types of tasks a `Maid` instance can handle.
			]=]
			type MaidTask = () -> () | Instance | RBXScriptConnection | Maid | thread
			type Maid = typeof(setmetatable({_Tasks = {}:: {MaidTask}}, Maid))
			
			--// Functions
			
			--[=[
				Creates a new instance of the Maid class.
				
				:::caution
				The Maid class cannot be used directly. First, you must create a Maid instance with `Maid.new()`
				:::
			]=]
			function Maid.new(): Maid
				return setmetatable({_Tasks = {}}, Maid)
			end
			
			--[=[
				Will ingest any type of [MaidTask] for later cleaning through [Maid:DoCleaning()].
			]=]
			function Maid:GiveTask(Task: MaidTask)
				table.insert(self._Tasks, Task)
			end
			
			--[=[
				Will listen for the provided Instance's destruction, and run [Maid:DoCleaning()] when this takes place.
				
				:::note
				During cleanup, whether invoked by the object's destruction or another method
				call; the maid will destroy any connections used to listen for destruction.
				:::
			]=]
			function Maid:LinkToInstance(Object: Instance)
				self:GiveTask(Object.Destroying:Connect(function()
					self:DoCleaning()
				end))
			end
			
			--[=[
				Will empty the current task table, and iterate over the previously
				given tasks and clean them up, depending on the type of [MaidTask].
				
				- Tasks of type `RBXScriptConnection`, or tables with a `Disconnect` method
				will have `::Disconnect()` called upon them.
				
				- Tasks of type `thread` will be terminated through `coroutine.close(Task)`.
				
				- Tasks of type `Instance`, or tables with a `Destroy` method will have
				`::Destroy()` called upon them.
				
				- **Any other tasks** will be called as a function.
				
				:::tip
				Because the default fallback behaviour is to call a given task like
				a function, tables with a `__call` metamethod can be given as a task.
				:::
				
				:::info
				Only tasks given up to this method's initial invocation will be cleaned,
				even if this method is still running while another task is being given.
				:::
				
				@yields
			]=]
			function Maid:DoCleaning()
				local Tasks = self._Tasks
				self._Tasks = {}
				
				for _, Task in next, Tasks do
					local TaskType = typeof(Task)
					local IsTable = (TaskType == "table")
					
					if TaskType == "RBXScriptConnection" or (IsTable and Task.Disconnect) then
						Task:Disconnect()
					elseif TaskType == "thread" then
						coroutine.close(Task)
					elseif TaskType == "Instance" or (IsTable and Task.Destroy) then
						Task:Destroy()
					else
						Task()
					end
				end
				
				table.clear(Tasks)
			end
			
			Maid.Disconnect = Maid.DoCleaning
			Maid.Destroy = Maid.DoCleaning
			
			return table.freeze(Maid)
		end)()
	end
	
	return source
end)()

if _G.maid then
	_G.maid:DoCleaning()
else
	_G.maid = Maid.new()
end

local player = Players.LocalPlayer
local maid = _G.maid
local lastTarget

local function findBall()
	local balls = workspace.Balls:GetChildren()
	
	for _, ball in ipairs(balls) do
		if ball:GetAttribute("realBall") then
			return ball
		end
	end
end

local function isSpam(ball, character)
	local distance = (ball.Position - character.HumanoidRootPart.Position).Magnitude
	local speed = ball.AssemblyLinearVelocity.Magnitude
	local maxDistance = speed / 2.73
	local lastTargetDistance = math.huge
	
	if lastTarget then
		lastTargetDistance = (lastTarget.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
	end
	
	if lastTargetDistance < 30 and speed > 25 then
		return true
	end
	
	return false
end

local function parry(character)
	local cf1 = CFrame.new()
	local tab1 = {}
	
	for _, alive in ipairs(workspace.Alive:GetChildren()) do
		local playerAlive = Players:GetPlayerFromCharacter(alive)
		if alive == lastTarget then
			tab1[tostring(playerAlive.UserId)] = character.HumanoidRootPart.Position
		else
			tab1[tostring(playerAlive.UserId)] = Vector3.zero
		end
	end
	
	if lastTarget then
		cf1 = CFrame.lookAt(character.HumanoidRootPart.Position, lastTarget.HumanoidRootPart.Position)
	end
	
	ParryAttempt:FireServer(
		0.5,
		cf1,
		tab1,
		{
			0,
			0
		}
	)
end

maid:GiveTask(task.spawn(function()
	while true do
		local ball, character = findBall(), player.Character
		if ball and character and character:FindFirstChild("HumanoidRootPart") then
			local distance = (ball.Position - character.HumanoidRootPart.Position).Magnitude
			local speed = ball.AssemblyLinearVelocity.Magnitude
			local maxDistance = speed / 2.73
			local zoomiesSpeed = ball.zoomies.VectorVelocity.Magnitude
			
			local target = ball:GetAttribute("target")
			
			if speed < 20 then
				maxDistance = 20
			end
			
			if target == player.Name then
				if distance <= maxDistance then
					if not isSpam(ball, character) then
						parry(character)
						ball.Changed:Wait()
					else
						repeat
							parry(character)
							character.HumanoidRootPart.CFrame *= CFrame.new(0, 1, 0)
							task.wait()
						until not isSpam(ball, character) or not ball.Parent or not character.Parent
					end
				end
			end
			
			for _, char in ipairs(workspace.Alive:GetChildren()) do
				if char == character then continue end
				
				local vector = (char.HumanoidRootPart.Position - character.HumanoidRootPart.Position)
				if vector.Magnitude < 25 then
					character.HumanoidRootPart.CFrame += -vector.Unit * 1
				end
			end
			
			if zoomiesSpeed < 1 then
				local vector = (ball.Position - character.HumanoidRootPart.Position)
				if vector.Magnitude < 50 then
					character.HumanoidRootPart.CFrame += vector.Unit * 1
				end
			end
		end
		task.wait()
	end
end))

maid:GiveTask(task.spawn(function()
	while true do
		local ball, character = findBall(), player.Character
		if ball and character then
			local target = ball:GetAttribute("target")
			ball.Changed:Wait()
			if target == character then return end
			lastTarget = workspace.Alive:FindFirstChild(target)
		end
		task.wait()
	end
end))

