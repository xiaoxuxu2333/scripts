Param = OverlapParams.new()
Param.CollisionGroup = "Default"
Param.FilterType = Enum.RaycastFilterType.Exclude

local function main()
	local function init()
		_G.temp = _G.temp or {}
	end
	local function new()
		for _, v in ipairs(_G.temp) do
			v:Destroy()
		end
		
		--if true then return end
		
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == "Rail"
				and obj.Size.X == 1
				and obj.Size.Y == 1
				--and #workspace:GetPartBoundsInBox(obj.CFrame * CFrame.new(0, 1.7 + 0.125, 0), obj.Size + Vector3.new(0, 0, 10), Param) == 0
			then
				local newObj = obj:Clone()
				newObj.CollisionGroup = "GuideRails"
				newObj.Size = obj.Size + Vector3.new(0, -0.75, 0)
				newObj.CFrame = obj.CFrame * CFrame.new(0, 1.7 + 0.125, 0)
				newObj.Transparency = 0.5
				newObj.Parent = obj.Parent
				table.insert(_G.temp, newObj)
				
				--[[if obj.Parent.Parent.Name == "Lanes" then continue end
				
				local newObj = newObj:Clone()
				newObj.Material = Enum.Material.Ice
				newObj.CollisionGroup = "GuideRails"
				newObj.BrickColor = BrickColor.Green()
				newObj.Size = Vector3.new(0.25, 1, obj.Size.Z)
				newObj.CFrame = obj.CFrame * CFrame.new(1, 1, 0)
				newObj.Parent = obj.Parent
				table.insert(_G.temp, newObj)
				
				local newObj = newObj:Clone()
				newObj.Material = Enum.Material.Ice
				newObj.CollisionGroup = "GuideRails"
				newObj.BrickColor = BrickColor.Green()
				newObj.Size = Vector3.new(0.25, 1, obj.Size.Z)
				newObj.CFrame = obj.CFrame * CFrame.new(-1, 1, 0)
				newObj.Parent = obj.Parent
				table.insert(_G.temp, newObj)]]
				
				
			elseif obj:IsA("WedgePart") or obj.Name == "Junk" or obj.Name == "NPCs" or obj.Name == "Oval" or obj.Name == "Tube" or obj.Name == "Ring" or obj.Name == "DamagePart" then
				if obj:IsA("BasePart") then
					obj.CanCollide = false
					obj.Transparency = 0.5
				elseif obj:IsA("Folder") then
					obj:Destroy()
				else
					for _, v in ipairs(obj:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
							v.Transparency = 0.5
						end
					end
				end
			elseif obj.Name == "Hammer" and obj:FindFirstChild("Hammer") then
				obj.Hammer.CanCollide = false
				obj.Hammer.Transparency = 0.5
			elseif obj.Name == "Boulder" or obj.Name == "Rocket" then
				obj.Transparency = 0.5
			elseif obj.Name == "Cannon" then
				for _, part in ipairs(obj:GetChildren()) do
					if part.Transparency < 1 then
						part.Transparency = 0.5
					end
				end
			end
		end
	end
	
	init()
	new()
end

main()
