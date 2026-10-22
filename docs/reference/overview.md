# Overview

`Mojolicious::Plugin::WebComponent` is a CPAN distribution (version 0.07,
`lib/Mojolicious/Plugin/WebComponent.pm:7`) that adds server-side templating to
custom web component scripts in a Mojolicious app.

## What it does

1. A template calls the `component` helper, which emits a
   `<script src='/component/<requestId>/<name>.js?<params>'></script>` tag.
2. The browser requests that URL. The plugin's route serves the component's
   JavaScript file from the app's static assets.
3. While serving, the plugin renders the matching Mojolicious template
   (`templates/components/<name>.html.ep`) and splices it into the script as a
   `let tmpl = document.createElement('template'); tmpl.innerHTML = ...` block,
   at the script's `let tmpl;` line or just before its
   `shadowRoot.appendChild(tmpl.content.cloneNode(true))` line.

Request parameters and route captures of the original page request travel on
the script URL and reach the template as the `$params` hash.

## Parts

| Part | Path |
|------|------|
| Plugin (route, helper, injection) | `lib/Mojolicious/Plugin/WebComponent.pm` |
| Tests and fixtures | `t/` |
| Packaging (Minilla, Module::Build::Tiny) | `minil.toml`, `Build.PL`, `META.json`, `cpanfile` |
| CI | `.github/workflows/test.yml` |
| Release notes | `Changes` |

The distribution is one Perl module. Its documentation is the POD after
`__END__` in the same file; `README.md` is the generated copy.

## Deployment

A library installed from CPAN (`requires 'Mojolicious'`, `cpanfile`). It has no
service of its own. Reverse-proxy installs are supported by prefixing the
generated script path with the request's base path
(`WebComponent.pm:109-111`, Changes 0.07).
