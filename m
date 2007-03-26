From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Mar 2007 16:10:14 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c tools/l ...
Message-ID: <20070326161014.12892.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-03-26 17:10:11

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 
	tools          : lvconvert.c lvcreate.c toollib.c toollib.h 

Log message:
	Fix creation and conversion of mirrors with tags.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.591&r2=1.592
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2007/03/23 12:43:17	1.591
+++ LVM2/WHATS_NEW	2007/03/26 16:10:09	1.592
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Fix creation and conversion of mirrors with tags.
   Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
   Split metadata areas in vgsplit properly.
 
--- LVM2/lib/metadata/mirror.c	2006/11/30 17:52:47	1.37
+++ LVM2/lib/metadata/mirror.c	2007/03/26 16:10:10	1.38
@@ -21,6 +21,7 @@
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
+#include "str_list.h"
 #include "locking.h"	/* FIXME Should not be used in this file */
 
 #include "defaults.h" /* FIXME: should this be defaults.h? */
@@ -77,6 +78,42 @@
 	lv_from->size = 0;
 }
 
+
+/*
+ * Delete independent/orphan LV, it must acquire lock.
+ */
+static int _delete_lv(struct lv_segment *mirrored_seg, struct logical_volume *lv)
+{
+	struct cmd_context *cmd = mirrored_seg->lv->vg->cmd;
+	struct str_list *sl;
+
+	/* Inherit tags - maybe needed for activation */
+	if (!str_list_match_list(&mirrored_seg->lv->tags, &lv->tags)) {
+		list_iterate_items(sl, &mirrored_seg->lv->tags)
+			if (!str_list_add(cmd->mem, &lv->tags, sl->str)) {
+				log_error("Aborting. Unable to tag.");
+				return 0;
+			}
+
+		if (!vg_write(mirrored_seg->lv->vg) ||
+		    !vg_commit(mirrored_seg->lv->vg)) {
+			log_error("Intermediate VG commit for orphan volume failed.");
+			return 0;
+		}
+	}
+
+	if (!activate_lv(cmd, lv))
+		return_0;
+
+	if (!deactivate_lv(cmd, lv))
+		return_0;
+
+	if (!lv_remove(lv))
+		return_0;
+
+	return 1;
+}
+
 /*
  * Reduce mirrored_seg to num_mirrors images.
  */
@@ -205,57 +242,15 @@
 	}
 
 	/* Delete the 'orphan' LVs */
-	for (m = num_mirrors; m < old_area_count; m++) {
-		/* LV is now independent of the mirror so must acquire lock. */
-		if (!activate_lv(mirrored_seg->lv->vg->cmd, seg_lv(mirrored_seg, m))) {
-			stack;
-			return 0;
-		}
-
-		if (!deactivate_lv(mirrored_seg->lv->vg->cmd, seg_lv(mirrored_seg, m))) {
-			stack;
-			return 0;
-		}
-
-		if (!lv_remove(seg_lv(mirrored_seg, m))) {
-			stack;
-			return 0;
-		}
-	}
-
-	if (lv1) {
-		if (!activate_lv(mirrored_seg->lv->vg->cmd, lv1)) {
-			stack;
-			return 0;
-		}
-
-		if (!deactivate_lv(mirrored_seg->lv->vg->cmd, lv1)) {
-			stack;
+	for (m = num_mirrors; m < old_area_count; m++)
+		if (!_delete_lv(mirrored_seg, seg_lv(mirrored_seg, m)))
 			return 0;
-		}
-
-		if (!lv_remove(lv1)) {
-			stack;
-			return 0;
-		}
-	}
 
-	if (log_lv) {
-		if (!activate_lv(mirrored_seg->lv->vg->cmd, log_lv)) {
-			stack;
-			return 0;
-		}
-
-		if (!deactivate_lv(mirrored_seg->lv->vg->cmd, log_lv)) {
-			stack;
-			return 0;
-		}
+	if (lv1 && !_delete_lv(mirrored_seg, lv1))
+		return 0;
 
-		if (!lv_remove(log_lv)) {
-			stack;
-			return 0;
-		}
-	}
+	if (log_lv && !_delete_lv(mirrored_seg, log_lv))
+		return 0;
 
 	return 1;
 }
--- LVM2/tools/lvconvert.c	2007/01/10 14:13:46	1.25
+++ LVM2/tools/lvconvert.c	2007/03/26 16:10:10	1.26
@@ -307,7 +307,7 @@
 					if (!(log_lv = create_mirror_log(cmd, lv->vg, ah,
 									 lp->alloc, lv->name,
 									 (sync_percent >= 100.0) ?
-									 1 : 0))) {
+									 1 : 0, &lv->tags))) {
 						log_error("Failed to create mirror log.");
 						return 0;
 					}
@@ -385,7 +385,7 @@
 			if (!arg_count(cmd, corelog_ARG) &&
 			    !(log_lv = create_mirror_log(cmd, lv->vg, ah,
 							 lp->alloc,
-							 lv->name, 0))) {
+							 lv->name, 0, &lv->tags))) {
 				log_error("Failed to create mirror log.");
 				return 0;
 			}
--- LVM2/tools/lvcreate.c	2007/03/09 20:47:41	1.133
+++ LVM2/tools/lvcreate.c	2007/03/26 16:10:10	1.134
@@ -476,8 +476,8 @@
 	uint64_t tmp_size;
 	struct volume_group *vg;
 	struct logical_volume *lv, *org = NULL, *log_lv = NULL;
-	struct list *pvh;
-	const char *tag;
+	struct list *pvh, tags;
+	const char *tag = NULL;
 	int consistent = 1;
 	struct alloc_handle *ah = NULL;
 	char lv_name_buf[128];
@@ -675,6 +675,19 @@
 		lv_name = &lv_name_buf[0];
 	}
 
+	if (arg_count(cmd, addtag_ARG)) {
+		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
+			log_error("Failed to get tag");
+			return 0;
+		}
+
+		if (!(vg->fid->fmt->features & FMT_TAGS)) {
+			log_error("Volume group %s does not support tags",
+				  vg->name);
+			return 0;
+		}
+	}
+
 	if (lp->mirrors > 1) {
 		/* FIXME Calculate how many extents needed for the log */
 
@@ -698,9 +711,13 @@
 			status |= MIRROR_NOTSYNCED;
 		}
 
+		list_init(&tags);
+		if (tag)
+			str_list_add(cmd->mem, &tags, tag);
+
 		if (!lp->corelog &&
 		    !(log_lv = create_mirror_log(cmd, vg, ah, lp->alloc,
-						 lv_name, lp->nosync))) {
+						 lv_name, lp->nosync, &tags))) {
 			log_error("Failed to create mirror log.");
 			return 0;
 		}
@@ -725,23 +742,10 @@
 			    lv->minor);
 	}
 
-	if (arg_count(cmd, addtag_ARG)) {
-		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
-			log_error("Failed to get tag");
-			goto error;
-		}
-
-		if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group %s does not support tags",
-				  lv->vg->name);
-			goto error;
-		}
-
-		if (!str_list_add(cmd->mem, &lv->tags, tag)) {
-			log_error("Failed to add tag %s to %s/%s",
-				  tag, lv->vg->name, lv->name);
-			goto error;
-		}
+	if (tag && !str_list_add(cmd->mem, &lv->tags, tag)) {
+		log_error("Failed to add tag %s to %s/%s",
+			  tag, lv->vg->name, lv->name);
+		goto error;
 	}
 
 	if (lp->mirrors > 1) {
--- LVM2/tools/toollib.c	2007/03/09 20:47:41	1.97
+++ LVM2/tools/toollib.c	2007/03/26 16:10:10	1.98
@@ -1310,11 +1310,13 @@
 					 struct alloc_handle *ah,
 					 alloc_policy_t alloc,
 					 const char *lv_name,
-					 int in_sync)
+					 int in_sync,
+					 struct list *tags)
 {
 	struct logical_volume *log_lv;
 	char *log_name;
 	size_t len;
+	struct str_list *sl;
 
 	len = strlen(lv_name) + 32;
 	if (!(log_name = alloca(len)) ||
@@ -1336,6 +1338,13 @@
 		goto error;
 	}
 
+	/* Temporary tag mirror log */
+	list_iterate_items(sl, tags)
+		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
+			log_error("Aborting. Unable to tag mirror log.");
+			goto error;
+		}
+
 	/* store mirror log on disk(s) */
 	if (!vg_write(vg)) {
 		stack;
@@ -1361,6 +1370,11 @@
 		goto error;
 	}
 
+	list_iterate_items(sl, tags)
+		if (!str_list_del(&log_lv->tags, sl->str))
+			log_error("Failed to remove tag %s from mirror log.",
+				  sl->str);
+
 	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
 				    in_sync ? -1 : 0)) {
 		log_error("Aborting. Failed to wipe mirror log. "
--- LVM2/tools/toollib.h	2007/03/09 20:47:41	1.45
+++ LVM2/tools/toollib.h	2007/03/26 16:10:10	1.46
@@ -100,7 +100,8 @@
 					 struct alloc_handle *ah,
 					 alloc_policy_t alloc,
 					 const char *lv_name,
-					 int in_sync);
+					 int in_sync,
+					 struct list *tags);
 
 int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	   uint64_t sectors, int value);


