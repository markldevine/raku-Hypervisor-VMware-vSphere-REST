unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies::floppy::backing:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Bool    $.auto-detect;
has Str:D   $.type          is required;
has Str     $.host-device;
has Str     $.image-file;

=finish
