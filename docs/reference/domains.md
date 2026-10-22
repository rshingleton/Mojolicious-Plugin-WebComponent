# Domains

One domain area; no `CONTEXT.md` or `CONTEXT-MAP.md` exists yet.

| Area | Code | Context |
|------|------|---------|
| Web component serving (helper, route, template injection) | `lib/Mojolicious/Plugin/WebComponent.pm` | none |

## Term gaps

Domain words the code or docs use that no context file defines (offer to
`name-it`):

| Word | Where it appears |
|------|------------------|
| component (script plus template pair) | helper name `component`, route `*component`, POD |
| template (`tmpl`) | `let tmpl;` marker in component scripts, `template` option and param, `template_path` |
| request id (`:req`, `reqId`, `requestId`) | route pattern, helper option, `_component` |
| asset dir | `$app->static->asset_dir` used in `_serve` (`:41`, `:77`) |
