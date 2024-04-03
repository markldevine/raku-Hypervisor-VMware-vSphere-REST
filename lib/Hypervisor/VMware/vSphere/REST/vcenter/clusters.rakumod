unit    class Hypervisor::VMware::vSphere::REST::vcenter::clusters:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::cis::session;
use     Hypervisor::VMware::vSphere::REST::vcenter::clusters::cluster;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::clusters::cluster %.clusters;
has     Bool $.listed is rw = False;

my      %identifier-to-name;

method cluster (Str:D $name is required) {
    return %!clusters{$name} if %!clusters{$name}:exists;
    die 'Unknown cluster name: ' ~ $name;
}

method query (Str:D $identifier is required) {
    self!list unless self.listed;
    if %identifier-to-name{$identifier}:exists {
        my $name = %identifier-to-name{$identifier};
        return if self.cluster($name).queried;
        return self!get($identifier);
    }
    die 'Unknown cluster identifier: ' ~ $identifier;
}

method list () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    self!list unless self.listed;
    return %!clusters.keys.sort;
}

method dump (Str :$name) {
    my @names = self.list;
    @names = ( $name ) with $name;
    for @names -> $name {
        my $identifier = self.cluster($name).identifier;
        self.query($identifier);
        say self.cluster($name).name;
        say "\t" ~ 'cluster identifier = ' ~ self.cluster($name).identifier;
        say "\t" ~ 'drs-enabled        = ' ~ self.cluster($name).drs-enabled;
        say "\t" ~ 'ha-enabled         = ' ~ self.cluster($name).ha-enabled;
        say "\t" ~ 'resource-pool      = ' ~ self.cluster($name).resource-pool;
    }
}

### GET https://{server}/api/vcenter/cluster/{cluster}
method !get (Str:D $identifier is required) {
#   say self.^name ~ '::!' ~ &?ROUTINE.name;
    my @content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/cluster/' ~ $identifier);
    my $name = %identifier-to-name{$identifier};
    for @content -> %v {
        self.cluster($name).resource-pool = %v<resource_pool> if %v<resource_pool>:exists;
    }
    self.cluster($name).queried = True;
}

### GET https://{server}/api/vcenter/cluster
method !list () {
#   say self.^name ~ '::!' ~ &?ROUTINE.name;
    my @content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/cluster');
    for @content -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<cluster>;
        %identifier-to-name{$identifier} = $name;
        %!clusters{$name}   = Hypervisor::VMware::vSphere::REST::vcenter::clusters::cluster.new(
            :$identifier,
            :drs-enabled(%v<drs_enabled>:exists ?? %v<drs_enabled>  !! Nil),
            :ha-enabled(%v<ha_enabled>:exists   ?? %v<ha_enabled>   !! Nil),
            :$name,
        );
    }
    self.listed = True;
}

=finish
