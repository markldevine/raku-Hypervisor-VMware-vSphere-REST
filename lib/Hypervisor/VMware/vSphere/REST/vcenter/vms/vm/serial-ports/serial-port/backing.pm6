unit class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port::backing:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use URI;

has Bool  $.auto-detect;
has Str   $.file;
has Str   $.host-device;
has URI   $.network-location;
has Bool  $.no-rx-loss;
has Str   $.pipe;
has URI   $.proxy;
has Str:D $.type                is required;

=finish
