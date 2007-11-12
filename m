From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Nov 2007 14:36:57 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20071112143657.4286.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-12 14:36:57

Modified files:
	tools          : toollib.c 

Log message:
	Remove new mirror logs when creation fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/tools/toollib.c	2007/11/02 20:40:05	1.110
+++ LVM2/tools/toollib.c	2007/11/12 14:36:57	1.111
@@ -1339,56 +1339,46 @@
 	size_t len;
 	struct str_list *sl;
 
+	if (!activation() && in_sync) {
+		log_error("Aborting. Unable to create in-sync mirror log "
+			  "while activation is disabled.");
+		return NULL;
+	}
+
 	len = strlen(lv_name) + 32;
 	if (!(log_name = alloca(len)) ||
 	    !(generate_log_name_format(vg, lv_name, log_name, len))) {
-		log_error("log_name allocation failed. "
-			  "Remove new LV and retry.");
+		log_error("log_name allocation failed.");
 		return NULL;
 	}
 
 	if (!(log_lv = lv_create_empty(log_name, NULL,
 				       VISIBLE_LV | LVM_READ | LVM_WRITE,
-				       alloc, 0, vg))) {
-		stack;
-		return NULL;
-	}
+				       alloc, 0, vg)))
+		return_NULL;
 
-	if (!lv_add_log_segment(ah, log_lv)) {
-		stack;
-		goto error;
-	}
+	if (!lv_add_log_segment(ah, log_lv))
+		return_NULL;
 
 	/* Temporary tag mirror log */
 	list_iterate_items(sl, tags)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
 			log_error("Aborting. Unable to tag mirror log.");
-			goto error;
+			return NULL;
 		}
 
 	/* store mirror log on disk(s) */
-	if (!vg_write(vg)) {
-		stack;
-		goto error;
-	}
+	if (!vg_write(vg))
+		return_NULL;
 
 	backup(vg);
 
-	if (!vg_commit(vg)) {
-		stack;
-		goto error;
-	}
-
-	if (!activation() && in_sync) {
-		log_error("Aborting. Unable to create in-sync mirror log "
-			  "while activation is disabled.");
-		goto error;
-	}
+	if (!vg_commit(vg))
+		return_NULL;
 
 	if (!activate_lv(cmd, log_lv)) {
-		log_error("Aborting. Failed to activate mirror log. "
-			  "Remove new LVs and retry.");
-		goto error;
+		log_error("Aborting. Failed to activate mirror log.");
+		goto revert_new_lv;
 	}
 
 	list_iterate_items(sl, tags)
@@ -1398,27 +1388,35 @@
 
 	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
 				    in_sync ? -1 : 0)) {
-		log_error("Aborting. Failed to wipe mirror log. "
-			  "Remove new LV and retry.");
-		goto error;
+		log_error("Aborting. Failed to wipe mirror log.");
+		goto deactivate_and_revert_new_lv;
 	}
 
 	if (activation() && !_write_log_header(cmd, log_lv)) {
-		log_error("Aborting. Failed to write mirror log header. "
-			  "Remove new LV and retry.");
-		goto error;
+		log_error("Aborting. Failed to write mirror log header.");
+		goto deactivate_and_revert_new_lv;
 	}
 
 	if (!deactivate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to deactivate mirror log. "
-			  "Remove new LV and retry.");
-		goto error;
+			  "Manual intervention required.");
+		return NULL;
 	}
 
 	log_lv->status &= ~VISIBLE_LV;
 
 	return log_lv;
-error:
-	/* FIXME Attempt to clean up. */
+
+deactivate_and_revert_new_lv:
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Unable to deactivate mirror log LV. "
+			  "Manual intervention required.");
+		return NULL;
+	}
+
+revert_new_lv:
+	if (!lv_remove(log_lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned log LV before retrying.");
 	return NULL;
 }


