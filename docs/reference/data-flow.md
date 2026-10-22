# Data flow

No persistence, queues or outbound calls. Everything is request-scoped and
read from the app's own static files and templates.

## Page render: `component` helper (`_component`)

```
template: %= component 'my-component', {template => ...}
  -> name gets ".js" appended if missing                       (:122)
  -> params = request params + route captures, minus `cb`      (:133-139)
  -> reqId  = opts.requestId || request_id                     (:120)
  -> path   = <base path> + route pattern, :req -> reqId,
              *component -> name, "?<params>" appended         (:109-127)
  -> returns <script src='path'></script> (Mojo::ByteStream)   (:128-130)
```

## Script request: route `_serve`

```
GET <path>/:req/*component?<params>
  -> params = request params + captures                        (:39)
  -> template param: skip (false/f/no/0) | alternate file name | default
  -> template name = component name without ".js"             (:61)
  -> "<template_path>/<name>" found in renderer->{templates}?
       yes: render_to_string(template, params => \%params)     (:63-65)
       no:  "<div>404 -  <template> template not found</div>"  (:68)
  -> wrap as `let tmpl = document.createElement('template');
              tmpl.innerHTML = `<html>``                       (:70-73)
  -> read static file "/<asset_dir>/js/<javascript_path>/<component>" (:77-78)
  -> copy lines; on the first `let tmpl;` line, replace it with the block
     and skip it; on the first `shadowRoot.appendChild(tmpl.content.cloneNode(true))`
     line, emit the block before it                            (:83-97)
  -> render(text => content)                                   (:99)
```

Inputs: the app's static directories (`$app->static->file`), the renderer's
template table, the request's query params and route captures.
Output: the script text as the response body.

## Notes from reading the code

- `$app->static->file($js)` returns undef when the file is absent; the code
  calls `->handle` on the result without a check (`:78-81`). *(Behaviour on a
  missing script file not run.)*
- The template HTML is interpolated into a JavaScript template literal
  without escaping (`:72`).
