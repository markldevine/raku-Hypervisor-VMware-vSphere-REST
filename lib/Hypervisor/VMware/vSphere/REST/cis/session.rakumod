unit         class Hypervisor::VMware::vSphere::REST::cis::session:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use          HTTP::UserAgent;
use          JSON::Fast;
use          KHPH;
use          URI;

use          Hypervisor::VMware::vSphere::REST::Grammars::DateTime;

constant     MINIMUM-ROOT-STASH-PATH-DEPTH = 2;

has Str      $.auth-login;
has Str      $.root-stash-path  = '/var/rakudo/Hypervisor/VMware/vSphere/REST';
has Str      $.useragent        = 'Rakudo HTTP::UserAgent';
has Str:D    $.vcenter          is required;

has DateTime $.created-time;
has DateTime $.last-accessed-time;
has Str      $.user;

has Bool     $.use-cache        is rw = False;

has Str      $.vsphere-api-session-id;

has HTTP::UserAgent $.ua;

my $Cache-Dir;

class Cache-Endpoint {
    has Str     $.json-path;
    has URI     $.uri;
    has Bool    $.valid is rw;
}

submethod TWEAK {
    $!auth-login = ~$*USER without $!auth-login;
    my @dirs = self.root-stash-path.IO.path.split('/');
    die ':root-stash-path must be at least ' ~ MINIMUM-ROOT-STASH-PATH-DEPTH ~ ' deep - more subdirectories required.' unless @dirs.elems >= MINIMUM-ROOT-STASH-PATH-DEPTH;
    mkdir(self.root-stash-path) unless self.root-stash-path.IO.e;
    chmod(0o3777, self.root-stash-path) unless self.root-stash-path.IO.mode == 3777;
    $Cache-Dir = self.root-stash-path ~ '/.cache';
    mkdir($Cache-Dir) unless $Cache-Dir.IO.e;
    chmod(0o1777, $Cache-Dir) unless ~$Cache-Dir.IO.mode == 1777;
}

method !get-cache-entry (Str:D $uri-str) {
#   say self.^name ~ '::!' ~ &?ROUTINE.name;
    my URI $uri    .= new($uri-str);
    my @dirs        = $uri.path.split('/');
    my $child       = @dirs.pop;
    my $parent      = @dirs.pop;
    my $base        = $Cache-Dir ~ '/' ~ $*USER ~ '/' ~ $uri.host ~ @dirs.join('/') ~ '/' ~ $parent;
    mkdir($base)    unless $base.IO.e;
    chmod(0o700, $base) unless ~$base.IO.mode == 700;

#   /rest/vcenter/cluster                                                       ->  /rest/vcenter/cluster.json
#   /rest/vcenter/cluster/domain-c1091      ??  /rest/vcenter/cluster.json      ->  /rest/vcenter/cluster/domain-c1091.json

    my $parent-json = $base ~ '.json';
    my $json-path   = $base ~ '/' ~ $child ~ '.json';

#   If no cache endpoint for this item yet, perform a fresh lookup
    return Cache-Endpoint.new(
        :$json-path,
        :$uri,
        :valid(False),
    ) unless $json-path.IO.e;

#   If cache entry for this item is older than its parent (if relevant), perform a fresh lookup
    return Cache-Endpoint.new(
        :$json-path,
        :$uri,
        :valid(False),
    ) if $parent-json.IO.e && ($json-path.IO.changed < $parent-json.IO.changed);

#   Good cache entry
    return Cache-Endpoint.new(
        :$json-path,
        :$uri,
        :valid(True),
    );
}

method fetch (Str:D $uri-str --> Hash:D) {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    my $cache-entry = self!get-cache-entry($uri-str);
    return from-json(slurp($cache-entry.json-path)) if self.use-cache && $cache-entry.valid;
    self.init unless $!ua.DEFINITE;
    my %headers;
    %headers<vmware-api-session-id> = self.vsphere-api-session-id;
say $cache-entry.uri;
    my $response    = self.ua.get($cache-entry.uri, |%headers);
    unless $response.is-success {
        self.delete;
        die ~$cache-entry.uri ~ ': failed!';
    }
    spurt($cache-entry.json-path, $response.content);
    return from-json($response.content);
}

method !password-stash-path () {
    return(self.root-stash-path ~ '/.credentials' ~ '/cis/session/' ~ self.vcenter ~ '/' ~ self.auth-login ~ '/' ~ $*USER ~ '/' ~ 'password.khph');
}

method !session-token-stash-path () {
    return(self.root-stash-path ~ '/.credentials' ~ '/cis/session/' ~ self.vcenter ~ '/' ~ self.auth-login ~ '/' ~ $*USER ~ '/' ~ 'session-token.khph');
}

method init () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    $!ua = HTTP::UserAgent.new(:$!useragent);
    if self!session-token-stash-path.IO.e {
        $!vsphere-api-session-id = KHPH.new(:stash-path(self!session-token-stash-path)).expose;
        try {
            CATCH {
                default {
                    note .exception.message without self!session-token-stash-path.IO.unlink;
                    $!vsphere-api-session-id = Nil;
                }
            }
            self.get;
        }
    }
    self.create without $!vsphere-api-session-id;
    self;
}

### POST https://{server}/rest/com/vmware/cis/session
method create () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    $!ua.auth($!auth-login, KHPH.new(:stash-path(self!password-stash-path)).expose);
    my URI $uri .= new('https://' ~ $!vcenter ~ '/rest/com/vmware/cis/session');
    my %header;
    my $response = $!ua.post($uri, %, |%header);
    die self.^name ~ '::' ~ &?ROUTINE.name ~ ': for ' ~ self.vcenter ~ ' failed!' unless $response.is-success;
    my %content = from-json($response.content);
    $!vsphere-api-session-id = %content<value>;
    $ = KHPH.new(:secret($!vsphere-api-session-id), :stash-path(self!session-token-stash-path));
    $!ua.auth($!auth-login, Str);
    Nil;
}

### POST https://{server}/rest/com/vmware/cis/session?~action=get
method get () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    my URI $uri .= new('https://' ~ $!vcenter ~ '/rest/com/vmware/cis/session?~action=get');
    my %header;
    %header<vmware-api-session-id> = $!vsphere-api-session-id;
    my $response = $!ua.post($uri, %, |%header);
    die self.^name ~ '::' ~ &?ROUTINE.name ~ ': for ' ~ self.vcenter ~ ' failed!' unless $response.is-success;
    my %content = from-json($response.content);
    my $actions = Hypervisor::VMware::vSphere::REST::Grammars::DateTime::Actions.new;
    $!created-time = Hypervisor::VMware::vSphere::REST::Grammars::DateTime.parse(%content<value><created_time>, :$actions).made;
    $!last-accessed-time = Hypervisor::VMware::vSphere::REST::Grammars::DateTime.parse(%content<value><last_accessed_time>, :$actions).made;
    $!user = %content<value><user>;
}

### DELETE https://{server}/rest/com/vmware/cis/session
method delete () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    my %header;
    %header<vmware-api-session-id> = $!vsphere-api-session-id;
    my $request = HTTP::Request.new: DELETE => 'https://' ~ $!vcenter ~ '/rest/com/vmware/cis/session', |%header;
    my $response = $!ua.request($request);
    note self.^name ~ '::' ~ &?ROUTINE.name ~ ': for ' ~ self.vcenter ~ ' failed!' unless $response.is-success;
    note .exception.message without self!session-token-stash-path.IO.unlink;
    $!ua = Nil;
    $!created-time = Nil;
    $!last-accessed-time = Nil;
    $!user = Nil;
    $!vsphere-api-session-id = Nil;
}

=finish
