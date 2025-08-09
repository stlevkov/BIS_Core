-- /console scriptErrors 1 (to see lua errors) (ingame)

-- Global variable for storing chat message state
local chatObj = { chatMsgFired = false, currentItem = nil }

-- Function to add static text with BIS and Pre-BIS item links to the tooltip for the HeadSlot item
local function AddStaticTextToTooltip(tooltip)

    if BIS_Core_Settings.active == false then return end

    -- Get the item link from the tooltip
    local _, itemLink = tooltip:GetItem()
    if not itemLink then
        print("No item link found")
        return
    end

    -- Mapping of slot names to slot IDs
    local slotNames = {
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot",
        "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot",
        "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
        "Trinket0Slot", "Trinket1Slot", "MainHandSlot",
        "SecondaryHandSlot", "RangedSlot"
    }

    -- Determine the slot by comparing item links
    local itemSlot
    for _, slotName in ipairs(slotNames) do
        local slotID = GetInventorySlotInfo(slotName)
        local slotItemLink = GetInventoryItemLink("player", slotID)
        if slotItemLink == itemLink then
            itemSlot = slotName
            break
        end
    end

    if not itemSlot then
        return
    end

    -- Determine the class and specialization
    local specName = GetClassRoleBisCore()

    -- Load BIS and Pre-BIS lists for the current spec
    local BIS_LIST = LoadBISListForSpecBisCore(specName).BIS
    local PRE_BIS_LIST = LoadBISListForSpecBisCore(specName).PreBIS

    -- Ensure BIS and Pre-BIS lists are available
    if not BIS_LIST or not PRE_BIS_LIST then
        tooltip:AddLine("|cff00ff00BIS and Pre-BIS data not available|r", 1, 1, 1)
        return
    end

    -- Get the BIS and Pre-BIS items for the detected slot
    local bisItemID, bisSource
    local preBisItems = {} -- Collect all pre-bis items for this slot
    
    for _, item in ipairs(BIS_LIST) do
        if item.slot == itemSlot then
            bisItemID = item.itemID
            bisSource = item.source
            break
        end
    end

    -- Collect all Pre-BIS items for this slot
    for _, item in ipairs(PRE_BIS_LIST) do
        if item.slot == itemSlot then
            table.insert(preBisItems, {itemID = item.itemID, source = item.source})
        end
    end

    -- Add BIS item to the tooltip
    if bisItemID then
        local bisItemLink = select(2, GetItemInfo(bisItemID))
        tooltip:AddLine("|cff00ff00BIS:|r " .. (bisItemLink or "Item not found"), 1, 1, 1)
    else
        tooltip:AddLine("|cff00ff00BIS:|r Item not found", 1, 1, 1)
    end

    -- Add Pre-BIS items to the tooltip
    if #preBisItems > 0 then
        local preBisText = ""
        for i, preBisItem in ipairs(preBisItems) do
            local preBisItemLink = select(2, GetItemInfo(preBisItem.itemID))
            if i == 1 then
                preBisText = (preBisItemLink or "Item not found")
            else
                preBisText = preBisText .. " or " .. (preBisItemLink or "Item not found")
            end
        end
        tooltip:AddLine("|cff00ff00Pre-BIS:|r " .. preBisText, 1, 1, 1)
    else
        tooltip:AddLine("|cff00ff00Pre-BIS:|r Item not found", 1, 1, 1)
    end

    -- Print clickable BIS and Pre-BIS items in chat, one per line
    if not chatObj.chatMsgFired or chatObj.currentItem ~= itemLink then

        if BIS_Core_Settings.chat == false then return end

        -- Get BIS and Pre-BIS item links
        local bisItemLink = bisItemID and select(2, GetItemInfo(bisItemID)) or nil

        -- Print BIS item with itemSlot and source
        if bisItemID then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BIS " .. itemSlot .. ":|r " .. (bisItemLink or "Item not found. Please update your addon files") .. " |cff00ff00Source:|r " .. (bisSource or "Unknown"))
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BIS " .. itemSlot .. ":|r Item not declared in the files")
        end

        -- Print Pre-BIS items with itemSlot and source
        if #preBisItems > 0 then
            for i, preBisItem in ipairs(preBisItems) do
                local preBisItemLink = select(2, GetItemInfo(preBisItem.itemID))
                local label = (i == 1) and "Pre-BIS " or "Pre-BIS Alt "
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. label .. itemSlot .. ":|r " .. (preBisItemLink or "Item not found. Please update your addon files") .. " |cff00ff00Source:|r " .. (preBisItem.source or "Unknown"))
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Pre-BIS " .. itemSlot .. ":|r Item not declared in the files")
        end

        -- Update the chatObj to reflect the message has been sent for this item
        chatObj.chatMsgFired = true
        chatObj.currentItem = itemLink
    end

    -- Show the tooltip
    tooltip:Show()
end

-- Hook GameTooltip to show static text with BIS and Pre-BIS item links for the HeadSlot item
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    AddStaticTextToTooltip(self)
end)