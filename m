From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 16:29:11 -0500
Subject: [PATCH 4/5] lvm-stack-on-resume-and-suspend-failures
In-Reply-To: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
References: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258752552-1589-4-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add missing 'stack;' for all suspend_lv and resume_lv callers.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/locking/locking.c   |    6 ++++--
 lib/metadata/lv_manip.c |    3 ++-
 lib/metadata/mirror.c   |    5 +++--
 tools/lvchange.c        |    6 ++++--
 tools/lvconvert.c       |    3 ++-
 tools/lvresize.c        |    3 ++-
 tools/pvmove.c          |   21 ++++++++++++++-------
 tools/toollib.c         |   13 ++++++++++++-
 8 files changed, 43 insertions(+), 17 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 9d86433..de890b2 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -439,7 +439,8 @@ int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, lvs)
-		resume_lv(cmd, lvl->lv);
+		if (!resume_lv(cmd, lvl->lv))
+			stack;
 
 	return 1;
 }
@@ -455,7 +456,8 @@ int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 			log_error("Failed to suspend %s", lvl->lv->name);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
-				resume_lv(cmd, lvl->lv);
+				if (!resume_lv(cmd, lvl->lv))
+					stack;
 			}
 
 			return 0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5041fd8..260a9ee 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1822,7 +1822,8 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(r = vg_commit(vg)))
 		stack;
 
-	resume_lvs(cmd, &lvs_changed);
+	if (!resume_lvs(cmd, &lvs_changed))
+		stack;
 out:
 	backup(vg);
 	return r;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 6936e8c..d53a219 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -596,8 +596,9 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	}
 
 	if (!vg_commit(mirrored_seg->lv->vg)) {
-		resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv);
-		return 0;
+		if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv))
+			stack;
+		return_0;
 	}
 
 	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index ab4dc33..ce94101 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -64,7 +64,8 @@ static int lvchange_permission(struct cmd_context *cmd,
 	}
 
 	if (!vg_commit(lv->vg)) {
-		resume_lv(cmd, lv);
+		if (!resume_lv(cmd, lv))
+			stack;
 		goto_out;
 	}
 
@@ -385,7 +386,8 @@ static int lvchange_readahead(struct cmd_context *cmd,
 	}
 
 	if (!vg_commit(lv->vg)) {
-		resume_lv(cmd, lv);
+		if (!resume_lv(cmd, lv))
+			stack;
 		goto_out;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0821c30..d1b86bf 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -790,7 +790,8 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 	}
 
 	if (!vg_commit(lv->vg)) {
-		resume_lv(cmd, lv);
+		if (!resume_lv(cmd, lv))
+			stack;
 		goto_out;
 	}
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 3b3a2eb..761ed27 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -638,7 +638,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (!vg_commit(vg)) {
 		stack;
-		resume_lv(cmd, lock_lv);
+		if (!resume_lv(cmd, lock_lv))
+			stack;
 		backup(vg);
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvmove.c b/tools/pvmove.c
index ac09d6a..a56e377 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -292,7 +292,8 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	/* Suspend mirrors on subsequent calls */
 	if (!first_time) {
 		if (!suspend_lv(cmd, lv_mirr)) {
-			resume_lvs(cmd, lvs_changed);
+			if (!resume_lvs(cmd, lvs_changed))
+				stack;
 			vg_revert(vg);
 			goto_out;
 		}
@@ -302,8 +303,10 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
 		if (!first_time)
-			resume_lv(cmd, lv_mirr);
-		resume_lvs(cmd, lvs_changed);
+			if (!resume_lv(cmd, lv_mirr))
+				stack;
+		if (!resume_lvs(cmd, lvs_changed))
+			stack;
 		goto out;
 	}
 
@@ -327,7 +330,8 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	} else if (!resume_lv(cmd, lv_mirr)) {
 		log_error("Unable to reactivate logical volume \"%s\"",
 			  lv_mirr->name);
-		resume_lvs(cmd, lvs_changed);
+		if (!resume_lvs(cmd, lvs_changed))
+			stack;
 		goto out;
 	}
 
@@ -501,8 +505,10 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 		log_error("ABORTING: Failed to write new data locations "
 			  "to disk.");
 		vg_revert(vg);
-		resume_lv(cmd, lv_mirr);
-		resume_lvs(cmd, lvs_changed);
+		if (!resume_lv(cmd, lv_mirr))
+			stack;
+		if (!resume_lvs(cmd, lvs_changed))
+			stack;
 		return 0;
 	}
 
@@ -514,7 +520,8 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	/* Unsuspend LVs */
-	resume_lvs(cmd, lvs_changed);
+	if (!resume_lvs(cmd, lvs_changed))
+		stack;
 
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 39a6d69..ada1302 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1252,7 +1252,18 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	return suspend_lv(cmd, lv) && resume_lv(cmd, lv);
+	int r = 0;
+
+	r = suspend_lv(cmd, lv);
+	if (!r)
+		goto_out;
+
+	r = resume_lv(cmd, lv);
+	if (!r)
+		goto_out;
+
+out:
+	return r;
 }
 
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg)
-- 
1.6.5.2


