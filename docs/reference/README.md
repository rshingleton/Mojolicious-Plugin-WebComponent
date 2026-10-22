# Reference

Mapped: whole repo, 2026-10-22.

| Page | Contents |
|------|----------|
| [overview.md](overview.md) | What the plugin does and its parts |
| [module-map.md](module-map.md) | Modules, paths, internals of `WebComponent.pm` |
| [entry-points.md](entry-points.md) | Plugin API, helper, route, config keys |
| [data-flow.md](data-flow.md) | Helper and route request paths |
| [domains.md](domains.md) | Domain areas and term gaps |
| [test-landscape.md](test-landscape.md) | Tests, fixtures, what each covers |
| [build-and-deploy.md](build-and-deploy.md) | Minilla build, release, CI |

`external-systems.md` is omitted: the repo has no third-party service.

## Commands

| Task | Command |
|------|---------|
| Test | `prove -lr t` |
| Author tests (POD) | `RELEASE_TESTING=1 prove -lr t` |
| Install deps | `cpanm --installdeps --with-develop .` |
| Build, lint, format, type-check | none configured |
