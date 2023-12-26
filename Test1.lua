local Cooldown = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("Utilities")
		:WaitForChild("Cooldown")
)
local Input = require(
	game:GetService("StarterPlayer").StarterPlayerScripts:WaitForChild("Input")
)
require(script.Parent:WaitForChild("CreateInput"))
local PART = Instance.new("Part")
PART.Color = Color3.fromRGB(203, 28, 31)
PART.Material = Enum.Material.Neon

local InputModule, Hooker = Input.Module, Input.Hooker
local CooldownModule = Cooldown.Module
local Info = require(script.Parent:WaitForChild("Info"))

local CooldownInfo = Info.StarSplitter.CooldownConfig
local StarSplitterInfo = Info.StarSplitter
local StarSplitterKeybind = StarSplitterInfo.Key
local CooldownObject = CooldownModule.new(CooldownInfo) 
local Hooks = {}
local StarSplitter = {}
function StarSplitter.EnableBind()
	for _, Hook in Hooks do
		Hook:Enable()
	end
	CooldownObject:Reset()
end
function StarSplitter.DisableBind()
	for _, Hook in Hooks do
		Hook:Disable()
	end
	CooldownObject:Reset()
end
local DidHold = false
function StarSplitter.AddBind()
	table.insert(Hooks, InputModule.AddHookToCategory(Hooker.new({
		Path = "IronSide/StarSplitter",
		Event = "InputBegan",
		Function = function(Input, GPE)
			if CooldownObject:IsOnCooldown() or GPE then return end
			if Input.KeyCode == Enum.KeyCode[StarSplitterKeybind] then
				DidHold = true
				task.spawn(StarSplitter._SummonAttacks)
				print(1)	
			end
		end,
	}), "Hold"))
	table.insert(Hooks, InputModule.AddHookToCategory(Hooker.new({
		Path = "IronSide/StarSplitter",
		Event = "InputEnded",
		Function = function(Input, GPE)
			if CooldownObject:IsOnCooldown() or not DidHold then return end
			if Input.KeyCode == Enum.KeyCode[StarSplitterKeybind] then
				CooldownObject:Reset()
				DidHold = false
				print(0)
			end
		end,
	}), "Release"))
end
function StarSplitter.DestroyBind()
	InputModule.RemoveCategory("StarSplitter", "IronSide")
end
function StarSplitter._CreateStructure()
	
end
function StarSplitter._SummonAttacks()
end
return StarSplitter
