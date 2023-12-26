local Input = require(script.Parent:WaitForChild("Input"))
local InputModule = Input.Module
local Hooker = Input.Hooker

InputModule.CreateCategory("Test", "")
InputModule.AddHookToCategory(Hooker.new({
	Path = "Test",
	Event = "InputBegan",
	Combination = "H->J->K",
	Function = function(GPE)
		print("Dude")
	end,
}), "Tester")
