unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies::floppy;

has     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies::floppy %.floppies;

method list () {
    return self.floppies.keys.sort;
}

method floppy (Str:D $name is required) {
    return %!floppies{$name} if %!floppies{$name}:exists;
    die 'Unknown floppy name: ' ~ $name;
}

=finish
