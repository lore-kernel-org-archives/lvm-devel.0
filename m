From: okozina <okozina@fedoraproject.org>
Date: Wed,  1 Apr 2015 18:42:50 +0000 (UTC)
Subject: master - lvconvert: move poll code in before refactoring
Message-ID: <20150401184250.E5AB861171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5190f566055ab4584772b1288fd8cbf69565eb4a
Commit:        5190f566055ab4584772b1288fd8cbf69565eb4a
Parent:        a098aa419f5be5d8f805ab6dc747770e58a4b7b1
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Mar 12 16:23:19 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 1 20:40:50 2015 +0200

lvconvert: move poll code in before refactoring

This commit has no impact on functionality. Code required to
be visible outside lvconvert.c is just moved into new file
lvconvert_poll.c and some calls are made non-static and
declared in new header file lvconvert.h
---
 tools/Makefile.in      |    1 +
 tools/lvconvert.c      |  233 ++++--------------------------------------------
 tools/lvconvert_poll.c |  213 +++++++++++++++++++++++++++++++++++++++++++
 tools/lvconvert_poll.h |   61 +++++++++++++
 4 files changed, 294 insertions(+), 214 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 96cb91d..1d294dd 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -21,6 +21,7 @@ SOURCES =\
 	formats.c \
 	lvchange.c \
 	lvconvert.c \
+	lvconvert_poll.c \
 	lvcreate.c \
 	lvdisplay.c \
 	lvextend.c \
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0e6f162..732f6fd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -15,6 +15,7 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "lv_alloc.h"
+#include "lvconvert_poll.h"
 
 struct lvconvert_params {
 	int cache;
@@ -698,221 +699,25 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	return 1;
 }
 
-static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
-					      const char *name,
-					      const char *uuid __attribute__((unused)))
-{
-	dev_close_all();
-
-	if (name && !strchr(name, '/'))
-		return vg_read_for_update(cmd, name, NULL, 0);
-
-	/* 'name' is the full LV name; must extract_vgname() */
-	return vg_read_for_update(cmd, extract_vgname(cmd, name),
-				  NULL, 0);
-}
-
-static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute__((unused)),
-						struct volume_group *vg,
-						const char *name,
-						const char *uuid,
-						uint64_t lv_type __attribute__((unused)))
-{
-	struct logical_volume *lv = find_lv(vg, name);
-
-	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)))
-		return NULL;
-
-	return lv;
-}
-
-static int _finish_lvconvert_mirror(struct cmd_context *cmd,
-				    struct volume_group *vg,
-				    struct logical_volume *lv,
-				    struct dm_list *lvs_changed __attribute__((unused)))
-{
-	if (!lv_is_converting(lv))
-		return 1;
-
-	if (!collapse_mirrored_lv(lv)) {
-		log_error("Failed to remove temporary sync layer.");
-		return 0;
-	}
-
-	lv->status &= ~CONVERTING;
-
-	if (!lv_update_and_reload(lv))
-		return_0;
-
-	log_print_unless_silent("Logical volume %s converted.", lv->name);
-
-	return 1;
-}
-
-/* Swap lvid and LV names */
-static int _swap_lv_identifiers(struct cmd_context *cmd,
-				struct logical_volume *a, struct logical_volume *b)
-{
-	union lvid lvid;
-	const char *name;
-
-	lvid = a->lvid;
-	a->lvid = b->lvid;
-	b->lvid = lvid;
-
-	name = a->name;
-	a->name = b->name;
-	if (!lv_rename_update(cmd, b, name, 0))
-		return_0;
-
-	return 1;
-}
-
-static void _move_lv_attributes(struct logical_volume *to, struct logical_volume *from)
-{
-	/* Maybe move this code into _finish_thin_merge() */
-	to->status = from->status; // FIXME maybe some masking ?
-	to->alloc = from->alloc;
-	to->profile = from->profile;
-	to->read_ahead = from->read_ahead;
-	to->major = from->major;
-	to->minor = from->minor;
-	to->timestamp = from->timestamp;
-	to->hostname = from->hostname;
-
-	/* Move tags */
-	dm_list_init(&to->tags);
-	dm_list_splice(&to->tags, &from->tags);
-
-	/* Anything else to preserve? */
-}
-
-/* Finalise merging of lv into merge_lv */
-static int _finish_thin_merge(struct cmd_context *cmd,
-			      struct logical_volume *merge_lv,
-			      struct logical_volume *lv)
-{
-	if (!_swap_lv_identifiers(cmd, merge_lv, lv)) {
-		log_error("Failed to swap %s with merging %s.",
-			  lv->name, merge_lv->name);
-		return 0;
-	}
-
-	/* Preserve origins' attributes */
-	_move_lv_attributes(lv, merge_lv);
-
-	/* Removed LV has to be visible */
-	if (!lv_remove_single(cmd, merge_lv, DONT_PROMPT, 1))
-		return_0;
-
-	return 1;
-}
-
-static int _finish_lvconvert_merge(struct cmd_context *cmd,
-				   struct volume_group *vg,
-				   struct logical_volume *lv,
-				   struct dm_list *lvs_changed __attribute__((unused)))
-{
-	struct lv_segment *snap_seg = find_snapshot(lv);
-
-	if (!lv_is_merging_origin(lv)) {
-		log_error("Logical volume %s has no merging snapshot.", lv->name);
-		return 0;
-	}
-
-	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.", lv->name);
-
-	if (seg_is_thin_volume(snap_seg)) {
-		clear_snapshot_merge(lv);
-
-		if (!_finish_thin_merge(cmd, lv, snap_seg->lv))
-			return_0;
-
-	} else if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT, 0)) {
-		log_error("Could not remove snapshot %s merged into %s.",
-			  snap_seg->cow->name, lv->name);
-		return 0;
-	}
-
-	return 1;
-}
-
-static progress_t _poll_merge_progress(struct cmd_context *cmd,
-				       struct logical_volume *lv,
-				       const char *name __attribute__((unused)),
-				       struct daemon_parms *parms)
-{
-	dm_percent_t percent = DM_PERCENT_0;
-
-	if (!lv_is_merging_origin(lv) ||
-	    !lv_snapshot_percent(lv, &percent)) {
-		log_error("%s: Failed query for merging percentage. Aborting merge.", lv->name);
-		return PROGRESS_CHECK_FAILED;
-	} else if (percent == DM_PERCENT_INVALID) {
-		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);
-		return PROGRESS_CHECK_FAILED;
-	} else if (percent == LVM_PERCENT_MERGE_FAILED) {
-		log_error("%s: Merge failed. Retry merge or inspect manually.", lv->name);
-		return PROGRESS_CHECK_FAILED;
-	}
-
-	if (parms->progress_display)
-		log_print_unless_silent("%s: %s: %.1f%%", lv->name, parms->progress_title,
-					100.0 - dm_percent_to_float(percent));
-	else
-		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
-			    100.0 - dm_percent_to_float(percent));
-
-	if (percent == DM_PERCENT_0)
-		return PROGRESS_FINISHED_ALL;
-
-	return PROGRESS_UNFINISHED;
-}
-
-static progress_t _poll_thin_merge_progress(struct cmd_context *cmd,
-					    struct logical_volume *lv,
-					    const char *name __attribute__((unused)),
-					    struct daemon_parms *parms)
-{
-	uint32_t device_id;
-
-	if (!lv_thin_device_id(lv, &device_id)) {
-		stack;
-		return PROGRESS_CHECK_FAILED;
-	}
-
-	/*
-	 * There is no need to poll more than once,
-	 * a thin snapshot merge is immediate.
-	 */
-
-	if (device_id != find_snapshot(lv)->device_id) {
-		log_error("LV %s is not merged.", lv->name);
-		return PROGRESS_CHECK_FAILED;
-	}
-
-	return PROGRESS_FINISHED_ALL; /* Merging happend */
-}
-
 static struct poll_functions _lvconvert_mirror_fns = {
-	.get_copy_vg = _get_lvconvert_vg,
-	.get_copy_lv = _get_lvconvert_lv,
+	.get_copy_vg = lvconvert_get_copy_vg,
+	.get_copy_lv = lvconvert_get_copy_lv,
 	.poll_progress = poll_mirror_progress,
-	.finish_copy = _finish_lvconvert_mirror,
+	.finish_copy = lvconvert_mirror_finish,
 };
 
 static struct poll_functions _lvconvert_merge_fns = {
-	.get_copy_vg = _get_lvconvert_vg,
-	.get_copy_lv = _get_lvconvert_lv,
-	.poll_progress = _poll_merge_progress,
-	.finish_copy = _finish_lvconvert_merge,
+	.get_copy_vg = lvconvert_get_copy_vg,
+	.get_copy_lv = lvconvert_get_copy_lv,
+	.poll_progress = poll_merge_progress,
+	.finish_copy = lvconvert_merge_finish,
 };
 
 static struct poll_functions _lvconvert_thin_merge_fns = {
-	.get_copy_vg = _get_lvconvert_vg,
-	.get_copy_lv = _get_lvconvert_lv,
-	.poll_progress = _poll_thin_merge_progress,
-	.finish_copy = _finish_lvconvert_merge,
+	.get_copy_vg = lvconvert_get_copy_vg,
+	.get_copy_lv = lvconvert_get_copy_lv,
+	.poll_progress = poll_thin_merge_progress,
+	.finish_copy = lvconvert_merge_finish,
 };
 
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
@@ -2421,7 +2226,7 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 		 * Both thin snapshot and origin are inactive,
 		 * replace the origin LV with its snapshot LV.
 		 */
-		if (!_finish_thin_merge(cmd, origin, lv))
+		if (!thin_merge_finish(cmd, origin, lv))
 			goto_out;
 
 		if (origin_is_active && !activate_lv(cmd, lv)) {
@@ -2626,7 +2431,7 @@ deactivate_pmslv:
 	if (!detach_pool_metadata_lv(first_seg(pool_lv), &mlv))
 		return_0;
 
-	if (!_swap_lv_identifiers(cmd, mlv, pmslv))
+	if (!swap_lv_identifiers(cmd, mlv, pmslv))
 		return_0;
 
 	/* Used _pmspare will become _tmeta */
@@ -2718,7 +2523,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	 * which could be easily removed by the user after i.e. power-off
 	 */
 
-	if (!_swap_lv_identifiers(cmd, torigin_lv, lv)) {
+	if (!swap_lv_identifiers(cmd, torigin_lv, lv)) {
 		stack;
 		goto revert_new_lv;
 	}
@@ -2744,7 +2549,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	return 1;
 
 deactivate_and_revert_new_lv:
-	if (!_swap_lv_identifiers(cmd, torigin_lv, lv))
+	if (!swap_lv_identifiers(cmd, torigin_lv, lv))
 		stack;
 
 	if (!deactivate_lv(cmd, torigin_lv)) {
@@ -3414,13 +3219,13 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 	struct volume_group *vg;
 	struct logical_volume* lv = NULL;
 
-	vg = _get_lvconvert_vg(cmd, vg_name, NULL);
+	vg = lvconvert_get_copy_vg(cmd, vg_name, NULL);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_NULL;
 	}
 
-	if (!(lv = _get_lvconvert_lv(cmd, vg, lv_name, NULL, 0))) {
+	if (!(lv = lvconvert_get_copy_lv(cmd, vg, lv_name, NULL, 0))) {
 		log_error("Can't find LV %s in VG %s", lv_name, vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
new file mode 100644
index 0000000..012911e
--- /dev/null
+++ b/tools/lvconvert_poll.c
@@ -0,0 +1,213 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "libdevmapper.h"
+#include "lvconvert_poll.h"
+#include "tools.h"
+
+struct volume_group *lvconvert_get_copy_vg(struct cmd_context *cmd,
+					   const char *name,
+					   const char *uuid __attribute__((unused)))
+{
+	dev_close_all();
+
+	if (name && !strchr(name, '/'))
+		return vg_read_for_update(cmd, name, NULL, 0);
+
+	/* 'name' is the full LV name; must extract_vgname() */
+	return vg_read_for_update(cmd, extract_vgname(cmd, name),
+				  NULL, 0);
+}
+
+struct logical_volume *lvconvert_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
+					     struct volume_group *vg,
+					     const char *name,
+					     const char *uuid,
+					     uint64_t lv_type __attribute__((unused)))
+{
+	struct logical_volume *lv = find_lv(vg, name);
+
+	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)))
+		return NULL;
+
+	return lv;
+}
+
+int lvconvert_mirror_finish(struct cmd_context *cmd,
+			    struct volume_group *vg,
+			    struct logical_volume *lv,
+			    struct dm_list *lvs_changed __attribute__((unused)))
+{
+	if (!lv_is_converting(lv))
+		return 1;
+
+	if (!collapse_mirrored_lv(lv)) {
+		log_error("Failed to remove temporary sync layer.");
+		return 0;
+	}
+
+	lv->status &= ~CONVERTING;
+
+	if (!lv_update_and_reload(lv))
+		return_0;
+
+	log_print_unless_silent("Logical volume %s converted.", lv->name);
+
+	return 1;
+}
+
+/* Swap lvid and LV names */
+int swap_lv_identifiers(struct cmd_context *cmd,
+			struct logical_volume *a, struct logical_volume *b)
+{
+	union lvid lvid;
+	const char *name;
+
+	lvid = a->lvid;
+	a->lvid = b->lvid;
+	b->lvid = lvid;
+
+	name = a->name;
+	a->name = b->name;
+	if (!lv_rename_update(cmd, b, name, 0))
+		return_0;
+
+	return 1;
+}
+
+static void _move_lv_attributes(struct logical_volume *to, struct logical_volume *from)
+{
+	/* Maybe move this code into thin_merge_finish() */
+	to->status = from->status; // FIXME maybe some masking ?
+	to->alloc = from->alloc;
+	to->profile = from->profile;
+	to->read_ahead = from->read_ahead;
+	to->major = from->major;
+	to->minor = from->minor;
+	to->timestamp = from->timestamp;
+	to->hostname = from->hostname;
+
+	/* Move tags */
+	dm_list_init(&to->tags);
+	dm_list_splice(&to->tags, &from->tags);
+
+	/* Anything else to preserve? */
+}
+
+/* Finalise merging of lv into merge_lv */
+int thin_merge_finish(struct cmd_context *cmd,
+		      struct logical_volume *merge_lv,
+		      struct logical_volume *lv)
+{
+	if (!swap_lv_identifiers(cmd, merge_lv, lv)) {
+		log_error("Failed to swap %s with merging %s.",
+			  lv->name, merge_lv->name);
+		return 0;
+	}
+
+	/* Preserve origins' attributes */
+	_move_lv_attributes(lv, merge_lv);
+
+	/* Removed LV has to be visible */
+	if (!lv_remove_single(cmd, merge_lv, DONT_PROMPT, 1))
+		return_0;
+
+	return 1;
+}
+
+int lvconvert_merge_finish(struct cmd_context *cmd,
+			   struct volume_group *vg,
+			   struct logical_volume *lv,
+			   struct dm_list *lvs_changed __attribute__((unused)))
+{
+	struct lv_segment *snap_seg = find_snapshot(lv);
+
+	if (!lv_is_merging_origin(lv)) {
+		log_error("Logical volume %s has no merging snapshot.", lv->name);
+		return 0;
+	}
+
+	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.", lv->name);
+
+	if (seg_is_thin_volume(snap_seg)) {
+		clear_snapshot_merge(lv);
+
+		if (!thin_merge_finish(cmd, lv, snap_seg->lv))
+			return_0;
+
+	} else if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT, 0)) {
+		log_error("Could not remove snapshot %s merged into %s.",
+			  snap_seg->cow->name, lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+progress_t poll_merge_progress(struct cmd_context *cmd,
+			       struct logical_volume *lv,
+			       const char *name __attribute__((unused)),
+			       struct daemon_parms *parms)
+{
+	dm_percent_t percent = DM_PERCENT_0;
+
+	if (!lv_is_merging_origin(lv) ||
+	    !lv_snapshot_percent(lv, &percent)) {
+		log_error("%s: Failed query for merging percentage. Aborting merge.", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	} else if (percent == DM_PERCENT_INVALID) {
+		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	} else if (percent == LVM_PERCENT_MERGE_FAILED) {
+		log_error("%s: Merge failed. Retry merge or inspect manually.", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	if (parms->progress_display)
+		log_print_unless_silent("%s: %s: %.1f%%", lv->name, parms->progress_title,
+					100.0 - dm_percent_to_float(percent));
+	else
+		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
+			    100.0 - dm_percent_to_float(percent));
+
+	if (percent == DM_PERCENT_0)
+		return PROGRESS_FINISHED_ALL;
+
+	return PROGRESS_UNFINISHED;
+}
+
+progress_t poll_thin_merge_progress(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    const char *name __attribute__((unused)),
+				    struct daemon_parms *parms)
+{
+	uint32_t device_id;
+
+	if (!lv_thin_device_id(lv, &device_id)) {
+		stack;
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	/*
+	 * There is no need to poll more than once,
+	 * a thin snapshot merge is immediate.
+	 */
+
+	if (device_id != find_snapshot(lv)->device_id) {
+		log_error("LV %s is not merged.", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	return PROGRESS_FINISHED_ALL; /* Merging happend */
+}
diff --git a/tools/lvconvert_poll.h b/tools/lvconvert_poll.h
new file mode 100644
index 0000000..d79962c
--- /dev/null
+++ b/tools/lvconvert_poll.h
@@ -0,0 +1,61 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_LVCONVERT_H
+#define _LVM_LVCONVERT_H
+
+#include "polldaemon.h"
+
+struct cmd_context;
+struct logical_volume;
+struct volume_group;
+
+struct volume_group *lvconvert_get_copy_vg(struct cmd_context *cmd,
+					   const char *name,
+					   const char *uuid __attribute__((unused)));
+
+struct logical_volume *lvconvert_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
+					     struct volume_group *vg,
+					     const char *name,
+					     const char *uuid,
+					     uint64_t lv_type __attribute__((unused)));
+
+int lvconvert_mirror_finish(struct cmd_context *cmd,
+			    struct volume_group *vg,
+			    struct logical_volume *lv,
+			    struct dm_list *lvs_changed __attribute__((unused)));
+
+int swap_lv_identifiers(struct cmd_context *cmd,
+			struct logical_volume *a, struct logical_volume *b);
+
+int thin_merge_finish(struct cmd_context *cmd,
+		      struct logical_volume *merge_lv,
+		      struct logical_volume *lv);
+
+int lvconvert_merge_finish(struct cmd_context *cmd,
+			   struct volume_group *vg,
+			   struct logical_volume *lv,
+			   struct dm_list *lvs_changed __attribute__((unused)));
+
+progress_t poll_merge_progress(struct cmd_context *cmd,
+			       struct logical_volume *lv,
+			       const char *name __attribute__((unused)),
+			       struct daemon_parms *parms);
+
+progress_t poll_thin_merge_progress(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    const char *name __attribute__((unused)),
+				    struct daemon_parms *parms);
+
+#endif  /* _LVM_LVCONVERT_H */


