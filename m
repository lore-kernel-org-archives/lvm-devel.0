From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:47 +0000 (UTC)
Subject: master - release: update version/WHATS_NEW
Message-ID: <20120807203047.CA78D3454@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df452b47a1ae0288e737cfcdc171f8fe31e4a876
Commit:        df452b47a1ae0288e737cfcdc171f8fe31e4a876
Parent:        3a6bea990b01a583de830b90fee492823139b7ea
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 20:41:45 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 20:41:45 2012 +0100

release: update version/WHATS_NEW

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   30 +++++++++++++-----------------
 WHATS_NEW_DM |   13 +++++++++----
 4 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/VERSION b/VERSION
index 8b62010..159419f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.97(2)-git (2012-07-29)
+2.02.97(2)-git (2012-08-07)
diff --git a/VERSION_DM b/VERSION_DM
index e01aaa7..6b6b104 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.76-git (2012-07-30)
+1.02.76-git (2012-08-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2c4d139..97f3150 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,22 +1,21 @@
-Version 2.02.97 - 
-===============================
+Version 2.02.97 - 7th August 2012
+=================================
   Improve documention of allocation policies in lvm.8.
   Increase limit for major:minor to 4095:1048575 when using -My option.
   Add make install_systemd_generators.
   Add generator for lvm2 activation systemd units.
   Add lvm_config_find_bool lvm2app fn to retrieve bool value from config tree.
-  Respect --test also when using lvmetad.
+  Respect --test when using lvmetad.
   No longer capitalise first LV attribute char for invalid snapshots.
   Allow vgextend to add PVs to a VG that is missing PVs.
   Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
-  Fix segfault when attempting to replace RAID 4/5/6 device (2.02.97).
-  Fix dumpconfig <node> to print only <node> without its siblings (2.02.89).
+  Fix dumpconfig <node> to print only <node> without its siblings. (2.02.89)
   Do not issue "Failed to handle a client connection" error if lvmetad killed.
-  Support changing of discard and zeroing for thin pool.
-  Report used discard for thin pool and volume.
-  Add support for controlling discard behavior of thin pool.
-  Detect features for new 1.1 thin pool target.
-  Count percentage of completeness upwards when merging a snapshot volume.
+  Support lvchange --discard and -Z with thin pools.
+  Add discard LV segment field to reports.
+  Add --discard to lvcreate --thin.
+  Set discard and external snapshot features if thin pool target is vsn 1.1+.
+  Count percentage of completeness upwards not downwards when merging snapshot.
   Skip activation when using vg/lvchange --sysinit -a ay and lvmetad is active.
   Fix extending RAID 4/5/6 logical volumes
   Fix test for PV with unknown VG in process_each_pv to ignore ignored mdas.
@@ -29,13 +28,10 @@ Version 2.02.97 -
   Add --activate synonym for --available arg and prefer --activate.
   Never issue discards when LV extents are being reconfigured, not deleted.
   Allow release_lv_segment_area to fail as functions it calls can fail.
-  Open device read-only to obtain readahead value.
-  Fix lvconvert error path NULL pointer dereference.
-  Check for create_instance() fail in pvscan_lvmetad_single().
-  Use 64bit math for reserved memory and stack.
-  Add tests for kernel_send() errors in cmirrod.
-  Print clean_bits in pull_state, fix cut&paste typo in cmirrord.
-  Add tests for errors from closedir(), close() in cmirrord.
+  Open device read-only instead of read-write when obtaining readahead value.
+  Fix lvconvert thin pool error path NULL pointer dereference.
+  Detect create_instance() failure in pvscan_lvmetad_single().
+  Use 64-bit calculations for reserved memory and stack.
   Fix missing sync of filesystem when creating thin volume snapshot.
 
 Version 2.02.96 - 8th June 2012
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a790ccf..b18c10c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,15 +1,20 @@
-Version 1.02.76 - 
-===============================
+Version 1.02.76 - 7th August 2012
+=================================
+  Add dm_vasprintf to libdevmapper.
   Allow --noflush with dmsetup status and wait (for thin target).
   Add dm_config_write_one_node to libdevmapper.
-  Add support for thin pool message release/reserve_metadata_snap.
-  Add support for thin pool discard and external origin.
+  Support thin pool message release/reserve_metadata_snap in libdevmapper.
+  Support thin pool discard and external origin features in libdevmapper.
   Add configure --enable-udev-rule-exec-detection to detect exec path in rules.
   Use sbindir in udev rules by default and remove executable path detection.
   Remove hard-coded paths for dmeventd fifos and use default-dm-run-dir.
   Add configure --with-lvmetad-pidfile to remove hard-coded value.
   Add configure --with-default-pid-dir for common directory with pid files.
   Add configure --with-default-dm-run-dir to set run directory for dm tools.
+  Detect kernel_send() errors in cmirrord.
+  Add __attribute__ instrumentation to libdevmapper.h.
+  Print clean_bits instead of sync_bits in pull_state in cmirrord.
+  Add tests for errors from closedir(), close() in cmirrord.
   Add documentation references in systemd units.
   Remove veritysetup.  Now maintained with cryptsetup.
 


