unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk;

has     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk %.disks;

method list () {
    return self.disks.keys.sort;
}

method disk (Str:D $name is required) {
    return %!disks{$name} if %!disks{$name}:exists;
    die 'Unknown disk name: ' ~ $name;
}

=finish
