local Parts = {}
for _,v in pairs(workspace:GetDescendants()) do
	if v:IsA("BasePart") and v.Name ~= "Terrain" then
		table.insert(Parts,v)
	end
end

jp = {
	size = {};
	cframe = {};
	color = {};
	transparency = {};
	cancollide = {};
	material = {}
}

for i,v in pairs(Parts) do
	table.insert(jp.size,tostring(v.Size))
	table.insert(jp.cframe,tostring(v.CFrame))
	table.insert(jp.color,tostring(v.Color))
	table.insert(jp.transparency,tostring(v.Transparency))
	table.insert(jp.cancollide,tostring(v.CanCollide))
	table.insert(jp.material,tostring(v.Material.Value))
	print("Saving",i.."/"..#Parts)
end
--print(game:GetService("HttpService"):JSONEncode(jp))
writefile("Parts.txt", game:GetService("HttpService"):JSONEncode(jp))