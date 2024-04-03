unit    class Hypervisor::VMware::vSphere::REST::vcenter::hosts:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Data::Dump::Tree;

use     Hypervisor::VMware::vSphere::REST::cis::session;
use     Hypervisor::VMware::vSphere::REST::vcenter::hosts::host;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::hosts::host %.hosts;
has     Bool $.listed is rw = False;

my      %identifier-to-name;

method host (Str:D $name is required) {
    return %!hosts{$name} if %!hosts{$name}:exists;
    die 'Unknown host name: ' ~ $name;
}

method list () {
    self!list unless self.listed;
    return %!hosts.values;
}

method names () {
    self!list unless self.listed;
    return %!hosts.keys.sort;
}

method dump (Str :$name) {
    my @names = self.names;
    @names[0] = $name with $name;
    for @names -> $name {
        say self.host($name).name;
        say "\t" ~ 'host identifier  = ' ~ self.host($name).identifier;
        say "\t" ~ 'connection state = ' ~ self.host($name).connection-state;
        say "\t" ~ 'power state      = ' ~ self.host($name).power-state with self.host($name).power-state;
    }
}

method !connect (Str:D $identifier is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }
method !create (Str:D $identifier is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }
method !delete (Str:D $identifier is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }
method !disconnect (Str:D $identifier is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }

### GET https://{server}/api/vcenter/host
method !list () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    my $content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/host');
    for $content.list -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<host>;
        %identifier-to-name{$identifier} = $name;
        %!hosts{$name}  = Hypervisor::VMware::vSphere::REST::vcenter::hosts::host.new(
            :connection-state(%v<connection_state>:exists ?? %v<connection_state> !! Nil),
            :$identifier,
            :$name,
            :power-state(%v<power_state>:exists           ?? %v<power_state>      !! Nil),
        );
    }
    self.listed = True;
}

=finish
