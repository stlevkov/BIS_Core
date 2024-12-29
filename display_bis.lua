
-- Function to create a shiny border around a frame
local function createBorder(frame)
    -- Ensure the frame is valid
    if not frame then return end

    -- Create a texture for the border
    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border") -- Shiny texture
    border:SetBlendMode("ADD") -- Makes it look shiny
    border:SetSize(70, 70) -- frame size
    border:SetPoint("CENTER", frame, "CENTER", 0, 0)

    -- Apply a golden color (R, G, B, Alpha)
    border:SetVertexColor(1, 0.84, 0, 0.6) -- Gold with reduced visibility (0.6 alpha)

    border:Hide() -- Hide by default; show only for BIS items

    return border
end


-- Function to create overlay text
local function createOverlay(parent, text)
    local overlay = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    overlay:SetText(text)
    overlay:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)

    -- Add shadow effect
    overlay:SetShadowOffset(-1, 1) -- Offset for the shadow (x, y)
    overlay:SetShadowColor(0, 0, 0, 1) -- Black shadow with full opacity
    overlay:Hide()

    -- Add a border
    local border = createBorder(parent)
    parent.border = border -- Attach the border to the frame for reference

    return overlay
end

-- Function to update the overlay and border for each slot
local function UpdateSlotOverlay(slot, bisOverlay, border)
    local itemLink = GetInventoryItemLink("player", slot)

    if itemLink and BIS_Core_Settings.active then
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
            if border then border:Show() end
        elseif isPreBIS then
            bisOverlay:SetText("pre")
            bisOverlay:Show()
            if border then border:Hide() end
        else
            bisOverlay:Hide()
            if border then border:Hide() end
        end
    else
        bisOverlay:Hide()
        if border then border:Hide() end
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
            local bisOverlay = createOverlay(slotFrame, "BIS")
            slotFrame:HookScript("OnShow", function()
                UpdateSlotOverlay(GetInventorySlotInfo(slotName), bisOverlay, slotFrame.border)
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
                UpdateSlotOverlay(GetInventorySlotInfo(slotName), bisOverlay, slotFrame.border)
            end
        end
    end

    CharacterFrame:HookScript("OnShow", UpdateAllSlots)
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    f:SetScript("OnEvent", UpdateAllSlots)
end

function BISCoreOverlaysInitialize()
    InitializeBISOverlays()
end
