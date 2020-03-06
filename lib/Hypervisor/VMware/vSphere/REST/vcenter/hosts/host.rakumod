unit        class Hypervisor::VMware::vSphere::REST::vcenter::hosts::host:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

has Str:D   $.connection-state  is required;
has Str:D   $.identifier        is required;
has Str:D   $.name              is required;
has Str     $.power-state       is required;

=finish
