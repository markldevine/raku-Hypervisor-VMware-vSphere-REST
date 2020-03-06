unit        class Hypervisor::VMware::vSphere::REST::vcenter::datastores::datastore:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Bool    $.accessible                    is rw;
has Int:D   $.capacity                      is required;
has Str:D   $.identifier                    is required;
has Int:D   $.free-space                    is required;
has Bool    $.multiple-host-access          is rw;
has Str:D   $.name                          is required;
has Bool    $.thin-provisioning-supported   is rw;
has Str:D   $.type                          is required;

has Bool    $.queried                       is rw           = False;

=finish
