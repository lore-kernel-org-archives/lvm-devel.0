From: David Teigland <teigland@sourceware.org>
Date: Thu, 3 May 2018 18:09:39 -0400
Subject: master - clvmd: defer freeing saved vgs
Message-ID: <201805032209.w43M9dtf005137@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5e13f2eef5314666e19923a03ae01f479a74fd8
Commit:        a5e13f2eef5314666e19923a03ae01f479a74fd8
Parent:        88fe07ad0ac8f12c2a2f4873d9bd32852c2f1536
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 30 16:48:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 3 14:54:48 2018 -0500

clvmd: defer freeing saved vgs

To avoid the chance of freeing a saved vg while another
code path is using it, defer freeing saved vgs until
all the lvmcache content is dropped for the vg.
---
 lib/activate/activate.c |   54 +++++++++--------
 lib/cache/lvmcache.c    |  149 +++++++++++++++++++++++++++++++++++++----------
 lib/cache/lvmcache.h    |    1 -
 3 files changed, 148 insertions(+), 56 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2d00dc6..985215a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2161,36 +2161,40 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (lv && lv_pre)
 		goto skip_read;
 
-	vg = lvmcache_get_saved_vg(vgid, 0);
-	vg_pre = lvmcache_get_saved_vg(vgid, 1);
-
-	if (!vg || !vg_pre) {
-		log_debug("lv_suspend dropping both saved vgs and rereading");
-
-		lvmcache_drop_saved_vgid(vgid);
-
-		vg = vg_read_by_vgid(cmd, vgid, 0);
-		vg_pre = vg_read_by_vgid(cmd, vgid, 1);
-
-		if (!vg || !vg_pre) {
-			log_error("lv_suspend could not find vgid %.8s vg %p vg_pre %p",
-				  vgid, vg, vg_pre);
+	if (!(vg = lvmcache_get_saved_vg(vgid, 0))) {
+		log_debug("lv_suspend did not find saved_vg %.8s so reading", vgid);
+		if (!(vg = vg_read_by_vgid(cmd, vgid, 0))) {
+			log_error("lv_suspend could not read vgid %.8s", vgid);
 			goto out;
 		}
+		log_debug("lv_suspend using read vg %s %d %p", vg->name, vg->seqno, vg);
+	} else {
+		log_debug("lv_suspend using saved_vg %s %d %p", vg->name, vg->seqno, vg);
+	}
 
-		/*
-		 * Note that vg and vg_pre returned by vg_read_by_vgid will
-		 * not be the same as saved_vg_old/saved_vg_new that would
-		 * be returned by lvmcache_get_saved_vg() because the saved_vg's
-		 * are copies of the vg struct that is created by _vg_read.
-		 * (Should we grab and use the saved_vg to use here instead of
-		 * the vg returned by vg_read_by_vgid?)
-		 */
-
-		if ((vg->status & EXPORTED_VG) || (vg_pre->status & EXPORTED_VG)) {
-			log_error("Volume group \"%s\" is exported", vg->name);
+	if (!(vg_pre = lvmcache_get_saved_vg(vgid, 1))) {
+		log_debug("lv_suspend did not find pre saved_vg %.8s so reading", vgid);
+		if (!(vg_pre = vg_read_by_vgid(cmd, vgid, 1))) {
+			log_error("lv_suspend could not read pre vgid %.8s", vgid);
 			goto out;
 		}
+		log_debug("lv_suspend using pre read vg %s %d %p", vg_pre->name, vg_pre->seqno, vg_pre);
+	} else {
+		log_debug("lv_suspend using pre saved_vg %s %d %p", vg_pre->name, vg_pre->seqno, vg_pre);
+	}
+
+	/*
+	 * Note that vg and vg_pre returned by vg_read_by_vgid will
+	 * not be the same as saved_vg_old/saved_vg_new that would
+	 * be returned by lvmcache_get_saved_vg() because the saved_vg's
+	 * are copies of the vg struct that is created by _vg_read.
+	 * (Should we grab and use the saved_vg to use here instead of
+	 * the vg returned by vg_read_by_vgid?)
+	 */
+
+	if ((vg->status & EXPORTED_VG) || (vg_pre->status & EXPORTED_VG)) {
+		log_error("Volume group \"%s\" is exported", vg->name);
+		goto out;
 	}
 
 	lv = lv_to_free = find_lv_in_vg_by_lvid(vg, lvid);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9023bcc..6d50545 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -97,6 +97,7 @@ struct lvmcache_vginfo {
 	char *saved_vg_new_buf;
 	struct dm_config_tree *saved_vg_new_cft;
 	struct volume_group *saved_vg_new;
+	struct dm_list saved_vg_to_free;
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -192,13 +193,63 @@ static void _update_cache_lock_state(const char *vgname, int locked)
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
+static void _saved_vg_inval(struct lvmcache_vginfo *vginfo, int inval_old, int inval_new)
+{
+	struct vg_list *vgl;
+
+	if (inval_old) {
+		if (vginfo->saved_vg_old)
+			log_debug_cache("lvmcache: inval saved_vg %s old %p",
+					vginfo->saved_vg_old->name, vginfo->saved_vg_old);
+
+		if (vginfo->saved_vg_old_buf)
+			dm_free(vginfo->saved_vg_old_buf);
+		if (vginfo->saved_vg_old_cft)
+			dm_config_destroy(vginfo->saved_vg_old_cft);
+
+		if (vginfo->saved_vg_old) {
+			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
+				vgl->vg = vginfo->saved_vg_old;
+				dm_list_add(&vginfo->saved_vg_to_free, &vgl->list);
+			}
+		}
+
+		vginfo->saved_vg_old_buf = NULL;
+		vginfo->saved_vg_old_cft = NULL;
+		vginfo->saved_vg_old = NULL;
+	}
+
+	if (inval_new) {
+		if (vginfo->saved_vg_new)
+			log_debug_cache("lvmcache: inval saved_vg %s new pre %p",
+					vginfo->saved_vg_new->name, vginfo->saved_vg_new);
+
+		if (vginfo->saved_vg_new_buf)
+			dm_free(vginfo->saved_vg_new_buf);
+		if (vginfo->saved_vg_new_cft)
+			dm_config_destroy(vginfo->saved_vg_new_cft);
+
+		if (vginfo->saved_vg_new) {
+			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
+				vgl->vg = vginfo->saved_vg_new;
+				dm_list_add(&vginfo->saved_vg_to_free, &vgl->list);
+			}
+		}
+
+		vginfo->saved_vg_new_buf = NULL;
+		vginfo->saved_vg_new_cft = NULL;
+		vginfo->saved_vg_new = NULL;
+	}
+}
+
 static void _saved_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int free_new)
 {
+	struct vg_list *vgl, *vgl2;
+
 	if (free_old) {
 		if (vginfo->saved_vg_old) {
 			log_debug_cache("lvmcache: free saved_vg %s old %p",
-					vginfo->saved_vg_old->name,
-					vginfo->saved_vg_old);
+					vginfo->saved_vg_old->name, vginfo->saved_vg_old);
 
 			vginfo->saved_vg_old->saved_in_clvmd = 0;
 		}
@@ -213,13 +264,21 @@ static void _saved_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int fre
 		vginfo->saved_vg_old_buf = NULL;
 		vginfo->saved_vg_old_cft = NULL;
 		vginfo->saved_vg_old = NULL;
+
+		dm_list_iterate_items_safe(vgl, vgl2, &vginfo->saved_vg_to_free) {
+			log_debug_cache("lvmcache: free saved_vg_to_free %s %p",
+					vgl->vg->name, vgl->vg);
+
+			dm_list_del(&vgl->list);
+			vgl->vg->saved_in_clvmd = 0;
+			release_vg(vgl->vg);
+		}
 	}
 
 	if (free_new) {
 		if (vginfo->saved_vg_new) {
 			log_debug_cache("lvmcache: free saved_vg %s new pre %p",
-					vginfo->saved_vg_new->name,
-					vginfo->saved_vg_new);
+					vginfo->saved_vg_new->name, vginfo->saved_vg_new);
 
 			vginfo->saved_vg_new->saved_in_clvmd = 0;
 		}
@@ -275,7 +334,7 @@ void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 	    (vginfo->saved_vg_new->seqno == vg->seqno))
 		return;
 
-	_saved_vg_free(vginfo, old, new);
+	_saved_vg_inval(vginfo, old, new);
 
 	if (!(size = export_vg_to_buffer(vg, &susp_buf)))
 		goto_bad;
@@ -310,7 +369,7 @@ void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 	return;
 
 bad:
-	_saved_vg_free(vginfo, old, new);
+	_saved_vg_inval(vginfo, old, new);
 	log_debug_cache("lvmcache failed to save pre %d vg %s", precommitted, vg->name);
 }
 
@@ -355,13 +414,12 @@ struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 					vginfo->saved_vg_old->seqno,
 					vginfo->saved_vg_old);
 
-		/* Do we need to actually set saved_vg_old to match saved_vg_new?
-		 * By just dropping old, we force a subsequent request for old to
-		 * reread it rather than just using new. */
-
 		if (vginfo->saved_vg_old && (vginfo->saved_vg_old->seqno < vg->seqno)) {
-			log_debug_cache("lvmcache: drop saved_vg_old because new invalidates");
-			_saved_vg_free(vginfo, 1, 0);
+			log_debug_cache("lvmcache: inval saved_vg_old %d %p for new %d %p %s",
+					vginfo->saved_vg_old->seqno, vginfo->saved_vg_old,
+					vg->seqno, vg, vg->name);
+
+			_saved_vg_inval(vginfo, 1, 0);
 		}
 	}
 
@@ -421,13 +479,12 @@ struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid)
 					vginfo->saved_vg_old->seqno,
 					vginfo->saved_vg_old);
 
-		/* Do we need to actually set saved_vg_old to match saved_vg_new?
-		 * By just dropping old, we force a subsequent request for old to
-		 * reread it rather than just using new. */
-
 		if (vginfo->saved_vg_old && (vginfo->saved_vg_old->seqno < vg->seqno)) {
-			log_debug_cache("lvmcache: drop saved_vg_old because new invalidates");
-			_saved_vg_free(vginfo, 1, 0);
+			log_debug_cache("lvmcache: inval saved_vg_old %d %p for new %d %p %s",
+					vginfo->saved_vg_old->seqno, vginfo->saved_vg_old,
+					vg->seqno, vg, vg->name);
+
+			_saved_vg_inval(vginfo, 1, 0);
 		}
 	}
 out:
@@ -436,16 +493,6 @@ out:
 	return vg;
 }
 
-void lvmcache_drop_saved_vg(struct volume_group *vg)
-{
-	struct lvmcache_vginfo *vginfo;
-
-	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id)))
-		return;
-
-	_saved_vg_free(vginfo, 1, 1);
-}
-
 void lvmcache_drop_saved_vgid(const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
@@ -453,7 +500,7 @@ void lvmcache_drop_saved_vgid(const char *vgid)
 	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
 		return;
 
-	_saved_vg_free(vginfo, 1, 1);
+	_saved_vg_inval(vginfo, 1, 1);
 }
 
 /*
@@ -1183,6 +1230,28 @@ next:
 	goto next;
 }
 
+static void _move_saved_vg(struct lvmcache_vginfo *to, struct lvmcache_vginfo *from)
+{
+	to->saved_vg_committed	= from->saved_vg_committed;
+	to->saved_vg_old_buf	= from->saved_vg_old_buf;
+	to->saved_vg_old_cft	= from->saved_vg_old_cft;
+	to->saved_vg_old	= from->saved_vg_old;
+	to->saved_vg_new_buf	= from->saved_vg_new_buf;
+	to->saved_vg_new_cft	= from->saved_vg_new_cft;
+	to->saved_vg_new	= from->saved_vg_new;
+
+	from->saved_vg_committed= 0;
+	from->saved_vg_old_buf	= NULL;
+	from->saved_vg_old_cft	= NULL;
+	from->saved_vg_old	= NULL;
+	from->saved_vg_new_buf	= NULL;
+	from->saved_vg_new_cft	= NULL;
+	from->saved_vg_new	= NULL;
+
+	dm_list_init(&to->saved_vg_to_free);
+	dm_list_splice(&to->saved_vg_to_free, &from->saved_vg_to_free);
+}
+
 /*
  * The initial label_scan at the start of the command is done without
  * holding VG locks.  Then for each VG identified during the label_scan,
@@ -1226,7 +1295,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 {
 	struct dm_list devs;
 	struct device_list *devl;
-	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_vginfo *vginfo, *tmp;
 	struct lvmcache_info *info, *info2;
 
 	if (lvmetad_used())
@@ -1256,6 +1325,15 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 		dm_list_add(&devs, &devl->list);
 	}
 
+	/*
+	 * clvmd stashes some copies of a vg on the vginfo struct
+	 * (FIXME: it shouldn't abuse vginfo and should use its own struct),
+	 * so when we replace vginfo in clvmd, we need to move the stashed
+	 * vg's from the old vginfo struct to the new vginfo struct.
+	 */
+	if (cmd->is_clvmd && (tmp = dm_zalloc(sizeof(*tmp))))
+		_move_saved_vg(tmp, vginfo);
+
 	dm_list_iterate_items_safe(info, info2, &vginfo->infos)
 		lvmcache_del(info);
 
@@ -1268,6 +1346,16 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 
 	label_scan_devs(cmd, &devs);
 
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		log_warn("VG info not found after rescan of %s", vgname);
+		return 0;
+	}
+
+	if (cmd->is_clvmd && tmp) {
+		_move_saved_vg(vginfo, tmp);
+		dm_free(tmp);
+	}
+
 	return 1;
 }
 
@@ -1834,6 +1922,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 			return 0;
 		}
 		dm_list_init(&vginfo->infos);
+		dm_list_init(&vginfo->saved_vg_to_free);
 
 		/*
 		 * A different VG (different uuid) can exist with the same name.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 7cdda43..20ce74b 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -216,7 +216,6 @@ void lvmcache_set_independent_location(const char *vgname);
 void lvmcache_save_vg(struct volume_group *vg, int precommitted);
 struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted);
 struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid);
-void lvmcache_drop_saved_vg(struct volume_group *vg);
 void lvmcache_drop_saved_vgid(const char *vgid);
 
 int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);


