-- Function to print messages with a prefix
local function BIS_Print(msg)
    print("|cff00ccffBIS Core:|r " .. msg)
end

-- Set up default values for the settings
local defaultSettings = {
    active = true,
    overlay = true,
    tooltip = true,
    chat = true
}

-- Command handler function
local function BIS_CommandHandler(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$")
    if command == "help" then
        BIS_Print("Available commands:")
        BIS_Print("|cff00ff00/bis status|r - Show the current status of the addon")
        BIS_Print("|cff00ff00/bis toggle|r - Toggle addon functionality")
        -- BIS_Print("|cff00ff00/bis overlay show|r - Show overlays on the character window")
        -- BIS_Print("|cff00ff00/bis overlay hide|r - Hide overlays on the character window")
        -- BIS_Print("|cff00ff00/bis tooltip show|r - Enable BIS tooltip additions")
        -- BIS_Print("|cff00ff00/bis tooltip hide|r - Disable BIS tooltip additions")
        -- BIS_Print("|cff00ff00/bis chat show|r - Enable BIS chat output")
        -- BIS_Print("|cff00ff00/bis chat hide|r - Disable BIS chat output")
    elseif command == "toggle" then
        BIS_Core_Settings.active = not BIS_Core_Settings.active
        if BIS_Core_Settings.active then
            BISCoreOverlaysInitialize()
        end
        BIS_Print("BIS functionality is now " .. (BIS_Core_Settings.active and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
    elseif command == "status" then
        BIS_Print("BIS functionality is currently " .. (BIS_Core_Settings.active and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        -- BIS_Print("Overlays are currently " .. (BIS_Core_Settings.overlay and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        -- BIS_Print("Tooltips are currently " .. (BIS_Core_Settings.tooltip and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
        -- BIS_Print("Chat output is currently " .. (BIS_Core_Settings.chat and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
    else
        BIS_Print("Unknown command. Type |cff00ff00/bis help|r for a list of commands.")
    end
end

-- Register the command
SLASH_BIS1 = "/bis"
SlashCmdList["BIS"] = BIS_CommandHandler

-- Ensure settings are initialized after VARIABLES_LOADED
local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:SetScript("OnEvent", function()
    -- Initialize saved variables with defaults if they are nil
    BIS_Core_Settings = BIS_Core_Settings or {}
    for key, value in pairs(defaultSettings) do
        if BIS_Core_Settings[key] == nil then
            BIS_Core_Settings[key] = value
        end
    end

    -- Print an initialization message
    print("BIS Core by Lqlqdum loaded! |cff00ccffv0.0.1|r. Check for new versions at |cff00ccffgithub.com/stlevkov/BIS_Core|r. Type |cff00ff00/bis toggle|r to show/hide or |cff00ff00/bis help|r for more details.")

    print("Checking for BIS Core settings on load to initialize overlays: " .. tostring(BIS_Core_Settings.active))
    -- Initialize BIS overlays if the addon is active on load
    if BIS_Core_Settings.active then
        BISCoreOverlaysInitialize()
    end
end)
