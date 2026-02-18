-- Clean Keys ActionBar - Settings Panel
-- Handles the addon settings UI in Options > AddOns

local addonName, addon = ...

-- Settings panel storage
local settingsPanel = nil
local settingsCategoryID = nil

-- Create Settings Panel (Modern API for Dragonflight+)
local function CreateSettingsPanel()
    -- Create main panel frame
    local panel = CreateFrame("Frame", "CleanKeysActionBarSettingsPanel", UIParent)
    panel.name = addonName
    
    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Clean Keys ActionBar")
    
    -- Description
    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText("Makes keybind text on action bars cleaner and more readable.")
    
    -- Enable Checkbox
    local enableCheck = CreateFrame("CheckButton", "CleanKeysEnableCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    enableCheck.Text:SetText("Enable Clean Keys")
    enableCheck:SetChecked(CleanKeysActionBarDB.enabled)
    enableCheck:SetScript("OnClick", function(self)
        CleanKeysActionBarDB.enabled = self:GetChecked()
        addon:UpdateAllActionButtons()
    end)
    
    -- Note about disabling
    local enableNote = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    enableNote:SetPoint("LEFT", enableCheck.Text, "RIGHT", 8, 0)
    enableNote:SetText("|cFFFFFF00(Reload required when disabling)|r")
    
    -- Font Size Label
    local fontSizeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontSizeLabel:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -20)
    fontSizeLabel:SetText("Font Size:")
    
    -- Font Size Value Label
    local fontSizeValue = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fontSizeValue:SetPoint("LEFT", fontSizeLabel, "RIGHT", 8, 0)
    fontSizeValue:SetText(CleanKeysActionBarDB.fontSize)
    
    -- Decrease button (-)
    local decreaseBtn = CreateFrame("Button", "CleanKeysFontDecrease", panel, "UIPanelButtonTemplate")
    decreaseBtn:SetPoint("TOPLEFT", fontSizeLabel, "BOTTOMLEFT", 0, -10)
    decreaseBtn:SetSize(32, 26)
    decreaseBtn:SetNormalFontObject("GameFontNormalLarge")
    decreaseBtn:SetText("-")
    decreaseBtn:SetScript("OnClick", function()
        local currentValue = CleanKeysActionBarDB.fontSize
        if currentValue > 6 then
            CleanKeysActionBarDB.fontSize = currentValue - 1
            fontSizeValue:SetText(CleanKeysActionBarDB.fontSize)
            addon:UpdateAllActionButtons()
        end
    end)
    
    -- Increase button (+)
    local increaseBtn = CreateFrame("Button", "CleanKeysFontIncrease", panel, "UIPanelButtonTemplate")
    increaseBtn:SetPoint("LEFT", decreaseBtn, "RIGHT", 5, 0)
    increaseBtn:SetSize(32, 26)
    increaseBtn:SetNormalFontObject("GameFontNormalLarge")
    increaseBtn:SetText("+")
    increaseBtn:SetScript("OnClick", function()
        local currentValue = CleanKeysActionBarDB.fontSize
        if currentValue < 24 then
            CleanKeysActionBarDB.fontSize = currentValue + 1
            fontSizeValue:SetText(CleanKeysActionBarDB.fontSize)
            addon:UpdateAllActionButtons()
        end
    end)
    
    -- Helper function to create offset controls
    local function CreateOffsetControls(parent, labelText, dbKeyX, dbKeyY, anchorFrame, anchorPoint)
        anchorPoint = anchorPoint or "BOTTOMLEFT"
        
        local container = CreateFrame("Frame", nil, parent)
        container:SetPoint("TOPLEFT", anchorFrame, anchorPoint, 0, -20)
        container:SetSize(400, 50)
        
        local label = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("TOPLEFT", 0, 0)
        label:SetText(labelText)
        
        -- X Offset
        local xLabel = container:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        xLabel:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -8)
        xLabel:SetText("X:")
        
        local xValue = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        xValue:SetPoint("LEFT", xLabel, "RIGHT", 5, 0)
        xValue:SetWidth(30)
        xValue:SetText(CleanKeysActionBarDB[dbKeyX] or 0)
        
        local xDecBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        xDecBtn:SetPoint("LEFT", xValue, "RIGHT", 10, 0)
        xDecBtn:SetSize(26, 22)
        xDecBtn:SetNormalFontObject("GameFontNormalLarge")
        xDecBtn:SetText("-")
        xDecBtn:SetScript("OnClick", function()
            CleanKeysActionBarDB[dbKeyX] = (CleanKeysActionBarDB[dbKeyX] or 0) - 1
            xValue:SetText(CleanKeysActionBarDB[dbKeyX])
            addon:UpdateAllActionButtons()
        end)
        
        local xIncBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        xIncBtn:SetPoint("LEFT", xDecBtn, "RIGHT", 3, 0)
        xIncBtn:SetSize(26, 22)
        xIncBtn:SetNormalFontObject("GameFontNormalLarge")
        xIncBtn:SetText("+")
        xIncBtn:SetScript("OnClick", function()
            CleanKeysActionBarDB[dbKeyX] = (CleanKeysActionBarDB[dbKeyX] or 0) + 1
            xValue:SetText(CleanKeysActionBarDB[dbKeyX])
            addon:UpdateAllActionButtons()
        end)
        
        -- Y Offset
        local yLabel = container:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        yLabel:SetPoint("LEFT", xIncBtn, "RIGHT", 20, 0)
        yLabel:SetText("Y:")
        
        local yValue = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        yValue:SetPoint("LEFT", yLabel, "RIGHT", 5, 0)
        yValue:SetWidth(30)
        yValue:SetText(CleanKeysActionBarDB[dbKeyY] or 0)
        
        local yDecBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        yDecBtn:SetPoint("LEFT", yValue, "RIGHT", 10, 0)
        yDecBtn:SetSize(26, 22)
        yDecBtn:SetNormalFontObject("GameFontNormalLarge")
        yDecBtn:SetText("-")
        yDecBtn:SetScript("OnClick", function()
            CleanKeysActionBarDB[dbKeyY] = (CleanKeysActionBarDB[dbKeyY] or 0) - 1
            yValue:SetText(CleanKeysActionBarDB[dbKeyY])
            addon:UpdateAllActionButtons()
        end)
        
        local yIncBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        yIncBtn:SetPoint("LEFT", yDecBtn, "RIGHT", 3, 0)
        yIncBtn:SetSize(26, 22)
        yIncBtn:SetNormalFontObject("GameFontNormalLarge")
        yIncBtn:SetText("+")
        yIncBtn:SetScript("OnClick", function()
            CleanKeysActionBarDB[dbKeyY] = (CleanKeysActionBarDB[dbKeyY] or 0) + 1
            yValue:SetText(CleanKeysActionBarDB[dbKeyY])
            addon:UpdateAllActionButtons()
        end)
        
        return container, xValue, yValue
    end
    
    -- Action Bar Hotkey Position
    local hotkeyPosContainer, hotkeyXValue, hotkeyYValue = CreateOffsetControls(
        panel, "Action Bar Hotkey Position:", "hotkeyOffsetX", "hotkeyOffsetY", increaseBtn
    )
    
    -- Extra Action Button Position
    local extraPosContainer, extraXValue, extraYValue = CreateOffsetControls(
        panel, "Extra Action Button Position:", "extraOffsetX", "extraOffsetY", hotkeyPosContainer
    )
    
    -- Extra Action Button info text
    local extraInfo = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    extraInfo:SetPoint("TOPLEFT", extraPosContainer, "BOTTOMLEFT", 0, -5)
    extraInfo:SetText("|cFF888888(Special ability button that appears during quests, dungeons, or boss fights)|r")
    
    -- Preview section
    local previewLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    previewLabel:SetPoint("TOPLEFT", extraInfo, "BOTTOMLEFT", 0, -20)
    previewLabel:SetText("Preview:")
    
    local previewText = panel:CreateFontString(nil, "ARTWORK")
    previewText:SetPoint("LEFT", previewLabel, "RIGHT", 10, 0)
    previewText:SetFont(addon.HOTKEY_FONT, CleanKeysActionBarDB.fontSize, addon.HOTKEY_FONT_FLAGS)
    previewText:SetText("CM4  SA5  SF9  CX")
    
    -- Key conversion examples
    local examplesLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    examplesLabel:SetPoint("TOPLEFT", previewLabel, "BOTTOMLEFT", 0, -30)
    examplesLabel:SetText("Key Conversions:")
    
    local examples = {
        "CTRL-BUTTON4 = CM4",
        "SHIFT-ALT-5 = SA5",
        "MOUSEWHEELUP = MWU",
        "NUMPAD1 = N1",
    }
    
    local lastLine = examplesLabel
    for _, example in ipairs(examples) do
        local line = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        line:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", lastLine == examplesLabel and 10 or 0, -4)
        line:SetText(example)
        lastLine = line
    end
    
    -- Refresh on show
    panel:SetScript("OnShow", function()
        enableCheck:SetChecked(CleanKeysActionBarDB.enabled)
        fontSizeValue:SetText(CleanKeysActionBarDB.fontSize)
        previewText:SetFont(addon.HOTKEY_FONT, CleanKeysActionBarDB.fontSize, addon.HOTKEY_FONT_FLAGS)
        hotkeyXValue:SetText(CleanKeysActionBarDB.hotkeyOffsetX)
        hotkeyYValue:SetText(CleanKeysActionBarDB.hotkeyOffsetY)
        extraXValue:SetText(CleanKeysActionBarDB.extraOffsetX)
        extraYValue:SetText(CleanKeysActionBarDB.extraOffsetY)
    end)
    
    -- Register with Settings API
    local category, layout = Settings.RegisterCanvasLayoutCategory(panel, addonName)
    Settings.RegisterAddOnCategory(category)
    
    settingsPanel = panel
    settingsCategoryID = category:GetID()
    
    return panel
end

-- Initialize settings
function addon:InitSettings()
    CreateSettingsPanel()
    
    -- Slash command to open settings
    SLASH_CLEANKEYS1 = "/cleankeys"
    SLASH_CLEANKEYS2 = "/ck"
    
    SlashCmdList["CLEANKEYS"] = function(msg)
        if settingsCategoryID then
            Settings.OpenToCategory(settingsCategoryID)
        end
    end
end
