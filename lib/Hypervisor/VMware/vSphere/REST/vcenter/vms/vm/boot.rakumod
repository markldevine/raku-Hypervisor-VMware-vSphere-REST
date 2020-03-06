unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Int:D   $.delay             is required;
has Bool    $.efi-legacy-boot   = False;
has Bool:D  $.enter-setup-mode  is required;
has Str     $.network-protocol;
has Bool:D  $.retry             is required;
has Int:D   $.retry-delay       is required;
has Str:D   $.type              is required;

=finish
