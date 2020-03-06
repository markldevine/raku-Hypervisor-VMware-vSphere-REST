unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::hardware:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Str     %.upgrade-error;
has Str:D   $.upgrade-policy    is required;
has Str:D   $.upgrade-status    is required;
has Str     $.upgrade-version;
has Str:D   $.version           is required;

=finish
