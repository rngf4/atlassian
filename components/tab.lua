local Tab = {}

print(getfenv())

function Tab.create(component)

	local options = component.options
	component.parent.tabCounter = component.parent.tabCounter + 1
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

return Tab
