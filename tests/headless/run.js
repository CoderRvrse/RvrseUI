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

console.log(`RvrseUI headless lifecycle test: ${uiPath}`);
let allPass = true;
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
