From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:04 +0000 (UTC)
Subject: master - cleanup: constify activation usage of lv pointer
Message-ID: <20140924085704.9763460D58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84cdf85bd2d682f11deeff51e39f3bfb98753829
Commit:        84cdf85bd2d682f11deeff51e39f3bfb98753829
Parent:        af18e7cfbfee96ff8f5ec2ab795c830b4a6c7da4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 15:50:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

cleanup: constify activation usage of lv pointer

Let's enforce cheking of write access to LV by compiler.
Activation part does never need to write anything to LV
so keep LV pointer const.
---
 lib/activate/activate.c          |   86 ++++++++++++++++++++------------------
 lib/activate/activate.h          |   25 ++++++-----
 lib/activate/dev_manager.c       |   42 +++++++++---------
 lib/activate/dev_manager.h       |   12 +++---
 lib/activate/fs.c                |    4 +-
 lib/activate/fs.h                |    2 +-
 lib/locking/cluster_locking.c    |    6 +-
 lib/locking/external_locking.c   |    2 +-
 lib/locking/file_locking.c       |    2 +-
 lib/locking/locking.c            |    4 +-
 lib/locking/locking.h            |    2 +-
 lib/locking/locking_types.h      |    2 +-
 lib/locking/no_locking.c         |    4 +-
 lib/metadata/lv.h                |    2 +-
 lib/metadata/metadata-exported.h |   14 +++---
 lib/metadata/metadata.c          |    2 +-
 lib/metadata/mirror.c            |   10 ++--
 lib/metadata/raid_manip.c        |    5 +-
 lib/metadata/replicator_manip.c  |    6 +-
 tools/polldaemon.h               |    2 +-
 20 files changed, 120 insertions(+), 114 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7f3a711..82ce6d8 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -108,7 +108,7 @@ int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,
 	return 1;
 }
 
-static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
+static int _lv_passes_volumes_filter(struct cmd_context *cmd, const struct logical_volume *lv,
 				     const struct dm_config_node *cn, const int cfg_id)
 {
 	const struct dm_config_value *cv;
@@ -248,7 +248,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 {
 	return 0;
 }
-int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv,
 			struct lvinfo *info)
 {
         return 0;
@@ -328,35 +328,35 @@ int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 }
 *******/
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
-			 struct logical_volume *ondisk_lv, struct logical_volume *incore_lv)
+			 const struct logical_volume *ondisk_lv, const struct logical_volume *incore_lv)
 {
 	return 1;
 }
-int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv)
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, const struct logical_volume *lv)
 {
 	return 1;
 }
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
-			unsigned exclusive, unsigned revert, struct logical_volume *lv)
+			unsigned exclusive, unsigned revert, const struct logical_volume *lv)
 {
 	return 1;
 }
-int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv)
+int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logical_volume *lv)
 {
 	return 1;
 }
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv, struct logical_volume *lv)
+			 int *activate_lv, const struct logical_volume *lv)
 {
 	return 1;
 }
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, int noscan,
-		int temporary, struct logical_volume *lv)
+		int temporary, const struct logical_volume *lv)
 {
 	return 1;
 }
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-			    int noscan, int temporary, struct logical_volume *lv)
+			    int noscan, int temporary, const struct logical_volume *lv)
 {
 	return 1;
 }
@@ -405,7 +405,7 @@ int lv_check_transient(struct logical_volume *lv)
 {
 	return 1;
 }
-int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
+int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume *lv,
 			   const struct lv_activate_opts *laopts, int monitor)
 {
 	return 1;
@@ -426,7 +426,7 @@ int device_is_usable(struct device *dev)
 {
         return 0;
 }
-int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 		       const char *layer, const char *target_type)
 {
         return 0;
@@ -458,7 +458,7 @@ int activation(void)
 }
 
 static int _passes_activation_filter(struct cmd_context *cmd,
-				     struct logical_volume *lv)
+				     const struct logical_volume *lv)
 {
 	const struct dm_config_node *cn;
 
@@ -487,7 +487,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 }
 
 static int _passes_readonly_filter(struct cmd_context *cmd,
-				   struct logical_volume *lv)
+				   const struct logical_volume *lv)
 {
 	const struct dm_config_node *cn;
 
@@ -695,7 +695,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 #define OPEN_COUNT_CHECK_RETRIES 25
 #define OPEN_COUNT_CHECK_USLEEP_DELAY 200000
 
-int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv,
 			struct lvinfo *info)
 {
 	unsigned int open_count_check_retries;
@@ -1256,7 +1256,7 @@ static int _lv_active(struct cmd_context *cmd, const struct logical_volume *lv)
 	return info.exists;
 }
 
-static int _lv_open_count(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lv_open_count(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	struct lvinfo info;
 
@@ -1268,7 +1268,7 @@ static int _lv_open_count(struct cmd_context *cmd, struct logical_volume *lv)
 	return info.open_count;
 }
 
-static int _lv_activate_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
+static int _lv_activate_lv(const struct logical_volume *lv, struct lv_activate_opts *laopts)
 {
 	int r;
 	struct dev_manager *dm;
@@ -1283,7 +1283,7 @@ static int _lv_activate_lv(struct logical_volume *lv, struct lv_activate_opts *l
 	return r;
 }
 
-static int _lv_preload(struct logical_volume *lv, struct lv_activate_opts *laopts,
+static int _lv_preload(const struct logical_volume *lv, struct lv_activate_opts *laopts,
 		       int *flush_required)
 {
 	int r = 0;
@@ -1305,7 +1305,7 @@ out:
 	return r;
 }
 
-static int _lv_deactivate(struct logical_volume *lv)
+static int _lv_deactivate(const struct logical_volume *lv)
 {
 	int r;
 	struct dev_manager *dm;
@@ -1320,7 +1320,7 @@ static int _lv_deactivate(struct logical_volume *lv)
 	return r;
 }
 
-static int _lv_suspend_lv(struct logical_volume *lv, struct lv_activate_opts *laopts,
+static int _lv_suspend_lv(const struct logical_volume *lv, struct lv_activate_opts *laopts,
 			  int lockfs, int flush_required)
 {
 	int r;
@@ -1538,7 +1538,7 @@ char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath)
 	return path;
 }
 
-static char *_build_target_uuid(struct cmd_context *cmd, struct logical_volume *lv)
+static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	const char *layer;
 
@@ -1553,7 +1553,7 @@ static char *_build_target_uuid(struct cmd_context *cmd, struct logical_volume *
 }
 
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
-				    struct logical_volume *lv, int *pending)
+				    const struct logical_volume *lv, int *pending)
 {
 	char *uuid;
 	enum dm_event_mask evmask = 0;
@@ -1585,7 +1585,7 @@ int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 	return evmask;
 }
 
-int target_register_events(struct cmd_context *cmd, const char *dso, struct logical_volume *lv,
+int target_register_events(struct cmd_context *cmd, const char *dso, const struct logical_volume *lv,
 			    int evmask __attribute__((unused)), int set, int timeout)
 {
 	char *uuid;
@@ -1621,7 +1621,7 @@ int target_register_events(struct cmd_context *cmd, const char *dso, struct logi
  * Returns 0 if an attempt to (un)monitor the device failed.
  * Returns 1 otherwise.
  */
-int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
+int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume *lv,
 			   const struct lv_activate_opts *laopts, int monitor)
 {
 #ifdef DMEVENTD
@@ -1796,7 +1796,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 struct detached_lv_data {
-	struct logical_volume *lv_pre;
+	const struct logical_volume *lv_pre;
 	struct lv_activate_opts *laopts;
 	int *flush_required;
 };
@@ -1817,9 +1817,11 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		       struct lv_activate_opts *laopts, int error_if_not_suspended,
-	               struct logical_volume *ondisk_lv, struct logical_volume *incore_lv)
+	               const struct logical_volume *ondisk_lv, const struct logical_volume *incore_lv)
 {
-	struct logical_volume *pvmove_lv = NULL, *ondisk_lv_to_free = NULL, *incore_lv_to_free = NULL;
+	const struct logical_volume *pvmove_lv = NULL;
+	const struct logical_volume *ondisk_lv_to_free = NULL;
+	const struct logical_volume *incore_lv_to_free = NULL;
 	struct lv_list *lvl_pre;
 	struct seg_list *sl;
         struct lv_segment *snap_seg;
@@ -1903,7 +1905,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		detached.laopts = laopts;
 		detached.flush_required = &flush_required;
 
-		if (!for_each_sub_lv(ondisk_lv, &_preload_detached_lv, &detached))
+		if (!for_each_sub_lv((struct logical_volume *)ondisk_lv, &_preload_detached_lv, &detached))
 			goto_out;
 
 		/*
@@ -1986,7 +1988,8 @@ out:
  *
  * Returns success if the device is not active
  */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *ondisk_lv, struct logical_volume *incore_lv)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
+			 const struct logical_volume *ondisk_lv, const struct logical_volume *incore_lv)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
@@ -2006,9 +2009,9 @@ int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		      struct lv_activate_opts *laopts, int error_if_not_active,
-	              struct logical_volume *lv)
+	              const struct logical_volume *lv)
 {
-	struct logical_volume *lv_to_free = NULL;
+	const struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	int r = 0;
 	int messages_only = 0;
@@ -2079,7 +2082,7 @@ out:
  */
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive,
-			unsigned revert, struct logical_volume *lv)
+			unsigned revert, const struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
@@ -2090,14 +2093,15 @@ int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 	return _lv_resume(cmd, lvid_s, &laopts, 0, lv);
 }
 
-int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv)
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
+	      const struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { .origin_only = origin_only, };
 
 	return _lv_resume(cmd, lvid_s, &laopts, 1, lv);
 }
 
-static int _lv_has_open_snapshots(struct logical_volume *lv)
+static int _lv_has_open_snapshots(const struct logical_volume *lv)
 {
 	struct lv_segment *snap_seg;
 	struct lvinfo info;
@@ -2115,9 +2119,9 @@ static int _lv_has_open_snapshots(struct logical_volume *lv)
 	return r;
 }
 
-int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv)
+int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logical_volume *lv)
 {
-	struct logical_volume *lv_to_free = NULL;
+	const struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	static const struct lv_activate_opts laopts = { .skip_in_use = 1 };
 	int r = 0;
@@ -2176,9 +2180,9 @@ out:
 
 /* Test if LV passes filter */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv, struct logical_volume *lv)
+			 int *activate_lv, const struct logical_volume *lv)
 {
-	struct logical_volume *lv_to_free = NULL;
+	const struct logical_volume *lv_to_free = NULL;
 	int r = 0;
 
 	if (!activation()) {
@@ -2205,9 +2209,9 @@ out:
 
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 			struct lv_activate_opts *laopts, int filter,
-	                struct logical_volume *lv)
+	                const struct logical_volume *lv)
 {
-	struct logical_volume *lv_to_free = NULL;
+	const struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	int r = 0;
 
@@ -2297,7 +2301,7 @@ out:
 
 /* Activate LV */
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-		int noscan, int temporary, struct logical_volume *lv)
+		int noscan, int temporary, const struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { .exclusive = exclusive,
 					   .noscan = noscan,
@@ -2311,7 +2315,7 @@ int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive,
 
 /* Activate LV only if it passes filter */
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-			    int noscan, int temporary, struct logical_volume *lv)
+			    int noscan, int temporary, const struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { .exclusive = exclusive,
 					   .noscan = noscan,
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index b6cf474..17648fc 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -74,15 +74,16 @@ void activation_release(void);
 void activation_exit(void);
 
 /* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *lv_ondisk, struct logical_volume *lv_incore);
-int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv);
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
+			 const struct logical_volume *lv_ondisk, const struct logical_volume *lv_incore);
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, const struct logical_volume *lv);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
-			unsigned origin_only, unsigned exclusive, unsigned revert, struct logical_volume *lv);
+			unsigned origin_only, unsigned exclusive, unsigned revert, const struct logical_volume *lv);
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-		int noscan, int temporary, struct logical_volume *lv);
+		int noscan, int temporary, const struct logical_volume *lv);
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-			    int noscan, int temporary, struct logical_volume *lv);
-int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv);
+			    int noscan, int temporary, const struct logical_volume *lv);
+int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logical_volume *lv);
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
 
@@ -94,14 +95,14 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
-int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv,
 			struct lvinfo *info);
 
 /*
  * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
  */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv, struct logical_volume *lv);
+			 int *activate_lv, const struct logical_volume *lv);
 /*
  * Checks against the auto_activation_volume_list and
  * returns 1 if the LV should be activated, 0 otherwise.
@@ -147,18 +148,18 @@ int lv_is_active_exclusive(const struct logical_volume *lv);
 int lv_is_active_exclusive_locally(const struct logical_volume *lv);
 int lv_is_active_exclusive_remotely(const struct logical_volume *lv);
 
-int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 		       const char *layer, const char *target_type);
 
-int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
+int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume *lv,
 			   const struct lv_activate_opts *laopts, int do_reg);
 
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
 char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath);
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *libpath,
-				    struct logical_volume *lv, int *pending);
-int target_register_events(struct cmd_context *cmd, const char *dso, struct logical_volume *lv,
+				    const struct logical_volume *lv, int *pending);
+int target_register_events(struct cmd_context *cmd, const char *dso, const struct logical_volume *lv,
 			    int evmask __attribute__((unused)), int set, int timeout);
 #endif
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4ee5a25..0437c69 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -60,11 +60,11 @@ struct dev_manager {
 };
 
 struct lv_layer {
-	struct logical_volume *lv;
+	const struct logical_volume *lv;
 	const char *old_name;
 };
 
-int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
+int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts)
 {
 	return (laopts->read_only || !(lv->status & LVM_WRITE));
 }
@@ -659,7 +659,7 @@ static int _status(const char *name, const char *uuid,
 }
 #endif
 
-int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 		       const char *layer, const char *target_type)
 {
 	int r = 0;
@@ -888,7 +888,7 @@ static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 }
 
 /* FIXME Merge with the percent function */
-int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
+int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *lv)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -1534,7 +1534,7 @@ static int _check_udev_fallback(struct cmd_context *cmd)
 
 #endif /* UDEV_SYNC_SUPPORT */
 
-static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *lv,
+static uint16_t _get_udev_flags(struct dev_manager *dm, const struct logical_volume *lv,
 				const char *layer, int noscan, int temporary)
 {
 	uint16_t udev_flags = 0;
@@ -1597,7 +1597,7 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *l
 }
 
 static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-			     struct logical_volume *lv, const char *layer)
+			     const struct logical_volume *lv, const char *layer)
 {
 	char *dlid, *name;
 	struct dm_info info, info2;
@@ -1656,7 +1656,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
  */
 static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
 					    struct dm_tree *dtree,
-					    struct logical_volume *lv)
+					    const struct logical_volume *lv)
 {
 	struct logical_volume *rlv = first_seg(lv)->replicator;
 	struct replicator_device *rdev;
@@ -1881,7 +1881,7 @@ static int _pool_register_callback(struct dev_manager *dm,
  * Add LV and any known dependencies
  */
 static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-			    struct logical_volume *lv, int origin_only)
+			    const struct logical_volume *lv, int origin_only)
 {
 	uint32_t s;
 	struct seg_list *sl;
@@ -2025,7 +2025,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	return 1;
 }
 
-static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, int origin_only)
+static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, const struct logical_volume *lv, int origin_only)
 {
 	struct dm_tree *dtree;
 
@@ -2217,7 +2217,7 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 
 static int _add_layer_target_to_dtree(struct dev_manager *dm,
 				      struct dm_tree_node *dnode,
-				      struct logical_volume *lv)
+				      const struct logical_volume *lv)
 {
 	const char *layer_dlid;
 
@@ -2235,8 +2235,8 @@ static int _add_layer_target_to_dtree(struct dev_manager *dm,
 }
 
 static int _add_origin_target_to_dtree(struct dev_manager *dm,
-					 struct dm_tree_node *dnode,
-					 struct logical_volume *lv)
+				       struct dm_tree_node *dnode,
+				       const struct logical_volume *lv)
 {
 	const char *real_dlid;
 
@@ -2251,7 +2251,7 @@ static int _add_origin_target_to_dtree(struct dev_manager *dm,
 
 static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 					       struct dm_tree_node *dnode,
-					       struct logical_volume *lv)
+					       const struct logical_volume *lv)
 {
 	const char *origin_dlid, *cow_dlid, *merge_dlid;
 	struct lv_segment *merging_snap_seg = find_snapshot(lv);
@@ -2280,7 +2280,7 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 
 static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 					 struct dm_tree_node *dnode,
-					 struct logical_volume *lv,
+					 const struct logical_volume *lv,
 					 struct lv_activate_opts *laopts)
 {
 	const char *origin_dlid;
@@ -2334,7 +2334,7 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				struct logical_volume *lv,
+				const struct logical_volume *lv,
 				struct lv_activate_opts *laopts,
 				const char *layer);
 
@@ -2570,7 +2570,7 @@ static int _set_udev_flags_for_children(struct dev_manager *dm,
 #endif
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				struct logical_volume *lv, struct lv_activate_opts *laopts,
+				const struct logical_volume *lv, struct lv_activate_opts *laopts,
 				const char *layer)
 {
 	struct lv_segment *seg;
@@ -2866,7 +2866,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 	return 1;
 }
 
-static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
+static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, action_t action)
 {
 	const size_t DLID_SIZE = ID_LEN + sizeof(UUID_PREFIX) - 1;
@@ -2962,7 +2962,7 @@ out_no_root:
 }
 
 /* origin_only may only be set if we are resuming (not activating) an origin LV */
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
+int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,
 			 struct lv_activate_opts *laopts)
 {
 	laopts->send_messages = 1;
@@ -2976,7 +2976,7 @@ int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
 }
 
 /* origin_only may only be set if we are resuming (not activating) an origin LV */
-int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
+int dev_manager_preload(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int *flush_required)
 {
 	if (!_tree_action(dm, lv, laopts, PRELOAD))
@@ -2987,7 +2987,7 @@ int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 	return 1;
 }
 
-int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
+int dev_manager_deactivate(struct dev_manager *dm, const struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { 0 };
 
@@ -2997,7 +2997,7 @@ int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
 	return 1;
 }
 
-int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
+int dev_manager_suspend(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required)
 {
 	dm->flush_required = flush_required;
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 9bdc413..8325bf9 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -26,7 +26,7 @@ struct dev_manager;
 struct dm_info;
 struct device;
 
-int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts);
+int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts);
 
 /*
  * Constructor and destructor.
@@ -76,14 +76,14 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 int dev_manager_thin_device_id(struct dev_manager *dm,
 			       const struct logical_volume *lv,
 			       uint32_t *device_id);
-int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
+int dev_manager_suspend(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
+int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,
 			 struct lv_activate_opts *laopts);
-int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
+int dev_manager_preload(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int *flush_required);
-int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
-int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv) __attribute__((nonnull(1, 2)));
+int dev_manager_deactivate(struct dev_manager *dm, const struct logical_volume *lv);
+int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *lv) __attribute__((nonnull(1, 2)));
 
 int dev_manager_mknodes(const struct logical_volume *lv);
 
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 7483044..66cb15f 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -468,8 +468,8 @@ int fs_del_lv_byname(const char *dev_dir, const char *vg_name,
 	return _fs_op(FS_DEL, dev_dir, vg_name, lv_name, "", "", check_udev);
 }
 
-int fs_rename_lv(struct logical_volume *lv, const char *dev, 
-		const char *old_vgname, const char *old_lvname)
+int fs_rename_lv(const struct logical_volume *lv, const char *dev,
+		 const char *old_vgname, const char *old_lvname)
 {
 	if (strcmp(old_vgname, lv->vg->name)) {
 		return
diff --git a/lib/activate/fs.h b/lib/activate/fs.h
index 9e433c8..fcbc4f1 100644
--- a/lib/activate/fs.h
+++ b/lib/activate/fs.h
@@ -27,7 +27,7 @@ int fs_add_lv(const struct logical_volume *lv, const char *dev);
 int fs_del_lv(const struct logical_volume *lv);
 int fs_del_lv_byname(const char *dev_dir, const char *vg_name,
 		     const char *lv_name, int check_udev);
-int fs_rename_lv(struct logical_volume *lv, const char *dev, 
+int fs_rename_lv(const struct logical_volume *lv, const char *dev,
 		 const char *old_vgname, const char *old_lvname);
 /* void fs_unlock(void);  moved to activate.h */
 uint32_t fs_get_cookie(void);
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index f2f4c80..800f33d 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -33,7 +33,7 @@
 #include <unistd.h>
 
 #ifndef CLUSTER_LOCKING_INTERNAL
-int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags, struct logical_volume *lv __attribute__((unused)));
+int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags, const struct logical_volume *lv __attribute__((unused)));
 int query_resource(const char *resource, int *mode);
 void locking_end(void);
 int locking_init(int type, struct dm_config_tree *cf, uint32_t *flags);
@@ -411,9 +411,9 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 /* API entry point for LVM */
 #ifdef CLUSTER_LOCKING_INTERNAL
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
-			  uint32_t flags, struct logical_volume *lv __attribute__((unused)))
+			  uint32_t flags, const struct logical_volume *lv __attribute__((unused)))
 #else
-	int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags, struct logical_volume *lv __attribute__((unused)))
+	int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags, const struct logical_volume *lv __attribute__((unused)))
 #endif
 {
 	char lockname[PATH_MAX];
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index bc597ff..430ff08 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -30,7 +30,7 @@ static int (*_init_fn) (int type, struct dm_config_tree * cft,
 static int (*_lock_query_fn) (const char *resource, int *mode) = NULL;
 
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
-			  uint32_t flags, struct logical_volume *lv __attribute__((unused)))
+			  uint32_t flags, const struct logical_volume *lv __attribute__((unused)))
 {
 	if (!_lock_fn)
 		return 0;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index e6def3f..5fd0ed3 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -42,7 +42,7 @@ static void _reset_file_locking(void)
 }
 
 static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
-			       uint32_t flags, struct logical_volume *lv)
+			       uint32_t flags, const struct logical_volume *lv)
 {
 	char lockfile[PATH_MAX];
 	unsigned origin_only = (flags & LCK_ORIGIN_ONLY) ? 1 : 0;
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 544751e..c88a85b 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -244,7 +244,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname)
  * FIXME This should become VG uuid.
  */
 static int _lock_vol(struct cmd_context *cmd, const char *resource,
-		     uint32_t flags, lv_operation_t lv_op, struct logical_volume *lv)
+		     uint32_t flags, lv_operation_t lv_op, const struct logical_volume *lv)
 {
 	uint32_t lck_type = flags & LCK_TYPE_MASK;
 	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
@@ -295,7 +295,7 @@ out:
 	return ret;
 }
 
-int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, struct logical_volume *lv)
+int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const struct logical_volume *lv)
 {
 	char resource[258] __attribute__((aligned(8)));
 	lv_operation_t lv_op;
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 1351cd2..c1affb4 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -49,7 +49,7 @@ int remote_lock_held(const char *vol, int *exclusive);
  *   Lock/unlock an individual logical volume
  *   char *vol holds lvid
  */
-int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, struct logical_volume *lv);
+int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const struct logical_volume *lv);
 
 /*
  * Internal locking representation.
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 5fa5cba..8280e4f 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -17,7 +17,7 @@
 #include "config.h"
 
 typedef int (*lock_resource_fn) (struct cmd_context * cmd, const char *resource,
-				 uint32_t flags, struct logical_volume *lv);
+				 uint32_t flags, const struct logical_volume *lv);
 typedef int (*query_resource_fn) (const char *resource, int *mode);
 
 typedef void (*fin_lock_fn) (void);
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index ab95933..b1dcb30 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -34,7 +34,7 @@ static void _no_reset_locking(void)
 }
 
 static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
-			     uint32_t flags, struct logical_volume *lv)
+			     uint32_t flags, const struct logical_volume *lv)
 {
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_ACTIVATION:
@@ -79,7 +79,7 @@ static int _no_query_resource(const char *resource, int *mode)
 
 static int _readonly_lock_resource(struct cmd_context *cmd,
 				   const char *resource,
-				   uint32_t flags, struct logical_volume *lv)
+				   uint32_t flags, const struct logical_volume *lv)
 {
 	if ((flags & LCK_TYPE_MASK) == LCK_WRITE &&
 	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 3a21f94..d43bc01 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -95,7 +95,7 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     enum activation_change activate);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
-struct logical_volume *lv_ondisk(struct logical_volume *lv);
+const struct logical_volume *lv_ondisk(const struct logical_volume *lv);
 struct profile *lv_config_profile(const struct logical_volume *lv);
 char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_mirror_image_in_sync(const struct logical_volume *lv);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4993c22..5787f5a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1065,7 +1065,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
-int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv);
+int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
@@ -1087,10 +1087,10 @@ struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
 int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs);
 void free_cmd_vgs(struct dm_list *cmd_vgs);
 
-int find_replicator_vgs(struct logical_volume *lv);
+int find_replicator_vgs(const struct logical_volume *lv);
 
-int lv_read_replicator_vgs(struct logical_volume *lv);
-void lv_release_replicator_vgs(struct logical_volume *lv);
+int lv_read_replicator_vgs(const struct logical_volume *lv);
+void lv_release_replicator_vgs(const struct logical_volume *lv);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint64_t lv_type);
@@ -1099,9 +1099,9 @@ struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 						  const char *name,
 						  const char *uuid,
 						  uint64_t lv_type);
-struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv);
-const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
-const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
+const struct logical_volume *find_pvmove_lv_in_lv(const struct logical_volume *lv);
+const char *get_pvmove_pvname_from_lv(const struct logical_volume *lv);
+const char *get_pvmove_pvname_from_lv_mirr(const struct logical_volume *lv_mirr);
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 354dc68..04d63eb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4805,7 +4805,7 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl)
 	return dm_pool_end_object(mem);
 }
 
-struct logical_volume *lv_ondisk(struct logical_volume *lv)
+const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 1206a1c..d89e5cd 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1504,7 +1504,7 @@ int remove_mirrors_from_segments(struct logical_volume *lv,
 	return 1;
 }
 
-const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr)
+const char *get_pvmove_pvname_from_lv_mirr(const struct logical_volume *lv_mirr)
 {
 	struct lv_segment *seg;
 
@@ -1523,9 +1523,9 @@ const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr)
 /*
  * Find first pvmove LV referenced by a segment of an LV.
  */
-struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv)
+const struct logical_volume *find_pvmove_lv_in_lv(const struct logical_volume *lv)
 {
-	struct lv_segment *seg;
+	const struct lv_segment *seg;
 	uint32_t s;
 
 	dm_list_iterate_items(seg, &lv->segments) {
@@ -1540,9 +1540,9 @@ struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv)
 	return NULL;
 }
 
-const char *get_pvmove_pvname_from_lv(struct logical_volume *lv)
+const char *get_pvmove_pvname_from_lv(const struct logical_volume *lv)
 {
-	struct logical_volume *pvmove_lv;
+	const struct logical_volume *pvmove_lv;
 
 	pvmove_lv = find_pvmove_lv_in_lv(lv);
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f494f11..c07de90 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1822,7 +1822,7 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 }
 
 /* Return 1 if a partial raid LV can be activated redundantly */
-static int _partial_raid_lv_is_redundant(struct logical_volume *lv)
+static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 {
 	struct lv_segment *raid_seg = first_seg(lv);
 	uint32_t copies;
@@ -1911,9 +1911,10 @@ static int _lv_may_be_activated_in_degraded_mode(struct logical_volume *lv, void
 	return 1;
 }
 
-int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv)
+int partial_raid_lv_supports_degraded_activation(const struct logical_volume *clv)
 {
 	int not_capable = 0;
+	struct logical_volume * lv = (struct logical_volume *)clv; /* drop const */
 
 	if (!_lv_may_be_activated_in_degraded_mode(lv, &not_capable) || not_capable)
 		return_0;
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index f264c7c..54dc759 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -600,7 +600,7 @@ void free_cmd_vgs(struct dm_list *cmd_vgs)
  * Find all needed remote VGs for processing given LV.
  * Missing VGs are added to VG's cmd_vg list and flag cmd_missing_vgs is set.
  */
-int find_replicator_vgs(struct logical_volume *lv)
+int find_replicator_vgs(const struct logical_volume *lv)
 {
 	struct replicator_site *rsite;
 	int ret = 1;
@@ -632,7 +632,7 @@ int find_replicator_vgs(struct logical_volume *lv)
  * Read all remote VGs from lv's replicator sites.
  * Function is used in activation context and needs all VGs already locked.
  */
-int lv_read_replicator_vgs(struct logical_volume *lv)
+int lv_read_replicator_vgs(const struct logical_volume *lv)
 {
 	struct replicator_device *rdev;
 	struct replicator_site *rsite;
@@ -670,7 +670,7 @@ bad:
  * Release all VG resources taken by lv's replicator sites.
  * Function is used in activation context and needs all VGs already locked.
  */
-void lv_release_replicator_vgs(struct logical_volume *lv)
+void lv_release_replicator_vgs(const struct logical_volume *lv)
 {
 	struct replicator_site *rsite;
 
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
index 78ea783..89c3aae 100644
--- a/tools/polldaemon.h
+++ b/tools/polldaemon.h
@@ -28,7 +28,7 @@ typedef enum {
 struct daemon_parms;
 
 struct poll_functions {
-	const char *(*get_copy_name_from_lv) (struct logical_volume *lv);
+	const char *(*get_copy_name_from_lv) (const struct logical_volume *lv);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
 					     const char *name,
 					     const char *uuid);


