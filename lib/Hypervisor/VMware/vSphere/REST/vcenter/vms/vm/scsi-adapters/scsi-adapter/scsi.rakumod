unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter::scsi:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Int:D $.bus                 is required;
has Int   $.pci-slot-number;
has Int:D $.unit                is required;

=finish
