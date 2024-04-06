unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::backing;
use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::ide;
use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::nvme;
use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::sata;
use  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::scsi;

has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::backing  $.backing   is required;
has  Int                                                                        $.capacity;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::ide      $.ide;
has  Str:D                                                                      $.label     is required;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::nvme     $.nvme;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::sata     $.sata;
has  Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::scsi     $.scsi;
has  Str:D                                                                      $.type      is required;

=finish
