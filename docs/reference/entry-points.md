# Entry points

| Entry point | Kind | Path | Notes |
|-------------|------|------|-------|
| `plugin WebComponent => {...}` / `$app->plugin(WebComponent, {...})` | Public API (`register`) | `lib/Mojolicious/Plugin/WebComponent.pm:17` | Config keys read: `path`, `javascript_path`, `template_path` |
| `component` helper | Template helper | `WebComponent.pm:29` | `component $name, \%opts`; option `template` (name, or `undef` to skip templating); `requestId` (overrides the id in the URL) |
| `component` with no args | Helper | `WebComponent.pm:29` | Returns the plugin instance |
| `GET`/`HEAD <path>/:req/*component` | HTTP route `webcomponent` | `WebComponent.pm:9-13`, handler `_serve` at `:32` | Default `<path>` is `/component`; `:req` is the request id and is not used when serving |

## Config keys

| Key | Default | Read at |
|-----|---------|---------|
| `path` | `/component` | `WebComponent.pm:11` |
| `javascript_path` | `components` (under `<static asset_dir>/js/`) | `WebComponent.pm:42` |
| `template_path` | `components` (under the app templates) | `WebComponent.pm:43` |

The POD also lists a `helper` key under `register` (`WebComponent.pm:464`); the
code defines the helper name as the literal `'component'` (`:21`) and does not
read `config->{helper}`.

## Parameters on the script URL

`_serve` reads `template` from the merged params (`:47`). A value matching
`/(false|f|no|0)/i` (unanchored) skips templating; any other value names the
template file. `_component` writes `template=false` into the request params
when the helper option is `undef` (`:113-116`).
