unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices::boot-device;

has     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices::boot-device @.boot-devices;

method list () {
    return self.boot-devices
}

=finish
