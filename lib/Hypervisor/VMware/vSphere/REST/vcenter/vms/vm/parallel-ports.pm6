unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port;

has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port %.parallel-ports;

method list () {
    return self.parallel-ports.keys.sort;
}

method parallel-port (Str:D $name is required) {
    return %!parallel-ports{$name} if %!parallel-ports{$name}:exists;
    die 'Unknown parallel port name: ' ~ $name;
}

=finish
