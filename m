From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Apr 2010 14:16:34 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20100423141634.513.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-23 14:16:33

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/misc       : lvm-string.c lvm-string.h 
	tools          : toollib.c 

Log message:
	Set appropriate udev flags for reserved LVs.
	
	There's no need for foreign udev rules to touch LVM reserved devices
	(snapshot, pvmove, _mlog, _mimage, _vorigin) even if they happen to
	be visible. The same applies for /dev/disk content - no need to create
	any content for these devices (and so no need to run any "blkid" etc.).
	This also prevents setting any inotify "watch" from udev rules on such
	devices that is a source of race conditions (the rules need to honor
	DM_UDEV_DISABLE_OTHER_RULES_FLAG for this to work though).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1535&r2=1.1536
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.194&r2=1.195

--- LVM2/WHATS_NEW	2010/04/23 02:57:39	1.1535
+++ LVM2/WHATS_NEW	2010/04/23 14:16:32	1.1536
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Set appropriate udev flags for reserved LVs.
   Don't preload the origin when removing a snapshot whose merge is pending.
   Disallow the addition of mirror images while a conversion is happening.
   Disallow primary mirror image removal when mirror is not in-sync.
--- LVM2/lib/activate/dev_manager.c	2010/04/23 02:57:41	1.186
+++ LVM2/lib/activate/dev_manager.c	2010/04/23 14:16:33	1.187
@@ -751,12 +751,55 @@
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
+	 * naming deterministic (e.g. symlinks in /dev/disk/by-uuid).
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
@@ -794,20 +837,8 @@
 		}
 	}
 
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
-	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major,
-							    info.minor, udev_flags)) {
+	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major, info.minor,
+							_get_udev_flags(dm, lv, layer))) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
 			  info.major, info.minor);
 		return 0;
@@ -1164,7 +1195,6 @@
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
-	uint16_t udev_flags = 0;
 
 	/* FIXME Seek a simpler way to lay out the snapshot-merge tree. */
 
@@ -1205,18 +1235,6 @@
 
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
@@ -1229,7 +1247,7 @@
 					     _read_only_lv(lv),
 					     (lv->vg->status & PRECOMMITTED) ? 1 : 0,
 					     lvlayer,
-					     udev_flags)))
+					     _get_udev_flags(dm, lv, layer))))
 		return_0;
 
 	/* Store existing name so we can do rename later */
--- LVM2/lib/misc/lvm-string.c	2010/04/14 13:01:43	1.19
+++ LVM2/lib/misc/lvm-string.c	2010/04/23 14:16:33	1.20
@@ -242,3 +242,49 @@
 
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
--- LVM2/lib/misc/lvm-string.h	2010/04/14 13:01:43	1.19
+++ LVM2/lib/misc/lvm-string.h	2010/04/23 14:16:33	1.20
@@ -34,6 +34,9 @@
 
 int validate_name(const char *n);
 
+int apply_lvname_restrictions(const char *name);
+int is_reserved_lvname(const char *name);
+
 /*
  * Returns number of occurrences of c in first len characters of str.
  */
--- LVM2/tools/toollib.c	2010/04/14 02:19:49	1.194
+++ LVM2/tools/toollib.c	2010/04/23 14:16:33	1.195
@@ -1125,52 +1125,6 @@
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


