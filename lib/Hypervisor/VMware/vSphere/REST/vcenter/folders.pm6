unit    class Hypervisor::VMware::vSphere::REST::vcenter::folders:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::cis::session;
use     Hypervisor::VMware::vSphere::REST::vcenter::folders::folder;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::folders::folder %folders;
has     Bool $.listed is rw = False;

my      %identifier-to-name;

method folder (Str:D $name is required) {
    return %!folders{$name} if %!folders{$name}:exists;
    die 'Unknown folder name: ' ~ $name;
}

method list () {
    self!list unless self.listed;
    return %!folders.keys.sort;
}

method dump (Str :$name) {
    my @names = self.list;
    @names = ( $name ) with $name;
    for @names -> $name {
        say self.folder($name).name;
        say "\t" ~ 'folder identifier = ' ~ self.folder($name).identifier;
        say "\t" ~ 'type              = ' ~ self.folder($name).type;
    }
}

### GET https://{server}/rest/vcenter/folder
method !list () {
#say self.^name ~ '::' ~ &?ROUTINE.name;
    my %content = $!session.fetch('https://' ~ $!session.vcenter ~ '/rest/vcenter/folder');
    for %content<value>.list -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<folder>;
        %identifier-to-name{$identifier} = $name;
        %!folders{$name} = Hypervisor::VMware::vSphere::REST::vcenter::folders::folder.new(
            :$identifier,
            :$name,
            :type(%v<type>:exists ?? %v<type> !! Nil),
        );
    }
    self.listed = True;
}

=finish
