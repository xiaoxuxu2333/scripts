local function findBall()
	for _, ball in ipairs(workspace.Balls:GetChildren()) do
		if ball:GetAttribute("realBall") then
			return ball
		end
	end
end

local char = game.Players.LocalPlayer.Character
local root = char.HumanoidRootPart
local hum = char.Humanoid
local cf = root.CFrame
local ball = findBall()

while hum:GetState() ~= Enum.HumanoidStateType.Dead
	or char.Parent
	or ball.Parent
	or #workspace.Alive:GetChildren() < 2
do
	local startTime = workspace:GetServerTimeNow()
	
	while (workspace:GetServerTimeNow() - startTime) < 25 do
		keypress(Enum.KeyCode.Q)
		keyrelease(Enum.KeyCode.Q)
		root.CFrame = CFrame.new(cf.X, 14000, cf.Z)
		root.AssemblyLinearVelocity = Vector3.zero
		task.wait()
		
		if not (hum:GetState() ~= Enum.HumanoidStateType.Dead
				or char.Parent
				or ball.Parent
				or #workspace.Alive:GetChildren() < 2
			)
		then
			break
		end
	end
	
	root.CFrame = ball.CFrame + ball.zoomies.VectorVelocity
	ball.Changed:Wait()
end

root.CFrame = cf
