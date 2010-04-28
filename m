From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:37:45 +0200
Subject: [PATCH 23/23] Replicator: man pages for lvcreate, lvchange
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <4c53ddd3ac82e08294b1c6f2f64dfe50fe07f1a3.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update man pages to cover basic usage of lvcreate and lvchange
utility to handle basic replicator funtionality.

Current desriptions shows how to create replicator,
add site, add replicated device.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/lvchange.8.in |   56 +++++++++++++++++++++++++++++++++++++++++++++++
 man/lvcreate.8.in |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 118 insertions(+), 1 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index c3cb3b2..8ae1230 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -3,10 +3,17 @@
 lvchange \- change attributes of a logical volume
 .SH SYNOPSIS
 .B lvchange
+[\-\-addsite Site]
 [\-\-addtag Tag]
 [\-A|\-\-autobackup y|n] [\-a|\-\-available y|n|ey|en|ly|ln]
 [\-\-alloc AllocationPolicy]
 [\-C|\-\-contiguous y|n] [\-d|\-\-debug] [\-\-deltag Tag]
+[\-\-delsite Site]
+[[\-\-fallbehinddata Size[bBsSkKmMgGtTpPeE]] |
+[\-\-fallbehindios  IOS] |
+[\-\-fallbehindtimeout sec]]
+[\-\-sitemode [sync|warn|stall|drop|fail]
+[[\-\-activesite Site] | [\-\-passivesite Site]]
 [\-\-resync]
 [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
@@ -19,6 +26,7 @@ lvchange \- change attributes of a logical volume
 [\-p|\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
 [\-\-refresh]
 [\-t|\-\-test]
+[\-\-remotevolumegroup VolumeGroupName]
 [\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
 .SH DESCRIPTION
 lvchange allows you to change the attributes of a logical volume
@@ -102,10 +110,58 @@ If the logical volume is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering 
 manually without a clustered lock manager.
+.TP
+.I \-\-addsite
+Add new site to given replicator LV.
+.TP
+.I \-\-delsite
+Remove given site from replicator LV.
+.TP
+.I \-\-fallbehinddata
+How many data could get replicator behind. Cannot be mixed
+with --fallbehindios or --fallbehindtimeout.
+.TP
+.I \-\-fallbehindios
+How many io operation could be queued in replicator backing store device.
+Cannot be mixed with --fallbehinddata or --fallbehindtimeout.
+.TP
+.I \-\-fallbehindtimeout
+How many seconds could be replicator behind actual data. Cannot be mixed
+with --fallbehinddata or --fallbehindios.
+.TP
+.I \-\-sitemode
+Select replication mode. Default is Warn.
+Sync is synchronous mode. Warn,Stall,Drop,Fail are asynchronous modes.
+Warn issues warning when remote site is switched to sync log.
+Stall stalls replicator until remote site is back in range.
+Drop drops whole remote site, if it get too behind.
+Fail whole replicator fails is remote sites gets too behind.
+Local site works usually in stall mode. There is no synclog for local
+replicated volumes.
+.TP
+.I \-\-activesite
+Marks site as active. Note: Only one site from replicator could be
+marked active with actual implementation and this site must be
+local site.
+.TP
+.I \-\-passivesite
+Marks site as passive which is default.
+.TP
+.I \-\-remotevolumegroup
+Selects remote volume group for remote site that contains logical volumes
+with same names for replication as the volume group for site. Local site
+for replicator is assumed if remotevolumegroup is not specified.
+.TP
 .SH Examples
 "lvchange -pr vg00/lvol1" changes the permission on 
 volume lvol1 in volume group vg00 to be read-only.
 
+"lvchange --addsite NewYork vg00/replicator0"
+adds new local site NewYork in replicator vg00/replicator0.
+
+"lvchange --activesite NewYork vg00/replicator0"
+marks site NewYork in replicator vg00/replicator0 as active.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8),
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 3c36b97..ee9701b 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -14,7 +14,9 @@ lvcreate \- create a logical volume in an existing volume group
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-M|\-\-persistent y|n] [\-\-minor minor]
 [\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core|mirrored}] [\-\-corelog]
-[\-R|\-\-regionsize MirrorLogRegionSize]]
+[\-R|\-\-regionsize {MirrorLogRegionSize|ReplicatorLogRegionSize}]]
+[[\+\+replicatorlog SyncLogLogicalVolumePath]
+[\+\+site ReplicatorSiteName]]
 [\-n|\-\-name LogicalVolumeName]
 [\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
 [\-t|\-\-test]
@@ -35,6 +37,22 @@ VolumeGroupName [PhysicalVolumePath[:PE[-PE]]...]
 OriginalLogicalVolumePath | 
 [\-s|\-\-snapshot]
 VolumeGroupName \-\-virtualsize VirtualSize}
+.br
+
+.br
+.B lvcreate
+{\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |
+ \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE] |
+ \+\+replicatorlog ReplicatorLogLogicalVolumePath}
+[\-\-replicatorlogtype ReplicatorLogType]
+[\-\-replicatorsynclog {disk|core}]
+[\-R|\-\-regionsize ReplicatorSyncLogRegionSize]]
+[\-\-nosync]
+\-n|\-\-name ReplicatorName
+\-\-replicator
+VolumeGroupName
+.br
+
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
 .B vgcreate(8), vgchange(8)
@@ -51,6 +69,9 @@ extents will be restricted to these volumes.
 .br
 The second form supports the creation of snapshot logical volumes which 
 keep the contents of the original logical volume for backup purposes.
+.br
+The third form supports the creation of replicator logical volumes which 
+keep the contents of the replicators.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
@@ -119,6 +140,41 @@ device is activated, for example, after every reboot.  Using "mirrored"
 will create a persistent log that is itself mirrored.
 
 The optional argument --corelog is equivalent to --mirrorlog core.
+.TP
+.I \-\-replicator
+Creates empty replicator logical volume. ( see
+.B lvchange(8)
+) for options, how to customize created replicator LV.
+
+Specifying optional argument --nosync will cause the creation
+of the replicator to skip the initial resynchronization. Any data written
+afterwards will be replicated, but the original content will not be
+copied.  This is useful for skipping a potentially long and resource
+intensive initial sync of an empty device.
+
+The optional argument --replicatorsynclog specifies the type of synclog to be
+used. The default is disk, which is persistent and requires a small amount of
+storage space, usually on a separate device from the data being replicated.
+Using core means the replicator is regenerated by copying the data from the
+first device again each time the device is activated, for example, after every
+reboot.
+
+The optional argument --replicatorlog specifies the LogicalVolumePath of the
+LV to be used as the main backing store device for keeping replicator master
+log for replicator or synclog device for replicator device. If not specified, 
+log is allocated with given -L|--size of -l|--extents.
+Note: This backing store device should be very fast and reliable storage
+(i.e. raid1), so should be selected with special care.
+
+The optional argument --replicatorlogtype specifies type of the backing store
+log. The default and currently the only valid and supported type is 
+\fBringbuffer\fP.
+
+
+.TP
+.I \-\-replicatordev
+Creates empty replicated logical volume in given ReplicatorName.
+(Future: If the --site is not specified, local site is found inside replicator LV.) 
 
 .TP
 .I \-n, \-\-name LogicalVolumeName
@@ -237,10 +293,15 @@ under 100MB of actual data on it.
 creates a linear logical volume "vg00/lvol1" using physical extents
 /dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents.
 
+"lvcreate -L 1G -n replicator0 vg00"
+.br
+creates an empty replicator logical volume "vg00/replicator0" and hidden backing
+store volume vg00/replicator0_rlog of size 1G.
 
 .SH SEE ALSO
 .BR lvm (8), 
 .BR vgcreate (8), 
+.BR lvchange (8)
 .BR lvremove (8), 
 .BR lvrename (8)
 .BR lvextend (8), 
-- 
1.7.0.1


