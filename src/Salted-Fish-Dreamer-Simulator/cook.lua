local LocalPlayer = game:GetService("Players").LocalPlayer

local Kitchen = game:GetService("Workspace").Stuffs.Kitchen
local ThirteenSpicesCD = Kitchen.ThirteenSpices.ClickDetector

local UILib = getgenv().UILibCache or loadstring(game:HttpGet("https://gitee.com/xiaoxuxu233/mirror/raw/master/wizard.lua"))
getgenv().UILibCache = UILib

local UI = UILib()
local window = UI:NewWindow("Unnamed")
local main = window:NewSection("主要功能")

main:CreateToggle("自动做饭", function(enabled)
    getgenv().cooking = enabled
    if not enabled then return end
    
    while getgenv().cooking do
        for _ = 1, 6 do
            fireclickdetector(ThirteenSpicesCD)
        end
        task.wait()
        fireproximityprompt(Kitchen:WaitForChild("Pot").ProximityPrompt)
    end
end)

main:CreateToggle("自动吃", function(enabled)
    getgenv().eating = enabled
    if not enabled then return end
    
    while getgenv().eating do
        for _, tool in LocalPlayer.Backpack:GetChildren() do
            tool.Parent = LocalPlayer.Character
            tool:Activate()
            task.wait()
            tool.Parent = LocalPlayer.Backpack
        end
        task.wait()
    end
end)