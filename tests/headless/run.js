// tests/headless/run.js
// Runs the built RvrseUI.lua headless inside a strict fake Roblox client
// (roblox_mock.lua) and checks that closing a window leaves nothing behind:
// no live connections, no ScreenGuis, no errors. Each scenario in
// lifecycle_driver.lua runs in its own fresh `luau` process.
//
// Usage:
//   node tests/headless/run.js                       # ./RvrseUI.lua, all scenarios
//   node tests/headless/run.js path/to/RvrseUI.lua   # another build
//   node tests/headless/run.js RvrseUI.lua x,two     # chosen scenarios
//
// Needs the `luau` CLI (https://github.com/luau-lang/luau/releases) on PATH,
// or its path in the LUAU environment variable. Exit code 0 = all PASS.

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const here = __dirname;
const uiPath = path.resolve(process.argv[2] || path.join(here, '..', '..', 'RvrseUI.lua'));
const mock = fs.readFileSync(path.join(here, 'roblox_mock.lua'), 'utf8');
const driver = fs.readFileSync(path.join(here, 'lifecycle_driver.lua'), 'utf8');
const ui = fs.readFileSync(uiPath, 'utf8');
const luau = process.env.LUAU || 'luau';

const declared = driver.match(/--\s*SCENARIOS:\s*([\w,-]+)/);
const scenarios = (process.argv[3] || (declared ? declared[1] : 'x')).split(',').filter(Boolean);

// Embed RvrseUI.lua as a long string whose bracket level it never uses.
let level = 1;
while (ui.includes(']' + '='.repeat(level) + ']')) level++;
const open = '[' + '='.repeat(level) + '[';
const close = ']' + '='.repeat(level) + ']';

// ── Source guard: no new always-on print ──────────────────────────────
// A bare print( in src/ shows in every user's console. Diagnostics go through
// Debug.printf or a module's gated dprint; the lines below are the only bare
// prints allowed (gated helpers, lines inside a debug check, status messages).
const ALLOWED_PRINTS = {
    'src/Debug.lua': ['print("[RvrseUI]", ...)'],
    'src/Overlay.lua': ['print(...)'],
    'src/Hotkeys.lua': ['print(...)'],
    'src/Elements/ColorPicker.lua': ['print(...)'],
    'src/Elements/Keybind.lua': [
        'print("[KEYBIND] UI Toggle key updated to:", io.KeyCode.Name)',
        'print("[KEYBIND] UI Escape key updated to:", io.KeyCode.Name)',
    ],
    'src/Particles.lua': [
        'print("[Particles] Initialized with Perlin noise")',
        'print("[Particles] Layer set:", layer and "active" or "nil")',
        'print(string.format("[Particles] Playing - State: %s | Target count: %d | FPS: %.1f",',
        'print("[Particles] Stopped - Fast fade:", fastFade or false)',
        'print("[Particles] State changed:", currentState)',
        'print("[Particles] Config updated:", key, "=", value)',
    ],
    // Only the gated dprint helper. The two status lines that used to sit here
    // ("Successfully mounted to CoreGui", "All interfaces destroyed") printed in
    // every user's console on every launch and now go through dprint.
    'src/WindowManager.lua': ['print(...)'],
    // WindowBuilder has no allowed bare print any more: the status lines go
    // through Debug.printf, and the two real failures (a config that would not
    // load, a Notify that threw) go through warn(), which is Roblox's channel
    // for a problem rather than a line in everyone's output.
};
function luaFiles(dir) {
    return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
        const full = path.join(dir, entry.name);
        return entry.isDirectory() ? luaFiles(full) : entry.name.endsWith('.lua') ? [full] : [];
    });
}
function strayPrints(root) {
    const stray = [];
    for (const file of luaFiles(path.join(root, 'src'))) {
        const rel = path.relative(root, file).split(path.sep).join('/');
        const left = [...(ALLOWED_PRINTS[rel] || [])];
        fs.readFileSync(file, 'utf8').split(/\r?\n/).forEach((line, index) => {
            const code = line.trim();
            if (code.startsWith('--') || !/(^|[^.:\w])print\(/.test(code)) return;
            const at = left.indexOf(code);
            if (at >= 0) left.splice(at, 1);
            else stray.push(`${rel}:${index + 1}: ${code}`);
        });
    }
    return stray;
}

console.log(`RvrseUI headless lifecycle test: ${uiPath}`);
let allPass = true;
const stray = strayPrints(path.join(here, '..', '..'));
console.log(`--- source guard (no always-on print in src/): ${stray.length === 0 ? 'PASS' : 'FAIL'}`);
for (const line of stray) {
    console.log(`   ${line}`);
}
if (stray.length > 0) {
    console.log('   Send a diagnostic through Debug.printf or a gated dprint; a deliberate status line goes in ALLOWED_PRINTS.');
    allPass = false;
}

// The version is written down TWICE -- in src/Version.lua, which is what every
// hub and every player actually sees, and in VERSION.json, which is what the
// release notes and the changelog are read from. Nothing kept them equal, and
// they have drifted before.
//
// Two copies of one fact with no gate between them is the single bug shape this
// project keeps paying for: a stale copy is silent, looks fine locally, and is
// only noticed once it is live. A mismatch here is cheap to catch and cheap to
// fix, so catch it.
const versionDrift = (() => {
    const root = path.join(here, '..', '..');
    let lua, json;
    try {
        lua = fs.readFileSync(path.join(root, 'src', 'Version.lua'), 'utf8');
        json = JSON.parse(fs.readFileSync(path.join(root, 'VERSION.json'), 'utf8'));
    } catch (e) {
        return [`could not read both version files: ${e.message}`];
    }
    // Read one field out of the Version.Data table. Deliberately no regex:
    // a pattern built from a string has to survive the escaping of whatever
    // writes this file, and it already silently matched nothing once, which
    // made the guard report every field as missing instead of comparing it.
    const field = (name) => {
        for (const raw of lua.split(String.fromCharCode(10))) {
            const line = raw.trim();
            if (!line.startsWith(name)) continue;
            const rest = line.slice(name.length).trim();
            if (!rest.startsWith('=')) continue;
            let value = rest.slice(1).trim();
            const comment = value.indexOf('--');
            if (comment >= 0) value = value.slice(0, comment).trim();
            if (value.endsWith(',')) value = value.slice(0, -1).trim();
            if (value.length >= 2 && value[0] === '"' && value[value.length - 1] === '"') {
                value = value.slice(1, -1);
            }
            return value;
        }
        return null;
    };

    const v = json.version || {};
    const pairs = [
        ['Full', field('Full'), v.full],
        ['Major', field('Major'), v.major === undefined ? undefined : String(v.major)],
        ['Minor', field('Minor'), v.minor === undefined ? undefined : String(v.minor)],
        ['Patch', field('Patch'), v.patch === undefined ? undefined : String(v.patch)],
        ['Build', field('Build'), v.build],
        ['Hash', field('Hash'), v.hash],
        ['Channel', field('Channel'), v.channel],
    ];
    const bad = [];
    for (const [name, inLua, inJson] of pairs) {
        if (String(inLua) !== String(inJson)) {
            bad.push(`${name}: src/Version.lua says ${inLua}, VERSION.json says ${inJson}`);
        }
    }
    // Full must also agree with its own parts, or GetString and Check disagree.
    const parts = `${field('Major')}.${field('Minor')}.${field('Patch')}`;
    if (field('Full') !== parts) {
        bad.push(`Full is ${field('Full')} but Major.Minor.Patch is ${parts}`);
    }
    return bad;
})();
console.log(`--- version guard (src/Version.lua matches VERSION.json): ${versionDrift.length === 0 ? 'PASS' : 'FAIL'}`);
for (const line of versionDrift) {
    console.log(`   ${line}`);
}
if (versionDrift.length > 0) {
    console.log('   Change BOTH files together: Version.lua is what players see, VERSION.json is what the changelog is read from.');
    allPass = false;
}
for (const scenario of scenarios) {
    const source = [
        'local M = (function()',
        mock,
        'end)()',
        `local RVRSEUI_SRC = ${open}\n${ui}${close}`,
        'local HUB_SRC = ""',
        `local H_SCENARIO = "${scenario}"`,
        "M.httpRoutes['CoderRvrse/RvrseUI'] = RVRSEUI_SRC",
        "M.chunkNames[RVRSEUI_SRC] = '=RvrseUI'",
        driver,
    ].join('\n');
    const file = path.join(os.tmpdir(), `rvrseui-headless-${scenario}.lua`);
    fs.writeFileSync(file, source);

    const run = spawnSync(luau, [file], { encoding: 'utf8', timeout: 120000 });
    if (run.error) {
        console.error(`Could not start "${luau}": ${run.error.message}`);
        console.error('Install the luau CLI or set LUAU=/path/to/luau.');
        process.exit(2);
    }
    const lines = `${run.stdout || ''}${run.stderr || ''}`.split(/\r?\n/);
    const pass = lines.includes('HARNESS RESULT PASS');
    allPass = allPass && pass;
    console.log(`--- ${scenario}: ${pass ? 'PASS' : 'FAIL'}`);
    for (const line of lines) {
        if (/^(H |MOCK ERROR)/.test(line) || (!pass && /error/i.test(line))) {
            console.log(`   ${line}`);
        }
    }
}
console.log(allPass ? 'ALL PASS' : 'FAILED');
process.exit(allPass ? 0 : 1);
