local VirtualInputManager = game:GetService("VirtualInputManager")

local tracks = {}
for _, gui in game.Players.LocalPlayer.PlayerGui:GetChildren() do
    if gui:FindFirstChild("GameplayFrame") then
        for _, track in gui.GameplayFrame.Tracks:GetChildren() do
            if track.Name:find("Track") then
                table.insert(tracks, track)
            end
        end
        break
    end
end

local keys = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.L, Enum.KeyCode.Semicolon}

local UI = loadstring(game:HttpGet("https://gitee.com/xiaoxuxu233/mirror/raw/master/wizard.lua"))()
local window = UI:NewWindow("Unnamed")
local main = window:NewSection("Main")

main:CreateToggle("Auto-Play", function(enabled)
	autoplaying = enabled
	if not enabled then return end

	while autoplaying do
    	for _, track in tracks do
			for _, note in track:GetChildren() do
				local key = keys[tonumber(track.Name:sub(6, 6))]
				if note.Name == "NoteProto" then
					local scale = note.Position.Y.Scale
					if scale > 1 and note.Visible then
						VirtualInputManager:SendKeyEvent(true, key, false, game)
						note.Visible = false
						note.AncestryChanged:Once(function()
							VirtualInputManager:SendKeyEvent(false, key, false, game)
							note.Visible = true
						end)
					end
				else
					local scale = note.Head.Position.Y.Scale
					if scale > 1 and note.Head.Visible then
						note.Head.Visible = false
						VirtualInputManager:SendKeyEvent(true, key, false, game)
					end
					local scale = note.Tail.Position.Y.Scale
					if scale > 0.97 and not note.Head.Visible then
						task.delay(0, function()
							VirtualInputManager:SendKeyEvent(false, key, false, game)
							note.Head.Visible = true
						end)
					end
				end
            end
        end
		task.wait()
	end
end)
