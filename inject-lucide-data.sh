#!/bin/bash
# Inject Lucide sprite data into RvrseUI.lua after services section

echo "📦 Injecting Lucide sprite data into RvrseUI.lua..."

# 1. Rebuild first to get latest code
node build.js

# 2. Read the lucide data
LUCIDE_DATA=$(cat src/lucide-icons-data.lua)

# 3. Create the injection block
INJECTION="

-- ========================
-- Lucide Icons Sprite Data
-- ========================
-- 500+ Lucide icons via sprite sheets (145KB)
-- Set as global for LucideIcons module to access
_G.RvrseUI_LucideIconsData = $LUCIDE_DATA
"

# 4. Find the line number where modules start (after RvrseUI = {})
MODULE_START=$(grep -n "^-- ========================" RvrseUI.lua | head -n 1 | cut -d: -f1)

# 5. Split the file and inject
head -n $(($MODULE_START - 1)) RvrseUI.lua > RvrseUI-temp.lua
echo "$INJECTION" >> RvrseUI-temp.lua
tail -n +$MODULE_START RvrseUI.lua >> RvrseUI-temp.lua
mv RvrseUI-temp.lua RvrseUI.lua

echo "✅ Lucide sprite data injected!"
