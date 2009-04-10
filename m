From: Milan Broz <mbroz@redhat.com>
Date: Fri, 10 Apr 2009 13:25:13 +0200
Subject: [PATCH 2/2] fix clvmd metadta backup
Message-ID: <49DF2C99.6040202@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move metadata backup call after vg_commit.

The backup() call store metadata from memory.

But if we have cluster, and backup() call performs
even remote nodes metadata vackup, it reads data from disk.

We want to have all metadata backup consistend,
move all backup() calls after vg_commit.

(Moreover, some tools already do that.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |   11 ++++-------
 lib/metadata/mirror.c   |   25 ++++++++++++++-----------
 tools/lvchange.c        |   32 ++++++++++++--------------------
 tools/lvconvert.c       |   12 ++++++------
 tools/lvcreate.c        |   10 +++++-----
 tools/lvresize.c        |    4 ++--
 tools/pvmove.c          |    4 ++--
 7 files changed, 45 insertions(+), 53 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ec9e19e..6331660 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1773,8 +1773,6 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!vg_write(vg))
 		return 0;
 
-	backup(vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		stack;
 		vg_revert(vg);
@@ -1789,6 +1787,8 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 
 	resume_lv(cmd, lv);
 
+	backup(vg);
+
 	return 1;
 }
 
@@ -2051,14 +2051,11 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* store it on disks */
-	if (!vg_write(vg))
-		return 0;
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
 
 	backup(vg);
 
-	if (!vg_commit(vg))
-		return 0;
-
 	/* If no snapshots left, reload without -real. */
 	if (origin && !lv_is_origin(origin)) {
 		if (!suspend_lv(cmd, origin))
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index e10d0dc..c53aec3 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -270,14 +270,11 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		}
 
 	/* store mirror log on disk(s) */
-	if (!vg_write(log_lv->vg))
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
 		goto activate_lv;
 
 	backup(log_lv->vg);
 
-	if (!vg_commit(log_lv->vg))
-		goto activate_lv;
-
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
@@ -334,10 +331,12 @@ revert_new_lv:
 		return 0;
 	}
 
-	if (!vg_write(log_lv->vg) ||
-	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
 		log_error("Manual intervention may be required to "
 			  "remove/restore abandoned log LV before retrying.");
+	else
+		backup(log_lv->vg);
+
 activate_lv:
 	if (was_active && !remove_on_failure && !activate_lv(cmd, log_lv))
 		return_0;
@@ -1504,11 +1503,15 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	return 1;
 
   out_remove_log:
-	if (log_lv && (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
-		       (backup(log_lv->vg), !vg_commit(log_lv->vg))))
-		log_error("Manual intervention may be required to remove "
-			  "abandoned log LV before retrying.");
-
+	if (log_lv) {
+		if (!lv_remove(log_lv) ||
+		    !vg_write(log_lv->vg) ||
+		    !vg_commit(log_lv->vg))
+			log_error("Manual intervention may be required to remove "
+				  "abandoned log LV before retrying.");
+		else
+			backup(log_lv->vg);
+	}
   out_remove_imgs:
 	alloc_destroy(ah);
 	return 0;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index cd0ff5a..9fa5e8f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -56,8 +56,6 @@ static int lvchange_permission(struct cmd_context *cmd,
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
@@ -75,6 +73,8 @@ static int lvchange_permission(struct cmd_context *cmd,
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	return 1;
 }
 
@@ -274,8 +274,6 @@ static int lvchange_resync(struct cmd_context *cmd,
 			return 0;
 		}
 
-		backup(lv->vg);
-
 		if (!vg_commit(lv->vg)) {
 			log_error("Failed to commit intermediate VG metadata.");
 			if (!attach_mirror_log(first_seg(lv), log_lv))
@@ -285,6 +283,8 @@ static int lvchange_resync(struct cmd_context *cmd,
 			return 0;
 		}
 
+		backup(lv->vg);
+
 		if (!activate_lv(cmd, log_lv)) {
 			log_error("Unable to activate %s for mirror log resync",
 				  log_lv->name);
@@ -349,15 +349,12 @@ static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-	if (!vg_write(lv->vg))
+	/* No need to suspend LV for this change */
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
 	backup(lv->vg);
 
-	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg))
-		return_0;
-
 	return 1;
 }
 
@@ -401,8 +398,6 @@ static int lvchange_readahead(struct cmd_context *cmd,
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
@@ -420,6 +415,8 @@ static int lvchange_readahead(struct cmd_context *cmd,
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	return 1;
 }
 
@@ -477,14 +474,11 @@ static int lvchange_persistent(struct cmd_context *cmd,
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
 	backup(lv->vg);
 
-	if (!vg_commit(lv->vg))
-		return_0;
-
 	if (active) {
 		log_verbose("Re-activating logical volume \"%s\"", lv->name);
 		if (!activate_lv(cmd, lv)) {
@@ -527,15 +521,13 @@ static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
-		return_0;
-
-	backup(lv->vg);
 
 	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg))
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
+	backup(lv->vg);
+
 	return 1;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2ded226..9597f63 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -281,8 +281,6 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 	if (!vg_write(vg))
 		return_0;
 
-	backup(vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(vg);
@@ -301,6 +299,8 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 		return 0;
 	}
 
+	backup(vg);
+
 	log_print("Logical volume %s converted.", lv->name);
 
 	return 1;
@@ -589,8 +589,6 @@ commit_changes:
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
@@ -609,6 +607,8 @@ commit_changes:
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 
@@ -664,8 +664,6 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, org)) {
 		log_error("Failed to suspend origin %s", org->name);
 		vg_revert(lv->vg);
@@ -680,6 +678,8 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	log_print("Logical volume %s converted to snapshot.", lv->name);
 
 	return 1;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e5916db..78dc6b3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -786,14 +786,11 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg))
+	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
 	backup(vg);
 
-	if (!vg_commit(vg))
-		return_0;
-
 	if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
@@ -878,9 +875,12 @@ deactivate_and_revert_new_lv:
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || (backup(vg), !vg_commit(vg)))
+	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
+	else
+		backup(vg);
+
 	return 0;
 }
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 0f3ddc2..99cf422 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -626,8 +626,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	backup(vg);
-
 	/* If snapshot, must suspend all associated devices */
 	if (lv_is_cow(lv))
 		lock_lv = origin_from_cow(lv);
@@ -651,6 +649,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
+	backup(vg);
+
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
diff --git a/tools/pvmove.c b/tools/pvmove.c
index f89ea93..eb9b9c0 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -287,8 +287,6 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	backup(vg);
-
 	/* Suspend lvs_changed */
 	if (!suspend_lvs(cmd, lvs_changed))
 		return_0;
@@ -338,6 +336,8 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	backup(vg);
+
 	return 1;
 }
 



