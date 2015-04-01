From: okozina <okozina@fedoraproject.org>
Date: Wed,  1 Apr 2015 18:42:48 +0000 (UTC)
Subject: master - pvmove: move poll code in before refactoring
Message-ID: <20150401184248.C978C61171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a098aa419f5be5d8f805ab6dc747770e58a4b7b1
Commit:        a098aa419f5be5d8f805ab6dc747770e58a4b7b1
Parent:        bf2d831e7e9ceb7fe0528dba8587a4157b4ac789
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Mar 12 16:21:43 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 1 20:40:39 2015 +0200

pvmove: move poll code in before refactoring

This commit has no impact on functionality. Code required to
be visible outside pvmove.c is just moved into new file
pvmove_poll.c and some calls are made non-static and declared in
new header file pvmove.h
---
 tools/Makefile.in   |    1 +
 tools/pvmove.c      |  348 ++-------------------------------------------------
 tools/pvmove_poll.c |  341 +++++++++++++++++++++++++++++++++++++++++++++++++
 tools/pvmove_poll.h |   45 +++++++
 4 files changed, 396 insertions(+), 339 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 5c1583f..96cb91d 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -38,6 +38,7 @@ SOURCES =\
 	pvcreate.c \
 	pvdisplay.c \
 	pvmove.c \
+	pvmove_poll.c \
 	pvremove.c \
 	pvresize.c \
 	pvscan.c \
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 3072584..7c01dcc 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,46 +16,7 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "display.h"
-
-#define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
-#define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
-
-static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
-{
-	const struct segment_type *segtype;
-	unsigned attr = 0;
-	int found = 1;
-	static int _clustered_found = -1;
-
-	if (clustered && _clustered_found >= 0)
-		return _clustered_found;
-
-	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
-		return_0;
-
-	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(cmd, NULL, clustered ? &attr : NULL))
-		found = 0;
-
-	if (activation() && clustered) {
-		if (found && (attr & MIRROR_LOG_CLUSTERED))
-			_clustered_found = found = 1;
-		else
-			_clustered_found = found = 0;
-	}
-
-	return found;
-}
-
-static unsigned _pvmove_is_exclusive(struct cmd_context *cmd,
-				     struct volume_group *vg)
-{
-	if (vg_is_clustered(vg))
-		if (!_pvmove_target_present(cmd, 1))
-			return 1;
-
-	return 0;
-}
+#include "pvmove_poll.h"
 
 /* Allow /dev/vgname/lvname, vgname/lvname or lvname */
 static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
@@ -88,13 +49,6 @@ static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
 	return lvname;
 }
 
-static struct volume_group *_get_vg(struct cmd_context *cmd, const char *vgname)
-{
-	dev_close_all();
-
-	return vg_read_for_update(cmd, vgname, NULL, 0);
-}
-
 /* Create list of PVs for allocation of replacement extents */
 static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 					 char **argv, struct volume_group *vg,
@@ -497,193 +451,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	return lv_mirr;
 }
 
-static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
-			unsigned exclusive)
-{
-	int r = 0;
-
-	if (exclusive || lv_is_active_exclusive(lv_mirr))
-		r = activate_lv_excl(cmd, lv_mirr);
-	else
-		r = activate_lv(cmd, lv_mirr);
-
-	if (!r)
-		stack;
-
-	return r;
-}
-
-static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
-				      void *baton)
-{
-	uint32_t mimage_to_remove = *((uint32_t *)baton);
-	struct lv_segment *mirror_seg;
-
-	if (!(mirror_seg = get_only_segment_using_this_lv(mimage_lv))) {
-		log_error(INTERNAL_ERROR "%s is not a proper mirror image",
-			  mimage_lv->name);
-		return 0;
-	}
-
-	if (seg_type(mirror_seg, 0) != AREA_LV) {
-		log_error(INTERNAL_ERROR "%s is not a pvmove mirror of LV-type",
-			  mirror_seg->lv->name);
-		return 0;
-	}
-
-	if (mimage_to_remove > mirror_seg->area_count) {
-		log_error(INTERNAL_ERROR "Mirror image %" PRIu32 " not found in segment",
-			  mimage_to_remove);
-		return 0;
-	}
-
-	if (seg_lv(mirror_seg, mimage_to_remove) == mimage_lv)
-		return 1;
-
-	return 0;
-}
-
-static int _detach_pvmove_mirror(struct cmd_context *cmd,
-				 struct logical_volume *lv_mirr)
-{
-	uint32_t mimage_to_remove = 0;
-	struct dm_list lvs_completed;
-	struct lv_list *lvl;
-
-	/* Update metadata to remove mirror segments and break dependencies */
-	dm_list_init(&lvs_completed);
-
-	if (arg_is_set(cmd, abort_ARG) &&
-	    (seg_type(first_seg(lv_mirr), 0) == AREA_LV))
-		mimage_to_remove = 1; /* remove the second mirror leg */
-
-	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, _is_pvmove_image_removable, &mimage_to_remove, PVMOVE) ||
-	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
-					    &lvs_completed)) {
-		return 0;
-	}
-
-	dm_list_iterate_items(lvl, &lvs_completed)
-		/* FIXME Assumes only one pvmove at a time! */
-		lvl->lv->status &= ~LOCKED;
-
-	return 1;
-}
-
-static int _suspend_lvs(struct cmd_context *cmd, unsigned first_time,
-			struct logical_volume *lv_mirr,
-			struct dm_list *lvs_changed,
-			struct volume_group *vg_to_revert)
-{
-	/*
-	 * Suspend lvs_changed the first time.
-	 * Suspend mirrors on subsequent calls.
-	 */
-	if (first_time) {
-		if (!suspend_lvs(cmd, lvs_changed, vg_to_revert))
-			return_0;
-	} else if (!suspend_lv(cmd, lv_mirr)) {
-		if (vg_to_revert)
-			vg_revert(vg_to_revert);
-		return_0;
-	}
-
-	return 1;
-}
-
-static int _resume_lvs(struct cmd_context *cmd, unsigned first_time,
-		       struct logical_volume *lv_mirr,
-		       struct dm_list *lvs_changed)
-{
-	/*
-	 * Suspend lvs_changed the first time.
-	 * Suspend mirrors on subsequent calls.
-	 */
-
-	if (first_time) {
-		if (!resume_lvs(cmd, lvs_changed)) {
-			log_error("Unable to resume logical volumes");
-			return 0;
-		}
-	} else if (!resume_lv(cmd, lv_mirr)) {
-		log_error("Unable to reactivate logical volume \"%s\"",
-			  lv_mirr->name);
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
- * Called to set up initial pvmove LV and to advance the mirror
- * to successive sections of it.
- * (Not called after the last section completes.)
- */
-static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
-			    struct logical_volume *lv_mirr,
-			    struct dm_list *lvs_changed, unsigned flags)
-{
-	unsigned exclusive = (flags & PVMOVE_EXCLUSIVE) ? 1 : 0;
-	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
-	int r = 0;
-
-	log_verbose("Updating volume group metadata");
-	if (!vg_write(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
-		return 0;
-	}
-
-	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
-		log_error("ABORTING: Temporary pvmove mirror %s failed.", first_time ? "activation" : "reload");
-		/* FIXME Add a recovery path for first time too. */
-		if (!first_time && !revert_lv(cmd, lv_mirr))
-			stack;
-		return 0;
-	}
-
-	/* Commit on-disk metadata */
-	if (!vg_commit(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
-		if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
-			stack;
-		if (!first_time && !revert_lv(cmd, lv_mirr))
-			stack;
-		return 0;
-	}
-
-	/* Activate the temporary mirror LV */
-	/* Only the first mirror segment gets activated as a mirror */
-	/* FIXME: Add option to use a log */
-	if (first_time) {
-		if (!exclusive && _pvmove_is_exclusive(cmd, vg))
-			exclusive = 1;
-
-		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			if (test_mode()) {
-				r = 1;
-				goto out;
-			}
-
-			/*
-			 * FIXME Run --abort internally here.
-			 */
-			log_error("ABORTING: Temporary pvmove mirror activation failed. Run pvmove --abort.");
-			goto out;
-		}
-	}
-
-	r = 1;
-
-out:
-	if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
-		r = 0;
-
-	if (r)
-		backup(vg);
-
-	return r;
-}
-
 static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 			  int argc, char **argv)
 {
@@ -728,13 +495,13 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	vg = _get_vg(cmd, pv_vg_name(pv));
+	vg = get_vg(cmd, pv_vg_name(pv));
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_ECMD_FAILED;
 	}
 
-	exclusive = _pvmove_is_exclusive(cmd, vg);
+	exclusive = pvmove_is_exclusive(cmd, vg);
 
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print_unless_silent("Detected pvmove in progress for %s", pv_name);
@@ -788,7 +555,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	if (flags & PVMOVE_FIRST_TIME) {
 		if (exclusive)
 			flags |= PVMOVE_EXCLUSIVE;
-		if (!_update_metadata
+		if (!pvmove_update_metadata
 		    (cmd, vg, lv_mirr, lvs_changed, flags))
 			goto_out;
 	}
@@ -801,110 +568,13 @@ out:
 	return r;
 }
 
-static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
-			  struct logical_volume *lv_mirr,
-			  struct dm_list *lvs_changed)
-{
-	int r = 1;
-
-	if (!dm_list_empty(lvs_changed) &&
-	    (!_detach_pvmove_mirror(cmd, lv_mirr) ||
-	    !replace_lv_with_error_segment(lv_mirr))) {
-		log_error("ABORTING: Removal of temporary mirror failed");
-		return 0;
-	}
-
-	/* Store metadata without dependencies on mirror segments */
-	if (!vg_write(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
-			  "to disk.");
-		return 0;
-	}
-
-	/* Suspend LVs changed (implicitly suspends lv_mirr) */
-	if (!suspend_lvs(cmd, lvs_changed, vg)) {
-		log_error("ABORTING: Locking LVs to remove temporary mirror failed");
-		if (!revert_lv(cmd, lv_mirr))
-			stack;
-		return 0;
-	}
-
-	/* Store metadata without dependencies on mirror segments */
-	if (!vg_commit(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
-			  "to disk.");
-		if (!revert_lv(cmd, lv_mirr))
-			stack;
-		if (!revert_lvs(cmd, lvs_changed))
-			stack;
-		return 0;
-	}
-
-	/* Release mirror LV.  (No pending I/O because it's been suspended.) */
-	if (!resume_lv(cmd, lv_mirr)) {
-		log_error("Unable to reactivate logical volume \"%s\"",
-			  lv_mirr->name);
-		r = 0;
-	}
-
-	/* Unsuspend LVs */
-	if (!resume_lvs(cmd, lvs_changed))
-		stack;
-
-	/* Deactivate mirror LV */
-	if (!deactivate_lv(cmd, lv_mirr)) {
-		log_error("ABORTING: Unable to deactivate temporary logical "
-			  "volume \"%s\"", lv_mirr->name);
-		r = 0;
-	}
-
-	log_verbose("Removing temporary pvmove LV");
-	if (!lv_remove(lv_mirr)) {
-		log_error("ABORTING: Removal of temporary pvmove LV failed");
-		return 0;
-	}
-
-	/* Store it on disks */
-	log_verbose("Writing out final volume group after pvmove");
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
-			  "to disk.");
-		return 0;
-	}
-
-	/* FIXME backup positioning */
-	backup(vg);
-
-	return r;
-}
-
-static struct volume_group *_get_move_vg(struct cmd_context *cmd,
-					 const char *name,
-					 const char *uuid __attribute__((unused)))
-{
-	struct physical_volume *pv;
-	struct volume_group *vg;
-
-	/* Reread all metadata in case it got changed */
-	if (!(pv = find_pv_by_name(cmd, name, 0, 0))) {
-		log_error("ABORTING: Can't reread PV %s", name);
-		/* What more could we do here? */
-		return NULL;
-	}
-
-	vg = _get_vg(cmd, pv_vg_name(pv));
-	free_pv_fid(pv);
-
-	return vg;
-}
-
 static struct poll_functions _pvmove_fns = {
 	.get_copy_name_from_lv = get_pvmove_pvname_from_lv_mirr,
-	.get_copy_vg = _get_move_vg,
+	.get_copy_vg = pvmove_get_copy_vg,
 	.get_copy_lv = find_pvmove_lv_from_pvname,
 	.poll_progress = poll_mirror_progress,
-	.update_metadata = _update_metadata,
-	.finish_copy = _finish_pvmove,
+	.update_metadata = pvmove_update_metadata,
+	.finish_copy = pvmove_finish,
 };
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
@@ -924,7 +594,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 	int ret;
 
 	/* dm raid1 target must be present in every case */
-	if (!_pvmove_target_present(cmd, 0)) {
+	if (!pvmove_target_present(cmd, 0)) {
 		log_error("Required device-mapper target(s) not "
 			  "detected in your kernel");
 		return ECMD_FAILED;
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
new file mode 100644
index 0000000..a5c5971
--- /dev/null
+++ b/tools/pvmove_poll.c
@@ -0,0 +1,341 @@
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
+#include "pvmove_poll.h"
+#include "tools.h"
+
+int pvmove_target_present(struct cmd_context *cmd, int clustered)
+{
+	const struct segment_type *segtype;
+	unsigned attr = 0;
+	int found = 1;
+	static int _clustered_found = -1;
+
+	if (clustered && _clustered_found >= 0)
+		return _clustered_found;
+
+	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+		return_0;
+
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(cmd, NULL, clustered ? &attr : NULL))
+		found = 0;
+
+	if (activation() && clustered) {
+		if (found && (attr & MIRROR_LOG_CLUSTERED))
+			_clustered_found = found = 1;
+		else
+			_clustered_found = found = 0;
+	}
+
+	return found;
+}
+
+unsigned pvmove_is_exclusive(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (vg_is_clustered(vg))
+		if (!pvmove_target_present(cmd, 1))
+			return 1;
+
+	return 0;
+}
+
+struct volume_group *get_vg(struct cmd_context *cmd, const char *vgname)
+{
+	dev_close_all();
+
+	return vg_read_for_update(cmd, vgname, NULL, 0);
+}
+
+int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
+		 unsigned exclusive)
+{
+	int r = 0;
+
+	if (exclusive || lv_is_active_exclusive(lv_mirr))
+		r = activate_lv_excl(cmd, lv_mirr);
+	else
+		r = activate_lv(cmd, lv_mirr);
+
+	if (!r)
+		stack;
+
+	return r;
+}
+
+static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
+				      void *baton)
+{
+	uint32_t mimage_to_remove = *((uint32_t *)baton);
+	struct lv_segment *mirror_seg;
+
+	if (!(mirror_seg = get_only_segment_using_this_lv(mimage_lv))) {
+		log_error(INTERNAL_ERROR "%s is not a proper mirror image",
+			  mimage_lv->name);
+		return 0;
+	}
+
+	if (seg_type(mirror_seg, 0) != AREA_LV) {
+		log_error(INTERNAL_ERROR "%s is not a pvmove mirror of LV-type",
+			  mirror_seg->lv->name);
+		return 0;
+	}
+
+	if (mimage_to_remove > mirror_seg->area_count) {
+		log_error(INTERNAL_ERROR "Mirror image %" PRIu32 " not found in segment",
+			  mimage_to_remove);
+		return 0;
+	}
+
+	if (seg_lv(mirror_seg, mimage_to_remove) == mimage_lv)
+		return 1;
+
+	return 0;
+}
+
+static int _detach_pvmove_mirror(struct cmd_context *cmd,
+				 struct logical_volume *lv_mirr)
+{
+	uint32_t mimage_to_remove = 0;
+	struct dm_list lvs_completed;
+	struct lv_list *lvl;
+
+	/* Update metadata to remove mirror segments and break dependencies */
+	dm_list_init(&lvs_completed);
+
+	if (arg_is_set(cmd, abort_ARG) &&
+	    (seg_type(first_seg(lv_mirr), 0) == AREA_LV))
+		mimage_to_remove = 1; /* remove the second mirror leg */
+
+	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, _is_pvmove_image_removable, &mimage_to_remove, PVMOVE) ||
+	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
+					    &lvs_completed)) {
+		return 0;
+	}
+
+	dm_list_iterate_items(lvl, &lvs_completed)
+		/* FIXME Assumes only one pvmove at a time! */
+		lvl->lv->status &= ~LOCKED;
+
+	return 1;
+}
+
+static int _suspend_lvs(struct cmd_context *cmd, unsigned first_time,
+			struct logical_volume *lv_mirr,
+			struct dm_list *lvs_changed,
+			struct volume_group *vg_to_revert)
+{
+	/*
+	 * Suspend lvs_changed the first time.
+	 * Suspend mirrors on subsequent calls.
+	 */
+	if (first_time) {
+		if (!suspend_lvs(cmd, lvs_changed, vg_to_revert))
+			return_0;
+	} else if (!suspend_lv(cmd, lv_mirr)) {
+		if (vg_to_revert)
+			vg_revert(vg_to_revert);
+		return_0;
+	}
+
+	return 1;
+}
+
+static int _resume_lvs(struct cmd_context *cmd, unsigned first_time,
+		       struct logical_volume *lv_mirr,
+		       struct dm_list *lvs_changed)
+{
+	/*
+	 * Suspend lvs_changed the first time.
+	 * Suspend mirrors on subsequent calls.
+	 */
+
+	if (first_time) {
+		if (!resume_lvs(cmd, lvs_changed)) {
+			log_error("Unable to resume logical volumes");
+			return 0;
+		}
+	} else if (!resume_lv(cmd, lv_mirr)) {
+		log_error("Unable to reactivate logical volume \"%s\"",
+			  lv_mirr->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Called to set up initial pvmove LV and to advance the mirror
+ * to successive sections of it.
+ * (Not called after the last section completes.)
+ */
+int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
+			   struct logical_volume *lv_mirr,
+			   struct dm_list *lvs_changed, unsigned flags)
+{
+	unsigned exclusive = (flags & PVMOVE_EXCLUSIVE) ? 1 : 0;
+	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
+	int r = 0;
+
+	log_verbose("Updating volume group metadata");
+	if (!vg_write(vg)) {
+		log_error("ABORTING: Volume group metadata update failed.");
+		return 0;
+	}
+
+	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
+		log_error("ABORTING: Temporary pvmove mirror %s failed.", first_time ? "activation" : "reload");
+		/* FIXME Add a recovery path for first time too. */
+		if (!first_time && !revert_lv(cmd, lv_mirr))
+			stack;
+		return 0;
+	}
+
+	/* Commit on-disk metadata */
+	if (!vg_commit(vg)) {
+		log_error("ABORTING: Volume group metadata update failed.");
+		if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
+			stack;
+		if (!first_time && !revert_lv(cmd, lv_mirr))
+			stack;
+		return 0;
+	}
+
+	/* Activate the temporary mirror LV */
+	/* Only the first mirror segment gets activated as a mirror */
+	/* FIXME: Add option to use a log */
+	if (first_time) {
+		if (!exclusive && pvmove_is_exclusive(cmd, vg))
+			exclusive = 1;
+
+		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
+			if (test_mode()) {
+				r = 1;
+				goto out;
+			}
+
+			/*
+			 * FIXME Run --abort internally here.
+			 */
+			log_error("ABORTING: Temporary pvmove mirror activation failed. Run pvmove --abort.");
+			goto out;
+		}
+	}
+
+	r = 1;
+
+out:
+	if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
+		r = 0;
+
+	if (r)
+		backup(vg);
+
+	return r;
+}
+
+int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
+		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed)
+{
+	int r = 1;
+
+	if (!dm_list_empty(lvs_changed) &&
+	    (!_detach_pvmove_mirror(cmd, lv_mirr) ||
+	    !replace_lv_with_error_segment(lv_mirr))) {
+		log_error("ABORTING: Removal of temporary mirror failed");
+		return 0;
+	}
+
+	/* Store metadata without dependencies on mirror segments */
+	if (!vg_write(vg)) {
+		log_error("ABORTING: Failed to write new data locations "
+			  "to disk.");
+		return 0;
+	}
+
+	/* Suspend LVs changed (implicitly suspends lv_mirr) */
+	if (!suspend_lvs(cmd, lvs_changed, vg)) {
+		log_error("ABORTING: Locking LVs to remove temporary mirror failed");
+		if (!revert_lv(cmd, lv_mirr))
+			stack;
+		return 0;
+	}
+
+	/* Store metadata without dependencies on mirror segments */
+	if (!vg_commit(vg)) {
+		log_error("ABORTING: Failed to write new data locations "
+			  "to disk.");
+		if (!revert_lv(cmd, lv_mirr))
+			stack;
+		if (!revert_lvs(cmd, lvs_changed))
+			stack;
+		return 0;
+	}
+
+	/* Release mirror LV.  (No pending I/O because it's been suspended.) */
+	if (!resume_lv(cmd, lv_mirr)) {
+		log_error("Unable to reactivate logical volume \"%s\"",
+			  lv_mirr->name);
+		r = 0;
+	}
+
+	/* Unsuspend LVs */
+	if (!resume_lvs(cmd, lvs_changed))
+		stack;
+
+	/* Deactivate mirror LV */
+	if (!deactivate_lv(cmd, lv_mirr)) {
+		log_error("ABORTING: Unable to deactivate temporary logical "
+			  "volume \"%s\"", lv_mirr->name);
+		r = 0;
+	}
+
+	log_verbose("Removing temporary pvmove LV");
+	if (!lv_remove(lv_mirr)) {
+		log_error("ABORTING: Removal of temporary pvmove LV failed");
+		return 0;
+	}
+
+	/* Store it on disks */
+	log_verbose("Writing out final volume group after pvmove");
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("ABORTING: Failed to write new data locations "
+			  "to disk.");
+		return 0;
+	}
+
+	/* FIXME backup positioning */
+	backup(vg);
+
+	return r;
+}
+
+struct volume_group *pvmove_get_copy_vg(struct cmd_context *cmd, const char *name,
+					const char *uuid __attribute__((unused)))
+{
+	struct physical_volume *pv;
+	struct volume_group *vg;
+
+	/* Reread all metadata in case it got changed */
+	if (!(pv = find_pv_by_name(cmd, name, 0, 0))) {
+		log_error("ABORTING: Can't reread PV %s", name);
+		/* What more could we do here? */
+		return NULL;
+	}
+
+	vg = get_vg(cmd, pv_vg_name(pv));
+	free_pv_fid(pv);
+
+	return vg;
+}
diff --git a/tools/pvmove_poll.h b/tools/pvmove_poll.h
new file mode 100644
index 0000000..2fee23a
--- /dev/null
+++ b/tools/pvmove_poll.h
@@ -0,0 +1,45 @@
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
+#ifndef _LVM_PVMOVE_H
+#define _LVM_PVMOVE_H
+
+#define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
+#define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
+
+struct cmd_context;
+struct dm_list;
+struct logical_volume;
+struct volume_group;
+
+int pvmove_target_present(struct cmd_context *cmd, int clustered);
+
+unsigned pvmove_is_exclusive(struct cmd_context *cmd, struct volume_group *vg);
+
+struct volume_group *get_vg(struct cmd_context *cmd, const char *vgname);
+
+int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
+		 unsigned exclusive);
+
+int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
+			   struct logical_volume *lv_mirr,
+			   struct dm_list *lvs_changed, unsigned flags);
+
+int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
+		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed);
+
+struct volume_group *pvmove_get_copy_vg(struct cmd_context *cmd,
+					const char *name, const char *uuid);
+
+#endif  /* _LVM_PVMOVE_H */


