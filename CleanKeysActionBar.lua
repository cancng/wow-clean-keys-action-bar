-- Clean Keys ActionBar
-- Makes keybind text on action bars cleaner and more readable

local addonName, addon = ...

-- Export addon table for other files
addon.name = addonName

-- Font settings
addon.HOTKEY_FONT = "Fonts\\FRIZQT__.TTF"
addon.HOTKEY_FONT_FLAGS = "OUTLINE"

-- Default settings
addon.defaults = {
    enabled = true,
    fontSize = 12,
    fontBold = false,
    hotkeyOffsetX = 0,
    hotkeyOffsetY = 0,
    extraOffsetX = 0,
    extraOffsetY = 0,
}

-- Key replacements table
local keyReplacements = {
    -- Mouse buttons
    ["MOUSEWHEELUP"] = "MWU",
    ["MOUSEWHEELDOWN"] = "MWD",
    ["BUTTON1"] = "M1",
    ["BUTTON2"] = "M2",
    ["BUTTON3"] = "M3",
    ["BUTTON4"] = "M4",
    ["BUTTON5"] = "M5",
    ["BUTTON6"] = "M6",
    ["BUTTON7"] = "M7",
    ["BUTTON8"] = "M8",
    ["BUTTON9"] = "M9",
    ["BUTTON10"] = "M10",
    ["BUTTON11"] = "M11",
    ["BUTTON12"] = "M12",
    
    -- Numpad
    ["NUMPAD0"] = "N0",
    ["NUMPAD1"] = "N1",
    ["NUMPAD2"] = "N2",
    ["NUMPAD3"] = "N3",
    ["NUMPAD4"] = "N4",
    ["NUMPAD5"] = "N5",
    ["NUMPAD6"] = "N6",
    ["NUMPAD7"] = "N7",
    ["NUMPAD8"] = "N8",
    ["NUMPAD9"] = "N9",
    ["NUMPADPLUS"] = "N+",
    ["NUMPADMINUS"] = "N-",
    ["NUMPADMULTIPLY"] = "N*",
    ["NUMPADDIVIDE"] = "N/",
    ["NUMPADDECIMAL"] = "N.",
    
    -- Special keys
    ["CAPSLOCK"] = "CL",
    ["SPACEBAR"] = "SP",
    ["SPACE"] = "SP",
    ["BACKSPACE"] = "BS",
    ["DELETE"] = "DL",
    ["INSERT"] = "IN",
    ["HOME"] = "HM",
    ["END"] = "EN",
    ["PAGEUP"] = "PU",
    ["PAGEDOWN"] = "PD",
    ["ESCAPE"] = "ES",
    ["TAB"] = "TB",
    ["PRINTSCREEN"] = "PS",
    ["SCROLLLOCK"] = "SL",
    ["PAUSE"] = "PA",
    
    -- Arrow keys
    ["UP"] = "UP",
    ["DOWN"] = "DN",
    ["LEFT"] = "LT",
    ["RIGHT"] = "RT",
}

-- Convert a raw keybind to clean text
local function CleanKey(key)
    if not key or key == "" then
        return ""
    end
    
    local result = key:upper()
    local modifiers = ""
    
    -- Extract modifiers in order (Ctrl, Shift, Alt)
    if result:find("CTRL%-") then
        result = result:gsub("CTRL%-", "")
        modifiers = modifiers .. "C"
    end
    if result:find("SHIFT%-") then
        result = result:gsub("SHIFT%-", "")
        modifiers = modifiers .. "S"
    end
    if result:find("ALT%-") then
        result = result:gsub("ALT%-", "")
        modifiers = modifiers .. "A"
    end
    
    -- Clean up any remaining dashes at the start
    result = result:gsub("^%-+", "")
    
    -- Apply key replacements
    if keyReplacements[result] then
        result = keyReplacements[result]
    end
    
    -- Combine modifiers and key
    if modifiers ~= "" then
        return modifiers .. result
    end
    
    return result
end

-- Binding name patterns for different button types
local bindingPatterns = {
    ["ActionButton"] = "ACTIONBUTTON",
    ["MultiBarBottomLeftButton"] = "MULTIACTIONBAR1BUTTON",
    ["MultiBarBottomRightButton"] = "MULTIACTIONBAR2BUTTON",
    ["MultiBarRightButton"] = "MULTIACTIONBAR3BUTTON",
    ["MultiBarLeftButton"] = "MULTIACTIONBAR4BUTTON",
    ["PetActionButton"] = "BONUSACTIONBUTTON",
    ["StanceButton"] = "SHAPESHIFTBUTTON",
    ["ExtraActionButton"] = "EXTRAACTIONBUTTON",
    ["ZoneAbilityFrame"] = "EXTRAACTIONBUTTON",
}

-- Get binding key for a button
local function GetButtonBinding(button)
    local buttonName = button:GetName()
    if not buttonName then return nil end
    
    for pattern, bindingPrefix in pairs(bindingPatterns) do
        if buttonName:find("^" .. pattern) then
            local id = buttonName:match("(%d+)$")
            if id then
                return GetBindingKey(bindingPrefix .. id)
            end
        end
    end
    
    return nil
end

-- Check if button is extra action button
local function IsExtraActionButton(button)
    local name = button:GetName()
    if not name then return false end
    return name:find("ExtraActionButton") or (button:GetParent() and button:GetParent():GetName() == "ZoneAbilityFrame")
end

-- Update hotkey text on a button
local function UpdateButtonHotkey(button)
    if not CleanKeysActionBarDB or not CleanKeysActionBarDB.enabled then
        return
    end
    
    local hotkey = button.HotKey
    if not hotkey and button.GetName then
        hotkey = _G[button:GetName() .. "HotKey"]
    end
    
    if not hotkey then return end
    
    local key = GetButtonBinding(button)
    if key then
        hotkey:SetText(CleanKey(key))
        
        -- Build font flags
        local fontFlags = "OUTLINE"
        if CleanKeysActionBarDB.fontBold then
            fontFlags = "OUTLINE, THICKOUTLINE"
        end
        hotkey:SetFont(addon.HOTKEY_FONT, CleanKeysActionBarDB.fontSize, fontFlags)
        
        -- Allow text to overflow outside button bounds
        hotkey:SetWidth(0)
        hotkey:SetWordWrap(false)
        hotkey:SetNonSpaceWrap(false)
        
        -- Apply position offset
        local isExtra = IsExtraActionButton(button)
        local offsetX = isExtra and CleanKeysActionBarDB.extraOffsetX or CleanKeysActionBarDB.hotkeyOffsetX
        local offsetY = isExtra and CleanKeysActionBarDB.extraOffsetY or CleanKeysActionBarDB.hotkeyOffsetY
        
        hotkey:ClearAllPoints()
        hotkey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2 + offsetX, -2 + offsetY)
    end
end

-- Hook into the action button hotkey update
local function SetupHooks()
    -- For modern WoW (Dragonflight+), hook the mixin method
    if ActionButtonMixin and ActionButtonMixin.UpdateHotkeys then
        hooksecurefunc(ActionButtonMixin, "UpdateHotkeys", function(self)
            UpdateButtonHotkey(self)
        end)
    end
    
    -- For older API / Classic
    if ActionButton_UpdateHotkeys then
        hooksecurefunc("ActionButton_UpdateHotkeys", function(self)
            UpdateButtonHotkey(self)
        end)
    end
    
    -- Pet action bar
    if PetActionButton_SetHotkeys then
        hooksecurefunc("PetActionButton_SetHotkeys", function(self)
            UpdateButtonHotkey(self)
        end)
    end
    
    -- Stance/Shapeshift bar
    if StanceButton_UpdateHotkeys then
        hooksecurefunc("StanceButton_UpdateHotkeys", function(self)
            UpdateButtonHotkey(self)
        end)
    end
    
    -- LibActionButton support (Bartender, ElvUI, etc.)
    if LibStub then
        local LAB = LibStub("LibActionButton-1.0", true)
        if LAB then
            hooksecurefunc(LAB:GetAllButtons()[1] or {}, "UpdateHotkeys", function(self)
                UpdateButtonHotkey(self)
            end)
        end
    end
    
end

-- Update all visible action buttons
function addon:UpdateAllActionButtons()
    -- Main action bar
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button then
            UpdateButtonHotkey(button)
        end
    end
    
    -- Multi bars
    local multiBarNames = {
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
    }
    
    for _, barName in ipairs(multiBarNames) do
        for i = 1, 12 do
            local button = _G[barName .. i]
            if button then
                UpdateButtonHotkey(button)
            end
        end
    end
    
    -- Pet action bar
    for i = 1, 10 do
        local button = _G["PetActionButton" .. i]
        if button then
            UpdateButtonHotkey(button)
        end
    end
    
    -- Stance bar
    for i = 1, 10 do
        local button = _G["StanceButton" .. i]
        if button then
            UpdateButtonHotkey(button)
        end
    end
    
    -- Extra Action Button (quest/boss mechanics)
    local extraButton = _G["ExtraActionButton1"]
    if extraButton then
        UpdateButtonHotkey(extraButton)
    end
    
    -- Zone Ability Button
    if ZoneAbilityFrame and ZoneAbilityFrame.SpellButton then
        UpdateButtonHotkey(ZoneAbilityFrame.SpellButton)
    end
end

-- Event frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_BINDINGS")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
frame:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
frame:RegisterEvent("SPELLS_CHANGED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize saved variables
        if not CleanKeysActionBarDB then
            CleanKeysActionBarDB = CopyTable(addon.defaults)
        end
        
        for k, v in pairs(addon.defaults) do
            if CleanKeysActionBarDB[k] == nil then
                CleanKeysActionBarDB[k] = v
            end
        end
        
        SetupHooks()
        
        -- Initialize settings panel (from Settings.lua)
        if addon.InitSettings then
            addon:InitSettings()
        end
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(0.5, function() addon:UpdateAllActionButtons() end)
        C_Timer.After(2, function() addon:UpdateAllActionButtons() end)
        
    elseif event == "UPDATE_BINDINGS" or event == "ACTIONBAR_SLOT_CHANGED" or event == "ACTIONBAR_PAGE_CHANGED" 
           or event == "UPDATE_EXTRA_ACTIONBAR" or event == "SPELLS_CHANGED" then
        C_Timer.After(0.1, function() addon:UpdateAllActionButtons() end)
    end
end)
