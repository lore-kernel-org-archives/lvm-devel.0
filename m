From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 15 Jun 2013 00:31:13 +0000 (UTC)
Subject: master - text: miscellaneous comments & message tweaks
Message-ID: <20130615003113.1E6DD60D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2dc21d89fb1b60fd57fd471e3934132f4f53dc6
Commit:        c2dc21d89fb1b60fd57fd471e3934132f4f53dc6
Parent:        538acd56f1a3cd439028e0b9c9d6106cb820228c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 15 01:28:54 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 15 01:28:54 2013 +0100

text: miscellaneous comments & message tweaks

---
 WHATS_NEW                                          |   10 +++++-----
 WHATS_NEW_DM                                       |    2 +-
 daemons/dmeventd/dmeventd.c                        |    2 +-
 doc/example.conf.in                                |    2 +-
 lib/activate/dev_manager.c                         |    4 ++++
 lib/metadata/mirror.c                              |    2 +-
 libdm/mm/pool-fast.c                               |    2 +-
 man/vgcfgrestore.8.in                              |   10 +++++-----
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 9 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a061467..97e3ebf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -77,14 +77,14 @@ Version 2.02.99 -
   Fix missing cleanup of flags when the LV is detached from pool.
   Fix check for some forbidden discards conversion of thin pools.
   Add pool_is_active() to check for any pool related active LV.
-  Report blank field if the LV doesn't have an origin instead of 0.
+  Report blank origin_size field if the LV doesn't have an origin instead of 0.
   Do not take a free lv name argument for lvconvert --thinpool option.
-  Avoid flushing thin pool when quering for transaction_id.
+  Avoid flushing thin pool when just requesting transaction_id.
   Add internal function lv_layer() to obtain layer name for LV.
   Report partial and in-sync RAID attribute based on kernel status
   Fix blkdeactivate to handle nested mountpoints and mangled mount paths.
-  Set locales with LC_ALL instead of lower priority LANG variable.
-  Fix a crash-inducing race condition in lvmetad.
+  Use LC_ALL to set locale in daemons and fsadm instead of lower priority LANG.
+  Avoid crash-inducing race in lvmetad when VG disappears during rename.
   Add log/debug_classes to lvm.conf to control debug log messages.
   Synchronize with udev in pvscan --cache and fix dangling udev_sync cookies.
   Fix autoactivation to not autoactivate VG/LV on each change of the PVs used.
@@ -135,7 +135,7 @@ Version 2.02.99 -
   Remove dependency on fedora-storage-init.service in lvm2 systemd units.
   Depend on lvm2-lvmetad.socket in lvm2-monitor.service systemd unit.
   Hardcode use_lvmetad=0 if cluster locking used and issue a warning msg.
-  Avoid LVM from trying to read a mirror that has a failed device in its mirrored log.
+  Avoid trying to read a mirror that has a failed device in its mirrored log.
   Relax ignore_suspended_devices to read from mirrors that don't have a device marked failed.
   Change lvs heading Copy% to Cpy%Sync and print RAID4/5/6 sync% there too.
   Fix clvmd support for option -d and properly use its argument.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 46ce9b0..c4bdcbf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -14,7 +14,7 @@ Version 1.02.78 -
   Add dm_config_write_{node_out/one_node_out} for enhanced config output.
   Add dm_config_value_is_bool to check for boolean value in supported formats.
   Fix config node lookup inside empty sections to not return the section itself.
-  Extend support for status info of thin pool target.
+  Append discards and read-only fields to exported struct dm_status_thin_pool.
   Fix segfault for truncated string token in config file after the first '"'.
   Close open dmeventd FIFO file descriptors on exec (FD_CLOEXEC).
   Fix resource leak in error path of dmeventd's umount of thin volume.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 4710910..64e1683 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -37,7 +37,7 @@
 #include <unistd.h>
 #include <signal.h>
 #include <arpa/inet.h>		/* for htonl, ntohl */
-#include <fcntl.h>
+#include <fcntl.h>		/* for musl libc */
 
 #ifdef linux
 /*
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 94c32d5..1620721 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -93,7 +93,7 @@ devices {
     # Use anchors if you want to be really specific
     # filter = [ "a|^/dev/hda8$|", "r/.*/" ]
 
-    # Since "filter" is often overriden from command line, it is not suitable
+    # Since "filter" is often overridden from command line, it is not suitable
     # for system-wide device filtering (udev rules, lvmetad). To hide devices
     # from LVM-specific udev processing and/or from lvmetad, you need to set
     # global_filter. The syntax is the same as for normal "filter"
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cd50fa0..9855bc9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1059,6 +1059,8 @@ int dev_manager_raid_status(struct dev_manager *dm,
 		goto out;
 	}
 
+	/* FIXME Check there's only one target */
+
 	if (!dm_get_status_raid(dm->mem, params, status))
 		goto_out;
 
@@ -1213,6 +1215,8 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
+	/* FIXME Check for thin and check there's exactly one target */
+
 	if (!dm_get_status_thin_pool(dm->mem, params, status))
 		goto_out;
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index f4f7b66..6c6554e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -868,7 +868,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		sub_lv = seg_lv(mirrored_seg, s);
 		if (!(is_temporary_mirror_layer(sub_lv) && lv_mirror_count(sub_lv) != 1)) {
 			if (!is_removable) {
-				log_error(INTERNAL_ERROR "Test is_removable undefined.");
+				log_error(INTERNAL_ERROR "_remove_mirror_images called incorrectly with is_removable undefined.");
 				return 0;
 			}
 			if (!is_removable(sub_lv, removable_baton))
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 0e13416..2b494d6 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -18,7 +18,7 @@
 #endif
 
 #include "dmlib.h"
-#include <stddef.h>
+#include <stddef.h>	/* For musl libc */
 #include <malloc.h>
 
 struct chunk {
diff --git a/man/vgcfgrestore.8.in b/man/vgcfgrestore.8.in
index a5c8194..ac84300 100644
--- a/man/vgcfgrestore.8.in
+++ b/man/vgcfgrestore.8.in
@@ -35,12 +35,12 @@ Specifies a metadata backup or archive file to be used for restoring
 VolumeGroupName.  Often this file has been created with \fBvgcfgbackup\fP.
 .TP
 .B \-\-force
-To restore metadata with thin pool volumes, user currently
-needs to use this flag. The tool DOES NOT perform any validation.
+Necessary to restore metadata with thin pool volumes.
 .br
-WARNING: Restoring lvm2 metadata that does not exactly match the 
-thin pool kernel metadata may lead to the destruction of the pool content.
-Use with extreme caution.
+\fBWARNING: Use with extreme caution.
+Most changes to thin metadata cannot be reverted.
+You may lose data if you restore metadata that does not match the thin pool
+kernel metadata precisely.\fP
 .SH REPLACING PHYSICAL VOLUMES
 \fBvgdisplay \-\-partial \-\-verbose\fP will show you the UUIDs and sizes of
 any PVs that are no longer present.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 6fc2865..f3a01a2 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -19,7 +19,7 @@
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
-#include <limits.h>		/* for PATH_MAX */
+#include <limits.h>		/* For PATH_MAX for musl libc */
 #include "lvm2app.h"
 
 #define KMSG_DEV_PATH        "/dev/kmsg"


