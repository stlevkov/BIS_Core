# BIS_Core - World of Warcraft Classic Addon

BIS_Core is a World of Warcraft Classic addon written in Lua that displays "BIS" (Best in Slot) and "Pre-BIS" tags on items in the character window, helping players identify optimal gear for their class and specialization.

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites and Setup
- Install Lua 5.3 for syntax validation:
  - `sudo apt-get update && sudo apt-get install -y lua5.3 liblua5.3-dev`
- Verify installation: `lua5.3 -v`

### Core Development Workflow
- **IMPORTANT**: This is a WoW addon - there is NO traditional build process. Files are used directly by the game client.
- **AUTOMATED VALIDATION**: Run `./validate_addon.sh` for complete validation - takes <2 seconds. NEVER CANCEL.
- **Quick syntax check**: `luac5.3 -p *.lua` - takes <1 second. NEVER CANCEL.
- **Individual file check**: `luac5.3 -p filename.lua` - instant validation.
- **File structure verification**: The validation script checks that all files listed in `BIS_Core.toc` exist and are in correct order.

### Addon Structure and Loading Order
The addon loads files in this EXACT order (defined in BIS_Core.toc):
1. display_helper.lua - Command handling and settings
2. display_util.lua - Utility functions for class/spec detection  
3. display_bis.lua - Main overlay display logic
4. display_tooltip.lua - Tooltip enhancements
5. Class files (deathknight.lua through warrior.lua) - BIS gear definitions

**CRITICAL**: Always maintain this loading order. Never reorder files in BIS_Core.toc without careful consideration.

### Testing and Validation
- **ALWAYS run validation script first**: `./validate_addon.sh` - comprehensive check taking <2 seconds
- **Syntax validation is MANDATORY before any changes**: `luac5.3 -p filename.lua`
- **NO automated tests exist** - testing requires World of Warcraft client
- **Manual testing workflow**:
  1. Run `./validate_addon.sh` to ensure addon integrity
  2. Copy addon to `World of Warcraft/_classic_/Interface/AddOns/BIS_Core/`
  3. Start WoW Classic client  
  4. Enable addon in AddOns menu
  5. Create/login character
  6. Open character window (`C` key)
  7. Verify BIS/Pre-BIS tags appear on appropriate gear
  8. Test slash commands: `/bis help`, `/bis status`, `/bis toggle`

### Development Guidelines
- **File editing**: Edit Lua files directly - no compilation needed
- **Immediate testing**: Copy changed files to WoW addon directory for testing
- **Syntax check EVERY change**: Run `luac5.3 -p filename.lua` after editing any file
- **Line counts**: Current codebase is 1,315 lines across 14 Lua files
- **Code style**: Follow existing Lua patterns in the codebase

## Validation Scenarios

### After Making Any Changes
1. **ALWAYS run the validation script**: `./validate_addon.sh`
2. **Check individual files if needed**: `luac5.3 -p filename.lua`
3. **Manual testing required**: Test in WoW client with character that has gear
4. **Test scenarios**:
   - Login with different classes (Shaman, Warrior, Paladin, etc.)
   - Verify specialization detection works correctly
   - Confirm BIS/Pre-BIS tags display on appropriate items
   - Test slash commands function properly

### Specific Test Cases
- **Specialization detection**: Create characters with different talent builds
- **Gear display**: Equip items that should show BIS/Pre-BIS tags  
- **Class switching**: Test with multiple character classes
- **Settings persistence**: Verify `/bis toggle` state persists across sessions

## Common Tasks and File Organization

### Key Files and Their Purposes
- `BIS_Core.toc`: Addon metadata and file loading order - CRITICAL file
- `display_helper.lua`: Slash commands and settings (77 lines)
- `display_util.lua`: Class/spec detection logic (127 lines)  
- `display_bis.lua`: Main overlay rendering (132 lines)
- `display_tooltip.lua`: Tooltip enhancements (123 lines)
- Class files: BIS gear definitions for each class (45-116 lines each)

### Common Development Tasks
- **Adding new BIS items**: Edit appropriate class file (e.g., `shaman.lua`)
- **Modifying display logic**: Edit `display_bis.lua`
- **Changing slash commands**: Edit `display_helper.lua`
- **Updating specialization detection**: Edit `display_util.lua`
- **Tooltip modifications**: Edit `display_tooltip.lua`

### Repository Structure
```
BIS_Core/
├── BIS_Core.toc          # Addon manifest (CRITICAL)
├── README.md             # Documentation  
├── LICENSE               # MIT License
├── validate_addon.sh     # Validation script (NEW)
├── display_helper.lua    # Commands & settings
├── display_util.lua      # Utility functions
├── display_bis.lua       # Main display logic
├── display_tooltip.lua   # Tooltip logic
├── images/              # Screenshots
│   └── bis_overlay.png
└── [class].lua          # Class-specific BIS lists
    ├── deathknight.lua
    ├── druid.lua
    ├── hunter.lua
    ├── mage.lua
    ├── paladin.lua
    ├── priest.lua
    ├── rogue.lua
    ├── shaman.lua
    ├── warlock.lua
    └── warrior.lua
```

## Installation and Distribution

### For Development
1. Clone repository: `git clone https://github.com/stlevkov/BIS_Core.git`
2. **NO build step required** - files are ready to use
3. Copy to WoW addon directory for testing

### For Users  
1. Download/extract to `World of Warcraft/_classic_/Interface/AddOns/BIS_Core/`
2. Ensure folder structure matches repository structure
3. Enable in WoW AddOns menu
4. Restart client and test with `/bis help`

## Important Notes

### Timeouts and Performance
- **Validation script**: <2 seconds for complete check
- **Syntax validation**: <1 second for all files, instant for individual files
- **File operations**: Instant (no compilation needed)
- **Testing**: Depends on WoW client startup time (~30-60 seconds)

### Limitations
- **NO automated testing framework** exists
- **Manual testing required** for all functionality
- **WoW client dependency** for complete validation
- **NO continuous integration** currently configured

### Error Prevention
- **ALWAYS validate syntax** before committing changes
- **Test with multiple character classes** when possible
- **Verify file loading order** in BIS_Core.toc after changes
- **Check for typos in item IDs** in class files

### Known Issues
- One TODO found in druid.lua line referencing alternative item ID
- No linting tools configured (luacheck installation attempted but failed due to network restrictions)

## Quick Reference Commands

```bash
# Complete validation (RECOMMENDED)
./validate_addon.sh

# Syntax check all files
luac5.3 -p *.lua

# Syntax check single file  
luac5.3 -p filename.lua

# Manual comprehensive check (if validation script unavailable)
for file in *.lua; do echo "Checking $file:"; luac5.3 -p "$file" && echo "✓ OK" || echo "✗ FAILED"; done

# Line count summary
wc -l *.lua

# Find TODO/FIXME items
grep -r "TODO\|FIXME\|HACK" --include="*.lua" .

# Repository size
du -sh .

# Verify .toc file integrity
grep "\.lua" BIS_Core.toc | while read file; do if [ ! -f "$file" ]; then echo "Missing: $file"; else echo "Found: $file"; fi; done
```

**Remember**: This is a WoW addon, not a traditional application. The "build" process is copying files to the game directory and testing in-client. Always prioritize syntax validation and manual testing over automated processes that don't exist for this project type.