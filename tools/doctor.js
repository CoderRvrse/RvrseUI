#!/usr/bin/env node
//
// tools/doctor.js — is this working copy telling the truth?
//
// RUN THIS BEFORE YOU BUILD OR COMMIT. `git status` is not enough, and this
// script exists because trusting it shipped a broken artifact.
//
// WHAT WENT WRONG, AND WHY git status COULD NOT SEE IT
//
// `core.autocrlf=true` (the Windows default, and set globally on the machine
// this repo is usually built on) rewrites line endings on checkout. A working
// copy of src/lucide-icons-data.lua ended CRLF while the blob in git ended LF.
//
// git reported that file as CLEAN. Not "modified" — clean. Its stat cache
// (size + mtime) matched the index entry, so it never re-read the contents.
//
// So RvrseUI.lua was packed from a source file THAT DOES NOT EXIST IN THE
// REPOSITORY, and everyone else's build differed by one byte. Every local
// re-run reproduced the same corruption, so it looked correct forever. Only
// CI — a machine that had never held that working copy — could see it.
//
// This script compares each tracked file's bytes on disk against the blob git
// actually stores, which is the one question `git status` will not answer.
//
//   node tools/doctor.js
//
// Exit 0 = clean. Exit 1 = something diverged, with the fix printed.

const { execFileSync } = require('child_process');
const fs = require('fs');

function git(args) {
    return execFileSync('git', args, { maxBuffer: 1 << 28 });
}

function main() {
    let files;
    try {
        files = git(['ls-files', '-z']).toString('utf8').split('\0').filter(Boolean);
    } catch (err) {
        console.error('❌ not a git repository (or git is not on PATH)');
        process.exit(1);
    }

    const diverged = [];
    for (const file of files) {
        let onDisk;
        try {
            onDisk = fs.readFileSync(file);
        } catch {
            continue; // deleted or unreadable: that is `git status`'s job, not ours
        }
        let stored;
        try {
            stored = git(['show', `:${file}`]);
        } catch {
            continue; // not in the index (unmerged, etc.)
        }
        if (!onDisk.equals(stored)) {
            diverged.push({ file, disk: onDisk.length, blob: stored.length });
        }
    }

    // Anything git ALREADY reports as modified is honest work in progress, not
    // the silent kind this script is for. Separate the two, because a developer
    // mid-change should not be told their tree is corrupt.
    const announced = new Set(
        git(['diff', '--name-only', 'HEAD', '-z']).toString('utf8').split('\0').filter(Boolean)
    );
    const silent = diverged.filter((d) => !announced.has(d.file));

    if (silent.length === 0) {
        console.log(`✅ ${files.length} tracked files: every working copy matches the blob git stores.`);
        if (diverged.length) {
            console.log(`   (${diverged.length} file(s) modified and correctly reported by git status — that is fine.)`);
        }
        return;
    }

    console.error('❌ WORKING COPIES THAT DIFFER FROM GIT, WHICH git status DID NOT REPORT:\n');
    for (const d of silent) {
        const delta = d.disk - d.blob;
        console.error(`   ${d.file}`);
        console.error(`      on disk ${d.disk} bytes, stored ${d.blob} bytes (${delta > 0 ? '+' : ''}${delta})`);
    }
    console.error('\n   Almost always this is line endings: core.autocrlf rewrote the file on');
    console.error('   checkout and git\'s stat cache hid it. Anything built from these files is');
    console.error('   built from content nobody else has.\n');
    console.error('   Fix each one by forcing git to hand it back:\n');
    for (const d of silent) {
        console.error(`      rm "${d.file}" && git checkout -- "${d.file}"`);
    }
    console.error('\n   (A plain `git checkout --` may do nothing, because git still believes');
    console.error('   the file is clean. Deleting it first is what makes it real.)\n');
    console.error('   Then rebuild: node tools/build.js\n');
    console.error('   See docs/LINE-ENDINGS.md.');
    process.exit(1);
}

main();
