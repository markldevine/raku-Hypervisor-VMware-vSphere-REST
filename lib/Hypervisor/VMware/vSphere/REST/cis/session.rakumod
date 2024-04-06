unit         class Hypervisor::VMware::vSphere::REST::cis::session:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Data::Dump::Tree;

use         Cro::HTTP::Client;
use         Cro::Uri;
use         JSON::Fast;
use         KHPH;

use          Hypervisor::VMware::vSphere::REST::Grammars::DateTime;

constant     MINIMUM-ROOT-STASH-PATH-DEPTH = 2;

has Str      $.auth-login;
has Str      $.root-stash-path  = $*HOME ~ '/.rakucache/Hypervisor/VMware/vSphere/REST';
has Str      $.user-agent       = 'Raku Cro::HTTP::Client';
has Str:D    $.vcenter          is required;

has DateTime $.created-time;
has DateTime $.last-accessed-time;
has Str      $.user;

has Bool     $.use-cache        is rw = False;

has Str      $.vmware-api-session-id;

has Cro::HTTP::Client $.http-client;

my $Cache-Dir;

class Cache-Endpoint {
    has Str         $.json-path;
    has Cro::Uri    $.uri;
    has Bool        $.valid is rw;
}

submethod TWEAK {
    $!auth-login    = ~$*USER without $!auth-login;
    my @dirs        = self.root-stash-path.IO.path.split('/');
    die ':root-stash-path must be at least ' ~ MINIMUM-ROOT-STASH-PATH-DEPTH ~ ' deep - more subdirectories required.' unless @dirs.elems >= MINIMUM-ROOT-STASH-PATH-DEPTH;
    mkdir(self.root-stash-path) unless self.root-stash-path.IO.e;
    chmod(0o3777, self.root-stash-path) unless self.root-stash-path.IO.mode == 3777;
    $Cache-Dir      = self.root-stash-path ~ '/.cache';
    mkdir($Cache-Dir) unless $Cache-Dir.IO.e;
    chmod(0o1777, $Cache-Dir) unless ~$Cache-Dir.IO.mode == 1777;
    $!http-client   = Cro::HTTP::Client.new(
                        auth        => {
                                            username    => self.auth-login,
                                            password    => KHPH.new(:stash-path(self!password-stash-path)).expose,
                                            if-asked    => True,
                                       },
                        ca          => { :insecure },
                        user-agent  => self.user-agent,
                      );
}

method !get-cache-entry (Str:D $uri-str) {
#   say self.^name ~ '::!' ~ &?ROUTINE.name;
    my $uri         = Cro::Uri.parse($uri-str);
    my @dirs        = $uri.path-segments;
    my $child       = @dirs.pop;
    my $parent      = @dirs.pop;
    my $base        = $Cache-Dir ~ '/' ~ $*USER ~ '/' ~ $uri.host ~ @dirs.join('/') ~ '/' ~ $parent;
    mkdir($base)    unless $base.IO.e;
    chmod(0o700, $base) unless ~$base.IO.mode == 700;

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

method fetch (Str:D $uri-str, :%query) {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    my $cache-entry = self!get-cache-entry($uri-str);
    return from-json(slurp($cache-entry.json-path)) if self.use-cache && $cache-entry.valid;
    self!get-vmware-api-session-id;
    my $response;
    try {
        CATCH {
            when X::Cro::HTTP::Error {
                die "Problem fetching " ~ .request.target;
            }
            when 'stale vmware-api-session-id' {
                self!delete;
                $!vmware-api-session-id = Nil;
                die '$!vmware-api-session-id expired:  renewed now; try again...';                                      #%%%%%%%%%%%%%
            }
            default                             { die $_; }
        }
        if %query.elems {
            $response = await self.http-client.get($uri-str, headers => [ vmware-api-session-id => self.vmware-api-session-id ], :%query);
        }
        else {
            $response = await self.http-client.get($uri-str, headers => [ vmware-api-session-id => self.vmware-api-session-id ]);
        }
    }
    my $body = await $response.body;
    spurt($cache-entry.json-path, to-json($body));
    return $body;
}

method !password-stash-path () {
    return(self.root-stash-path ~ '/.credentials' ~ '/api/session/' ~ self.vcenter ~ '/' ~ self.auth-login ~ '/' ~ $*USER ~ '/' ~ 'password.khph');
}

method !session-token-stash-path () {
    return(self.root-stash-path ~ '/.credentials' ~ '/api/session/' ~ self.vcenter ~ '/' ~ self.auth-login ~ '/' ~ $*USER ~ '/' ~ 'session-token.khph');
}

### POST https://{server}/api/session
method !get-vmware-api-session-id () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    $!vmware-api-session-id = Nil;
    $!vmware-api-session-id = KHPH.new(:stash-path(self!session-token-stash-path)).expose if self!session-token-stash-path.IO ~~ :s;
    return self.vmware-api-session-id if self.vmware-api-session-id;
    CATCH {
        when X::Cro::HTTP::Error {
            note self.^name ~ '::' ~ &?ROUTINE.name ~ ': ' ~ $_;
            exit 500;
        }
    }
    my $response    = await self.http-client.post: 'https://' ~ $!vcenter ~ '/api/session';
    my $vmware-api-session-id = await $response.body;
    die self.^name ~ '::' ~ &?ROUTINE.name ~ ': Unable to find vmware-api-session-id in response headers' unless $vmware-api-session-id;
    $!vmware-api-session-id  = $vmware-api-session-id;
    $ = KHPH.new(:secret($!vmware-api-session-id), :stash-path(self!session-token-stash-path));
    return self.vmware-api-session-id;
}

#%%%    < v7
### POST https://{server}/rest/com/vmware/cis/session?~action=get
#method get () {
##   say self.^name ~ '::' ~ &?ROUTINE.name;
#    my $uri                 = Cro::Uri.new('https://' ~ self.vcenter ~ '/rest/com/vmware/cis/session?~action=get');
#    my %header;
#    %header<vmware-api-session-id> = $!vmware-api-session-id;
#    my $response            = $!http-client.post($uri, %, |%header);
#    die self.^name ~ '::' ~ &?ROUTINE.name ~ ': for ' ~ self.vcenter ~ ' failed!' unless $response.is-success;
#    my %content             = from-json($response.content);
#    my $actions             = Hypervisor::VMware::vSphere::REST::Grammars::DateTime::Actions.new;
#    $!created-time          = Hypervisor::VMware::vSphere::REST::Grammars::DateTime.parse(%content<value><created_time>, :$actions).made;
#    $!last-accessed-time    = Hypervisor::VMware::vSphere::REST::Grammars::DateTime.parse(%content<value><last_accessed_time>, :$actions).made;
#    $!user = %content<value><user>;
#}

### DELETE https://{server}/rest/com/vmware/cis/session
method !delete () {
    say self.^name ~ '::' ~ &?ROUTINE.name;
    $ = await Cro::HTTP::Client.delete('https://' ~ $!vcenter ~ '/rest/com/vmware/cis/session', headers => [ vmware-api-session-id => self.vmware-api-session-id ]);
    CATCH {
        when X::Cro::HTTP::Error {
            note "self.^name ~ '::' ~ &?ROUTINE.name ~ 'Unexpected error: $_";
        }
    }
    self!session-token-stash-path.IO.unlink;
    $!created-time = Nil;
    $!last-accessed-time = Nil;
    $!vmware-api-session-id = Nil;
}

=finish
