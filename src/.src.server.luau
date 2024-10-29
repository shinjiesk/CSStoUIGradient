
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
frame.BackgroundColor3 = Color3.fromRGB(240, 240, 240) -- 薄いグレー
frame.Parent = widget

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 100)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.MultiLine = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.TextWrapped = true
textBox.Text = ""
textBox.PlaceholderText = "ここにCSSグラデーションのコードを貼り付ける"
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- 白
textBox.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 30)
button.Position = UDim2.new(0.5, -50, 1, -40)
button.Text = "グラデーションを適用"
button.BackgroundColor3 = Color3.fromRGB(220, 220, 220) -- 明るいグレー
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
    -- 角度とカラーストップを分離
    local angle = 0 -- デフォルト角度（下から上）
    local colorPart = cssGradient
    
    -- 角度の解析
    local angleMatch = cssGradient:match("linear%-gradient%((%-?%d+)deg")
    if angleMatch then
        angle = tonumber(angleMatch)
        angle = (270 + angle) % 360
        -- カラー部分の抽出
        colorPart = cssGradient:match("linear%-gradient%b()"):match("deg,(.+)%)")
        if not colorPart then
            colorPart = cssGradient:match("linear%-gradient%b()"):match("deg(.+)%)")
        end
    end
    
    local colorEntries = {}
    
    -- 色とパーセンテージの組み合わせを抽出
    for color, position in colorPart:gmatch("(#%x+)%s*(%d*%.?%d*)%%?") do
        table.insert(colorEntries, {
            color = hexToRGB(color),
            position = position ~= "" and tonumber(position) / 100 or nil
        })
    end
    
    -- 位置が省略された場合の処理
    local numColors = #colorEntries
    if numColors > 0 then
        -- 最初の色に位置が指定されていない場合は0%とする
        if not colorEntries[1].position then
            colorEntries[1].position = 0
        end
        
        -- 最後の色に位置が指定されていない場合は100%とする
        if not colorEntries[numColors].position then
            colorEntries[numColors].position = 1
        end
        
        -- 中間の色に位置が指定されていない場合は等間隔で配置
        local lastSpecifiedIndex = 1
        for i = 2, numColors - 1 do
            if not colorEntries[i].position then
                -- 次の指定された位置を探す
                local nextSpecifiedIndex = i
                for j = i + 1, numColors do
                    if colorEntries[j].position then
                        nextSpecifiedIndex = j
                        break
                    end
                end
                
                -- この区間の未指定の色を等間隔に配置
                local startPos = colorEntries[lastSpecifiedIndex].position
                local endPos = colorEntries[nextSpecifiedIndex].position
                local count = nextSpecifiedIndex - lastSpecifiedIndex + 1
                local step = (endPos - startPos) / (count - 1)
                
                for j = lastSpecifiedIndex + 1, nextSpecifiedIndex - 1 do
                    colorEntries[j].position = startPos + step * (j - lastSpecifiedIndex)
                end
                
                lastSpecifiedIndex = nextSpecifiedIndex
            else
                lastSpecifiedIndex = i
            end
        end
    end
    
    -- ColorSequenceKeypointの配列に変換
    local keypoints = {}
    for _, entry in ipairs(colorEntries) do
        table.insert(keypoints, ColorSequenceKeypoint.new(entry.position, entry.color))
    end
    
    return keypoints, angle
end

local function applyGradient()
    local selection = game:GetService("Selection"):Get()
    if #selection == 0 then
        warn("No object selected")
        return
    end
    
    local selectedObject = selection[1]
    local uiGradient
    
    -- 選択されたオブジェクトがUIGradientの場合はそれを使用
    if selectedObject:IsA("UIGradient") then
        uiGradient = selectedObject
    else
        -- UIGradientが子に存在するか確認し、なければ新規作成
        uiGradient = selectedObject:FindFirstChildOfClass("UIGradient")
        if not uiGradient then
            uiGradient = Instance.new("UIGradient")
            uiGradient.Parent = selectedObject
        end
    end
    
    local cssGradient = textBox.Text
    local keypoints, angle = parseCSSGradient(cssGradient)
    
    if #keypoints > 0 then
        local newGradient = ColorSequence.new(keypoints)
        uiGradient.Color = newGradient
        uiGradient.Rotation = angle
        print("CSS Gradient applied successfully!")
    else
        warn("Failed to parse CSS gradient")
    end
end

button.MouseButton1Click:Connect(applyGradient)
PluginButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)





