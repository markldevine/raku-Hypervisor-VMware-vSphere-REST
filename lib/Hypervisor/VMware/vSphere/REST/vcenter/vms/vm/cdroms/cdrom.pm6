unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::backing;
use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::ide;
use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::sata;

has  Bool:D                                                                         $.allow-guest-control   is required;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::backing:D  $.backing is required;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::ide        $.ide;
has  Str:D                                                                          $.label                 is required;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::sata       $.sata;
has  Bool:D                                                                         $.start-connected       is required;
has  Str:D                                                                          $.state                 is required;
has  Str:D                                                                          $.type                  is required;

=finish
