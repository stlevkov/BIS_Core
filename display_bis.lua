-- /dump GetInventoryItemLink("player", 1) (ingame to find the item ID)
-- /console scriptErrors 1 (to see lua errors) (ingame)

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
        local specName = GetClassRoleBisCore()

        -- Load BIS and Pre-BIS lists for the current spec
        local BIS_LIST = LoadBISListForSpecBisCore(specName).BIS
        local PRE_BIS_LIST = LoadBISListForSpecBisCore(specName).PreBIS

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
