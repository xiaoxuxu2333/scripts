for i, door in ipairs(workspace.OfficeBuild.Doors:GetChildren()) do
	local doorInside = door:FindFirstChild("DoorInside")
	local doorPrimary = doorInside and doorInside.Primary
	local doorHinge = doorPrimary and doorPrimary.HingeConstraint
	if doorHinge then
		doorHinge.Enabled = false
		
		for i, basePart in ipairs(doorInside:GetChildren()) do
			basePart.CanCollide = false
		end
		
		local alignPosition = doorPrimary:FindFirstChild("AlignPosition") or Instance.new("AlignPosition", doorPrimary)
		alignPosition.Responsiveness = 200
		alignPosition.MaxForce = math.huge
		alignPosition.Attachment0 = doorPrimary.Attachment
		alignPosition.Attachment1 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		local alignOrientation = doorPrimary:FindFirstChild("AlignOrientation") or Instance.new("AlignOrientation", doorPrimary)
		alignOrientation.Responsiveness = 200
		alignOrientation.MaxTorque = math.huge
		alignOrientation.Attachment0 = doorPrimary.Attachment
		alignOrientation.Attachment1 = game.Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
	end
end