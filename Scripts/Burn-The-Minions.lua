local player = game.Players.LocalPlayer
local character = player.Character

local teleportedBlocks = {}

while true do
	for _, block in ipairs(workspace.Blocks.Blockers:GetDescendants()) do
		if block:IsA("Part") and block.Stats:FindFirstChild("Killer") and not table.find(teleportedBlocks, block) then
			if block.Stats.Killer.Value == player.Name then
				block.CFrame = CFrame.new(-100, 300, -300)
				table.insert(teleportedBlocks, block)
			end
			block.CanCollide = false
		end
	end
	task.wait()
end