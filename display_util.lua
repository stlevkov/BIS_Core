

local englishClass = select(2, UnitClass("player"))

-- Function to load the appropriate BIS list based on class and spec
function LoadBISListForSpecBisCore(specName)
    local specBIS = _G["BIS_LIST_" .. englishClass]

    if specBIS then
        -- Get BIS and Pre-BIS for the current spec
        local classSpecBIS = specBIS[specName] or {BIS = {}, PreBIS = {}}  -- Default to empty if spec not found
        return classSpecBIS
    end

    return {BIS = {}, PreBIS = {}} -- Default empty lists if BIS list not found
end

-- Function to process the class specialization based on talent points
local function processClassSpecialization()
    local numTabs = GetNumTalentTabs()
    local talents = { 0, 0, 0 }

    for t = 1, numTabs do
        local numTalents = GetNumTalents(t)
        local calculateTalents = 0
        for i = 1, numTalents do
            local nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i)
            calculateTalents = calculateTalents + currRank
        end
        talents[t] = calculateTalents
    end
    return talents
end

-- Function to determine the specialization based on talents and class
function GetClassRoleBisCore()
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
            return "Discipline"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Holy"
        else
            return "Shadow"
        end
    elseif englishClass == "MAGE" then
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Arcane"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Fire"
        else
            return "Frost"
        end
    elseif englishClass == "DEATHKNIGHT" then
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return "Blood"
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return "Frost"
        else
            return "Unholy"
        end
    else
        print("BIS will not work for this Class: " .. englishClass)
    end
end

return GetClassRoleBisCore(), LoadBISListForSpecBisCore()