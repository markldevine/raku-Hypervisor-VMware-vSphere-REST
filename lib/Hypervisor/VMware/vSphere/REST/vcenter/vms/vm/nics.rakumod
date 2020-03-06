unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic;

has     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic %.nics;

method list () {
    return self.nics.keys.sort;
}

method nic (Str:D $name is required) {
    return %!nics{$name} if %!nics{$name}:exists;
    die 'Unknown nic name: ' ~ $name;
}

=finish
