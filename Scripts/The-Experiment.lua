RoomPanel = workspace.TCamera.RoomPanel

--RoomPanel.Next.Click
--RoomPanel.Prev.Click
--RoomPanel.Screen.Gui.Panel.RoomPage.Text

_G.Toggle = true

TargetPage = 4

while _G.Toggle do
	task.wait()
	if RoomPanel:GetAttribute("Reconnecting") then continue end
	
	local page = tonumber(RoomPanel.Screen.Gui.Panel.RoomPage.Text:sub(3, 3))
	
	if page < TargetPage then
		fireclickdetector(RoomPanel.Next.Click)
		task.wait(0.3)
	elseif page > TargetPage then
		fireclickdetector(RoomPanel.Prev.Click)
		task.wait(0.3)
	end
end
