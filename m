From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Apr 2018 17:51:11 -0400
Subject: master - clvmd: reuse a vg struct for sequential LV operations
Message-ID: <201804252151.w3PLpBDt017652@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fec86571ff9133c0a24a794d1221a0fefde7670
Commit:        1fec86571ff9133c0a24a794d1221a0fefde7670
Parent:        f8616ac2d87b247dd9ae041d59e6dbe43c88172c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 24 13:19:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 25 16:39:43 2018 -0500

clvmd: reuse a vg struct for sequential LV operations

After reading a VG, stash it in lvmcache as "saved_vg".
Before reading the VG again, try to use the saved_vg.
The saved_vg is dropped on VG lock operations.
---
 lib/activate/activate.c |   70 +++++++++++++++++++++++++++---------------
 lib/cache/lvmcache.c    |   78 ++++++++++++++++++++++++++++++++++++++++------
 lib/cache/lvmcache.h    |    4 ++-
 lib/metadata/metadata.c |   19 ++++++++---
 lib/metadata/metadata.h |    4 ++
 lib/metadata/vg.c       |    5 +++
 lib/metadata/vg.h       |    1 +
 7 files changed, 139 insertions(+), 42 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 9211714..eb04ef0 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -29,6 +29,7 @@
 #include "segtype.h"
 #include "sharedlib.h"
 #include "lvmcache.h"
+#include "metadata.h"
 
 #include <limits.h>
 #include <fcntl.h>
@@ -2144,11 +2145,52 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	struct dm_pool *mem = NULL;
 	struct dm_list suspend_lvs;
 	struct lv_list *lvl;
+	const union lvid *lvid = (const union lvid *) lvid_s;
+	const char *vgid = (const char *)lvid->id[0].uuid;
+	struct volume_group *vg;
+	struct volume_group *vg_pre;
 	int found;
 
 	if (!activation())
 		return 1;
 
+	if (lv && lv_pre)
+		goto skip_read;
+
+	vg = lvmcache_get_saved_vg(vgid, 0);
+	vg_pre = lvmcache_get_saved_vg(vgid, 1);
+
+	if (!vg || !vg_pre) {
+		lvmcache_drop_saved_vgid(vgid);
+
+		vg = vg_read_by_vgid(cmd, vgid, 0);
+		vg_pre = vg_read_by_vgid(cmd, vgid, 1);
+
+		if (!vg || !vg_pre) {
+			log_error("lv_suspend could not find vgid %.8s vg %p vg_pre %p",
+				  vgid, vg, vg_pre);
+			goto out;
+		}
+
+		log_debug("lv_suspend found vg %s vg %p vg_pre %p",
+			  vg->name, vg, vg_pre);
+
+		if ((vg->status & EXPORTED_VG) || (vg_pre->status & EXPORTED_VG)) {
+			log_error("Volume group \"%s\" is exported", vg->name);
+			goto out;
+		}
+	}
+
+	lv = lv_to_free = find_lv_in_vg_by_lvid(vg, lvid);
+	lv_pre = lv_pre_to_free = find_lv_in_vg_by_lvid(vg_pre, lvid);
+
+	if (!lv || !lv_pre) {
+		log_error("lv_suspend could not find lv %p lv_pre %p vg %p vg_pre %p vgid %s",
+			  lv, lv_pre, vg, vg_pre, vgid);
+		goto out;
+	}
+
+skip_read:
 	/* lv comes from committed metadata */
 	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
@@ -2405,16 +2447,16 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	 * When called in clvmd, lvid_s is set and lv is not.  We need to
 	 * get the VG metadata without reading disks because devs are
 	 * suspended.  lv_suspend() saved old and new VG metadata for us
-	 * to use here.  If vg_commit() happened, lvmcache_get_saved_vg
+	 * to use here.  If vg_commit() happened, lvmcache_get_saved_vg_latest
 	 * will return the new metadata for us to use in resuming LVs.
-	 * If vg_commit() did not happen, lvmcache_get_saved_vg
+	 * If vg_commit() did not happen, lvmcache_get_saved_vg_latest
 	 * returns the old metadata which we use to resume LVs.
 	 */
 	if (!lv && lvid_s) {
 		lvid = (const union lvid *) lvid_s;
 		vgid = (const char *)lvid->id[0].uuid;
 
-		if ((vg = lvmcache_get_saved_vg(vgid))) {
+		if ((vg = lvmcache_get_saved_vg_latest(vgid))) {
 			log_debug_activation("Resuming LVID %s found saved vg seqno %d %s", lvid_s, vg->seqno, vg->name);
 			if ((lv_found = find_lv_in_vg_by_lvid(vg, lvid))) {
 				log_debug_activation("Resuming LVID %s found saved LV %s", lvid_s, display_lvname(lv_found));
@@ -2635,10 +2677,6 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 			 int *activate_lv, const struct logical_volume *lv)
 {
 	const struct logical_volume *lv_to_free = NULL;
-	struct volume_group *vg = NULL;
-	struct logical_volume *lv_found = NULL;
-	const union lvid *lvid;
-	const char *vgid;
 	int r = 0;
 
 	if (!activation()) {
@@ -2646,24 +2684,6 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 		return 1;
 	}
 
-	/*
-	 * This function is called while devices are suspended,
-	 * so try to use the copy of the vg that was saved in
-	 * lv_suspend.
-	 */
-	if (!lv && lvid_s) {
-		lvid = (const union lvid *) lvid_s;
-		vgid = (const char *)lvid->id[0].uuid;
-
-		if ((vg = lvmcache_get_saved_vg(vgid))) {
-			log_debug_activation("activation_filter for %s found saved VG seqno %d %s", lvid_s, vg->seqno, vg->name);
-			if ((lv_found = find_lv_in_vg_by_lvid(vg, lvid))) {
-				log_debug_activation("activation_filter for %s found saved LV %s", lvid_s, display_lvname(lv_found));
-				lv = lv_found;
-			}
-		}
-	}
-
 	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7978b07..4a7b6f9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -197,6 +197,14 @@ static void _update_cache_lock_state(const char *vgname, int locked)
 static void _saved_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int free_new)
 {
 	if (free_old) {
+		if (vginfo->saved_vg_old) {
+			log_debug_cache("lvmcache: free saved_vg %s old %p",
+					vginfo->saved_vg_old->name,
+					vginfo->saved_vg_old);
+
+			vginfo->saved_vg_old->saved_in_clvmd = 0;
+		}
+
 		if (vginfo->saved_vg_old_buf)
 			dm_free(vginfo->saved_vg_old_buf);
 		if (vginfo->saved_vg_old_cft)
@@ -210,6 +218,14 @@ static void _saved_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int fre
 	}
 
 	if (free_new) {
+		if (vginfo->saved_vg_new) {
+			log_debug_cache("lvmcache: free saved_vg %s new pre %p",
+					vginfo->saved_vg_new->name,
+					vginfo->saved_vg_new);
+
+			vginfo->saved_vg_new->saved_in_clvmd = 0;
+		}
+
 		if (vginfo->saved_vg_new_buf)
 			dm_free(vginfo->saved_vg_new_buf);
 		if (vginfo->saved_vg_new_cft)
@@ -230,6 +246,8 @@ static void _drop_metadata(const char *vgname, int drop_precommitted)
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
+	log_debug_cache("lvmcache: dropping saved_vg %s pre %d", vgname, drop_precommitted);
+
 	if (drop_precommitted)
 		_saved_vg_free(vginfo, 0, 1);
 	else
@@ -241,7 +259,7 @@ void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 	struct lvmcache_vginfo *vginfo;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
-	struct volume_group *susp_vg = NULL;
+	struct volume_group *save_vg = NULL;
 	struct dm_config_tree *susp_cft = NULL;
 	char *susp_buf = NULL;
 	size_t size;
@@ -275,39 +293,67 @@ void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 	if (!(susp_cft = config_tree_from_string_without_dup_node_check(susp_buf)))
 		goto_bad;
 
-	if (!(susp_vg = import_vg_from_config_tree(susp_cft, fid)))
+	if (!(save_vg = import_vg_from_config_tree(susp_cft, fid)))
 		goto_bad;
 
+	save_vg->saved_in_clvmd = 1;
+
 	if (old) {
 		vginfo->saved_vg_old_buf = susp_buf;
 		vginfo->saved_vg_old_cft = susp_cft;
-		vginfo->saved_vg_old = susp_vg;
-		log_debug_cache("lvmcache saved suspended vg old seqno %d %s", vg->seqno, vg->name);
+		vginfo->saved_vg_old = save_vg;
+		log_debug_cache("lvmcache saved vg %s seqno %d %p",
+				save_vg->name, save_vg->seqno, save_vg);
 	} else {
 		vginfo->saved_vg_new_buf = susp_buf;
 		vginfo->saved_vg_new_cft = susp_cft;
-		vginfo->saved_vg_new = susp_vg;
-		log_debug_cache("lvmcache saved suspended vg new seqno %d %s", vg->seqno, vg->name);
+		vginfo->saved_vg_new = save_vg;
+		log_debug_cache("lvmcache saved pre vg %s seqno %d %p",
+				save_vg->name, save_vg->seqno, save_vg);
 	}
 	return;
 
 bad:
 	_saved_vg_free(vginfo, old, new);
-	log_debug_cache("lvmcache failed to save suspended pre %d vg %s", precommitted, vg->name);
+	log_debug_cache("lvmcache failed to save pre %d vg %s", precommitted, vg->name);
 }
 
-struct volume_group *lvmcache_get_saved_vg(const char *vgid)
+struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
+	struct volume_group *vg = NULL;
+	int new = precommitted;
+	int old = !precommitted;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
-		return_NULL;
+		goto out;
+
+	if (new)
+		vg = vginfo->saved_vg_new;
+	else if (old)
+		vg = vginfo->saved_vg_old;
+out:
+	if (!vg)
+		log_debug_cache("lvmcache no saved vg %s pre %d", vgid, precommitted);
+	return vg;
+}
 
+struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct volume_group *vg = NULL;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
+		goto out;
 
 	if (vginfo->saved_vg_committed)
-		return vginfo->saved_vg_new;
+		vg = vginfo->saved_vg_new;
 	else
-		return vginfo->saved_vg_old;
+		vg = vginfo->saved_vg_old;
+out:
+	if (!vg)
+		log_debug_cache("lvmcache no saved vg %s", vgid);
+	return vg;
 }
 
 void lvmcache_drop_saved_vg(struct volume_group *vg)
@@ -320,6 +366,16 @@ void lvmcache_drop_saved_vg(struct volume_group *vg)
 	_saved_vg_free(vginfo, 1, 1);
 }
 
+void lvmcache_drop_saved_vgid(const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
+		return;
+
+	_saved_vg_free(vginfo, 1, 1);
+}
+
 /*
  * Remote node uses this to upgrade precommitted metadata to commited state
  * when receives vg_commit notification.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index b62d589..7cdda43 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -214,8 +214,10 @@ int lvmcache_get_vg_devs(struct cmd_context *cmd,
 void lvmcache_set_independent_location(const char *vgname);
 
 void lvmcache_save_vg(struct volume_group *vg, int precommitted);
-struct volume_group *lvmcache_get_saved_vg(const char *vgid);
+struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted);
+struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid);
 void lvmcache_drop_saved_vg(struct volume_group *vg);
+void lvmcache_drop_saved_vgid(const char *vgid);
 
 int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2df9abe..a908658 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4559,9 +4559,9 @@ void free_pv_fid(struct physical_volume *pv)
  * activate.c so we know the appropriate VG lock is already held and
  * the vg_read_internal is therefore safe.
  */
-static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
-					    const char *vgid,
-					    unsigned precommitted)
+struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
+				     const char *vgid,
+				     unsigned precommitted)
 {
 	const char *vgname;
 	struct volume_group *vg;
@@ -4578,6 +4578,12 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	if (lvmlockd_use())
 		log_error(INTERNAL_ERROR "vg_read_by_vgid failed with lvmlockd");
 
+	if ((vg = lvmcache_get_saved_vg(vgid, precommitted))) {
+		log_debug_metadata("lvmcache: using saved_vg %s seqno %d pre %d %p",
+				   vg->name, vg->seqno, precommitted, vg);
+		return vg;
+	}
+
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
 	if (critical_section())
 		log_debug_metadata("Reading VG by vgid in critical section pre %d vgid %.8s", precommitted, vgid);
@@ -4610,6 +4616,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	}
 
 	label_scan_destroy(cmd); /* drop bcache to close devs, keep lvmcache */
+	lvmcache_save_vg(vg, precommitted);
 	return vg;
 
  scan:
@@ -4621,6 +4628,8 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 		goto fail;
 
 	label_scan_destroy(cmd); /* drop bcache to close devs, keep lvmcache */
+
+	lvmcache_save_vg(vg, precommitted);
 	return vg;
 
  fail:
@@ -4640,12 +4649,12 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 	lvid = (const union lvid *) lvid_s;
 
 	log_very_verbose("Finding %svolume group for uuid %s", precommitted ? "precommitted " : "", lvid_s);
-	if (!(vg = _vg_read_by_vgid(cmd, (const char *)lvid->id[0].uuid, precommitted))) {
+	if (!(vg = vg_read_by_vgid(cmd, (const char *)lvid->id[0].uuid, precommitted))) {
 		log_error("Reading VG not found for LVID %s", lvid_s);
 		return NULL;
 	}
 
-	log_verbose("Found volume group \"%s\"", vg->name);
+	log_verbose("Found volume group \"%s\" %p", vg->name, vg);
 	if (vg->status & EXPORTED_VG) {
 		log_error("Volume group \"%s\" is exported", vg->name);
 		goto out;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 83983b4..1e3dd1b 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -374,6 +374,10 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
 					     const union lvid *lvid);
 
+struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
+                                     const char *vgid,
+                                     unsigned precommitted);
+
 struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
 				   const struct logical_volume *lv);
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 0b69e42..1020a67 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -97,6 +97,11 @@ void release_vg(struct volume_group *vg)
 	if (!vg || (vg->fid && vg == vg->fid->fmt->orphan_vg))
 		return;
 
+	if (vg->saved_in_clvmd) {
+		log_debug("release_vg skip saved %s %p", vg->name, vg);
+		return;
+	}
+
 	release_vg(vg->vg_committed);
 	release_vg(vg->vg_precommitted);
 	_free_vg(vg);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 086a42c..29d88f8 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -50,6 +50,7 @@ struct volume_group {
 	uint32_t seqno;		/* Metadata sequence number */
 	unsigned skip_validate_lock_args : 1;
 	unsigned lvmetad_update_pending: 1;
+	unsigned saved_in_clvmd: 1;
 
 	/*
 	 * The parsed committed (on-disk) copy of this VG; is NULL if this VG is committed


