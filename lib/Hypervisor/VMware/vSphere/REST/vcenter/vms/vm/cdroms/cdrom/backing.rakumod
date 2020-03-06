unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::backing:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Bool    $.auto-detect;
has Str     $.device-access-type;
has Str     $.host-device;
has Str     $.iso-file;
has Str:D   $.type                  is required;

=finish
