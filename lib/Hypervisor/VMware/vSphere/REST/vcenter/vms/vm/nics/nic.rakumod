unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic::backing;

has  Bool:D                                                                     $.allow-guest-control           is required;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic::backing:D  $.backing                       is required;
has  Str:D                                                                      $.label                         is required;
has  Str                                                                        $.mac-address;
has  Str:D                                                                      $.mac-type                      is required;
has  Int                                                                        $.pci-slot-number;
has  Bool:D                                                                     $.start-connected               is required;
has  Str:D                                                                      $.state                         is required;
has  Str:D                                                                      $.type                          is required;
has  Bool                                                                       $.upt-compatibility-enabled;
has  Bool:D                                                                     $.wake-on-lan-enabled           is required;

=finish
