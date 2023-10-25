local arr = {}

for angle = 0, 360, 360 / 39.999 do
	local rad = math.rad(angle)
	local x = math.cos(rad) / 0.5
	local y = math.sin(rad) / 0.5
	
	table.insert(arr, {x = x, y = y})
end

--[[for i = 2,  #arr do
	local pos = arr[i]
	pos = Vector2.new(pos.x, pos.y)
	
	local last = arr[i - 1]
	last = Vector2.new(last.x, last.y)
	
	for alpha = 0, 1, 0.1 do
		local lerp =  pos:Lerp(last, alpha)
		table.insert(arr, {x = lerp.X, y = lerp.Y})
	end
end]]

local args = {
	arr,
    	BrickColor.Green()
}

game:GetService("ReplicatedStorage"):WaitForChild("SubmitDrawing"):FireServer(unpack(args))
