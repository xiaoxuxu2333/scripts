local Maid = (function()
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local PlayerName = Player.Name
local Mouse = Player:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BallAdded = Remotes:WaitForChild("BallAdded")
local ParryAttempt = Remotes:WaitForChild("ParryAttempt")
local PlrInvisibilityd = Remotes:WaitForChild("PlrInvisibilityd")
local Platform = Remotes:WaitForChild("Platform")
local RequestEquipAbility = Remotes.Store:WaitForChild("RequestEquipAbility")
local PlrForcefielded = Remotes:WaitForChild("PlrForcefielded")
local ShadowFollow = Remotes:WaitForChild("ShadowFollow")

if _G.Maid then
	_G.Maid:DoCleaning()
	_G.Maid = nil
end

local Maid = Maid.new()
_G.Maid = Maid

local PARRY_SPAM_MIN_DISTANCE = 30

local function findRealBall()
	for _, ball in ipairs(workspace.Balls:GetChildren()) do
		if ball:GetAttribute("realBall") then
			return ball
		end
	end
end

local function isOthersInvis()
	for _, character in ipairs(workspace.Alive:GetChildren()) do
		if character == Player.Character then continue end
		if character.Torso.Transparency < 1 then
			return false
		end
	end
	
	return true
end

local function parry()
	local playersDistance = {}
	for _, playerCharacter in next, workspace.Alive:GetChildren() do
		local player = Players[playerCharacter.Name]
		playersDistance[tostring(player.UserId)] = Vector3.zero
	end
	
	local angles
	local ball = findRealBall()
	
	if ball then
		angles = CFrame.lookAt(Vector3.zero, Player.Character.HumanoidRootPart.CFrame.LookVector)
	else
		angles = CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))
	end
	
	ParryAttempt:FireServer(0.5, angles, playersDistance, {238, 40})
end

Maid:GiveTask(task.spawn(function()
	local lastTarget
	local lastTargetDistance = 0
	
	while true do
		local dt = task.wait()
		
		local ball = findRealBall()
		local character = Player.Character
		local zoomies = ball and ball:FindFirstChild("zoomies")
		
		if not (ball and zoomies and character and character:FindFirstChild("HumanoidRootPart") and character.Parent ~= workspace.Dead) then continue end
		
		local ballVel = zoomies.VectorVelocity
		local ballSpd = ballVel.Magnitude
		local ballPos = ball.Position + ball.AssemblyLinearVelocity
		local ballRealVel = ball.AssemblyLinearVelocity
		local ballRealSpd = ballRealVel.Magnitude
		local ballRealPos = ball.Position
		
		local characterPos = character.HumanoidRootPart.Position
		
		local distance = (characterPos - ballRealPos).Magnitude
		local maxDistance = math.floor(ballSpd / 2.74)
		
		print(maxDistance)
		
		if ballRealSpd < 20 then
			maxDistance = 15
		end
		
		if ball:GetAttribute("target") == PlayerName then
			
			if distance < maxDistance then
				character.Humanoid:MoveTo(character.HumanoidRootPart.Position)
				parry()
				
				if lastTargetDistance > PARRY_SPAM_MIN_DISTANCE then
					ball.Changed:Wait()
				else
					repeat
						lastTarget = workspace.Alive:FindFirstChild(ball:GetAttribute("target"))
						if lastTarget then
							if lastTarget ~= character and lastTarget.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
								lastTargetDistance = (lastTarget.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
							else
								lastTargetDistance = 1000
							end
						end
						for _ = 1, 200 do
							parry()
						end
						
						task.wait()
					until lastTargetDistance > PARRY_SPAM_MIN_DISTANCE
					
					--PlrForcefielded:FireServer()
				end
				
				--[[if distance > PARRY_SPAM_MIN_DISTANCE then
					ball.Changed:Wait()
				else
					if not isOthersInvis() then
						print("spam")
						parry()
						
						--for _ = 1, 16 do
						--	task.spawn(parry)
						--end
						--PlrForcefielded:FireServer()
						--
					else
						print("instant spam")
						repeat
							parry()
							task.wait()
						until not isOthersInvis()
					end
				end
				--]]
			end
		else
			lastTarget = workspace.Alive:FindFirstChild(ball:GetAttribute("target"))
			if lastTarget then
				lastTargetDistance = (lastTarget.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
				character.HumanoidRootPart.CFrame = CFrame.lookAt(
					character.HumanoidRootPart.Position,
					Vector3.new(
						lastTarget.HumanoidRootPart.Position.X,
						character.HumanoidRootPart.Position.Y,
						lastTarget.HumanoidRootPart.Position.Z
					)
				)
				character.Humanoid:MoveTo(lastTarget.HumanoidRootPart.Position)
			end
		end
	end
end))

print("executed")
