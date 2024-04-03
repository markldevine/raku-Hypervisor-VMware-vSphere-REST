unit    class Hypervisor::VMware::vSphere::REST::vcenter::datacenters:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::cis::session;
use     Hypervisor::VMware::vSphere::REST::vcenter::datacenters::datacenter;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::datacenters::datacenter %.datacenters;
has     Bool $.listed is rw = False;

my      %identifier-to-name;

method datacenter (Str:D $name is required) {
    return %!datacenters{$name} if %!datacenters{$name}:exists;
    die 'Unknown datacenter name: ' ~ $name;
}

method query (Str:D $identifier is required) {
    self!list unless self.listed;
    if %identifier-to-name{$identifier}:exists {
        my $name = %identifier-to-name{$identifier};
        return if self.datacenter($name).queried;
        return self!get($identifier);
    }
    die 'Unknown datacenter identifier: ' ~ $identifier;
}

method list () {
    self!list unless self.listed;
    return %!datacenters.keys.sort;
}

method dump (Str :$name) {
    my @names = self.list;
    @names = ( $name ) with $name;
    for @names -> $name {
        my $identifier = self.datacenter($name).identifier;
        self.query($identifier);
        say self.datacenter($name).name;
        say "\t" ~ 'datacenter identifier = ' ~ self.datacenter($name).identifier;
        say "\t" ~ 'datastore-folder      = ' ~ self.datacenter($name).datastore-folder;
        say "\t" ~ 'host-folder           = ' ~ self.datacenter($name).host-folder;
        say "\t" ~ 'network-folder        = ' ~ self.datacenter($name).network-folder;
        say "\t" ~ 'vm-folder             = ' ~ self.datacenter($name).vm-folder;
    }
}

method !create (Str:D $identifier is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }
method !delete (Str:D $identifier is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }

### GET https://{server}/api/vcenter/datacenter/{datacenter}
method !get (Str:D $identifier is required) {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my @content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/datacenter/' ~ $identifier);
    my $name = %identifier-to-name{$identifier};
    for @content -> %v {
        self.datacenter($name).datastore-folder = %v<datastore_folder> if %v<datastore_folder>:exists;
        self.datacenter($name).host-folder      = %v<host_folder>      if %v<host_folder>:exists;
        self.datacenter($name).network-folder   = %v<network_folder>   if %v<network_folder>:exists;
        self.datacenter($name).vm-folder        = %v<vm_folder>        if %v<vm_folder>:exists;
    }
    self.datacenter($name).queried = True;
}

### GET https://{server}/api/vcenter/datacenter
method !list () {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my @content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/datacenter');
    for @content -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<datacenter>;
        %identifier-to-name{$identifier} = $name;
        %!datacenters{$name} = Hypervisor::VMware::vSphere::REST::vcenter::datacenters::datacenter.new(
            :$identifier,
            :$name,
        );
    }
    self.listed = True;
}

=finish
