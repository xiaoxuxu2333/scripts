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
local Mouse = Player:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BallAdded = Remotes:WaitForChild("BallAdded")
local ParryAttempt = Remotes:WaitForChild("ParryAttempt")
local PlrInvisibilityd = Remotes:WaitForChild("PlrInvisibilityd")
local Platform = Remotes:WaitForChild("Platform")
local PlrForcefielded = Remotes:WaitForChild("PlrForcefielded")
local RequestEquipAbility = Remotes.Store:WaitForChild("RequestEquipAbility")

local function findRealBall()
	for _, ball in ipairs(workspace.Balls:GetChildren()) do
		if ball:GetAttribute("realBall") then
			return ball
		end
	end
end

if _G.Maid then
	_G.Maid:DoCleaning()
	_G.Maid = nil
end

local Maid = Maid.new()
_G.Maid = Maid

local Ball = findRealBall()

local PARRY_SPAM_MIN_DISTANCE = 15

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://5273899897"
ClickSound.Volume = 10
ClickSound.PlaybackSpeed = 20

Maid:GiveTask(BallAdded.OnClientEvent:Connect(function(_ball, ...)
	Ball = _ball
end))

local function sendNotification(text)
	StarterGui:SetCore("SendNotification", {
		Title = "Script",
		Text = text,
		Duration = 0,
	})
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
	local tab2 = {238, 40}
	
	for _, playerCharacter in next, workspace.Alive:GetChildren() do
		local player = Players[playerCharacter.Name]
		if playerCharacter:FindFirstChild("HumanoidRootPart") then
			playersDistance[tostring(player.UserId)] = playerCharacter.HumanoidRootPart.Position
		end
	end
	
	local angles
	local ball = findRealBall()
	
	if ball then
		angles = CFrame.lookAt(Vector3.zero, Player.Character.HumanoidRootPart.CFrame.LookVector)
		--angles = CFrame.lookAt(Player.Character.HumanoidRootPart.Position, ball.Position)
	else
		angles = CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))
	end
	
	ParryAttempt:FireServer(0.5, angles, playersDistance, tab2)
end

local function onCharacterAdded(character)
	--[[
	local maid = Maid.new()
	
	local function clean()
		maid:DoCleaning()
	end

	Maid:GiveTask(character.ChildAdded:Connect(function(child)
		if child.Name == "Highlight" then
			sendNotification("Ball")
			
			maid:GiveTask(RunService.RenderStepped:Connect(function()
				local ball = findRealBall()
				
				local zoomies = realBall.zoomies
				
				local ballVelocity = zoomies.VectorVelocity
				local ballSpeed = ballVelocity.Magnitude
				local ballPosition = ball.Position + ballVelocity
				local ballRealVelocity = ball.AssemblyLinearVelocity
				local ballRealSpeed = ballVelocity.Magnitude
				local ballRealPosition = ball.Position
				
				local maxDistance = math.max(ballSpeed / 2.65, 40)
				local distance = (character.HumanoidRootPart.Position - ballRealPosition).Magnitude
				
				if distance < maxDistance then
					sendNotification("Parry")
					
					local hasOthersInvis = isOthersInvis()
					if hasOthersInvis then
						parry()
					end
					
					if distance < PARRY_SPAM_MIN_DISTANCE and ballSpeed > 15 then
						print("Parry Spam")
						parry()
					else
						parry()
						return clean()
					end
					
					parry()
					return clean()
				end
			end))
			
			maid:LinkToInstance(child)
			maid:LinkToInstance(character)
		end
	end))
	
	Maid:GiveTask(character.ChildRemoved:Connect(function(child)
		if child.Name == "Highlight" then
			print("highlight removed")
			return clean()
		end
	end))
	--]]
end

Maid:GiveTask(task.spawn(function()
	while true do
		local ball = findRealBall()
		local character = Player.Character
		if ball and character and character:FindFirstChild("HumanoidRootPart") then
			local zoomies = ball:WaitForChild("zoomies")
			
			local ballVel = zoomies.VectorVelocity
			local ballSpd = ballVel.Magnitude
			local ballPos = ball.Position + ballVel
			local ballRealVel = ball.AssemblyLinearVelocity
			local ballRealSpd = ballRealVel.Magnitude
			local ballRealPos = ball.Position
			
			local characterPos = character.HumanoidRootPart.Position
			
			local distance = (characterPos - ballRealPos).Magnitude
			local maxDistance = math.max(ballSpd / 2.65, if ballRealSpd < 30 then 8 else 40)
			
			if ball:GetAttribute("target") == Player.Name then
				if distance < maxDistance then
					character.Humanoid:MoveTo(character.HumanoidRootPart.Position)
					parry()
					
					if distance > PARRY_SPAM_MIN_DISTANCE
						--and ballRealSpd > 50
					then
						ball.Changed:Wait()
					else
						for _ = 1, 5 do
							parry()
						end
						if not isOthersInvis() then
							PlrForcefielded:FireServer()
						else
							repeat
								parry()
								task.wait()
							until not isOthersInvis()
						end
					end
					
					local target = workspace.Alive:FindFirstChild(ball:GetAttribute("target"))
					if target and not isOthersInvis() then
						character.Humanoid:MoveTo(target.HumanoidRootPart.Position)
					end
				end
			end
		end
		
		task.wait()
	end
end))

Maid:GiveTask(Player.CharacterAdded:Connect(onCharacterAdded))
if Player.Character then onCharacterAdded(Player.Character) end

sendNotification("Executed")
print("executed")
