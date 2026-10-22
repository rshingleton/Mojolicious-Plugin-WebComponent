# Module map

| Module | Path | Responsibility | Depends on | Used by |
|--------|------|----------------|------------|---------|
| Plugin class | `lib/Mojolicious/Plugin/WebComponent.pm` | `register` installs the `component` helper; `route` attribute builds the serving route lazily; `_serve` renders and injects the template; `_component` builds the script tag; `_getAllParams` merges query params and route captures | Mojolicious (`Mojo::Base`, `Mojo::Parameters`, `Mojo::ByteStream`, renderer, static), Carp, Data::Dumper | Host Mojolicious apps; `t/register.t` |
| Test fixtures | `t/files/assets/js/components/my-component.js`, `t/templates/` | Sample component script, component template, page and layout used by `t/register.t` | the plugin | `t/register.t` |
| CI workflow | `.github/workflows/test.yml` | Runs `prove -lr t` on Perl 5.20 to 5.36 | cpanm, `cpanfile` | GitHub push and pull request events |
| Packaging | `minil.toml`, `Build.PL`, `META.json`, `cpanfile` | Minilla release config (`ModuleBuildTiny`), generated build script and metadata, runtime dependency list | Minilla | CPAN release |

## Plugin internals (`WebComponent.pm`)

| Symbol | Line | Kind | Role |
|--------|------|------|------|
| `route` | 9 | attribute (lazy) | `any([HEAD GET] => "<path>/:req/*component")`, named `webcomponent`, handled by `_serve`; `<path>` is `config->{path}` or `/component` |
| `app`, `config` | 14-15 | attributes | Set in `register` |
| `register` | 17 | method | Stores app and config; skips if helper `component` exists; sets stash default `webcomponent.helper`; adds helper `component` |
| `_serve` | 32 | route callback | Resolves script and template, injects, renders as text |
| `_component` | 102 | helper body | Returns the script tag as `Mojo::ByteStream` |
| `_getAllParams` | 133 | method | Request params plus `mojo.captures`, as `Mojo::Parameters`, without `cb` |

The `component` helper with no arguments returns the plugin object itself
(`WebComponent.pm:29`); with arguments it calls `_component`.
