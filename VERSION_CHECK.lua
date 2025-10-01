-- VERSION_CHECK.lua - Check what version you're actually running

-- Load RvrseUI with FORCE CACHE BUST
local RvrseUI = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()
))()

-- Print version info
print("===========================================")
print("VERSION CHECK RESULTS:")
print("===========================================")
print("Version:", RvrseUI.Version.Full)
print("Build:", RvrseUI.Version.Build)
print("Hash:", RvrseUI.Version.Hash)
print("Channel:", RvrseUI.Version.Channel)
print("===========================================")

-- Check if outdated
if RvrseUI.Version.Patch < 7 then
	warn("⚠️ YOU ARE RUNNING AN OUTDATED VERSION!")
	warn("Current version: v" .. RvrseUI.Version.Full)
	warn("Latest version: v2.3.7")
	warn("")
	warn("ERRORS YOU MAY SEE:")
	warn("- 'attempt to index nil with Switch'")
	warn("- 'attempt to index nil with BackgroundColor3'")
	warn("")
	warn("FIX: You MUST reload this script to get v2.3.7!")
	warn("1. Stop your game completely")
	warn("2. Re-run this script")
	warn("3. Check version again")
else
	print("✅ YOU ARE RUNNING THE LATEST VERSION!")
	print("All errors should be fixed.")
end

print("===========================================")

-- Test Theme system
if Theme and Theme.Switch then
	print("✅ Theme system: OK")
else
	warn("❌ Theme system: BROKEN (running old version)")
end

-- Don't create UI, just check version
