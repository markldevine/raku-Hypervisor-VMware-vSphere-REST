unit class Hypervisor::VMware::vSphere::REST::vcenter:ver<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

use Hypervisor::VMware::vSphere::REST::cis::session;

use Hypervisor::VMware::vSphere::REST::vcenter::clusters;
use Hypervisor::VMware::vSphere::REST::vcenter::datacenters;
use Hypervisor::VMware::vSphere::REST::vcenter::datastores;
use Hypervisor::VMware::vSphere::REST::vcenter::folders;
use Hypervisor::VMware::vSphere::REST::vcenter::hosts;
use Hypervisor::VMware::vSphere::REST::vcenter::networks;
use Hypervisor::VMware::vSphere::REST::vcenter::resource-pools;
use Hypervisor::VMware::vSphere::REST::vcenter::vms;

has Str  $.auth-login       is required;
has Str  $.root-stash-path  = $*HOME ~ '/.rakucache/Hypervisor/VMware/vSphere/REST';
has Str  $.vcenter          is required;
has Bool $.use-cache        is rw = False;

### Attributes
has Hypervisor::VMware::vSphere::REST::cis::session             $.session;
has Hypervisor::VMware::vSphere::REST::vcenter::clusters        $.clusters;
has Hypervisor::VMware::vSphere::REST::vcenter::datacenters     $.datacenters;
has Hypervisor::VMware::vSphere::REST::vcenter::datastores      $.datastores;
has Hypervisor::VMware::vSphere::REST::vcenter::folders         $.folders;
has Hypervisor::VMware::vSphere::REST::vcenter::hosts           $.hosts;
has Hypervisor::VMware::vSphere::REST::vcenter::networks        $.networks;
has Hypervisor::VMware::vSphere::REST::vcenter::resource-pools  $.resource-pools;
has Hypervisor::VMware::vSphere::REST::vcenter::vms             $.vms;

submethod TWEAK {
    $!session           = Hypervisor::VMware::vSphere::REST::cis::session.new(:$!auth-login, :$!root-stash-path, :$!use-cache, :$!vcenter);
    $!clusters          = Hypervisor::VMware::vSphere::REST::vcenter::clusters.new(:$!session);
    $!datacenters       = Hypervisor::VMware::vSphere::REST::vcenter::datacenters.new(:$!session);
    $!datastores        = Hypervisor::VMware::vSphere::REST::vcenter::datastores.new(:$!session);
    $!folders           = Hypervisor::VMware::vSphere::REST::vcenter::folders.new(:$!session);
    $!hosts             = Hypervisor::VMware::vSphere::REST::vcenter::hosts.new(:$!session);
    $!networks          = Hypervisor::VMware::vSphere::REST::vcenter::networks.new(:$!session);
    $!resource-pools    = Hypervisor::VMware::vSphere::REST::vcenter::resource-pools.new(:$!session);
    $!vms               = Hypervisor::VMware::vSphere::REST::vcenter::vms.new(:$!session);
    self;
}

method dump {
    say '-' x 80;   self.clusters.dump;
    say '-' x 80;   self.datacenters.dump;
    say '-' x 80;   self.datastores.dump;
    say '-' x 80;   self.folders.dump;
    say '-' x 80;   self.hosts.dump;
    say '-' x 80;   self.networks.dump;
    say '-' x 80;   self.resource-pools.dump;
    say '-' x 80;   self.vms.dump;
}

=finish
