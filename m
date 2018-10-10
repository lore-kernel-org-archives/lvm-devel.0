From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 10 Oct 2018 07:28:48 -0400
Subject: master - build: make generate
Message-ID: <201810101128.w9ABSmAf031685@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e12a332923bb81cc293b64821226e8c2632742c
Commit:        6e12a332923bb81cc293b64821226e8c2632742c
Parent:        5c36ad06a12e25302f6daf7f3504db82845195a8
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 10 08:31:55 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 10 11:25:50 2018 +0200

build: make generate

---
 man/lvchange.8_pregen  |   53 +-
 man/lvconvert.8_pregen |  133 ++-
 man/lvcreate.8_pregen  | 3486 +++++++++++++++++++++++++++++++++++++++++++++++-
 man/lvscan.8_pregen    |   35 +-
 man/pvmove.8_pregen    |    7 +-
 man/pvscan.8_pregen    |   11 +-
 man/vgchange.8_pregen  |   23 +-
 man/vgscan.8_pregen    |   10 -
 8 files changed, 3659 insertions(+), 99 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 03e0b1c..05da60f 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -45,6 +45,10 @@ lvchange - Change the attributes of logical volume(s)
 .ad b
 .br
 .ad l
+    \fB--compression\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
     \fB--config\fP \fIString\fP
 .ad b
 .br
@@ -57,6 +61,10 @@ lvchange - Change the attributes of logical volume(s)
 .ad b
 .br
 .ad l
+    \fB--deduplication\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
     \fB--deltag\fP \fITag\fP
 .ad b
 .br
@@ -165,6 +173,10 @@ lvchange - Change the attributes of logical volume(s)
 .ad b
 .br
 .ad l
+    \fB--readonly\fP
+.ad b
+.br
+.ad l
     \fB--rebuild\fP \fIPV\fP
 .ad b
 .br
@@ -272,6 +284,14 @@ required, after which the others are optional.
 .ad b
 .br
 .ad l
+     \fB--compression\fP \fBy\fP|\fBn\fP,
+.ad b
+.br
+.ad l
+     \fB--deduplication\fP \fBy\fP|\fBn\fP,
+.ad b
+.br
+.ad l
      \fB--detachprofile\fP,
 .ad b
 .br
@@ -411,6 +431,10 @@ Activate or deactivate an LV.
 [    \fB--sysinit\fP ]
 .ad b
 .br
+.ad l
+[    \fB--readonly\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -703,6 +727,13 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
+\fB--compression\fP \fBy\fP|\fBn\fP
+.br
+Controls whether compression is enabled or disable for VDO volume.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB--config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
@@ -729,6 +760,13 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--deduplication\fP \fBy\fP|\fBn\fP
+.br
+Controls whether deduplication is enabled or disable for VDO volume.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB--deltag\fP \fITag\fP
 .br
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
@@ -940,6 +978,20 @@ a suitable value automatically.
 .ad b
 .HP
 .ad l
+\fB--readonly\fP
+.br
+Run the command in a special read-only mode which will read on-disk
+metadata without needing to take any locks. This can be used to peek
+inside metadata used by a virtual machine image while the virtual
+machine is running.
+It can also be used to peek inside the metadata of clustered VGs
+when clustered locking is not configured or running. No attempt
+will be made to communicate with the device-mapper kernel driver, so
+this option is unable to report whether or not LVs are
+actually in use.
+.ad b
+.HP
+.ad l
 \fB--rebuild\fP \fIPV\fP
 .br
 Selects a PV to rebuild in a raid LV. Multiple PVs can be rebuilt by
@@ -1027,7 +1079,6 @@ available. As such, some functionality needs to be disabled and this option
 acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
-When used in conjunction with lvmetad enabled and running,
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
 .ad b
 .HP
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index c9df4da..635967f 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -51,6 +51,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
+    \fB--compression\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
     \fB--config\fP \fIString\fP
 .ad b
 .br
@@ -59,6 +63,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
+    \fB--deduplication\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
 .br
@@ -227,6 +235,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
+    \fB--vdopool\fP \fILV\fP
+.ad b
+.br
+.ad l
  \fB-v\fP|\fB--verbose\fP
 .ad b
 .br
@@ -235,6 +247,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
+ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+.ad b
+.br
+.ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
 .br
@@ -479,7 +495,7 @@ Split images from a raid1 or mirror LV and use them to create a new LV.
 .RE
 -
 
-Split images from a raid1 LV and track changes to origin.
+Split images from a raid1 LV and track changes to origin for later merge.
 .br
 .P
 \fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB--trackchanges\fP \fILV\fP\fI_cache_raid1\fP
@@ -722,6 +738,33 @@ Convert LV to type cache-pool.
 .RE
 -
 
+Convert LV to type vdopool.
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBvdo-pool\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+.br
+.RS 4
+.ad l
+[ \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP ]
+.ad b
+.br
+.ad l
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--compression\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Separate and keep the cache pool from a cache LV.
 .br
 .P
@@ -942,12 +985,7 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP
-.br
-If the operation requires polling, this option causes the command to
-return before the operation is complete, and polling is done in the
-background.
-.ad b
+\fB-b\fP|\fB--background\fP.ad b
 .HP
 .ad l
 \fB-H\fP|\fB--cache\fP
@@ -1027,6 +1065,13 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
+\fB--compression\fP \fBy\fP|\fBn\fP
+.br
+Controls whether compression is enabled or disable for VDO volume.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB--config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
@@ -1043,6 +1088,13 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--deduplication\fP \fBy\fP|\fBn\fP
+.br
+Controls whether deduplication is enabled or disable for VDO volume.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
@@ -1295,6 +1347,8 @@ Before the separation, the cache is flushed. Also see --uncache.
 Splits the specified number of images from a raid1 or mirror LV
 and uses them to create a new LV. If --trackchanges is also specified,
 changes to the raid1 LV are tracked while the split LV remains detached.
+If --name is specified, then the images are permanently split from the
+original LV and changes are not tracked.
 .ad b
 .HP
 .ad l
@@ -1368,10 +1422,12 @@ The name of a thin pool LV.
 .br
 Can be used with --splitmirrors on a raid1 LV. This causes
 changes to the original raid1 LV to be tracked while the split images
-remain detached. This allows the read-only detached image(s) to be
-merged efficiently back into the raid1 LV later. Only the regions with
-changed data are resynchronized during merge. (This option only applies
-when using the raid1 LV type.)
+remain detached. This is a temporary state that allows the read-only
+detached image to be merged efficiently back into the raid1 LV later.
+Only the regions with changed data are resynchronized during merge.
+While a raid1 LV is tracking changes, operations on it are limited to
+merging the split image (see --mergemirrors) or permanently splitting
+the image (see --splitmirrors with --name.
 .ad b
 .HP
 .ad l
@@ -1404,6 +1460,13 @@ or a profile.
 .ad b
 .HP
 .ad l
+\fB--vdopool\fP \fILV\fP
+.br
+The name of a VDO pool LV.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
@@ -1417,6 +1480,23 @@ Display version information.
 .ad b
 .HP
 .ad l
+\fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
+.br
+The virtual size of a new thin LV.
+See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
+Using virtual size (-V) and actual size (-L) together creates
+a sparse LV.
+lvm.conf global/sparse_segtype_default determines the
+default segment type used to create a sparse LV.
+Anything written to a sparse LV will be returned when reading from it.
+Reading from other areas of the LV will return blocks of zeros.
+When using a snapshot to create a sparse LV, a hidden virtual device
+is created using the zero target, and the LV has the suffix _vorigin.
+Snapshots are less efficient than thin provisioning when creating
+large sparse LVs (GiB).
+.ad b
+.HP
+.ad l
 \fB-y\fP|\fB--yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
@@ -1647,6 +1727,37 @@ Convert LV to type cache (infers --type cache).
 .br
 -
 
+Convert LV to type vdopool.
+.br
+.P
+\fBlvconvert\fP \fB--vdopool\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+.br
+.RS 4
+.ad l
+[ \fB-n\fP|\fB--name\fP \fILV\fP\fI_new\fP ]
+.ad b
+.br
+.ad l
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--type\fP \fBvdo-pool\fP ]
+.ad b
+.br
+.ad l
+[    \fB--compression\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Separate and delete the cache pool from a cache LV.
 .br
 .P
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index b6483b5..7a2adb1 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -59,6 +59,10 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
+    \fB--compression\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
     \fB--config\fP \fIString\fP
 .ad b
 .br
@@ -71,6 +75,10 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
+    \fB--deduplication\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
 .br
@@ -227,6 +235,14 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
+    \fB--vdo\fP
+.ad b
+.br
+.ad l
+    \fB--vdopool\fP \fILV\fP
+.ad b
+.br
+.ad l
  \fB-v\fP|\fB--verbose\fP
 .ad b
 .br
@@ -286,6 +302,132 @@ options, even though it is typically used. When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.
 .SH USAGE
+Create an LV that returns VDO when used.
+.br
+.P
+\fBlvcreate\fP \fB--type\fP \fBvdo\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+.br
+.RS 4
+.ad l
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+.ad b
+.br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--vdo\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
+.ad l
+[    \fB--compression\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
 Create a linear LV.
 .br
 .P
@@ -297,9 +439,93 @@ Create a linear LV.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBlinear\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -322,6 +548,90 @@ Create a striped LV (infers --type striped).
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -345,6 +655,54 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
@@ -356,6 +714,42 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 [    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -391,6 +785,54 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
@@ -398,6 +840,42 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 [    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -428,6 +906,54 @@ Create a raid10 LV.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
@@ -435,6 +961,42 @@ Create a raid10 LV.
 [    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -466,9 +1028,93 @@ Create a COW snapshot LV of an origin LV.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBsnapshot\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -492,6 +1138,54 @@ Create a thin pool.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -519,6 +1213,42 @@ Create a thin pool.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -546,6 +1276,54 @@ Create a cache pool.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -569,6 +1347,42 @@ Create a cache pool.
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -588,6 +1402,54 @@ Create a thin LV in a thin pool (infers --type thin).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -599,6 +1461,42 @@ Create a thin LV in a thin pool (infers --type thin).
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -613,6 +1511,54 @@ Create a thin LV that is a snapshot of an existing thin LV
 .br
 .RS 4
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -624,6 +1570,42 @@ Create a thin LV that is a snapshot of an existing thin LV
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -644,6 +1626,54 @@ Create a thin LV that is a snapshot of an external origin LV.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -659,6 +1689,42 @@ Create a thin LV that is a snapshot of an external origin LV.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -688,6 +1754,54 @@ where the new thin pool is named by the --thinpool arg.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -711,6 +1825,42 @@ where the new thin pool is named by the --thinpool arg.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -745,94 +1895,83 @@ by the --cachepool arg.
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachepolicy\fP \fIString\fP ]
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachesettings\fP \fIString\fP ]
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
 .ad b
 .br
 .ad l
-[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
-
-Common options for command:
-.
-.RS 4
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
 .ad l
-[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
 .ad l
-[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
 .ad b
 .br
 .ad l
-[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+[    \fB--cachepolicy\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+[    \fB--cachesettings\fP \fIString\fP ]
 .ad b
 .br
 .ad l
-[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 .ad l
@@ -870,6 +2009,18 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
+Common options for command:
+.
+.RS 4
 .RE
 
 Common options for lvm:
@@ -1064,6 +2215,13 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
+\fB--compression\fP \fBy\fP|\fBn\fP
+.br
+Controls whether compression is enabled or disable for VDO volume.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB--config\fP \fIString\fP
 .br
 Config settings for the command. These override lvm.conf settings.
@@ -1090,6 +2248,13 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--deduplication\fP \fBy\fP|\fBn\fP
+.br
+Controls whether deduplication is enabled or disable for VDO volume.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
@@ -1475,6 +2640,21 @@ Use inferred types with care because it can lead to unexpected results.
 .ad b
 .HP
 .ad l
+\fB--vdo\fP
+.br
+Specifies the command is handling VDO LV.
+See --type vdo.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
+\fB--vdopool\fP \fILV\fP
+.br
+The name of a VDO pool LV.
+See \fBlvmvdo\fP(7) for more information about VDO usage.
+.ad b
+.HP
+.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
@@ -1597,9 +2777,237 @@ Create an LV that returns errors when used.
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
+Create an VDO LV with VDO pool.
+.br
+.P
+\fBlvcreate\fP \fB--vdo\fP \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+.br
+.RS 4
+.ad l
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+.ad b
+.br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
+.ad l
+[    \fB--compression\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
+Create an VDO LV using existing VDO pool.
+.br
+.P
+\fBlvcreate\fP \fB--vdopool\fP \fILV\fP \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT] \fIVG\fP
+.br
+.RS 4
+.ad l
+[    \fB--vdo\fP ]
+.ad b
+.br
+.ad l
+[    \fB--type\fP \fBvdo\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 -
 
 Create an LV that returns zeros when read.
@@ -1612,6 +3020,90 @@ Create an LV that returns zeros when read.
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1627,6 +3119,90 @@ Create a linear LV.
 [ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
 .ad b
 .br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1653,6 +3229,90 @@ Create a striped LV (also see lvcreate --stripes).
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1688,9 +3348,93 @@ Create a mirror LV (also see --type raid1).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1727,6 +3471,90 @@ Create a COW snapshot LV of an origin LV
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1758,6 +3586,90 @@ Create a sparse COW snapshot LV of a virtual origin LV
 [ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1784,9 +3696,93 @@ Create a sparse COW snapshot LV of a virtual origin LV.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBsnapshot\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1810,6 +3806,54 @@ Create a thin pool (infers --type thin-pool).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -1837,6 +3881,42 @@ Create a thin pool (infers --type thin-pool).
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1866,6 +3946,54 @@ Create a thin pool named by the --thinpool arg
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -1893,6 +4021,42 @@ Create a thin pool named by the --thinpool arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1925,6 +4089,54 @@ Create a cache pool named by the --cachepool arg
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -1948,6 +4160,42 @@ Create a cache pool named by the --cachepool arg
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1974,6 +4222,54 @@ Create a thin LV in a thin pool.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
@@ -1989,6 +4285,42 @@ Create a thin LV in a thin pool.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2007,6 +4339,54 @@ Create a thin LV in a thin pool named in the first arg
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
@@ -2014,6 +4394,42 @@ Create a thin LV in a thin pool named in the first arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2034,6 +4450,54 @@ naming pool.)
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -2045,6 +4509,42 @@ naming pool.)
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2061,6 +4561,54 @@ Create a thin LV that is a snapshot of an existing thin LV.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP ]
 .ad b
 .br
@@ -2068,6 +4616,42 @@ Create a thin LV that is a snapshot of an existing thin LV.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2082,6 +4666,54 @@ Create a thin LV that is a snapshot of an existing thin LV
 .br
 .RS 4
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -2093,6 +4725,42 @@ Create a thin LV that is a snapshot of an existing thin LV
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2107,6 +4775,54 @@ Create a thin LV that is a snapshot of an external origin LV
 .br
 .RS 4
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [    \fB--type\fP \fBthin\fP ]
 .ad b
 .br
@@ -2118,6 +4834,42 @@ Create a thin LV that is a snapshot of an external origin LV
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2149,6 +4901,54 @@ where the new thin pool is named by the --thinpool arg
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2172,6 +4972,42 @@ where the new thin pool is named by the --thinpool arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2206,6 +5042,54 @@ where the new thin pool is named by the --thinpool arg
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2229,6 +5113,42 @@ where the new thin pool is named by the --thinpool arg
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2265,6 +5185,54 @@ arg is a VG name.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2288,6 +5256,42 @@ arg is a VG name.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2320,6 +5324,54 @@ arg is a VG name (variant, infers --type thin).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2343,6 +5395,42 @@ arg is a VG name (variant, infers --type thin).
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2380,6 +5468,54 @@ config setting sparse_segtype_default.
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2407,6 +5543,42 @@ config setting sparse_segtype_default.
 [    \fB--errorwhenfull\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2438,6 +5610,54 @@ by the --cachepool arg (variant, infers --type cache).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2465,6 +5685,42 @@ by the --cachepool arg (variant, infers --type cache).
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2496,6 +5752,54 @@ in the first arg (variant, also use --cachepool).
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2527,6 +5831,42 @@ in the first arg (variant, also use --cachepool).
 [    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2562,6 +5902,54 @@ to type cache after creating a new cache pool LV to use
 .ad b
 .br
 .ad l
+[ \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+.ad b
+.br
+.ad l
+[ \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-K\fP|\fB--ignoreactivationskip\fP ]
+.ad b
+.br
+.ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-n\fP|\fB--name\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[ \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP ]
+.ad b
+.br
+.ad l
+[ \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
 [ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
 .ad b
 .br
@@ -2593,6 +5981,42 @@ to type cache after creating a new cache pool LV to use
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
+.ad l
+[    \fB--addtag\fP \fITag\fP ]
+.ad b
+.br
+.ad l
+[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+.ad b
+.br
+.ad l
+[    \fB--ignoremonitoring\fP ]
+.ad b
+.br
+.ad l
+[    \fB--metadataprofile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--minor\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--monitor\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--nosync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
+.ad l
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 489286e..2d4fd6b 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -3,12 +3,10 @@
 lvscan - List all logical volumes in all volume groups
 .
 .SH SYNOPSIS
-\fBlvscan\fP \fIoption_args\fP
+\fBlvscan\fP
 .br
     [ \fIoption_args\fP ]
 .br
-    [ \fIposition_args\fP ]
-.br
 .SH DESCRIPTION
 lvscan scans all VGs or all supported LVM block devices in the system for
 LVs. The output consists of one line for each LV indicating whether or not
@@ -23,23 +21,6 @@ comprehensive information about LVs.
 [ \fB-a\fP|\fB--all\fP ]
 .ad b
 .br
-[ COMMON_OPTIONS ]
-.RE
-.br
-
-\fBlvscan\fP \fB--cache\fP
-.br
-.RS 4
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fILV\fP ... ]
-.RE
-
-Common options for command:
-.
-.RS 4
 .ad l
 [ \fB-b\fP|\fB--blockdevice\fP ]
 .ad b
@@ -55,7 +36,10 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
+.br
+[ COMMON_OPTIONS ]
 .RE
+.br
 
 Common options for lvm:
 .
@@ -133,12 +117,6 @@ No longer used.
 .ad b
 .HP
 .ad l
-\fB--cache\fP
-.br
-Scan the devices used by an LV and send the metadata to lvmetad.
-.ad b
-.HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
@@ -271,11 +249,6 @@ answer yes. Use with extreme caution.
 .ad b
 .SH VARIABLES
 .HP
-\fILV\fP
-.br
-Logical Volume name.  See \fBlvm\fP(8) for valid names.
-An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index e553722..16bbe94 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -195,12 +195,7 @@ Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP
-.br
-If the operation requires polling, this option causes the command to
-return before the operation is complete, and polling is done in the
-background.
-.ad b
+\fB-b\fP|\fB--background\fP.ad b
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 3ce59b5..2326ec5 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -129,7 +129,7 @@ Display PV information.
 .RE
 .br
 
-Populate the lvmetad cache by scanning PVs.
+Autoactivate a VG when all PVs are online.
 .br
 .P
 \fBpvscan\fP \fB--cache\fP
@@ -239,17 +239,12 @@ Auto-activate LVs in a VG when the PVs scanned have completed the VG.
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP
-.br
-If the operation requires polling, this option causes the command to
-return before the operation is complete, and polling is done in the
-background.
-.ad b
+\fB-b\fP|\fB--background\fP.ad b
 .HP
 .ad l
 \fB--cache\fP
 .br
-Scan one or more devices and send the metadata to lvmetad.
+Scan one or more devices and record that they are online.
 .ad b
 .HP
 .ad l
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 94dbd88..e1fcb81 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -143,6 +143,10 @@ vgchange - Change volume group attributes
 .ad b
 .br
 .ad l
+    \fB--readonly\fP
+.ad b
+.br
+.ad l
     \fB--refresh\fP
 .ad b
 .br
@@ -417,6 +421,10 @@ Activate or deactivate LVs.
 .ad b
 .br
 .ad l
+[    \fB--readonly\fP ]
+.ad b
+.br
+.ad l
 [    \fB--ignorelockingfailure\fP ]
 .ad b
 .br
@@ -920,6 +928,20 @@ Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
+\fB--readonly\fP
+.br
+Run the command in a special read-only mode which will read on-disk
+metadata without needing to take any locks. This can be used to peek
+inside metadata used by a virtual machine image while the virtual
+machine is running.
+It can also be used to peek inside the metadata of clustered VGs
+when clustered locking is not configured or running. No attempt
+will be made to communicate with the device-mapper kernel driver, so
+this option is unable to report whether or not LVs are
+actually in use.
+.ad b
+.HP
+.ad l
 \fB--refresh\fP
 .br
 If the LV is active, reload its metadata.
@@ -968,7 +990,6 @@ available. As such, some functionality needs to be disabled and this option
 acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
-When used in conjunction with lvmetad enabled and running,
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
 .ad b
 .HP
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index fe9f201..7fe3713 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -14,10 +14,6 @@ vgscan scans all supported LVM block devices in the system for VGs.
 .br
 .RS 4
 .ad l
-[    \fB--cache\fP ]
-.ad b
-.br
-.ad l
 [    \fB--ignorelockingfailure\fP ]
 .ad b
 .br
@@ -99,12 +95,6 @@ Common options for lvm:
 .SH OPTIONS
 .HP
 .ad l
-\fB--cache\fP
-.br
-Scan all devices and send the metadata to lvmetad.
-.ad b
-.HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.


