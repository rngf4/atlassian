local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

Table = nil
MainUI = nil
Tab = nil
Button = nil

local modules = {
	Table = "utilities/table",
	MainUI = "components/ui",
	Tab = "components/tab",
	Button = "components/button"
}

if RS:IsStudio() then
	for moduleName, modulePath in next, modules do
		local route = script.Parent
		for _, directory in next, string.split(modulePath, "/") do
			route = route[directory]
		end
		getfenv()[moduleName] = require(route)
	end
end

local function createPrimogenitor(options)
	local objectType = options.type
	options.type = nil
	local instanceObject = Instance.new(objectType)

	local defaults = {
		BorderSizePixel = 0,
		Font = Enum.Font.SourceSans,
		AutoButtonColor = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left
	}

	for property, value in next, defaults do
		pcall(function() 
			instanceObject[property] = value
		end)
	end

	for property, value in next, options do

		instanceObject[property] = value

	end

	local methods = {}

	function methods:object(objectOptions)
		objectOptions.Parent = instanceObject
		return createPrimogenitor(objectOptions)
	end

	function methods:round(borderRadius)
		self:object{
			type = "UICorner",
			CornerRadius = UDim.new(0, borderRadius or 4)
		}

		return self
	end

	return setmetatable(methods, {
		__index = instanceObject, 
		__newindex = function(_, property, value)
			if typeof(value) == "table" and value.isTween ~= nil then
				local to = value.value
				local tween = TS:Create(instanceObject, value.TweenInfo or TweenInfo.new(0.25), {[property] = to})
				tween:Play()
			else
				instanceObject[property] = value
			end
		end,
		__call = function() return instanceObject end
	})
end

--[[local function callOnChange(tbl, attributes)
	setmetatable(tbl, {
		__index = function(_, key)
			if attributes.Has(key) then
				return attributes[key]()
			else
				print("This is not a valid method")
			end
		end,
	})
end]]

local Library = {
	blueprint = {}
}
Library.__index = Library

function Library:create(options)

	options = Table.PreserveMerge({theme = "dark", title="UI Library"}, options)
	local object = {
		type = "library",
		constructor = MainUI.create,
		options = options,
		children = {},
		parent = self
	}
	table.insert(self.blueprint, object)

	return setmetatable(object, Library)
end

function Library:tab(options)
	options = Table.PreserveMerge({name = "Tab", description = nil}, options)
	local object = {
		type = "tab",
		constructor = Tab.create,
		options = options,
		children = {},
		parent = self
	}
	table.insert(self.children, object)
	self.__index = self

	return setmetatable(object, self)
end

function Library:button(options)
	options = Table.PreserveMerge({name = "Button", description = nil, text = "Click", callback = function() end}, options)
	local object = {
		type = "button",
		constructor = Button.create,
		options = options,
		parent = self,
		terminate = true
	}
	table.insert(self.children, object)
	self.__index = self

	return setmetatable(object, self)
end

local function parseModuleNames()
	local loading = {}
	local count = 0
	for moduleName, modulePath in next, modules do
		count = count + 1
		local githubUrl = "https://raw.githubusercontent.com/rngf4/atlassian/main/"
		local route = githubUrl .. modulePath .. ".lua"
		table.insert(loading, {url = route, path = modulePath, name = moduleName})
	end
	return loading, count
end

local function loadModules(setLoadingPercentage)
	local loading, modulesToLoad = parseModuleNames()
	local loadedModules = 0
	local loadingError
	local loadedResponses = {}

	for _, moduleData in next, loading do
		spawn(function()
			local s, e = pcall(function()
				local res = game:HttpGetAsync(moduleData.url, true)
				loadedModules = loadedModules + 1
				setLoadingPercentage(loadedModules / modulesToLoad)
				loadedResponses[moduleData.name] = {response = res, name = moduleData.name}
			end)
			if not s then
				loadingError = e
			end
		end)
	end

	repeat
		task.wait()
	until loadedModules >= modulesToLoad or loadingError

	if not loadingError then
		for _, moduleData in next, loadedResponses do
			local module = loadstring(moduleData.response)
			local moduleEnv = getfenv(module)
			for _, appendingModule in next, loadedResponses do
				if appendingModule.response then
					moduleEnv[appendingModule.name] = loadstring(appendingModule.response)()
				end
			end
			setfenv(module, moduleEnv)

			getfenv()[moduleData.name] = module()
		end
	end

	return loadingError
end

local function constructLayer(layer)
	for index, component in next, layer do
		--if not (index == "__index" or index == "children" or index == "parent") then
		local properties = component.constructor(component)
		Table.PreserveMerge(component, properties)
		local oldIndex = getmetatable(component).__index
		setmetatable(component, {
			__index = oldIndex,
			__newindex = component.tracking.set or nil
		})
		if not component.terminate then
			constructLayer(component.children)
		end
		--end
	end
end

function Library:init()



	local gui = createPrimogenitor{
		type = "ScreenGui",
		Parent = (RS:IsStudio() and game.Players.LocalPlayer.PlayerGui) or game.CoreGui
	}

	local mainFrame = gui:object{
		type = "Frame",
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(34, 39, 43)
	}:round()
	mainFrame.Size = {isTween = true, value = UDim2.fromOffset(300, 175)}

	local loadingBar = mainFrame:object{
		type = "Frame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(54, 59, 63),
		Size = UDim2.fromOffset(200, 8)
	}:round(100)

	local loadingPart = loadingBar:object{
		type = "Frame",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(194, 199, 203),
		Size = UDim2.fromScale(0, 1)
	}:round(100)

	local function setLoadingPercentage(percentage)
		loadingPart.Size = {isTween = true, value = UDim2.fromScale(percentage, 1)}
	end

	self.mainFrame = mainFrame

	if not RS:IsStudio() then
		local loadingError = loadModules(setLoadingPercentage)
		if loadingError then
			error("Critical error loading a module: " .. loadingError)
		end
	else
		local moduleCount = 4
		local dule = 0
		for moduleName, _ in next, modules do
			dule = dule + 1
			wait(0.5)
			setLoadingPercentage(dule/moduleCount)
		end

	end

	wait(0.25)

	loadingBar.BackgroundTransparency = {isTween = true, value = 1}
	loadingPart.BackgroundTransparency = {isTween = true, value = 1}

	wait(0.25)

	loadingBar():Destroy()

	return self
end

function Library:construct(options)
	options = Table.PreserveMerge({}, options)
	constructLayer(self.blueprint)
end

return Library
