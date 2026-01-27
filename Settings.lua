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
    
    -- Font Size Slider
    local fontSizeSlider = CreateFrame("Slider", "CleanKeysFontSizeSlider", panel, "OptionsSliderTemplate")
    fontSizeSlider:SetPoint("TOPLEFT", fontSizeLabel, "BOTTOMLEFT", 0, -10)
    fontSizeSlider:SetWidth(200)
    fontSizeSlider:SetMinMaxValues(6, 24)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)
    fontSizeSlider:SetValue(CleanKeysActionBarDB.fontSize)
    fontSizeSlider.Low:SetText("6")
    fontSizeSlider.High:SetText("24")
    fontSizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        CleanKeysActionBarDB.fontSize = value
        fontSizeValue:SetText(value)
        addon:UpdateAllActionButtons()
    end)
    
    -- Preview section
    local previewLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    previewLabel:SetPoint("TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -30)
    previewLabel:SetText("Preview:")
    
    local previewText = panel:CreateFontString(nil, "ARTWORK")
    previewText:SetPoint("LEFT", previewLabel, "RIGHT", 10, 0)
    previewText:SetFont(addon.HOTKEY_FONT, CleanKeysActionBarDB.fontSize, addon.HOTKEY_FONT_FLAGS)
    previewText:SetText("CM4  SA5  SF9  CX")
    
    -- Update preview when slider changes
    fontSizeSlider:HookScript("OnValueChanged", function(self, value)
        previewText:SetFont(addon.HOTKEY_FONT, math.floor(value + 0.5), addon.HOTKEY_FONT_FLAGS)
    end)
    
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
        fontSizeSlider:SetValue(CleanKeysActionBarDB.fontSize)
        fontSizeValue:SetText(CleanKeysActionBarDB.fontSize)
        previewText:SetFont(addon.HOTKEY_FONT, CleanKeysActionBarDB.fontSize, addon.HOTKEY_FONT_FLAGS)
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
