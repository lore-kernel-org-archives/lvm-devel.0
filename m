From: David Teigland <teigland@sourceware.org>
Date: Thu, 3 May 2018 18:09:43 -0400
Subject: master - clvmd: separate saved_vg from vginfo
Message-ID: <201805032209.w43M9hab005153@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c016b573ee32ff836f1d427d5cf58eb6480cf7b8
Commit:        c016b573ee32ff836f1d427d5cf58eb6480cf7b8
Parent:        a5e13f2eef5314666e19923a03ae01f479a74fd8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 2 16:58:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 3 14:54:48 2018 -0500

clvmd: separate saved_vg from vginfo

The clvmd saved_vg data is independent from the normal lvm
lvmcache vginfo data, so separate saved_vg from vginfo.
Normal lvm doesn't need to use save_vg at all, and in clvmd,
lvmcache changes on vginfo can be made without worrying
about unwanted effects on saved_vg.
---
 daemons/clvmd/lvm-functions.c |    1 -
 lib/cache/lvmcache.c          |  399 +++++++++++++++++++++-------------------
 lib/cache/lvmcache.h          |   10 +-
 lib/commands/toolcontext.c    |   12 +-
 lib/commands/toolcontext.h    |    2 +-
 lib/metadata/metadata.c       |    4 +-
 tools/toollib.c               |    4 +-
 7 files changed, 231 insertions(+), 201 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 3bb00d3..34da66d 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -903,7 +903,6 @@ int init_clvm(struct dm_hash_table *excl_uuid)
 		return 0;
 	}
 
-	cmd->is_clvmd = 1;
 	cmd->cmd_line = "clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6d50545..506bcdf 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -63,11 +63,12 @@ struct lvmcache_vginfo {
 	int seqno;
 	int independent_metadata_location; /* metadata read from independent areas */
 	int scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
+};
 
+struct saved_vg {
 	/*
-	 * The following are not related to lvmcache or vginfo,
-	 * but are borrowing the vginfo to store the data.
 	 * saved_vg_* are used only by clvmd.
+	 * It is not related to lvmcache or vginfo.
 	 *
 	 * For activation/deactivation, these are used to avoid
 	 * clvmd rereading a VG for each LV that is activated.
@@ -83,13 +84,8 @@ struct lvmcache_vginfo {
 	 *
 	 * saved_vg_committed is set to 1 when clvmd gets
 	 * LCK_VG_COMMIT from vg_commit().
-	 *
-	 * This data does not really belong in lvmcache, it's unrelated
-	 * to lvmcache or vginfo, but it's just a convenient place
-	 * for clvmd to stash the VG (since the same caller isn't
-	 * present to pass the VG to both suspend and resume in the
-	 * case of clvmd.)
 	 */
+	char vgid[ID_LEN + 1];
 	int saved_vg_committed;
 	char *saved_vg_old_buf;
 	struct dm_config_tree *saved_vg_old_cft;
@@ -104,6 +100,7 @@ static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
 static struct dm_hash_table *_lock_hash = NULL;
+static struct dm_hash_table *_saved_vg_hash = NULL;
 static DM_LIST_INIT(_vginfos);
 static DM_LIST_INIT(_found_duplicate_devs);
 static DM_LIST_INIT(_unused_duplicate_devs);
@@ -114,7 +111,7 @@ static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
 static int _suppress_lock_ordering = 0;
 
-int lvmcache_init(void)
+int lvmcache_init(struct cmd_context *cmd)
 {
 	/*
 	 * FIXME add a proper lvmcache_locking_reset() that
@@ -138,6 +135,11 @@ int lvmcache_init(void)
 	if (!(_lock_hash = dm_hash_create(128)))
 		return 0;
 
+	if (cmd->is_clvmd) {
+		if (!(_saved_vg_hash = dm_hash_create(128)))
+			return 0;
+	}
+
 	/*
 	 * Reinitialising the cache clears the internal record of
 	 * which locks are held.  The global lock can be held during
@@ -193,79 +195,95 @@ static void _update_cache_lock_state(const char *vgname, int locked)
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
-static void _saved_vg_inval(struct lvmcache_vginfo *vginfo, int inval_old, int inval_new)
+static struct saved_vg *_saved_vg_from_vgid(const char *vgid)
+{
+	struct saved_vg *svg;
+	char id[ID_LEN + 1] __attribute__((aligned(8)));
+
+	/* vgid not necessarily NULL-terminated */
+	(void) dm_strncpy(id, vgid, sizeof(id));
+
+	if (!(svg = dm_hash_lookup(_saved_vg_hash, id))) {
+		log_debug_cache("lvmcache: no saved_vg for vgid \"%s\"", id);
+		return NULL;
+	}
+
+	return svg;
+}
+
+static void _saved_vg_inval(struct saved_vg *svg, int inval_old, int inval_new)
 {
 	struct vg_list *vgl;
 
 	if (inval_old) {
-		if (vginfo->saved_vg_old)
+		if (svg->saved_vg_old)
 			log_debug_cache("lvmcache: inval saved_vg %s old %p",
-					vginfo->saved_vg_old->name, vginfo->saved_vg_old);
+					svg->saved_vg_old->name, svg->saved_vg_old);
 
-		if (vginfo->saved_vg_old_buf)
-			dm_free(vginfo->saved_vg_old_buf);
-		if (vginfo->saved_vg_old_cft)
-			dm_config_destroy(vginfo->saved_vg_old_cft);
+		if (svg->saved_vg_old_buf)
+			dm_free(svg->saved_vg_old_buf);
+		if (svg->saved_vg_old_cft)
+			dm_config_destroy(svg->saved_vg_old_cft);
 
-		if (vginfo->saved_vg_old) {
+		if (svg->saved_vg_old) {
 			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
-				vgl->vg = vginfo->saved_vg_old;
-				dm_list_add(&vginfo->saved_vg_to_free, &vgl->list);
+				vgl->vg = svg->saved_vg_old;
+				dm_list_add(&svg->saved_vg_to_free, &vgl->list);
 			}
 		}
 
-		vginfo->saved_vg_old_buf = NULL;
-		vginfo->saved_vg_old_cft = NULL;
-		vginfo->saved_vg_old = NULL;
+		svg->saved_vg_old_buf = NULL;
+		svg->saved_vg_old_cft = NULL;
+		svg->saved_vg_old = NULL;
 	}
 
 	if (inval_new) {
-		if (vginfo->saved_vg_new)
+		if (svg->saved_vg_new)
 			log_debug_cache("lvmcache: inval saved_vg %s new pre %p",
-					vginfo->saved_vg_new->name, vginfo->saved_vg_new);
+					svg->saved_vg_new->name, svg->saved_vg_new);
 
-		if (vginfo->saved_vg_new_buf)
-			dm_free(vginfo->saved_vg_new_buf);
-		if (vginfo->saved_vg_new_cft)
-			dm_config_destroy(vginfo->saved_vg_new_cft);
+		if (svg->saved_vg_new_buf)
+			dm_free(svg->saved_vg_new_buf);
+		if (svg->saved_vg_new_cft)
+			dm_config_destroy(svg->saved_vg_new_cft);
 
-		if (vginfo->saved_vg_new) {
+		if (svg->saved_vg_new) {
 			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
-				vgl->vg = vginfo->saved_vg_new;
-				dm_list_add(&vginfo->saved_vg_to_free, &vgl->list);
+				vgl->vg = svg->saved_vg_new;
+				dm_list_add(&svg->saved_vg_to_free, &vgl->list);
 			}
 		}
 
-		vginfo->saved_vg_new_buf = NULL;
-		vginfo->saved_vg_new_cft = NULL;
-		vginfo->saved_vg_new = NULL;
+		svg->saved_vg_new_buf = NULL;
+		svg->saved_vg_new_cft = NULL;
+		svg->saved_vg_new = NULL;
 	}
 }
 
-static void _saved_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int free_new)
+static void _saved_vg_free(struct saved_vg *svg, int free_old, int free_new)
 {
 	struct vg_list *vgl, *vgl2;
 
 	if (free_old) {
-		if (vginfo->saved_vg_old) {
+		if (svg->saved_vg_old) {
 			log_debug_cache("lvmcache: free saved_vg %s old %p",
-					vginfo->saved_vg_old->name, vginfo->saved_vg_old);
+					svg->saved_vg_old->name, svg->saved_vg_old);
 
-			vginfo->saved_vg_old->saved_in_clvmd = 0;
+			svg->saved_vg_old->saved_in_clvmd = 0;
 		}
 
-		if (vginfo->saved_vg_old_buf)
-			dm_free(vginfo->saved_vg_old_buf);
-		if (vginfo->saved_vg_old_cft)
-			dm_config_destroy(vginfo->saved_vg_old_cft);
-		if (vginfo->saved_vg_old)
-			release_vg(vginfo->saved_vg_old);
+		if (svg->saved_vg_old_buf)
+			dm_free(svg->saved_vg_old_buf);
+		if (svg->saved_vg_old_cft)
+			dm_config_destroy(svg->saved_vg_old_cft);
+		if (svg->saved_vg_old)
+			release_vg(svg->saved_vg_old);
 
-		vginfo->saved_vg_old_buf = NULL;
-		vginfo->saved_vg_old_cft = NULL;
-		vginfo->saved_vg_old = NULL;
+		svg->saved_vg_old_buf = NULL;
+		svg->saved_vg_old_cft = NULL;
+		svg->saved_vg_old = NULL;
 
-		dm_list_iterate_items_safe(vgl, vgl2, &vginfo->saved_vg_to_free) {
+		dm_list_iterate_items_safe(vgl, vgl2, &svg->saved_vg_to_free) {
 			log_debug_cache("lvmcache: free saved_vg_to_free %s %p",
 					vgl->vg->name, vgl->vg);
 
@@ -276,111 +294,144 @@ static void _saved_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int fre
 	}
 
 	if (free_new) {
-		if (vginfo->saved_vg_new) {
+		if (svg->saved_vg_new) {
 			log_debug_cache("lvmcache: free saved_vg %s new pre %p",
-					vginfo->saved_vg_new->name, vginfo->saved_vg_new);
+					svg->saved_vg_new->name, svg->saved_vg_new);
 
-			vginfo->saved_vg_new->saved_in_clvmd = 0;
+			svg->saved_vg_new->saved_in_clvmd = 0;
 		}
 
-		if (vginfo->saved_vg_new_buf)
-			dm_free(vginfo->saved_vg_new_buf);
-		if (vginfo->saved_vg_new_cft)
-			dm_config_destroy(vginfo->saved_vg_new_cft);
-		if (vginfo->saved_vg_new)
-			release_vg(vginfo->saved_vg_new);
+		if (svg->saved_vg_new_buf)
+			dm_free(svg->saved_vg_new_buf);
+		if (svg->saved_vg_new_cft)
+			dm_config_destroy(svg->saved_vg_new_cft);
+		if (svg->saved_vg_new)
+			release_vg(svg->saved_vg_new);
 
-		vginfo->saved_vg_new_buf = NULL;
-		vginfo->saved_vg_new_cft = NULL;
-		vginfo->saved_vg_new = NULL;
+		svg->saved_vg_new_buf = NULL;
+		svg->saved_vg_new_cft = NULL;
+		svg->saved_vg_new = NULL;
 	}
 }
 
 static void _drop_metadata(const char *vgname, int drop_precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
+	struct saved_vg *svg;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
+	if (!(svg = _saved_vg_from_vgid(vginfo->vgid)))
+		return;
+
 	if (drop_precommitted)
-		_saved_vg_free(vginfo, 0, 1);
+		_saved_vg_free(svg, 0, 1);
 	else
-		_saved_vg_free(vginfo, 1, 1);
+		_saved_vg_free(svg, 1, 1);
 }
 
 void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 {
-	struct lvmcache_vginfo *vginfo;
+	struct saved_vg *svg;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 	struct volume_group *save_vg = NULL;
-	struct dm_config_tree *susp_cft = NULL;
-	char *susp_buf = NULL;
+	struct dm_config_tree *save_cft = NULL;
+	const struct format_type *fmt;
+	char *save_buf = NULL;
 	size_t size;
 	int new = precommitted;
 	int old = !precommitted;
 
-	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id)))
-		goto_bad;
+	if (!(svg = _saved_vg_from_vgid((const char *)&vg->id))) {
+		/* Nothing is saved yet for this vg */
 
-	/* already saved */
-	if (old && vginfo->saved_vg_old &&
-	    (vginfo->saved_vg_old->seqno == vg->seqno))
-		return;
+		if (!(svg = dm_zalloc(sizeof(*svg))))
+			return;
 
-	/* already saved */
-	if (new && vginfo->saved_vg_new &&
-	    (vginfo->saved_vg_new->seqno == vg->seqno))
-		return;
+		dm_list_init(&svg->saved_vg_to_free);
+
+		dm_strncpy(svg->vgid, (const char *)vg->id.uuid, sizeof(svg->vgid));
+
+		if (!dm_hash_insert(_saved_vg_hash, svg->vgid, svg)) {
+			log_error("lvmcache: failed to insert saved_vg %s", svg->vgid);
+			return;
+		}
+	} else {
+		/* Nothing to do if we've already saved this seqno */
+
+		if (old && svg->saved_vg_old && (svg->saved_vg_old->seqno == vg->seqno))
+			return;
+
+		if (new && svg->saved_vg_new && (svg->saved_vg_new->seqno == vg->seqno))
+			return;
+
+		/* Invalidate the existing saved_vg that will be replaced */
+
+		_saved_vg_inval(svg, old, new);
+	}
 
-	_saved_vg_inval(vginfo, old, new);
 
-	if (!(size = export_vg_to_buffer(vg, &susp_buf)))
+	if (!(size = export_vg_to_buffer(vg, &save_buf)))
 		goto_bad;
 
+	fmt = vg->fid->fmt;
 	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = vginfo->vgname;
-	fic.context.vg_ref.vg_id = vginfo->vgid;
-	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
+	fic.context.vg_ref.vg_name = vg->name;
+	fic.context.vg_ref.vg_id = svg->vgid;
+
+	if (!(fid = fmt->ops->create_instance(fmt, &fic)))
 		goto_bad;
 
-	if (!(susp_cft = config_tree_from_string_without_dup_node_check(susp_buf)))
+	if (!(save_cft = config_tree_from_string_without_dup_node_check(save_buf)))
 		goto_bad;
 
-	if (!(save_vg = import_vg_from_config_tree(susp_cft, fid)))
+	if (!(save_vg = import_vg_from_config_tree(save_cft, fid)))
 		goto_bad;
 
+	dm_free(save_buf);
+	dm_config_destroy(save_cft);
+
 	save_vg->saved_in_clvmd = 1;
 
 	if (old) {
-		vginfo->saved_vg_old_buf = susp_buf;
-		vginfo->saved_vg_old_cft = susp_cft;
-		vginfo->saved_vg_old = save_vg;
-		log_debug_cache("lvmcache saved old vg %s seqno %d %p",
+		/*
+		svg->saved_vg_old_buf = save_buf;
+		svg->saved_vg_old_cft = save_cft;
+		*/
+		svg->saved_vg_old = save_vg;
+		log_debug_cache("lvmcache: saved old vg %s seqno %d %p",
 				save_vg->name, save_vg->seqno, save_vg);
 	} else {
-		vginfo->saved_vg_new_buf = susp_buf;
-		vginfo->saved_vg_new_cft = susp_cft;
-		vginfo->saved_vg_new = save_vg;
-		log_debug_cache("lvmcache saved pre vg %s seqno %d %p",
+		/*
+		svg->saved_vg_new_buf = save_buf;
+		svg->saved_vg_new_cft = save_cft;
+		*/
+		svg->saved_vg_new = save_vg;
+		log_debug_cache("lvmcache: saved pre vg %s seqno %d %p",
 				save_vg->name, save_vg->seqno, save_vg);
 	}
 	return;
 
 bad:
-	_saved_vg_inval(vginfo, old, new);
-	log_debug_cache("lvmcache failed to save pre %d vg %s", precommitted, vg->name);
+	if (save_buf)
+		dm_free(save_buf);
+	if (save_cft)
+		dm_config_destroy(save_cft);
+
+	_saved_vg_inval(svg, old, new);
+	log_debug_cache("lvmcache: failed to save pre %d vg %s", precommitted, vg->name);
 }
 
 struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 {
-	struct lvmcache_vginfo *vginfo;
+	struct saved_vg *svg;
 	struct volume_group *vg = NULL;
 	int new = precommitted;
 	int old = !precommitted;
 
-	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
+	if (!(svg = _saved_vg_from_vgid(vgid)))
 		goto out;
 
 	/*
@@ -389,118 +440,116 @@ struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 	 */
 
 	if (new)
-		vg = vginfo->saved_vg_new;
+		vg = svg->saved_vg_new;
 	else if (old)
-		vg = vginfo->saved_vg_old;
+		vg = svg->saved_vg_old;
 
 	if (vg && old) {
-		if (!vginfo->saved_vg_new)
+		if (!svg->saved_vg_new)
 			log_debug_cache("lvmcache: get old saved_vg %d %s %p",
 					vg->seqno, vg->name, vg);
 		else
 			log_debug_cache("lvmcache: get old saved_vg %d %s %p new is %d %p",
 					vg->seqno, vg->name, vg,
-					vginfo->saved_vg_new->seqno,
-					vginfo->saved_vg_new);
+					svg->saved_vg_new->seqno,
+					svg->saved_vg_new);
 	}
 
 	if (vg && new) {
-		if (!vginfo->saved_vg_old)
+		if (!svg->saved_vg_old)
 			log_debug_cache("lvmcache: get new (pre) saved_vg %d %s %p",
 					vg->seqno, vg->name, vg);
 		else
 			log_debug_cache("lvmcache: get new (pre) saved_vg %d %s %p old is %d %p",
 					vg->seqno, vg->name, vg,
-					vginfo->saved_vg_old->seqno,
-					vginfo->saved_vg_old);
+					svg->saved_vg_old->seqno,
+					svg->saved_vg_old);
 
-		if (vginfo->saved_vg_old && (vginfo->saved_vg_old->seqno < vg->seqno)) {
+		if (svg->saved_vg_old && (svg->saved_vg_old->seqno < vg->seqno)) {
 			log_debug_cache("lvmcache: inval saved_vg_old %d %p for new %d %p %s",
-					vginfo->saved_vg_old->seqno, vginfo->saved_vg_old,
+					svg->saved_vg_old->seqno, svg->saved_vg_old,
 					vg->seqno, vg, vg->name);
 
-			_saved_vg_inval(vginfo, 1, 0);
+			_saved_vg_inval(svg, 1, 0);
 		}
 	}
 
-	if (!vg && new && vginfo->saved_vg_old)
+	if (!vg && new && svg->saved_vg_old)
 		log_warn("lvmcache_get_saved_vg pre %d wanted new but only have old %d %s",
 			 precommitted,
-			 vginfo->saved_vg_old->seqno,
-			 vginfo->saved_vg_old->name);
+			 svg->saved_vg_old->seqno,
+			 svg->saved_vg_old->name);
 
-	if (!vg && old && vginfo->saved_vg_new)
+	if (!vg && old && svg->saved_vg_new)
 		log_warn("lvmcache_get_saved_vg pre %d wanted old but only have new %d %s",
 			 precommitted,
-			 vginfo->saved_vg_new->seqno,
-			 vginfo->saved_vg_new->name);
+			 svg->saved_vg_new->seqno,
+			 svg->saved_vg_new->name);
 out:
 	if (!vg)
-		log_debug_cache("lvmcache no saved vg %s pre %d", vgid, precommitted);
+		log_debug_cache("lvmcache: no saved pre %d %s", precommitted, vgid);
 	return vg;
 }
 
 struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid)
 {
-	struct lvmcache_vginfo *vginfo;
+	struct saved_vg *svg;
 	struct volume_group *vg = NULL;
 	int old = 0;
 	int new = 0;
 
-	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
+	if (!(svg = _saved_vg_from_vgid(vgid)))
 		goto out;
 
-	if (vginfo->saved_vg_committed) {
-		vg = vginfo->saved_vg_new;
+	if (svg->saved_vg_committed) {
+		vg = svg->saved_vg_new;
 		new = 1;
 	} else {
-		vg = vginfo->saved_vg_old;
+		vg = svg->saved_vg_old;
 		old = 1;
 	}
 
 	if (vg && old) {
-		if (!vginfo->saved_vg_new)
+		if (!svg->saved_vg_new)
 			log_debug_cache("lvmcache: get_latest old saved_vg %d %s %p",
 					vg->seqno, vg->name, vg);
 		else
 			log_debug_cache("lvmcache: get_latest old saved_vg %d %s %p new is %d %p",
 					vg->seqno, vg->name, vg,
-					vginfo->saved_vg_new->seqno,
-					vginfo->saved_vg_new);
+					svg->saved_vg_new->seqno,
+					svg->saved_vg_new);
 	}
 
 	if (vg && new) {
-		if (!vginfo->saved_vg_old)
+		if (!svg->saved_vg_old)
 			log_debug_cache("lvmcache: get_latest new (pre) saved_vg %d %s %p",
 					vg->seqno, vg->name, vg);
 		else
 			log_debug_cache("lvmcache: get_latest new (pre) saved_vg %d %s %p old is %d %p",
 					vg->seqno, vg->name, vg,
-					vginfo->saved_vg_old->seqno,
-					vginfo->saved_vg_old);
+					svg->saved_vg_old->seqno,
+					svg->saved_vg_old);
 
-		if (vginfo->saved_vg_old && (vginfo->saved_vg_old->seqno < vg->seqno)) {
+		if (svg->saved_vg_old && (svg->saved_vg_old->seqno < vg->seqno)) {
 			log_debug_cache("lvmcache: inval saved_vg_old %d %p for new %d %p %s",
-					vginfo->saved_vg_old->seqno, vginfo->saved_vg_old,
+					svg->saved_vg_old->seqno, svg->saved_vg_old,
 					vg->seqno, vg, vg->name);
 
-			_saved_vg_inval(vginfo, 1, 0);
+			_saved_vg_inval(svg, 1, 0);
 		}
 	}
 out:
 	if (!vg)
-		log_debug_cache("lvmcache no saved vg %s", vgid);
+		log_debug_cache("lvmcache: no saved vg latest %s", vgid);
 	return vg;
 }
 
 void lvmcache_drop_saved_vgid(const char *vgid)
 {
-	struct lvmcache_vginfo *vginfo;
+	struct saved_vg *svg;
 
-	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
-		return;
-
-	_saved_vg_inval(vginfo, 1, 1);
+	if ((svg = _saved_vg_from_vgid(vgid)))
+		_saved_vg_inval(svg, 1, 1);
 }
 
 /*
@@ -511,15 +560,20 @@ void lvmcache_drop_saved_vgid(const char *vgid)
 void lvmcache_commit_metadata(const char *vgname)
 {
 	struct lvmcache_vginfo *vginfo;
+	struct saved_vg *svg;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
-	vginfo->saved_vg_committed = 1;
+	if ((svg = _saved_vg_from_vgid(vginfo->vgid)))
+		svg->saved_vg_committed = 1;
 }
 
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 {
+	if (!_saved_vg_hash)
+		return;
+
 	if (lvmcache_vgname_is_locked(VG_GLOBAL))
 		return;
 
@@ -597,11 +651,6 @@ int lvmcache_verify_lock_order(const char *vgname)
 
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
 {
-	if (!_lock_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
-		return;
-	}
-
 	if (dm_hash_lookup(_lock_hash, vgname))
 		log_error(INTERNAL_ERROR "Nested locking attempted on VG %s.",
 			  vgname);
@@ -1230,28 +1279,6 @@ next:
 	goto next;
 }
 
-static void _move_saved_vg(struct lvmcache_vginfo *to, struct lvmcache_vginfo *from)
-{
-	to->saved_vg_committed	= from->saved_vg_committed;
-	to->saved_vg_old_buf	= from->saved_vg_old_buf;
-	to->saved_vg_old_cft	= from->saved_vg_old_cft;
-	to->saved_vg_old	= from->saved_vg_old;
-	to->saved_vg_new_buf	= from->saved_vg_new_buf;
-	to->saved_vg_new_cft	= from->saved_vg_new_cft;
-	to->saved_vg_new	= from->saved_vg_new;
-
-	from->saved_vg_committed= 0;
-	from->saved_vg_old_buf	= NULL;
-	from->saved_vg_old_cft	= NULL;
-	from->saved_vg_old	= NULL;
-	from->saved_vg_new_buf	= NULL;
-	from->saved_vg_new_cft	= NULL;
-	from->saved_vg_new	= NULL;
-
-	dm_list_init(&to->saved_vg_to_free);
-	dm_list_splice(&to->saved_vg_to_free, &from->saved_vg_to_free);
-}
-
 /*
  * The initial label_scan at the start of the command is done without
  * holding VG locks.  Then for each VG identified during the label_scan,
@@ -1295,7 +1322,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 {
 	struct dm_list devs;
 	struct device_list *devl;
-	struct lvmcache_vginfo *vginfo, *tmp;
+	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info, *info2;
 
 	if (lvmetad_used())
@@ -1325,15 +1352,6 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 		dm_list_add(&devs, &devl->list);
 	}
 
-	/*
-	 * clvmd stashes some copies of a vg on the vginfo struct
-	 * (FIXME: it shouldn't abuse vginfo and should use its own struct),
-	 * so when we replace vginfo in clvmd, we need to move the stashed
-	 * vg's from the old vginfo struct to the new vginfo struct.
-	 */
-	if (cmd->is_clvmd && (tmp = dm_zalloc(sizeof(*tmp))))
-		_move_saved_vg(tmp, vginfo);
-
 	dm_list_iterate_items_safe(info, info2, &vginfo->infos)
 		lvmcache_del(info);
 
@@ -1351,11 +1369,6 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 		return 0;
 	}
 
-	if (cmd->is_clvmd && tmp) {
-		_move_saved_vg(vginfo, tmp);
-		dm_free(tmp);
-	}
-
 	return 1;
 }
 
@@ -1409,11 +1422,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	_scanning_in_progress = 1;
 
-	if (!_vgname_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
-		goto out;
-	}
-
 	/* FIXME: can this happen? */
 	if (!cmd->full_filter) {
 		log_error("label scan is missing full filter");
@@ -1708,7 +1716,6 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 	dm_free(vginfo->system_id);
 	dm_free(vginfo->vgname);
 	dm_free(vginfo->creation_host);
-	_saved_vg_free(vginfo, 1, 1);
 
 	if (*vginfo->vgid && _vgid_hash &&
 	    lvmcache_vginfo_from_vgid(vginfo->vgid) == vginfo)
@@ -1922,7 +1929,6 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 			return 0;
 		}
 		dm_list_init(&vginfo->infos);
-		dm_list_init(&vginfo->saved_vg_to_free);
 
 		/*
 		 * A different VG (different uuid) can exist with the same name.
@@ -2045,11 +2051,6 @@ out:
 
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 {
-	if (!_lock_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
-		return 0;
-	}
-
 	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
 }
 
@@ -2419,6 +2420,11 @@ static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
 			  dm_hash_get_key(_lock_hash, n));
 }
 
+static void _destroy_saved_vg(struct saved_vg *svg)
+{
+	_saved_vg_free(svg, 1, 1);
+}
+
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 {
 	struct dm_hash_node *n;
@@ -2455,6 +2461,12 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 		_lock_hash = NULL;
 	}
 
+	if (_saved_vg_hash) {
+		dm_hash_iter(_saved_vg_hash, (dm_hash_iterate_fn) _destroy_saved_vg);
+		dm_hash_destroy(_saved_vg_hash);
+		_saved_vg_hash = NULL;
+	}
+
 	if (!dm_list_empty(&_vginfos))
 		log_error(INTERNAL_ERROR "_vginfos list should be empty");
 	dm_list_init(&_vginfos);
@@ -2475,9 +2487,16 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	_destroy_duplicate_device_list(&_found_duplicate_devs); /* should be empty anyway */
 	_found_duplicate_pvs = 0;
 
-	if (retain_orphans)
-		if (!init_lvmcache_orphans(cmd))
-			stack;
+	if (retain_orphans) {
+		struct format_type *fmt;
+
+		lvmcache_init(cmd);
+
+		dm_list_iterate_items(fmt, &cmd->formats) {
+			if (!lvmcache_add_orphan_vginfo(fmt->orphan_vg_name, fmt))
+				stack;
+		}
+	}
 }
 
 int lvmcache_pvid_is_locked(const char *pvid) {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 20ce74b..797ff21 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -63,7 +63,7 @@ struct lvmcache_vgsummary {
 	int seqno;
 };
 
-int lvmcache_init(void);
+int lvmcache_init(struct cmd_context *cmd);
 void lvmcache_allow_reads_with_lvmetad(void);
 
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
@@ -213,11 +213,15 @@ int lvmcache_get_vg_devs(struct cmd_context *cmd,
 			 struct dm_list *devs);
 void lvmcache_set_independent_location(const char *vgname);
 
+int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
+
+/*
+ * These are clvmd-specific functions and are not related to lvmcache.
+ * FIXME: rename these with a clvm_ prefix in place of lvmcache_
+ */
 void lvmcache_save_vg(struct volume_group *vg, int precommitted);
 struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted);
 struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid);
 void lvmcache_drop_saved_vgid(const char *vgid);
 
-int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
-
 #endif
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 76e15e0..4fdd62f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1814,7 +1814,7 @@ out:
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(unsigned is_long_lived,
+struct cmd_context *create_toolcontext(unsigned is_clvmd,
 				       const char *system_dir,
 				       unsigned set_buffering,
 				       unsigned threaded,
@@ -1841,7 +1841,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		log_error("Failed to allocate command context");
 		return NULL;
 	}
-	cmd->is_long_lived = is_long_lived;
+	cmd->is_long_lived = is_clvmd;
+	cmd->is_clvmd = is_clvmd;
 	cmd->threaded = threaded ? 1 : 0;
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
@@ -1970,6 +1971,10 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_init_formats(cmd))
 		goto_out;
 
+	if (!lvmcache_init(cmd))
+		goto_out;
+
+	/* FIXME: move into lvmcache_init */
 	if (!init_lvmcache_orphans(cmd))
 		goto_out;
 
@@ -2191,6 +2196,9 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_formats(cmd))
 		return_0;
 
+	if (!lvmcache_init(cmd))
+		return_0;
+
 	if (!init_lvmcache_orphans(cmd))
 		return_0;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 1d9de0a..34222ee 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -236,7 +236,7 @@ struct cmd_context {
  * system_dir may be NULL to use the default value.
  * The environment variable LVM_SYSTEM_DIR always takes precedence.
  */
-struct cmd_context *create_toolcontext(unsigned is_long_lived,
+struct cmd_context *create_toolcontext(unsigned is_clvmd,
 				       const char *system_dir,
 				       unsigned set_buffering,
 				       unsigned threaded,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d65daaf..16fd6fa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4599,7 +4599,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 
 	if (!(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
 		log_debug_metadata("Reading VG by vgid %.8s no VG name found, retrying.", vgid);
-		lvmcache_destroy(cmd, 0, 0);
+		lvmcache_destroy(cmd, 1, 0);
 		label_scan_destroy(cmd);
 		lvmcache_label_scan(cmd);
 		warn_flags |= SKIP_RESCAN;
@@ -4630,7 +4630,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 	return vg;
 
  scan:
-	lvmcache_destroy(cmd, 0, 0);
+	lvmcache_destroy(cmd, 1, 0);
 	label_scan_destroy(cmd);
 	lvmcache_label_scan(cmd);
 	warn_flags |= SKIP_RESCAN;
diff --git a/tools/toollib.c b/tools/toollib.c
index 53e7f9a..e633cdd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -111,7 +111,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 	if (!skip_lvm) {
 		reset_locking();
 		lvmcache_destroy(cmd, 1, 1);
-		if (!lvmcache_init())
+		if (!lvmcache_init(cmd))
 			/* FIXME Clean up properly here */
 			_exit(ECMD_FAILED);
 	}
@@ -4622,7 +4622,7 @@ int process_each_pv(struct cmd_context *cmd,
 		log_verbose("Some PVs were not found in first search, retrying.");
 
 		lvmcache_destroy(cmd, 0, 0);
-		if (!lvmcache_init()) {
+		if (!lvmcache_init(cmd)) {
 			log_error("Failed to initalize lvm cache.");
 			ret_max = ECMD_FAILED;
 			goto out;


