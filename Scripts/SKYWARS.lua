local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

if _G.Mine then
	_G.Mine:Disconnect()
	_G.Mine = nil
end

_G.Mine = RunService.Heartbeat:Connect(function(deltaTime)
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		if localPlayer.Character:FindFirstChild("Axe") then
			for i, block in ipairs(workspace:GetDescendants()) do
				if block.Name == "Block" and block:IsA("BasePart") and (block.Position - localPlayer.Character.PrimaryPart.Position).Magnitude < 10 then
					localPlayer.Character.Axe.RemoteEvent:FireServer(block)
				end
			end
			
			--[[if mouse.Target and mouse.Target.Name == "Block" then
				localPlayer.Character.Axe.RemoteEvent:FireServer(mouse.Target)
			end]]
		end
	elseif UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		if localPlayer.Character:FindFirstChild("Axe") then
			local map = workspace:FindFirstChild("Map", true)
			
			for i, block in ipairs(map.Ores:GetChildren()) do
				local box = block:FindFirstChild("BoxHandleAdornment") or Instance.new("BoxHandleAdornment", block)
				box.Adornee = block
				box.AlwaysOnTop = true
				box.ZIndex = 0
				box.Size = block.Size
				box.Transparency = 0.5
				
				if (block.Position - localPlayer.Character.PrimaryPart.Position).Magnitude < 10 then
					localPlayer.Character.Axe.RemoteEvent:FireServer(block)
				end
			end
		end
	end
		
	if localPlayer.Character:FindFirstChild("Sword") then
		if localPlayer.Character.Sword.Handle:FindFirstChild("Mesh") then
			localPlayer.Character.Sword.Handle.Mesh:Destroy()
		end
		if localPlayer.Character["Right Arm"]:FindFirstChild("RightGrip") then
			localPlayer.Character["Right Arm"].RightGrip:Destroy()
		end
		localPlayer.Character.Sword.Handle.Anchored = true
		localPlayer.Character.Sword.Handle.CFrame = mouse.Hit
		localPlayer.Character.Sword.Handle.Size = Vector3.one * 10
		localPlayer.Character.Sword.Handle.Massless = true
	end
end)