local PluginButton = plugin:CreateToolbar("Gradient Tools"):CreateButton(
    "CSS to UIGradient",
    "Convert CSS gradient to UIGradient",
    "rbxassetid://0" -- Replace with an appropriate icon asset ID
)

local widget = plugin:CreateDockWidgetPluginGui(
    "CSSGradientConverter",
    DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 300, 150, 300, 150)
)
widget.Title = "CSS Gradient Converter"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1
frame.Parent = widget

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 100)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.MultiLine = true
textBox.PlaceholderText = "Paste CSS gradient here..."
textBox.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 30)
button.Position = UDim2.new(0.5, -50, 1, -40)
button.Text = "Apply Gradient"
button.Parent = frame

local function hexToRGB(hex)
    hex = hex:gsub("#","")
    return Color3.fromRGB(
        tonumber("0x"..hex:sub(1,2)),
        tonumber("0x"..hex:sub(3,4)),
        tonumber("0x"..hex:sub(5,6))
    )
end

local function parseCSSGradient(cssGradient)
    local colors = {}
    for color, position in cssGradient:gmatch("(#%x+)%s*(%d*%.?%d*)%%") do
        local rgb = hexToRGB(color)
        local pos = tonumber(position) / 100
        table.insert(colors, ColorSequenceKeypoint.new(pos, rgb))
    end
    return colors
end

local function applyGradient()
    local selection = game:GetService("Selection"):Get()
    local uiGradient = selection[1]
    
    if uiGradient and uiGradient:IsA("UIGradient") then
        local cssGradient = textBox.Text
        local keypoints = parseCSSGradient(cssGradient)
        
        if #keypoints > 0 then
            local newGradient = ColorSequence.new(keypoints)
            uiGradient.Color = newGradient
            print("CSS Gradient applied successfully!")
        else
            warn("Failed to parse CSS gradient")
        end
    else
        warn("Please select a UIGradient object")
    end
end

button.MouseButton1Click:Connect(applyGradient)
PluginButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)