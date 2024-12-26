-- /console scriptErrors 1 (to see lua errors) (ingame)

-- Global variable for storing chat message state
chatObj = { chatMsgFired = false, currentItem = nil }

local englishClass = select(2, UnitClass("player"))

-- Function to process the class specialization based on talent points
local function processClassSpecialization()
    local numTabs = GetNumTalentTabs()
    local talents = { 0, 0, 0 }

    for t = 1, numTabs do
        local numTalents = GetNumTalents(t)
        local calculateTalents = 0
        for i = 1, numTalents do
            nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i)
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
            if classRole[3] > 11 then
                return "FeralDPS"
            else
                return "FeralTank"
            end
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

-- Function to add static text with BIS and Pre-BIS item links to the tooltip for the HeadSlot item
local function AddStaticTextToTooltip(tooltip)

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
    local specName = getClassRole()

    -- Load BIS and Pre-BIS lists for the current spec
    local BIS_LIST = LoadBISListForSpec(specName).BIS
    local PRE_BIS_LIST = LoadBISListForSpec(specName).PreBIS

    -- Ensure BIS and Pre-BIS lists are available
    if not BIS_LIST or not PRE_BIS_LIST then
        tooltip:AddLine("|cff00ff00BIS and Pre-BIS data not available|r", 1, 1, 1)
        return
    end

    -- Get the BIS and Pre-BIS items for the detected slot
    local bisItemID, preBisItemID, bisSource, preBisSource
    for _, item in ipairs(BIS_LIST) do
        if item.slot == itemSlot then
            bisItemID = item.itemID
            bisSource = item.source
            break
        end
    end

    for _, item in ipairs(PRE_BIS_LIST) do
        if item.slot == itemSlot then
            preBisItemID = item.itemID
            preBisSource = item.source
            break
        end
    end

    -- Add BIS item to the tooltip
    if bisItemID then
        local bisItemLink = select(2, GetItemInfo(bisItemID))
        tooltip:AddLine("|cff00ff00BIS:|r " .. (bisItemLink or "Item not found"), 1, 1, 1)
    else
        tooltip:AddLine("|cff00ff00BIS:|r Item not found", 1, 1, 1)
    end

    -- Add Pre-BIS item to the tooltip
    if preBisItemID then
        local preBisItemLink = select(2, GetItemInfo(preBisItemID))
        tooltip:AddLine("|cff00ff00Pre-BIS:|r " .. (preBisItemLink or "Item not found"), 1, 1, 1)
    else
        tooltip:AddLine("|cff00ff00Pre-BIS:|r Item not found", 1, 1, 1)
    end

    -- Print clickable BIS and Pre-BIS items in chat, one per line
    if not chatObj.chatMsgFired or chatObj.currentItem ~= itemLink then
        -- Get BIS and Pre-BIS item links
        local bisItemLink = bisItemID and select(2, GetItemInfo(bisItemID)) or nil
        local preBisItemLink = preBisItemID and select(2, GetItemInfo(preBisItemID)) or nil

        -- Print BIS item with itemSlot and source
        if bisItemID then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BIS " .. itemSlot .. ":|r " .. (bisItemLink or "Item not found. Please update your addon files") .. " |cff00ff00Source:|r " .. (bisSource or "Unknown"))
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BIS " .. itemSlot .. ":|r Item not declared in the files")
        end

        -- Print Pre-BIS item with itemSlot and source
        if preBisItemID then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Pre-BIS " .. itemSlot .. ":|r " .. (preBisItemLink or "Item not found. Please update your addon files") .. " |cff00ff00Source:|r " .. (preBisSource or "Unknown"))
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

-- -- Handle item info loading if the item is not yet cached
-- local function OnItemInfoReceived(itemID)
--     print("Item info received for itemID: " .. itemID)
--     -- Re-fetch item details after the item info is loaded
--     local randomItemName, randomItemLink = GetItemInfo(itemID)
--     if randomItemLink then
--         -- Update tooltips with the loaded item info
--         GameTooltip:ClearLines()
--         AddStaticTextToTooltip(GameTooltip)
--     end
-- end

-- -- Hook into the GET_ITEM_INFO_RECEIVED event to handle item info once loaded
-- local frame = CreateFrame("Frame")
-- frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
-- frame:SetScript("OnEvent", function(self, event, itemID)
--     OnItemInfoReceived(itemID)
-- end)

-- Hook GameTooltip to show static text with BIS and Pre-BIS item links for the HeadSlot item
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    AddStaticTextToTooltip(self)
end)