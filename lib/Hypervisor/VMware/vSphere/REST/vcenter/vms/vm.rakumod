unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cpu;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::hardware;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::memory;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters;
use Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports;

has Int $.cpu-count;
has Int $.memory-size-MiB;
has Str $.name              is required;
has Str $.power-state       is required;
has Str $.identifier        is required;

has Bool $.queried          is rw = False;

has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot           $.boot              is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices   $.boot-devices      is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms         $.cdroms            is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cpu            $.cpu               is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks          $.disks             is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies       $.floppies          is rw;
has Str                                                                 $.guest-OS          is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::hardware       $.hardware          is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::memory         $.memory            is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics           $.nics              is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports $.parallel-ports    is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters  $.sata-adapters     is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters  $.scsi-adapters     is rw;
has Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports   $.serial-ports      is rw;

=finish
