unit    class Hypervisor::VMware::vSphere::REST::vcenter::resource-pools:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::cis::session;
use     Hypervisor::VMware::vSphere::REST::vcenter::resource-pools::resource-pool;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::resource-pools::resource-pool %.resource-pools;
has     Bool $.listed is rw = False;

my      %identifier-to-name;

method resource-pool (Str:D $name is required) {
    return %!resource-pools{$name} if %!resource-pools{$name}:exists;
    die 'Unknown resource-pool name: ' ~ $name;
}

method query (Str $identifier is required) {
    self!list unless self.listed;
    if %identifier-to-name{$identifier}:exists {
        my $name = %identifier-to-name{$identifier};
        return if self.resource-pool($name).queried;
        return self!get($identifier);
    }
    die 'Unknown resource-pool identifier: ' ~ $identifier;
}

method list () {
    self!list unless self.listed;
    return %!resource-pools.keys.sort;
}

method dump (Str :$name) {
    my @names = self.list;
    @names = ( $name ) with $name;
    for @names -> $name {
        my $identifier = self.resource-pool($name).identifier;
        self.query($identifier);
        say self.resource-pool($name).name;
        say "\t" ~ 'resource-pool identifier  = ' ~ self.resource-pool($name).identifier;
        say "\t" ~ 'resource-pools            = ' ~ self.resource-pool($name).resource-pools.join(', ');
    }
}

### GET https://{server}/rest/vcenter/resource-pool/{resource_pool}
method !get (Str:D $identifier is required) {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my %content = $!session.fetch('https://' ~ $!session.vcenter ~ '/rest/vcenter/resource-pool/' ~ $identifier);
    my $name = %identifier-to-name{$identifier};
    for %content<value> -> %v {
        self.resource-pool($name).resource-pools = %v<resource_pools>.Array if %v<resource_pools>:exists;
    }
    self.resource-pool($name).queried = True;
}

### GET https://{server}/rest/vcenter/resource-pool
method !list () {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my %content = $!session.fetch('https://' ~ $!session.vcenter ~ '/rest/vcenter/resource-pool');
    for %content<value>.list -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<resource_pool>;
        %identifier-to-name{$identifier} = $name;
        %!resource-pools{$name} = Hypervisor::VMware::vSphere::REST::vcenter::resource-pools::resource-pool.new(
            :$identifier,
            :$name,
        );
    }
    self.listed = True;
}

=finish
