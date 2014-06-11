From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:36 +0000 (UTC)
Subject: master - man: properly escape -
Message-ID: <20140611091136.9FE5960F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08969876330111e6d49618ff0313bdd61b69d7f2
Commit:        08969876330111e6d49618ff0313bdd61b69d7f2
Parent:        49560910275696fa7dd149932fe9c4530667ecdd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 11 11:06:30 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:10:55 2014 +0200

man: properly escape -

Dash should be using '\' to be typographically correct.
---
 man/blkdeactivate.8.in             |    6 +-
 man/clvmd.8.in                     |    8 +-
 man/cmirrord.8.in                  |    4 +-
 man/dmeventd.8.in                  |   12 ++-
 man/dmsetup.8.in                   |    2 +-
 man/fsadm.8.in                     |    2 +-
 man/lvchange.8.in                  |    6 +-
 man/lvconvert.8.in                 |   22 ++--
 man/lvcreate.8.in                  |   22 ++--
 man/lvdisplay.8.in                 |    4 +-
 man/lvextend.8.in                  |   12 +-
 man/lvm-dumpconfig.8.in            |    4 +-
 man/lvm.8.in                       |    2 +-
 man/lvm.conf.5.in                  |   34 +++---
 man/lvm2-activation-generator.8.in |    2 +-
 man/lvmcache.7.in                  |   44 +++---
 man/lvmchange.8.in                 |    2 +-
 man/lvmconf.8.in                   |    4 +-
 man/lvmdiskscan.8.in               |    2 +-
 man/lvmdump.8.in                   |    6 +-
 man/lvmetad.8.in                   |   10 +-
 man/lvmsadc.8.in                   |    2 +-
 man/lvmsar.8.in                    |    2 +-
 man/lvmthin.7.in                   |  274 ++++++++++++++++++------------------
 man/lvreduce.8.in                  |    2 +-
 man/lvremove.8.in                  |    2 +-
 man/lvrename.8.in                  |    2 +-
 man/lvresize.8.in                  |   28 ++--
 man/lvs.8.in                       |    4 +-
 man/lvscan.8.in                    |    2 +-
 man/pvchange.8.in                  |    4 +-
 man/pvck.8.in                      |    2 +-
 man/pvcreate.8.in                  |   12 +-
 man/pvmove.8.in                    |   20 ++--
 man/pvremove.8.in                  |    2 +-
 man/pvresize.8.in                  |    2 +-
 man/pvs.8.in                       |    2 +-
 man/pvscan.8.in                    |    2 +-
 man/vgcfgbackup.8.in               |    4 +-
 man/vgcfgrestore.8.in              |    2 +-
 man/vgchange.8.in                  |   16 +-
 man/vgck.8.in                      |    2 +-
 man/vgcreate.8.in                  |    6 +-
 man/vgdisplay.8.in                 |    4 +-
 man/vgextend.8.in                  |    2 +-
 man/vgimport.8.in                  |    2 +-
 man/vgimportclone.8.in             |    4 +-
 man/vgmerge.8.in                   |    6 +-
 man/vgmknodes.8.in                 |    2 +-
 man/vgreduce.8.in                  |    6 +-
 man/vgremove.8.in                  |    6 +-
 man/vgrename.8.in                  |    4 +-
 man/vgs.8.in                       |    2 +-
 man/vgscan.8.in                    |    2 +-
 man/vgsplit.8.in                   |    6 +-
 55 files changed, 327 insertions(+), 323 deletions(-)

diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index f6713f3..9998744 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -1,6 +1,6 @@
 .TH "BLKDEACTIVATE" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH "NAME"
-blkdeactivate \- utility to deactivate block devices
+blkdeactivate \(em utility to deactivate block devices
 .SH SYNOPSIS
 .B blkdeactivate
 .RI [ options ]
@@ -65,12 +65,12 @@ Deactivate all supported block devices found in the system. Retry deactivation
 of device-mapper devices in case the deactivation fails. Deactivate the whole
 Volume Group at once when processing an LVM Logical Volume.
 .sp
-.B blkdeactivate \-u -d retry -l wholevg
+.B blkdeactivate \-u \-d retry \-l wholevg
 
 Deactivate all supported block devices found in the system. Retry deactivation
 of device-mapper devices in case the deactivation fails and force removal.
 .sp
-.B blkdeactivate -d force,retry
+.B blkdeactivate \-d force,retry
 
 .SH SEE ALSO
 .BR lsblk (8)
diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 2d7b06b..d79c29b 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -1,6 +1,6 @@
 .TH CLVMD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
 .SH NAME
-clvmd \- cluster LVM daemon
+clvmd \(em cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
 .RB [ \-d
@@ -54,7 +54,7 @@ enable cluster-wide logging then the command needs to be issued twice, eg:
 .br
 .B clvmd
 .br
-.B clvmd -d2
+.B clvmd \-d2
 .br
 .TP
 .BR \-E < "\fIlock uuid" >
@@ -68,7 +68,7 @@ Show help information.
 .TP
 .B \-I \fIcluster manager
 Selects the cluster manager to use for locking and internal communications,
-the available managers will be listed as part of the \fBclvmd -h\fP output.
+the available managers will be listed as part of the \fBclvmd \-h\fP output.
 clvmd will use the first cluster manager that succeeds, and it checks them
 in the order cman,corosync,openais. As it is quite possible to have
 (eg) corosync and cman available on the same system you might have to
@@ -107,7 +107,7 @@ The default is 0 (no timeout) and the value is in seconds. Don't set this too
 small or you will experience spurious errors. 10 or 20 seconds might be
 sensible.
 .br
-This timeout will be ignored if you start clvmd with the -d switch.
+This timeout will be ignored if you start clvmd with the \-d switch.
 .TP
 .B \-V
 Display the version of the cluster LVM daemon.
diff --git a/man/cmirrord.8.in b/man/cmirrord.8.in
index 035fa43..8ef6794 100644
--- a/man/cmirrord.8.in
+++ b/man/cmirrord.8.in
@@ -1,6 +1,6 @@
 .TH CMIRRORD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
 .SH NAME
-cmirrord \- cluster mirror log daemon
+cmirrord \(em cluster mirror log daemon
 
 .SH SYNOPSIS
 .B cmirrord
@@ -27,4 +27,4 @@ cluster mirror log daemon.
 .SH SEE ALSO
 .BR lvm (8)
 .BR clvmd (8)
-.BR cluster.conf (5)
\ No newline at end of file
+.BR cluster.conf (5)
diff --git a/man/dmeventd.8.in b/man/dmeventd.8.in
index e742a61..77bbafb 100644
--- a/man/dmeventd.8.in
+++ b/man/dmeventd.8.in
@@ -1,9 +1,11 @@
 .TH DMEVENTD 8 "DM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
 .SH NAME
-dmeventd \- Device-mapper event daemon
+dmeventd \(em Device-mapper event daemon
 .SH SYNOPSIS
 .B dmeventd
-.RB [ \-d " [" -d " [" -d ]]]
+.RB [ \-d
+.RB [ \-d
+.RB [ \-d ]]]
 .RB [ \-f ]
 .RB [ \-h ]
 .RB [ \-R ]
@@ -36,7 +38,11 @@ See \fBlvm.conf\fP(5).
 .SH OPTIONS
 .TP
 .B \-d
-Repeat from 1 to 3 times (-d, -dd, -ddd) to increase the detail of
+Repeat from 1 to 3 times (
+.BR \-d ,
+.BR \-dd ,
+.BR \-ddd
+) to increase the detail of
 debug messages sent to syslog.
 Each extra d adds more debugging information.
 .TP
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 1b17580..b257c89 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -1,6 +1,6 @@
 .TH DMSETUP 8 "Apr 06 2006" "Linux" "MAINTENANCE COMMANDS"
 .SH NAME
-dmsetup \- low level logical volume management
+dmsetup \(em low level logical volume management
 .SH SYNOPSIS
 .ad l
 .B dmsetup clear
diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index 20ec4c8..2aecd65 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -1,6 +1,6 @@
 .TH "FSADM" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH "NAME"
-fsadm \- utility to resize or check filesystem on a device
+fsadm \(em utility to resize or check filesystem on a device
 .SH SYNOPSIS
 .B fsadm
 .RI [ options ]
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 27f81aa..ce10012 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -1,6 +1,6 @@
 .TH LVCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvchange \- change attributes of a logical volume
+lvchange \(em change attributes of a logical volume
 .SH SYNOPSIS
 .B lvchange
 .RB [ \-\-addtag
@@ -190,7 +190,7 @@ the number of I/Os to the drive to a minimum.  The default behavior is to
 set the write-mostly attribute for the specified physical volume in the
 logical volume.  It is possible to also remove the write-mostly flag by
 appending a ":n" to the physical volume or to toggle the value by specifying
-":t".  The \fB--writemostly\fP argument can be specified more than one time
+":t".  The \fB\-\-writemostly\fP argument can be specified more than one time
 in a single command; making it possible to toggle the write-mostly attributes
 for all the physical volumes in a logical volume at once.
 .TP
@@ -253,7 +253,7 @@ Suppress locking failure messages.
 .SH Examples
 Changes the permission on volume lvol1 in volume group vg00 to be read-only:
 .sp
-.B lvchange -pr vg00/lvol1
+.B lvchange \-pr vg00/lvol1
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvmcache (7),
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 44a3dbe..76003b4 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -1,6 +1,6 @@
 .TH LVCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
 .SH NAME
-lvconvert \- convert a logical volume from linear to mirror or snapshot
+lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
 .BR \-m | \-\-mirrors
@@ -30,7 +30,7 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-y | \-\-yes ]
 .RB [ \-\-version ]
 .IR LogicalVolume [ Path ]
-.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .sp
 .B lvconvert \-\-splitmirrors \fIImages
 .RB [ \-\-commandprofile
@@ -39,7 +39,7 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .IR SplitLogicalVolumeName ]
 .RB [ \-\-trackchanges ]
 .IR MirrorLogicalVolume [ Path ]
-.RI [ SplittablePhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.RI [ SplittablePhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .sp
 .B lvconvert
 .BR \-\-splitsnapshot
@@ -124,7 +124,7 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .IR ExternalOriginLogicalVolume { Name | Path }
 .RB [ \-\-originname
 .IR NewExternalOriginVolumeName ]]
-.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
@@ -142,7 +142,7 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .B \-\-poolmetadatasize
 .IR CachePoolMetadataSize [ bBsSkKmMgG ]}]
 .IR LogicalVolume [ Path ]
-.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
@@ -198,7 +198,7 @@ For more information on cache pool LVs and cache LVs, see \fBlvm\fP(8).
 .TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.
-For example, "\fB-m 1\fP" would convert the original logical
+For example, "\fB\-m 1\fP" would convert the original logical
 volume to a mirror volume with 2-sides; that is, a
 linear volume plus one copy.  There are two implementations of mirroring
 which correspond to the "raid1" and "mirror" segment types.  The default
@@ -451,10 +451,10 @@ Converts logical volume "vg00/lvol2" to snapshot of original volume
 .B lvconvert \-s vg00/lvol1 vg00/lvol2
 
 Converts linear logical volume "vg00/lvol1" to a two-way mirror,
-using physical extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation
+using physical extents /dev/sda:0\-15 and /dev/sdb:0\-15 for allocation
 of new extents:
 .sp
-.B lvconvert \-m1 vg00/lvol1 /dev/sda:0-15 /dev/sdb:0-15
+.B lvconvert \-m1 vg00/lvol1 /dev/sda:0\-15 /dev/sdb:0\-15
 
 Converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
 extents from /dev/sda:
@@ -507,19 +507,19 @@ and convert "vg00/lv1" into a thin volume using this pool. Original "vg00/lv1"
 is used as an external read-only origin, where all writes to such volume
 are stored in the "vg00/lvpool".
 .sp
-.B lvconvert \-\-thinpool vg00/lvpool -c 128 -T lv1
+.B lvconvert \-\-thinpool vg00/lvpool \-c 128 \-T lv1
 
 Convert the logical volume "vg00/origin" into a thin volume from the thin pool
 "vg00/lvpool". This thin volume will use "vg00/origin" as an external origin
 volume for unprovisioned areas in this volume.
 For the read-only external origin use the new name "vg00/external".
 .sp
-.B lvconvert \-\-thinpool vg00/lvpool \-\-originname external -T vg00/origin
+.B lvconvert \-\-thinpool vg00/lvpool \-\-originname external \-T vg00/origin
 
 Convert an existing logical volume to a cache pool LV using the
 given cache metadata LV.
 .sp
-.B lvconvert --type cache-pool --poolmetadata vg00/lvx_meta vg00/lvx_data
+.B lvconvert \-\-type cache-pool \-\-poolmetadata vg00/lvx_meta vg00/lvx_data
 .br
 .B lvrename vg00/lvx_data vg00/lvx_cachepool
 
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 164ca27..64468a0 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -85,7 +85,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
 .IR VolumeGroup { Name | Path }[/ ThinPoolLogicalVolumeName ]
-.RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
+.RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
 .br
 
 .B lvcreate
@@ -136,8 +136,8 @@ for common options.
 .IR \fB\-a ", " \fB\-\-activate " {" y | ay | n | ey | en | ly | ln }
 Controls the availability of the Logical Volumes for immediate use after
 the command finishes running.
-By default, new Logical Volumes are activated (\fB-a\fIy\fR).
-If it is possible technically, \fB-a\fIn\fR will leave the new Logical
+By default, new Logical Volumes are activated (\fB\-a\fIy\fR).
+If it is possible technically, \fB\-a\fIn\fR will leave the new Logical
 Volume inactive. But for example, snapshots can only be created
 in the active state so \fB\-a\fIn\fR cannot be used with \fB\-\-snapshot\fP.
 Normally the \fB\-\-zero\fP \fIn\fP argument has to be supplied too because
@@ -256,7 +256,7 @@ Default unit is megabytes.
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Creates a mirrored logical volume with \fIMirrors\fP copies.
 For example, specifying
-.BI -m 1
+.BI \-m 1
 would result in a mirror with two-sides; that is,
 a linear volume plus one copy.
 
@@ -507,9 +507,9 @@ under 100MiB of actual data on it:
 .B lvcreate \-\-virtualsize 1T \-\-size 100M \-\-snapshot \-\-name sparse vg1
 
 Creates a linear logical volume "vg00/lvol1" using physical extents
-/dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents:
+/dev/sda:0\-7 and /dev/sdb:0\-7 for allocation of extents:
 .sp
-.B lvcreate \-L 64M -n lvol1 vg00 /dev/sda:0\-7 /dev/sdb:0\-7
+.B lvcreate \-L 64M \-n lvol1 vg00 /dev/sda:0\-7 /dev/sdb:0\-7
 
 Creates a 5GiB RAID5 logical volume "vg00/my_lv", with 3 stripes (plus
 a parity drive for a total of 4 devices) and a stripesize of 64KiB:
@@ -542,30 +542,30 @@ will share the same blocks within the thin pool.
 Note: the size MUST NOT be specified, otherwise the non-thin snapshot
 is created instead:
 .sp
-.B lvcreate -s vg00/thinvol --name thinsnap
+.B lvcreate \-s vg00/thinvol \-\-name thinsnap
 
 Creates a thin snapshot volume of read-only inactive volume "origin"
 which then becomes the thin external origin for the thin snapshot volume
 in vg00 that will use an existing thin pool "vg00/pool":
 .sp
-.B lvcreate -s --thinpool vg00/pool  origin
+.B lvcreate \-s \-\-thinpool vg00/pool  origin
 
 Create a cache pool LV that can later be used to cache one
 logical volume.
 .sp
-.B lvcreate --type cache-pool -L 1G -n my_lv_cachepool vg /dev/fast1
+.B lvcreate \-\-type cache-pool \-L 1G \-n my_lv_cachepool vg /dev/fast1
 
 If there is an existing cache pool LV, create the large slow
 device (i.e. the origin LV) and link it to the supplied cache pool LV,
 creating a cache LV.
 .sp
-.B lvcreate --type cache -L 100G -n my_lv vg/my_lv_cachepool /dev/slow1
+.B lvcreate \-\-type cache \-L 100G \-n my_lv vg/my_lv_cachepool /dev/slow1
 
 If there is an existing logical volume, create the small and fast
 cache pool LV and link it to the supplied existing logical
 volume (i.e. the origin LV), creating a cache LV.
 .sp
-.B lvcreate --type cache -L 1G -n my_lv_cachepool vg/my_lv /dev/fast1
+.B lvcreate \-\-type cache \-L 1G \-n my_lv_cachepool vg/my_lv /dev/fast1
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index bf9f544..5593752 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -1,6 +1,6 @@
 .TH LVDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvdisplay \- display attributes of a logical volume
+lvdisplay \(em display attributes of a logical volume
 .SH SYNOPSIS
 .B lvdisplay
 .RB [ \-a | \-\-all ]
@@ -37,7 +37,7 @@ lvdisplay \- display attributes of a logical volume
 .RB [ \-o | \-\-options
 .RI [ + ] Field [ ,Field ...]]
 .RB [ \-O | \-\-sort
-.RI [ + | - ] Key1 [ , [ + | - ] Key2 ...]]
+.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-segments ]
 .RB [ \-\-separator
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
index 845a3ea..8deab54 100644
--- a/man/lvextend.8.in
+++ b/man/lvextend.8.in
@@ -1,6 +1,6 @@
 .TH LVEXTEND 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvextend \- extend the size of a logical volume
+lvextend \(em extend the size of a logical volume
 .SH SYNOPSIS
 .B lvextend
 .RB [ \-\-alloc
@@ -28,7 +28,7 @@ lvextend \- extend the size of a logical volume
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .I LogicalVolumePath
-.RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
+.RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
 .SH DESCRIPTION
 lvextend allows you to extend the size of a logical volume.
 Extension of snapshot logical volumes (see
@@ -108,18 +108,18 @@ Extends the size of the logical volume "vg01/lvol10" by 54MiB on physical
 volume /dev/sdk3. This is only possible if /dev/sdk3 is a member of
 volume group vg01 and there are enough free physical extents in it:
 .sp
-.B lvextend -L +54 /dev/vg01/lvol10 /dev/sdk3
+.B lvextend \-L +54 /dev/vg01/lvol10 /dev/sdk3
 
 Extends the size of logical volume "vg01/lvol01" by the amount of free
 space on physical volume /dev/sdk3. This is equivalent to specifying
-"-l +100%PVS" on the command line:
+"\-l +100%PVS" on the command line:
 .sp
 .B lvextend /dev/vg01/lvol01 /dev/sdk3
 
 Extends a logical volume "vg01/lvol01" by 16MiB using physical extents
-/dev/sda:8-9 and /dev/sdb:8-9 for allocation of extents:
+/dev/sda:8\-9 and /dev/sdb:8\-9 for allocation of extents:
 .sp
-.B lvextend -L+16M vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9
+.B lvextend -L+16M vg01/lvol01 /dev/sda:8\-9 /dev/sdb:8\-9
 
 .SH SEE ALSO
 .BR fsadm (8),
diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index 4b21ef1..844f8ac 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -1,9 +1,9 @@
 .TH "LVM-DUMPCONFIG" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH "NAME"
-lvm-dumpconfig \- dump LVM configuration
+lvm-dumpconfig \(em dump LVM configuration
 .SH SYNOPSIS
 .B lvm dumpconfig
-.RB [ \-f | \-\-file ]
+.RB [ \-f | \-\-file
 .IR filename ]
 .RB [ \-\-type
 .RI { current | default | diff | missing | new | profilable | profilable-command | profilable-metadata }
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 9df3cde..5449e20 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -1,6 +1,6 @@
 .TH LVM 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvm \- LVM2 tools
+lvm \(em LVM2 tools
 .SH SYNOPSIS
 .B lvm
 [command | file]
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index bf73a29..c434527 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -1,6 +1,6 @@
 .TH LVM.CONF 5 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvm.conf \- Configuration file for LVM2
+lvm.conf \(em Configuration file for LVM2
 .SH SYNOPSIS
 .B #DEFAULT_SYS_DIR#/lvm.conf
 .SH DESCRIPTION
@@ -65,8 +65,8 @@ For this purpose, there's the \fBcommand_profile_template.profile\fP
 (for metadata profiles) which contain all settings that are customizable
 by profiles of certain type. Users are encouraged to copy these template
 profiles and edit them as needed. Alternatively, the
-\fBlvm dumpconfig --file <ProfileName.profile> --type profilable-command <section>\fP
-or \fBlvm dumpconfig --file <ProfileName.profile> --type profilable-metadata <section>\fP
+\fBlvm dumpconfig \-\-file <ProfileName.profile> \-\-type profilable-command <section>\fP
+or \fBlvm dumpconfig \-\-file <ProfileName.profile> \-\-type profilable-metadata <section>\fP
 can be used to generate a configuration with profilable settings in either
 of the type for given section and save it to new ProfileName.profile
 (if the section is not specified, all profilable settings are reported).
@@ -249,7 +249,7 @@ start of the aligned data area of the Physical Volume will be shifted
 by the alignment_offset exposed in sysfs.
 .sp
 To see the location of the first Physical Extent of an existing Physical Volume
-use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
+use \fBpvs \-o +pe_start\fP .  It will be a multiple of the requested
 \fBdata_alignment\fP plus the alignment_offset from
 \fBdata_alignment_offset_detection\fP (if enabled) or the pvcreate
 commandline.
@@ -318,7 +318,7 @@ is invoked.  By default tools append messages to the log file.
 When set, display and reporting tools will still write the requested
 device properties to standard output, but messages confirming that
 something was or wasn't changed will be reduced to the 'verbose' level
-and not appear unless -v is supplied.
+and not appear unless \-v is supplied.
 .IP
 \fBsyslog\fP \(em Set to 1 (the default) to send log messages through syslog.
 Turn off by setting to 0.  If you set to an integer greater than one,
@@ -394,7 +394,7 @@ Interpreted as octal if the first digit is zero.
 Defaults to 077.
 Use 022 to allow other users to read the files by default.
 .IP
-\fBformat\fP \(em The default value of \fB--metadatatype\fP used
+\fBformat\fP \(em The default value of \fB\-\-metadatatype\fP used
 to determine which format of metadata to use when creating new
 physical volumes and volume groups. \fBlvm1\fP or \fBlvm2\fP.
 .IP
@@ -408,14 +408,14 @@ If an LVM2 tool is then run but unable to communicate
 with device-mapper, it will automatically invoke the equivalent LVM1
 version of the tool.  Note that for LVM1 tools to
 manipulate physical volumes and volume groups created by LVM2 you
-must use \fB--metadataformat lvm1\fP when creating them.
+must use \fB\-\-metadataformat lvm1\fP when creating them.
 .IP
 \fBlibrary_dir\fP \(em A directory searched for LVM2's shared libraries
 ahead of the places \fBdlopen\fP (3) searches.
 .IP
 \fBformat_libraries\fP \(em A list of shared libraries to load that contain
 code to process different formats of metadata. For example, liblvm2formatpool.so
-is needed to read GFS pool metadata if LVM2 was configured \fB--with-pool=shared\fP.
+is needed to read GFS pool metadata if LVM2 was configured \fB\-\-with-pool=shared\fP.
 .IP
 \fBlocking_type\fP \(em What type of locking to use.
 1 is the default, which use flocks on files in \fBlocking_dir\fP
@@ -424,7 +424,7 @@ avoid conflicting LVM2 commands running concurrently on a single
 machine. 0 disables locking and risks corrupting your metadata.
 If set to 2, the tools will load the external \fBlocking_library\fP
 (see below).
-If the tools were configured \fB--with-cluster=internal\fP
+If the tools were configured \fB\-\-with-cluster=internal\fP
 (the default) then 3 means to use built-in cluster-wide locking.
 Type 4 enforces read-only metadata and forbids any operations that
 might want to modify Volume Group metadata.
@@ -450,7 +450,7 @@ group metadata and PV state flags are obtained from the lvmetad instance and no
 scanning is done by the individual commands. In a setup with lvmetad, lvmetad
 udev rules \fBmust\fP be set up for LVM to work correctly. Without proper udev
 rules, all changes in block device configuration will be \fBignored\fP until a
-manual 'pvscan --cache' is performed.
+manual 'pvscan \-\-cache' is performed.
 .br
 If lvmetad has been running while use_lvmetad was 0, it \fBMUST\fP be stopped before
 changing use_lvmetad to 1 and started again afterwards.
@@ -487,7 +487,7 @@ These options are useful if you are replicating configuration files
 around a cluster.  Use of \fBhosttags = 1\fP means every machine
 can have static and identical local configuration files yet use
 different settings and activate different logical volumes by
-default.  See also \fBvolume_list\fP below and \fB--addtag\fP
+default.  See also \fBvolume_list\fP below and \fB\-\-addtag\fP
 in \fBlvm\fP (8).
 .TP
 \fBactivation\fP \(em Settings affecting device-mapper activation
@@ -564,7 +564,7 @@ to store on each physical volume.
 Currently it can be set to 0, 1 or 2.  The default is 1.
 If set to 2, one copy is placed at the beginning of the disk
 and the other is placed at the end.
-It can be overridden on the command line with \fB--pvmetadatacopies\fP
+It can be overridden on the command line with \fB\-\-pvmetadatacopies\fP
 (see \fBpvcreate\fP).
 If creating a volume group with just one physical volume, it's a
 good idea to have 2 copies.  If creating a large volume group with
@@ -590,12 +590,12 @@ metadata format, this states whether metadata areas should be ignored.
 The default is "n".  If metadata areas on a physical volume are ignored,
 LVM will not not store metadata in the metadata areas present on newly
 created Physical Volumes.  The option can be overridden on the command
-line with \fB--metadataignore\fP (See \fBpvcreate\fP and \fBpvchange\fP).
+line with \fB\-\-metadataignore\fP (See \fBpvcreate\fP and \fBpvchange\fP).
 Metadata areas cannot be created or extended after Logical Volumes have
 been allocated on the device.
 If you do not want to store metadata on this device, it is still wise
 always to allocate a metadata area (use a non-zero value for
-\fB--pvmetadatacopies\fP) in case you need it in the future and to use
+\fB\-\-pvmetadatacopies\fP) in case you need it in the future and to use
 this option to instruct LVM2 to ignore it.
 .IP
 \fBvgmetadatacopies\fP \(em When creating a volume group using the
@@ -603,17 +603,17 @@ LVM2 metadata format, this is the default number of copies of metadata
 desired across all the physical volumes in the volume group.  If set to
 a non-zero value, LVM will automatically set or clear the metadataignore
 flag on the physical volumes (see \fBpvcreate\fP and \fBpvchange\fP
-\fB--metadataignore\fP) in order to achieve the desired number of metadata
+\fB\-\-metadataignore\fP) in order to achieve the desired number of metadata
 copies.  An LVM command that adds or removes physical volumes (for example,
 \fBvgextend\fP, \fBvgreduce\fP, \fBvgsplit\fP, or \fBvgmerge\fP), may cause
 LVM to automatically set or clear the metadataignore flags.  Also, if
 physical volumes go missing or reappear, or a new number of copies is
-explicitly set (see \fBvgchange --vgmetadatacopies\fP), LVM may adjust
+explicitly set (see \fBvgchange \-\-vgmetadatacopies\fP), LVM may adjust
 the metadataignore flags.
 Set \fBvgmetadatacopies\fP to 0 instructs LVM not to set or clear the
 metadataignore flags automatically.  You may set a value larger than the
 sum of all metadata areas on all physical volumes.  The value can
-be overridden on the command line with \fB--vgmetadatacopies\fP for various
+be overridden on the command line with \fB\-\-vgmetadatacopies\fP for various
 commands (for example, \fBvgcreate\fP and \fBvgchange\fP), and can be
 queryied with the \fBvg_mda_copies\fP field of \fBvgs\fP.  This option
 is useful for volume groups containing large numbers of physical volumes
diff --git a/man/lvm2-activation-generator.8.in b/man/lvm2-activation-generator.8.in
index 180b8da..0f6d838 100644
--- a/man/lvm2-activation-generator.8.in
+++ b/man/lvm2-activation-generator.8.in
@@ -12,7 +12,7 @@ option is used). Otherwise, if \fBlvmetad\fP(8) is enabled,
 the lvm2-activation-generator exits immediately without generating
 any systemd units and LVM2 fully relies on event-based activation
 to activate the LVM2 volumes instead using the \fBpvscan\fP(8)
-(pvscan --cache -aay) call that is a part of \fBudev\fP(8) rules.
+(pvscan \-\-cache -aay) call that is a part of \fBudev\fP(8) rules.
 
 These systemd units are generated by lvm2-activation-generator:
 .sp
diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 5a09257..87fb9f4 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -1,6 +1,6 @@
 .TH "LVMCACHE" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH NAME
-lvmcache - LVM caching
+lvmcache \(em LVM caching
 
 .SH DESCRIPTION
 
@@ -66,22 +66,22 @@ steps might be used in practice.
 .SS Cache Commands
 .nf
 0. create OriginLV
-lvcreate -L LargeSize -n OriginLV VG SlowPVs
+lvcreate \-L LargeSize \-n OriginLV VG SlowPVs
 
 1. create CacheDataLV
-lvcreate -L CacheSize -n CacheDataLV VG FastPVs
+lvcreate \-L CacheSize \-n CacheDataLV VG FastPVs
 
 2. create CacheMetaLV
-lvcreate -L MetaSize -n CacheMetaLV VG FastPVs
+lvcreate \-L MetaSize \-n CacheMetaLV VG FastPVs
 
 3. create CachePoolLV
-lvconvert --type cache-pool --poolmetadata VG/CacheMetaLV VG/CacheDataLV
+lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV VG/CacheDataLV
 CachePoolLV takes the name of CacheDataLV.
 CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
 4. create CacheLV
-lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
+lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
 CacheLV takes the name of OriginLV.
 OriginLV is renamed OriginLV_corig and becomes hidden.
 .fi
@@ -94,20 +94,20 @@ Creating a simple cache LV.
 
 .nf
 0. Create the origin LV
-# lvcreate -L 10G -n lvx vg /dev/slow_dev
+# lvcreate \-L 10G \-n lvx vg /dev/slow_dev
 
 1. Create a cache data LV
-# lvcreate -L 1G -n lvx_cache vg /dev/fast_dev
+# lvcreate \-L 1G \-n lvx_cache vg /dev/fast_dev
 
 2. Create a cache metadata LV (~1/1000th size of CacheDataLV or 8MiB)
-# lvcreate -L 8M -n lvx_cache_meta vg /dev/fast_dev
+# lvcreate \-L 8M \-n lvx_cache_meta vg /dev/fast_dev
 
 3. Create a cache pool LV, combining cache data LV and cache metadata LV
-# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
+# lvconvert \-\-type cache-pool \-\-poolmetadata vg/lvx_cache_meta \\
 	vg/lvx_cache
 
 4. Create a cached LV by combining the cache pool LV and origin LV
-# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
+# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
 .B Example 2:
@@ -120,22 +120,22 @@ redundant.  Example 2 illustrates how to do that.  Note that only steps
 
 .nf
 0. Create an origin LV we wish to cache
-# lvcreate -L 10G -n lvx vg /dev/slow_devs
+# lvcreate \-L 10G \-n lvx vg /dev/slow_devs
 
 1. Create a 2-way RAID1 cache data LV
-# lvcreate --type raid1 -m 1 -L 1G -n lvx_cache vg \\
+# lvcreate \-\-type raid1 \-m 1 \-L 1G -n lvx_cache vg \\
 	/dev/fast1 /dev/fast2
 
 2. Create a 2-way RAID1 cache metadata LV
-# lvcreate --type raid1 -m 1 -L 8M -n lvx_cache_meta vg \\
+# lvcreate \-\-type raid1 \-m 1 \-L 8M -n lvx_cache_meta vg \\
 	/dev/fast1 /dev/fast2
 
 3. Create a cache pool LV combining cache data LV and cache metadata LV
-# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
+# lvconvert \-\-type cache-pool \-\-poolmetadata vg/lvx_cache_meta \\
 	vg/lvx_cache
 
 4. Create a cached LV by combining the cache pool LV and origin LV
-# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
+# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
 .B Example 3:
@@ -151,20 +151,20 @@ in this case.
 
 .nf
 0. Create an origin LV we wish to cache (yours may already exist)
-# lvcreate -L 10G -n lvx vg /dev/slow
+# lvcreate \-L 10G \-n lvx vg /dev/slow
 
 1. Create a cache data LV
-# lvcreate -L 1G -n lvx_cache vg /dev/fast
+# lvcreate \-L 1G \-n lvx_cache vg /dev/fast
 
 2. Create a cache metadata LV
-# lvcreate -L 8M -n lvx_cache_meta vg /dev/fast
+# lvcreate \-L 8M \-n lvx_cache_meta vg /dev/fast
 
 3. Create a cache pool LV specifying cache mode "writethrough"
-# lvconvert --type cache-pool --poolmetadata vg/lvx_cache_meta \\
-	--cachemode writethrough vg/lvx_cache
+# lvconvert \-\-type cache-pool \-\-poolmetadata vg/lvx_cache_meta \\
+	\-\-cachemode writethrough vg/lvx_cache
 
 4. Create a cache LV by combining the cache pool LV and origin LV
-# lvconvert --type cache --cachepool vg/lvx_cache vg/lvx
+# lvconvert \-\-type cache \-\-cachepool vg/lvx_cache vg/lvx
 .fi
 
 .SS Removing Cache Logical Volumes
diff --git a/man/lvmchange.8.in b/man/lvmchange.8.in
index 0d58813..dc6b3bd 100644
--- a/man/lvmchange.8.in
+++ b/man/lvmchange.8.in
@@ -1,6 +1,6 @@
 .TH LVMCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvmchange \- change attributes of the logical volume manager
+lvmchange \(em change attributes of the logical volume manager
 .SH SYNOPSIS
 .B lvmchange
 .SH DESCRIPTION
diff --git a/man/lvmconf.8.in b/man/lvmconf.8.in
index 2c822ee..bfd539a 100644
--- a/man/lvmconf.8.in
+++ b/man/lvmconf.8.in
@@ -1,9 +1,7 @@
 .TH "LVMCONF" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 
 .SH "NAME"
-.B lvmconf
-\- LVM configuration modifier
-
+lvmconf \(em LVM configuration modifier
 .SH "SYNOPSIS"
 .B lvmconf
 .RB [ \-\-disable-cluster ]
diff --git a/man/lvmdiskscan.8.in b/man/lvmdiskscan.8.in
index c35d071..6de34c1 100644
--- a/man/lvmdiskscan.8.in
+++ b/man/lvmdiskscan.8.in
@@ -1,6 +1,6 @@
 .TH LVMDISKSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvmdiskscan \- scan for all devices visible to LVM2
+lvmdiskscan \(em scan for all devices visible to LVM2
 .SH SYNOPSIS
 .B lvmdiskscan
 .RB [ \-\-commandprofile
diff --git a/man/lvmdump.8.in b/man/lvmdump.8.in
index a34e062..9a8c469 100644
--- a/man/lvmdump.8.in
+++ b/man/lvmdump.8.in
@@ -1,6 +1,6 @@
 .TH LVMDUMP 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
-lvmdump - create lvm2 information dumps for diagnostic purposes
+lvmdump \(em create lvm2 information dumps for diagnostic purposes
 .SH SYNOPSIS
 .B lvmdump
 .RB [ \-a ]
@@ -83,10 +83,10 @@ of systemd journal for current boot.
 .TP
 .B \-u
 Gather udev info and context: /etc/udev/udev.conf file, udev daemon version
-(output of 'udevadm info --version' command), udev rules currently used in the system
+(output of 'udevadm info \-\-version' command), udev rules currently used in the system
 (content of /lib/udev/rules.d and /etc/udev/rules.d directory),
 list of files in /lib/udev directory and dump of current udev
-database content (the output of 'udevadm info --export-db' command).
+database content (the output of 'udevadm info \-\-export\-db' command).
 .SH ENVIRONMENT VARIABLES
 .TP
 \fBLVM_BINARY\fP
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index a8ca678..4f60249 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -1,6 +1,6 @@
 .TH LVMETAD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
 .SH NAME
-lvmetad \- LVM metadata cache daemon
+lvmetad \(em LVM metadata cache daemon
 .SH SYNOPSIS
 .B lvmetad
 .RB [ \-l
@@ -22,7 +22,7 @@ consistent image of the volume groups available in the system.
 lvmetad is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by specifying the
 \fBglobal/use_lvmetad\fP setting. If this is not defined in the LVM configuration
 explicitly then default setting is used instead (see the output of
-\fBlvm dumpconfig --type default global/use_lvmetad\fP command).
+\fBlvm dumpconfig \-\-type default global/use_lvmetad\fP command).
 .SH OPTIONS
 
 To run the daemon in a test environment both the pidfile_path and the
@@ -37,11 +37,11 @@ Show help information.
 .IR \fB\-l " {" all | wire | debug }
 Select the type of log messages to generate.
 Messages are logged by syslog.  
-Additionally, when -f is given they are also sent to standard error.
+Additionally, when \-f is given they are also sent to standard error.
 Since release 2.02.98, there are two classes of messages: wire and debug.
 Selecting 'all' supplies both and is equivalent to a comma-separated list
--l wire,debug.
-Prior to release 2.02.98, repeating -d from 1 to 3 times, viz. -d, -dd, -ddd,
+\-l wire,debug.
+Prior to release 2.02.98, repeating \-d from 1 to 3 times, viz. \-d, \-dd, \-ddd,
 increased the detail of messages.
 .TP
 .B \-p \fIpidfile_path
diff --git a/man/lvmsadc.8.in b/man/lvmsadc.8.in
index e0af210..e156de2 100644
--- a/man/lvmsadc.8.in
+++ b/man/lvmsadc.8.in
@@ -1,7 +1,7 @@
 .TH "LVMSADC" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 
 .SH "NAME"
-lvmsadc \- LVM system activity data collector
+lvmsadc \(em LVM system activity data collector
 
 .SH "SYNOPSIS"
 .B lvmsadc
diff --git a/man/lvmsar.8.in b/man/lvmsar.8.in
index 29de791..a9a6132 100644
--- a/man/lvmsar.8.in
+++ b/man/lvmsar.8.in
@@ -1,7 +1,7 @@
 .TH "LVMSAR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 
 .SH "NAME"
-lvmsar \- LVM system activity reporter
+lvmsar \(em LVM system activity reporter
 
 .SH "SYNOPSIS"
 .B lvmsar
diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 030745b..a2da3ca 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -1,7 +1,7 @@
 .TH "LVMTHIN" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 
 .SH NAME
-lvmthin - LVM thin provisioning
+lvmthin \(em LVM thin provisioning
 
 .SH DESCRIPTION
 
@@ -101,20 +101,20 @@ The primary method for using lvm thin provisioning:
    Create an LV that will hold thin pool data.
 
    Command
-   lvcreate -n ThinDataLV -L LargeSize VG
+   lvcreate \-n ThinDataLV \-L LargeSize VG
 
    Example
-   # lvcreate -n pool0 -L 10G vg
+   # lvcreate \-n pool0 \-L 10G vg
 
 2. create ThinMetaLV
 
    Create an LV that will hold thin pool metadata.
 
    Command
-   lvcreate -n ThinMetaLV -L SmallSize VG
+   lvcreate \-n ThinMetaLV \-L SmallSize VG
 
    Example
-   # lvcreate -n pool0meta -L 1G vg
+   # lvcreate \-n pool0meta \-L 1G vg
 
    # lvs
    pool0     vg          -wi-a-----  10.00g
@@ -128,10 +128,10 @@ The primary method for using lvm thin provisioning:
    The new ThinPoolLV takes the previous name of ThinDataLV.
 
    Command
-   lvconvert --thinpool VG/ThinDataLV --poolmetadata VG/ThinMetaLV
+   lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
    Example
-   # lvconvert --thinpool vg/pool0 --poolmetadata vg/pool0meta
+   # lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 
    # lvs vg/pool0
    LV    VG  Attr       LSize  Pool Origin Data%
@@ -152,14 +152,14 @@ The primary method for using lvm thin provisioning:
    contain the ThinLV.
 
    Command
-   lvcreate --type thin -n ThinLV -V VirtualSize --thinpool VG/ThinPoolLV
+   lvcreate \-\-type thin \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
 
    Example
    Create a thin LV in a thin pool:
-   # lvcreate --type thin -n thin1 -V 1T --thinpool vg/pool0
+   # lvcreate \-\-type thin \-n thin1 \-V 1T \-\-thinpool vg/pool0
 
    Create another thin LV in the same thin pool:
-   # lvcreate --type thin -n thin2 -V 1T --thinpool vg/pool0
+   # lvcreate \-\-type thin \-n thin2 \-V 1T \-\-thinpool vg/pool0
 
    # lvs vg/thin1 vg/thin2
    LV    VG  Attr       LSize Pool  Origin Data%
@@ -171,18 +171,18 @@ The primary method for using lvm thin provisioning:
    Create snapshots of an existing ThinLV or SnapLV.
 
    Command
-   lvcreate --type thin -n SnapLV -s ThinLV --thinpool VG/ThinPoolLV
-   lvcreate --type thin -n SnapLV -s PrevSnapLV --thinpool VG/ThinPoolLV
+   lvcreate \-\-type thin \-n SnapLV \-s ThinLV \-\-thinpool VG/ThinPoolLV
+   lvcreate \-\-type thin \-n SnapLV \-s PrevSnapLV \-\-thinpool VG/ThinPoolLV
 
    Example
    Create first snapshot of an existing ThinLV:
-   # lvcreate --type thin -n thin1s1 -s thin1 --thinpool vg/pool0
+   # lvcreate \-\-type thin \-n thin1s1 \-s thin1 \-\-thinpool vg/pool0
 
    Create second snapshot of the same ThinLV:
-   # lvcreate --type thin -n thin1s2 -s thin1 --thinpool vg/pool0
+   # lvcreate \-\-type thin \-n thin1s2 \-s thin1 \-\-thinpool vg/pool0
 
    Create a snapshot of the first snapshot:
-   # lvcreate --type thin -n thin1s1s1 -s thin1s1 --thinpool vg/pool0
+   # lvcreate \-\-type thin \-n thin1s1s1 \-s thin1s1 \-\-thinpool vg/pool0
 
    # lvs vg/thin1s1 vg/thin1s2 vg/thin1s1s1
    LV        VG  Attr       LSize Pool  Origin
@@ -193,19 +193,19 @@ The primary method for using lvm thin provisioning:
 6. activate SnapLV
 
    Thin snapshots are created with the persistent "activation skip"
-   flag, indicated by the "k" attribute.  Use -K with lvchange
+   flag, indicated by the "k" attribute.  Use \-K with lvchange
    or vgchange to activate thin snapshots with the "k" attribute.
-   
+
    Command
-   lvchange -ay -K VG/SnapLV
-   
+   lvchange \-ay \-K VG/SnapLV
+
    Example
-   # lvchange -ay -K vg/thin1s1
-   
+   # lvchange \-ay \-K vg/thin1s1
+
    # lvs vg/thin1s1
    thin1s1 vg   Vwi-a-tz-k 1.00t pool0 thin1
 .fi
-   
+
 
 .SH Thin Topics
 
@@ -268,14 +268,14 @@ at the end of the lvcreate line.  It can be especially helpful
 to use fast devices for the metadata LV.
 
 .nf
-lvcreate -n ThinDataLV -L LargeSize VG LargePV
-lvcreate -n ThinMetaLV -L SmallSize VG SmallPV
-lvconvert --thinpool VG/ThinDataLV --poolmetadata VG/ThinMetaLV
+lvcreate \-n ThinDataLV \-L LargeSize VG LargePV
+lvcreate \-n ThinMetaLV \-L SmallSize VG SmallPV
+lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
 Example
-# lvcreate -n pool0 -L 10G vg /dev/sdA
-# lvcreate -n pool0meta -L 1G vg /dev/sdB
-# lvconvert --thinpool vg/pool0 --poolmetadata vg/pool0meta
+# lvcreate \-n pool0 \-L 10G vg /dev/sdA
+# lvcreate \-n pool0meta \-L 1G vg /dev/sdB
+# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 .fi
 
 .BR lvm.conf (5)
@@ -292,14 +292,14 @@ To tolerate device failures, use raid for the pool data LV and
 pool metadata LV.  This is especially recommended for pool metadata LVs.
 
 .nf
-lvcreate --type raid1 -m 1 -n ThinMetaLV -L SmallSize VG PVA PVB
-lvcreate --type raid1 -m 1 -n ThinDataLV -L LargeSize VG PVC PVD
-lvconvert --thinpool VG/ThinDataLV --poolmetadata VG/ThinMetaLV
+lvcreate \-\-type raid1 \-m 1 \-n ThinMetaLV \-L SmallSize VG PVA PVB
+lvcreate \-\-type raid1 \-m 1 \-n ThinDataLV \-L LargeSize VG PVC PVD
+lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
 Example
-# lvcreate --type raid1 -m 1 -n pool0 -L 10G vg /dev/sdA /dev/sdB
-# lvcreate --type raid1 -m 1 -n pool0meta -L 1G vg /dev/sdC /dev/sdD
-# lvconvert --thinpool vg/pool0 --poolmetadata vg/pool0meta
+# lvcreate \-\-type raid1 \-m 1 \-n pool0 \-L 10G vg /dev/sdA /dev/sdB
+# lvcreate \-\-type raid1 \-m 1 \-n pool0meta \-L 1G vg /dev/sdC /dev/sdD
+# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 .fi
 
 
@@ -309,7 +309,7 @@ Example
 
 The first time a thin pool LV is created, lvm will create a spare
 metadata LV in the VG.  This behavior can be controlled with the
-option --poolmetadataspare y|n.  (Future thin pool creations will
+option \-\-poolmetadataspare y|n.  (Future thin pool creations will
 also attempt to create the pmspare LV if none exists.)
 
 To create the pmspare ("pool metadata spare") LV, lvm first creates
@@ -323,11 +323,11 @@ explicitly.
 
 .nf
 Example
-# lvcreate -n pool0 -L 10G vg
-# lvcreate -n pool0meta -L 10G vg
-# lvconvert --thinpool vg/pool0 --poolmetadata vg/pool0meta
+# lvcreate \-n pool0 \-L 10G vg
+# lvcreate \-n pool0meta \-L 10G vg
+# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 
-# lvs -a
+# lvs \-a
 [lvol0_pmspare] vg          ewi-------  10.00g
 pool0           vg          twi---tz--  10.00g
 [pool0_tdata]   vg          Twi-------  10.00g
@@ -366,7 +366,7 @@ be repaired.
 
 Command to repair a thin pool:
 .nf
-lvconvert --repair VG/ThinPoolLV
+lvconvert \-\-repair VG/ThinPoolLV
 .fi
 
 Repair performs the following steps:
@@ -396,7 +396,7 @@ the pool metadata LV can be manually swapped with another LV
 containing new metadata:
 
 .nf
-lvconvert --thinpool VG/ThinPoolLV --poolmetadata VG/NewThinMetaLV
+lvconvert \-\-thinpool VG/ThinPoolLV \-\-poolmetadata VG/NewThinMetaLV
 .fi
 
 
@@ -409,14 +409,14 @@ specifying a thin pool metadata LV.  LVM will automatically
 create a metadata LV from the same VG.
 
 .nf
-lvcreate -n ThinDataLV -L LargeSize VG
-lvconvert --thinpool VG/ThinDataLV
+lvcreate \-n ThinDataLV \-L LargeSize VG
+lvconvert \-\-thinpool VG/ThinDataLV
 
 Example
-# lvcreate -n pool0 -L 10G vg
-# lvconvert --thinpool vg/pool0
+# lvcreate \-n pool0 \-L 10G vg
+# lvconvert \-\-thinpool vg/pool0
 
-# lvs -a
+# lvs \-a
 pool0           vg          twi-a-tz--  10.00g
 [pool0_tdata]   vg          Twi-ao----  10.00g
 [pool0_tmeta]   vg          ewi-ao----  16.00m
@@ -442,31 +442,31 @@ by normal activation commands.  The skipping behavior does not
 apply to deactivation commands.
 
 A snapshot LV with the "k" attribute can be activated using
-the -K (or --ignoreactivationskip) option in addition to the
-standard -ay (or --activate y) option.
+the \-K (or \-\-ignoreactivationskip) option in addition to the
+standard \-ay (or \-\-activate y) option.
 
 Command to activate a thin snapshot LV:
 .nf
-lvchange -ay -K VG/SnapLV
+lvchange \-ay \-K VG/SnapLV
 .fi
 
 The persistent "activation skip" flag can be turned off during
-lvcreate, or later with lvchange using the -kn
-(or --setactivationskip n) option.
-It can be turned on again with -ky (or --setactivationskip y).
+lvcreate, or later with lvchange using the \-kn
+(or \-\-setactivationskip n) option.
+It can be turned on again with \-ky (or \-\-setactivationskip y).
 
 When the "activation skip" flag is removed, normal activation
-commands will activate the LV, and the -K activation option is
+commands will activate the LV, and the \-K activation option is
 not needed.
 
 Command to create snapshot LV without the activation skip flag:
 .nf
-lvcreate --type thin -n SnapLV -kn -s ThinLV --thinpool VG/ThinPoolLV
+lvcreate \-\-type thin \-n SnapLV \-kn \-s ThinLV \-\-thinpool VG/ThinPoolLV
 .fi
 
 Command to remove the activation skip flag from a snapshot LV:
 .nf
-lvchange -kn VG/SnapLV
+lvchange \-kn VG/SnapLV
 .fi
 
 .BR lvm.conf (5)
@@ -498,26 +498,26 @@ vgcfgbackup does not back up thin pool metadata.
 
 The available free space in a thin pool LV can be displayed
 with the lvs command.  Free space can be added by extending
-the thin pool LV. 
+the thin pool LV.
 
 .nf
 Command to extend thin pool data space:
-lvextend -L Size VG/ThinPoolLV
+lvextend \-L Size VG/ThinPoolLV
 
 Example
 
 1. A thin pool LV is using 26.96% of its data blocks.
 # lvs
-LV    VG           Attr       LSize   Pool  Origin Data%                                     
-pool0 vg           twi-a-tz--  10.00g               26.96                          
+LV    VG           Attr       LSize   Pool  Origin Data%
+pool0 vg           twi-a-tz--  10.00g               26.96
 
 2. Double the amount of physical space in the thin pool LV.
-# lvextend -L+10G vg/pool0
+# lvextend \-L+10G vg/pool0
 
 3. The percentage of used data blocks is half the previous value.
 # lvs
-LV    VG           Attr       LSize   Pool  Origin Data%                                          
-pool0 vg           twi-a-tz--  20.00g               13.48  
+LV    VG           Attr       LSize   Pool  Origin Data%
+pool0 vg           twi-a-tz--  20.00g               13.48
 .fi
 
 Other methods of increasing free data space in a thin pool LV
@@ -530,25 +530,25 @@ fstrim on the file system using a thin LV.
 \&
 
 The available metadata space in a thin pool LV can be displayed
-with the lvs -o+metadata_percent command.
+with the lvs \-o+metadata_percent command.
 
 Command to extend thin pool metadata space:
 .nf
-lvextend -L Size VG/ThinPoolLV_tmeta
+lvextend \-L Size VG/ThinPoolLV_tmeta
 .fi
 
 Example
 
-1. A thin pool LV is using 12.40% of its metadata blocks. 
+1. A thin pool LV is using 12.40% of its metadata blocks.
 .nf
-# lvs -oname,size,data_percent,metadata_percent vg/pool0
-LV    LSize   Data%  Meta% 
+# lvs \-oname,size,data_percent,metadata_percent vg/pool0
+LV    LSize   Data%  Meta%
 pool0  20.00g  13.48  12.40
 .fi
 
 2. Display a thin pool LV with its component thin data LV and thin metadata LV.
 .nf
-# lvs -a -oname,attr,size vg
+# lvs \-a \-oname,attr,size vg
 LV              Attr       LSize
 pool0           twi-a-tz--  20.00g
 [pool0_tdata]   Twi-ao----  20.00g
@@ -557,12 +557,12 @@ pool0           twi-a-tz--  20.00g
 
 3. Double the amount of physical space in the thin metadata LV.
 .nf
-# lvextend -L+12M vg/pool0_tmeta
+# lvextend \-L+12M vg/pool0_tmeta
 .fi
 
 4. The percentage of used metadata blocks is half the previous value.
 .nf
-# lvs -a -oname,size,data_percent,metadata_percent vg
+# lvs \-a \-oname,size,data_percent,metadata_percent vg
 LV              LSize   Data%  Meta%
 pool0            20.00g  13.48   6.20
 [pool0_tdata]    20.00g
@@ -581,7 +581,7 @@ been used by removed files.  fstrim uses discards and will not work
 if the thin pool LV has discards mode set to ignore.
 
 Example
- 
+
 A thin pool has 10G of physical data space, and a thin LV has a virtual
 size of 100G.  Writing a 1G file to the file system reduces the
 free space in the thin pool by 10% and increases the virtual usage
@@ -590,38 +590,38 @@ of the file system by 1%.  Removing the 1G file restores the virtual
 thin pool.  The fstrim command restores the physical space to the thin pool.
 
 .nf
-# lvs -a -oname,attr,size,pool_lv,origin,data_percent,metadata_percent vg
+# lvs \-a \-oname,attr,size,pool_lv,origin,data_percent,metadata_percent vg
 LV              Attr       LSize   Pool  Origin Data%  Meta%
 pool0           twi-a-tz--  10.00g               47.01  21.03
-thin1           Vwi-aotz-- 100.00g pool0          2.70       
+thin1           Vwi-aotz-- 100.00g pool0          2.70
 
-# df -h /mnt/X
+# df \-h /mnt/X
 Filesystem            Size  Used Avail Use% Mounted on
 /dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
 
 # dd if=/dev/zero of=/mnt/X/1Gfile bs=4096 count=262144; sync
 
 # lvs
-pool0           vg   twi-a-tz--  10.00g               57.01  25.26                
-thin1           vg   Vwi-aotz-- 100.00g pool0          3.70       
+pool0           vg   twi-a-tz--  10.00g               57.01  25.26
+thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
 
-# df -h /mnt/X
+# df \-h /mnt/X
 /dev/mapper/vg-thin1   99G  2.1G   92G   3% /mnt/X
 
 # rm /mnt/X/1Gfile
 
 # lvs
-pool0           vg   twi-a-tz--  10.00g               57.01  25.26                       
-thin1           vg   Vwi-aotz-- 100.00g pool0          3.70       
+pool0           vg   twi-a-tz--  10.00g               57.01  25.26
+thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
 
-# df -h /mnt/X
+# df \-h /mnt/X
 /dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
 
-# fstrim -v /mnt/X
+# fstrim \-v /mnt/X
 
 # lvs
-pool0           vg   twi-a-tz--  10.00g               47.01  21.03                     
-thin1           vg   Vwi-aotz-- 100.00g pool0          2.70       
+pool0           vg   twi-a-tz--  10.00g               47.01  21.03
+thin1           vg   Vwi-aotz-- 100.00g pool0          2.70
 .fi
 
 The "Discard" section covers an option for automatically freeing data
@@ -641,9 +641,9 @@ Command to enable or disable the monitoring and automatic extension
 of an existing thin pool LV:
 
 .nf
-lvchange --monitor {y|n} VG/ThinPoolLV
+lvchange \-\-monitor {y|n} VG/ThinPoolLV
 .fi
- 
+
 .BR lvm.conf (5)
 .B thin_pool_autoextend_threshold thin_pool_autoextend_percent
 .br
@@ -716,7 +716,7 @@ When metadata space is exhausted, the lvs command displays 100 under Meta%
 for the thin pool LV:
 
 .nf
-# lvs -o lv_name,size,data_percent,metadata_percent vg/pool0
+# lvs \-o lv_name,size,data_percent,metadata_percent vg/pool0
 LV    LSize Data%  Meta%
 pool0              100.00
 .fi
@@ -730,7 +730,7 @@ repair.
 
 1. Deactivate the thin pool LV, or reboot the system if this is not possible.
 
-2. Repair thin pool with lvconvert --repair.
+2. Repair thin pool with lvconvert \-\-repair.
 .br
    See "Metadata check and repair".
 
@@ -747,17 +747,17 @@ repair.
 
 When a thin pool provisions a new data block for a thin LV, the
 new block is first overwritten with zeros.  The zeroing mode is
-indicated by the "z" attribute displayed by lvs.  The option -Z
-(or --zero) can be added to commands to specify the zeroing mode.
+indicated by the "z" attribute displayed by lvs.  The option \-Z
+(or \-\-zero) can be added to commands to specify the zeroing mode.
 
 Command to set the zeroing mode when creating a thin pool LV:
 .nf
-lvconvert -Z{y|n} --thinpool VG/ThinDataLV --poolmetadata VG/ThinMetaLV
+lvconvert \-Z{y|n} \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 .fi
 
 Command to change the zeroing mode of an existing thin pool LV:
 .nf
-lvchange -Z{y|n} VG/ThinPoolLV
+lvchange \-Z{y|n} VG/ThinPoolLV
 .fi
 
 If zeroing mode is changed from "n" to "y", previously provisioned
@@ -791,26 +791,26 @@ mode.
 
 Command to display the current discard mode of a thin pool LV:
 .nf
-lvs -o+discards VG/ThinPoolLV
+lvs \-o+discards VG/ThinPoolLV
 .fi
- 
+
 Command to set the discard mode when creating a thin pool LV:
 .nf
-lvconvert --discards {ignore|nopassdown|passdown}
-    --thinpool VG/ThinDataLV --poolmetadata VG/ThinMetaLV
+lvconvert \-\-discards {ignore|nopassdown|passdown}
+    \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 .fi
 
 Command to change the discard mode of an existing thin pool LV:
 .nf
-lvchange --discards {ignore|nopassdown|passdown} VG/ThinPoolLV
+lvchange \-\-discards {ignore|nopassdown|passdown} VG/ThinPoolLV
 .fi
- 
+
 .nf
 Example
-# lvs -o name,discards vg/pool0
+# lvs \-o name,discards vg/pool0
 pool0 passdown
 
-# lvchange --discards ignore vg/pool0
+# lvchange \-\-discards ignore vg/pool0
 .fi
 
 .BR lvm.conf (5)
@@ -824,7 +824,7 @@ controls the default discards mode used when creating a thin pool.
 \&
 
 The size of data blocks managed by a thin pool can be specified with
-the --chunksize option when the thin pool LV is created.  The default
+the \-\-chunksize option when the thin pool LV is created.  The default
 unit is kilobytes and the default value is 64KiB.  The value must be a
 power of two between 4KiB and 1GiB.
 
@@ -834,10 +834,10 @@ a smaller value reduces copying time and consumes less space.
 
 Command to display the thin pool LV chunk size:
 .nf
-lvs -o+chunksize VG/ThinPoolLV
- 
+lvs \-o+chunksize VG/ThinPoolLV
+
 Example
-# lvs -o name,chunksize
+# lvs \-o name,chunksize
 pool0 64.00k
 .fi
 
@@ -863,7 +863,7 @@ ThinPoolLVSize / ThinPoolLVChunkSize * 64b.
 
 When creating a thin metadata LV explicitly, the size is specified
 in the lvcreate command.  When a command automatically creates a
-thin metadata LV, the --poolmetadatasize option can be used specify
+thin metadata LV, the \-\-poolmetadatasize option can be used specify
 a non-default size.  The default unit is megabytes.
 
 
@@ -878,13 +878,13 @@ snapshot are stored in the thin pool, and the external LV is used
 to read unwritten parts of the thin snapshot.
 
 .nf
-lvcreate --type thin -n SnapLV -s VG/ExternalOriginLV
-      --thinpool VG/ThinPoolLV
- 
+lvcreate \-\-type thin \-n SnapLV \-s VG/ExternalOriginLV
+      \-\-thinpool VG/ThinPoolLV
+
 Example
-# lvchange -an vg/lve
-# lvchange --permission r vg/lve
-# lvcreate --type thin -n snaplve -s vg/lve --thinpool vg/pool0
+# lvchange \-an vg/lve
+# lvchange \-\-permission r vg/lve
+# lvcreate \-\-type thin \-n snaplve \-s vg/lve \-\-thinpool vg/pool0
 
 # lvs vg/lve vg/snaplve
 LV      VG  Attr       LSize  Pool  Origin Data%
@@ -902,7 +902,7 @@ standard LV.  At the same time, the existing LV is converted to a
 read only external LV with a new name.  Unwritten portions of the
 thin LV are read from the external LV.
 The new name given to the existing LV can be specified with
---originname, otherwise the existing LV will be given a default
+\-\-originname, otherwise the existing LV will be given a default
 name, e.g. lvol#.
 
 Convert ExampleLV into a read only external LV with the new name
@@ -910,17 +910,17 @@ NewExternalOriginLV, and create a new thin LV that is given the previous
 name of ExampleLV.
 
 .nf
-lvconvert --type thin --thinpool VG/ThinPoolLV
-      --originname NewExternalOriginLV --thin VG/ExampleLV
+lvconvert \-\-type thin \-\-thinpool VG/ThinPoolLV
+      \-\-originname NewExternalOriginLV \-\-thin VG/ExampleLV
 
 Example
-# lvcreate -n lv_example -L 10G vg
+# lvcreate \-n lv_example \-L 10G vg
 
 # lvs
 lv_example      vg          -wi-a-----  10.00g
 
-# lvconvert --type thin --thinpool vg/pool0
-          --originname lv_external --thin vg/lv_example
+# lvconvert \-\-type thin \-\-thinpool vg/pool0
+          \-\-originname lv_external \-\-thin vg/lv_example
 
 # lvs
 LV              VG          Attr       LSize   Pool  Origin
@@ -939,16 +939,16 @@ This one command creates a thin data LV, a thin metadata LV,
 and combines the two into a thin pool LV.
 
 .nf
-lvcreate -L LargeSize --thinpool VG/ThinPoolLV
+lvcreate \-L LargeSize \-\-thinpool VG/ThinPoolLV
 
 Example
-# lvcreate -L8M --thinpool vg/pool0
+# lvcreate \-L8M \-\-thinpool vg/pool0
 
 # lvs vg/pool0
 LV    VG  Attr       LSize Pool Origin Data%
 pool0 vg  twi-a-tz-- 8.00m               0.00
 
-# lvs -a
+# lvs \-a
 pool0           vg          twi-a-tz--   8.00m
 [pool0_tdata]   vg          Twi-ao----   8.00m
 [pool0_tmeta]   vg          ewi-ao----   8.00m
@@ -964,21 +964,21 @@ lvcreate command.  This one command creates a thin data LV,
 a thin metadata LV, combines the two into a thin pool LV,
 and creates a thin LV in the new pool.
 .br
--L LargeSize specifies the physical size of the thin pool LV.
+\-L LargeSize specifies the physical size of the thin pool LV.
 .br
--V VirtualSize specifies the virtual size of the thin LV.
+\-V VirtualSize specifies the virtual size of the thin LV.
 
 .nf
-lvcreate -L LargeSize -V VirtualSize -n ThinLV --thinpool VG/ThinPoolLV
+lvcreate \-L LargeSize \-V VirtualSize \-n ThinLV \-\-thinpool VG/ThinPoolLV
 
 Equivalent to:
-lvcreate -L LargeSize --thinpool VG/ThinPoolLV
-lvcreate --type thin -n ThinLV -V VirtualSize --thinpool VG/ThinPoolLV
+lvcreate \-L LargeSize \-\-thinpool VG/ThinPoolLV
+lvcreate \-\-type thin \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
 
 Example
-# lvcreate -L8M -V2G -n thin1 --thinpool vg/pool0
+# lvcreate \-L8M \-V2G \-n thin1 \-\-thinpool vg/pool0
 
-# lvs -a
+# lvs \-a
 pool0           vg          twi-a-tz--   8.00m
 [pool0_tdata]   vg          Twi-ao----   8.00m
 [pool0_tmeta]   vg          ewi-ao----   8.00m
@@ -991,7 +991,7 @@ thin1           vg          Vwi-a-tz--   2.00g pool0
 \&
 
 A thin snapshot can be merged into its origin thin LV using the lvconvert
---merge command.  The result of a snapshot merge is that the origin thin
+\-\-merge command.  The result of a snapshot merge is that the origin thin
 LV takes the content of the snapshot LV, and the snapshot LV is removed.
 Any content that was unique to the origin thin LV is lost after the merge.
 
@@ -1001,7 +1001,7 @@ the effect of the merge is delayed until the origin thin LV is next
 activated.
 
 .nf
-lvconvert --merge VG/SnapLV
+lvconvert \-\-merge VG/SnapLV
 
 Example
 # lvs vg
@@ -1010,7 +1010,7 @@ pool0   vg twi-a-tz--  10.00g
 thin1   vg Vwi-a-tz-- 100.00g pool0
 thin1s1 vg Vwi-a-tz-k 100.00g pool0 thin1
 
-# lvconvert --merge vg/thin1s1
+# lvconvert \-\-merge vg/thin1s1
 
 # lvs vg
 LV      VG Attr       LSize   Pool  Origin
@@ -1038,7 +1038,7 @@ file1 file2 file3
 # ls /mnt/Xs
 file3 file4 file5
 
-# lvconvert --merge vg/thin1s1
+# lvconvert \-\-merge vg/thin1s1
 Logical volume vg/thin1s1 contains a filesystem in use.
 Delaying merge since snapshot is open.
 Merging of thin snapshot thin1s1 will occur on next activation.
@@ -1046,7 +1046,7 @@ Merging of thin snapshot thin1s1 will occur on next activation.
 # umount /mnt/X
 # umount /mnt/Xs
 
-# lvs -a vg
+# lvs \-a vg
 LV              VG   Attr       LSize   Pool  Origin
 pool0           vg   twi-a-tz--  10.00g
 [pool0_tdata]   vg   Twi-ao----  10.00g
@@ -1054,13 +1054,13 @@ pool0           vg   twi-a-tz--  10.00g
 thin1           vg   Owi-a-tz-- 100.00g pool0
 [thin1s1]       vg   Swi-a-tz-k 100.00g pool0 thin1
 
-# lvchange -an vg/thin1
-# lvchange -ay vg/thin1
+# lvchange \-an vg/thin1
+# lvchange \-ay vg/thin1
 
 # mount /dev/vg/thin1 /mnt/X
 
 # ls /mnt/X
-file3 file4 file5 
+file3 file4 file5
 .fi
 
 
@@ -1076,18 +1076,18 @@ file system on the origin LV.
 If the snapshot LV is writable, mounting will recover the log to clear the
 dummy transaction, but will require skipping the uuid check:
 
-mount /dev/VG/SnapLV /mnt -o nouuid
+mount /dev/VG/SnapLV /mnt \-o nouuid
 
 Or, the uuid can be changed on disk before mounting:
 
-xfs_admin -U generate /dev/VG/SnapLV
+xfs_admin \-U generate /dev/VG/SnapLV
 .br
 mount /dev/VG/SnapLV /mnt
 
 If the snapshot LV is readonly, the log recovery and uuid check need to be
 skipped while mounting readonly:
 
-mount /dev/VG/SnapLV /mnt -o ro,nouuid,norecovery
+mount /dev/VG/SnapLV /mnt \-o ro,nouuid,norecovery
 
 
 .SH SEE ALSO
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index 852ef0b..120afb7 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -1,6 +1,6 @@
 .TH LVREDUCE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvreduce \- reduce the size of a logical volume
+lvreduce \(em reduce the size of a logical volume
 .SH SYNOPSIS
 .B lvreduce
 .RB [ \-A | \-\-autobackup
diff --git a/man/lvremove.8.in b/man/lvremove.8.in
index 245b6e6..b0bb477 100644
--- a/man/lvremove.8.in
+++ b/man/lvremove.8.in
@@ -1,6 +1,6 @@
 .TH LVREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvremove \- remove a logical volume
+lvremove \(em remove a logical volume
 .SH SYNOPSIS
 .B lvremove
 .RB [ \-A | \-\-autobackup
diff --git a/man/lvrename.8.in b/man/lvrename.8.in
index b299fa2..bba46ae 100644
--- a/man/lvrename.8.in
+++ b/man/lvrename.8.in
@@ -1,6 +1,6 @@
 .TH LVRENAME 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvrename \- rename a logical volume
+lvrename \(em rename a logical volume
 .SH SYNOPSIS
 .B lvrename
 .RB [ \-A | \-\-autobackup
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 52f9e38..ed95a0d 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -1,6 +1,6 @@
 .TH LVRESIZE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvresize \- resize a logical volume
+lvresize \(em resize a logical volume
 .SH SYNOPSIS
 .B lvresize
 .RB [ \-\-alloc " " \fIAllocationPolicy ]
@@ -19,7 +19,7 @@ lvresize \- resize a logical volume
 .RB [ \-n | \-\-nofsck ]
 .RB [ \-r | \-\-resizefs ]
 .IR LogicalVolume { Name | Path }
-.RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
+.RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
 .SH DESCRIPTION
 lvresize allows you to resize a logical volume.
 Be careful when reducing a logical volume's size, because data in the reduced
@@ -30,7 +30,7 @@ Resizing snapshot logical volumes (see
 .BR lvcreate (8)
 for information about creating snapshots) is supported as well.
 But to change the number of copies in a mirrored logical
-volume use 
+volume use
 .BR lvconvert (8).
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
@@ -40,16 +40,16 @@ Force resize without prompting even when it may cause data loss.
 .TP
 .BR \-n ", " \-\-nofsck
 Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use \fB--force\fR to proceed with 
+requires it. You may need to use \fB\-\-force\fR to proceed with
 this option.
 .TP
 .BR \-r ", " \-\-resizefs
-Resize underlying filesystem together with the logical volume using 
+Resize underlying filesystem together with the logical volume using
 \fBfsadm\fR(8).
 .TP
-.IR \fB\-l ", " \fB\-\-extents " [" + | - ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
+.IR \fB\-l ", " \fB\-\-extents " [" + | \- ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
 Change or set the logical volume size in units of logical extents.
-With the \fI+\fP or \fI-\fP sign the value is added to or subtracted from the actual size
+With the \fI+\fP or \fI\-\fP sign the value is added to or subtracted from the actual size
 of the logical volume and without it, the value is taken as an absolute one.
 The total number of physical extents affected will be
 greater than this if, for example, the volume is mirrored.
@@ -68,12 +68,12 @@ to be allocated or freed (including extents used by any mirrors, for example).
 The code may currently allocate or remove more space than you might otherwise
 expect.
 .TP
-.IR \fB\-L ", " \fB\-\-size " [" + | - ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
+.IR \fB\-L ", " \fB\-\-size " [" + | \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Change or set the logical volume size in units of megabytes.
 A size suffix of \fIM\fP for megabytes,
 \fIG\fP for gigabytes, \fIT\fP for terabytes, \fIP\fP for petabytes
 or \fIE\fP for exabytes is optional.
-With the \fI+\fP or \fI-\fP sign the value is added or subtracted
+With the \fI+\fP or \fI\-\fP sign the value is added or subtracted
 from the actual size of the logical volume and rounded
 to the full extent size and without it,
 the value is taken as an absolute one.
@@ -110,13 +110,13 @@ or has rules that ignore the devices LVM2 creates.
 .SH EXAMPLES
 .br
 Extend a logical volume vg1/lv1 by 16MB using physical extents
-/dev/sda:0-1 and /dev/sdb:0-1 for allocation of extents:
+/dev/sda:0\-1 and /dev/sdb:0\-1 for allocation of extents:
 .sp
-.B lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1
+.B lvresize \-L+16M vg1/lv1 /dev/sda:0\-1 /dev/sdb:0\-1
 .SH SEE ALSO
 .BR fsadm (8),
-.BR lvm (8), 
+.BR lvm (8),
 .BR lvconvert (8),
-.BR lvcreate (8), 
-.BR lvreduce (8), 
+.BR lvcreate (8),
+.BR lvreduce (8),
 .BR lvchange (8)
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 43d79d8..2467306 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -1,6 +1,6 @@
 .TH LVS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvs \- report information about logical volumes
+lvs \(em report information about logical volumes
 .SH SYNOPSIS
 .B lvs
 .RB [ \-\-aligned ]
@@ -48,7 +48,7 @@ are components of normally-accessible Logical Volumes, such as mirrors,
 but which are not independently accessible (e.g. not mountable).
 The names of such Logical Volumes are enclosed within square brackets
 in the output.  For example, after creating a mirror using
-.B lvcreate -m1 --mirrorlog disk
+.B lvcreate -m1 \-\-mirrorlog disk
 , this option will reveal three internal Logical
 Volumes, with suffixes mimage_0, mimage_1, and mlog.
 .TP
diff --git a/man/lvscan.8.in b/man/lvscan.8.in
index 001f544..fad0fbe 100644
--- a/man/lvscan.8.in
+++ b/man/lvscan.8.in
@@ -1,6 +1,6 @@
 .TH LVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-lvscan \- scan (all disks) for Logical Volumes
+lvscan \(em scan (all disks) for Logical Volumes
 .SH SYNOPSIS
 .B lvscan
 .RB [ \-a | \-\-all]
diff --git a/man/pvchange.8.in b/man/pvchange.8.in
index 6fe3e3d..606b1dd 100644
--- a/man/pvchange.8.in
+++ b/man/pvchange.8.in
@@ -1,6 +1,6 @@
 .TH PVCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvchange \- change attributes of a physical volume
+pvchange \(em change attributes of a physical volume
 .SH SYNOPSIS
 .B pvchange
 .RB [ \-\-addtag
@@ -49,7 +49,7 @@ Disallows the allocation of physical extents on this physical volume
 (possibly because of disk errors, or because it will be removed after
 freeing it:
 .sp
-.B pvchange -x n /dev/sdk1
+.B pvchange \-x n /dev/sdk1
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8)
diff --git a/man/pvck.8.in b/man/pvck.8.in
index 4308196..368dc06 100644
--- a/man/pvck.8.in
+++ b/man/pvck.8.in
@@ -1,6 +1,6 @@
 .TH PVCK 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvck \- check physical volume metadata
+pvck \(em check physical volume metadata
 .SH SYNOPSIS
 .B pvck
 .RB [ \-\-commandprofile
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 76a0abb..9011585 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -1,6 +1,6 @@
 .TH PVCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvcreate \- initialize a disk or partition for use by LVM
+pvcreate \(em initialize a disk or partition for use by LVM
 .SH SYNOPSIS
 .B pvcreate
 .RB [ \-\-commandprofile
@@ -117,7 +117,7 @@ You should also specify an appropriate \fIPhysicalExtentSize\fP when creating
 the Volume Group with \fBvgcreate\fP.
 .sp
 To see the location of the first Physical Extent of an existing Physical Volume
-use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
+use \fBpvs \-o +pe_start\fP .  It will be a multiple of the requested
 alignment.  In addition it may be shifted by \fIalignment_offset\fP from
 \fIdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP(5)) or
 \fB\-\-dataalignmentoffset\fP.
@@ -149,7 +149,7 @@ area in case you need it in the future and to use this option to instruct
 LVM2 to ignore it.
 .TP
 .B \-\-restorefile \fIfile
-In conjunction with \fB--uuid\fP, this extracts the location and size
+In conjunction with \fB\-\-uuid\fP, this extracts the location and size
 of the data on the PV from the file (produced by \fBvgcfgbackup\fP)
 and ensures that the metadata that the program produces is consistent
 with the contents of the file i.e. the physical extents will be in
@@ -172,11 +172,11 @@ Create a separate bootloader area of specified size besides PV's data
 area. The bootloader area is an area of reserved space on the PV from
 which LVM2 will not allocate any extents and it's kept untouched. This is
 primarily aimed for use with bootloaders to embed their own data or metadata.
-The start of the bootloader area is always aligned, see also \fB--dataalignment\fP
-and \fB--dataalignmentoffset\fP. The bootloader area size may eventually
+The start of the bootloader area is always aligned, see also \fB\-\-dataalignment\fP
+and \fB\-\-dataalignmentoffset\fP. The bootloader area size may eventually
 end up increased due to the alignment, but it's never less than the
 size that is requested. To see the bootloader area start and size of
-an existing Physical Volume use \fBpvs -o +pv_ba_start,pv_ba_size\fP.
+an existing Physical Volume use \fBpvs \-o +pv_ba_start,pv_ba_size\fP.
 .TP
 .B \-\-setphysicalvolumesize \fIsize
 Overrides the automatically-detected size of the PV.  Use with care.
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index 39e6cbf..0f58b05 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -1,6 +1,6 @@
 .TH PVMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvmove \- move physical extents
+pvmove \(em move physical extents
 .SH SYNOPSIS
 .B pvmove
 .RB [ \-\-abort ]
@@ -17,8 +17,8 @@ pvmove \- move physical extents
 .RB [ \-v | \-\-verbose ]
 .RB [ \-n | \-\-name
 .IR LogicalVolume ]
-.RI [ SourcePhysicalVolume [ :PE [ -PE ]...]
-.RI [ DestinationPhysicalVolume [ :PE [ -PE ]...]...]]
+.RI [ SourcePhysicalVolume [ :PE [ \-PE ]...]
+.RI [ DestinationPhysicalVolume [ :PE [ \-PE ]...]...]]
 .SH DESCRIPTION
 pvmove allows you to move the allocated physical extents (PEs) on
 .I SourcePhysicalVolume
@@ -35,7 +35,7 @@ is specified, the normal allocation rules for the Volume Group are used.
 If pvmove gets interrupted for any reason (e.g. the machine crashes)
 then run pvmove again without any PhysicalVolume arguments to
 restart any moves that were in progress from the last checkpoint.
-Alternatively use \fBpvmove --abort\fP at any time to abort them
+Alternatively use \fBpvmove \-\-abort\fP at any time to abort them
 at the last checkpoint.
 
 You can run more than one pvmove at once provided they are moving data
@@ -117,13 +117,13 @@ can be specified like this:
 To perform the action only on extents belonging to the single Logical Volume 
 lvol1 do this:
 .sp
-.B pvmove -n lvol1 /dev/sdb1 /dev/sdc1
+.B pvmove \-n lvol1 /dev/sdb1 /dev/sdc1
 .P
 Rather than moving the contents of the entire device, it is possible to
 move a range of Physical Extents - for example numbers 1000 to 1999
 inclusive on /dev/sdb1 - like this:
 .sp
-.B pvmove /dev/sdb1:1000-1999
+.B pvmove /dev/sdb1:1000\-1999
 .P
 A range can also be specified as start+length, so
 .sp
@@ -135,22 +135,22 @@ also refers to 1000 Physical Extents starting from Physical Extent number 1000.
 To move a range of Physical Extents to a specific location (which must have
 sufficient free extents) use the form:
 .sp
-.B pvmove /dev/sdb1:1000-1999 /dev/sdc1
+.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1
 .sp
 or
 .sp
-.B pvmove /dev/sdb1:1000-1999 /dev/sdc1:0-999
+.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1:0\-999
 .P
 If the source and destination are on the same disk, the 
 .B anywhere
 allocation policy would be needed, like this:
 .sp
-.B pvmove --alloc anywhere /dev/sdb1:1000-1999 /dev/sdb1:0-999
+.B pvmove \-\-alloc anywhere /dev/sdb1:1000\-1999 /dev/sdb1:0\-999
 .P
 The part of a specific Logical Volume present within in a range of Physical
 Extents can also be picked out and moved, like this:
 .sp
-.B pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
+.B pvmove \-n lvol1 /dev/sdb1:1000\-1999 /dev/sdc1
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgconvert (8)
diff --git a/man/pvremove.8.in b/man/pvremove.8.in
index abf1ca9..5f9b055 100644
--- a/man/pvremove.8.in
+++ b/man/pvremove.8.in
@@ -1,6 +1,6 @@
 .TH PVREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvremove \- remove a physical volume
+pvremove \(em remove a physical volume
 .SH SYNOPSIS
 .B pvremove
 .RB [ \-\-commandprofile
diff --git a/man/pvresize.8.in b/man/pvresize.8.in
index 14e459c..2cc1183 100644
--- a/man/pvresize.8.in
+++ b/man/pvresize.8.in
@@ -1,6 +1,6 @@
 .TH PVRESIZE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvresize \- resize a disk or partition in use by LVM2
+pvresize \(em resize a disk or partition in use by LVM2
 .SH SYNOPSIS
 .B pvresize
 .RB [ \-\-commandprofile
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 9f9cde8..ed57980 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -1,6 +1,6 @@
 .TH PVS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvs \- report information about physical volumes
+pvs \(em report information about physical volumes
 .SH SYNOPSIS
 .B pvs
 .RB [ \-a | \-\-all ]
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 19ca3fc..c1187ac 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -1,6 +1,6 @@
 .TH PVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-pvscan \- scan all disks for physical volumes
+pvscan \(em scan all disks for physical volumes
 .SH SYNOPSIS
 .B pvscan
 .RB [ \-\-commandprofile
diff --git a/man/vgcfgbackup.8.in b/man/vgcfgbackup.8.in
index 2bfebc6..17b3bcb 100644
--- a/man/vgcfgbackup.8.in
+++ b/man/vgcfgbackup.8.in
@@ -1,6 +1,6 @@
 .TH VGCFGBACKUP 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgcfgbackup \- backup volume group descriptor area
+vgcfgbackup \(em backup volume group descriptor area
 .SH SYNOPSIS
 .B vgcfgbackup
 .RB [ \-\-commandprofile
@@ -20,7 +20,7 @@ will be backed up.
 .sp
 In a default installation, each volume group gets backed up into a separate
 file bearing the name of the volume group in the directory #DEFAULT_BACKUP_DIR#.
-You can write the backup to an alternative file using \fB-f\fP.  In this case
+You can write the backup to an alternative file using \fB\-f\fP.  In this case
 if you are backing up more than one volume group the filename is
 treated as a template, and %s gets replaced by the volume group name.
 .sp
diff --git a/man/vgcfgrestore.8.in b/man/vgcfgrestore.8.in
index 752fc56..96b0a10 100644
--- a/man/vgcfgrestore.8.in
+++ b/man/vgcfgrestore.8.in
@@ -1,6 +1,6 @@
 .TH VGCFGRESTORE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgcfgrestore \- restore volume group descriptor area
+vgcfgrestore \(em restore volume group descriptor area
 .SH SYNOPSIS
 .B vgcfgrestore
 .RB [ \-\-commandprofile
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index d756811..284a655 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -1,6 +1,6 @@
 .TH VGCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgchange \- change attributes of a volume group
+vgchange \(em change attributes of a volume group
 .SH SYNOPSIS
 .B vgchange
 .RB [ \-\-addtag
@@ -34,7 +34,7 @@ vgchange \- change attributes of a volume group
 .RB [ \-\-noudevsync ]
 .RB [ \-l | \-\-logicalvolume
 .IR MaxLogicalVolumes ]
-.RB [ -p | \-\-maxphysicalvolumes
+.RB [ \-p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
 .RB [ \-\-metadataprofile
 .IR ProfileName ]
@@ -44,7 +44,7 @@ vgchange \- change attributes of a volume group
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-\-refresh ]
-.RB [ -t | \-\-test ]
+.RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .RB [ \-x | \-\-resizeable
@@ -168,8 +168,8 @@ For volume groups with metadata in lvm1 format, the limit is 255.
 If the metadata uses lvm2 format, the value 0 removes this restriction:
 there is then no limit.  If you have a large number of physical volumes in
 a volume group with metadata in lvm2 format, for tool performance reasons,
-you should consider some use of \fB--pvmetadatacopies 0\fP as described in
-\fBpvcreate(8)\fP, and/or use \fB--vgmetadatacopies\fP.
+you should consider some use of \fB\-\-pvmetadatacopies 0\fP as described in
+\fBpvcreate(8)\fP, and/or use \fB\-\-vgmetadatacopies\fP.
 .TP
 .BR \-\-metadataprofile " " \fIProfileName
 Uses and attaches ProfileName configuration profile to the volume group
@@ -181,7 +181,7 @@ attached. See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\
 .BR \-\- [ vg ] metadatacopies " " \fINumberOfCopies | \fIunmanaged | \fIall
 Sets the desired number of metadata copies in the volume group.  If set to
 a non-zero value, LVM will automatically manage the 'metadataignore'
-flags on the physical volumes (see \fBpvchange\fP or \fBpvcreate --metadataignore\fP) in order
+flags on the physical volumes (see \fBpvchange\fP or \fBpvcreate \-\-metadataignore\fP) in order
 to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
 LVM will not automatically manage the 'metadataignore' flags.  If set to
 \fIall\fP, LVM will first clear all of the 'metadataignore' flags on all
@@ -225,12 +225,12 @@ with/by physical volumes.
 .SH Examples
 To activate all known volume groups in the system:
 .sp
-.B vgchange -a y
+.B vgchange \-a y
 
 To change the maximum number of logical volumes of inactive volume group
 vg00 to 128.
 .sp
-.B vgchange -l 128 /dev/vg00
+.B vgchange \-l 128 /dev/vg00
 
 
 .SH SEE ALSO
diff --git a/man/vgck.8.in b/man/vgck.8.in
index 56cbdb0..f09e709 100644
--- a/man/vgck.8.in
+++ b/man/vgck.8.in
@@ -1,6 +1,6 @@
 .TH VGCK 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgck \- check volume group metadata
+vgck \(em check volume group metadata
 .SH SYNOPSIS
 .B vgck
 .RB [ \-\-commandprofile
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index a2340d3..bcfbcfc 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -1,6 +1,6 @@
 .TH VGCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgcreate \- create a volume group
+vgcreate \(em create a volume group
 .SH SYNOPSIS
 .B vgcreate
 .RB [ \-\-addtag
@@ -17,11 +17,11 @@ vgcreate \- create a volume group
 .RB [ \-h | \-\-help ]
 .RB [ \-l | \-\-maxlogicalvolumes
 .IR MaxLogicalVolumes ]
-.RB [ -M | \-\-metadatatype
+.RB [ \-M | \-\-metadatatype
 .IR type ]
 .RB [ \-\-metadataprofile
 .IR ProfileName ]
-.RB [ -p | \-\-maxphysicalvolumes
+.RB [ \-p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
 .RB [ \-\- [ vg ] metadatacopies
 .IR NumberOfCopies | unmanaged | all ]
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index bb2ead7..d1ea89a 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -1,6 +1,6 @@
 .TH VGDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgdisplay \- display attributes of volume groups
+vgdisplay \(em display attributes of volume groups
 .SH SYNOPSIS
 .B vgdisplay
 .RB [ \-A | \-\-activevolumegroups ]
@@ -37,7 +37,7 @@ vgdisplay \- display attributes of volume groups
 .RB [ \-o|\-\-options
 .RI [ + ] Field1 [ ,Field2 ...]]
 .RB [ \-O | \-\-sort
-.RI [ + | - ] Key1 [ , [ + | - ] Key2 ...]]
+.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-separator
 .IR Separator ]
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index ae7291c..52837db 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -1,6 +1,6 @@
 .TH VGEXTEND 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgextend \- add physical volumes to a volume group
+vgextend \(em add physical volumes to a volume group
 .SH SYNOPSIS
 .B vgextend
 .RB [ \-A | \-\-autobackup
diff --git a/man/vgimport.8.in b/man/vgimport.8.in
index 9496d40..31378f4 100644
--- a/man/vgimport.8.in
+++ b/man/vgimport.8.in
@@ -1,6 +1,6 @@
 .TH VGIMPORT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgimport \- make exported volume groups known to the system
+vgimport \(em make exported volume groups known to the system
 .SH SYNOPSIS
 .B vgimport
 .RB [ \-a | \-\-all ]
diff --git a/man/vgimportclone.8.in b/man/vgimportclone.8.in
index 52ff079..cdf5e68 100644
--- a/man/vgimportclone.8.in
+++ b/man/vgimportclone.8.in
@@ -1,6 +1,6 @@
 .TH VGIMPORTCLONE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc." \" -*- nroff -*-
 .SH NAME
-vgimportclone \- import and rename duplicated volume group (e.g. a hardware snapshot)
+vgimportclone \(em import and rename duplicated volume group (e.g. a hardware snapshot)
 .SH SYNOPSIS
 .B vgimportclone
 .RB [ \-n | \-\-basevgname
@@ -38,7 +38,7 @@ To rename the VG associated with "/dev/sdc" and "/dev/sdd"
 from "vg00" to "vg00_snap"
 (and to change associated VG and PV UUIDs) do:
 .sp
-.B vgimportclone --basevgname vg00_snap /dev/sdc /dev/sdd
+.B vgimportclone \-\-basevgname vg00_snap /dev/sdc /dev/sdd
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/vgmerge.8.in b/man/vgmerge.8.in
index f67cffb..bfc8c34 100644
--- a/man/vgmerge.8.in
+++ b/man/vgmerge.8.in
@@ -1,6 +1,6 @@
 .TH VGMERGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgmerge \- merge two volume groups
+vgmerge \(em merge two volume groups
 .SH SYNOPSIS
 .B vgmerge
 .RB [ \-A | \-\-autobackup
@@ -24,7 +24,7 @@ fit into \fIDestinationVolumeGroupName\fP's limits.
 See \fBlvm\fP(8) for common options.
 .TP
 .BR \-l ", " \-\-list
-Display merged \fIDestinationVolumeGroupName\fP like \fBvgdisplay -v\fP.
+Display merged \fIDestinationVolumeGroupName\fP like \fBvgdisplay \-v\fP.
 .TP 
 .BR \-t ", " \-\-test
 Do a test run WITHOUT making any real changes.
@@ -33,7 +33,7 @@ Merge the inactive volume group named "my_vg"
 into the active or inactive volume group named "databases" giving verbose
 runtime information:
 .sp
-.B vgmerge -v databases my_vg
+.B vgmerge \-v databases my_vg
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
diff --git a/man/vgmknodes.8.in b/man/vgmknodes.8.in
index 54fd3ec..4f5bbfe 100644
--- a/man/vgmknodes.8.in
+++ b/man/vgmknodes.8.in
@@ -1,6 +1,6 @@
 .TH VGMKNODES 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgmknodes \- recreate volume group directory and logical volume special files
+vgmknodes \(em recreate volume group directory and logical volume special files
 .SH SYNOPSIS
 .B vgmknodes
 .RB [ \-\-commandprofile
diff --git a/man/vgreduce.8.in b/man/vgreduce.8.in
index 141533e..9e70a0a 100644
--- a/man/vgreduce.8.in
+++ b/man/vgreduce.8.in
@@ -1,6 +1,6 @@
 .TH VGREDUCE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgreduce \- reduce a volume group
+vgreduce \(em reduce a volume group
 .SH SYNOPSIS
 .B vgreduce
 .RB [ \-a | \-\-all ]
@@ -31,7 +31,7 @@ group (new logical volumes may again be created, changed and so on).
 
 If this is not possible (there are logical volumes referencing the missing
 physical volumes) and you cannot or do not want to remove them manually, you
-can run this option with \fB--force\fP to have \fBvgreduce\fP
+can run this option with \fB\-\-force\fP to have \fBvgreduce\fP
 remove any partial LVs.
 
 Any logical volumes and dependent snapshots that were partly on the 
@@ -40,7 +40,7 @@ that lie on disks that are still present.
 
 If your logical volumes spanned several disks including the ones that are
 lost, you might want to try to salvage data first by activating your
-logical volumes with \fB--partial\fP as described in \fBlvm\fP(8).
+logical volumes with \fB\-\-partial\fP as described in \fBlvm\fP(8).
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/vgremove.8.in b/man/vgremove.8.in
index d17db10..f824a56 100644
--- a/man/vgremove.8.in
+++ b/man/vgremove.8.in
@@ -1,6 +1,6 @@
 .TH VGREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgremove \- remove a volume group
+vgremove \(em remove a volume group
 .SH SYNOPSIS
 .B vgremove
 .RB [ \-\-commandprofile
@@ -16,12 +16,12 @@ vgremove \- remove a volume group
 .SH DESCRIPTION
 vgremove allows you to remove one or more volume groups.
 If one or more physical volumes in the volume group are lost,
-consider \fBvgreduce --removemissing\fP to make the volume group
+consider \fBvgreduce \-\-removemissing\fP to make the volume group
 metadata consistent again.
 .sp
 If there are logical volumes that exist in the volume group,
 a prompt will be given to confirm removal.  You can override
-the prompt with \fB-f\fP.
+the prompt with \fB\-f\fP.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
diff --git a/man/vgrename.8.in b/man/vgrename.8.in
index 6951fb0..1f2539b 100644
--- a/man/vgrename.8.in
+++ b/man/vgrename.8.in
@@ -1,6 +1,6 @@
 .TH VGRENAME 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgrename \- rename a volume group
+vgrename \(em rename a volume group
 .SH SYNOPSIS
 .B vgrename
 .RB [ \-A | \-\-autobackup
@@ -47,7 +47,7 @@ Changes the name of the Volume Group with UUID
 .br
 Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to VolGroup00_tmp:
 .sp
-.B vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 VolGroup00_tmp
+.B vgrename Zvlifi\-Ep3t\-e0Ng\-U42h\-o0ye\-KHu1\-nl7Ns4 VolGroup00_tmp
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/vgs.8.in b/man/vgs.8.in
index c32195b..b389ea2 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -1,6 +1,6 @@
 .TH VGS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgs \- report information about volume groups
+vgs \(em report information about volume groups
 .SH SYNOPSIS
 .B vgs
 .RB [ \-a | \-\-all ]
diff --git a/man/vgscan.8.in b/man/vgscan.8.in
index c11b1ea..b9105d8 100644
--- a/man/vgscan.8.in
+++ b/man/vgscan.8.in
@@ -1,6 +1,6 @@
 .TH VGSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgscan \- scan all disks for volume groups and rebuild caches
+vgscan \(em scan all disks for volume groups and rebuild caches
 .SH SYNOPSIS
 .B vgscan
 .RB [ \-\-commandprofile
diff --git a/man/vgsplit.8.in b/man/vgsplit.8.in
index 546d02f..5939ed5 100644
--- a/man/vgsplit.8.in
+++ b/man/vgsplit.8.in
@@ -1,6 +1,6 @@
 .TH VGSPLIT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
-vgsplit \- split a volume group into two
+vgsplit \(em split a volume group into two
 .SH SYNOPSIS
 .B vgsplit
 .RB [ \-\-alloc
@@ -15,9 +15,9 @@ vgsplit \- split a volume group into two
 .RB [ \-h | \-\-help ]
 .RB [ \-l | \-\-maxlogicalvolumes
 .IR MaxLogicalVolumes ]
-.RB [ -M | \-\-metadatatype
+.RB [ \-M | \-\-metadatatype
 .IR type ]
-.RB [ -p | \-\-maxphysicalvolumes
+.RB [ \-p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
 .RB [ \-\- [ vg ] metadatacopies
 .IR NumberOfCopies | unmanaged | all ]


