unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters::sata-adapter;

has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters::sata-adapter %.sata-adapters;

method list () {
    return self.sata-adapters.keys.sort;
}

method sata-adapter (Str:D $name is required) {
    return %!sata-adapters{$name} if %!sata-adapters{$name}:exists;
    die 'Unknown sata adapter name: ' ~ $name;
}

=finish
