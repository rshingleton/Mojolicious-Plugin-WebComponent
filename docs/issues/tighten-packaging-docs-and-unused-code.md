---
title: "Tighten packaging, docs and unused code"
type: feature
status: open
source: user
---

## Context

Filed by sweep-it from the audit (findings 11, 13-18). Files: `lib/Mojolicious/Plugin/WebComponent.pm`, `cpanfile`, `Build.PL`, `META.json`, `README.md`, `t/templates/layouts/default_layout.html.ep`.

## Problem

- POD documents a `helper` option (`:464`); `register` hardcodes `'component'` (`:21`).
- `cpanfile` has no `perl` or Mojolicious minimum; code needs Perl 5.20 and signatures (`Build.PL` says 5.008001, `META.json` says v5.20.0).
- `Carp` and `Data::Dumper` are loaded and unused (`:4-5`); a commented-out line at `:76`.
- `_serve` reads private `$app->renderer->{templates}` (`:63`).
- POD example typos: `WebCojsDeferredmponent` (`:216`), `</ldiv>` (`:354`), `$store.systems` (`:355`); `README.md` copies them.
- Test layout asks for a `system-hosts` component that does not exist under `t/`.

## Acceptance

- `helper` is honoured (`$config->{helper} // 'component'`) or removed from the POD; a test proves it.
- `cpanfile` declares `perl 5.020` and a tested Mojolicious minimum; metadata agrees.
- Unused imports and dead comment removed; template lookup uses a public renderer API or is covered by a test that fails if the internal changes.
- POD and `README.md` examples corrected; `t/` layout uses `my-component`.

## Notes

Low risk, no behaviour change except the `helper` option. Independent of the other two issues.
