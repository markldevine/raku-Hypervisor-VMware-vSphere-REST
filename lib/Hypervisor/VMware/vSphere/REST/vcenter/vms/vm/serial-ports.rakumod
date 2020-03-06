unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port;

has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port %.serial-ports;

method list () {
    return self.serial-ports.keys.sort;
}

method serial-port (Str:D $name is required) {
    return %!serial-ports{$name} if %!serial-ports{$name}:exists;
    die 'Unknown serial port name: ' ~ $name;
}

=finish
