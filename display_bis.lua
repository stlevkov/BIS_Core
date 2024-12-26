-- /dump GetInventoryItemLink("player", 1) (ingame to find the item ID)
-- /console scriptErrors 1 (to see lua errors) (ingame)

local englishClass = select(2, UnitClass("player"))

-- Function to process the class specialization based on talent points
local function processClassSpecialization()
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
    local classRole = processClassSpecialization()

    if englishClass == "ROGUE" then
        if classRole[3] > classRole[1] and classRole[3] > classRole[2] then
            return "Subtlety"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Assassination"
        else
            return "Combat"
        end
    elseif englishClass == "PALADIN" then
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
    elseif englishClass == "WARLOCK" then
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Affliction"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Demonology"
        else
            return "Destruction"
        end
    elseif englishClass == "HUNTER" then
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Beast Mastery"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Marksmanship"
        else
            return "Survival"
        end
    elseif englishClass == "DRUID" then
        if classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Feral"
        elseif classRole[3] > classRole[1] and classRole[3] > classRole[2] then
            return "Restoration"
        else
            return "Balance"
        end
    elseif englishClass == "PRIEST" then
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Shadow"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Holy"
        else
            return "Discipline"
        end
    elseif englishClass == "MAGE" then
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Arcane"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Fire"
        else
            return "Frost"
        end
    elseif englishClass == "BIS_LIST_DEATHKNIGHT" then
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Blood"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Frost"
        else
            return "Unholy"
        end
    else
        print("BIS will not work for this Class")
    end
end

-- Function to load the appropriate BIS list based on class and spec
local function LoadBISListForSpec(specName)

    local specBIS = _G["BIS_LIST_" .. englishClass]

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

        -- Get the player's current specialization based on talents
        local specName = getClassRole()

        -- Load BIS and Pre-BIS lists for the current spec
        local BIS_LIST = LoadBISListForSpec(specName).BIS
        local PRE_BIS_LIST = LoadBISListForSpec(specName).PreBIS

        local isBIS, isPreBIS = false, false
        -- Check if the current item is in the BIS list
        for _, item in ipairs(BIS_LIST) do
            if item.itemID == itemId then
                isBIS = true
                break
            end
        end

        -- Check if the current item is in the Pre-BIS list
        for _, item in ipairs(PRE_BIS_LIST) do
            if item.itemID == itemId then
                isPreBIS = true
                break
            end
        end

        if isBIS then
            bisOverlay:SetText("BIS")
            bisOverlay:Show()
        elseif isPreBIS then
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
