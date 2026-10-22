---
title: "Decide and implement a stable cacheable component URL (replace :req)"
type: feature
status: open
source: user
---

## Context

Filed by sweep-it from the audit (finding 10) and the comparison with Mojolicious::Plugin::AssetPack. AssetPack's route `/asset/:checksum/*name` uses a content fingerprint looked up in a registered table; this plugin copied the shape but `:req` is the request id and is never used (`WebComponent.pm:12`, `:120`).

## Problem

The script URL changes on every page view, so browsers cannot cache it and the template is re-rendered on every fetch. There is no registered set of components, which is also what lets finding 1 (path traversal) happen.

Decision needed from the owner: replace `:req` with a content hash (script plus rendered template plus relevant params), keep the request id as an option, or leave as is. A change to the URL shape is breaking: release as 0.08 with a `Changes` entry.

## Acceptance

- Decision recorded (ADR or issue comment).
- If hashed: the same component with the same inputs gives the same URL across requests; any change to script, template or params changes it.
- Script responses carry `Cache-Control` suited to a fingerprinted URL.
- `requestId` helper option behaviour is documented or removed.
- Tests cover URL stability, change on edit, and cache headers; `Changes` and POD updated.

## Notes

Do after or with the issue for the script route fixes (traversal and injection), since both touch `_serve` and `_component`. AssetPack internals other than `register` were not read.
