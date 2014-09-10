From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Sep 2014 20:05:37 +0000 (UTC)
Subject: master - lv_rename: fix snapshot rename
Message-ID: <20140910200537.A69E060DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c61c5f360d00097fcb97ac9d9dec6687cd86e35f
Commit:        c61c5f360d00097fcb97ac9d9dec6687cd86e35f
Parent:        17e8b6aa686958c49b9a4752ea235bbdc99a7643
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 9 18:47:27 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 10 21:57:38 2014 +0200

lv_rename: fix snapshot rename

Fix rename operation for snapshot (cow) LV.
Only the snapshot's origin has the lock and by mistake suspend
and resume has been called for the snapshot LV.
This further made volumes unusable in cluster.

So instead of suspend and resuming list of LVs,
we need to just suspend and resume origin.

As the sequence write/suspend/commit/resume
is widely used in lvm2 code base - move it to
new lv_update_and_reload function.
---
 WHATS_NEW                        |    2 +
 lib/metadata/lv_manip.c          |   98 ++++++++++++++++++++++----------------
 lib/metadata/metadata-exported.h |    4 ++
 3 files changed, 63 insertions(+), 41 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bf929f6..2175d29 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.112 - 
 =====================================
+  Introduce common code to modify metadate and reload updated LV.
+  Fix rename of active snapshot volume in cluster.
   Make sure shared libraries are built with RELRO option.
 
 Version 2.02.111 - 1st September 2014
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 60aa6f8..3b158b8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3940,10 +3940,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		     const char *new_name, int update_mda)
 {
 	struct volume_group *vg = lv->vg;
-	struct lv_names lv_names;
-	DM_LIST_INIT(lvs_changed);
-	struct lv_list lvl, lvl2, *lvlp;
-	int r = 0;
+	struct lv_names lv_names = { .old = lv->name };
 
 	/* rename is not allowed on sub LVs */
 	if (!lv_is_visible(lv)) {
@@ -3965,51 +3962,25 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	if (update_mda && !archive(vg))
 		return_0;
 
+	if (!(lv_names.new = dm_pool_strdup(cmd->mem, new_name))) {
+		log_error("Failed to allocate space for new name.");
+		return 0;
+	}
+
 	/* rename sub LVs */
-	lv_names.old = lv->name;
-	lv_names.new = new_name;
 	if (!for_each_sub_lv(lv, _rename_cb, (void *) &lv_names))
 		return_0;
 
 	/* rename main LV */
-	if (!(lv->name = dm_pool_strdup(cmd->mem, new_name))) {
-		log_error("Failed to allocate space for new name");
-		return 0;
-	}
-
-	if (!update_mda)
-		return 1;
+	lv->name = lv_names.new;
 
-	lvl.lv = lv;
-	dm_list_add(&lvs_changed, &lvl.list);
+	if (lv_is_cow(lv))
+		lv = origin_from_cow(lv);
 
-	/* rename active virtual origin too */
-	if (lv_is_cow(lv) && lv_is_virtual_origin(lvl2.lv = origin_from_cow(lv)))
-		dm_list_add_h(&lvs_changed, &lvl2.list);
-
-	log_verbose("Writing out updated volume group");
-	if (!vg_write(vg))
-		return 0;
-
-	if (!suspend_lvs(cmd, &lvs_changed, vg))
-		goto_out;
-
-	if (!(r = vg_commit(vg)))
-		stack;
+	if (update_mda && !lv_update_and_reload(lv))
+		return_0;
 
-	/*
-	 * FIXME: resume LVs in reverse order to prevent memory
-	 * lock imbalance when resuming virtual snapshot origin
-	 * (resume of snapshot resumes origin too)
-	 */
-	dm_list_iterate_back_items(lvlp, &lvs_changed)
-		if (!resume_lv(cmd, lvlp->lv)) {
-			r = 0;
-			stack;
-		}
-out:
-	backup(vg);
-	return r;
+	return 1;
 }
 
 /*
@@ -5739,6 +5710,51 @@ no_remove:
 	return 0;
 }
 
+static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
+{
+	struct volume_group *vg = lv->vg;
+	int do_backup = 0, r = 0;
+
+	log_very_verbose("Updating logical volume %s on disk(s).",
+			 display_lvname(lv));
+
+	if (!vg_write(vg))
+		return_0;
+
+	if (!(origin_only ? suspend_lv_origin(vg->cmd, lv) : suspend_lv(vg->cmd, lv))) {
+		log_error("Failed to lock logical volume %s.",
+			  display_lvname(lv));
+		vg_revert(vg);
+	} else if (!(r = vg_commit(vg)))
+		stack; /* !vg_commit() has implict vg_revert() */
+	else
+		do_backup = 1;
+
+	log_very_verbose("Updating logical volume %s in kernel.",
+			 display_lvname(lv));
+
+	if (!(origin_only ? resume_lv_origin(vg->cmd, lv) : resume_lv(vg->cmd, lv))) {
+		log_error("Problem reactivating logical volume %s.",
+			  display_lvname(lv));
+		r = 0;
+	}
+
+	if (do_backup)
+		backup(vg);
+
+	return r;
+}
+
+int lv_update_and_reload(struct logical_volume *lv)
+{
+        return _lv_update_and_reload(lv, 0);
+}
+
+int lv_update_and_reload_origin(struct logical_volume *lv)
+{
+        return _lv_update_and_reload(lv, 1);
+}
+
 /*
  * insert_layer_for_segments_on_pv() inserts a layer segment for a segment area.
  * However, layer modification could split the underlying layer segment.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0db4334..b0ca632 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -700,6 +700,10 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		     const char *new_name, int update_mda);
 
+/* Updates and reloads metadata for given lv */
+int lv_update_and_reload(struct logical_volume *lv);
+int lv_update_and_reload_origin(struct logical_volume *lv);
+
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 


