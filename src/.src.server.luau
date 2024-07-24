local PluginButton = plugin:CreateToolbar("Gradient Tools"):CreateButton(
    "CSS to UIGradient",
    "Convert CSS gradient to UIGradient",
    "rbxassetid://0" -- Replace with an appropriate icon asset ID
)

local function parseCSSGradient(cssGradient)
    -- この関数はCSSグラデーション文字列を解析します
    -- 例: "linear-gradient(to right, #ff0000 0%, #00ff00 50%, #0000ff 100%)"
    local colors = {}
    for color, position in cssGradient:gmatch("#(%x%x%x%x%x%x)%s*(%d*%.?%d*)%%") do
        local r, g, b = tonumber("0x"..color:sub(1,2))/255, tonumber("0x"..color:sub(3,4))/255, tonumber("0x"..color:sub(5,6))/255
        local pos = tonumber(position) / 100
        table.insert(colors, {Color3.new(r, g, b), pos})
    end
    return colors
end

local function applyGradientToUIGradient(uiGradient, parsedColors)
    local keypoints = {}
    for _, colorData in ipairs(parsedColors) do
        table.insert(keypoints, ColorSequenceKeypoint.new(colorData[2], colorData[1]))
    end
    uiGradient.Color = ColorSequence.new(keypoints)
end

local function onButtonClick()
    local selection = game:GetService("Selection"):Get()
    local uiGradient = selection[1]
    
    if uiGradient and uiGradient:IsA("UIGradient") then
        local cssGradient = plugin:PromptForString("Enter CSS Gradient", "e.g. linear-gradient(to right, #ff0000 0%, #00ff00 50%, #0000ff 100%)")
        
        if cssGradient then
            local parsedColors = parseCSSGradient(cssGradient)
            applyGradientToUIGradient(uiGradient, parsedColors)
        end
    else
        warn("Please select a UIGradient object")
    end
end

PluginButton.Click:Connect(onButtonClick)