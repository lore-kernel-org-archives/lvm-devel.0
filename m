From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Aug 2007 21:01:53 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW man/lvconvert.8 man ...
Message-ID: <20070824210153.23392.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-24 21:01:52

Modified files:
	.              : VERSION WHATS_NEW 
	man            : lvconvert.8 lvcreate.8 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.695&r2=1.696
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/VERSION	2007/07/17 20:53:51	1.156
+++ LVM2/VERSION	2007/08/24 21:01:52	1.157
@@ -1 +1 @@
-2.02.28-cvs (2007-07-17)
+2.02.28-cvs (2007-08-24)
--- LVM2/WHATS_NEW	2007/08/24 08:29:39	1.695
+++ LVM2/WHATS_NEW	2007/08/24 21:01:52	1.696
@@ -1,36 +1,37 @@
-Version 2.02.28 -
-================================
+Version 2.02.28 - 24th August 2007
+==================================
   Fix clvmd logging so you can get lvm-level debugging out of it.
   Introduce VG_GLOBAL lock type for vgscan/pvscan to trigger clvmd -R.
+  Change locking_flags from int to uint32_t.
   Fix clvmd -R, so it fully refreshes the caches.
   Change lvconvert_mirrors to use mirror segtype not striped.
   Fix lvconvert_mirrors detection of number of existing mirrors.
-  Clean up numerous compiler warnings that crept in recently.
+  Clean up numerous compiler warnings that appeared in recent releases.
   Remove several unused parameters from _allocate().
   Only permit --force, --verbose and --debug arguments to be repeated.
-  Move guts of vgremove into library.
   Fix inconsistent licence notices: executables are GPLv2; libraries LGPLv2.1.
-  Move guts of lvremove into library.
-  Allow clvmd debug to be turned on in a running daemon using clvmd -d
+  Move guts of vgremove and lvremove into library, including yes_no_prompt.
+  Allow clvmd debug to be turned on in a running daemon using clvmd -d [-C].
   Update to use autoconf 2.61, while still supporting 2.57.
-  Add more cluster info to lvmdump
-  Add const attributes where possible, first cut.
+  Add more cluster info to lvmdump.
+  Add further const attributes throughout.
   Add support for renaming mirrored LVs.
-  Factor out core of lvrename() to lv_rename lvm library function.
+  Factor out core of lvrename() to library function.
   Add --mirrorlog argument to specify log type for mirrors.
-  Don't try to monitor devices which we failed to create.
-  Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.
+  Don't attempt to monitor devices if their creation failed in _lv_activate.
+  Don't leak a file descriptor in fcntl_lock_file() when fcntl fails.
   Replace create_dir with dm_create_dir.
-  Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
+  Detect stream write failure reliably with lvm_fclose using dm_fclose.
   Fix clvmd if compiled with gulm support. (2.02.26)
-  Trivial fix to lvdisplay man page.
+  Fix lvdisplay man page to say LV size is reported in sectors, not KB.
   Add vg_lock_and_read() external library function.
   Fix loading of persistent cache if cache_dir is used. (2.02.23)
-  Eliminate uses of strdup+basename.  Use last_path_component instead.
+  Reduce _compare_paths lstat error message from log_error to log_very_verbose.
+  Create util.h with last_path_component replacing strdup + basename.
   Use gcc's printf attribute wherever possible.
-  In _line_append, use "sizeof buf - 1" rather than equivalent "4095"
+  In _line_append, use "sizeof buf - 1" rather than equivalent "4095".
   Introduce is_same_inode macro, now including a comparison of st_dev.
-  Don't leak a file descriptor in _lock_file(), when flock fails.
+  Don't leak a file descriptor in _lock_file() when flock fails.
   Add SUN's LDOM virtual block device (vdisk) and ps3disk to filters.
   Split metadata-external.h out from metadata.h for the tools to use.
 
--- LVM2/man/lvconvert.8	2007/08/09 20:43:29	1.7
+++ LVM2/man/lvconvert.8	2007/08/24 21:01:52	1.8
@@ -3,7 +3,7 @@
 lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-\-m/\-\-mirrors Mirrors [\-\-log {disk|core}] [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
+\-m/\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
 [\-A/\-\-alloc AllocationPolicy]
 [\-h/\-?/\-\-help]
 [\-v/\-\-verbose]
@@ -37,10 +37,14 @@
 volume to a mirror volume with 2-sides; that is, a
 linear volume plus one copy.
 .TP
-.I \-\-log disk/core
-This optional argument switches the logging type of a
-mirror.  The logging type can be either "disk" (persistent)
-or "core" (non-persistent).  The default logging type is "disk".
+.I \-\-mirrorlog {disk|core}
+Specifies the type of log to use.
+The default is disk, which is persistent and requires
+a small amount of storage space, usually on a separate device
+from the data being mirrored. 
+Core may be useful for short-lived mirrors: It means the mirror is
+regenerated by copying the data from the first device again every
+time the device is activated - perhaps, for example, after every reboot.
 .TP
 .I \-\-corelog
 The optional argument "--corelog" is the same as specifying "--log core".
--- LVM2/man/lvcreate.8	2007/08/09 20:43:29	1.16
+++ LVM2/man/lvcreate.8	2007/08/24 21:01:52	1.17
@@ -11,7 +11,7 @@
 {\-l/\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
  \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-M/\-\-persistent y/n] [\-\-minor minor]
-[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-log {disk|log}] [\-\-corelog]
+[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|log}] [\-\-corelog]
 [\-R/\-\-regionsize MirrorLogRegionSize]]
 [\-n/\-\-name LogicalVolumeName]
 [\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors]
@@ -85,25 +85,24 @@
 Set to y to make the minor number specified persistent.
 .TP
 .I \-m, \-\-mirrors Mirrors
-Creates a mirrored logical volume with "Mirrors" copies.  For example,
+Creates a mirrored logical volume with Mirrors copies.  For example,
 specifying "-m 1" would result in a mirror with two-sides; that is, a
 linear volume plus one copy.
 
-Specifying the optional argument "--nosync" will cause the creation
+Specifying the optional argument --nosync will cause the creation
 of the mirror to skip the initial resynchronization.  Any data written
 afterwards will be mirrored, but the original contents will not be
 copied.  This is useful for skipping a potentially long and resource
-intensive initial sync.
+intensive initial sync of an empty device.
 
-The optional argument "--log" gives the ability to specify the type
-of mirror log to be used.  The available types are "disk" and "core",
-where "disk" is the default.  The "disk" log is persistent and requires
-a small amount of storage space - usually on a separate device from the
-mirror devices.  While the "disk" log may cause the mirror to be slightly
-slower during writes, it prevents the need to completely resynchronize
-the mirror upon each instantiation (e.g. a reboot).
+The optional argument --mirrorlog specifies the type of log to be used.
+The default is disk, which is persistent and requires
+a small amount of storage space, usually on a separate device from the
+data being mirrored. Using core means the mirror is regenerated
+by copying the data from the first device again each time the
+device is activated, for example, after every reboot.
 
-The optional argument "--corelog" is the same as specifying "--log core".
+The optional argument --corelog is equivalent to --log core.
 
 .TP
 .I \-n, \-\-name LogicalVolumeName


