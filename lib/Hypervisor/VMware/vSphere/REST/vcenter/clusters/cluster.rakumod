unit        class Hypervisor::VMware::vSphere::REST::vcenter::clusters::cluster:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Str:D   $.identifier        is required;
has Bool:D  $.drs-enabled       is required;
has Bool:D  $.ha-enabled        is required;
has Str:D   $.name              is required;
has Str     $.resource-pool     is rw;

has Bool    $.queried           is rw = False;

=finish
