local function findClosestAlive(maxDst)
	local bestChar
	local bestDst = maxDst
	
	for _, char in workspace.Alive:GetChildren() do
		if char == game.Players.LocalPlayer.Character
			or char:FindFirstChild("HumanoidRootPart") == nil
			or (char.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude > bestDst
		then continue end
		
		bestChar = char
		bestDst = (char.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude
	end
	
	return bestChar
end

local function parry()
	task.spawn(function()
		local positions = {}
		
		for _, plr in game.Players:GetPlayers() do
			positions[tostring(plr.UserId)] = Vector3.zero
		end
		
		game.ReplicatedStorage.Remotes.ParryAttempt:FireServer(0, CFrame.new(), positions, {0, 0})
	end)
end

if bb_co then
	coroutine.close(bb_co)
end

getgenv().bb_co = task.spawn(function()
	local balls = workspace.Balls

	local parried = false
	
	while true do
		task.wait()
		
		local ball = balls:GetChildren()[1]
		local char = game.Players.LocalPlayer.Character
		local root = char:FindFirstChild("HumanoidRootPart")
		if not ball
			or not root
			or char.Parent ~= workspace.Alive
		then continue end

		local targetChar = workspace.Alive:FindFirstChild(ball:GetAttribute("target"))
		if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then continue end

		if targetChar == char
			and ball.velocity.magnitude ~= 0
		then
			if ((root.Position + (root.velocity / 10)) - (ball.Position + (ball.velocity / 5))).magnitude < ball.velocity.magnitude / 2.74
				and not parried
			then
				parry()
				parried = true
				
				while findClosestAlive(20) do
					for _ = 1, 5 do
						parry()
					end
					
					task.wait()
				end
				
				-- repeat
				-- 	task.wait()
				-- until ball:GetAttribute("target") ~= char.Name
				-- 	or not ball.Parent
				-- 	or ball.velocity.magnitude == 0
			end
		else
			if char:FindFirstChild("ParryHighlight") then
				print("maybe pulled")
			end
			
			local dst = (targetChar.HumanoidRootPart.Position - root.Position).magnitude
			
			print(dst)
			
			parried = false
		end
	end
end)
