# rust-guide-th

```
██████╗  ██╗   ██╗ ███████╗ ████████╗     ██████╗  ██╗   ██╗ ██╗ ██████╗  ███████╗    ████████╗ ██╗  ██╗
██╔══██╗ ██║   ██║ ██╔════╝ ╚══██╔══╝    ██╔════╝  ██║   ██║ ██║ ██╔══██╗ ██╔════╝    ╚══██╔══╝ ██║  ██║
██████╔╝ ██║   ██║ ███████╗    ██║       ██║  ███╗ ██║   ██║ ██║ ██║  ██║ █████╗         ██║    ███████║
██╔══██╗ ██║   ██║ ╚════██║    ██║       ██║   ██║ ██║   ██║ ██║ ██║  ██║ ██╔══╝         ██║    ██╔══██║
██║  ██║ ╚██████╔╝ ███████║    ██║       ╚██████╔╝ ╚██████╔╝ ██║ ██████╔╝ ███████╗       ██║    ██║  ██║
╚═╝  ╚═╝  ╚═════╝  ╚══════╝    ╚═╝        ╚═════╝   ╚═════╝  ╚═╝ ╚═════╝  ╚══════╝       ╚═╝    ╚═╝  ╚═╝
```

---

## ◆ PULSE

[![GitHub Pages](https://img.shields.io/badge/Pages-live-2ea44f)](https://suradet-ps.github.io/rust-guide-th/)
[![License](https://img.shields.io/badge/license-Open%20Licence%202.0-blue.svg)](#-anatomy)

Rust is memory safe by default - rust-guide-th maps the places where
that guarantee must be earned. This is the complete Thai translation of
ANSSI's *Secure Rust Guidelines*: all 17 upstream markdown files (13
published chapters, the licence, and the parked stubs), built with
mdbook, terminology locked by a single glossary, every code block
byte-identical to the original, and every link checked against the
built book (353 anchors). The structure mirrors the upstream repo
file-for-file, and the Open Licence travels with the text. Built for
the Thai-speaking Rustacean:
[suradet-ps.github.io/rust-guide-th](https://suradet-ps.github.io/rust-guide-th/).

| 17 files translated ▣ | Glossary ▣ | Links 353/353 ▣ | Build passing ▣ |
|---|---|---|---|

*v1.0.0 - translation, glossary, verification, and the static build
are all sealed.*

> Built with mdbook 0.5 + Markdown, translated from
> [ANSSI-FR/rust-guide](https://github.com/ANSSI-FR/rust-guide),
> verified by script and rendered as static HTML - a secure guide with
> the checklist on the page.
>
> **suradet-ps**, artifact keeper

---

## ◆ IGNITION

One runtime, three preprocessors, six commands.

```
⟫ git clone https://github.com/suradet-ps/rust-guide-th.git
⟫ cd rust-guide-th
⟫ cargo install mdbook --version 0.5.4 --locked
⟫ cargo install --path mdbook-plugins/mdbook-checklist --locked
⟫ cargo install --path mdbook-plugins/mdbook-code-align --locked
⟫ cargo install --path mdbook-plugins/mdbook-extensions --locked
⟫ mdbook serve --open
```

Open [http://localhost:3000](http://localhost:3000).

```
⟫ mdbook build                               # static HTML into book/
⟫ powershell scripts/check-links.ps1         # all anchors in the built book (pwsh on Linux/macOS)
⟫ powershell scripts/verify-translation.ps1  # byte-exact check vs upstream
```

> On Linux or macOS, run the verification scripts using `pwsh scripts/<script>.ps1`.
> `verify-translation.ps1` checks against `ANSSI-FR/rust-guide` in adjacent directories or via `-Orig <path>`.

<details>
<summary>Translating a chapter</summary>

A chapter is a file: `src/th/<chapter>.md`, listed in
`src/th/SUMMARY.md`. The glossary lives in `GLOSSARY.md` - a term
is chosen once and reused everywhere. Code blocks, `{{#include ...}}`
directives, citations, link targets, and heading `{#anchor}` ids stay
verbatim; only prose and headings are translated. Heading anchors
follow mdbook's slug rules (Thai tone marks are stripped), so anchors
are copied from the built HTML, never guessed.

</details>

---

## ◆ ANATOMY

One stack, three vendored preprocessors, zero custom JS written here.

- **Translates** - the complete guide: introduction, development
  environment, libraries, naming, integer operations, error handling,
  language guarantees, the three `unsafe` chapters (generalities,
  memory, FFI), and the standard library - Thai prose over untouched
  code.
- **Glossaries** - `GLOSSARY.md` locks the vocabulary (one Thai
  term per concept, chosen once and reused), so chapter nine agrees
  with chapter two.
- **Verifies** - `scripts/verify-translation.ps1` diffs every code
  block (47 of them), `{{#include ...}}` directive, heading level,
  `{#anchor}` id, recommendation id and type, citation, footnote, and
  link target against upstream `ANSSI-FR/rust-guide` - byte-exact or
  it does not pass.
- **Checks** - `scripts/check-links.ps1` walks the built book and
  resolves every anchor link against real heading ids - 353 of them,
  all reachable.
- **Builds** - mdbook renders static HTML into `book/`, with
  `mdbook-checklist` (recommendation boxes and the generated checklist
  page), `mdbook-extensions` (citations and references), and
  `mdbook-code-align` (code snippet alignment) vendored in
  `mdbook-plugins/` and installed from source - zero server runtime,
  readable offline and searchable by built-in static index.
- **Licenses** - Open Licence 2.0, inherited from upstream, with the
  LICENSE file shipped beside the text.

---

## ◆ RITUALS

**The core ceremony** - the translation pass:

1. Open a chapter in `src/th/`. The upstream `ANSSI-FR/rust-guide`
   repo sits beside it (clone
   `https://github.com/ANSSI-FR/rust-guide` alongside `rust-guide-th`)
   - structure is a contract.
2. Translate the prose; keep every code block, include directive, and
   command as the original wrote it.
3. Consult `GLOSSARY.md` for every term that already has a canon.
   New terms get proposed in the glossary first.
4. Build, verify, check. The book builds clean, the diff is
   byte-exact, and the anchors resolve.

**The ceremony of the anchor** - mdbook slugs strip Thai tone marks
and vowel signs, so a heading's anchor is never its plain spelling.
Anchors are read from the built HTML, written into the source, and
re-verified - a guessed anchor is a broken link waiting to happen.

**The ceremony of the code block** - a translated command that is not
byte-identical to the original is a regression, not a translation.
The verifier is the conscience of the repo.

---

## ◆ ECHOES

**Where this artifact is heading**

```
P1 ▸ SUMMARY, introduction, licence, glossary ─────────────────────── ▸ sealed
P2 ▸ the lifecycle and ecosystem chapters ─────────────────────────── ▸ sealed
P3 ▸ the language chapters ────────────────────────────────────────── ▸ sealed
P4 ▸ the unsafe chapters, generalities to FFI ─────────────────────── ▸ sealed
P5 ▸ link verification, translation verifier, mdbook build ────────── ▸ sealed
```

**Raising the artifact** - the honest path lives in `GLOSSARY.md`
(term canon), `scripts/` (the verification gate), and `book.toml`
(book config). New chapters follow the frontmatter contract of the
upstream files. Open an issue first to discuss a change.

**Status** - on every change: `mdbook build` must pass, the
translation verifier must report byte-exact code blocks across all 17
files, and the link checker must report `ALL ANCHOR LINKS OK`.
[Watch the gates](scripts).

---

```
  ─────────────────────────────────────────
   Every recommendation has its checklist
   Every book has its first page
  ─────────────────────────────────────────
```

Translated from the
[ANSSI-FR/rust-guide](https://github.com/ANSSI-FR/rust-guide), which
is licensed under the [Open Licence 2.0](LICENSE.md).
