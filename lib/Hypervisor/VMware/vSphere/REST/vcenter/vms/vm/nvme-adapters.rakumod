unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters::nvme-adapter;

has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters::nvme-adapter %.nvme-adapters;

method list () {
    return self.nvme-adapters.keys.sort;
}

method nvme-adapter (Str:D $name is required) {
    return %!nvme-adapters{$name} if %!nvme-adapters{$name}:exists;
    die 'Unknown nvme adapter name: ' ~ $name;
}

=finish
