#!/usr/bin/env node
// BUILD_MONOLITHIC.js
// Properly compiles modular architecture into single RvrseUI.lua file
// This inlines all require() calls while preserving init logic

const fs = require('fs');
const path = require('path');

console.log('🔨 RvrseUI v3.0.2 Monolithic Build Script');
console.log('='.repeat(60));

// Read init.lua as the template
console.log('📖 Reading init.lua template...');
let initContent = fs.readFileSync('init.lua', 'utf8');

// Header for compiled file
const header = `-- RvrseUI v3.0.2 | Modern Professional UI Framework
-- Compiled from modular architecture on ${new Date().toISOString().split('T')[0]}
-- Source: https://github.com/CoderRvrse/RvrseUI

-- Features: Glassmorphism, Spring Animations, Mobile-First Responsive, Touch-Optimized
-- API: CreateWindow → CreateTab → CreateSection → {All 12 Elements}
-- Extras: Notify system, Theme switcher, LockGroup system, Drag-to-move, Auto-scaling
-- Architecture: 26 modules compiled into single file for loadstring() usage

-- 💡 For modular version (development), use: require(script.init)
-- 💡 For single-file version (production), use: loadstring(game:HttpGet(...))()

`;

// Modules to inline (in dependency order)
const modules = [
	{ name: 'Version', path: 'src/Version.lua' },
	{ name: 'Debug', path: 'src/Debug.lua' },
	{ name: 'Obfuscation', path: 'src/Obfuscation.lua' },
	{ name: 'Icons', path: 'src/Icons.lua' },
	{ name: 'Theme', path: 'src/Theme.lua' },
	{ name: 'Animator', path: 'src/Animator.lua' },
	{ name: 'State', path: 'src/State.lua' },
	{ name: 'UIHelpers', path: 'src/UIHelpers.lua' },
	{ name: 'Config', path: 'src/Config.lua' },
	{ name: 'WindowManager', path: 'src/WindowManager.lua' },
	{ name: 'Hotkeys', path: 'src/Hotkeys.lua' },
	{ name: 'Notifications', path: 'src/Notifications.lua' },
	{ name: 'Button', path: 'src/Elements/Button.lua' },
	{ name: 'Toggle', path: 'src/Elements/Toggle.lua' },
	{ name: 'Dropdown', path: 'src/Elements/Dropdown.lua' },
	{ name: 'Slider', path: 'src/Elements/Slider.lua' },
	{ name: 'Keybind', path: 'src/Elements/Keybind.lua' },
	{ name: 'TextBox', path: 'src/Elements/TextBox.lua' },
	{ name: 'ColorPicker', path: 'src/Elements/ColorPicker.lua' },
	{ name: 'Label', path: 'src/Elements/Label.lua' },
	{ name: 'Paragraph', path: 'src/Elements/Paragraph.lua' },
	{ name: 'Divider', path: 'src/Elements/Divider.lua' },
	{ name: 'SectionBuilder', path: 'src/SectionBuilder.lua' },
	{ name: 'TabBuilder', path: 'src/TabBuilder.lua' },
	{ name: 'WindowBuilder', path: 'src/WindowBuilder.lua' },
];

console.log(`\n📦 Processing ${modules.length} modules...`);

// Function to wrap module code
function wrapModule(moduleName, moduleCode) {
	// Remove module header comments
	moduleCode = moduleCode.replace(/^--[^\n]*\n/gm, '');

	// Remove the final "return ModuleName" statement
	moduleCode = moduleCode.replace(/\nreturn\s+\w+\s*$/m, '');

	return `-- ============================================
-- ${moduleName} Module (Inlined)
-- ============================================
local ${moduleName} = (function()
${moduleCode.trim()}

	return ${moduleName}
end)()

`;
}

// Process each module
let inlinedModules = '';
modules.forEach((module, index) => {
	console.log(`  [${index + 1}/${modules.length}] ${module.name}`);

	try {
		const moduleCode = fs.readFileSync(module.path, 'utf8');
		inlinedModules += wrapModule(module.name, moduleCode);
	} catch (err) {
		console.error(`❌ Failed to read ${module.path}:`, err.message);
		process.exit(1);
	}
});

console.log('\n✅ All modules processed successfully!');
console.log('\n🔧 Assembling final file...');

// Now replace all require() calls in init.lua with inline declarations
// Pattern: local ModuleName = require(script.src.ModuleName)
// Replace with: (already defined above)

// Remove all require statements since we've inlined them
initContent = initContent.replace(/local \w+ = require\(script\.src\.\w+\)/g, '-- (module inlined above)');
initContent = initContent.replace(/local \w+ = require\(script\.src\.Elements\.\w+\)/g, '-- (module inlined above)');

// Remove the import section header since modules are now inline
initContent = initContent.replace(/-- ============================================\n-- IMPORT ALL MODULES\n-- ============================================\n/g, '');

// Remove empty lines created by replacements
initContent = initContent.replace(/\n\n\n+/g, '\n\n');

// Build final file
const finalCode = header + inlinedModules + initContent;

// Write output
console.log('💾 Writing RvrseUI.lua...');
fs.writeFileSync('RvrseUI.lua', finalCode, 'utf8');

// Get file stats
const stats = fs.statSync('RvrseUI.lua');
const sizeKB = Math.floor(stats.size / 1024);
const lines = finalCode.split('\n').length;

console.log('\n' + '='.repeat(60));
console.log('✅ BUILD COMPLETE!');
console.log('='.repeat(60));
console.log(`📦 Output: RvrseUI.lua`);
console.log(`📊 Size: ${sizeKB} KB`);
console.log(`📏 Lines: ${lines}`);
console.log(`🔧 Modules: ${modules.length} inlined`);
console.log('\n🚀 Ready for production use!');
console.log('\n📝 Next steps:');
console.log('  1. Test: Run TEST_ALL_FEATURES.lua in Roblox Studio');
console.log('  2. Verify: All 12 elements work correctly');
console.log('  3. Push: git add RvrseUI.lua && git commit && git push');
console.log('\n💡 Usage in Roblox:');
console.log('  loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderRvrse/RvrseUI/main/RvrseUI.lua?" .. tick()))()');
