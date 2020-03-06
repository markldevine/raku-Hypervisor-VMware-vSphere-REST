unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom;

has     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom %.cdroms;

method list () {
    return self.cdroms.keys.sort;
}

method cdrom (Str:D $name is required) {
    return %!cdroms{$name} if %!cdroms{$name}:exists;
    die 'Unknown cdrom name: ' ~ $name;
}

=finish
