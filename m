From: okozina <okozina@fedoraproject.org>
Date: Wed,  1 Apr 2015 18:42:53 +0000 (UTC)
Subject: master - pvmove: split pvmove_update_metadata function
Message-ID: <20150401184253.1F5CC61171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65623b63a20a221b48dfd87455dc77f5ac0c6bf4
Commit:        65623b63a20a221b48dfd87455dc77f5ac0c6bf4
Parent:        5190f566055ab4584772b1288fd8cbf69565eb4a
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Mar 16 20:23:58 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 1 20:41:03 2015 +0200

pvmove: split pvmove_update_metadata function

So far pvmove_update_metadata (originaly _update_metadata) was
used for both initial and subsequent metadata updates during polling.
With a new polldaemon (lvmpolld) all operations that require polling
have to be split in two parts: The initiating one and the polling one.
The later step will be used from lvm command spawned by lvmpolld to
monitor and advance the mirror on next segment if required.

1) The initiation part is _update_metadata in pvmove.c which performs
only the first update, setting up the pvmove itself in metadata.

2) pvmove_update_metadata in pvmove_poll.c now handles all other
subsequent metadata updates except the last one.

Due to the split we could remove some code. Also some functions were
moved back to pvmove.c as they were suited for initialisation of pvmove
only.
---
 tools/pvmove.c      |  131 +++++++++++++++++++++++++++++++++++++++---
 tools/pvmove_poll.c |  160 ++++++--------------------------------------------
 tools/pvmove_poll.h |   10 ---
 3 files changed, 143 insertions(+), 158 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 7c01dcc..bef900b 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -18,6 +18,45 @@
 #include "display.h"
 #include "pvmove_poll.h"
 
+#define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
+
+static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
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
+static unsigned _pvmove_is_exclusive(struct cmd_context *cmd,
+				     struct volume_group *vg)
+{
+	if (vg_is_clustered(vg))
+		if (!_pvmove_target_present(cmd, 1))
+			return 1;
+
+	return 0;
+}
+
 /* Allow /dev/vgname/lvname, vgname/lvname or lvname */
 static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
 				   const char *arg)
@@ -451,6 +490,86 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	return lv_mirr;
 }
 
+static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
+			unsigned exclusive)
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
+/*
+ * Called to set up initial pvmove LV only.
+ * (Not called after first or any other section completes.)
+ */
+static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
+			    struct logical_volume *lv_mirr,
+			    struct dm_list *lvs_changed, unsigned exclusive)
+{
+	int r = 0;
+
+	log_verbose("Updating volume group metadata for the first time.");
+	if (!vg_write(vg)) {
+		log_error("ABORTING: Volume group metadata update failed.");
+		return 0;
+	}
+
+	if (!suspend_lvs(cmd, lvs_changed, vg)) {
+		log_error("ABORTING: Temporary pvmove mirror activation failed.");
+		/* FIXME Add a recovery path for first time too. */
+		return 0;
+	}
+
+	/* Commit on-disk metadata */
+	if (!vg_commit(vg)) {
+		log_error("ABORTING: First volume group metadata update failed.");
+		if (!resume_lvs(cmd, lvs_changed)) {
+			log_error("Unable to resume logical volumes.");
+			return 0;
+		}
+	}
+
+	/* Activate the temporary mirror LV */
+	/* Only the first mirror segment gets activated as a mirror */
+	/* FIXME: Add option to use a log */
+	if (!exclusive && _pvmove_is_exclusive(cmd, vg))
+		exclusive = 1;
+
+	if (!_activate_lv(cmd, lv_mirr, exclusive)) {
+		if (test_mode()) {
+			r = 1;
+			goto out;
+		}
+
+		/*
+		 * FIXME Run --abort internally here.
+		 */
+		log_error("ABORTING: Temporary pvmove mirror activation failed. Run pvmove --abort.");
+		goto out;
+	}
+
+	r = 1;
+
+out:
+	if (!resume_lvs(cmd, lvs_changed)) {
+		log_error("Unable to resume logical volumes.");
+		r = 0;
+	}
+
+	if (r)
+		backup(vg);
+
+	return r;
+}
+
 static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 			  int argc, char **argv)
 {
@@ -501,7 +620,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 		return_ECMD_FAILED;
 	}
 
-	exclusive = pvmove_is_exclusive(cmd, vg);
+	exclusive = _pvmove_is_exclusive(cmd, vg);
 
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print_unless_silent("Detected pvmove in progress for %s", pv_name);
@@ -552,13 +671,9 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* init_pvmove(1); */
 	/* vg->status |= PVMOVE; */
 
-	if (flags & PVMOVE_FIRST_TIME) {
-		if (exclusive)
-			flags |= PVMOVE_EXCLUSIVE;
-		if (!pvmove_update_metadata
-		    (cmd, vg, lv_mirr, lvs_changed, flags))
+	if (flags & PVMOVE_FIRST_TIME)
+		if (!_update_metadata(cmd, vg, lv_mirr, lvs_changed, exclusive))
 			goto_out;
-	}
 
 	/* LVs are all in status LOCKED */
 	r = ECMD_PROCESSED;
@@ -594,7 +709,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 	int ret;
 
 	/* dm raid1 target must be present in every case */
-	if (!pvmove_target_present(cmd, 0)) {
+	if (!_pvmove_target_present(cmd, 0)) {
 		log_error("Required device-mapper target(s) not "
 			  "detected in your kernel");
 		return ECMD_FAILED;
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index a5c5971..0e9d639 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -15,42 +15,6 @@
 #include "pvmove_poll.h"
 #include "tools.h"
 
-int pvmove_target_present(struct cmd_context *cmd, int clustered)
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
-unsigned pvmove_is_exclusive(struct cmd_context *cmd, struct volume_group *vg)
-{
-	if (vg_is_clustered(vg))
-		if (!pvmove_target_present(cmd, 1))
-			return 1;
-
-	return 0;
-}
-
 struct volume_group *get_vg(struct cmd_context *cmd, const char *vgname)
 {
 	dev_close_all();
@@ -58,22 +22,6 @@ struct volume_group *get_vg(struct cmd_context *cmd, const char *vgname)
 	return vg_read_for_update(cmd, vgname, NULL, 0);
 }
 
-int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
-		 unsigned exclusive)
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
 static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
 				      void *baton)
 {
@@ -131,73 +79,26 @@ static int _detach_pvmove_mirror(struct cmd_context *cmd,
 	return 1;
 }
 
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
 /*
- * Called to set up initial pvmove LV and to advance the mirror
- * to successive sections of it.
- * (Not called after the last section completes.)
+ * Called to advance the mirror to successive sections of it.
+ * (Not called first time or after the last section completes.)
  */
 int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			   struct logical_volume *lv_mirr,
-			   struct dm_list *lvs_changed, unsigned flags)
+			   struct dm_list *lvs_changed __attribute__((unused)),
+			   unsigned flags __attribute__((unused)))
 {
-	unsigned exclusive = (flags & PVMOVE_EXCLUSIVE) ? 1 : 0;
-	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
-	int r = 0;
-
-	log_verbose("Updating volume group metadata");
+	log_verbose("Updating volume group metadata.");
 	if (!vg_write(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
 		return 0;
 	}
 
-	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
-		log_error("ABORTING: Temporary pvmove mirror %s failed.", first_time ? "activation" : "reload");
-		/* FIXME Add a recovery path for first time too. */
-		if (!first_time && !revert_lv(cmd, lv_mirr))
+	if (!suspend_lv(cmd, lv_mirr)) {
+		if (vg)
+			vg_revert(vg);
+		log_error("ABORTING: Temporary pvmove mirror reload failed.");
+		if (!revert_lv(cmd, lv_mirr))
 			stack;
 		return 0;
 	}
@@ -205,44 +106,23 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	/* Commit on-disk metadata */
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
-		if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
-			stack;
-		if (!first_time && !revert_lv(cmd, lv_mirr))
+		if (!resume_lv(cmd, lv_mirr))
+			log_error("Unable to reactivate logical volume \"%s\".",
+				  lv_mirr->name);
+		if (!revert_lv(cmd, lv_mirr))
 			stack;
 		return 0;
 	}
 
-	/* Activate the temporary mirror LV */
-	/* Only the first mirror segment gets activated as a mirror */
-	/* FIXME: Add option to use a log */
-	if (first_time) {
-		if (!exclusive && pvmove_is_exclusive(cmd, vg))
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
+	if (!resume_lv(cmd, lv_mirr)) {
+		log_error("Unable to reactivate logical volume \"%s\".",
+			  lv_mirr->name);
+		return 0;
 	}
 
-	r = 1;
-
-out:
-	if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
-		r = 0;
-
-	if (r)
-		backup(vg);
+	backup(vg);
 
-	return r;
+	return 1;
 }
 
 int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
diff --git a/tools/pvmove_poll.h b/tools/pvmove_poll.h
index 2fee23a..776920c 100644
--- a/tools/pvmove_poll.h
+++ b/tools/pvmove_poll.h
@@ -15,23 +15,13 @@
 #ifndef _LVM_PVMOVE_H
 #define _LVM_PVMOVE_H
 
-#define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
-#define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
-
 struct cmd_context;
 struct dm_list;
 struct logical_volume;
 struct volume_group;
 
-int pvmove_target_present(struct cmd_context *cmd, int clustered);
-
-unsigned pvmove_is_exclusive(struct cmd_context *cmd, struct volume_group *vg);
-
 struct volume_group *get_vg(struct cmd_context *cmd, const char *vgname);
 
-int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
-		 unsigned exclusive);
-
 int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			   struct logical_volume *lv_mirr,
 			   struct dm_list *lvs_changed, unsigned flags);


