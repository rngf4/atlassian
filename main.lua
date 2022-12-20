local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

Table = nil

local modules = {
	Table = "utilities/table"
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
	local objectType = Table.Pull(options, "type")
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
				TS:Create(instanceObject, value.TweenInfo or TweenInfo.new(0.25), {[property] = to}):Play()
			else
				instanceObject[property] = value
			end
		end,
		__call = function() return instanceObject end
	})
end

local function createLibrary(component)

	local options = component.options

	local gui = createPrimogenitor{
		type = "ScreenGui",
		Parent = (RS:IsStudio() and game.Players.LocalPlayer.PlayerGui) or game.CoreGui
	}

	local mainFrame = gui:object{
		type = "Frame",
		Size = UDim2.fromOffset(700, 450),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(34, 39, 43)
	}:round()


	local tabButtons = mainFrame:object{
		type = "Frame",
		Size = UDim2.new(0, 200, 1, 0),
		BackgroundTransparency = 1
	}
	
	tabButtons:object{
		type = "UIListLayout",
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	
	
	local title = tabButtons:object{
		type = "TextLabel",
		Size = UDim2.new(1, 0, 0, 39),
		Text = options.title:upper(),
		Font = Enum.Font.SourceSansBold,
		TextColor3 = Color3.fromRGB(159, 173, 188),
		BackgroundTransparency = 1,
		TextSize = 17
	}
	
	title:object{
		type = "UIPadding",
		PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 20),
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 6)
	}

	tabButtons:object{
		type = "UIPadding",
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6)
	}

	local tabButtonContainer = tabButtons:object{
		type = "Frame",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	}

	tabButtonContainer:object{
		type = "UIListLayout",
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}

	local tabContainer = mainFrame:object{
		type = "Frame",
		Size = UDim2.new(1, -200, 1, 0),
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1

	}

	local function changeTitle(toTitle)
		title.Text = toTitle:upper()
	end

	local function getTitle()
		return title.Text
	end

	local optionsHandlers = {
		title = {
			set = changeTitle,
			get = getTitle
		}
	}

	-- track options

	return {
		tracking = {
			get = function(_, option)
				option = option:lower()
				if Table.Has(optionsHandlers, option) and optionsHandlers[option].get then
					return optionsHandlers[option].get()
				end
			end,
			set = function(_, option, value)
				option = option:lower()
				if Table.Has(optionsHandlers, option) and optionsHandlers[option].set then
					optionsHandlers[option].set(value)
				end
			end,
		},
		tabButtonContainer = tabButtonContainer,
		tabContainer = tabContainer,
		tabCounter = 0
	}
end

local function createTab(component)

	local options = component.options
	component.parent.tabCounter += 1
	local tabButton = component.parent.tabButtonContainer:object{
		type = "TextButton",
		Text = "",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Color3.fromRGB(161, 189, 217),
		BackgroundTransparency = 1
	}
	
	local tab = component.parent.tabContainer:object{
		type = "ScrollingFrame",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(161, 189, 217),
		ScrollBarImageTransparency = 0.72,
		CanvasSize = UDim2.new(),
		Visible = (component.parent.tabCounter == 1 and true) or false
	}
	
	local function hideTab()
		tab.Visible = false
	end
	
	local function showTab()
		tab.Visible = true
	end
	
	tab:object{
		type = "UIPadding",
		PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 20),
		PaddingBottom = UDim.new(0, 20),
		PaddingTop = UDim.new(0, 20)
	}
	
	local tabLayout = tab:object{
		type = "UIListLayout",
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10)
	}
	
	local tabTitle = tab:object{
		type = "TextLabel",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 29),
		Text = options.name,
		TextColor3 = Color3.fromRGB(199, 209, 219),
		Font = Enum.Font.SourceSansBold,
		TextSize = 27
	}
	
	local tabDescription = tab:object{
		type = "TextLabel",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 17),
		TextSize = 19,
		Font = Enum.Font.SourceSansSemibold,
		TextColor3 = Color3.fromRGB(134, 150, 167),
		Text = options.description or ""
	}
	
	tabLayout():GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
		tab.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y)
	end)
	
	tabButton.MouseEnter:connect(function()
		tabButton.BackgroundTransparency = {isTween = true, value = 0.92}
	end)
	
	tabButton.MouseLeave:connect(function()
		tabButton.BackgroundTransparency = {isTween = true, value = 1}
	end)
	
	tabButton.MouseButton1Click:connect(function()
		for _, tab in next, component.parent.children do
			if tab ~= component then
				tab.hideTab()
			end
		end
		showTab()
	end)
	
	tabButton:object{
		type = "UIPadding",
		PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 20),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8)
	}

	local name = tabButton:object{
		type = "TextLabel",
		Text = options.name,
		TextColor3 = Color3.fromRGB(199, 209, 219),
		TextSize = 17,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 19),
		Font = Enum.Font.SourceSansSemibold
	}
	
	local description = tabButton:object{
		type = "TextLabel",
		TextColor3 = Color3.fromRGB(134, 150, 167),
		TextSize = 15,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 17),
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		Text = options.description or ""
	}
	
	if options.description == nil then
		name.Position = UDim2.fromScale(0, 0.5)
		name.AnchorPoint = Vector2.new(0, 0.5)
		description.TextTransparency = 1
		
		tabDescription.Size = UDim2.new(1, 0, 0, 0)
		tabDescription.TextTransparency = 1
	end
	
	local function changeDescription(toDescription)
		if toDescription == nil then
			name.Position = {isTween = true, value = UDim2.fromScale(0, 0.5)}
			name.AnchorPoint = {isTween = true, value = Vector2.new(0, 0.5)}
			description.TextTransparency = {isTween = true, value = 1}
			
			tabDescription.Size = {isTween = true, value = UDim2.new(1, 0, 0, 0)}
			tabDescription.TextTransparency = {isTween = true, value = 1}
		else
			description.Text = toDescription
			tabDescription.Text = toDescription
			
			description.TextTransparency = {isTween = true, value = 0}
			name.Position = {isTween = true, value = UDim2.fromScale(0, 0)}
			name.AnchorPoint = {isTween = true, value = Vector2.new(0, 0)}
			
			tabDescription.Size = {isTween = true, value = UDim2.new(1, 0, 0, 17)}
			tabDescription.TextTransparency = {isTween = true, value = 0}
		end
	end
	
	local function changeName(toName)
		name.Text = toName
	end
	
	local optionsHandlers = {
		name = {
			set = changeName,
		},
		description = {
			set = changeDescription
		}
	}
	
	return {
		tracking = {
			get = function(_, option)
				option = option:lower()
				if Table.Has(optionsHandlers, option) and optionsHandlers[option].get then
					return optionsHandlers[option].get()
				end
			end,
			set = function(_, option, value)
				option = option:lower()
				if Table.Has(optionsHandlers, option) and optionsHandlers[option].set then
					optionsHandlers[option].set(value)
				end
			end,
		},
		tab = tab,
		hideTab = hideTab
	}
end

local function createButton(component)
	
	local options = component.options
	
	local buttonContainer = component.parent.tab:object{
		type = "Frame",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1
	}
	
	buttonContainer:object{
		type = "UIListLayout",
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	}
	
	local buttonName = buttonContainer:object{
		type = "TextLabel",
		Text = options.name,
		TextColor3 = Color3.fromRGB(134, 150, 167),
		TextSize = 16,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.SourceSansSemibold
	}
	
	local button = buttonContainer:object{
		type = "TextButton",
		Text = "",
		BackgroundColor3 = Color3.fromRGB(87, 157, 255),
		Size = UDim2.new(0, 84, 0, 32),
	}:round(3)
	
	button.MouseEnter:connect(function()
		button.BackgroundColor3 = {isTween = true, value = Color3.fromRGB(133, 184, 255)}
	end)
	
	button.MouseLeave:connect(function()
		button.BackgroundColor3 = {isTween = true, value = Color3.fromRGB(87, 157, 255)}
	end)
	
	button:object{
		type = "UIPadding",
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10)
	}
	
	local buttonText = button:object{
		type = "TextLabel",
		BackgroundTransparency = 1,
		Text = options.text,
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(22, 26, 29),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5)
	}
	
	
	
	return {}
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
		constructor = createLibrary,
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
		constructor = createTab,
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
		constructor = createButton,
		options = options,
		parent = self,
		terminate = true
	}
	table.insert(self.children, object)
	self.__index = self

	return setmetatable(object, self)
end

local function constructLayer(layer)
	for index, component in next, layer do
		if not (index == "__index" or index == "children" or index == "parent") then
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
		end
	end
end

function Library:init(options)
	
	if not RS:IsStudio() then
		print(modules) -- add onto getfenv
	end
	
	options = Table.PreserveMerge({}, options)
	constructLayer(self.blueprint)
end

return Library
