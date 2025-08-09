# SM BiS Addon by Lqlqdum

## Overview
The **SM BiS Addon** is a World of Warcraft Classic addon that displays "BIS" (Best in Slot) and "Pre-BIS" tags on items in your character window, helping you quickly identify which items match your optimal gear list. The addon adapts to your class and specialization, loading the appropriate BIS lists for your character.

<img src="images/bis_overlay.png"/>

## Features
- Detects your class and specialization based on talent points.
- Displays **BIS** or **Pre-BIS** tags on equipped items that match your Best in Slot list.
- Supports multiple classes and specializations.
- **NEW**: Alternative Pre-BIS items - specify multiple pre-bis options per slot for player choice.
- Customizable BIS lists can be edited or extended as needed.

## Installation
1. Download the addon and extract it to your `World of Warcraft/_classic_/Interface/AddOns` folder.
2. Ensure the folder structure looks like this:
   ```
   World of Warcraft
   └── _classic_
       └── Interface
           └── AddOns
               └── BIS_Core
                   ├── display_bis.lua
                   ├── display_tooltip.lua
                   ├── shaman.lua
                   ├── warrior.lua
                   ├── paladin.lua
                   └── ... (other class files)
   ```
3. Restart WoW and ensure the addon is enabled in the AddOns menu.

## Usage
1. Open your character window in-game (`C` by default).
2. Items in your equipment slots will show:
   - **BIS**: If the item matches your Best in Slot list.
   - **pre**: If the item matches your Pre-BIS list (including alternative pre-bis items).
3. Hover over equipped items to see tooltips showing:
   - Single pre-bis: "Pre-BIS: [Item Name]"
   - Multiple pre-bis: "Pre-BIS: [Main Item] or [Alternative Item]"
4. Enable chat output with `/bis chat show` to see pre-bis alternatives in chat.

## How It Works
- The addon determines your class and specialization using the WoW API.
- It then loads the appropriate BIS and Pre-BIS lists from class-specific Lua files.
- If an equipped item matches your BIS or Pre-BIS lists, the addon displays the corresponding tag in the character window.

## Customization
### Adding or Modifying BIS Lists
To add or modify BIS lists:
1. Open the class-specific Lua file in a text editor (e.g., `shaman.lua`).
2. Add or edit entries in the `BIS` and `PreBIS` tables using the following format:
   ```lua
    BIS = {
        { slot = "HeadSlot", itemID = 51227, source = "Vendor" }, -- Sanctified Ymirjar Lord's Helmet (heroic)
       ....
   },
   PreBIS = {
        { slot = "HeadSlot", itemID = 51212, source = "Vendor" }, -- Sanctified Ymirjar Lord's Helmet (normal)
       ...
   }
   ```
3. Save the file and reload the UI in-game with `/reload`.

### Alternative Pre-BIS Items (New Feature)
You can now specify multiple pre-bis items for the same slot to give players alternative options:

```lua
PreBIS = {
    { slot = "HeadSlot", itemID = 51212, source = "Vendor Normal Mark" }, -- Main pre-bis option
    { slot = "HeadSlot", itemID = 50640, source = "Lady Deathwhisper 25HC" }, -- Alternative pre-bis option
    { slot = "NeckSlot", itemID = 50182, source = "Blood Queen Lana'thel 25" }, -- Single pre-bis (works as before)
    { slot = "ShoulderSlot", itemID = 51214, source = "Vendor Normal Mark" }, -- Main shoulder option
    { slot = "ShoulderSlot", itemID = 51847, source = "Prince Valandar 10HC" } -- Alternative shoulder option
}
```

**How it works:**
- **Character Window**: Items will show "pre" overlay if they match any pre-bis item (main or alternative)
- **Tooltips**: Will display "[Main Item] or [Alternative Item]" when hovering over equipped items
- **Chat Output**: Will show "Pre-BIS ItemSlot:" for the first item and "Pre-BIS Alt ItemSlot:" for additional items
- **Backward Compatibility**: Existing single pre-bis items continue to work exactly as before

## Troubleshooting
1. **Addon not showing BIS tags?**
   - Ensure the addon is installed in the correct folder.
   - Check the game's AddOns menu to verify the addon is enabled.
   - Reload the UI (`/reload`) after making changes.

2. **Error: `attempt to call global 'something' (a nil value)`?**
   - The addon now uses global variables to load class-specific BIS lists. Ensure the `shaman.lua` and other class files are loaded as part of the addon.

3. **Need help with an issue?**
   - Feel free to open an issue on [GitHub](https://github.com/stlevkov/BIS_Core).

## Credits
- **Author**: [Lqlqdum](https://github.com/stlevkov)
- Inspired by the need for an easy-to-use BIS tracking tool in WoW Classic.
- Special thanks to [Brandon Sturgeon](https://gist.github.com/brandonsturgeon) for providing the BIS items. Original list can be found here: https://gist.github.com/brandonsturgeon/756ed49463ad8f659a1b760c1a20d441
