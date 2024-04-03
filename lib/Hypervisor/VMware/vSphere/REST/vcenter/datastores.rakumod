unit    class Hypervisor::VMware::vSphere::REST::vcenter::datastores:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::cis::session;
use     Hypervisor::VMware::vSphere::REST::vcenter::datastores::datastore;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::datastores::datastore %.datastores;
has     Bool $.listed is rw = False;

my      %identifier-to-name;

method datastore (Str:D $name is required) {
    return %!datastores{$name} if %!datastores{$name}:exists;
    die 'Unknown datastore name: ' ~ $name;
}

method query (Str:D $identifier is required) {
    self!list unless self.listed;
    if %identifier-to-name{$identifier}:exists {
        my $name = %identifier-to-name{$identifier};
        return if self.datastore($name).queried;
        return self!get($identifier);
    }
    die 'Unknown datastore identifier: ' ~ $identifier;
}

method list () {
    self!list unless self.listed;
    return %!datastores.keys.sort;
}

method dump (Str :$name) {
    my @names = self.list;
    @names = ( $name ) with $name;
    for @names -> $name {
        my $identifier = self.datastore($name).identifier;
        self.query($identifier);
        say self.datastore($name).name;
        say "\t" ~ 'datastore identifier        = ' ~ self.datastore($name).identifier;
        say "\t" ~ 'accessible                  = ' ~ self.datastore($name).accessible;
        say "\t" ~ 'capacity                    = ' ~ self.datastore($name).capacity;
        say "\t" ~ 'free-space                  = ' ~ self.datastore($name).free-space;
        say "\t" ~ 'multiple-host-access        = ' ~ self.datastore($name).multiple-host-access;
        say "\t" ~ 'thin-provisioning-supported = ' ~ self.datastore($name).thin-provisioning-supported;
        say "\t" ~ 'type                        = ' ~ self.datastore($name).type;
    }
}

### GET https://{server}/api/vcenter/datastore/{datastore}
method !get (Str:D $identifier is required) {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my @content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/datastore/' ~ $identifier);
    my $name = %identifier-to-name{$identifier};
    for @content -> %v {
        self.datastore($name).accessible                    = %v<accessible>                    if %v<accessible>:exists;
        self.datastore($name).multiple-host-access          = %v<multiple_host_access>          if %v<multiple_host_access>:exists;
        self.datastore($name).thin-provisioning-supported   = %v<thin_provisioning_supported>   if %v<thin_provisioning_supported>:exists;
    }
    self.datastore($name).queried = True;
}

### GET https://{server}/api/vcenter/datastore
method !list () {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my @content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/datastore');
    for @content -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<datastore>;
        %identifier-to-name{$identifier} = $name;
        %!datastores{$name}   = Hypervisor::VMware::vSphere::REST::vcenter::datastores::datastore.new(
            :capacity(%v<capacity>:exists       ?? %v<capacity>     !! Nil),
            :$identifier,
            :free-space(%v<free_space>:exists   ?? %v<free_space>   !! Nil),
            :$name,
            :type(%v<type>:exists               ?? %v<type>         !! Nil),
        );
    }
    self.listed = True;
}

=finish
