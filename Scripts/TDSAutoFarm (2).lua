local Maplist = {
	["Crossroads"] = {
		"DJ Booth",
		"Commander",
		"Farm",
		"Ranger",
		"Ace Pilot"
	}
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")

if game.PlaceId == 3260590327 then
	local ElevatorsFolder = workspace:WaitForChild("Elevators")
	
	local function Enter(Elevator)
		local args = {
			[1] = "Elevators",
			[2] = "Enter",
			[3] = Elevator
		}
	
		RemoteFunction:InvokeServer(unpack(args))
	end
	
	local function Leave()
		local args = {
			[1] = "Elevators",
			[2] = "Leave"
		}
	
		RemoteFunction:InvokeServer(unpack(args))
	end
	
	local function EquipTroops(Troop)
		local args = {
		    [1] = "Inventory",
		    [2] = "Execute",
		    [3] = "Troops",
		    [4] = "Add",
		    [5] = {
		        ["Name"] = Troop
		    }
		}
	
		RemoteFunction:InvokeServer(unpack(args))
	end
	
	local function UnequipTroops(Troop)
		local args = {
		    [1] = "Inventory",
		    [2] = "Execute",
		    [3] = "Troops",
		    [4] = "Remove",
		    [5] = {
		        ["Name"] = Troop
		    }
		}
	
		RemoteFunction:InvokeServer(unpack(args))
	end
	
	while task.wait() do
		for _, Elevator in ElevatorsFolder:GetChildren() do
			local State = Elevator:WaitForChild("State")
			local Title = State:WaitForChild("Map"):WaitForChild("Title")
			local Difficulty = State:WaitForChild("Difficulty")
			local Players = State:WaitForChild("Players")
			local Timer = State:WaitForChild("Timer")
			if Maplist[Title.Value] and Players.Value == 0 and (Elevator:GetPivot().Position ~= Vector3.new(-89.72832489013672, -3.472903251647949, 37.655303955078125) or Elevator:GetPivot().Position ~= Vector3.new(-77.93400573730469, -3.472903251647949, 58.0836181640625)) then
				Enter(Elevator)
				
				for Name, Troop in RemoteFunction:InvokeServer("Session", "Search", "Inventory.Troops") do
		            if (Troop.Equipped) then
		               UnequipTroops(Name)
		            end
		        end
				
				for _, Troop in Maplist[Title.Value] do
					EquipTroops(Troop)
				end
				
				print("Ready to", Title.Value)
				
				for i = Timer.Value, 0, -1 do
					print("Teleporting...", i)
					
					if State.Players.Value > 1 then
						break
					end
					
					task.wait(1)
				end
				
				Leave()
			end
		end
	end
else
	local State = ReplicatedStorage:WaitForChild("State")
	local Map = State:WaitForChild("Map")
	
	local function Vote(Difficulty)
		RemoteFunction:InvokeServer("Difficulty", "Vote", Difficulty)
	end
	
	local function WaveWait(wave, time)
		repeat
			local CurrentWave = nil
			local CurrentTime = nil
			if time then
				CurrentTime = ReplicatedStorage:WaitForChild("State"):WaitForChild("Timer"):WaitForChild("Time").Value
			elseif wave then
				CurrentWave = tonumber(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameGui"):WaitForChild("Health"):WaitForChild("Wave").Text:sub(6))
			end
				
			task.wait()
		until CurrentWave == wave and CurrentTime == time 
	end
	
	local function Skip(wave)
		WaveWait(wave)
		
		repeat
			task.wait()
		until game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameGui"):WaitForChild("Waves"):WaitForChild("Content").Position == UDim2.fromScale(0, 0)
		
		RemoteFunction:InvokeServer("Waves", "Skip")
	end
	
	local function Place(name, pos, wave, time)
		local CurrentTroop = nil
		
		local Troop = {}
		
		local function TroopWait()
			repeat
				task.wait()
			until CurrentTroop
		end
		
		coroutine.wrap(function()
			WaveWait(wave, time)
		
			CurrentTroop = RemoteFunction:InvokeServer("Troops", "Place", name, {Rotation = CFrame.new(), Position = pos})
	 	end)()
	 	
		function Troop:Sell(wave, time)
			coroutine.wrap(function()
				TroopWait()
				WaveWait(wave, time)
					
				RemoteFunction:InvokeServer("Troops", "Sell", {Troop = CurrentTroop})
			end)()
			
			return Troop
		end
			
		function Troop:Target(wave, time)
			coroutine.wrap(function()
				TroopWait()
				WaveWait(wave, time)
				
				RemoteFunction:InvokeServer("Troops", "Target", "Set", {Troop = CurrentTroop})
			end)()
			
			return Troop
		end
			
		function Troop:Upgrade(wave, time)
			coroutine.wrap(function()
				TroopWait()
				WaveWait(wave, time)
				
				RemoteFunction:InvokeServer("Troops", "Upgrade", "Set", {Troop = CurrentTroop})
			end)()
			
			return Troop
		end
		
		return Troop
	end
	
	if Map.Value == "Crossroads" then
		Vote("Insane")
		Place("Farm", nil):Upgrade():Upgrade(3, 5)
		Place("Farm", nil, 1):Upgrade(1, 5):Upgrade(4, 5)
		Place("Farm", nil, 5):Upgrade(5):Upgrade(5, 5)
		Place("Farm", nil, 6):Upgrade(6):Upgrade(6, 5)
		Place("Farm", nil, 6, 5):Upgrade(6):Upgrade(6, 5)
		
		
		Place("Ace Pilot", nil, 2, 5):Upgrade(7):Upgrade(7):Upgrade(8)
		
		Skip(1)
		Skip(2)
		Skip(3)
		Skip(4)
		Skip(5)
		Skip(6)
		Skip(7)
	end
end