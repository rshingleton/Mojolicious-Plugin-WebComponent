# Test landscape

Run all: `prove -lr t` (same command as `.github/workflows/test.yml`). Last
run for this map: 4 files, 10 tests passed; the two author tests were skipped.

| Test | Path | Kind | Covers |
|------|------|------|--------|
| Compile | `t/00_compile.t` | Load check | `require_ok` of the plugin module |
| Register | `t/register.t` | Integration (`Test::Mojo`, Mojolicious::Lite app) | `GET /` returns 200; a page using `<my-component>` returns 200; `component('my-component', {requestId => 'test-id'})` returns the expected script tag; `GET /component/test-id/my-component.js` returns 200 with the template text injected |
| POD syntax | `t/pod.t` | Author test | `all_pod_files_ok`; runs only with `RELEASE_TESTING` set |
| POD coverage | `t/pod-coverage.t` | Author test | `all_pod_coverage_ok`; runs only with `RELEASE_TESTING` set |

## Fixtures

| File | Role |
|------|------|
| `t/files/assets/js/components/my-component.js` | Component script containing the `let tmpl;` marker; static root is rewritten from `/public` to `/files` in `t/register.t` |
| `t/templates/components/my-component.html.ep` | Component template |
| `t/templates/default/index.html.ep` | Page using `<my-component>`; layout `default_layout` |
| `t/templates/layouts/default_layout.html.ep` | Layout calling `component 'system-hosts'` |

## Facts about coverage

- Exercised in `t/register.t`: default `path`, default `javascript_path` and
  `template_path`, default template name.
- Not exercised by any test: the `path`, `javascript_path`, `template_path`
  config keys; the `template` option and param; the missing-template message;
  the reverse-proxy base path; the `inline let tmpl` injection branch on
  `shadowRoot.appendChild`.
- The layout's `component 'system-hosts'` has no matching script or template
  under `t/`.
