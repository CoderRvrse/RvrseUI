# ⛔ CRITICAL: git can tell you a file is clean when it is not

**Read this before you build, commit, or debug a build that "only fails in CI".**

This has bitten this repository repeatedly. It is not a theoretical problem and
it is not your editor. It has shipped a wrong artifact to production.

---

## The one-line version

> `core.autocrlf` rewrites line endings on checkout. Git's stat cache then
> reports the rewritten file as **clean**. Anything you build is built from
> content **nobody else has** — and it will look correct on your machine
> forever.

**`git status` is not evidence.** Run this instead:

```sh
node tools/doctor.js
```

---

## What actually happened (2026-10-31)

CI failed the reproducibility gate with a **one-byte** difference in
`RvrseUI.lua` that could not be reproduced locally. Four separate local checks
said everything was fine.

The cause:

| | |
|---|---|
| Working copy of `src/lucide-icons-data.lua` | ended `\r\n` |
| The blob stored in git | ended `\n` |
| `git status`, `git diff`, `git diff --stat` | **all reported it clean** |

Git never re-read the file. Its stat cache (size + mtime) matched the index
entry, so it took the shortcut and said "unchanged".

The shipped monolith was therefore packed from **a source file that does not
exist in the repository**:

```
committed   ...{257,257}}}}\r\n
rebuilt     ...{257,257}}}}\n
```

`core.autocrlf` was `true` **globally** on the build machine. The repo set it
to `false` locally, which does **not** undo a conversion an earlier checkout
already performed.

### Why it survived so long

Every local re-run reproduced the same corruption, so the build was
"reproducible" on that machine and nowhere else. Only a machine that had never
held that working copy — CI — could see the truth. **The local check was
circular and could never have caught it.**

---

## How to detect it

`tools/doctor.js` compares every tracked file's bytes on disk against the blob
git actually stores, which is the question `git status` will not answer:

```sh
node tools/doctor.js
```

It separates files git *honestly reports as modified* (your work in progress —
fine) from files that differ **silently** (the dangerous kind).

By hand, for one file:

```sh
git show ":src/lucide-icons-data.lua" > /tmp/blob
cmp src/lucide-icons-data.lua /tmp/blob
```

---

## How to fix it

```sh
rm "<file>" && git checkout -- "<file>"
```

**Deleting it first is not superstition.** A plain `git checkout -- <file>`
can do nothing at all, because git still believes the file is clean and sees
no work to do.

Then rebuild and commit the result:

```sh
node tools/build.js
```

---

## What stops it recurring

### 1. `.gitattributes` freezes line endings

```
* -text
```

Store what you are given, hand back exactly that, on every platform. It
changes **no file's content** — only git's meddling. Do not remove it.

**A build cannot be deterministic while a checkout is free to change the bytes
it reads.** Any reproducibility gate is worthless without this.

### 2. The build is reproducible

`tools/build.js` and `tools/build.lua` take the version and build id from
`VERSION.json`. They used to embed `new Date()` / `os.date()`, which made
*every* rebuild "change" the file — so `git diff` could never answer *"does the
committed monolith match its sources?"*.

That is precisely how the header kept announcing **v4.5.2 for five releases**
while the library was 4.10.0.

### 3. CI rebuilds and fails on any difference

```yaml
- name: Docs and monolith match their sources
  run: |
    node tools/build.js
    git diff --exit-code -- RvrseUI.lua docs/index.html README.md
```

**This step must run before `Format Code`.** `stylua` rewrites `src/` in place;
rebuilding after it compares the committed monolith against sources CI itself
just reformatted — a diff of thousands of lines that means nothing. (That
mistake was made too, on the first version of this gate.)

---

## Testing a reproducibility gate

**Never test it where you built.** That is circular, and circular is exactly
what hid this for five releases.

Test the **hostile** case — a fresh clone with the setting that causes the
damage:

```sh
git clone --config core.autocrlf=true <repo> /tmp/hostile
cd /tmp/hostile && node tools/build.js && git diff --exit-code
```

If that passes, the gate is real.

---

## Checklist before you touch this repo

1. `node tools/doctor.js` → must be clean
2. Make your change in `src/`, **never** in `RvrseUI.lua`
3. `node tools/build.js`
4. `node tools/doctor.js` again
5. Commit `src/` **and** the rebuilt `RvrseUI.lua` together

Related: `CLAUDE.md` (CRITICAL WARNING #0 on `do ... end` wrapping),
`docs/DEV_NOTES.md`.
