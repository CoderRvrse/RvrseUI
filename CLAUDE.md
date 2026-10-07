# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# RvrseUI – Maintainer Notes (v4.5.1)

> **⚠️ CRITICAL: Read this entire document before making ANY changes to the codebase.**
> This file documents the architecture, build system, common pitfalls, and strict workflows that MUST be followed.

---

## 🚨 CRITICAL WARNING #0 (v4.5.0): Every module is wrapped in `do ... end` — keep it that way

`tools/build.js` and `tools/build.lua` put each module inside its own `do ... end` block. That keeps a module's
private top-level locals private. The 4.4.x builds dropped the wrapping, so `WindowBuilder.lua`'s
`local Theme, Animator, ..., Obfuscation` (nil until `CreateWindow`) shadowed the real module tables for every
line after it, and the monolith died on load with `attempt to index nil with 'Initialize'` — on every executor.

- Module tables still become shared globals (`local Theme = {}` → `Theme = {}`); everything else stays block-local.
- `build.js` and `build.lua` must produce **identical** output (only the timestamp line differs). After touching
  either, run both and diff them.
- Before pushing a build, run `node tests/headless/run.js` — a bad build breaks every hub instantly, because
  hubs load `main/RvrseUI.lua` live. (The 4.4.x build fails it at load.)

## 🚨 CRITICAL WARNING #0b (v4.5.0): Nothing may outlive its window

A window's `Lifecycle` (created at the top of `WindowBuilder:CreateWindow`) owns everything the window starts.
`teardownWindow(reason)` is the ONLY close path (X button, `Window:Destroy()`, `RvrseUI:Destroy()`, destroy key).

- **Any connection to a service** (`UIS.*`, `RunService.*`, `game:GetService(...)`) or to an instance outside the
  window **must** be tracked: in WindowBuilder `Lifecycle:Track(conn)`, in elements `trackCleanup(conn)`.
  Connections on instances inside the window die with it, but service connections never do.
- **Anything parented outside the window** (overlay panels, dropdown lists, fallback ScreenGuis) must be tracked
  too: `trackCleanup(instance)`.
- **Shared listener lists** (`RvrseUI._lockListeners`): elements call `addLockListener(fn)`, never `table.insert`.
- The last window to close calls `WindowBuilder:TeardownShared(...)` (host, `Overlay:Teardown()`,
  `Hotkeys:Teardown()`, `Particles:Teardown()`); `CreateWindow` revives them (`Overlay:Revive()`, `Hotkeys:Init()`).
- Tabs from code (v4.5.1): `Window:SelectTab(target)`, target = position (1 = first tab created), tab Title, or
  the tab object. Returns true/false; an unknown target warns and returns false, it never errors. Each entry in
  WindowBuilder's `tabs` list carries `title`, `activate` and `api` for it (set in TabBuilder).
- Public API: `Window:OnClose(fn)`, `CreateWindow{ OnClose = fn }`, `Window:Track(item)`, `Window:IsDestroyed()`,
  `CreateWindow{ TurnOffTogglesOnClose = true }` + per-toggle `TurnOffOnClose`. RvrseUI's own settings toggles
  (e.g. Profiles "Auto Save") set `TurnOffOnClose = false`.
- Verify with the headless harness: `node tools/build.js && node tests/headless/run.js` (needs the `luau` CLI;
  see `tests/headless/README.md`) — 9 close scenarios, must report 0 live connections and 0 ScreenGuis after
  close. v4.3.31 fails it with 38 leaked connections per window.

---

## 🔥 Migration Handoff – Luau-First Initiative (Completed ✅)

- **Mission Status:** Toolchain migration complete! All Luau tools (Stylua, Selene, Rojo, Wally) now install via **Aftman** (the preferred Roblox toolchain manager). Configuration lives in `aftman.toml` at repo root. CI workflow `.github/workflows/luau-ci.yml` uses Aftman v0.2.7 to manage tool versions declaratively. No more manual cargo installs or brittle download scripts.
- **Monolith Health:** The public API (`RvrseUI:CreateWindow`, `:Notify`, etc.) was reintroduced in `RvrseUI.lua` v4.3.8; SurvivalHub sample loads again. Before pushing further changes, run `lua tools/build.lua` and smoke-test `examples/RvrseUI-SurvivalHub.lua` with `loadstring` to confirm hydration logic still matches README.
- **Outstanding Defects:** Light-mode visuals still show alpha seam/corner mismatch. Audit ImageLabel assets for correct `SliceCenter`, match all `UICorner` radii, ensure `ClipsDescendants` is false where `UIStroke` should spill, and remove semi-transparent PNG halos. Track fixes in `/src/UIHelpers` and `/src/Theme`.
- **Regression Warning:** Roblox logs reported `value of type nil cannot be converted to a number` from `CreateTextBox`. Review `src/Elements/TextBox.lua` line parity with compiled monolith (lines ~6248 and ~7556) to identify missing defaults before next build.
- **Legacy Tooling Inventory:** Remaining non-Luau helpers live under `docs/__archive/2025-10-16/BUILD_MONOLITHIC.js`. Treat everything under `tools/` as the source of truth for builds; if you port archived JS logic, mark the original file `vendored` in `.gitattributes` and uprev the Lua replacement in `tools/`. No active shell scripts remain.
- **Next Checkpoint:** Finish CI stabilization (pinned Wally + retry guard), then document the Luau-first plan in README + VERSION bump. Only after CI is green should Claude continue porting archived Node workflows or tackling UI polish.

---

## 🚨 CRITICAL WARNING #1: NEVER Overcomplicate Drag-and-Drop Logic!

### **ALWAYS use the classic Roblox drag pattern - NOTHING MORE!**

**What happened in v4.0.4:**
- Window and controller chip "kicked away" from cursor during drag
- **ROOT CAUSE:** Overcomplicated logic with AbsolutePosition calculations, AnchorPoint math, GUI inset handling, coordinate conversions
- **600 lines of buggy complex code** trying to be "smart" about cursor tracking
- User reported: *"if i click on th upper top side of coin the mouse shifts more center"*

**The Fix - Back to Basics:**
```lua
-- ✅ CORRECT - Simple delta calculation (THE ONLY WAY!)
local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position      -- Store mouse start
        startPos = frame.Position       -- Store frame start
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
```

**Rules - NO EXCEPTIONS:**
- ✅ **Store starting mouse position** (`dragStart = input.Position`)
- ✅ **Store starting frame position** (`startPos = frame.Position`)
- ✅ **Calculate delta** (`delta = input.Position - dragStart`)
- ✅ **Apply delta to original position** (`startPos + delta`)
- ✅ **Use UDim2 directly** - Roblox handles scale/offset math for you!
- ❌ **NEVER use AbsolutePosition** - it's for reading, not drag logic!
- ❌ **NEVER do AnchorPoint math** - UDim2 system handles it automatically!
- ❌ **NEVER calculate GUI inset** - not needed with this pattern!
- ❌ **NEVER convert coordinate spaces** - stay in input.Position space!
- ❌ **NEVER lock sizes during drag** - not needed!
- ❌ **NEVER disable hover animations** - not needed!

**Why This Works:**
- Roblox's UDim2 system handles ALL coordinate transformations for you
- `input.Position` is screen-space, `UDim2` is UI-space - Roblox converts automatically
- Simple delta calculation: `currentMouse - startMouse = howMuchToMove`
- Apply that movement to where the frame started: `startFrame + movement = newFrame`
- **NO MATH NEEDED!** Just subtraction and addition!

**What We Removed (All Unnecessary!):**
```lua
-- ❌ ALL OF THIS WAS WRONG:
local function getPointerPosition(inputObject)
    return Vector2.new(inputObject.Position.X, inputObject.Position.Y)
end

local function getGuiInset()
    return GuiService:GetGuiInset()
end

local topLeft = root.AbsolutePosition
local bottomRight = topLeft + root.AbsoluteSize
local dragPointerOffset = pointer - topLeft
local newPosition = UDim2.fromOffset(
    pointerPosition.X - dragPointerOffset.X,
    pointerPosition.Y - dragPointerOffset.Y
)
-- ... 200+ more lines of confusion
```

**Result:**
- ✅ 65% code reduction (400 lines → 140 lines)
- ✅ NO jumps, NO drift, cursor perfectly locked to grab point
- ✅ Works with ANY AnchorPoint value
- ✅ Works with ANY parent container
- ✅ User confirmed: *"that was it that was the fix back to the basics!"*

**Reference Implementation:**
See `SIMPLE_DRAG_REFERENCE.lua` for the canonical pattern. Copy it exactly for any future drag needs.

**If you're tempted to add ANY complexity to drag logic:**
1. **STOP** - You're about to introduce bugs
2. **Re-read this section** - The simple pattern is complete
3. **Ask yourself:** "Why am I not using the proven pattern?"
4. **Use the simple pattern** - It works perfectly!

---

## 🚨 CRITICAL WARNING #2: UIHelpers.shadow() Restriction

### **NEVER use `shadow()` helper on overlay panels or dropdown menus!**

**What happened in v4.0.1:**
- The `shadow()` helper creates an ImageLabel that extends **40px beyond the parent element**
- For overlay panels (ColorPicker, Dropdown), this created a **giant gray box covering the entire screen**
- Shadow ZIndex = parent.ZIndex - 1, blocking ALL UI below it

**Elements Fixed:**
- ❌ ColorPicker.lua:196 - `shadow(pickerPanel, 0.7, 20)` → DISABLED
- ❌ Dropdown.lua:180 - `shadow(dropdownList, 0.6, 16)` → DISABLED
- ❌ DropdownLegacy.lua:91 - `shadow(dropdownList, 0.6, 16)` → DISABLED

**Rules:**
- ✅ **USE shadow() ONLY on small inline elements** (< 60px, ZIndex < 100)
  - Button elements, Toggle thumbs, Slider thumbs
- ❌ **NEVER use shadow() on:**
  - Overlay panels (ColorPicker, Dropdown, Modals)
  - Large containers (> 100px)
  - Elements with high ZIndex (> 100)
  - Scrolling frames, Popup elements

**Alternative:** Use `stroke()` for visual definition on overlay panels.

**Full Documentation:** [docs/UI-ARCHITECTURE.md](docs/UI-ARCHITECTURE.md#-critical-ui-helper-restrictions)

---

## 🚨 CRITICAL WARNING #3: Function Forward-Declaration Required

### **ALWAYS forward-declare functions used in closures/callbacks!**

**What happened in v4.0.2:**
- Dropdown.lua's `setOpen()` function was called in blocker click handler
- But `setOpen` wasn't defined until 346 lines later!
- Multi-select dropdown crashed when clicking blocker: `:3853: attempt to call a nil value`

**The Fix:**
```lua
-- ✅ CORRECT - Forward declare before use
local setOpen  -- Forward declaration

local function showOverlayBlocker()
    overlayBlocker.MouseButton1Click:Connect(function()
        setOpen(false)  -- ✅ OK! Variable exists in scope
    end)
end

setOpen = function(state)  -- Assign to forward-declared variable
    -- ...
end

// ❌ WRONG - Function doesn't exist yet
local function showOverlayBlocker()
    overlayBlocker.MouseButton1Click:Connect(function()
        setOpen(false)  -- ❌ nil! setOpen doesn't exist yet
    end)
end

function setOpen(state)  -- Too late! Closure already has nil reference
    -- ...
end
```

**Rule:** If Function A creates a closure that calls Function B, and Function B is defined AFTER Function A, you MUST forward-declare Function B!

---

## 🚨 CRITICAL WARNING #4: Lua Closure Upvalue Capture Bug

### **NEVER define wrapper functions that capture forward-declared variables!**

**What happened in v4.0.3:**
- Multi-select dropdown blocker would NOT close when clicking outside
- Blocker click event fired, but `setOpen` was `nil` inside the handler
- **ROOT CAUSE:** Lua closures capture variable VALUES at definition time, NOT references!

**The Bug:**
```lua
local setOpen  -- Forward declaration (setOpen = nil at this point)

-- ❌ BROKEN - closeDropdown captures setOpen's CURRENT value (nil)
local function closeDropdown()
    if setOpen then  -- This captures nil from line above!
        setOpen(false)
    end
end

-- Later...
setOpen = function(state)  -- Assigned here, but closeDropdown already has nil!
    showOverlayBlocker()
    overlayBlocker.MouseButton1Click:Connect(closeDropdown)  -- Handler has nil!
end
```

**Evidence from logs:**
```
06:05:56 -- setOpen exists: true (type: function)  ← When connecting handler
06:06:01 -- setOpen type: nil                      ← When handler fires! BUG!
```

**The Fix - Use Inline Anonymous Functions:**
```lua
local setOpen  -- Forward declaration

setOpen = function(state)
    showOverlayBlocker()

    -- ✅ CORRECT - Create closure at connection point, INSIDE setOpen body
    overlayBlocker.MouseButton1Click:Connect(function()
        if setOpen then  -- Captures setOpen from CURRENT scope (exists!)
            setOpen(false)
        end
    end)
end
```

**Why This Works:**
1. The inline `function()` is created at line where `Connect()` is called
2. `Connect()` is called INSIDE `setOpen` function body
3. At that point, `setOpen` variable EXISTS in the current scope
4. The inline closure captures the CURRENT scope (setOpen = function)
5. When clicked, closure looks up `setOpen` and finds the function!

**Proof it's fixed:**
```
06:24:25 -- setOpen type at click time: function  ← FIXED!
06:24:25 -- setOpen exists: true
06:24:25 -- [DROPDOWN] ✅ setOpen EXISTS! Calling setOpen(false)...
06:24:25 -- [DROPDOWN] ✅ Dropdown closed successfully!
```

**Rules:**
- ❌ **NEVER** define wrapper functions early that reference forward-declared variables
- ✅ **ALWAYS** use inline anonymous functions created at the connection point
- ✅ **ALWAYS** create closures INSIDE the function body where the variable is assigned
- 🔍 **TEST** by logging variable type at definition time vs. call time

**Files Affected:**
- `src/Elements/Dropdown.lua:267` - Fallback blocker handler (inline function)
- `src/Elements/Dropdown.lua:605` - Overlay blocker handler (inline function)

**Never Repeat This Pattern:**
```lua
local myVar
local function wrapper() return myVar end  -- ❌ Captures nil!
myVar = "value"
wrapper()  -- Returns nil, not "value"!
```

---

## 🚨 CRITICAL WARNING #5: NEVER Use `_G` - Executor Safety

### **ALWAYS use `local` or `getgenv()` - NEVER `_G`!**

**Why This Matters:**
- RvrseUI is designed for **executor safety** and **detection avoidance**
- Using `_G` makes your scripts **easily detectable** by anti-cheat systems
- Roblox can monitor and log `_G` usage globally

**What is `_G`?**
- `_G` is Roblox's global environment shared across ALL scripts
- Anti-cheat systems monitor it for suspicious activity
- **NEVER use it for exploits, hubs, or executors!**

**The Safe Alternatives:**

### ✅ CORRECT - Use Local Variables (Recommended)
```lua
-- ✅ SAFE - Script-scoped, not detectable
local RvrseUI = loadstring(game:HttpGet(...))()
local Window = RvrseUI:CreateWindow({
    Name = "My Hub"
})

local enabled = true
local looping = false
```

### ✅ CORRECT - Use getgenv() for Persistent State
```lua
-- ✅ SAFE - Executor-private global (NOT Roblox's _G!)
if not getgenv().RvrseUI then
    getgenv().RvrseUI = loadstring(game:HttpGet(...))()
end

local RvrseUI = getgenv().RvrseUI

-- Store toggles in getgenv() (NOT _G!)
getgenv().loopEnabled = true

while getgenv().loopEnabled do
    task.wait()
    -- Your loop logic
end

-- To stop:
getgenv().loopEnabled = false
```

### ❌ WRONG - NEVER Do This
```lua
-- ❌ DETECTED - Do NOT use _G!
_G.RvrseUI = loadstring(game:HttpGet(...))()
_G.Window = _G.RvrseUI:CreateWindow(...)
_G.enabled = true
_G.looping = false

-- Roblox can detect and flag all of these!
```

**Key Differences:**

| Storage | Scope | Detection Risk | Use Case |
|---------|-------|----------------|----------|
| `local` | Script-only | None | Most data (recommended) |
| `getgenv()` | Executor-private | None | Persistent toggles/state |
| `_G` | Roblox-global | **HIGH** | **NEVER use!** |

**Rules - NO EXCEPTIONS:**
- ✅ **RvrseUI internally uses ZERO `_G` references** - Verified in build scripts
- ✅ **All examples use `local` variables** - Safe by default
- ✅ **Use `getgenv()` for persistent state** - Executor-private, not detectable
- ❌ **NEVER use `_G` in production scripts** - Instant red flag for anti-cheat
- ❌ **NEVER store UI references in `_G`** - Use local or getgenv()

**Verification:**
```bash
# RvrseUI has ZERO _G usage:
grep -r "_G\." src/ init.lua
# (Returns no results - verified clean)
```

**Full Documentation:**
See [docs/SECURITY.md](docs/SECURITY.md) for complete security best practices, common mistakes, and advanced patterns.

**If you add ANY code that touches `_G`:**
1. **STOP** - You're introducing detection risk
2. **Re-read this section** - Use `getgenv()` instead
3. **Ask yourself:** "Can this be `local` instead?"
4. **Test:** Verify anti-cheat doesn't flag it

---

## 🗒️ Developer Log – v4.3.1 Token Icon Customization

**Date:** 2025-10-20  
**Summary:** The controller chip (minimize token) now uses the shared Lucide icon resolver. Both the global API and per-window API can swap the token icon, tint color, and fallback glyph without touching core source.

- Added `RvrseUI:SetTokenIcon` / `GetTokenIcon` for global overrides that cascade to existing windows.
- Added `Window:SetTokenIcon` / `GetTokenIcon` for per-window adjustments (friendly for executor UIs that want to theme chips independently).
- Controller chip rendering now instantiates the same sprite/text pipeline used by the header buttons; fallbacks show automatically if the Lucide sheet is missing.
- Theme switching re-applies the active token icon color when `UseThemeColor` is true (the default).
- README updated with usage examples; VERSION metadata bumped to v4.3.1 (build 20251020c).

**Regression test checklist**
1. Build with `lua tools/build.lua` and confirm `RvrseUI.lua` header shows v4.3.2.
2. Run `examples/test-lucide-icons.lua` – minimize/restore and verify the token icon matches the chosen Lucide glyph (check `[LUCIDE]` logs).
3. In Studio or executor, run:
   ```lua
   RvrseUI:SetTokenIcon("lucide://sparkles", { Color = Color3.fromRGB(255, 200, 255) })
   local win = RvrseUI:CreateWindow({ Name = "Themed", TokenIcon = "lucide://flame" })
   win:SetTokenIcon(false, { Fallback = "🔥" })
   ```
   Ensure fallback emoji shows when passing `false`, and that theme toggles recolor chips using the accent palette.

## 🗒️ Developer Log – v4.3.0 Lucide Icon Refresh

- Buttons and labels now share the same icon lane logic as tabs/notifications, so `lucide://`, `icon://`, emoji, and `rbxassetid://` inputs render without overlap.
- `IconResolver` gained an image branch for Roblox assets; when a scheme begins with `rbxassetid://` or is numeric, we instantiate an `ImageLabel` instead of a text node.
- The monolith build embeds `_G.RvrseUI_LucideIconsData`, ensuring executors load the sprite atlas even when HttpService is sandboxed.
- Example coverage consolidated into `examples/test-lucide-icons.lua`, which exercises each element using mixed icon sources for fast regression checks.
- README and CLAUDE were refreshed to document the pipeline and provide explicit guidance for regenerating the Lucide dataset.

**Verification checklist**
- ✅ Run `examples/test-lucide-icons.lua` in Studio or your executor (watch for `[LUCIDE]` logs confirming the sprite sheet load).
- ✅ Trigger notifications via the example to ensure toast icons honor the same resolver.
- ✅ Confirm `_G.RvrseUI_LucideIconsData` exists in the global environment when loading the monolith (only during runtime; we do not depend on `_G` for configuration).

### 🚨 Critical Lucide Failure Playbook

If you ever see console output like:

```
⚠️ [RvrseUI] ❌ Failed to load Lucide icons sprite sheet
[LUCIDE] ⚠️ Sprite sheet not loaded, using fallback for: sparkles
```

take the following steps before shipping anything:

1. **Rebuild the bundle.** Run `lua tools/build.lua`. Missing `_G.RvrseUI_LucideIconsData` embeds are the root cause 99% of the time.
2. **Sanity-check the output.** Open the regenerated `RvrseUI.lua` and confirm both the v4.3.0 header and the embedded `_G.RvrseUI_LucideIconsData` block exist.
3. **Run the Lucide smoke test.** Execute `examples/test-lucide-icons.lua` in Studio/executor. Expect `[LUCIDE] ✅ Sprite sheet data loaded successfully` with no fallback spam.
4. **Commit source + monolith together.** Always push the changed `src/` files *and* the rebuilt `RvrseUI.lua`. Skipping one is how this bug resurfaced three times.

Treat this failure as a release blocker. If the test script shows fallbacks, halt the deployment and resolve it immediately.

---

## 🧠 Advanced: Lucide Icon Pipeline

1. **Source data** lives in `src/lucide-icons-data.lua` – generated JSON describing glyphs, sprite UVs, and fallbacks. Treat it as build output; regenerate via `lua tools/generate-lucide-data.lua` when adding SVGs.
2. **Resolver logic** resides in `src/LucideIcons.lua` and `src/Icons.lua`. `LucideIcons.Resolve()` returns sprite metadata or unicode, while `Icons.ResolveIconPayload()` orchestrates the different schemes.
3. **Build step** (`lua tools/build.lua`) loads `lucide-icons-data.lua`, serializes it, and injects `_G.RvrseUI_LucideIconsData` into `RvrseUI.lua` / `init.lua`. This keeps executors offline-friendly.
4. **Element factories** (Button/Label/Notification/Tab) call `Icons.AttachIcon(holder, payload, themeColor)` to create either an ImageLabel (sprites/assets) or TextLabel (emoji/fallbacks) pre-sized with 24px padding.
5. **Testing**: `examples/test-lucide-icons.lua` should be exercised any time icon-related code changes. It covers lucide sprites, unicode fallbacks, emoji, and Roblox assets across tabs, buttons, labels, and notifications.

> **Pro tip:** When importing new Lucide SVGs, resize them to 24×24, run the generator, rebuild the monolith, and double-check the atlas hash in the `[LUCIDE]` console logs to ensure the sprite sheet updated.

---

## 🏗️ Architecture Overview

### File Structure
```
RvrseUI/
├── src/                      # ✅ SOURCE OF TRUTH - Edit these files
│   ├── Version.lua           # Version metadata
│   ├── Debug.lua             # Debug logging system
│   ├── Obfuscation.lua       # Name obfuscation for anti-detection
│   ├── Theme.lua             # Dark/Light palettes
│   ├── Animator.lua          # Spring animations
│   ├── State.lua             # Global state management
│   ├── UIHelpers.lua         # UI utility functions
│   ├── Icons.lua             # Legacy emoji/icon resolver + helpers
│   ├── LucideIcons.lua       # Lucide sprite resolver + Unicode fallbacks
│   ├── lucide-icons-data.lua # Generated Lucide atlas metadata (auto-built)
│   ├── Config.lua            # Persistence system
│   ├── WindowManager.lua     # Multi-window coordination
│   ├── Overlay.lua           # Overlay layer management (dropdowns, blockers)
│   ├── Notifications.lua     # Toast notification system
│   ├── Hotkeys.lua           # Global hotkey management
│   ├── KeySystem.lua         # 🔐 Advanced key validation system
│   ├── Particles.lua         # Organic particle effects
│   ├── SectionBuilder.lua    # Section construction
│   ├── TabBuilder.lua        # Tab construction
│   ├── WindowBuilder.lua     # Main window construction
│   └── Elements/             # All UI elements
│       ├── Button.lua
│       ├── Toggle.lua
│       ├── Dropdown.lua
│       ├── Slider.lua
│       ├── Keybind.lua
│       ├── TextBox.lua
│       ├── ColorPicker.lua
│       ├── Label.lua
│       ├── Paragraph.lua
│       └── Divider.lua
├── init.lua                  # ✅ Modular entry point (bootstrap logic)
├── tools/build.lua                  # ✅ Luau build script
├── 
├── RvrseUI.lua               # ❌ GENERATED - Never edit directly!
├── VERSION.json              # Version metadata & changelog
├── README.md                 # User-facing documentation
└── CLAUDE.md                 # This file (maintainer guide)
```

### Two Entry Points, Same Result

**1. Modular Mode** (`init.lua`)
- Used during development
- `require(script.init)` loads all modules separately
- Bootstrap logic lives in `init.lua`

**2. Monolith Mode** (`RvrseUI.lua`)
- Used for distribution via `loadstring(game:HttpGet(...))()`
- **Generated by build scripts** - combines all `src/` modules into one file
- **Now embeds the same bootstrap as `init.lua`** (as of v3.0.4)

---

## ⚙️ Build System Deep Dive

### How The Build Works

**`tools/build.lua` (Luau packer) perform these steps:**

1. **Read all modules** from `src/` in dependency order (30 modules total)
2. **Strip module headers** (comment lines starting with `--`)
3. **Convert local declarations to globals**: `local Module = {}` → `Module = {}`
4. **Remove shadowing declarations**: Any `local RvrseUI` that would conflict
5. **Remove return statements**: `return ModuleName` at end of files
6. **Wrap in scoping blocks**: Each module wrapped in `do...end` block with indentation
7. **Initialize modules**: Bootstrap logic from `init.lua` (services, overlay, notifications)
8. **Inject RvrseUI public API**: 200+ lines from `init.lua` embedded at end
9. **Add return statement**: `return RvrseUI` so `loadstring()` works

**Exact module compilation order:**
```
Foundation: Version → Debug → Obfuscation
Visual Data: Theme → Icons → LucideIcons → (lucide-icons-data injected by build)
Core Systems: Animator → State → UIHelpers
Services: Config → WindowManager → Hotkeys → Notifications → KeySystem → Overlay
Visual FX: Particles
Elements: Button → Toggle → Dropdown → Slider → Keybind → TextBox → ColorPicker → Label → Paragraph → Divider
Builders: SectionBuilder → TabBuilder → WindowBuilder
```

**Module count: 30 total** (includes LucideIcons + Particles pipeline)

### Critical Build Rules

#### ✅ DO:
- Edit files in `src/` or `init.lua`
- Run `lua tools/build.lua` after EVERY source change
- Commit both source files AND regenerated `RvrseUI.lua` together
- Test the compiled `RvrseUI.lua` in Roblox before pushing

#### ❌ DON'T:
- **NEVER** edit `RvrseUI.lua` directly
- **NEVER** skip the rebuild step
- **NEVER** commit source changes without rebuilding
- **NEVER** modify build scripts without understanding full impact

### Why Variable Scoping Matters

When compiling into ONE file, all modules share the same global scope:

```lua
-- ❌ BAD: This creates variable shadowing
local RvrseUI = {}        -- Line 24 (main table)
-- ... 1000 lines later ...
local RvrseUI = nil       -- Line 1728 (Notifications module)
-- ❌ This shadows the first one! Now RvrseUI is nil!
```

**Solution:** Build scripts remove conflicting `local RvrseUI` declarations:
```javascript
content.replace(/^local RvrseUI.*$/gm, '-- [Removed conflicting local RvrseUI]');
```

---

## 🚨 Common Pitfalls & How We Fixed Them

### Mistake #1: Module Declarations Removed Entirely
**What Happened (v3.0.4 initial build):**
```javascript
// ❌ BROKEN - Removed entire declaration
content.replace(/local ([A-Z][A-Za-z]+) = \{\}/g, '');
// Result: "local Version = {}" → "" (nothing!)
// Error: :33: attempt to index function with 'Data'
```

**Fix:**
```javascript
// ✅ FIXED - Convert to global, keep declaration
content.replace(/^local ([A-Z][A-Za-z]+) = \{\}/gm, '$1 = {}');
// Result: "local Version = {}" → "Version = {}"
```

### Mistake #2: Missing Public API
**What Happened:**
- Build compiled all modules but never added RvrseUI methods
- `loadstring()` returned an empty `{}` table
- Error: `:12: attempt to index nil with 'EnableDebug'`

**Fix:**
- Extracted 200+ line API wrapper from `init.lua` (lines 162-350)
- Embedded it at the end of the build, before `return RvrseUI`
- All 24 public methods now properly exported

### Mistake #3: Variable Shadowing
**What Happened:**
- Notifications module had `local RvrseUI` at module level
- When compiled into one file, this shadowed main `local RvrseUI = {}`
- Error: `:5206: attempt to index nil with 'Version'`

**Fix:**
- Build scripts now remove all conflicting `local RvrseUI` declarations
- Only ONE `local RvrseUI = {}` exists (at line 24)

---

## 📋 Strict Development Workflow

### Making Source Changes

```bash
# 1. Edit source files
vim src/WindowBuilder.lua

# 2. Rebuild the monolith
lua tools/build.lua

# 3. Test in Roblox
# Load the generated RvrseUI.lua and verify changes work

# 4. Commit both source and compiled together
git add src/WindowBuilder.lua RvrseUI.lua
git commit -m "feat: add feature X"
git push origin main
```

### Version Bumps (Complete Checklist)

When releasing a new version, update ALL these files:

```bash
# 1. VERSION.json
{
  "version": {
    "patch": 4,           # Increment
    "full": "3.0.4",      # Update
    "build": "20251010",  # YYYYMMDD
    "hash": "K7M3P9X1"    # New random hash
  },
  "changelog": {
    "3.0.4": {            # Add new entry
      "changes": [...]
    }
  }
}

# 2. README.md
![Version](https://img.shields.io/badge/version-3.0.4-blue)
local VERSION = "v3.0.4"

# 3. CLAUDE.md (header)
# RvrseUI – Maintainer Notes (v4.0.0)

# 4. src/Version.lua
Version.Data = {
  Patch = 4,
  Full = "3.0.4",
  Build = "20251010",
  Hash = "K7M3P9X1"
}

# 5. tools/build.lua (version banners)
console.log('🔨 RvrseUI v3.0.4 Build Script');
const header = `-- RvrseUI v3.0.4 | Modern Professional UI Framework

# 6. Rebuild
lua tools/build.lua

# 7. Commit everything together
git add VERSION.json README.md CLAUDE.md src/Version.lua tools/build.lua tools/build.lua RvrseUI.lua
git commit -m "chore: bump version to v3.0.4"
git push origin main
```

**⚠️ The pre-push hook will block if version files are inconsistent!**

---

## 🔧 Module-Specific Rules

### Configuration Persistence Lockdown
- Save/load now routes through the live `RvrseUI` context (`src/Config.lua`) so every flagged element serializes correctly.
- Theme cache (`_savedTheme`) is synced back to the active window; do not strip this hand-off.
- Boolean `ConfigurationSaving = true` reuses the last profile by splitting `folder/file.json`; keep this parsing intact.
- `ConfigurationSaving.AutoSave = false` disables background writes; keep `_autoSave` guard in sync if you extend persistence.
- Profiles tab auto-injects when configuration saving is enabled; customise via `ConfigurationManager` or disable it entirely when embedding bespoke controls.
- When touching persistence code, verify the executor supports `writefile/readfile/isfile` and rerun a full save → load cycle with all 12 elements.

### Profiles Tab Behaviours
- Dropdown always re-scans on open and after Save/Save As/Delete; do not reintroduce cached lists.
- `SetConfigProfile` now updates the in-memory context and `_lastContext`; keep this when adding profile shortcuts.
- Deleting the active profile clears selection and labels—ensure any future UI also handles this case.
- Auto-save toggle mirrors `RvrseUI:SetAutoSaveEnabled`; avoid writing alternate toggles that bypass the guard.

### Window & Chip Drag System (v3.0.4)
- **Advanced cursor-locked drag** with grab-offset caching ensures cursor stays glued to exact grab point
- Window header drag handles GUI inset for all host types (`IgnoreGuiInset = true/false`)
- Controller chip drag uses `AnchorPoint (0.5, 0.5)` for center-based positioning
- Both systems use sub-pixel precision: `math.floor(value + 0.5)`
- Debug logging throughout: `Debug.printf("[DRAG] ...")` and `Debug.printf("[CHIP DRAG] ...")`
- If you change the host container, update inset logic in `WindowBuilder` accordingly

### Overlay Layer & Dropdowns (`src/Overlay.lua`)
- Dedicated `Overlay` module manages the overlay layer, initialized in both `init.lua` and the monolith bootstrap.
- `Overlay:Initialize()` creates `RvrseUI_Overlay` Frame with `ZIndex = 20000` on a separate ScreenGui.
- `Overlay:GetLayer()` returns the overlay Frame for dropdown/popup parenting.
- Dropdown element default is `Overlay = true`; set `Overlay = false` for legacy inline menus.
- Overlay mode requires the blocker to close menus—preserve `ensureBlocker()` and `setOpen(false)` patterns when extending.
- The overlay layer is kept transparent and hidden when idle; dropdowns show/hide it as needed.
- When adding new overlay elements, use `deps.OverlayLayer` (from WindowBuilder) to ensure consistent z-ordering.

### Lucide Icon System (`src/LucideIcons.lua` + `src/Icons.lua`) - v4.3.0
- **Atlas-backed sprites**: `lucide://` icons resolve through `_G.RvrseUI_LucideIconsData` injected at build time, so executors load the sheet without extra HTTP calls.
- **Unified spacing**: Buttons, labels, tabs, and notifications reserve a 24px lane for sprites/fallbacks—no more text overlap when Unicode glyphs are used.
- **Asset overrides**: Map uploaded Roblox images via `LucideIcons.AssetMap` to swap any Lucide glyph for a bespoke asset.
  ```lua
  LucideIcons.AssetMap = {
      ["sparkles"] = 16364871493,  -- Roblox `rbxassetid://` id
      ["home"] = "rbxassetid://123456789"
  }
  ```
- **Resolution order**:
  1. `rbxassetid://` or numeric asset → ImageLabel (no fallback)
  2. `LucideIcons.AssetMap` override → ImageLabel
  3. Lucide atlas glyph → ImageLabel with theme tinting
  4. Unicode fallback → TextLabel (icon://, emoji, or configured fallback)
  5. Raw text → When nothing else matches
- **Supported schemes** (all elements): `lucide://home`, `icon://star`, `"🔥"`, `rbxassetid://16364871493`, `"16364871493"`.
- **Testing**: `examples/test-lucide-icons.lua` exercises tabs, notifications, buttons, and labels with all schemes. Run it after any icon-related change.
- **Maintenance**: Regenerate `src/lucide-icons-data.lua` via `tools/generate-lucide-data.lua` whenever new SVGs are imported; rebuild the monolith immediately after.

### Monolith Build Pipeline
- `tools/build.lua` (Luau packer) wrap each module in a `do ... end` scope with tab indentation before concatenation.
- Bootstrap logic from `init.lua` is embedded into the monolith (lines 138-232 of build scripts):
  - Initializes all modules in dependency order
  - Creates `DEFAULT_HOST` ScreenGui (DisplayOrder = 999)
  - Creates `DEFAULT_OVERLAY` Frame (ZIndex = 20000) via inline code (Overlay module not used in bootstrap)
  - Initializes Notifications, Hotkeys, WindowManager
  - Sets up Elements table with all 11 element types
- The compiled `RvrseUI.lua` is standalone: safe to `loadstring()` without external dependencies.
- Any edits in `src/` or `init.lua` must be followed by `lua tools/build.lua` to keep the monolith aligned.
- **NEVER patch `RvrseUI.lua` directly** - it will be overwritten on next build.
- The compiled file caches `DEFAULT_HOST` / `DEFAULT_OVERLAY`. If destroyed manually, `RvrseUI:CreateWindow` recreates them (lines 293-300 of build scripts).
- Version bumps require updating `VERSION.json`, README badge, CLAUDE.md header, and rerunning build for timestamp update.

### Hotkey Pipeline
- `Hotkeys:Initialize` immediately wires `InputBegan` and prevents double hookups. Ensure any future hotkey changes toggle `_initialized` carefully.

### KeySystem (`src/KeySystem.lua`) - v4.0.0 NEW!
- **737-line advanced key validation system** with multiple authentication methods
- Blocks `CreateWindow` execution until key validated or max attempts exhausted
- **CRITICAL**: All animations use `Animator:Tween()` not `Animator:Spring()` (Spring is a table, not method!)
- Theme colors accessed via `deps.Theme:Get()` which returns the palette table (not `Theme.Current` which is a string!)
- Obfuscation uses `:Generate()` method, not `:Obfuscate()`

#### Key System Architecture
- **UI Design**: 500px wide container, gradient header with 🔐 icon, animated rotating border gradient, modern rounded corners (16px)
- **Validation Methods** (4 types):
  1. Simple string key (`Key = "string"`) - Rayfield compatible
  2. Multiple keys (`Keys = {"key1", "key2"}`) - RvrseUI extension
  3. HWID/User ID whitelist (`Whitelist = {"123", "HWID-ABC"}`)
  4. Custom validator function (`Validator = function(key) return boolean end`)
- **Remote Key Fetching**: `GrabKeyFromSite = true` + URL in `Key` parameter
- **File Persistence**: Saves validated keys to `RvrseUI/KeySystem/{FileName}.key`
- **Attempt Limiting**: Configurable `MaxAttempts` (default 3)
- **Graceful Failure**: Returns dummy window object on validation failure (prevents script crashes)
- **Discord Logging**: Optional webhook integration logs all attempts with user info
- **Callbacks**: `OnKeyValid`, `OnKeyInvalid`, `OnAttemptsExhausted` for custom behavior

#### Integration with WindowBuilder
- KeySystem validation runs **BEFORE** window creation in `WindowBuilder:CreateWindow()`
- If validation fails and `KickOnFailure = false`, a **dummy window object** is returned with no-op methods
- Dummy window prevents `attempt to index nil` errors when user script tries to call `Window:CreateTab()`
- All dummy methods return empty tables so script continues without crashing
- Warning logged: `[RvrseUI] Key validation failed - Window creation blocked`

#### Common KeySystem Pitfalls
1. **Animation Method Error** - Use `Animator:Tween(obj, props, info)` not `Animator:Spring()`
2. **Theme Access** - Use `deps.Theme:Get()` to get color palette table
3. **Color Properties** - Theme palette uses: `Bg`, `Text`, `TextSub`, `TextMuted`, `Surface`, `Accent`, `AccentHover`, `Success`, `Error`, `Warning`
4. **Nil Message Handling** - Always use `tostring(message or "default")` when logging validation results
5. **Dummy Window Pattern** - Must return full dummy object tree (Window → Tab → Section → Elements) to prevent crashes

#### KeySystem Testing
```lua
-- Test lockout behavior (wrong keys)
RvrseUI:CreateWindow({
    KeySystem = true,
    KeySettings = {
        Keys = {"TestKey123"},
        MaxAttempts = 3,
        KickOnFailure = false,  -- Don't kick to test dummy window
        OnKeyInvalid = function(key, attemptsLeft)
            print("❌ INVALID:", key, "| Left:", attemptsLeft)
        end,
        OnAttemptsExhausted = function()
            print("⚠️ LOCKOUT! No attempts remaining")
        end
    }
})
-- Enter 3 wrong keys → Lockout → Dummy window returned → Script continues
```

### Debug & Version Helpers
- `Debug.printf` is relied on throughout `WindowBuilder`; keep it exported when refactoring the debug module.
- `Version` exposes fields via metatable—always update `Version.Data` rather than reassigning properties directly.

### Dependency Injection Pattern
- **All builders use dependency injection** via `Initialize(deps)` method.
- The `deps` table is assembled in `init.lua` (lines 126-152) and contains:
  - Modules: Theme, Animator, State, Config, UIHelpers, Icons, etc.
  - Services: UserInputService, GuiService, RunService, TweenService, HttpService
  - Builders: TabBuilder, SectionBuilder, WindowBuilder
  - Elements: Table of all 11 element constructors
  - OverlayLayer: Reference to overlay Frame
- **In the monolith**, deps is constructed inline in `RvrseUI:CreateWindow()` (build scripts lines 247-269).
- **NEVER use global lookups** in modules - always accept dependencies via Initialize or function parameters.
- When adding new modules, follow the pattern:
  ```lua
  local Module = {}
  local deps

  function Module:Initialize(dependencies)
      deps = dependencies
  end

  function Module:DoSomething()
      -- Use deps.Theme, deps.Animator, etc.
      deps.Theme:Switch("Dark")
  end
  ```

---

## 🧪 Testing & Validation

### Quick Validation Checklist
1. Toggle each element flag, call `SaveConfiguration`, restart script, confirm values restore.
2. If auto-save is disabled, ensure manual saves still write expected profiles.
3. Minimize to the 🎮 chip, drag around edges, restore, then destroy via `Escape`.
4. Open dropdowns on top of dense layouts and verify overlay blockers close them.
5. Confirm `ToggleUIKeybind` still acts globally after any hotkey changes.
6. Run docs build (README badge/version) when bumping releases.

### Testing Drag Systems
```lua
-- Enable debug mode to see drag logging
RvrseUI:EnableDebug(true)

-- Test window header drag
-- 1. Click anywhere on the header
-- 2. Drag - cursor should stay locked to exact grab point
-- 3. Check console for: "[DRAG] Cached offset: X=..., Y=..."

-- Test controller chip drag
-- 1. Minimize window
-- 2. Click on 🎮 chip
-- 3. Drag - chip should follow cursor perfectly from grab point
-- 4. Check console for: "[CHIP DRAG] Cached grab offset: X=..., Y=..."
```

---

## 🚑 Troubleshooting Common Errors

### Error: `attempt to index function with 'Data'`
**Cause:** Module declaration was removed entirely
**Fix:** Check build scripts convert `local Module = {}` → `Module = {}`

### Error: `attempt to index nil with 'EnableDebug'`
**Cause:** RvrseUI public API not embedded in build
**Fix:** Verify build scripts include the `rvrseUIAPI` wrapper before `return RvrseUI`

### Error: `attempt to index nil with 'Version'`
**Cause:** Variable shadowing - conflicting `local RvrseUI` declarations
**Fix:** Build scripts should remove all `local RvrseUI` except the main one on line 24

### Build Produces 0 KB File
**Cause:** Syntax error in source or build script
**Fix:** Check build script output for errors, verify all modules compile individually

### Changes Don't Appear After Rebuild
**Cause:** Cached old version or didn't rebuild
**Fix:** Run `lua tools/build.lua` again, check file timestamp, clear Roblox cache

---

## 🎯 AI Assistant Guidelines

If you're an AI (like Claude or GPT) working on this project:

### BEFORE Making Changes:
1. ✅ Read `CLAUDE.md` (this file) completely
2. ✅ Read `README.md` to understand user-facing features
3. ✅ Check `VERSION.json` for current version and changelog
4. ✅ Review the specific `src/` files you plan to modify

### WHEN Making Changes:
1. ✅ Only edit files in `src/` or `init.lua`
2. ✅ Never directly edit `RvrseUI.lua`
3. ✅ Always rebuild after source changes: `lua tools/build.lua`
4. ✅ Test the compiled output before committing
5. ✅ Commit source + compiled together

### AFTER Making Changes:
1. ✅ Verify the build produced no errors
2. ✅ Check file size is reasonable (~150 KB)
3. ✅ Test in Roblox if possible
4. ✅ Update version files if releasing
5. ✅ Document breaking changes in VERSION.json changelog

### RED FLAGS (Stop and Ask):
- 🚨 You want to edit `RvrseUI.lua` directly
- 🚨 You want to skip the rebuild step
- 🚨 You're adding `local RvrseUI` anywhere
- 🚨 You're modifying build script regex without testing
- 🚨 You're changing module initialization order
- 🚨 You're removing or renaming `Debug.printf` calls

---

## 📚 Additional Resources

- **User Documentation:** `README.md`
- **Version History:** `VERSION.json` (changelog section)
- **Archived Tests:** `docs/__archive/2025-10-09/TEST_ALL_FEATURES.lua`
- **GitHub Repository:** https://github.com/CoderRvrse/RvrseUI
- **GitHub Issues:** https://github.com/CoderRvrse/RvrseUI/issues

## 🛠️ Common Development Commands

### Building the Monolith
```bash
# Build with Node.js (preferred)
lua tools/build.lua

# Build with Lua (fallback)
lua tools/build.lua
```

### Testing
```bash
# Test in Roblox Studio
# 1. Load init.lua as a ModuleScript under ReplicatedStorage
# 2. Require it from a LocalScript
# 3. Verify all features work

# Test compiled monolith
# 1. Copy RvrseUI.lua content
# 2. Use loadstring(game:HttpGet(...))() in Roblox
# 3. Verify all features work
```

### Version Management
```bash
# Update version across all files (manual process)
# 1. Edit VERSION.json (version.patch, version.full, version.build, version.hash)
# 2. Edit README.md (badge and example code)
# 3. Edit CLAUDE.md (header)
# 4. Edit src/Version.lua (Version.Data table)
# 5. Edit tools/build.lua (header comments)
# 6. Run: lua tools/build.lua
# 7. Commit all changes together
```

### Git Workflow
```bash
# Standard workflow
git add src/ModuleName.lua RvrseUI.lua  # Always commit source + compiled together
git commit -m "feat: description"
git push origin main

# Version release workflow
git add VERSION.json README.md CLAUDE.md src/Version.lua tools/build.lua tools/build.lua RvrseUI.lua
git commit -m "chore: bump version to v3.0.X"
git push origin main
```

---

## 🔒 Final Reminder

> **This project has a sophisticated build system that can break in subtle ways.**
> **Follow the documented workflow strictly.**
> **When in doubt, ask before changing core files.**
> **Test thoroughly before pushing to main.**

**Last Updated:** 2026-10-07 (v4.5.1 - Window:SelectTab)

---

## 📊 Module Statistics

- **Total Modules:** 31 (FilterableList added in v4.4.0)
  - Foundation: 3 (Version, Debug, Obfuscation)
  - Visual Data: 4 (Theme, Icons, LucideIcons, lucide-icons-data)
  - Core Systems: 3 (Animator, State, UIHelpers)
  - Services: 6 (Config, WindowManager, Overlay, Notifications, Hotkeys, KeySystem)
  - Visual FX: 1 (Particles)
  - Elements: 11 (Button, Toggle, Dropdown, Slider, Keybind, TextBox, ColorPicker, Label, Paragraph, Divider, FilterableList)
  - Builders: 3 (SectionBuilder, TabBuilder, WindowBuilder)
- **Element Count:** 11 UI elements
- **Total Lines (compiled):** ~6,500 lines in RvrseUI.lua
- **File Size:** ~450 KB (RvrseUI.lua monolith)
