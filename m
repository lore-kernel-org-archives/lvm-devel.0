From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Apr 2018 17:51:05 -0400
Subject: master - lvmcache: rename suspended_vg to saved_vg
Message-ID: <201804252151.w3PLp5QS017641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8616ac2d87b247dd9ae041d59e6dbe43c88172c
Commit:        f8616ac2d87b247dd9ae041d59e6dbe43c88172c
Parent:        28a9fcd94b810cbd603b4fb0c5149bf96f6caeaa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 24 12:18:22 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 25 16:39:43 2018 -0500

lvmcache: rename suspended_vg to saved_vg

The copy of the VG which clvmd stashes in lvmcache should
not only be used between suspend and resume, but between
sequential LV operations in clvmd, so that clvmd does not
need to reread the VG for each one.  Prepare for that by
renaming the stashed VG as "saved_vg".
---
 lib/activate/activate.c |   12 ++--
 lib/cache/lvmcache.c    |  127 +++++++++++++++++++++++------------------------
 lib/cache/lvmcache.h    |    6 +-
 3 files changed, 72 insertions(+), 73 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 565e643..9211714 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2181,8 +2181,8 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * did happen (or failed), and it will resume LVs using the
 	 * new/precommitted metadata if the vg_commit succeeded.
 	 */
-	lvmcache_save_suspended_vg(lv->vg, 0);
-	lvmcache_save_suspended_vg(lv_pre->vg, 1);
+	lvmcache_save_vg(lv->vg, 0);
+	lvmcache_save_vg(lv_pre->vg, 1);
 
 	if (!info.exists || info.suspended) {
 		if (!error_if_not_suspended) {
@@ -2405,16 +2405,16 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	 * When called in clvmd, lvid_s is set and lv is not.  We need to
 	 * get the VG metadata without reading disks because devs are
 	 * suspended.  lv_suspend() saved old and new VG metadata for us
-	 * to use here.  If vg_commit() happened, lvmcache_get_suspended_vg
+	 * to use here.  If vg_commit() happened, lvmcache_get_saved_vg
 	 * will return the new metadata for us to use in resuming LVs.
-	 * If vg_commit() did not happen, lvmcache_get_suspended_vg
+	 * If vg_commit() did not happen, lvmcache_get_saved_vg
 	 * returns the old metadata which we use to resume LVs.
 	 */
 	if (!lv && lvid_s) {
 		lvid = (const union lvid *) lvid_s;
 		vgid = (const char *)lvid->id[0].uuid;
 
-		if ((vg = lvmcache_get_suspended_vg(vgid))) {
+		if ((vg = lvmcache_get_saved_vg(vgid))) {
 			log_debug_activation("Resuming LVID %s found saved vg seqno %d %s", lvid_s, vg->seqno, vg->name);
 			if ((lv_found = find_lv_in_vg_by_lvid(vg, lvid))) {
 				log_debug_activation("Resuming LVID %s found saved LV %s", lvid_s, display_lvname(lv_found));
@@ -2655,7 +2655,7 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 		lvid = (const union lvid *) lvid_s;
 		vgid = (const char *)lvid->id[0].uuid;
 
-		if ((vg = lvmcache_get_suspended_vg(vgid))) {
+		if ((vg = lvmcache_get_saved_vg(vgid))) {
 			log_debug_activation("activation_filter for %s found saved VG seqno %d %s", lvid_s, vg->seqno, vg->name);
 			if ((lv_found = find_lv_in_vg_by_lvid(vg, lvid))) {
 				log_debug_activation("activation_filter for %s found saved LV %s", lvid_s, display_lvname(lv_found));
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f1fd683..7978b07 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -69,37 +69,36 @@ struct lvmcache_vginfo {
 	/*
 	 * The following are not related to lvmcache or vginfo,
 	 * but are borrowing the vginfo to store the data.
+	 * saved_vg_* are used only by clvmd.
 	 *
-	 * suspended_vg_* are used only by clvmd suspend/resume.
+	 * For activation/deactivation, these are used to avoid
+	 * clvmd rereading a VG for each LV that is activated.
+	 *
+	 * For suspend/resume, this is used to avoid disk reads
+	 * while devices are suspended:
 	 * In suspend, both old (current) and new (precommitted)
 	 * metadata is saved.  (Each in three forms: buffer, cft,
 	 * and vg).  In resume, if the vg was committed
-	 * (suspended_vg_committed is set), then LVs are resumed
+	 * (saved_vg_committed is set), then LVs are resumed
 	 * using the new metadata, but if the vg wasn't committed,
 	 * then LVs are resumed using the old metadata.
 	 *
-	 * suspended_vg_committed is set to 1 when clvmd gets
+	 * saved_vg_committed is set to 1 when clvmd gets
 	 * LCK_VG_COMMIT from vg_commit().
 	 *
-	 * These fields are only used between suspend and resume
-	 * in clvmd, and should never be used in any other way.
-	 * The contents of this data are never changed.  This
-	 * data does not really belong in lvmcache, it's unrelated
+	 * This data does not really belong in lvmcache, it's unrelated
 	 * to lvmcache or vginfo, but it's just a convenient place
-	 * for clvmd to stash the VG between suspend and resume
-	 * (since the same caller isn't present to pass the VG to
-	 * both suspend and resume in the case of clvmd.)
-	 *
-	 * This data is not really a "cache" of the VG, it is just
-	 * a location to pass the VG between suspend and resume.
+	 * for clvmd to stash the VG (since the same caller isn't
+	 * present to pass the VG to both suspend and resume in the
+	 * case of clvmd.)
 	 */
-	int suspended_vg_committed;
-	char *suspended_vg_old_buf;
-	struct dm_config_tree *suspended_vg_old_cft;
-	struct volume_group *suspended_vg_old;
-	char *suspended_vg_new_buf;
-	struct dm_config_tree *suspended_vg_new_cft;
-	struct volume_group *suspended_vg_new;
+	int saved_vg_committed;
+	char *saved_vg_old_buf;
+	struct dm_config_tree *saved_vg_old_cft;
+	struct volume_group *saved_vg_old;
+	char *saved_vg_new_buf;
+	struct dm_config_tree *saved_vg_new_cft;
+	struct volume_group *saved_vg_new;
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -195,32 +194,32 @@ static void _update_cache_lock_state(const char *vgname, int locked)
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
-static void _suspended_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int free_new)
+static void _saved_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int free_new)
 {
 	if (free_old) {
-		if (vginfo->suspended_vg_old_buf)
-			dm_free(vginfo->suspended_vg_old_buf);
-		if (vginfo->suspended_vg_old_cft)
-			dm_config_destroy(vginfo->suspended_vg_old_cft);
-		if (vginfo->suspended_vg_old)
-			release_vg(vginfo->suspended_vg_old);
+		if (vginfo->saved_vg_old_buf)
+			dm_free(vginfo->saved_vg_old_buf);
+		if (vginfo->saved_vg_old_cft)
+			dm_config_destroy(vginfo->saved_vg_old_cft);
+		if (vginfo->saved_vg_old)
+			release_vg(vginfo->saved_vg_old);
 
-		vginfo->suspended_vg_old_buf = NULL;
-		vginfo->suspended_vg_old_cft = NULL;
-		vginfo->suspended_vg_old = NULL;
+		vginfo->saved_vg_old_buf = NULL;
+		vginfo->saved_vg_old_cft = NULL;
+		vginfo->saved_vg_old = NULL;
 	}
 
 	if (free_new) {
-		if (vginfo->suspended_vg_new_buf)
-			dm_free(vginfo->suspended_vg_new_buf);
-		if (vginfo->suspended_vg_new_cft)
-			dm_config_destroy(vginfo->suspended_vg_new_cft);
-		if (vginfo->suspended_vg_new)
-			release_vg(vginfo->suspended_vg_new);
+		if (vginfo->saved_vg_new_buf)
+			dm_free(vginfo->saved_vg_new_buf);
+		if (vginfo->saved_vg_new_cft)
+			dm_config_destroy(vginfo->saved_vg_new_cft);
+		if (vginfo->saved_vg_new)
+			release_vg(vginfo->saved_vg_new);
 
-		vginfo->suspended_vg_new_buf = NULL;
-		vginfo->suspended_vg_new_cft = NULL;
-		vginfo->suspended_vg_new = NULL;
+		vginfo->saved_vg_new_buf = NULL;
+		vginfo->saved_vg_new_cft = NULL;
+		vginfo->saved_vg_new = NULL;
 	}
 }
 
@@ -232,12 +231,12 @@ static void _drop_metadata(const char *vgname, int drop_precommitted)
 		return;
 
 	if (drop_precommitted)
-		_suspended_vg_free(vginfo, 0, 1);
+		_saved_vg_free(vginfo, 0, 1);
 	else
-		_suspended_vg_free(vginfo, 1, 1);
+		_saved_vg_free(vginfo, 1, 1);
 }
 
-void lvmcache_save_suspended_vg(struct volume_group *vg, int precommitted)
+void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct format_instance *fid;
@@ -253,16 +252,16 @@ void lvmcache_save_suspended_vg(struct volume_group *vg, int precommitted)
 		goto_bad;
 
 	/* already saved */
-	if (old && vginfo->suspended_vg_old &&
-	    (vginfo->suspended_vg_old->seqno == vg->seqno))
+	if (old && vginfo->saved_vg_old &&
+	    (vginfo->saved_vg_old->seqno == vg->seqno))
 		return;
 
 	/* already saved */
-	if (new && vginfo->suspended_vg_new &&
-	    (vginfo->suspended_vg_new->seqno == vg->seqno))
+	if (new && vginfo->saved_vg_new &&
+	    (vginfo->saved_vg_new->seqno == vg->seqno))
 		return;
 
-	_suspended_vg_free(vginfo, old, new);
+	_saved_vg_free(vginfo, old, new);
 
 	if (!(size = export_vg_to_buffer(vg, &susp_buf)))
 		goto_bad;
@@ -280,24 +279,24 @@ void lvmcache_save_suspended_vg(struct volume_group *vg, int precommitted)
 		goto_bad;
 
 	if (old) {
-		vginfo->suspended_vg_old_buf = susp_buf;
-		vginfo->suspended_vg_old_cft = susp_cft;
-		vginfo->suspended_vg_old = susp_vg;
+		vginfo->saved_vg_old_buf = susp_buf;
+		vginfo->saved_vg_old_cft = susp_cft;
+		vginfo->saved_vg_old = susp_vg;
 		log_debug_cache("lvmcache saved suspended vg old seqno %d %s", vg->seqno, vg->name);
 	} else {
-		vginfo->suspended_vg_new_buf = susp_buf;
-		vginfo->suspended_vg_new_cft = susp_cft;
-		vginfo->suspended_vg_new = susp_vg;
+		vginfo->saved_vg_new_buf = susp_buf;
+		vginfo->saved_vg_new_cft = susp_cft;
+		vginfo->saved_vg_new = susp_vg;
 		log_debug_cache("lvmcache saved suspended vg new seqno %d %s", vg->seqno, vg->name);
 	}
 	return;
 
 bad:
-	_suspended_vg_free(vginfo, old, new);
+	_saved_vg_free(vginfo, old, new);
 	log_debug_cache("lvmcache failed to save suspended pre %d vg %s", precommitted, vg->name);
 }
 
-struct volume_group *lvmcache_get_suspended_vg(const char *vgid)
+struct volume_group *lvmcache_get_saved_vg(const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 
@@ -305,20 +304,20 @@ struct volume_group *lvmcache_get_suspended_vg(const char *vgid)
 		return_NULL;
 
 
-	if (vginfo->suspended_vg_committed)
-		return vginfo->suspended_vg_new;
+	if (vginfo->saved_vg_committed)
+		return vginfo->saved_vg_new;
 	else
-		return vginfo->suspended_vg_old;
+		return vginfo->saved_vg_old;
 }
 
-void lvmcache_drop_suspended_vg(struct volume_group *vg)
+void lvmcache_drop_saved_vg(struct volume_group *vg)
 {
 	struct lvmcache_vginfo *vginfo;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id)))
 		return;
 
-	_suspended_vg_free(vginfo, 1, 1);
+	_saved_vg_free(vginfo, 1, 1);
 }
 
 /*
@@ -333,7 +332,7 @@ void lvmcache_commit_metadata(const char *vgname)
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
-	vginfo->suspended_vg_committed = 1;
+	vginfo->saved_vg_committed = 1;
 }
 
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
@@ -1483,7 +1482,7 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 	dm_free(vginfo->system_id);
 	dm_free(vginfo->vgname);
 	dm_free(vginfo->creation_host);
-	_suspended_vg_free(vginfo, 1, 1);
+	_saved_vg_free(vginfo, 1, 1);
 
 	if (*vginfo->vgid && _vgid_hash &&
 	    lvmcache_vginfo_from_vgid(vginfo->vgid) == vginfo)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index ad478bd..b62d589 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -213,9 +213,9 @@ int lvmcache_get_vg_devs(struct cmd_context *cmd,
 			 struct dm_list *devs);
 void lvmcache_set_independent_location(const char *vgname);
 
-void lvmcache_save_suspended_vg(struct volume_group *vg, int precommitted);
-struct volume_group *lvmcache_get_suspended_vg(const char *vgid);
-void lvmcache_drop_suspended_vg(struct volume_group *vg);
+void lvmcache_save_vg(struct volume_group *vg, int precommitted);
+struct volume_group *lvmcache_get_saved_vg(const char *vgid);
+void lvmcache_drop_saved_vg(struct volume_group *vg);
 
 int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 


