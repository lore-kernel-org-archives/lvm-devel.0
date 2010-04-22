From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 22 Apr 2010 14:25:33 +0200
Subject: [PATCH] Set appropriate udev flags for reserved LVs
Message-ID: <4BD0403D.1070203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've run into a problem while creating mirrors lately. The _mlog
device is set visible for a while during initialisation and that
made it possible for all foreign udev rules to be applied (since
it was set visible for a while, it didn't have the
DM_UDEV_DISABLE_OTHER_RULES_FLAG set).

The "watch" rule that is in udisks' rules was applied and set the
inotify watch on the _mlog. Then, we tried to wipe the _mlog as part
of the initialisation process and then close it after that. But
closing a device once opened rw fires the inotify watch, generating
one of the "superb" artifical events we can't synchronize with.
Hence fires the udev rules in return letting all of them to touch
the device.

In the meantime, we're trying to deactivate the _mlog device, but
there is quite a big chance we will hit a race ending up with:

"LV ... in use: not deactivating
 Aborting. Failed to deactivate mirror log. Manual intervention required.
 Failed to initialise mirror log."

...and failing the whole operation afterwards.

This patch just adds:

	else if (is_reserved_lvname(lv->name))
		udev_flags |= DM_UDEV_DISABLE_DISK_RULES_FLAG |
			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;

There's no need for other rules to touch such devices from udev rules
(snapshot, pvmove, _mlog, _mimage, _vorigin). The same applies for
/dev/disk content - no need to create any content for these devices
(and so no need to run any "blkid" etc.). This also prevents to set
any "watch" on such devices.

Normally, these devices would be flagged invisible, but there are
some cases we need to set them visible for a while (that applies
for the _mlog mainly, but let's generalize this).

The other part of the patch is just a little refactoring, creating
the "_get_udev_flags" fn (the code was repeated at 2 places) and
also moving "is_reserved_lvname" and "apply_lvname_restrictions"
from toollib.c to a more general lvm-string.c so it can be used widely.

Peter
---
 lib/activate/dev_manager.c |   75 +++++++++++++++++++++++++++----------------
 lib/misc/lvm-string.c      |   46 +++++++++++++++++++++++++++
 lib/misc/lvm-string.h      |    3 ++
 tools/toollib.c            |   46 ---------------------------
 4 files changed, 96 insertions(+), 74 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 66cc94c..132672d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -753,12 +753,55 @@ int dev_manager_mknodes(const struct logical_volume *lv)
 	return r;
 }
 
+static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *lv,
+				const char *layer)
+{
+	uint16_t udev_flags = 0;
+
+	/*
+	 * Is this top-level and visible device?
+	 * If not, create just the /dev/mapper content.
+	 */
+	if (layer || !lv_is_visible(lv))
+		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
+			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
+			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
+	/*
+	 * There's no need for other udev rules to touch special LVs with
+	 * reserved names. We don't need to populate /dev/disk here either.
+	 * Even if they happen to be visible and top-level.
+	 */
+	else if (is_reserved_lvname(lv->name))
+		udev_flags |= DM_UDEV_DISABLE_DISK_RULES_FLAG |
+			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
+
+	/*
+	 * Snapshots and origins could have the same rule applied that will
+	 * give symlinks exactly the same name (e.g. a name based on
+	 * filesystem UUID). We give preference to origins to make such
+	 * naming deterministic (e.g. /dev/disk/by-uuid).
+	 */
+	if (lv_is_cow(lv))
+		udev_flags |= DM_UDEV_LOW_PRIORITY_FLAG;
+
+	/*
+	 * Finally, add flags to disable /dev/mapper and /dev/<vgname> content
+	 * to be created by udev if it is requested by user's configuration.
+	 * This is basically an explicit fallback to old node/symlink creation
+	 * without udev.
+	 */
+	if (!dm->cmd->current_settings.udev_rules)
+		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
+			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
+
+	return udev_flags;
+}
+
 static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			       struct logical_volume *lv, const char *layer)
 {
 	char *dlid, *name;
 	struct dm_info info, info2;
-	uint16_t udev_flags = 0;
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -796,20 +839,9 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		}
 	}
 
-	if (layer || !lv_is_visible(lv))
-		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
-			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
-			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
 
-	if (lv_is_cow(lv))
-		udev_flags |= DM_UDEV_LOW_PRIORITY_FLAG;
-
-	if (!dm->cmd->current_settings.udev_rules)
-		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
-			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
-
-	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major,
-							    info.minor, udev_flags)) {
+	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major, info.minor,
+							_get_udev_flags(dm, lv, layer))) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
 			  info.major, info.minor);
 		return 0;
@@ -1166,7 +1198,6 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
-	uint16_t udev_flags = 0;
 
 	/* FIXME Seek a simpler way to lay out the snapshot-merge tree. */
 
@@ -1207,18 +1238,6 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	lvlayer->lv = lv;
 
-	if (layer || !lv_is_visible(lv))
-		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
-			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
-			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
-
-	if (lv_is_cow(lv))
-		udev_flags |= DM_UDEV_LOW_PRIORITY_FLAG;
-
-	if (!dm->cmd->current_settings.udev_rules)
-		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
-			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
-
 	/*
 	 * Add LV to dtree.
 	 * If we're working with precommitted metadata, clear any
@@ -1231,7 +1250,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 					     _read_only_lv(lv),
 					     (lv->vg->status & PRECOMMITTED) ? 1 : 0,
 					     lvlayer,
-					     udev_flags)))
+					     _get_udev_flags(dm, lv, layer))))
 		return_0;
 
 	/* Store existing name so we can do rename later */
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index f79c8b0..7eed799 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -242,3 +242,49 @@ int validate_name(const char *n)
 
 	return 1;
 }
+
+int apply_lvname_restrictions(const char *name)
+{
+	if (!strncmp(name, "snapshot", 8)) {
+		log_error("Names starting \"snapshot\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (!strncmp(name, "pvmove", 6)) {
+		log_error("Names starting \"pvmove\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (strstr(name, "_mlog")) {
+		log_error("Names including \"_mlog\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (strstr(name, "_mimage")) {
+		log_error("Names including \"_mimage\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (strstr(name, "_vorigin")) {
+		log_error("Names including \"_vorigin\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	return 1;
+}
+
+int is_reserved_lvname(const char *name)
+{
+	int rc, old_suppress;
+
+	old_suppress = log_suppress(2);
+	rc = !apply_lvname_restrictions(name);
+	log_suppress(old_suppress);
+
+	return rc;
+}
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index d5e5449..35d9245 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -34,6 +34,9 @@ char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
 
 int validate_name(const char *n);
 
+int apply_lvname_restrictions(const char *name);
+int is_reserved_lvname(const char *name);
+
 /*
  * Returns number of occurrences of c in first len characters of str.
  */
diff --git a/tools/toollib.c b/tools/toollib.c
index 81e81fa..475e90e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1125,52 +1125,6 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 	return r;
 }
 
-int apply_lvname_restrictions(const char *name)
-{
-	if (!strncmp(name, "snapshot", 8)) {
-		log_error("Names starting \"snapshot\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (!strncmp(name, "pvmove", 6)) {
-		log_error("Names starting \"pvmove\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_mlog")) {
-		log_error("Names including \"_mlog\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_mimage")) {
-		log_error("Names including \"_mimage\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_vorigin")) {
-		log_error("Names including \"_vorigin\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	return 1;
-}
-
-int is_reserved_lvname(const char *name)
-{
-	int rc, old_suppress;
-
-	old_suppress = log_suppress(2);
-	rc = !apply_lvname_restrictions(name);
-	log_suppress(old_suppress);
-
-	return rc;
-}
-
 void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 				  struct volume_group *vg)
 {


