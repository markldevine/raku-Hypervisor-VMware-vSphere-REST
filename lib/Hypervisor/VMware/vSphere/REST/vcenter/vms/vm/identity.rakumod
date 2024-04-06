unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::identity:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Str:D   $.bios_uuid         is required;
has Str:D   $.instance_uuid     is required;
has Str:D   $.name              is required;

=finish
