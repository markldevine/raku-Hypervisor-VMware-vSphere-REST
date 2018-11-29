unit        class Hypervisor::VMware::vSphere::REST::vcenter::resource-pools::resource-pool:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Str:D   $.identifier        is required;
has Str:D   $.name              is required;
has Str     @.resource-pools    is rw;
has Bool    $.queried           is rw           = False;

=finish
