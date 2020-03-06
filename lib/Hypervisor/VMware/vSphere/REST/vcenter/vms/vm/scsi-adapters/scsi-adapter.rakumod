unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter::scsi;

has Str:D                                                                                       $.label     is required;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter::scsi:D    $.scsi      is required;
has Str:D                                                                                       $.sharing   is required;
has Str:D                                                                                       $.type      is required;

=finish
