local Button = {}

function Button.create(component)

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

return Button
