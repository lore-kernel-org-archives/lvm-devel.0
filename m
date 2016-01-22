From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 22 Jan 2016 13:20:49 +0000 (UTC)
Subject: master - conf: add metadata/check_pv_device_sizes
Message-ID: <20160122132049.0845460C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=136fd8f2f642c82b132ded4b9a95b05e822e9117
Commit:        136fd8f2f642c82b132ded4b9a95b05e822e9117
Parent:        c0912af3104cb72ea275d90b8b1d68a25a9ca48a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 22 13:20:21 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 22 14:16:00 2016 +0100

conf: add metadata/check_pv_device_sizes

---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   11 +++++++++++
 lib/commands/toolcontext.c   |    2 ++
 lib/commands/toolcontext.h   |    1 +
 lib/config/config_settings.h |    8 ++++++++
 lib/metadata/metadata.c      |    3 ++-
 6 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ff64846..0eb86e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Add metadata/check_pv_device_sizes switch to lvm.conf for device size checks.
   Warn if device size is less than corresponding PV size in metadata.
   Cache device sizes internally.
   Restore support for command breaking in process_each_lv_in_vg() (2.02.118).
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4dbe289..60f8023 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1415,6 +1415,17 @@ activation {
 # This configuration section has an automatic default value.
 # metadata {
 
+	# Configuration option metadata/check_pv_device_sizes.
+	# Check device sizes are not smaller than corresponding PV sizes.
+	# If device size is less than corresponding PV size found in metadata,
+	# there is always a risk of data loss. If this option is set, then LVM
+	# issues a warning message each time it finds that the device size is
+	# less than corresponding PV size. You should not disable this unless
+	# you are absolutely sure about what you are doing!
+	# This configuration option is advanced.
+	# This configuration option has an automatic default value.
+	# check_pv_device_sizes = 1
+
 	# Configuration option metadata/pvmetadatacopies.
 	# Number of copies of metadata to store on each PV.
 	# The --pvmetadatacopies option overrides this setting.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 90e8abe..4f94df4 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -670,6 +670,8 @@ static int _process_config(struct cmd_context *cmd)
 	/* LVM stores sizes internally in units of 512-byte sectors. */
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
+	cmd->check_pv_dev_sizes = find_config_tree_bool(cmd, metadata_check_pv_device_sizes_CFG, NULL);
+
 	if (!process_profilable_config(cmd))
 		return_0;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index e2b5377..5fda9a9 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -113,6 +113,7 @@ struct cmd_context {
 	 * Switches.
 	 */
 	unsigned is_long_lived:1;		/* optimises persistent_filter handling */
+	unsigned check_pv_dev_sizes:1;
 	unsigned handles_missing_pvs:1;
 	unsigned handles_unknown_segments:1;
 	unsigned use_linear_target:1;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d516f83..210a06f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1352,6 +1352,14 @@ cfg_array(activation_auto_lock_start_list_CFG, "auto_lock_start_list", activatio
 	"Locking is auto-started only for VGs selected by this list.\n"
 	"The rules are the same as those for auto_activation_volume_list.\n")
 
+cfg(metadata_check_pv_device_sizes_CFG, "check_pv_device_sizes", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 141), NULL, 0, NULL,
+	"Check device sizes are not smaller than corresponding PV sizes.\n"
+	"If device size is less than corresponding PV size found in metadata,\n"
+	"there is always a risk of data loss. If this option is set, then LVM\n"
+	"issues a warning message each time it finds that the device size is\n"
+	"less than corresponding PV size. You should not disable this unless\n"
+	"you are absolutely sure about what you are doing!\n")
+
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of copies of metadata to store on each PV.\n"
 	"The --pvmetadatacopies option overrides this setting.\n"
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b9e4121..d8a7128 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -672,7 +672,8 @@ static int _check_pv_dev_sizes(struct volume_group *vg)
 	uint64_t dev_size, size;
 	int r = 1;
 
-	if (is_orphan_vg(vg->name))
+	if (!vg->cmd->check_pv_dev_sizes ||
+	    is_orphan_vg(vg->name))
 		return 1;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {


