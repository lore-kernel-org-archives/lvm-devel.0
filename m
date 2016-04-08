From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Apr 2016 15:30:17 +0000 (UTC)
Subject: master - activation: Skip another non-prefixed info ioctl.
Message-ID: <20160408153017.5CED961B62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f40dfb48ad0114c89ac5fc0a8670a3792565e9a9
Commit:        f40dfb48ad0114c89ac5fc0a8670a3792565e9a9
Parent:        e6768997e192e26aaf091b6ed2700a3391f178b5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 8 16:27:12 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 8 16:27:12 2016 +0100

activation: Skip another non-prefixed info ioctl.

_percent() also does a lookup by dm uuid.
Also get kernel version from cmd->kernel_vsn.
---
 lib/activate/activate.c    |    4 +-
 lib/activate/dev_manager.c |   60 ++++++++++++++++++++++++-------------------
 lib/activate/dev_manager.h |    3 +-
 3 files changed, 37 insertions(+), 30 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 985d6b9..ca82518 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -660,7 +660,7 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	/* New thin-pool has no layer, but -tpool suffix needs to be queried */
 	if (!use_layer && lv_is_new_thin_pool(lv)) {
 		/* Check if there isn't existing old thin pool mapping in the table */
-		if (!dev_manager_info(cmd->mem, lv, NULL, 0, 0, &dminfo, NULL, NULL))
+		if (!dev_manager_info(cmd, lv, NULL, 0, 0, &dminfo, NULL, NULL))
 			return_0;
 		if (!dminfo.exists)
 			use_layer = 1;
@@ -669,7 +669,7 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	if (seg_status)
 		seg_status->seg = seg;
 
-	if (!dev_manager_info(cmd->mem, lv,
+	if (!dev_manager_info(cmd, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
 			      with_open_count, with_read_ahead,
 			      &dminfo, (info) ? &info->read_ahead : NULL,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 18e2081..89fa9e9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -29,7 +29,6 @@
 
 #include <limits.h>
 #include <dirent.h>
-#include <sys/utsname.h>
 
 #define MAX_TARGET_PARAMSIZE 50000
 #define LVM_UDEV_NOSCAN_FLAG DM_SUBSYSTEM_UDEV_FLAG0
@@ -675,25 +674,31 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 	return r;
 }
 
-/* Returns 1 for kernels >= 3.X, otherwise 0 */
-static int _check_new_kernel(void)
+/*
+ * If active LVs were activated by a version of LVM2 before 2.02.00 we must
+ * perform additional checks to find them because they do not have the LVM-
+ * prefix on their dm uuids.
+ * As of 2.02.150, we've chosen to disable this compatibility arbitrarily if
+ * we're running kernel version 3 or above.
+ */
+#define MIN_KERNEL_MAJOR 3
+
+static int _original_uuid_format_check_required(struct cmd_context *cmd)
 {
-	static int major = 0;
-	struct utsname _uts;
+	static int _kernel_major = 0;
 
-	if (!major) {
-		if (uname(&_uts) ||
-		    (sscanf(_uts.release, "%d", &major) != 1))
-			major = 1;
-		else if (major >= 3)
-			log_debug("Not checking for devices without prefix "
-				  UUID_PREFIX " with newer kernel.");
+	if (!_kernel_major) {
+		if ((sscanf(cmd->kernel_vsn, "%d", &_kernel_major) != 1))
+			_kernel_major = 1;
+		else if (_kernel_major >= MIN_KERNEL_MAJOR)
+			log_debug_activation("Skipping checks for old devices without " UUID_PREFIX
+					     " dm uuid prefix (kernel vsn %d >= %d).", _kernel_major, MIN_KERNEL_MAJOR);
 	}
 
-	return (major >= 3);
+	return (_kernel_major < MIN_KERNEL_MAJOR);
 }
 
-static int _info(const char *dlid, int with_open_count, int with_read_ahead,
+static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count, int with_read_ahead,
 		 struct dm_info *dminfo, uint32_t *read_ahead,
 		 struct lv_seg_status *seg_status)
 {
@@ -722,8 +727,8 @@ static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 		}
 	}
 
-	/* With kernels > 3.X skip checking for devices without UUID_PREFIX */
-	if (_check_new_kernel())
+	/* Must we still check for the pre-2.02.00 dm uuid format? */
+	if (!_original_uuid_format_check_required(cmd))
 		return r;
 
 	/* Check for dlid before UUID_PREFIX was added */
@@ -740,7 +745,7 @@ static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 	return _info_run(INFO, NULL, NULL, info, NULL, 0, 0, 0, major, minor);
 }
 
-int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
+int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		     const char *layer,
 		     int with_open_count, int with_read_ahead,
 		     struct dm_info *dminfo, uint32_t *read_ahead,
@@ -749,19 +754,19 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 	char *dlid, *name;
 	int r;
 
-	if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, layer)))
+	if (!(name = dm_build_dm_name(cmd->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(mem, lv, layer))) {
+	if (!(dlid = build_dm_uuid(cmd->mem, lv, layer))) {
 		r = 0;
 		goto_out;
 	}
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
-	r = _info(dlid, with_open_count, with_read_ahead,
+	r = _info(cmd, dlid, with_open_count, with_read_ahead,
 		  dminfo, read_ahead, seg_status);
 out:
-	dm_pool_free(mem, name);
+	dm_pool_free(cmd->mem, name);
 
 	return r;
 }
@@ -1008,7 +1013,8 @@ static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
 				 event_nr, fail_if_percent_unsupported))
 			return 1;
-		else if (_percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
+		else if (_original_uuid_format_check_required(dm->cmd) &&
+			 _percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
 				      target_type, wait, lv, percent,
 				      event_nr, fail_if_percent_unsupported))
 			return 1;
@@ -1686,7 +1692,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
-	if (!_info(dlid, 1, 0, &info, NULL, NULL)) {
+	if (!_info(dm->cmd, dlid, 1, 0, &info, NULL, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}
@@ -1884,8 +1890,8 @@ static int _pool_callback(struct dm_tree_node *node,
 			log_sys_error("close", argv[args]);
 
 		if (ret == (int) DM_ARRAY_SIZE(buf)) {
-			log_debug("%s skipped, detect empty disk header on %s.",
-				  argv[0], argv[args]);
+			log_debug_activation("%s skipped, detect empty disk header on %s.",
+					     argv[0], argv[args]);
 			return 1;
 		}
 	}
@@ -2210,7 +2216,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 		return_NULL;
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
-	if (!_info(dlid, 1, 0, &info, NULL, NULL)) {
+	if (!_info(dm->cmd, dlid, 1, 0, &info, NULL, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index bcfb226..3744a61 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -45,11 +45,12 @@ void dev_manager_exit(void);
  * (eg, an origin is created before its snapshot, but is not
  * unsuspended until the snapshot is also created.)
  */
-int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
+int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		     const char *layer,
 		     int with_open_count, int with_read_ahead,
 		     struct dm_info *dminfo, uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status);
+
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 dm_percent_t *percent);


