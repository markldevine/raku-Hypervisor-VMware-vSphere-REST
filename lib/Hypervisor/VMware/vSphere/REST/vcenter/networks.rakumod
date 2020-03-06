unit    class Hypervisor::VMware::vSphere::REST::vcenter::networks:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::cis::session;
use     Hypervisor::VMware::vSphere::REST::vcenter::networks::network;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::networks::network %.networks;
has     Bool $.listed is rw = False;

my      %identifier-to-name;

method network (Str:D $name is required) {
    return %!networks{$name} if %!networks{$name}:exists;
    die 'Unknown network name: ' ~ $name;
}

method list () {
    self!list unless self.listed;
    return %!networks.keys.sort;
}

method dump (Str :$name) {
    my @names = self.list;
    @names = ( $name ) with $name;
    for @names -> $name {
        say self.network($name).name;
        say "\t" ~ 'network identifier = ' ~ self.network($name).identifier;
        say "\t" ~ 'type               = ' ~ self.network($name).type;
    }
}

### GET https://{server}/rest/vcenter/network
method !list () {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my %content = $!session.fetch('https://' ~ $!session.vcenter ~ '/rest/vcenter/network');
    for %content<value>.list -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<network>;
        %identifier-to-name{$identifier} = $name;
        %!networks{$name} = Hypervisor::VMware::vSphere::REST::vcenter::networks::network.new(
            :$identifier,
            :$name,
            :type(%v<type>:exists ?? %v<type> !! Nil),
        );
    }
    self.listed = True;
}

=finish
