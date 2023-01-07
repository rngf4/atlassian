local UI = {}

function UI.create(component)

	local options = component.options

	component.mainFrame.Size = { isTween = true, value = UDim2.fromOffset(700, 450)}

	local tabButtons = component.mainFrame:object{
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

	local tabContainer = component.mainFrame:object{
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

return UI
