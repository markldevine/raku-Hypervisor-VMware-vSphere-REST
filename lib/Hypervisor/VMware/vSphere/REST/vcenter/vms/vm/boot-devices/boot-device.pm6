unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices::boot-device:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Str     @.disks;
has Str     $.nic;
has Str:D   $.type  is required;

=finish
