unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port::backing:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Bool  $.auto-detect;
has Str   $.file;
has Str   $.host-device;
has Str:D $.type            is required;

=finish
