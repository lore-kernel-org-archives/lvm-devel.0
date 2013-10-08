From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  8 Oct 2013 11:43:59 +0000 (UTC)
Subject: master - activation: add support for flagging an LV to skip udev scanning during activation
Message-ID: <20131008114359.725B161439@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce7489ed228da22c2a355d0b403a1e5dc6d8c0e0
Commit:        ce7489ed228da22c2a355d0b403a1e5dc6d8c0e0
Parent:        273373bf53b34817481ef2c395c84a7cdf4f1998
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 8 13:27:21 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 8 13:43:14 2013 +0200

activation: add support for flagging an LV to skip udev scanning during activation

A common scenario is during new LV creation when we need to wipe the
newly created LV and avoid any udev scanning before this stage otherwise
it could cause the device (the LV) to be claimed by some other subsystem
for which there were stale metadata within LV data.

This patch adds possibility to mark the LV we're just about to wipe with
a flag that gets passed to udev via DM_COOKIE as a subsystem specific
flag - DM_SUBSYSTEM_UDEV_FLAG0 (in this case the subsystem is "LVM")
so LVM udev rules will take care of handling that.
---
 WHATS_NEW                        |    1 +
 daemons/clvmd/lvm-functions.c    |    2 +-
 lib/activate/activate.c          |   20 ++++++++++++--------
 lib/activate/activate.h          |    5 +++--
 lib/activate/dev_manager.c       |   15 +++++++++++----
 lib/locking/file_locking.c       |    4 ++--
 lib/locking/no_locking.c         |    4 ++--
 lib/metadata/lv_manip.c          |    6 ++++++
 lib/metadata/metadata-exported.h |    1 +
 9 files changed, 39 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cd9f00a..098f348 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Add support for flagging an LV to skip udev scanning during activation.
   Improve message when unable to change discards setting on active thin pool.
   Run full scan before vgrename operation to avoid any cache name collision.
   Fix lvconvert when converting to a thin pool and thin LV at once.
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index da7d335..f544218 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -401,7 +401,7 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
 	}
 
 	/* Now activate it */
-	if (!lv_activate(cmd, resource, exclusive, NULL))
+	if (!lv_activate(cmd, resource, exclusive, 0, NULL))
 		goto error;
 
 	return 0;
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 28549fc..c077113 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -337,12 +337,13 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 {
 	return 1;
 }
-int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv)
+int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, int noscan,
+		struct logical_volume *lv)
 {
 	return 1;
 }
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-			    struct logical_volume *lv)
+			    int noscan, struct logical_volume *lv)
 {
 	return 1;
 }
@@ -2027,9 +2028,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (filter)
 		laopts->read_only = _passes_readonly_filter(cmd, lv);
 
-	log_debug_activation("Activating %s/%s%s%s.", lv->vg->name, lv->name,
+	log_debug_activation("Activating %s/%s%s%s%s.", lv->vg->name, lv->name,
 			     laopts->exclusive ? " exclusively" : "",
-			     laopts->read_only ? " read-only" : "");
+			     laopts->read_only ? " read-only" : "",
+			     laopts->noscan ? " noscan" : "");
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
@@ -2066,9 +2068,10 @@ out:
 }
 
 /* Activate LV */
-int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv)
+int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive,
+		int noscan, struct logical_volume *lv)
 {
-	struct lv_activate_opts laopts = { .exclusive = exclusive };
+	struct lv_activate_opts laopts = { .exclusive = exclusive, .noscan = noscan };
 
 	if (!_lv_activate(cmd, lvid_s, &laopts, 0, lv))
 		return_0;
@@ -2077,9 +2080,10 @@ int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, stru
 }
 
 /* Activate LV only if it passes filter */
-int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv)
+int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
+			    int noscan, struct logical_volume *lv)
 {
-	struct lv_activate_opts laopts = { .exclusive = exclusive };
+	struct lv_activate_opts laopts = { .exclusive = exclusive, .noscan = noscan  };
 
 	if (!_lv_activate(cmd, lvid_s, &laopts, 1, lv))
 		return_0;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index f34d376..4eac320 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -38,6 +38,7 @@ struct lv_activate_opts {
 	int skip_in_use;
 	unsigned revert;
 	unsigned read_only;
+	unsigned noscan;
 };
 
 /* target attribute flags */
@@ -80,9 +81,9 @@ int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned o
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive, unsigned revert, struct logical_volume *lv);
-int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv);
+int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, int noscan, struct logical_volume *lv);
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s,
-			    int exclusive, struct logical_volume *lv);
+			    int exclusive, int noscan, struct logical_volume *lv);
 int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv);
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b8233bf..0f5a04c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -30,6 +30,7 @@
 #include <dirent.h>
 
 #define MAX_TARGET_PARAMSIZE 50000
+#define LVM_UDEV_NOSCAN_FLAG DM_SUBSYSTEM_UDEV_FLAG0
 
 typedef enum {
 	PRELOAD,
@@ -1399,7 +1400,7 @@ static int _check_udev_fallback(struct cmd_context *cmd)
 #endif /* UDEV_SYNC_SUPPORT */
 
 static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *lv,
-				const char *layer)
+				const char *layer, uint16_t flags)
 {
 	uint16_t udev_flags = 0;
 
@@ -1447,6 +1448,11 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *l
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
+	/*
+	 * Firmly set requested flags.
+	 */
+	udev_flags |= flags;
+
 	return udev_flags;
 }
 
@@ -1493,7 +1499,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major, info.minor,
-							_get_udev_flags(dm, lv, layer))) {
+							_get_udev_flags(dm, lv, layer, 0))) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
 			  info.major, info.minor);
 		return 0;
@@ -2334,7 +2340,7 @@ static int _set_udev_flags_for_children(struct dev_manager *dm,
 		}
 
 		dm_tree_node_set_udev_flags(child,
-					    _get_udev_flags(dm, lvl->lv, NULL));
+					    _get_udev_flags(dm, lvl->lv, NULL, 0));
 	}
 
 	return 1;
@@ -2411,7 +2417,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 					     read_only_lv(lv, laopts),
 					     ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
 					     lvlayer,
-					     _get_udev_flags(dm, lv, layer))))
+					     _get_udev_flags(dm, lv, layer,
+						laopts->noscan ? LVM_UDEV_NOSCAN_FLAG : 0))))
 		return_0;
 
 	/* Store existing name so we can do rename later */
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 5e49bc4..b6b2b10 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -305,7 +305,7 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_READ:
 			log_very_verbose("Locking LV %s (R)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 0, lv_ondisk(lv)))
+			if (!lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv)))
 				return 0;
 			break;
 		case LCK_PREAD:
@@ -318,7 +318,7 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_EXCL:
 			log_very_verbose("Locking LV %s (EX)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 1, lv_ondisk(lv)))
+			if (!lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv)))
 				return 0;
 			break;
 		default:
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 5f3f0b6..4772706 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -48,11 +48,11 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 		case LCK_UNLOCK:
 			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0, lv_ondisk(lv));
 		case LCK_READ:
-			return lv_activate_with_filter(cmd, resource, 0, lv_ondisk(lv));
+			return lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv));
 		case LCK_WRITE:
 			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0, lv_ondisk(lv), lv);
 		case LCK_EXCL:
-			return lv_activate_with_filter(cmd, resource, 1, lv_ondisk(lv));
+			return lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv));
 		default:
 			break;
 		}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f42db1d..22327d7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5421,6 +5421,8 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!dev_close_immediate(dev))
 		stack;
 
+	lv->status &= ~LV_NOSCAN;
+
 	return 1;
 }
 
@@ -5977,6 +5979,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		goto out;
 	}
 
+	/* Do not scan this LV until properly zeroed. */
+	if (lp->zero)
+		lv->status |= LV_NOSCAN;
+
 	if (lv_is_thin_pool(lv)) {
 		if (is_change_activating(lp->activate)) {
 			if (vg_is_clustered(lv->vg)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 308dcfe..1e9543a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -102,6 +102,7 @@
 #define LV_WRITEMOSTLY		UINT64_C(0x0000020000000000)	/* LV (RAID1) */
 
 #define LV_ACTIVATION_SKIP	UINT64_C(0x0000040000000000)	/* LV */
+#define LV_NOSCAN		UINT64_C(0x0000080000000000)	/* LV */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */


