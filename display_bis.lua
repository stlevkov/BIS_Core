-- /dump GetInventoryItemLink("player", 1) (ingame to find the item ID)
-- /console scriptErrors 1 (to see lua errors) (ingame)

-- Function to process the class specialization based on talent points
function processClassSpecialization()
    local numTabs = GetNumTalentTabs();
    local talents = { 0, 0, 0 }

    for t = 1, numTabs do
        local numTalents = GetNumTalents(t);
        local calculateTalents = 0
        for i = 1, numTalents do
            nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i);
            calculateTalents = calculateTalents + currRank
        end
        talents[t] = calculateTalents
    end
    return talents
end

-- Function to determine the specialization based on talents and class
local function getClassRole()
    local englishClass = select(2, UnitClass("player"))
    local classRole = processClassSpecialization()
    
    if englishClass == "PALADIN" then
        if classRole[3] > classRole[1] and classRole[3] > classRole[2] then
            return "Retribution"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Protection"
        else
            return "Holy"
        end
    elseif englishClass == "WARRIOR" then
        if classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Fury"
        elseif classRole[3] > classRole[1] and classRole[3] > classRole[2] then
            return "Protection"
        else
            return "Arms"
        end
    elseif englishClass == "SHAMAN" then
        if classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Enhancement"
        elseif classRole[3] > classRole[1] and classRole[3] > classRole[2] then
            return "Restoration"
        else
            return "Elemental"
        end
    else
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Spec1"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Spec2"
        else
            return "Spec3"
        end
    end
end

-- Function to load the appropriate BIS list based on class and spec
local function LoadBISListForSpec(specName)
    local englishClass = select(2, UnitClass("player"))
    local specBIS = nil

    -- Load the appropriate BIS list based on class
    if englishClass == "PALADIN" then
        specBIS = require("paladin") -- Load the Paladin BIS list file
    elseif englishClass == "SHAMAN" then
        specBIS = BIS_LIST_SHAMAN
    elseif englishClass == "WARRIOR" then
        specBIS = require("warrior") -- Load the Warrior BIS list file
    -- Add other classes here (e.g., "MAGE", "DRUID", etc.)
    else
        return {BIS = {}, PreBIS = {}}
    end
    
    if specBIS then
        -- Get BIS and Pre-BIS for the current spec
        local classSpecBIS = specBIS[specName] or {BIS = {}, PreBIS = {}}  -- Default to empty if spec not found
        return classSpecBIS
    end
    
    return {BIS = {}, PreBIS = {}} -- Default empty lists if BIS list not found
end

-- Create the overlay text function
local function CreateOverlay(parent, text)
    local overlay = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    overlay:SetText(text)
    overlay:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)

    -- Add shadow effect
    overlay:SetShadowOffset(-1, 1) -- Offset for the shadow (x, y)
    overlay:SetShadowColor(0, 0, 0, 1) -- Black shadow with full opacity
    overlay:Hide()

    return overlay
end

-- Function to update the overlay for each slot
local function UpdateSlotOverlay(slot, bisOverlay)
    local itemLink = GetInventoryItemLink("player", slot)

    if itemLink then
        local itemId = tonumber(itemLink:match("item:(%d+):"))

        local englishClass = select(2, UnitClass("player"))

        -- Get the player's current specialization based on talents
        local specName = getClassRole()

        -- Load BIS and Pre-BIS lists for the current spec
        local BIS_LIST = LoadBISListForSpec(specName).BIS
        local PRE_BIS_LIST = LoadBISListForSpec(specName).PreBIS

        if BIS_LIST[itemId] then
            bisOverlay:SetText("BIS")
            bisOverlay:Show()
        elseif PRE_BIS_LIST[itemId] then
            bisOverlay:SetText("pre")
            bisOverlay:Show()
        else
            bisOverlay:Hide()
        end
    else
        bisOverlay:Hide()
    end
end

-- Initialize BIS overlays for all slots
local function InitializeBISOverlays()

    for _, slotName in pairs({
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot",
        "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot",
        "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
        "Trinket0Slot", "Trinket1Slot", "MainHandSlot",
        "SecondaryHandSlot", "RangedSlot"
    }) do
        local slotFrame = _G["Character" .. slotName]
        if slotFrame then
            local bisOverlay = CreateOverlay(slotFrame, "BIS")
            slotFrame:HookScript("OnShow", function()
                UpdateSlotOverlay(GetInventorySlotInfo(slotName), bisOverlay)
            end)
        end
    end

    local function UpdateAllSlots()
        for _, slotName in pairs({
            "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot",
            "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot",
            "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
            "Trinket0Slot", "Trinket1Slot", "MainHandSlot",
            "SecondaryHandSlot", "RangedSlot"
        }) do
            local slotFrame = _G["Character" .. slotName]
            local bisOverlay = slotFrame and slotFrame:GetFontString()
            if bisOverlay then
                UpdateSlotOverlay(GetInventorySlotInfo(slotName), bisOverlay)
            end
        end
    end

    CharacterFrame:HookScript("OnShow", UpdateAllSlots)
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    f:SetScript("OnEvent", UpdateAllSlots)
end

InitializeBISOverlays()
