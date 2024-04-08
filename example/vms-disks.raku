#!/usr/bin/env raku

use lib '/home/mdevine/github.com/raku-Hypervisor-VMware-vSphere-REST/lib';
#use lib '/home/mdevine/github.com/raku-Our-Utilities/lib';
#use lib '/home/mdevine/github.com/raku-Our-Grid/lib';
use lib '/home/mdevine/github.com/raku-Our-Redis/lib';
use Data::Dump::Tree;

use Getopt::Long;
use JSON::Fast;
use Our::Cache;
use Our::Grid;
use Our::Grid::Cell;
use Our::Grid::Cell::Fragment;
use Our::Redis;
use Our::Utilities;

use Hypervisor::VMware::vSphere::REST::vcenter;

#my Our::Redis                                   $redis-cli;
#my Hypervisor::VMware::vSphere::REST::vcenter   $vcenter;

sub MAIN (
    Str:D               :$vcenter-server!,                      #= vCenter server name
    Str:D               :$vcenter-user-id!,                     #= user id (I.e., "ABC123@company.org")
    Str                 :$redis-server,                         #= specify a Redis server for site-specific info
    Bool                :$csv,                                  #= dump CSV to STDOUT
    Bool                :$gui,                                  #= Graphical User Interface
    Bool                :$html,                                 #= dump HTML to STDOUT
    Bool                :$json,                                 #= dump JSON to STDOUT
#   Grid-Email-Formats  :$mail-body-format,                     #= email body format
                        :$mail-body-format,                     #= email body format
                        :$mail-from,                            #= email 'From:' addressee
                        :@mail-to,                              #= accumulate email 'To:' addressees
                        :@mail-cc,                              #= accumulate email 'Cc:' addressees
                        :@mail-bcc,                             #= accumulate email 'Bcc:' addressees
    Bool                :$text,                                 #= TEXT print
    Bool                :$tui,                                  #= Terminal User Interface
    Bool                :$xml,                                  #= dump XML to STDOUT
    Bool                :$light-mode,                           #= reverse header highlight for light-mode
    Int                 :@sort-columns,                         #= accumulate column numbers to sort by
    Bool                :$sort-descending,                      #= sort in descending order
    Bool                :$group-by-system,                      #= group data around systems
    Bool                :$use-cache,                            #= use previous cached data
) {
    my Bool $mailing;
    my $from                = $mail-from;
    my $format              = $mail-body-format;
    if $mail-from && @mail-to.elems {
        die '--mail-from=<email-address> required to send mail!' unless $mail-from;
        die '--mail-to=<email-address[,email-address]> required to send mail!' unless @mail-to.elems;
        $from               = $mail-from[0] if $mail-from ~~ Array;
        $format             = $mail-body-format[0] if $mail-body-format ~~ Array;
        $mailing = True;
    }
    my $reverse-highlight   = $light-mode ?? True !! False;
    my $preferences-cache-file-name = cache-file-name(:meta<preferences>);
    my $preferences-cache   = cache(:cache-file-name($preferences-cache-file-name));
    $preferences-cache      = from-json($preferences-cache) if $preferences-cache;
    without $light-mode {
        $reverse-highlight  = $preferences-cache<light-mode> if $preferences-cache<light-mode>:exists;
    }
    cache(:cache-file-name($preferences-cache-file-name), :data(to-json({light-mode => $reverse-highlight})));

#   if $redis-server {
#       $redis-cli         .= new: :$redis-server, :tunnel;
#   }
#   else {
#       $redis-cli         .= new: :tunnel;
#   }
#   my @vcenter-sets        = $redis-cli.KEYS('Our:vCenters:*');
#   my @vcenters            = $redis-cli.SUNION(:keys(@vcenter-sets));
    $vcenter               .= new: :auth-login($vcenter-user-id), :vcenter($vcenter-server.lc), :use-cache;

### Setup grid
    my Our::Grid $grid;
    if $group-by-system {
        $grid  .= new: :title('VM Report: ' ~ $vcenter-server), :$reverse-highlight, :0group-by-column;
    }
    else {
        $grid  .= new: :title('VM Report: ' ~ $vcenter-server), :$reverse-highlight;
    }
    $grid.add-heading('Virtual Machine',    :justification<left>),
    $grid.add-heading('Disk',               :justification<left>);      # Label + superscript(disk number)
    $grid.add-heading('Type',               :justification<right>);
    $grid.add-heading('Capacity',           :justification<right>);     # bytes to bytes unit
    $grid.add-heading('Backing File',       :justification<right>);

### Query the vCenter
    for $vcenter.vms.list -> $vm-name {
        $vcenter.vms.query(:$vm-name);
        for $vcenter.vms.vm($vm-name).disks.list -> $disk-name {
            $grid.add-cell($vm-name, :justification<left>);
            my @fragments;
            @fragments[0]   = Our::Grid::Cell::Fragment.new(:text($vcenter.vms.vm($vm-name).disks.disk($disk-name).label));
            @fragments[1]   = Our::Grid::Cell::Fragment.new(:text($disk-name), :superscript);
            $grid.add-cell(:cell(Our::Grid::Cell.new(:@fragments, :justification<left>)));
            $grid.add-cell($vcenter.vms.vm($vm-name).disks.disk($disk-name).type, :justification<right>);
            with $vcenter.vms.vm($vm-name).disks.disk($disk-name).capacity {
                $grid.add-cell($vcenter.vms.vm($vm-name).disks.disk($disk-name).capacity, :bytes-to-bytes-unit, :justification<right>);
            }
            else {
                $grid.add-cell('0');
            }
            $grid.add-cell($vcenter.vms.vm($vm-name).disks.disk($disk-name).backing.vmdk-file ?? $vcenter.vms.vm($vm-name).disks.disk($disk-name).backing.vmdk-file !! 'None', :justification<right>);
            $grid.current-row++;
        }
    }
    if @sort-columns.elems {
        $grid.sort-by-columns(:@sort-columns, :descending($sort-descending));
    }
    {
        when $text          {   $grid.TEXT-print; }
        when $html          {   $grid.HTML-print; }
        when $csv           {   $grid.CSV-print;  }
        when $json          {   $grid.JSON-print; }
        when $mailing       {
                                $grid.send-proxy-mail-via-redis(
                                    :cro-host<127.0.0.1>,
                                    :22151cro-port,
                                    :mail-from($from),
                                    :@mail-to,
                                    :@mail-cc,
                                    :@mail-bcc,
                                    :$format,
                                );
        }
        when $xml           {   $grid.XML-print;  }
        when $tui           {   $grid.TUI;        }
        when $gui           {   $grid.GUI;        }
        default             {   $grid.ANSI-print; }
    }
}

=finish
