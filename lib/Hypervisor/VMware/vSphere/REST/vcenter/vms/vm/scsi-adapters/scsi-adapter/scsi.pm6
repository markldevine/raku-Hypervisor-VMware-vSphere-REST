unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter::scsi:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Int:D $.bus                 is required;
has Int   $.pci-slot-number;
has Int:D $.unit                is required;

=finish
