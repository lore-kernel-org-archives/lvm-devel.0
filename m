From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 23 Oct 2013 12:10:12 +0000 (UTC)
Subject: master - activation: flag temporary LVs internally
Message-ID: <20131023121012.726A260F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=039bdad732cd6c0d96b5b8c2c6c7beb528cf338a
Commit:        039bdad732cd6c0d96b5b8c2c6c7beb528cf338a
Parent:        1dd6626696b100c8cf176921917418bb8d7f8055
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 23 14:06:39 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 23 14:09:37 2013 +0200

activation: flag temporary LVs internally

Add LV_TEMPORARY flag for LVs with limited existence during command
execution. Such LVs are temporary in way that they need to be activated,
some action done and then removed immediately. Such LVs are just like
any normal LV - the only difference is that they are removed during
LVM command execution. This is also the case for LVs representing
future pool metadata spare LVs which we need to initialize by using
the usual LV before they are declared as pool metadata spare.

We can optimize some other parts like udev to do a better job if
it knows that the LV is temporary and any processing on it is just
useless.

This flag is orthogonal to LV_NOSCAN flag introduced recently
as LV_NOSCAN flag is primarily used to mark an LV for the scanning
to be avoided before the zeroing of the device happens. The LV_TEMPORARY
flag makes a difference between a full-fledged LV visible in the system
and the LV just used as a temporary overlay for some action that needs to
be done on underlying PVs.

For example: lvcreate --thinpool POOL --zero n -L 1G vg

- first, the usual LV is created to do a clean up for pool metadata
  spare. The LV is activated, zeroed, deactivated.

- between "activated" and "zeroed" stage, the LV_NOSCAN flag is used
  to avoid any scanning in udev

- betwen "zeroed" and "deactivated" stage, we need to avoid the WATCH
  udev rule, but since the LV is just a usual LV, we can't make a
  difference. The LV_TEMPORARY internal LV flag helps here. If we
  create the LV with this flag, the DM_UDEV_DISABLE_DISK_RULES
  and DM_UDEV_DISABLE_OTHER_RULES flag are set (just like as it is
  with "invisible" and non-top-level LVs) - udev is directed to
  skip WATCH rule use.

- if the LV_TEMPORARY flag was not used, there would normally be
  a WATCH event generated once the LV is closed after "zeroed"
  stage. This will make problems with immediated deactivation that
  follows.
---
 WHATS_NEW                        |    1 +
 daemons/clvmd/lvm-functions.c    |    2 +-
 lib/activate/activate.c          |   21 +++++++++++++--------
 lib/activate/activate.h          |   20 ++++++++++++++++----
 lib/activate/dev_manager.c       |   18 +++++++++++-------
 lib/format_text/flags.c          |    1 +
 lib/locking/file_locking.c       |    6 ++++--
 lib/locking/no_locking.c         |    6 ++++--
 lib/metadata/lv_manip.c          |    3 +++
 lib/metadata/metadata-exported.h |    8 +++++++-
 lib/metadata/thin_manip.c        |    1 +
 11 files changed, 62 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7cfa87c..49f37a4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Add internal flag for temporary LVs to properly direct udev to not interfere.
   Fix endless loop in blkdeactivate <device>... if unable to umount/deactivate.
   Add dev-block-<major>:<minor>.device systemd alias for complete PV tracking.
   Use major:minor as short form of --major and --minor arg for pvscan --cache.
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index f544218..b15732f 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -401,7 +401,7 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
 	}
 
 	/* Now activate it */
-	if (!lv_activate(cmd, resource, exclusive, 0, NULL))
+	if (!lv_activate(cmd, resource, exclusive, 0, 0, NULL))
 		goto error;
 
 	return 0;
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 131a093..006681e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -338,12 +338,12 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 	return 1;
 }
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, int noscan,
-		struct logical_volume *lv)
+		int temporary, struct logical_volume *lv)
 {
 	return 1;
 }
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-			    int noscan, struct logical_volume *lv)
+			    int noscan, int temporary, struct logical_volume *lv)
 {
 	return 1;
 }
@@ -2055,10 +2055,11 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (filter)
 		laopts->read_only = _passes_readonly_filter(cmd, lv);
 
-	log_debug_activation("Activating %s/%s%s%s%s.", lv->vg->name, lv->name,
+	log_debug_activation("Activating %s/%s%s%s%s%s.", lv->vg->name, lv->name,
 			     laopts->exclusive ? " exclusively" : "",
 			     laopts->read_only ? " read-only" : "",
-			     laopts->noscan ? " noscan" : "");
+			     laopts->noscan ? " noscan" : "",
+			     laopts->temporary ? " temporary" : "");
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
@@ -2096,9 +2097,11 @@ out:
 
 /* Activate LV */
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-		int noscan, struct logical_volume *lv)
+		int noscan, int temporary, struct logical_volume *lv)
 {
-	struct lv_activate_opts laopts = { .exclusive = exclusive, .noscan = noscan };
+	struct lv_activate_opts laopts = { .exclusive = exclusive,
+					   .noscan = noscan,
+					   .temporary = temporary };
 
 	if (!_lv_activate(cmd, lvid_s, &laopts, 0, lv))
 		return_0;
@@ -2108,9 +2111,11 @@ int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive,
 
 /* Activate LV only if it passes filter */
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
-			    int noscan, struct logical_volume *lv)
+			    int noscan, int temporary, struct logical_volume *lv)
 {
-	struct lv_activate_opts laopts = { .exclusive = exclusive, .noscan = noscan  };
+	struct lv_activate_opts laopts = { .exclusive = exclusive,
+					   .noscan = noscan,
+					   .temporary = temporary };
 
 	if (!_lv_activate(cmd, lvid_s, &laopts, 1, lv))
 		return_0;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 4eac320..df888cd 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -38,7 +38,18 @@ struct lv_activate_opts {
 	int skip_in_use;
 	unsigned revert;
 	unsigned read_only;
-	unsigned noscan;
+	unsigned noscan;	/* Mark this LV to avoid its scanning. This also
+				   directs udev to use proper udev flag to avoid
+				   any scanning in udev. This udev flag is automatically
+				   dropped in udev db on any spurious event that follows. */
+	unsigned temporary;	/* Mark this LV as temporary. It means, the LV
+				 * is created, used and deactivated within single
+				 * LVM command execution. Such LVs are mostly helper
+				 * LVs to do some action or cleanup before the proper
+				 * LV is created. This also directs udev to use proper
+				 * set of flags to avoid any scanning in udev. These udev
+				 * flags are persistent in udev db for any spurious event
+				 * that follows. */
 };
 
 /* target attribute flags */
@@ -81,9 +92,10 @@ int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned o
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive, unsigned revert, struct logical_volume *lv);
-int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, int noscan, struct logical_volume *lv);
-int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s,
-			    int exclusive, int noscan, struct logical_volume *lv);
+int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive,
+		int noscan, int temporary, struct logical_volume *lv);
+int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
+			    int noscan, int temporary, struct logical_volume *lv);
 int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv);
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 0f5a04c..0b911f2 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1400,7 +1400,7 @@ static int _check_udev_fallback(struct cmd_context *cmd)
 #endif /* UDEV_SYNC_SUPPORT */
 
 static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *lv,
-				const char *layer, uint16_t flags)
+				const char *layer, int noscan, int temporary)
 {
 	uint16_t udev_flags = 0;
 
@@ -1449,9 +1449,14 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *l
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
 	/*
-	 * Firmly set requested flags.
+	 * LVM subsystem specific flags.
 	 */
-	udev_flags |= flags;
+	if (noscan)
+		udev_flags |= DM_SUBSYSTEM_UDEV_FLAG0;
+
+	if (temporary)
+		udev_flags |= DM_UDEV_DISABLE_DISK_RULES_FLAG |
+			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
 
 	return udev_flags;
 }
@@ -1499,7 +1504,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major, info.minor,
-							_get_udev_flags(dm, lv, layer, 0))) {
+							_get_udev_flags(dm, lv, layer, 0, 0))) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
 			  info.major, info.minor);
 		return 0;
@@ -2340,7 +2345,7 @@ static int _set_udev_flags_for_children(struct dev_manager *dm,
 		}
 
 		dm_tree_node_set_udev_flags(child,
-					    _get_udev_flags(dm, lvl->lv, NULL, 0));
+					    _get_udev_flags(dm, lvl->lv, NULL, 0, 0));
 	}
 
 	return 1;
@@ -2417,8 +2422,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 					     read_only_lv(lv, laopts),
 					     ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
 					     lvlayer,
-					     _get_udev_flags(dm, lv, layer,
-						laopts->noscan ? LVM_UDEV_NOSCAN_FLAG : 0))))
+					     _get_udev_flags(dm, lv, layer, laopts->noscan, laopts->temporary))))
 		return_0;
 
 	/* Store existing name so we can do rename later */
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a27b791..e31429e 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -62,6 +62,7 @@ static const struct flag _lv_flags[] = {
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_NOSCAN, NULL, 0},
+	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index b6b2b10..ab3dabd 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -305,7 +305,8 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_READ:
 			log_very_verbose("Locking LV %s (R)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv)))
+			if (!lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0,
+						     lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv)))
 				return 0;
 			break;
 		case LCK_PREAD:
@@ -318,7 +319,8 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_EXCL:
 			log_very_verbose("Locking LV %s (EX)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv)))
+			if (!lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0,
+						     lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv)))
 				return 0;
 			break;
 		default:
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 4772706..dac2f80 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -48,11 +48,13 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 		case LCK_UNLOCK:
 			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0, lv_ondisk(lv));
 		case LCK_READ:
-			return lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv));
+			return lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0,
+						       lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv));
 		case LCK_WRITE:
 			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0, lv_ondisk(lv), lv);
 		case LCK_EXCL:
-			return lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0, lv_ondisk(lv));
+			return lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0,
+						       lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv));
 		default:
 			break;
 		}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 383bab1..88fceb2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5987,6 +5987,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lp->zero)
 		lv->status |= LV_NOSCAN;
 
+	if (lp->temporary)
+		lv->status |= LV_TEMPORARY;
+
 	if (lv_is_thin_pool(lv)) {
 		if (is_change_activating(lp->activate)) {
 			if (vg_is_clustered(lv->vg)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1e9543a..c00e4e5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -102,7 +102,12 @@
 #define LV_WRITEMOSTLY		UINT64_C(0x0000020000000000)	/* LV (RAID1) */
 
 #define LV_ACTIVATION_SKIP	UINT64_C(0x0000040000000000)	/* LV */
-#define LV_NOSCAN		UINT64_C(0x0000080000000000)	/* LV */
+#define LV_NOSCAN		UINT64_C(0x0000080000000000)	/* LV - internal use only - the LV
+									should not be scanned */
+#define LV_TEMPORARY		UINT64_C(0x0000100000000000)	/* LV - internal use only - the LV
+								        is supposed to be created and
+									removed during single LVM
+									command execution. */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -721,6 +726,7 @@ struct lvcreate_params {
 	int log_count; /* mirror */
 	int nosync; /* mirror */
 	int poolmetadataspare; /* thin pool */
+	int temporary; /* temporary LV */
 #define ACTIVATION_SKIP_SET		0x01 /* request to set LV activation skip flag state */
 #define ACTIVATION_SKIP_SET_ENABLED	0x02 /* set the LV activation skip flag state to 'enabled' */
 #define ACTIVATION_SKIP_IGNORE		0x04 /* request to ignore LV activation skip flag (if any) */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index a6e0fc2..bd5b117 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -809,6 +809,7 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 		.stripes = 1,
 		.vg_name = vg->name,
 		.zero = 1,
+		.temporary = 1,
 	};
 
 	dm_list_init(&lp.tags);


