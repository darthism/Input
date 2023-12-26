local UserInputService = game:GetService("UserInputService")
local function GetFromPath(Table, Path)
	local Temp = Table
	local Flag = true
	for _, Nest in string.split(Path, "/") do
		if not Temp[Nest] then
			Flag = false
			break
		end
		Temp = Temp[Nest]
	end
	return Flag, Temp
end
local function ConvertKeyCodeToWord(KeyCode)
	local StringKeyCode = tostring(KeyCode)
	return StringKeyCode:sub(14, string.len(StringKeyCode))
end
local function ArrayToString(Array)
	local Buffer = ""
	for _, Value in Array do
		Buffer..=tostring(Value)
	end
	return Buffer
end
local Events = {
	InputBegan = {},
	InputEnded = {},
	InputChanged = {},
}
local CombinationsDictionary = {}
local Hooker = {}
Hooker.__index = Hooker

function Hooker.new(Dictionary)
	local self
	self = setmetatable({
		Path = Dictionary.Path,
		Event = Dictionary.Event,
		Function = Dictionary.Function,
		Combination = Dictionary.Combination,
		Enabled = true,
	}, Hooker)
	Events[Dictionary.Event][Dictionary.Path] = self
	if self.Combination then
		CombinationsDictionary[ArrayToString(string.split(self.Combination, "->")).."-"..tostring(self)] = self
	end
	return self
end
function Hooker:Enable()
	self.Enabled = true
end
function Hooker:Disable()
	self.Enabled = false
end
function Hooker:Destroy()
	self:Disable()
	Events[self.Event][self.Path] = nil
	if self.Combination then
		CombinationsDictionary[ArrayToString(string.split(self.Combination, "->")).."-"..tostring(self)] = nil
	end
end
local Category = {}
Category.__tostring = "Category"
function Category.new(Name)
	return setmetatable({
		Name = Name,
		Hooks = {},
	}, Category)
end
local Categories = {}
local Input = {}
function Input.CreateCategory(Name, Path)
	local Success, Table = GetFromPath(Categories, Path)
	if not Path then
		Success = true
	end
	Table[Name] = Category.new(Name)
	Table[Name].Hooks = {}
	if not Success then
		warn(string.format("Unable to create nested category: %s for alleged path: %s", Name, Path))
	end
end
function Input.EnableCategory(Path)
	local _, Table = GetFromPath(Categories, Path)
	for _, Hook in Table.Hooks do
		for Index, Value in Table do
			if Index == "Hooks" then
				continue
			end
			Input.EnableCategory(Path.."/"..Index)
		end
		Hook:Enable()
	end
end
function Input.DisableCategory(Path)
	local _, Table = GetFromPath(Categories, Path)
	for _, Hook in Table.Hooks do
		for Index, Value in Table do
			if Index == "Hooks" then
				continue
			end
			Input.DisableCategory(Path.."/"..Index)
		end
		Hook:Disable()
	end
end
function Input.RemoveCategory(Name, Path)
	local _, Parent = GetFromPath(Categories, Path)
	local Hooks = Parent[Name].Hooks
	for _, Hook in Hooks do
		Hook:Destroy()
	end
	Parent[Name] = nil
end
function Input.AddHookToCategory(Hook, Name)
	local _, Category = GetFromPath(Categories, Hook.Path)
	Category.Hooks[Name] = Hook
	return Hook
end
function Input.RemoveHookFromCategory(Name, Path)
	local _, Category = GetFromPath(Categories, Path)
	local Hook =  Category.Hooks[Name]
	Hook:Destroy()
	Category.Hooks[Name] = nil
end
local TIME_LIMIT = 1
local CombinationsRecord = {}
local Clock
for Event, _ in Events do
	local Hookers = Events[Event]
	UserInputService[Event]:Connect(function(Input, GPE)
		for _, _Hooker in Hookers do
			if not _Hooker.Enabled or _Hooker.Combination then return end
			_Hooker.Function(Input, GPE)
		end
		if Input.KeyCode ~= Enum.KeyCode.Unknown then
			if not Clock then
				Clock = os.clock()
			elseif os.clock() - Clock > TIME_LIMIT then
				table.clear(CombinationsRecord)
			end
			table.insert(CombinationsRecord, ConvertKeyCodeToWord(Input.KeyCode))
			for Combination, _Hooker in CombinationsDictionary do
				Combination = string.split(Combination, "-")[1]
				local Size = string.len(Combination)
				if Size > #CombinationsRecord then
					continue
				end
				local Flag = true
				local Start = #CombinationsRecord - (Size - 1)
				for I = Start, #CombinationsRecord do
					local Key = CombinationsRecord[I]
					if Key ~= Combination:sub(I - (Start - 1), I - (Start - 1)) then
						Flag = false
						Clock = os.clock()
						break
					end
				end
				if Flag then
					_Hooker.Function(GPE)
				end
			end
			Clock = os.clock()
		end
	end)
end
return {
	Module = Input,
	Hooker = Hooker,
}
