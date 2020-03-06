unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::memory:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Bool:D  $.hot-add-enabled               is required;
has Int     $.hot-add-increment-size-MiB;
has Int     $.hot-add-limit-MiB;
has Int:D   $.size-MiB                      is required;

=finish
