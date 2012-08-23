From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:43:01 +0000 (UTC)
Subject: master - lvconvert: use _reload_lv on more places
Message-ID: <20120823124301.904CBA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57c0f72b1d0349382c226c2b5614489b59db99e8
Commit:        57c0f72b1d0349382c226c2b5614489b59db99e8
Parent:        4698fb0543637761fc11af76643f6b8e81a631a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 2 11:38:07 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:38:45 2012 +0200

lvconvert: use _reload_lv on more places

Use common subroutine.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   90 +++++++++++++++++-----------------------------------
 2 files changed, 31 insertions(+), 60 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1dcc5c2..9bd1739 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98
 =================================
+  Reuse _reload_lv() in more lvconvert functions.
   Fix dereference of NULL in lvmetad error path logging.
   Fix buffer memory leak in lvmetad logging.
   Use 'ignore' discards for thin metadata created with older versions.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4c8dd50..2bfde24 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -492,32 +492,40 @@ static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attrib
 	return lv;
 }
 
-static int _reload_lv(struct cmd_context *cmd, struct logical_volume *lv)
+static int _reload_lv(struct cmd_context *cmd,
+                      struct volume_group *vg,
+		      struct logical_volume *lv)
 {
+	int r = 0;
+
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-	if (!vg_write(lv->vg))
+	if (!vg_write(vg))
 		return_0;
 
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
-		vg_revert(lv->vg);
-		return 0;
+		vg_revert(vg);
+		goto out;
 	}
 
-	if (!vg_commit(lv->vg)) {
+	if (!vg_commit(vg)) {
 		if (!resume_lv(cmd, lv))
 			stack;
-		return_0;
+		goto_out;
 	}
 
 	log_very_verbose("Updating \"%s\" in kernel", lv->name);
 
 	if (!resume_lv(cmd, lv)) {
 		log_error("Problem reactivating %s", lv->name);
-		return 0;
+		goto out;
 	}
-	return 1;
+
+	r = 1;
+out:
+	backup(vg);
+	return r;
 }
 
 static int _finish_lvconvert_mirror(struct cmd_context *cmd,
@@ -525,8 +533,6 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 				    struct logical_volume *lv,
 				    struct dm_list *lvs_changed __attribute__((unused)))
 {
-	int r = 0;
-
 	if (!(lv->status & CONVERTING))
 		return 1;
 
@@ -539,32 +545,12 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-	if (!vg_write(vg))
+	if (!(_reload_lv(cmd, vg, lv)))
 		return_0;
 
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
-		vg_revert(vg);
-		goto out;
-	}
-
-	if (!vg_commit(vg)) {
-		resume_lv(cmd, lv);
-		goto_out;
-	}
-
-	log_very_verbose("Updating \"%s\" in kernel", lv->name);
-
-	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
-		goto out;
-	}
-
-	r = 1;
 	log_print("Logical volume %s converted.", lv->name);
-out:
-	backup(vg);
-	return r;
+
+	return 1;
 }
 
 static int _finish_lvconvert_merge(struct cmd_context *cmd,
@@ -904,7 +890,6 @@ static int _lv_update_mirrored_log(struct logical_volume *lv,
 				    operable_pvs, 0U);
 }
 
-static int _reload_lv(struct cmd_context *cmd, struct logical_volume *lv);
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
@@ -948,8 +933,10 @@ static int _lv_update_log_type(struct cmd_context *cmd,
 		 *        but it doesn't matter because we don't support
 		 *        mirrored logs in cluster mirrors.
 		 */
-		if (old_log_count)
-			return _reload_lv(cmd, log_lv);
+		if (old_log_count &&
+		    !_reload_lv(cmd, log_lv->vg, log_lv))
+			return_0;
+
 		return 1;
 	}
 
@@ -1328,8 +1315,8 @@ out:
 
 out_skip_log_convert:
 
-	if (!_reload_lv(cmd, lv))
-		return 0;
+	if (!_reload_lv(cmd, lv->vg, lv))
+		return_0;
 
 	return 1;
 }
@@ -1369,8 +1356,8 @@ int mirror_remove_missing(struct cmd_context *cmd,
 				 log_count))
 		return 0;
 
-	if (!_reload_lv(cmd, lv))
-		return 0;
+	if (!_reload_lv(cmd, lv->vg, lv))
+		return_0;
 
 	return 1;
 }
@@ -1673,7 +1660,6 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 			      struct lvconvert_params *lp)
 {
 	struct logical_volume *org;
-	int r = 0;
 
 	if (!(org = find_lv(lv->vg, lp->origin))) {
 		log_error("Couldn't find origin volume '%s'.", lp->origin);
@@ -1714,28 +1700,12 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	}
 
 	/* store vg on disk(s) */
-	if (!vg_write(lv->vg))
+	if (!_reload_lv(cmd, lv->vg, lv))
 		return_0;
 
-	if (!suspend_lv(cmd, org)) {
-		log_error("Failed to suspend origin %s", org->name);
-		vg_revert(lv->vg);
-		goto out;
-	}
-
-	if (!vg_commit(lv->vg))
-		goto_out;
-
-	if (!resume_lv(cmd, org)) {
-		log_error("Problem reactivating origin %s", org->name);
-		goto out;
-	}
-
 	log_print("Logical volume %s converted to snapshot.", lv->name);
-	r = 1;
-out:
-	backup(lv->vg);
-	return r;
+
+	return 1;
 }
 
 static int lvconvert_merge(struct cmd_context *cmd,


