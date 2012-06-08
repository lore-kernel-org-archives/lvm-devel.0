From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Jun 2012 23:29:52 +0000 (UTC)
Subject: master - release: WHATS_NEW tidy
Message-ID: <20120608232952.AE1582719@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8dade001b82326ad15ec04ce329aeda218c3830c
Commit:        8dade001b82326ad15ec04ce329aeda218c3830c
Parent:        dd5b2974c09a6650211b6f02f0e86ec63d6413d4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 9 00:29:20 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 9 00:29:20 2012 +0100

release: WHATS_NEW tidy

---
 WHATS_NEW |   42 +++++++++++++++++++++++-------------------
 1 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7692b2f..89e26b5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.96 - 
-================================
+Version 2.02.96 - 8th June 2012
+===============================
   Upstream source repo now fedorahosted.org git not sources.redhat.com CVS.
   Fix error paths for regex filter initialization.
   Re-enable partial activation of non-thin LVs until it can be fixed. (2.02.90)
@@ -10,8 +10,8 @@ Version 2.02.96 -
   Add missing pkg init --with-systemdsystemunitdir in configure.in (2.02.92).
   Fix division by zero if PV with zero PE count is used during vgcfgrestore.
   Add initial support for thin pool lvconvert.
-  Fix lvrename for thin volumes (regression in for_each_sub_lv() 2.02.89).
-  Fix up-convert when mirror activation is controled by volume_list and tags.
+  Fix lvrename for thin volumes (regression in for_each_sub_lv). (2.02.89)
+  Fix up-convert when mirror activation is controlled by volume_list and tags.
   Warn of deadlock risk when using snapshots of mirror segment type.
   Fix bug in cmirror that caused incorrect status info to print on some nodes.
   Remove statement that snapshots cannot be tagged from lvm man page.
@@ -24,18 +24,18 @@ Version 2.02.96 -
   Handle replacement of an active device that goes missing with an error device.
   Change change raid1 segtype always to request a flush when suspending.
   Add udev info and context to lvmdump.
+  Add lvmetad man page.
   Fix RAID device replacement code so that it works under snapshot.
   Fix inability to split RAID1 image while specifying a particular PV.
-  Update man pages to give them same look&feel.
-  Fix lvresize of thin pool for stipped devices.
+  Update man pages to give them all the same look&feel.
+  Fix lvresize of thin pool for striped devices.
   For lvresize round upward when specifying number of extents.
-  For lvcreate with %FREE support rounding downward strip alignment.
+  For lvcreate with %FREE support rounding downward stripe alignment.
   Change message severity to log_very_verbose for missing dev info in udev db.
-  Fix problems when specifying PVs during RAID down-converts.
-  Fix ability to handle failures in mirrored log (regression intro 2.02.89).
+  Fix lvconvert when specifying removal of a RAID device other than last one.
+  Fix ability to handle failures in mirrored log in dmeventd plugin. (2.02.89)
   Fix unlocking volume group in vgreduce in error path.
-  Exit immediately if LISTEN_PID env var incorrect during systemd handover.
-  Detect VG name being part of the LV name in lvconvert --splitmirrors -n.
+  Cope when VG name is part of the supplied name in lvconvert --splitmirrors -n.
   Fix exclusive lvchange running from other node. (2.02.89)
   Add 'vgscan --cache' functionality for consistency with 'pvscan --cache'.
   Keep exclusive activation in pvmove if LV is already active.
@@ -44,25 +44,29 @@ Version 2.02.96 -
   Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
   Always free hash table on update_pvid_to_vgid() in lvmetad.
   Update and fix monitoring of thin pool devices.
-  Check hash insert success in lock_vg clvmd.
-  Check for buffer overwrite in get_cluster_type() clvmd.
+  Check hash insert success in lock_vg in clvmd.
+  Check for buffer overwrite in get_cluster_type() in clvmd.
   Fix global/detect_internal_vg_cache_corruption config check.
   Update lcov Makefile target to support all dmeventd plugins.
-  Fix initializiation of thin monitoring (2.02.92).
-  Support improperly formated device numbers in /proc/devices (2.02.91).
+  Fix initializiation of thin monitoring. (2.02.92)
+  Cope with improperly formatted device numbers in /proc/devices. (2.02.91)
+  Exit if LISTEN_PID environment variable incorrect in lvmetad systemd handover.
+  Use pvscan --cache instead of vgscan in lvmetad scripts.
   Fix fsadm propagation of -e option.
   Fix fsadm parsing of /proc/mounts files (don't check for substrings).
   Fix fsadm usage of arguments with space.
-  Fix a regression in handling of lvchange/lvcreate --major/--minor.
+  Fix arg_int_value alongside ARG_GROUPABLE --major/--minor for lvcreate/change.
   Fix name conflicts that prevent down-converting RAID1 when specifying a device
   Improve thin_check option passing and use configured path.
   Add --with-thin-check configure option for path to thin_check.
-  Detect lvm binary path in lvmetad udev rules.
   Fix error message when pvmove LV activation fails with name already in use.
   Better structure layout for device_info in dev_subsystem_name().
   Change message severity for creation of VG over uninitialised devices.
-  Fix error path for failing toolcontext creation.
-  Fix warn msg for thin pool chunk size and update man for chunksize (2.02.89).
+  Fix error path for failed toolcontext creation.
+  Detect lvm binary path in lvmetad udev rules.
+  Don't unlink socket on lvmetad shutdown if instantiated from systemd.
+  Restart lvmetad automatically from systemd if it exits from uncaught signal.
+  Fix warn msg for thin pool chunk size and update man for chunksize. (2.02.89)
 
 Version 2.02.95 - 6th March 2012
 ================================


