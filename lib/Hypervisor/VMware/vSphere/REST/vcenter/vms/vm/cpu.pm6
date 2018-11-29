unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cpu:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Int:D   $.cores-per-socket      is required;
has Int:D   $.count                 is required;
has Bool:D  $.hot-add-enabled       is required;
has Bool:D  $.hot-remove-enabled    is required;

=finish
