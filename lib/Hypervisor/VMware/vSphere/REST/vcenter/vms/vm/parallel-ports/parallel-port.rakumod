unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port::backing;

has Bool:D                                                                                          $.allow-guest-control   is required;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port::backing:D   $.backing               is required;
has Str:D                                                                                           $.label                 is required;
has Bool:D                                                                                          $.start-connected       is required;
has Str:D                                                                                           $.state                 is required;

=finish
