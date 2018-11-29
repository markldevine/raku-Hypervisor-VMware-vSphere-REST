unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::memory:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Bool:D  $.hot-add-enabled               is required;
has Int     $.hot-add-increment-size-MiB;
has Int     $.hot-add-limit-MiB;
has Int:D   $.size-MiB                      is required;

=finish
