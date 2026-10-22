use Mojo::Base -strict, -signatures;
use Test::Mojo;
use Test::More;
use Mojo::File qw(curfile);
use Mojolicious;

my $files = curfile->sibling('files')->to_string;
my $templates = curfile->sibling('templates')->to_string;

sub tester(%config) {
    my $app = Mojolicious->new(mode => 'test');
    $app->static->paths([$files]);
    $app->renderer->paths([$templates]);
    $app->plugin(WebComponent => \%config);
    $app->renderer->warmup;
    $app->routes->get('/helper' => sub ($c) {
        $c->render(text => join "\n",
            $c->component('my-component', {requestId => 'r'}),
            $c->component('my-component', {requestId => 'r', template => 'notes'}),
            $c->component('my-component', {requestId => 'r'}));
    });
    $app->routes->get('/page/:id' => sub ($c) {
        $c->render(text => $c->component('my-component', {requestId => 'r'}));
    });
    return Test::Mojo->new($app);
}

# the first request to a fresh app serves the script (route exists after register)
my $t = tester();
$t->get_ok('/component/x/my-component.js')->status_is(200)
    ->header_like('Content-Type' => qr{javascript})
    ->content_like(qr{This is a custom web component});

# a catch-all route declared before the plugin loads does not shadow the script route
{
    my $app = Mojolicious->new(mode => 'test');
    $app->static->paths([$files]);
    $app->renderer->paths([$templates]);
    $app->routes->any('/*any' => sub ($c) { $c->render(text => 'catchall') });
    $app->plugin('WebComponent');
    $app->renderer->warmup;
    Test::Mojo->new($app)->get_ok('/component/x/my-component.js')->status_is(200)
        ->content_like(qr{custom web component});
}

# names that leave the component folder or are not .js are not served
for my $name (qw(..%2f..%2f..%2fsecret.js %2e%2e%2f%2e%2e%2f%2e%2e%2fsecret.js sub%2fmy-component.js my-component.txt .hidden.js)) {
    $t->get_ok("/component/x/$name")->status_is(404)->content_unlike(qr{SECRET-MARKER});
}

# a component below a sub folder is served with its own template
$t->get_ok(q{/component/x/sub/sub-box.js})->status_is(200)->content_like(qr{<p>sub template});
$t->get_ok(q{/component/x/sub/..%2f..%2fsecret.js})->status_is(404)->content_unlike(qr{SECRET-MARKER});

# unknown component is a 404, not a 500
$t->get_ok('/component/x/nope.js')->status_is(404);

# the template is one string literal: backtick, ${} and backslash stay data
$t->get_ok('/component/x/tick-box.js?template=tick-box')->status_is(200)
    ->content_unlike(qr{innerHTML = `})->content_like(qr{innerHTML = "});
SKIP: {
    my $node = `node --version 2>/dev/null`;
    skip 'node not installed', 1 unless $node;
    my $js = $t->tx->res->text;
    require File::Temp;
    my ($tfh, $tfile) = File::Temp::tempfile(SUFFIX => '.js', UNLINK => 1);
    binmode $tfh, ':utf8';
    print $tfh $js;
    close $tfh;
    is system('node', '--check', $tfile), 0, 'component script with backtick and backslash template parses';
}

$t->get_ok('/component/x/echo-box.js?template=echo-box&q=${alert(1)}%60;alert(1);%60')->status_is(200)
    ->content_unlike(qr{innerHTML = `})->content_like(qr{innerHTML = "});

# a template name outside the allowlist is not echoed or rendered
$t->get_ok('/component/x/my-component.js?template=%60;alert(1);%60')->status_is(200)
    ->content_unlike(qr{alert\(1\)})->content_like(qr{template not found});
$t->get_ok('/component/x/my-component.js?template=..%2f..%2fdefault%2findex')->status_is(200)
    ->content_unlike(qr{dashboard})->content_like(qr{template not found});
$t->get_ok('/component/x/my-component.js?template=missing')->status_is(200)
    ->content_like(qr{components/missing template not found});

# a non-ASCII template name is looked up, not rejected as invalid
$t->get_ok(q{/component/x/my-component.js?template=caf%C3%A9})->status_is(200)
    ->content_like(qr{template not found})->content_like(qr{components/café});

# template names that merely contain f, no or 0 are still templates
for my $name (qw(notes footer 10-grid)) {
    $t->get_ok("/component/x/my-component.js?template=$name")->status_is(200)
        ->content_like(qr{<p>\Q$name\E template});
}
# and the whole-value switches skip templating
for my $off (qw(false f no 0 FALSE)) {
    $t->get_ok("/component/x/my-component.js?template=$off")->status_is(200)
        ->content_unlike(qr{tmpl\.innerHTML});
}

# non-ASCII round-trips in the script file and in the template
$t->get_ok('/component/x/utf-box.js')->status_is(200)->content_type_like(qr{charset=UTF-8}i)
    ->content_like(qr{this\.label = 'café €'})->content_like(qr{café € in template});

# helper urls: no callback, no route captures, option scoped to its own call
$t->get_ok('/helper')->status_is(200);
my @urls = split /\n/, $t->tx->res->text;
is scalar(@urls), 3, 'three script tags';
unlike $urls[0], qr{cb=|CODE}, 'no callback in url';
unlike $urls[1], qr{CODE}, 'no callback in url';
like $urls[1], qr{template=notes}, 'option applies to its own call';
unlike $urls[2], qr{template}, 'option does not leak to the next call';
$t->get_ok('/page/7?a=1')->status_is(200)
    ->content_like(qr{a=1})->content_unlike(qr{CODE|cb=|req=|component=});

# the helper refuses a name the route would never serve
for my $bad (q{../x}, q{.hidden}, q{a b}, q{x/..}) {
    eval { $t->app->build_controller->component($bad) };
    like $@, qr{invalid component name}, "component '$bad' dies";
}
ok eval { $t->app->build_controller->component(q{sub/sub-box}); 1 }, q{subfolder name is accepted};

# a route of the app under the component path is not reached once the plugin is registered
{
    my $app = Mojolicious->new(mode => q{test});
    $app->static->paths([$files]);
    $app->routes->get(q{/component/x/my-component.js} => sub ($c) { $c->render(text => q{mine}) });
    $app->plugin(q{WebComponent});
    Test::Mojo->new($app)->get_ok(q{/component/x/my-component.js})->content_unlike(qr{^mine\z});
}

# config keys: path, javascript_path, template_path
my $alt = tester(path => '/wc', javascript_path => 'alt', template_path => 'alt-tpl');
$alt->get_ok('/wc/x/alt-box.js')->status_is(200)->content_like(qr{alt template});
$alt->get_ok('/component/x/alt-box.js')->status_is(404);
is $alt->app->component('alt-box', {requestId => 'q'}),
    "<script src='/wc/q/alt-box.js'></script>", 'helper uses the configured path';

done_testing;
