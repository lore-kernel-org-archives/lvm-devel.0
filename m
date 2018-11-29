From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:13:04 -0500
Subject: master - make: generate man update
Message-ID: <201811292213.wATMD4KS016643@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3a22cdc31c38939efd51dd9a3a82e034adc21c5
Commit:        e3a22cdc31c38939efd51dd9a3a82e034adc21c5
Parent:        fc482406ec4e0607a9d7335ac927c64b361cad1c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 23:08:25 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:08 2018 +0100

make: generate man update

---
 man/lvchange.8_pregen       |   12 +---
 man/lvconvert.8_pregen      |   36 ++++++++++---
 man/lvcreate.8_pregen       |    3 -
 man/lvdisplay.8_pregen      |   11 +---
 man/lvextend.8_pregen       |    2 -
 man/lvm-fullreport.8_pregen |   11 +---
 man/lvm-lvpoll.8_pregen     |    2 -
 man/lvmconfig.8_pregen      |    2 -
 man/lvmdiskscan.8_pregen    |   11 +---
 man/lvreduce.8_pregen       |    2 -
 man/lvremove.8_pregen       |    2 -
 man/lvrename.8_pregen       |    2 -
 man/lvresize.8_pregen       |    2 -
 man/lvs.8_pregen            |   11 +---
 man/lvscan.8_pregen         |   11 +---
 man/pvchange.8_pregen       |    2 -
 man/pvck.8_pregen           |    2 -
 man/pvcreate.8_pregen       |  120 +++++++++++++++++++++++++++++++-----------
 man/pvdisplay.8_pregen      |   11 +---
 man/pvmove.8_pregen         |    9 ++-
 man/pvremove.8_pregen       |    2 -
 man/pvresize.8_pregen       |    2 -
 man/pvs.8_pregen            |   11 +---
 man/pvscan.8_pregen         |  111 +++++++++++++---------------------------
 man/vgcfgbackup.8_pregen    |   11 +---
 man/vgcfgrestore.8_pregen   |    2 -
 man/vgchange.8_pregen       |   15 ++----
 man/vgck.8_pregen           |    2 -
 man/vgconvert.8_pregen      |   21 ++++----
 man/vgcreate.8_pregen       |   24 +++++----
 man/vgdisplay.8_pregen      |   11 +---
 man/vgexport.8_pregen       |    2 -
 man/vgextend.8_pregen       |   17 +++----
 man/vgimport.8_pregen       |    2 -
 man/vgimportclone.8_pregen  |    2 -
 man/vgmerge.8_pregen        |    2 -
 man/vgmknodes.8_pregen      |    2 -
 man/vgreduce.8_pregen       |    2 -
 man/vgremove.8_pregen       |    2 -
 man/vgrename.8_pregen       |    2 -
 man/vgs.8_pregen            |   11 +---
 man/vgscan.8_pregen         |    2 -
 man/vgsplit.8_pregen        |    2 -
 43 files changed, 223 insertions(+), 301 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 05da60f..110dd91 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -631,7 +631,6 @@ if the list is set but empty, no LVs match.
 Autoactivation should be used during system boot to make it possible
 to select which LVs should be automatically activated by the system.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-See \fBclvmd\fP(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
 .ad b
 .HP
 .ad l
@@ -983,12 +982,9 @@ a suitable value automatically.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -1245,11 +1241,9 @@ Change LV permission to read-only:
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 635967f..cefdb0d 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -567,7 +567,7 @@ Convert LV to a thin LV, using the original LV as an external origin.
 .br
 -
 
-Convert LV to type cache.
+Attach a cache to an LV, converts the LV to type cache.
 .br
 .P
 \fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
@@ -626,6 +626,21 @@ Convert LV to type cache.
 .br
 -
 
+Attach a writecache to an LV, converts the LV to type writecache.
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_raid\fP
+.br
+.RS 4
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Convert LV to type thin-pool.
 .br
 .P
@@ -765,10 +780,10 @@ Convert LV to type vdopool.
 .br
 -
 
-Separate and keep the cache pool from a cache LV.
+Detach a cache from an LV.
 .br
 .P
-\fBlvconvert\fP \fB--splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool\fP
+\fBlvconvert\fP \fB--splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool_writecache\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -985,7 +1000,12 @@ See \fBlvm\fP(8) for more information about allocation.
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP.ad b
+\fB-b\fP|\fB--background\fP
+.br
+If the operation requires polling, this option causes the command to
+return before the operation is complete, and polling is done in the
+background.
+.ad b
 .HP
 .ad l
 \fB-H\fP|\fB--cache\fP
@@ -1668,7 +1688,7 @@ Convert LV to a thin LV, using the original LV as an external origin
 .br
 -
 
-Convert LV to type cache (infers --type cache).
+Attach a cache to an LV (infers --type cache).
 .br
 .P
 \fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
@@ -1758,10 +1778,10 @@ Convert LV to type vdopool.
 .br
 -
 
-Separate and delete the cache pool from a cache LV.
+Detach and delete a cache from an LV.
 .br
 .P
-\fBlvconvert\fP \fB--uncache\fP \fILV\fP\fI_thinpool_cache\fP
+\fBlvconvert\fP \fB--uncache\fP \fILV\fP\fI_thinpool_cache_writecache\fP
 .br
 .RS 4
 [ COMMON_OPTIONS ]
@@ -2019,11 +2039,9 @@ Detach and remove the cache pool from a cache LV.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 7a2adb1..2a5e05d 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -2099,7 +2099,6 @@ If autoactivation \fBay\fP is used, the LV is only activated
 if it matches an item in lvm.conf activation/auto_activation_volume_list.
 \fBay\fP implies --zero n and --wipesignatures n.
 See \fBlvmlockd\fP(8) for more information about activation options for shared VGs.
-See \fBclvmd\fP(8) for more information about activation options for clustered VGs.
 .ad b
 .HP
 .ad l
@@ -6177,11 +6176,9 @@ then combining the new origin LV with an existing cache pool.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 9a8962b..4ba8dff 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -368,12 +368,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -563,11 +560,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index b29f508..6466172 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -728,11 +728,9 @@ Extend an LV by 16MiB using specific physical extents.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 111b8ef..1170dc7 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -339,12 +339,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -538,11 +535,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 1f4c129..d491e77 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -340,11 +340,9 @@ Continue thin snapshot merge.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 0db2dd7..7f8e6c6 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -532,11 +532,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 8eb57bf..91a4567 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -173,12 +173,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -287,11 +284,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 7acc042..450ae80 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -391,11 +391,9 @@ Reduce the size of an LV by 3 logical extents:
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index c835672..7798e13 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -385,11 +385,9 @@ Remove all LVs the specified VG.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 8d2f9b3..811f5a0 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -322,11 +322,9 @@ An alternate syntax to rename "lvold" to "lvnew":
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 13246f5..e3a124a 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -654,11 +654,9 @@ Extend an LV by 16MB using specific physical extents:
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index fecca99..cbc0ed8 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -354,12 +354,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -644,11 +641,9 @@ s(k)ip activation: this volume is flagged to be skipped during activation.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 2d4fd6b..af11427 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -198,12 +198,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -323,11 +320,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 8c9288d..c21ce70 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -439,11 +439,9 @@ disk errors, or because it will be removed after freeing it).
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 499f62c..5277418 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -284,11 +284,9 @@ parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 2b4fb1c..aa893f4 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -8,27 +8,84 @@ pvcreate - Initialize physical volume(s) for use by LVM
     [ \fIoption_args\fP ]
 .br
 .SH DESCRIPTION
-pvcreate initializes a PV so that it is recognized as belonging to LVM,
-and allows the PV to be used in a VG. A PV can be a disk partition, whole
-disk, meta device, or loopback file.
-
-For DOS disk partitions, the partition id should be set to 0x8e using
-.BR fdisk (8),
-.BR cfdisk (8),
-or a equivalent. For GUID Partition Table (GPT), the id is
-E6D6D379-F507-44C2-A23C-238F2A3DF928. For
-whole disk devices only
-the partition table must be erased, which will effectively destroy all
-data on that disk. This can be done by zeroing the first sector with:
-
-.BI "dd if=/dev/zero of=" PhysicalVolume " bs=512 count=1"
+pvcreate initializes a Physical Volume (PV) on a device so the device is
+recognized as belonging to LVM.  This allows the PV to be used in a Volume
+Group (VG).  An LVM disk label is written to the device, and LVM metadata
+areas are initialized.  A PV can be placed on a whole device or partition.
 
 Use \fBvgcreate\fP(8) to create a new VG on the PV, or \fBvgextend\fP(8)
-to add the PV to existing VG.
+to add the PV to an existing VG.  Use \fBpvremove\fP(8) to remove the LVM
+disk label from the device.
 
 The force option will create a PV without confirmation.  Repeating the
 force option (\fB-ff\fP) will forcibly create a PV, overriding checks that
 normally prevent it, e.g. if the PV is already in a VG.
+
+.B Metadata location, size, and alignment
+
+The LVM disk label begins 512 bytes from the start of the device, and is
+512 bytes in size.
+
+The LVM metadata area begins at an offset (from the start of the device)
+equal to the page size of the machine creating the PV (often 4 KiB.) The
+metadata area contains a 512 byte header and a multi-KiB circular buffer
+that holds text copies of the VG metadata.
+
+With default settings, the first physical extent (PE), which contains LV
+data, is 1 MiB from the start of the device.  This location is controlled
+by \fBdefault_data_alignment\fP in lvm.conf, which is set to 1 (MiB) by
+default.  The pe_start will be a multiple of this many MiB.  This location
+can be checked with:
+.br
+.B pvs -o pe_start
+.I PV
+
+The size of the LVM metadata area is the space between the the start of
+the metadata area and the first PE.  When metadata begins at 4 KiB and the
+first PE is at 1024 KiB, the metadata area size is 1020 KiB.  This can be
+checked with:
+.br
+.B pvs -o mda_size
+.I PV
+
+The mda_size cannot be increased after pvcreate, so if larger metadata is
+needed, it must be set during pvcreate.  Two copies of the VG metadata
+must always fit within the metadata area, so the maximum VG metadata size
+is around half the mda_size.  This can be checked with:
+.br
+.B vgs -o mda_free
+.I VG
+
+A larger metadata area can be set with --metadatasize.  The resulting
+mda_size may be larger than specified due to default_data_alignment
+placing pe_start on a MiB boundary, and the fact that the metadata area
+extends to the first PE.  With metadata starting at 4 KiB and
+default_data_alignment 1 (MiB), setting --metadatasize 2048k results in
+pe_start of 3 MiB and mda_size of 3068 KiB.  Alternatively, --metadatasize
+2044k results in pe_start at 2 MiB and mda_size of 2044 KiB.
+
+The alignment of pe_start described above may be automatically overriden
+based on md device properties or device i/o properties reported in sysfs.
+These automatic adjustments can be enabled/disabled using lvm.conf
+settings md_chunk_alignment and data_alignment_offset_detection.
+
+To use a different pe_start alignment, use the --dataalignment option.
+The --metadatasize option would also typically be used in this case
+because the metadata area size also determines the location of pe_start.
+When using these two options together, pe_start is calculated as:
+metadata area start (page size), plus the specified --metadatasize,
+rounded up to the next multiple of --dataalignment.
+With metadata starting at 4 KiB, --metadatasize 2048k, and --dataalignment 128k,
+pe_start is 2176 KiB and mda_size is 2172 KiB.
+The pe_start of 2176 KiB is the nearest even multiple of 128 KiB that
+provides at least 2048 KiB of metadata space.
+Always check the resulting alignment and metadata size when using
+these options.
+
+To shift an aligned pe_start value, use the --dataaligmentoffset option.
+The pe_start alignment is calculated as described above, and then the
+value specified with --dataaligmentoffset is added to produce the final
+pe_start value.
 .SH USAGE
 \fBpvcreate\fP \fIPV\fP ...
 .br
@@ -161,14 +218,16 @@ Common options for lvm:
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
-Create a separate bootloader area of specified size besides PV's data
-area. The bootloader area is an area of reserved space on the PV from
-which LVM will not allocate any extents and it's kept untouched. This is
-primarily aimed for use with bootloaders to embed their own data or metadata.
+Reserve space for the bootloader between the LVM metadata area and the first PE.
+The bootloader area is reserved for bootloaders to embed their own data or
+metadata; LVM will not use it.
+The bootloader area begins where the first PE would otherwise be located.
+The first PE is moved out by the size of the bootloader area, and then moved
+out further if necessary to match the data alignment.
 The start of the bootloader area is always aligned, see also --dataalignment
-and --dataalignmentoffset. The bootloader area size may eventually
-end up increased due to the alignment, but it's never less than the
-size that is requested. To see the bootloader area start and size of
+and --dataalignmentoffset. The bootloader area may be larger than requested
+due to the alignment, but it's never less than the requested size.
+To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 .ad b
 .HP
@@ -191,17 +250,17 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
-Align the start of the data to a multiple of this number.
-Also specify an appropriate Physical Extent size when creating a VG.
-To see the location of the first Physical Extent of an existing PV,
-use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
-See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
+Align the start of a PV data area with a multiple of this number.
+To see the location of the first Physical Extent (PE) of an existing PV,
+use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
+see --dataalignmentoffset.
+Also specify an appropriate PE size when creating a VG.
 .ad b
 .HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-Shift the start of the data area by this additional offset.
+Shift the start of the PV data area by this additional offset.
 .ad b
 .HP
 .ad l
@@ -303,8 +362,7 @@ on the command.
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
-When 1, one copy of the VG metadata is stored at the front of the PV
-(starting in the 5th sector).
+When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
@@ -496,11 +554,9 @@ boundary) manually account for this when initializing for use by LVM.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 9dbcac3..ef225cf 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -353,12 +353,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -550,11 +547,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 16bbe94..e8413cb 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -195,7 +195,12 @@ Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP.ad b
+\fB-b\fP|\fB--background\fP
+.br
+If the operation requires polling, this option causes the command to
+return before the operation is complete, and polling is done in the
+background.
+.ad b
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -505,11 +510,9 @@ extents can also be picked out and moved.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 3d83478..89f8c0d 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -295,11 +295,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 5a5c975..53ed2fd 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -302,11 +302,9 @@ appropriate for the intended new partition size).
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 53c259c..1902f29 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -341,12 +341,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -568,11 +565,9 @@ e(x)ported
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 2326ec5..ed5ba92 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -10,73 +10,50 @@ pvscan - List all physical volumes
     [ \fIposition_args\fP ]
 .br
 .SH DESCRIPTION
-pvscan scans all supported LVM block devices in the system for PVs.
+When called without the --cache option, pvscan lists PVs on the system,
+like
+.BR pvs (8)
+or
+.BR pvdisplay (8).
+
+When the --cache and -aay options are used, pvscan records which PVs are
+available on the system, and activates LVs in completed VGs.  A VG is
+complete when pvscan sees that the final PV in the VG has appeared.  This
+is used by event-based system startup (systemd, udev) to activate LVs.
+
+The four main variations of this are:
+
+.B pvscan --cache
+.IR device
 
-\fBScanning with lvmetad\fP
+If device is present, lvm adds a record that the PV on device is online.
+If device is not present, lvm removes the online record for the PV.
+In most cases, the pvscan will only read the named devices.
 
-pvscan operates differently when used with the
-.BR lvmetad (8)
-daemon.
+.B pvscan --cache -aay
+.IR device ...
 
-Scanning disks is required to read LVM metadata and identify LVM PVs.
-Once read, lvmetad caches the metadata so that LVM commands can read it
-without repeatedly scanning disks.  This is helpful because scanning disks
-is time consuming, and frequent scanning may interfere with the normal
-work of the system and disks.
+This begins by performing the same steps as above.  Afterward, if the VG
+for the specified PV is complete, then pvscan will activate LVs in the VG
+(the same as vgchange -aay vgname would do.)
 
-When lvmetad is not used, LVM commands revert to scanning disks to read
-metadata.  Any LVM command that needs metadata will scan disks for it;
-running the pvscan command is not necessary for the sake of other LVM
-commands.
+.B pvscan --cache
 
-When lvmetad is used, LVM commands avoid scanning disks by reading
-metadata from lvmetad.  When new disks appear, they must be scanned so
-their metadata can be cached in lvmetad.  This is done by the command
-pvscan --cache, which scans disks and passes the metadata to lvmetad.
+This first clears all existing PV online records, then scans all devices
+on the system, adding PV online records for any PVs that are found.
 
-The pvscan --cache command is typically run automatically by system
-services when a new device appears.  Users do not generally need to run
-this command if the system and lvmetad are running properly.
+.B pvscan --cache -aay
+
+This begins by performing the same steps as pvscan --cache.  Afterward, it
+activates LVs in any complete VGs.
 
-Many scripts contain unnecessary pvscan (or vgscan) commands for
-historical reasons.  To avoid disrupting the system with extraneous disk
-scanning, an ordinary pvscan (without --cache) will simply read metadata
-from lvmetad like other LVM commands.  It does not do anything beyond
-displaying the current state of the cache.
-.IP \[bu] 2
-When given specific device name arguments, pvscan --cache will only
-read the named devices.
-.IP \[bu] 2
-LVM udev rules and systemd services are used to initiate automatic device
-scanning.
-.IP \[bu] 2
 To prevent devices from being scanned by pvscan --cache, add them
 to
 .BR lvm.conf (5)
 .B devices/global_filter.
-The devices/filter setting does not
-apply to system level scanning.
 For more information, see:
 .br
 .B lvmconfig --withcomments devices/global_filter
-.IP \[bu] 2
-If lvmetad is started or restarted after devices are visible, or
-if the global_filter has changed, then all devices must be rescanned
-for metadata with the command pvscan --cache.
-.IP \[bu] 2
-lvmetad does not cache older metadata formats, e.g. lvm1, and will
-be temporarily disabled if they are seen.
-.IP \[bu] 2
-To notify lvmetad about a device that is no longer present, the major and
-minor numbers must be given, not the path.
-.P
-\fBAutomatic activation\fP
-
-When event-driven system services detect a new LVM device, the first step
-is to automatically scan and cache the metadata from the device.  This is
-done by pvscan --cache.  A second step is to automatically activate LVs
-that are present on the new device.  This auto-activation is done by the
-same pvscan --cache command when the option --activate ay is included.
 
 Auto-activation of VGs or LVs can be enabled/disabled using:
 .br
@@ -87,21 +64,12 @@ For more information, see:
 .br
 .B lvmconfig --withcomments activation/auto_activation_volume_list
 
-When this setting is undefined, all LVs are auto-activated (when lvm is
-fully integrated with the event-driven system services.)
+To disable auto-activation, explicitly set this list to an empty list,
+i.e. auto_activation_volume_list = [ ].
+
+When this setting is undefined (e.g. commented), then all LVs are
+auto-activated.
 
-When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange --activate is needed.
-.IP \[bu] 2
-pvscan auto-activation can be only done in combination with --cache.
-.IP \[bu] 2
-Auto-activation is designated by the "a" argument in --activate ay.
-This is meant to distinguish system generated commands from explicit user
-commands, although it can be used in any activation command.  Whenever it
-is used, the auto_activation_volume_list is applied.
-.IP \[bu] 2
-Auto-activation is not yet supported for LVs that are part of partial or
-clustered volume groups.
 .SH USAGE
 Display PV information.
 .br
@@ -136,10 +104,6 @@ Autoactivate a VG when all PVs are online.
 .br
 .RS 4
 .ad l
-[ \fB-b\fP|\fB--background\fP ]
-.ad b
-.br
-.ad l
 [ \fB-a\fP|\fB--activate\fP \fBay\fP ]
 .ad b
 .br
@@ -239,9 +203,6 @@ Auto-activate LVs in a VG when the PVs scanned have completed the VG.
 .ad b
 .HP
 .ad l
-\fB-b\fP|\fB--background\fP.ad b
-.HP
-.ad l
 \fB--cache\fP
 .br
 Scan one or more devices and record that they are online.
@@ -486,11 +447,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index cd2521a..73a0868 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -215,12 +215,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -344,11 +341,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index b4e2183..71d2ada 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -434,11 +434,9 @@ missing PV. Repeat for all other missing PVs in the VG.  Then use
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index e1fcb81..10cf8a7 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -652,7 +652,6 @@ if the list is set but empty, no LVs match.
 Autoactivation should be used during system boot to make it possible
 to select which LVs should be automatically activated by the system.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-See \fBclvmd\fP(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
 .ad b
 .HP
 .ad l
@@ -913,8 +912,7 @@ on the command.
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
-When 1, one copy of the VG metadata is stored at the front of the PV
-(starting in the 5th sector).
+When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
@@ -933,12 +931,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -1159,11 +1154,9 @@ Change the maximum number of LVs for an inactive VG.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index b1418f3..4f2a866 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -282,11 +282,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index b2a6027..48cf5e5 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -111,14 +111,16 @@ Common options for lvm:
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
-Create a separate bootloader area of specified size besides PV's data
-area. The bootloader area is an area of reserved space on the PV from
-which LVM will not allocate any extents and it's kept untouched. This is
-primarily aimed for use with bootloaders to embed their own data or metadata.
+Reserve space for the bootloader between the LVM metadata area and the first PE.
+The bootloader area is reserved for bootloaders to embed their own data or
+metadata; LVM will not use it.
+The bootloader area begins where the first PE would otherwise be located.
+The first PE is moved out by the size of the bootloader area, and then moved
+out further if necessary to match the data alignment.
 The start of the bootloader area is always aligned, see also --dataalignment
-and --dataalignmentoffset. The bootloader area size may eventually
-end up increased due to the alignment, but it's never less than the
-size that is requested. To see the bootloader area start and size of
+and --dataalignmentoffset. The bootloader area may be larger than requested
+due to the alignment, but it's never less than the requested size.
+To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 .ad b
 .HP
@@ -221,8 +223,7 @@ on the command.
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
-When 1, one copy of the VG metadata is stored at the front of the PV
-(starting in the 5th sector).
+When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
@@ -357,11 +358,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index cc990cc..d8ebc2a 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -12,6 +12,12 @@ vgcreate creates a new VG on block devices. If the devices were not
 previously intialized as PVs with \fBpvcreate\fP(8), vgcreate will
 inititialize them, making them PVs. The pvcreate options for initializing
 devices are also available with vgcreate.
+
+When vgcreate uses an existing PV, that PV's existing values for metadata
+size, PE start, etc, are used, even if different values are specified in
+the vgcreate command.  To change these values, first use pvremove on the
+device.
+
 .SH USAGE
 \fBvgcreate\fP \fIVG\fP\fI_new\fP \fIPV\fP ...
 .br
@@ -226,17 +232,17 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
-Align the start of the data to a multiple of this number.
-Also specify an appropriate Physical Extent size when creating a VG.
-To see the location of the first Physical Extent of an existing PV,
-use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
-See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
+Align the start of a PV data area with a multiple of this number.
+To see the location of the first Physical Extent (PE) of an existing PV,
+use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
+see --dataalignmentoffset.
+Also specify an appropriate PE size when creating a VG.
 .ad b
 .HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-Shift the start of the data area by this additional offset.
+Shift the start of the PV data area by this additional offset.
 .ad b
 .HP
 .ad l
@@ -362,8 +368,7 @@ on the command.
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
-When 1, one copy of the VG metadata is stored at the front of the PV
-(starting in the 5th sector).
+When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
@@ -394,7 +399,6 @@ Create a shared VG using lvmlockd if LVM is compiled with lockd support.
 lvmlockd will select lock type sanlock or dlm depending on which lock
 manager is running. This allows multiple hosts to share a VG on shared
 devices. lvmlockd and a lock manager must be configured and running.
-(A shared VG using lvmlockd is different from a clustered VG using clvmd.)
 See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
@@ -561,11 +565,9 @@ Create a VG with two PVs, using the default physical extent size.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 7c8fb12..e65a53a 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -342,12 +342,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -533,11 +530,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index a87c871..5018efd 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -340,11 +340,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index a2aff35..d2b4f7e 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -162,17 +162,17 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
-Align the start of the data to a multiple of this number.
-Also specify an appropriate Physical Extent size when creating a VG.
-To see the location of the first Physical Extent of an existing PV,
-use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
-See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
+Align the start of a PV data area with a multiple of this number.
+To see the location of the first Physical Extent (PE) of an existing PV,
+use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
+see --dataalignmentoffset.
+Also specify an appropriate PE size when creating a VG.
 .ad b
 .HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-Shift the start of the data area by this additional offset.
+Shift the start of the PV data area by this additional offset.
 .ad b
 .HP
 .ad l
@@ -267,8 +267,7 @@ on the command.
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
-When 1, one copy of the VG metadata is stored at the front of the PV
-(starting in the 5th sector).
+When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
@@ -432,11 +431,9 @@ Add two PVs to a VG.
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index f3d86df..03b7bdc 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -338,11 +338,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 0d0eb84..11b8e7c 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -301,11 +301,9 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index 8b599f8..b964e3a 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -286,11 +286,9 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 1cff786..199e7eb 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -315,11 +315,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index fd92266..7aed4d8 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -445,11 +445,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 69f2831..703f3ba 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -332,11 +332,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 0313cf8..8085e06 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -328,11 +328,9 @@ Rename the VG with the specified UUID to "myvg".
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index c8a9611..7ba7b8c 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -336,12 +336,9 @@ Repeat once to also suppress any prompts with answer 'no'.
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered VGs
-when clustered locking is not configured or running. No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not LVs are
-actually in use.
+machine is running. No attempt will be made to communicate with the
+device-mapper kernel driver, so this option is unable to report whether
+or not LVs are actually in use.
 .ad b
 .HP
 .ad l
@@ -556,11 +553,9 @@ Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 7fe3713..68050c9 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -302,11 +302,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index c1e7f4e..f76a4db 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -395,11 +395,9 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmdump (8)
 
 .BR dmeventd (8)
-.BR lvmetad (8)
 .BR lvmpolld (8)
 .BR lvmlockd (8)
 .BR lvmlockctl (8)
-.BR clvmd (8)
 .BR cmirrord (8)
 .BR lvmdbusd (8)
 


