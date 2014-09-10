From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Sep 2014 20:05:41 +0000 (UTC)
Subject: master - lvconvert: use lv_update_and_reload
Message-ID: <20140910200541.D477860DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca2ea5f984207ca9ff8a48bcbb84ca0fc3ee6e72
Commit:        ca2ea5f984207ca9ff8a48bcbb84ca0fc3ee6e72
Parent:        f50cef96c651d155ff34b9b2fa7b73b673f528d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 8 22:48:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 10 21:57:38 2014 +0200

lvconvert: use lv_update_and_reload

Use lib function.
---
 tools/lvconvert.c |   55 ++++++----------------------------------------------
 1 files changed, 7 insertions(+), 48 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 185cd59..a04a7fc 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -672,45 +672,6 @@ static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attrib
 	return lv;
 }
 
-static int _reload_lv(struct cmd_context *cmd,
-                      struct volume_group *vg,
-		      struct logical_volume *lv)
-{
-	int r = 0;
-
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-
-	if (!vg_write(vg))
-		return_0;
-
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
-		vg_revert(vg);
-		if (!resume_lv(cmd, lv))
-			stack;
-		goto out;
-	}
-
-	if (!vg_commit(vg)) {
-		vg_revert(vg);
-		if (!resume_lv(cmd, lv))
-			stack;
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
-	backup(vg);
-out:
-	return r;
-}
-
 static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 				    struct volume_group *vg,
 				    struct logical_volume *lv,
@@ -726,9 +687,7 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 
 	lv->status &= ~CONVERTING;
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-
-	if (!_reload_lv(cmd, vg, lv))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	log_print_unless_silent("Logical volume %s converted.", lv->name);
@@ -1207,7 +1166,7 @@ static int _lv_update_log_type(struct cmd_context *cmd,
 		 *        mirrored logs in cluster mirrors.
 		 */
 		if (old_log_count &&
-		    !_reload_lv(cmd, log_lv->vg, log_lv))
+		    !lv_update_and_reload(log_lv))
 			return_0;
 
 		return 1;
@@ -1572,7 +1531,7 @@ out:
 
 out_skip_log_convert:
 
-	if (!_reload_lv(cmd, lv->vg, lv))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	return 1;
@@ -1609,7 +1568,7 @@ int mirror_remove_missing(struct cmd_context *cmd,
 	    !_lv_update_log_type(cmd, NULL, lv, failed_pvs, log_count))
 		return_0;
 
-	if (!_reload_lv(cmd, lv->vg, lv))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	return 1;
@@ -2117,7 +2076,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	}
 
 	/* store vg on disk(s) */
-	if (!_reload_lv(cmd, lv->vg, org))
+	if (!lv_update_and_reload(org))
 		return_0;
 
 	log_print_unless_silent("Logical volume %s converted to snapshot.", lv->name);
@@ -2608,7 +2567,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		goto revert_new_lv;
 	}
 
-	if (!_reload_lv(cmd, vg, torigin_lv)) {
+	if (!lv_update_and_reload(torigin_lv)) {
 		stack;
 		goto deactivate_and_revert_new_lv;
 	}
@@ -3057,7 +3016,7 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	if (!(cache_lv = lv_cache_create(pool_lv, origin)))
 		return_0;
 
-	if (!_reload_lv(cmd, cache_lv->vg, cache_lv))
+	if (!lv_update_and_reload(cache_lv))
 		return_0;
 
 	log_print_unless_silent("Logical volume %s is now cached.",


