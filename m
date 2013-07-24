From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Jul 2013 21:11:27 +0000 (UTC)
Subject: master - cleanup: comments and a message
Message-ID: <20130724211127.5BE0D61199@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d13e87b9efb07f6e40d9fb44b72387231d493fa2
Commit:        d13e87b9efb07f6e40d9fb44b72387231d493fa2
Parent:        97df05ce107ae2bed9ef02cfcdcdde39bd2100d4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 24 22:10:37 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 24 22:10:37 2013 +0100

cleanup: comments and a message

---
 WHATS_NEW           |   15 ++++++++-------
 lib/config/config.h |    2 +-
 make.tmpl.in        |    1 +
 tools/vgimport.c    |    3 +--
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fd44fb1..587b53d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -5,7 +5,7 @@ Version 2.02.99 -
   Use LOG_DEBUG/ERR msg severity instead default for lvm2-activation-generator.
   Support ARG_GROUPABLE with merge_synonym (for --raidwritemostly).
   Fix segfault when reporting raid_syncaction for older kernels.
-  Add LV reporting fields raid_mismatch_count, raid_sync_action, raid_write_behind.
+  Add LV report fields: raid_mismatch_count/raid_sync_action/raid_write_behind.
   Add LV reporting fields raid_min_recovery_rate, raid_max_recovery_rate.
   Add sync_percent as alias for copy_percent LV reporting field.
   Add lv_ prefix to modules reporting field.
@@ -63,6 +63,8 @@ Version 2.02.99 -
   Report lvs volume type 'o' also for external origin volumes.
   Report lvs target type 't' only for thin pools and thin volumes.
   Fix test for active snapshot in cluster before resizing it.
+  Allow local activation to receive a locally-supplied LV struct.
+  Add vg->vg_ondisk / lv_ondisk() holding committed metadata.
   Report backtrace from dump filter error path.
   Do not use persistent filter with lvmetad.
   Composable persistent filter functionality for global filter.
@@ -99,7 +101,6 @@ Version 2.02.99 -
   Add lvcreate/lvchange --[raid]{min|max}recoveryrate for raid LVs.
   Add lvchange --[raid]writemostly/writebehind support for RAID1
   Add lv_change_activate() for common activation code in vg/lvchange.
-  Revert change that allowed identical table reload for RAID.
   Add lvchange --[raid]syncaction for scrubbing of RAID LVs.
   Improve RAID kernel status retrieval to include sync_action/mismatch_cnt.
   Add external origin support for lvcreate.
@@ -114,19 +115,19 @@ Version 2.02.99 -
   Add --type {current|default|missing|new} and --atversion to lvm dumpconfig.
   Support automatic config validation and add 'config' section to lvm.conf.
   Add pvs -o pv_ba_start,pv_ba_size to report bootloader area start and size.
-  Add --bootloaderareasize to pvcreate and vgconvert to create a bootloader area.
+  Add --bootloaderareasize to pvcreate and vgconvert to create bootloader area.
   Add PV header extension: extension version, flags and bootloader areas.
   Initial support for lvconvert of thin external origin.
   Add _lv_remove_segs_using_this_lv() for removal of dependent lvs.
   Improve activation code for better support of stacked devices.
   Add _add_layer_target_to_dtree() for adding linear layer into dtree.
   Extend _cached_info() to accept layer string.
-  Allow identical table reload for RAID to restore transiently failed PVs.
-  vgimport '--force' now allows users to import VGs with missing PVs.
+  vgimport '--force' now allows import of VGs with missing PVs.
   Fix PV alignment to incorporate alignment offset if the PV has zero MDAs.
-  Allow remove/replace of RAID sub-LVs that are composed of error targets.
+  Add global/raid10_segtype_default to lvm.conf.
+  Allow removal or replacement of RAID LV components that are error segments.
   Make 'vgreduce --removemissing' able to handle RAID LVs with missing PVs.
-  Rename lvm.conf setting 'mirror_region_size' to 'raid_region_size'.
+  Accept activation/raid_region_size in preference to mirror_region_size config.
   Fix pvs -o pv_free reporting for PVs with zero PE count.
   Fix missing cleanup of flags when the LV is detached from pool.
   Fix check for some forbidden discards conversion of thin pools.
diff --git a/lib/config/config.h b/lib/config/config.h
index 263da4f..f57757b 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -20,7 +20,7 @@
 #include "defaults.h"
 
 /* 16 bits: 3 bits for major, 4 bits for minor, 9 bits for patchlevel */
-/* Max LVM version supported: 7.15.511. Just extend bits if ever needed. */
+/* FIXME Max LVM version supported: 7.15.511. Extend bits when needed. */
 #define vsn(major, minor, patchlevel) (major << 13 | minor << 9 | patchlevel)
 
 struct device;
diff --git a/make.tmpl.in b/make.tmpl.in
index e2c4441..6992255 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -34,6 +34,7 @@ LIBS = @LIBS@
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS)
 DEFS += @DEFS@
+# FIXME set this only where it's needed, not globally?
 CFLAGS += @CFLAGS@ @UDEV_CFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 20cae6c..3a0798a 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -80,8 +80,7 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		 * where the user simply forgot to move one or more disks in
 		 * the VG before running 'vgimport'.
 		 */
-		log_print("'--force' supplied.  Volume groups with missing PVs"
-			  " will be imported.");
+		log_warn("WARNING: Volume groups with missing PVs will be imported with --force.");
 		cmd->handles_missing_pvs = 1;
 	}
 


