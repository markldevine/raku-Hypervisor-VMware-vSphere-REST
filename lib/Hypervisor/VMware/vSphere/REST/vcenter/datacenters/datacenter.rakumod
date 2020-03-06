unit        class Hypervisor::VMware::vSphere::REST::vcenter::datacenters::datacenter:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Str:D   $.identifier        is required;
has Str     $.datastore-folder  is rw;
has Str     $.host-folder       is rw;
has Str:D   $.name              is required;
has Str     $.network-folder    is rw;
has Str     $.vm-folder         is rw;

has Bool    $.queried           is rw = False;

=finish
