unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port::backing;

has Bool:D                                                                                      $.allow-guest-control   is required;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port::backing:D   $.backing               is required;
has Str:D                                                                                       $.label                 is required;
has Bool:D                                                                                      $.start-connected       is required;
has Str:D                                                                                       $.state                 is required;
has Bool:D                                                                                      $.yield-on-poll         is required;

=finish
