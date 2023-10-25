local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local bp = plr:WaitForChild("Backpack")
local char = plr.Character
local f3x = bp["Building Tools"] or char["Building Tools"]
local main = f3x.SyncAPI.ServerEndpoint

--//function area\\--

function resize(part,cframe,size)
	main:InvokeServer("SyncResize",{{Part = part,CFrame = cframe, Size = size}})
end

function remove(part)
	main:InvokeServer("Remove",{Part = part})
end

function material(part,material)
	main:InvokeServer("SyncMaterial",{{Part = part, Material = material}})
end

function color(part,color)
	main:InvokeServer("SyncColor",{{Color = color, Part = part, UnionColoring = true}})
end

function create(type,cframe,parent)
	main:InvokeServer("CreatePart",type,cframe,parent)
end

function move(part,cframe)
	main:InvokeServer("SyncMove",{{CFrame = cframe, Part = part}})
end

function texture(part,face,texturetype,texture)
	main:InvokeServer("CreateTextures",{{Part = part, Face = face, TextureType = texturetype}})
	wait()
	main:InvokeServer("SyncTexture",{{Part = part, Face = face, TextureType = texturetype, Texture = texture}})
end

function anchor(part,turn)
	main:InvokeServer("SyncAnchor",{{Part = part, Anchored = turn}})
end

function coll(part,turn)
	main:InvokeServer("SyncCollision",{{Part = part, CanCollide = turn}})
end

function surf(part,top,front,bottom,right,left,back)
	main:InvokeServer("SyncSurface",{{Part = part,{Top = top, Front = front, Bottom = bottom, Right = right, Left = left, Back = back}}})
end

function clone(part,parent)
	main:InvokeServer("Clone",{Part = part},parent)
end

function rot(part,cframe)
	main:InvokeServer("SyncRotate",{{Part = part, CFrame = cframe}})
end

function lock(part,bool)
	main:InvokeServer("SetLocked",{part},bool)
end

function tran(part,tran)
	main:InvokeServer("SyncMaterial",{{Part = part, Transparency = tran}})
end

local PARENT = workspace.Script

local HttpService = game:GetService("HttpService")
local Parts = HttpService:JSONDecode(readfile("Parts.txt"))



for i = 1, #Parts.size do spawn(function()
	local c = string.split(tostring(Parts.cframe[i]), ",")
	create("Normal",CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12]),PARENT)
	print("Spawning",i.."/"..#Parts.size)
end)end
wait(1)
for i,v in pairs(PARENT:GetChildren()) do spawn(function()
		lock(v,true)
		print("locking",i.."/"..#Parts.size)
	end)
end
wait(8)
for i,v in pairs(PARENT:GetChildren()) do spawn(function()
		local c = string.split(tostring(Parts.cframe[i]), ",")
		local s = string.split(tostring(Parts.size[i]), ",")
		resize(v,CFrame.new(c[1], c[2] + 11, c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12]),Vector3.new(s[1], s[2], s[3]))
		print("resizing",i.."/"..#Parts.size)
	end)
end
wait(8)
for i,v in pairs(PARENT:GetChildren()) do spawn(function()
		local c = string.split(tostring(Parts.color[i]), ",")
		color(v,Color3.new(c[1], c[2], c[3]))
		print("painting",i.."/"..#Parts.size)
	end)
end
wait(8)
for i,v in pairs(PARENT:GetChildren()) do spawn(function()
		tran(v,Parts.transparency[i])
		print("Set Transparency",i.."/"..#Parts.size)
	end)
end
wait(8)
for i,v in pairs(PARENT:GetChildren()) do spawn(function()
		coll(v,Parts.cancollide[i])
		print("Set CanCollide",i.."/"..#Parts.size)
	end)
end
wait(8)
for i,v in pairs(PARENT:GetChildren()) do spawn(function()
		material(v,Parts.material[i])
		print("Set Material",i.."/"..#Parts.size)
	end)
end

