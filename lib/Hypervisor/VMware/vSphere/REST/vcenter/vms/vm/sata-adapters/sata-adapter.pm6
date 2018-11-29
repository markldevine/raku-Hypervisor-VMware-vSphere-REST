unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters::sata-adapter:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Int:D   $.bus               is required;
has Str:D   $.label             is required;
has Int     $.pci-slot-number;
has Str:D   $.type              is required;

=finish
