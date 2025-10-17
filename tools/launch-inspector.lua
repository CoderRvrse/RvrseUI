-- RvrseUI GUI Inspector Launcher
-- Run this script AFTER loading RvrseUI to inspect the GUI structure

print("=" .. string.rep("=", 60))
print("🔍 RvrseUI GUI Inspector")
print("=" .. string.rep("=", 60))

-- Load inspector
local Inspector = loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/tools/gui-inspector.lua"))()

-- Run inspector
Inspector:Run()

print("\n📋 Inspector Features:")
print("  ✓ Visual GUI tree with hierarchy")
print("  ✓ Click elements to see full details")
print("  ✓ Color-coded by element type")
print("  ✓ Shows Position, Size, Visibility, Transparency")
print("  ✓ Shows ZIndex, Parent, ClipsDescendants")
print("  ✓ Draggable window")
print("  ✓ Refresh button to rescan")
print("\n💡 Usage:")
print("  1. Click any element in the tree (left panel)")
print("  2. View detailed properties (right panel)")
print("  3. Look for ColorPickerPanel in the tree")
print("  4. Check its Parent (should be RvrseUI_OverlayLayer!)")
print("  5. Check Visible, Size, Transparency")
print("\n" .. string.rep("=", 60))
