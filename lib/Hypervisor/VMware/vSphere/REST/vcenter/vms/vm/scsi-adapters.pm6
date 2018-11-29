unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter;

has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter %.scsi-adapters;

method list () {
    return self.scsi-adapters.keys.sort;
}

method scsi-adapter (Str:D $name is required) {
    return %!scsi-adapters{$name} if %!scsi-adapters{$name}:exists;
    die 'Unknown scsi adapter name: ' ~ $name;
}

=finish
