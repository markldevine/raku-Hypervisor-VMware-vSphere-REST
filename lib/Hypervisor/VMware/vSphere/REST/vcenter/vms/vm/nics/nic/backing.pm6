unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic::backing:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has Int     $.connection-cookie;
has Str     $.distributed-port;
has Str     $.distributed-switch-uuid;
has Str     $.host-device;
has Str     $.network;
has Str     $.network-name;
has Str     $.opaque-network-id;
has Str     $.opaque-network-type;
has Str:D   $.type                      is required;

=finish
