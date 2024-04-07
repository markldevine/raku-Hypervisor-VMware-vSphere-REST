unit    class Hypervisor::VMware::vSphere::REST::vcenter::vms:api<0.1.0>:auth<Mark Devine (mark@markdevine.com)>;

use Data::Dump::Tree;

use     Cro::Uri;

#   Session
use     Hypervisor::VMware::vSphere::REST::cis::session;
#   Symbol Imports
use     Hypervisor::VMware::vSphere::REST::vcenter::hosts::host;
#   Data structure
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices::boot-device;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::backing;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::ide;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::backing;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::ide;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::sata;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::scsi;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies::floppy;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::hardware;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::memory;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic::backing;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters::nvme-adapter;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port::backing;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters::sata-adapter;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter::scsi;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port;
use     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port::backing;

has     Hypervisor::VMware::vSphere::REST::cis::session:D $.session is required;
has     Hypervisor::VMware::vSphere::REST::vcenter::vms::vm %.vms;

has     Bool $.listed is rw = False;

my      %identifier-to-name;

method vm (Str:D $name is required) {
    return %!vms{$name} if %!vms{$name}:exists;
    die 'Unknown vm name: ' ~ $name;
}

method query (Str:D $identifier is required) {
    self!list unless self.listed;
    if %identifier-to-name{$identifier}:exists {
        my $name = %identifier-to-name{$identifier};
        return if self.vm($name).queried;
        return self!get($identifier);
    }
    die 'Unknown vm identifier: ' ~ $identifier;
}

multi method list () {
    self!list unless self.listed;
    return %!vms.keys.sort;
}

multi method list (Hypervisor::VMware::vSphere::REST::vcenter::hosts::host:D :$host-object) {
#   say self.^name ~ '::' ~ &?ROUTINE.name ~ ' multi for Hypervisor::VMware::vSphere::REST::vcenter::hosts::host:D';
    self!list-by-host-id(:$host-object);
    return %!vms.keys.sort;
}

method dump (Str :$name) {
    my @names = self.list;
    @names = ( $name ) with $name;
    for @names -> $vm-name {
        my $identifier = self.vm($vm-name).identifier;
        self.query($identifier);
        put self.vm($vm-name).name;
        put "\t" ~ 'vm identifier                                   = ' ~ self.vm($vm-name).identifier;
#       put "\t" ~ 'power state                                     = ' ~ self.vm($vm-name).power-state;
### boot
        put "\t" ~ 'boot';
        put "\t\t" ~ 'delay                                   = ' ~ self.vm($vm-name).boot.delay;
        put "\t\t" ~ 'efi legacy boot                         = ' ~ so self.vm($vm-name).boot.efi-legacy-boot;
        put "\t\t" ~ 'enter setup mode                        = ' ~ self.vm($vm-name).boot.enter-setup-mode;
        put "\t\t" ~ 'retry                                   = ' ~ self.vm($vm-name).boot.retry;
        put "\t\t" ~ 'retry delay                             = ' ~ self.vm($vm-name).boot.retry-delay;
        put "\t\t" ~ 'type                                    = ' ~ self.vm($vm-name).boot.type;
### boot-devices
        if self.vm($vm-name).boot-devices.list {
            put "\t" ~ 'boot devices';
            my $boot-device-index = 0;
            for self.vm($vm-name).boot-devices.list -> $boot-device {
                put "\t\t" ~ $boot-device-index++ ~ ':';
                put "\t\t\t" ~ 'disks                           = ' ~ $boot-device.disks.join(', ') if $boot-device.disks.elems;
                put "\t\t\t" ~ 'nic                             = ' ~ $boot-device.nic with $boot-device.nic;
                put "\t\t\t" ~ 'type                            = ' ~ $boot-device.type;
            }
        }
### cpu
        put "\t" ~ 'cpu';
        put "\t\t" ~ 'cores per socket                        = ' ~ self.vm($vm-name).cpu.cores-per-socket;
        put "\t\t" ~ 'count                                   = ' ~ self.vm($vm-name).cpu.count;
        put "\t\t" ~ 'hot add enabled                         = ' ~ self.vm($vm-name).cpu.hot-add-enabled;
        put "\t\t" ~ 'hot remove enabled                      = ' ~ self.vm($vm-name).cpu.hot-remove-enabled;
### cdroms
        put "\t" ~ 'cdroms';
        for self.vm($vm-name).cdroms.list -> $cdrom-name {
            put "\t\t" ~ $cdrom-name;
            put "\t\t\t" ~ 'allow guest control             = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).allow-guest-control;
            put "\t\t\t" ~ 'backing';
            put "\t\t\t\t" ~ 'auto detect             = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.auto-detect
                with self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.auto-detect;
            put "\t\t\t\t" ~ 'device access type      = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.device-access-type
                with self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.device-access-type;
            put "\t\t\t\t" ~ 'host device             = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.host-device
                with self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.host-device;
            put "\t\t\t\t" ~ 'iso file                = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.iso-file
                with self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.iso-file;
            put "\t\t\t\t" ~ 'type                    = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).backing.type;
            with self.vm($vm-name).cdroms.cdrom($cdrom-name).ide {
                put "\t\t\t" ~ 'ide';
                put "\t\t\t\t" ~ 'master                  = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).ide.master;
                put "\t\t\t\t" ~ 'primary                 = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).ide.primary;
            }
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).label;
            with self.vm($vm-name).cdroms.cdrom($cdrom-name).sata {
                put "\t\t\t" ~ 'sata';
                put "\t\t\t\t" ~ 'bus                     = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).sata.bus;
                put "\t\t\t\t" ~ 'unit                    = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).sata.unit;
            }
            put "\t\t\t" ~ 'start connected                 = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).start-connected;
            put "\t\t\t" ~ 'state                           = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).state;
            put "\t\t\t" ~ 'type                            = ' ~ self.vm($vm-name).cdroms.cdrom($cdrom-name).type;
        }
### disks
        put "\t" ~ 'disks';
        for self.vm($vm-name).disks.list -> $disk-name {
            put "\t\t" ~ $disk-name;
            put "\t\t\t" ~ 'backing';
            put "\t\t\t\t" ~ 'type                    = ' ~ self.vm($vm-name).disks.disk($disk-name).backing.type;
            put "\t\t\t\t" ~ 'vmdk file               = ' ~ self.vm($vm-name).disks.disk($disk-name).backing.vmdk-file
                with self.vm($vm-name).disks.disk($disk-name).backing.vmdk-file;
            put "\t\t\t" ~ 'capacity                        = ' ~ self.vm($vm-name).disks.disk($disk-name).capacity
                with self.vm($vm-name).disks.disk($disk-name).capacity;
            with self.vm($vm-name).disks.disk($disk-name).ide {
                put "\t\t\t" ~ 'ide';
                put "\t\t\t\t" ~ 'master                  = ' ~ self.vm($vm-name).disks.disk($disk-name).ide.master;
                put "\t\t\t\t" ~ 'primary                 = ' ~ self.vm($vm-name).disks.disk($disk-name).ide.primary;
            }
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).disks.disk($disk-name).label;
            with self.vm($vm-name).disks.disk($disk-name).sata {
                put "\t\t\t" ~ 'sata';
                put "\t\t\t\t" ~ 'bus                     = ' ~ self.vm($vm-name).disks.disk($disk-name).sata.bus;
                put "\t\t\t\t" ~ 'unit                    = ' ~ self.vm($vm-name).disks.disk($disk-name).sata.unit;
            }
            with self.vm($vm-name).disks.disk($disk-name).scsi {
                put "\t\t\t" ~ 'scsi';
                put "\t\t\t\t" ~ 'bus                     = ' ~ self.vm($vm-name).disks.disk($disk-name).scsi.bus;
                put "\t\t\t\t" ~ 'unit                    = ' ~ self.vm($vm-name).disks.disk($disk-name).scsi.unit;
            }
            put "\t\t\t" ~ 'type                            = ' ~ self.vm($vm-name).disks.disk($disk-name).type;
        }
### floppies
        put "\t" ~ 'floppies';
        for self.vm($vm-name).floppies.list -> $floppy-name {
            put "\t\t" ~ $floppy-name;
            put "\t\t\t" ~ 'allow guest control             = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).allow-guest-control;
            put "\t\t\t" ~ 'backing';
            put "\t\t\t\t" ~ 'auto-detect             = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).backing.auto-detect
                with self.vm($vm-name).floppies.floppy($floppy-name).backing.auto-detect;
            put "\t\t\t\t" ~ 'type                    = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).backing.type;
            put "\t\t\t\t" ~ 'host device             = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).backing.host-device
                with self.vm($vm-name).floppies.floppy($floppy-name).backing.host-device;
            put "\t\t\t\t" ~ 'image file              = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).backing.image-file
                with self.vm($vm-name).floppies.floppy($floppy-name).backing.image-file;
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).label;
            put "\t\t\t" ~ 'start connected                 = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).start-connected;
            put "\t\t\t" ~ 'state                           = ' ~ self.vm($vm-name).floppies.floppy($floppy-name).state;
        }
### guest OS
        put "\t" ~ 'guest OS                                        = ' ~ self.vm($vm-name).guest-OS;
### hardware
        put "\t" ~ 'hardware';
        put "\t\t" ~ 'upgrade error                           = ' ~ self.vm($vm-name).hardware.upgrade-error.kv
            if self.vm($vm-name).hardware.upgrade-error.elems;
        put "\t\t" ~ 'upgrade policy                          = ' ~ self.vm($vm-name).hardware.upgrade-policy;
        put "\t\t" ~ 'upgrade status                          = ' ~ self.vm($vm-name).hardware.upgrade-status;
        put "\t\t" ~ 'upgrade version                         = ' ~ self.vm($vm-name).hardware.upgrade-version
            with self.vm($vm-name).hardware.upgrade-version;
        put "\t\t" ~ 'version                                 = ' ~ self.vm($vm-name).hardware.version;
### memory
        put "\t" ~ 'memory';
        put "\t\t" ~ 'hot add enabled                         = ' ~ self.vm($vm-name).memory.hot-add-enabled;
        put "\t\t" ~ 'hot add increment size MiB              = ' ~ self.vm($vm-name).memory.hot-add-increment-size-MiB
            with self.vm($vm-name).memory.hot-add-increment-size-MiB;
        put "\t\t" ~ 'hot add limit MiB                       = ' ~ self.vm($vm-name).memory.hot-add-limit-MiB
            with self.vm($vm-name).memory.hot-add-limit-MiB;
        put "\t\t" ~ 'size MiB                                = ' ~ self.vm($vm-name).memory.size-MiB;
### nics
        put "\t" ~ 'nics';
        for self.vm($vm-name).nics.list -> $nic-name {
            put "\t\t" ~ $nic-name;
            put "\t\t\t" ~ 'allow guest control             = ' ~ self.vm($vm-name).nics.nic($nic-name).allow-guest-control;
            put "\t\t\t" ~ 'backing';
            put "\t\t\t\t" ~ 'connection cookie       = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.connection-cookie
                with self.vm($vm-name).nics.nic($nic-name).backing.connection-cookie;
            put "\t\t\t\t" ~ 'distributed port        = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.distributed-port
                with self.vm($vm-name).nics.nic($nic-name).backing.distributed-port;
            put "\t\t\t\t" ~ 'distributed switch uuid = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.distributed-switch-uuid
                with self.vm($vm-name).nics.nic($nic-name).backing.distributed-switch-uuid;
            put "\t\t\t\t" ~ 'host device             = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.host-device
                with self.vm($vm-name).nics.nic($nic-name).backing.host-device;
            put "\t\t\t\t" ~ 'network                 = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.network
                with self.vm($vm-name).nics.nic($nic-name).backing.network;
            put "\t\t\t\t" ~ 'opaque network id       = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.opaque-network-id
                with self.vm($vm-name).nics.nic($nic-name).backing.opaque-network-id;
            put "\t\t\t\t" ~ 'opaque-network-type      = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.opaque-network-type
                with self.vm($vm-name).nics.nic($nic-name).backing.opaque-network-type;
            put "\t\t\t\t" ~ 'network name            = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.network-name
                with self.vm($vm-name).nics.nic($nic-name).backing.network-name;
            put "\t\t\t\t" ~ 'type                    = ' ~ self.vm($vm-name).nics.nic($nic-name).backing.type;
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).nics.nic($nic-name).label;
            put "\t\t\t" ~ 'mac address                     = ' ~ self.vm($vm-name).nics.nic($nic-name).mac-address
                with self.vm($vm-name).nics.nic($nic-name).mac-address;
            put "\t\t\t" ~ 'mac type                        = ' ~ self.vm($vm-name).nics.nic($nic-name).mac-type;
            put "\t\t\t" ~ 'pci slot number                 = ' ~ self.vm($vm-name).nics.nic($nic-name).pci-slot-number
                with self.vm($vm-name).nics.nic($nic-name).pci-slot-number;
            put "\t\t\t" ~ 'start connected                 = ' ~ self.vm($vm-name).nics.nic($nic-name).start-connected;
            put "\t\t\t" ~ 'state                           = ' ~ self.vm($vm-name).nics.nic($nic-name).state;
            put "\t\t\t" ~ 'type                            = ' ~ self.vm($vm-name).nics.nic($nic-name).type;
            put "\t\t\t" ~ 'upt compatibility enabled       = ' ~ self.vm($vm-name).nics.nic($nic-name).upt-compatibility-enabled
                with self.vm($vm-name).nics.nic($nic-name).upt-compatibility-enabled;
            put "\t\t\t" ~ 'wake on lan enabled             = ' ~ self.vm($vm-name).nics.nic($nic-name).wake-on-lan-enabled;
        }
### parallel ports
        put "\t" ~ 'parallel ports';
        for self.vm($vm-name).parallel-ports.list -> $parallel-port-name {
            put "\t\t" ~ $parallel-port-name;
            put "\t\t\t" ~ 'allow guest control             = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).allow-guest-control;
            put "\t\t\t" ~ 'backing';
            put "\t\t\t\t" ~ 'auto-detect             = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).backing.auto-detect
                with self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).backing.auto-detect;
            put "\t\t\t\t" ~ 'file                    = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).backing.file
                with self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).backing.file;
            put "\t\t\t\t" ~ 'host device             = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).backing.host-device
                with self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).backing.host-device;
            put "\t\t\t\t" ~ 'type                    = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).backing.type;
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).label;
            put "\t\t\t" ~ 'start connected                 = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).start-connected;
            put "\t\t\t" ~ 'state                           = ' ~ self.vm($vm-name).parallel-ports.parallel-port($parallel-port-name).state;
        }
### power state
        put "\t" ~ 'power state                                     = ' ~ self.vm($vm-name).power-state;
### sata adapters
        put "\t" ~ 'sata adapters';
        for self.vm($vm-name).sata-adapters.list -> $sata-adapter-name {
            put "\t\t" ~ $sata-adapter-name;
            put "\t\t\t" ~ 'bus                             = ' ~ self.vm($vm-name).sata-adapters.sata-adapter($sata-adapter-name).bus;
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).sata-adapters.sata-adapter($sata-adapter-name).label;
            put "\t\t\t" ~ 'pci slot number                 = ' ~ self.vm($vm-name).sata-adapters.sata-adapter($sata-adapter-name).pci-slot-number
                with self.vm($vm-name).sata-adapters.sata-adapter($sata-adapter-name).pci-slot-number;
            put "\t\t\t" ~ 'type                            = ' ~ self.vm($vm-name).sata-adapters.sata-adapter($sata-adapter-name).type;
        }
### scsi adapters
        put "\t" ~ 'scsi adapters';
        for self.vm($vm-name).scsi-adapters.list -> $scsi-adapter-name {
            put "\t\t" ~ $scsi-adapter-name;
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).scsi-adapters.scsi-adapter($scsi-adapter-name).label;
            put "\t\t\t" ~ 'scsi';
            put "\t\t\t\t" ~ 'bus                     = ' ~ self.vm($vm-name).scsi-adapters.scsi-adapter($scsi-adapter-name).scsi.bus;
            put "\t\t\t\t" ~ 'pci-slot-number         = ' ~ self.vm($vm-name).scsi-adapters.scsi-adapter($scsi-adapter-name).scsi.pci-slot-number
                with self.vm($vm-name).scsi-adapters.scsi-adapter($scsi-adapter-name).scsi.pci-slot-number;
            put "\t\t\t\t" ~ 'unit                    = ' ~ self.vm($vm-name).scsi-adapters.scsi-adapter($scsi-adapter-name).scsi.unit;
            put "\t\t\t" ~ 'sharing                         = ' ~ self.vm($vm-name).scsi-adapters.scsi-adapter($scsi-adapter-name).sharing;
            put "\t\t\t" ~ 'type                            = ' ~ self.vm($vm-name).scsi-adapters.scsi-adapter($scsi-adapter-name).type;
        }
### serial ports
        put "\t" ~ 'serial ports';
        for self.vm($vm-name).serial-ports.list -> $serial-port-name {
            put "\t\t" ~ $serial-port-name;
            put "\t\t\t" ~ 'allow guest control             = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).allow-guest-control;
            put "\t\t\t" ~ 'backing';
            put "\t\t\t\t" ~ 'auto-detect             = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.auto-detect
                with self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.auto-detect;
            put "\t\t\t\t" ~ 'file                    = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.file
                with self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.file;
            put "\t\t\t\t" ~ 'host device             = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.host-device
                with self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.host-device;
            put "\t\t\t\t" ~ 'network location        = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.network-location
                with self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.network-location;
            put "\t\t\t\t" ~ 'no-rx-loss              = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.no-rx-loss
                with self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.no-rx-loss;
            put "\t\t\t\t" ~ 'pipe                    = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.pipe
                with self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.pipe;
            put "\t\t\t\t" ~ 'proxy                   = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.proxy
                with self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.proxy;
            put "\t\t\t\t" ~ 'type                    = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).backing.type;
            put "\t\t\t" ~ 'label                           = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).label;
            put "\t\t\t" ~ 'start connected                 = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).start-connected;
            put "\t\t\t" ~ 'state                           = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).state;
            put "\t\t\t" ~ 'yield on poll                   = ' ~ self.vm($vm-name).serial-ports.serial-port($serial-port-name).yield-on-poll;
        }
    }
}

### POST https://{server}/api/vcenter/vm/{vm}
method !create (Str:D $vm is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }

### DELETE https://{server}/api/vcenter/vm/{vm}
method !delete (Str:D $vm is required) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ': Not yet implemented'; }

### GET https://{server}/api/vcenter/vm/{vm}
method !get (Str:D $identifier is required) {
#   https://vdc-download.vmware.com/vmwb-repository/dcr-public/c2c7244e-817b-40d8-98f3-6c2ad5db56d6/af6d8ff7-1c38-4571-b72a-614ac319a62b/operations/com/vmware/vcenter/vm.get-operation.html
#   say self.^name ~ '::!' ~ &?ROUTINE.name;
    my %content;
    my $name = %identifier-to-name{$identifier};
    {
        CATCH { default { say self.^name ~ '::!' ~ &?ROUTINE.name ~ '(' ~ $name ~ '[' ~ $identifier ~ ']): ' ~ .Str; die; } }
        %content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/vm/' ~ $identifier);
        die 'Name mismatch! Requested Identifier <' ~ $identifier ~ '> maps to name <' ~ $name ~ '> however retrieved record has name <' ~ %content<name> ~ '>' unless $name eq %content<name>;
    }

### boot
    %!vms{$name}.boot           = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot.new(
        :delay(%content<boot><delay>),
        :efi-legacy-boot(%content<boot><efi_legacy_boot>:exists                                         ?? %content<boot><efi_legacy_boot>                                                  !! Nil),
        :enter-setup-mode(%content<boot><enter_setup_mode>),
        :network-protocol(%content<boot><network-protocol>:exists                                       ?? %content<boot><network-protocol>                                                 !! Nil),
        :retry(%content<boot><retry>),
        :retry-delay(%content<boot><retry_delay>),
        :type(%content<boot><type>),
    );

### boot_devices
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices::boot-device @boot-devices;
    for %content<boot_devices>.list -> %boot-device {
        @boot-devices.push: Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices::boot-device.new(
            :disks(%boot-device<disks>:exists                                                           ?? %boot-device<disks>                                                              !! Array.new()),
            :nic(%boot-device<nic>:exists                                                               ?? %boot-device<nic>                                                                !! Nil),
            :type(%boot-device<type>),
        );
    }
    %!vms{$name}.boot-devices   = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::boot-devices.new(:@boot-devices);

### cdroms
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom %cdroms;
    for %content<cdroms>.keys -> $cdrom {
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::backing $backing .= new(
            :auto-detect(%content<cdroms>{$cdrom}<backing><auto_detect>:exists                          ?? %content<cdroms>{$cdrom}<backing><auto_detect>                                   !! Nil),
            :device-access-type(%content<cdroms>{$cdrom}<backing><device_access_type>:exists            ?? %content<cdroms>{$cdrom}<backing><device_access_type>                            !! Nil),
            :host-device(%content<cdroms>{$cdrom}<backing><host_device>:exists                          ?? %content<cdroms>{$cdrom}<backing><host_device>                                   !! Nil),
            :iso-file(%content<cdroms>{$cdrom}<backing><iso_file>:exists                                ?? %content<cdroms>{$cdrom}<backing><iso_file>                                      !! Nil),
            :type(%content<cdroms>{$cdrom}<backing><type>),
        );
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::ide $ide;
        $ide                   .= new(
            :master(%content<cdroms>{$cdrom}<ide><master>),
            :primary(%content<cdroms>{$cdrom}<ide><primary>),
        ) if %content<cdroms>{$cdrom}<ide>:exists;
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom::sata $sata;
        $sata                  .= new(
            :bus(%content<cdroms>{$cdrom}<sata><bus>),
            :unit(%content<cdroms>{$cdrom}<sata><unit>),
        ) if %content<cdroms>{$cdrom}<sata>:exists;
        %cdroms{$cdrom} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms::cdrom.new(
            :allow-guest-control(%content<cdroms>{$cdrom}<allow_guest_control>),
            :$backing,
            :$ide,
            :label(%content<cdroms>{$cdrom}<label>),
            :$sata,
            :start-connected(%content<cdroms>{$cdrom}<start_connected>),
            :state(%content<cdroms>{$cdrom}<state>),
            :type(%content<cdroms>{$cdrom}<type>),
        );
    }
    %!vms{$name}.cdroms         = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cdroms.new(:%cdroms);

### cpu
    %!vms{$name}.cpu            = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::cpu.new(
        :cores-per-socket(%content<cpu><cores_per_socket>),
        :count(%content<cpu><count>),
        :hot-add-enabled(%content<cpu><hot_add_enabled>),
        :hot-remove-enabled(%content<cpu><hot_remove_enabled>),
    );

### disks
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk %disks;
    for %content<disks>.keys -> $disk {
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::backing $backing .= new(
            :type(%content<disks>{$disk}<backing><type>),
            :vmdk-file(%content<disks>{$disk}<backing><vmdk_file>:exists                                ?? %content<disks>{$disk}<backing><vmdk_file>                                       !! Nil),
        );
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::ide $ide;
        $ide                    = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::ide.new(
            :master(%content<disks>{$disk}<ide><master>),
            :primary(%content<disks>{$disk}<ide><primary>),
        ) if %content<disks>{$disk}<ide>:exists;
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::nvme $nvme;
        $nvme                   = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::nvme.new(
            :bus(%content<disks>{$disk}<nvme><bus>),
            :unit(%content<disks>{$disk}<nvme><unit>),
        ) if %content<disks>{$disk}<nvme>:exists;
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::sata $sata;
        $sata                   = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::sata.new(
            :bus(%content<disks>{$disk}<sata><bus>),
            :unit(%content<disks>{$disk}<sata><unit>),
        ) if %content<disks>{$disk}<sata>:exists;
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::scsi $scsi;
        $scsi                   = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk::scsi.new(
            :bus(%content<disks>{$disk}<scsi><bus>),
            :unit(%content<disks>{$disk}<scsi><unit>),
        ) if %content<disks>{$disk}<scsi>:exists;
        %disks{$disk}           = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks::disk.new(
            :$backing,
            :capacity(%content<disks>{$disk}<capacity>),
            :$ide,
            :label(%content<disks>{$disk}<label>),
            :$nvme,
            :$sata,
            :$scsi,
            :type(%content<disks>{$disk}<type>),
        );
    }
    %!vms{$name}.disks          = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::disks.new(:%disks);

### floppies
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies::floppy %floppies;
    for %content<floppies>.keys -> $floppy {
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies::floppy::backing $backing .= new(
            :auto-detect(%content<floppies>{$floppy}<backing><auto_detect>:exists                       ?? %content<floppies>{$floppy}<backing><auto_detect>                                !! Nil),
            :host-device(%content<floppies>{$floppy}<backing><host_device>:exists                       ?? %content<floppies>{$floppy}<backing><host_device>                                !! Nil),
            :image-file(%content<floppies>{$floppy}<backing><image_file>:exists                         ?? %content<floppies>{$floppy}<backing><image_file>                                 !! Nil),
            :type(%content<floppies>{$floppy}<backing><type>),
        );
        %floppies{$floppy}      = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies::floppy.new(
            :allow-guest-control(%content<floppies>{$floppy}<allow_guest_control>),
            :$backing,
            :label(%content<floppies>{$floppy}<label>),
            :start-connected(%content<floppies>{$floppy}<start_connected>),
            :state(%content<floppies>{$floppy}<state>),
        );
    }
    %!vms{$name}.floppies       = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::floppies.new(:%floppies);

### guest-OS
    %!vms{$name}.guest-OS       = %content<guest_OS>;

### hardware
    %!vms{$name}.hardware       = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::hardware.new(
        :upgrade-error(%content<hardware><upgrade_error>:exists                                         ?? %content<hardware><upgrade_error>                                                !! Hash.new),
        :upgrade-policy(%content<hardware><upgrade_policy>),
        :upgrade-status(%content<hardware><upgrade_status>),
        :upgrade-version(%content<hardware><upgrade_version>:exists                                     ?? %content<hardware><upgrade_version>                                              !! Nil),
        :version(%content<hardware><version>),
    );

### identity
    %!vms{$name}.identity       = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::identity.new(
        :bios_uuid(%content<identity><bios_uuid>),
        :instance_uuid(%content<identity><instance_uuid>),
        :name(%content<identity><name>),
    );

### instant_clone_frozen
    %!vms{$name}.instant_clone_frozen   = %content<instant_clone_frozen>;

### memory
    %!vms{$name}.memory         = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::memory.new(
        :hot-add-enabled(%content<memory><hot_add_enabled>),
        :hot-add-increment-size-MiB(%content<memory><hot_add_increment_size_MiB>:exists                 ?? %content<memory><hot_add_increment_size_MiB>                                     !! Nil),
        :hot-add-limit-MiB(%content<memory><hot_add_limit_MiB>:exists                                   ?? %content<memory><hot_add_limit_MiB>                                              !! Nil),
        :size-MiB(%content<memory><size_MiB>),
    );

### nics
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic %nics;
    for %content<nics>.keys -> $nic {
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic::backing $backing .= new(
            :connection-cookie(%content<nics>{$nic}<backing><connection_cookie>:exists                  ?? %content<nics>{$nic}<backing><connection_cookie>                                 !! Nil),
            :distributed-port(%content<nics>{$nic}<backing><distributed_port>:exists                    ?? %content<nics>{$nic}<backing><distributed_port>                                  !! Nil),
            :distributed-switch-uuid(%content<nics>{$nic}<backing><distributed_switch_uuid>:exists      ?? %content<nics>{$nic}<backing><distributed_switch_uuid>                           !! Nil),
            :host-device(%content<nics>{$nic}<backing><host_device>:exists                              ?? %content<nics>{$nic}<backing><host_device>                                       !! Nil),
            :network(%content<nics>{$nic}<backing><network>:exists                                      ?? %content<nics>{$nic}<backing><network>                                           !! Nil),
            :network-name(%content<nics>{$nic}<backing><network_name>:exists                            ?? %content<nics>{$nic}<backing><network_name>                                      !! Nil),
            :opaque-network-id(%content<nics>{$nic}<backing><opaque_network_id>:exists                  ?? %content<nics>{$nic}<backing><opaque_network_id>                                 !! Nil),
            :opaque-network-type(%content<nics>{$nic}<backing><opaque_network_type>:exists              ?? %content<nics>{$nic}<backing><opaque_network_type>                               !! Nil),
            :type(%content<nics>{$nic}<backing><type>),
        );
        %nics{$nic}             = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics::nic.new(
            :allow-guest-control(%content<nics>{$nic}<allow_guest_control>),
            :$backing,
            :label(%content<nics>{$nic}<label>),
            :mac-address(%content<nics>{$nic}<mac_address>:exists                                       ?? %content<nics>{$nic}<mac_address>                                                !! Nil),
            :mac-type(%content<nics>{$nic}<mac_type>),
            :pci-slot-number(%content<nics>{$nic}<pci_slot_number>:exists                               ?? %content<nics>{$nic}<pci_slot_number>                                            !! Nil),
            :start-connected(%content<nics>{$nic}<start_connected>),
            :state(%content<nics>{$nic}<state>),
            :type(%content<nics>{$nic}<type>),
            :upt-compatibility-enabled(%content<nics>{$nic}<upt_compatibility_enabled>:exists           ?? %content<nics>{$nic}<upt_compatibility_enabled>                                  !! Nil),
            :wake-on-lan-enabled(%content<nics>{$nic}<wake_on_lan_enabled>),
        );
    }
    %!vms{$name}.nics           = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nics.new(:%nics);

### nvme adapters
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters::nvme-adapter %nvme-adapters;
    for %content<nvme_adapaters>.keys -> $nvme-adapter {
        %nvme-adapters{$nvme-adapter} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters::nvme-adapter.new(
            :bus(%content<nvme_adapters>{$nvme-adapter}<bus>),
            :label(%content<nvme_adapters>{$nvme-adapter}<label>),
            :pci-slot-number(%content<nvme_adapters>{$nvme-adapter}<pci_slot_number>:exists             ?? %content<nvme_adapters>{$nvme-adapter}<pci_slot_number>                          !! Nil),
        );
    }
    %!vms{$name}.nvme-adapters  = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::nvme-adapters.new(:%nvme-adapters);

### parallel ports
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port %parallel-ports;
    for %content<parallel_ports>.keys -> $parallel-port {
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port::backing $backing .= new(
            :auto-detect(%content<parallel_ports>{$parallel-port}<backing><auto_detect>:exists          ?? %content<parallel_ports>{$parallel-port}<backing><auto_detect>                   !! Nil),
            :file(%content<parallel_ports>{$parallel-port}<backing><file>:exists                        ?? %content<parallel_ports>{$parallel-port}<backing><file>                          !! Nil),
            :host-device(%content<parallel_ports>{$parallel-port}<backing><host_device>:exists          ?? %content<parallel_ports>{$parallel-port}<backing><host_device>                   !! Nil),
            :type(%content<parallel_ports>{$parallel-port}<backing><type>),
        );
        %parallel-ports{$parallel-port} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports::parallel-port.new(
            :allow-guest-control(%content<parallel_ports>{$parallel-port}<allow_guest_control>),
            :$backing,
            :label(%content<parallel_ports>{$parallel-port}<label>),
            :start-connected(%content<parallel_ports>{$parallel-port}<start_connected>),
            :state(%content<parallel_ports>{$parallel-port}<state>),
        );
    }
    %!vms{$name}.parallel-ports = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::parallel-ports.new(:%parallel-ports);

### power_state
    %!vms{$name}.power-state    = %content<power_state>;

### sata adapters
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters::sata-adapter %sata-adapters;
    for %content<sata_adapters>.keys -> $sata-adapter {
        %sata-adapters{$sata-adapter} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters::sata-adapter.new(
            :bus(%content<sata_adapters>{$sata-adapter}<bus>),
            :label(%content<sata_adapters>{$sata-adapter}<label>),
            :pci-slot-number(%content<sata_adapters>{$sata-adapter}<pci_slot_number>:exists             ?? %content<sata_adapters>{$sata-adapter}<pci_slot_number>                          !! Nil),
            :type(%content<sata_adapters>{$sata-adapter}<type>),
        );
    }
    %!vms{$name}.sata-adapters  = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::sata-adapters.new(:%sata-adapters);

### scsi adapters
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter %scsi-adapters;
    for %content<scsi_adapters>.keys -> $scsi-adapter {
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter::scsi $scsi .= new(
            :bus(%content<scsi_adapters>{$scsi-adapter}<scsi><bus>),
            :unit(%content<scsi_adapters>{$scsi-adapter}<scsi><unit>),
        );
        %scsi-adapters{$scsi-adapter} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters::scsi-adapter.new(
            :label(%content<scsi_adapters>{$scsi-adapter}<label>),
            :pci-slot-number(%content<scsi_adapters>{$scsi-adapter}<pci_slot_number>:exists             ?? %content<scsi_adapters>{$scsi-adapter}<pci_slot_number>                          !! Nil),
            :$scsi,
            :sharing(%content<scsi_adapters>{$scsi-adapter}<sharing>),
            :type(%content<scsi_adapters>{$scsi-adapter}<type>),
        );
    }
    %!vms{$name}.scsi-adapters  = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::scsi-adapters.new(:%scsi-adapters);

### serial ports
    my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port %serial-ports;
    for %content<serial_ports>.keys -> $serial-port {
        my Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port::backing $backing .= new(
            :auto-detect(%content<serial_ports>{$serial-port}<backing><auto_detect>:exists              ?? %content<serial_ports>{$serial-port}<backing><auto_detect>                       !! Nil),
            :file(%content<serial_ports>{$serial-port}<backing><file>:exists                            ?? %content<serial_ports>{$serial-port}<backing><file>                              !! Nil),
            :host-device(%content<serial_port>{$serial-port}<backing><host_device>:exists               ?? %content<serial_ports>{$serial-port}<backing><host_device>                       !! Nil),
            :network-location(%content<serial_port>{$serial-port}<backing><network_location>:exists     ?? Cro::Uri.new(%content<serial_ports>{$serial-port}<backing><network_location>)    !! Nil),
            :no-rx-loss(%content<serial_ports>{$serial-port}<backing><no_rx_loss>:exists                ?? %content<serial_ports>{$serial-port}<backing><no_rx_loss>                        !! Nil),
            :pipe(%content<serial_ports>{$serial-port}<backing><pipe>:exists                            ?? %content<serial_ports>{$serial-port}<backing><pipe>                              !! Nil),
            :proxy(%content<serial_ports>{$serial-port}<backing><proxy>:exists                          ?? Cro::Uri.new(%content<serial_ports>{$serial-port}<backing><proxy>)               !! Nil),
            :type(%content<serial_ports>{$serial-port}<backing><type>),
        );
        %serial-ports{$serial-port} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports::serial-port.new(
            :allow-guest-control(%content<serial_ports>{$serial-port}<allow_guest_control>),
            :$backing,
            :label(%content<serial_ports>{$serial-port}<label>),
            :start-connected(%content<serial_ports>{$serial-port}<start_connected>),
            :state(%content<serial_ports>{$serial-port}<state>),
            :yield-on-poll(%content<serial_ports>{$serial-port}<yield_on_poll>),
        );
    }
    %!vms{$name}.serial-ports   = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm::serial-ports.new(:%serial-ports);

    self.vm($name).queried      = True;
}

### GET https://{server}/api/vcenter/vm
method !list () {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    my $content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/vm');
    for $content.list -> $v {
        my $name        = $v<name>;
        my $identifier  = $v<vm>;
        %identifier-to-name{$identifier} = $name;
        %!vms{$name} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm.new(
            :cpu-count($v<cpu_count>:exists                                     ?? $v<cpu_count>                                        !! Nil),
            :$identifier,
            :memory-size-MiB($v<memory_size_MiB>:exists                         ?? $v<memory_size_MiB>                                  !! Nil),
            :$name,
            :power-state($v<power_state>),
        );
    }
    self.listed = True;
}

### GET https://{server}/api/vcenter/vm?filter.hosts={$host-id}
method !list-by-host-id (Hypervisor::VMware::vSphere::REST::vcenter::hosts::host:D :$host-object) {
#   say self.^name ~ '::' ~ &?ROUTINE.name;
    my %query   = 'hosts' => $host-object.identifier;
    my $content = $!session.fetch('https://' ~ $!session.vcenter ~ '/api/vcenter/vm', :%query);
    for $content.list -> %v {
        my $name        = %v<name>;
        my $identifier  = %v<vm>;
        %identifier-to-name{$identifier} = $name;
        %!vms{$name} = Hypervisor::VMware::vSphere::REST::vcenter::vms::vm.new(
            :cpu-count(%v<cpu_count>:exists                                     ?? %v<cpu_count>                                        !! Nil),
            :$identifier,
            :memory-size-MiB(%v<memory_size_MiB>:exists                         ?? %v<memory_size_MiB>                                  !! Nil),
            :$name,
            :power-state(%v<power_state>),
        );
    }
}

=finish
