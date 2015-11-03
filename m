From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Nov 2015 19:24:27 +0000 (UTC)
Subject: master - lvmetad: refactor and document
Message-ID: <20151103192427.A1B8760F81@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e6377f5bab83e2740bbcdd1e7e3d654e912e937
Commit:        4e6377f5bab83e2740bbcdd1e7e3d654e912e937
Parent:        4b47ee529639c7dd5ced56d7729747fe26b458e7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 18 09:42:38 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 3 13:18:27 2015 -0600

lvmetad: refactor and document

update_metadata and pv_found update the cached metadata;
these are both reworked to improve the code, organize it
by each possible state and transition, make it much more
clear what's changing, add more error checking and
handling, and add comments.

The state and content of the cache (hash tables) does not
change (apart from some things that didn't work before),
and the communication to/from commands does not change.
The implementation and organization of the code making
the state changes does change significantly.

One detail related to the content of the cache does change:
different hash tables do not reference the same memory any more;
the target values in each hash table are allocated and freed
individually.
---
 daemons/lvmetad/lvmetad-core.c | 1845 ++++++++++++++++++++++++++++++++++------
 1 files changed, 1565 insertions(+), 280 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 64d998e..8e911cd 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -30,6 +30,82 @@
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
 
 /*
+ * cache states:
+ * . Empty: no devices visible to the system have been added to lvmetad
+ * . Scanning: some devices visible to the system have been added to lvmetad
+ * . Initialized: all devices visible to the system have been added to lvmetad
+ * . Outdated: event on system or storage is not yet processed by lvmetad
+ *   Outdated variations:
+ *   - MissingDev: device added to system, not yet added to lvmetad
+ *   - RemovedDev: device removed from system, not yet removed from lvmetad
+ *   - MissingVG: new vg is written on disk, not yet added to lvmetad
+ *   - RemovedVG: vg is removed on disk, not yet removed in lvmetad
+ *   - ChangedVG: vg metadata is changed on disk, not yet updated in lvmetad
+ *   - MissingPV: new pv is written on disk, not yet added to in lvmetad
+ *   - RemovedPV: pv is removed on disk, not yet removed in lvmetad
+ *   - ChangedPV: pv metadata is changed on disk, not yet updated in lvmetad
+ * . Updated: events have been processed by lvmetad
+ *
+ * state transitions:
+ * . Empty -> Scanning
+ * . Scanning -> Initialized
+ * . Initialized -> Scanning
+ * . Initialized -> Outdated
+ * . Outdated -> Updated
+ * . Updated -> Outdated
+ * . Updated -> Scanning
+ * . Outdated -> Scanning
+ *
+ * state transitions caused by:
+ * . Empty is caused by:
+ *   - starting/restarting lvmetad
+ * . Scanning is caused by:
+ *   - running pvscan --cache
+ *   - running any command with different global_filter (token mismatch)
+ *   - running any command while lvmetad is Empty
+ *   - running a report/display command with --foreign
+ *   - running a report/display command with --shared
+ *   - running a command using lvmlockd global lock where global state is changed
+ * . Initialized is caused by:
+ *   - completion of Scanning
+ * . Outdated is caused by:
+ *   - device being added or removed on the system
+ *   - creating/removing/changing a VG
+ *   - creating/removing/changing a PV
+ * . Updated is caused by:
+ *   - receiving and processing all events
+ *
+ * request handling:
+ * . Empty: short period during startup, token error returned
+ * . Scanning: should be very short, lvmetad responds to requests with
+ *   the token error "updating"
+ * . Initialized: lvmetad responds to requests
+ * . Updated: lvmetad responds to requests
+ * . Outdated: should be very short, lvmetad responds to requests
+ *
+ * In general, the cache state before and after the transition
+ * "Updated -> Scanning -> Initialized" should match, unless
+ * events occur during that transition.
+ *
+ * The Scanning state includes:
+ * . receive a request to set the token to "updating" (Scanning state begins.)
+ * . receive a pv_clear_all request to clear current cache
+ * . receive a number of pv_found events to repopulate cache
+ * . receive a request to set the token to a hash value (Initialized state begins.)
+ *
+ * The transition from Outdated to Updated depends on lvm commands
+ * sending events to lvmetad, i.e. pv_found, pv_gone, vg_update,
+ * vg_remove.  Prior to receiving these events, lvmetad is not aware
+ * that it is in the Outdated state.
+ *
+ * When using a shared VG with lvmlockd, the Outdated state can last a
+ * longer time, but it won't be used in that state.  lvmlockd forces a
+ * transition "Outdated -> Scanning -> Initialized" before the cache
+ * is used.
+ */
+
+
+/*
  * valid/invalid state of cached metadata
  *
  * Normally when using lvmetad, the state is kept up-to-date through a
@@ -235,7 +311,7 @@ static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	/* We never remove items from s->lock.vg => the pointer remains valid. */
 	pthread_mutex_unlock(&s->lock.vg_lock_map);
 
-	DEBUGLOG(s, "locking VG %s", id);
+	/* DEBUGLOG(s, "locking VG %s", id); */
 	pthread_mutex_lock(vg);
 
 	/* Protect against structure changes of the vgid_to_metadata hash. */
@@ -253,7 +329,7 @@ bad:
 static void unlock_vg(lvmetad_state *s, const char *id) {
 	pthread_mutex_t *vg;
 
-	DEBUGLOG(s, "unlocking VG %s", id);
+	/* DEBUGLOG(s, "unlocking VG %s", id); */
 	/* Protect the s->lock.vg structure from concurrent access. */
 	pthread_mutex_lock(&s->lock.vg_lock_map);
 	if ((vg = dm_hash_lookup(s->lock.vg, id)))
@@ -305,43 +381,48 @@ static void merge_pvmeta(struct dm_config_node *pv, struct dm_config_node *pvmet
 	pvmeta->parent = pv;
 }
 
-/* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
- * this function. */
+/*
+ * Either the "big" vgs lock, or a per-vg lock needs to be held before entering
+ * this function.
+ *
+ * cft and vg is data being sent to the caller.
+ */
+
 static int update_pv_status(lvmetad_state *s,
 			    struct dm_config_tree *cft,
-			    struct dm_config_node *vg, int act)
+			    struct dm_config_node *vg)
 {
 	struct dm_config_node *pv;
-	int complete = 1;
 	const char *uuid;
 	struct dm_config_tree *pvmeta;
+	struct dm_config_node *pvmeta_cn;
+	int ret = 1;
 
 	lock_pvid_to_pvmeta(s);
 
 	for (pv = pvs(vg); pv; pv = pv->sib) {
-		if (!(uuid = dm_config_find_str(pv->child, "id", NULL)))
+		if (!(uuid = dm_config_find_str(pv->child, "id", NULL))) {
+			ERROR(s, "update_pv_status found no uuid for PV");
 			continue;
+		}
 
 		pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
-		if (act) {
-			set_flag(cft, pv, "status", "MISSING", !pvmeta);
-			if (pvmeta) {
-				struct dm_config_node *pvmeta_cn =
-					dm_config_clone_node(cft, pvmeta->root->child, 1);
-				merge_pvmeta(pv, pvmeta_cn);
-			}
-		}
-		if (!pvmeta) {
-			complete = 0;
-			if (!act) { /* optimisation */
-				unlock_pvid_to_pvmeta(s);
-				return complete;
+
+		set_flag(cft, pv, "status", "MISSING", !pvmeta);
+
+		if (pvmeta) {
+			if (!(pvmeta_cn = dm_config_clone_node(cft, pvmeta->root->child, 1))) {
+				ERROR(s, "update_pv_status out of memory");
+				ret = 0;
+				goto out;
 			}
+
+			merge_pvmeta(pv, pvmeta_cn);
 		}
 	}
+out:
 	unlock_pvid_to_pvmeta(s);
-
-	return complete;
+	return ret;
 }
 
 static struct dm_config_node *add_last_node(struct dm_config_tree *cft, const char *node_name)
@@ -415,6 +496,8 @@ static response pv_list(lvmetad_state *s, request r)
 	const char *id;
 	response res = { 0 };
 
+	DEBUGLOG(s, "pv_list");
+
 	buffer_init( &res.buffer );
 
 	if (!(res.cft = dm_config_create()))
@@ -446,6 +529,8 @@ static response pv_lookup(lvmetad_state *s, request r)
 	response res = { 0 };
 	struct dm_config_node *pv;
 
+	DEBUGLOG(s, "pv_lookup pvid %s", pvid);
+
 	buffer_init( &res.buffer );
 
 	if (!pvid && !devt)
@@ -492,6 +577,8 @@ static response vg_list(lvmetad_state *s, request r)
 	const char *name;
 	response res = { 0 };
 
+	DEBUGLOG(s, "vg_list");
+
 	buffer_init( &res.buffer );
 
 	if (!(res.cft = dm_config_create()))
@@ -572,7 +659,7 @@ static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvi
 	     dm_config_find_int64(pvmeta->root, "pvmeta/mda1/ignore", 1)))
 		return;
 
-	WARN(s, "PV %s has outdated metadata", pvid);
+	ERROR(s, "PV %s has outdated metadata for VG %s", pvid, vgid);
 
 	outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
 	if (!outdated_pvs) {
@@ -637,22 +724,42 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	buffer_init( &res.buffer );
 
-	DEBUGLOG(s, "vg_lookup: uuid = %s, name = %s", uuid, name);
+	if (!uuid && !name) {
+		ERROR(s, "vg_lookup with no uuid or name");
+		return reply_unknown("VG not found");
+
+	} else if (!uuid || !name) {
+		DEBUGLOG(s, "vg_lookup vgid %s name %s needs lookup",
+			 uuid ?: "none", name ?: "none");
 
-	if (!uuid || !name) {
 		lock_vgid_to_metadata(s);
 		if (name && !uuid)
 			uuid = dm_hash_lookup(s->vgname_to_vgid, name);
-		if (uuid && !name)
+		else if (uuid && !name)
 			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
 		unlock_vgid_to_metadata(s);
-	}
 
-	DEBUGLOG(s, "vg_lookup: updated uuid = %s, name = %s", uuid, name);
+		if (!uuid || !name)
+			return reply_unknown("VG not found");
 
-	/* Check the name here. */
-	if (!uuid || !name)
-		return reply_unknown("VG not found");
+	} else {
+		char *name_lookup = dm_hash_lookup(s->vgid_to_vgname, uuid);
+		char *uuid_lookup = dm_hash_lookup(s->vgname_to_vgid, name);
+
+		/* FIXME: comment out these sanity checks when not testing */
+
+		if (!name_lookup || !uuid_lookup) {
+			ERROR(s, "vg_lookup vgid %s name %s found incomplete mapping uuid %s name %s",
+			      uuid, name, uuid_lookup ?: "none", name_lookup ?: "none");
+			return reply_unknown("VG mapping incomplete");
+		} else if (strcmp(name_lookup, name) || strcmp(uuid_lookup, uuid)) {
+			ERROR(s, "vg_lookup vgid %s name %s found inconsistent mapping uuid %s name %s",
+			      uuid, name, uuid_lookup, name_lookup);
+			return reply_unknown("VG mapping inconsistent");
+		}
+	}
+
+	DEBUGLOG(s, "vg_lookup vgid %s name %s", uuid ?: "none", name ?: "none");
 
 	cft = lock_vg(s, uuid);
 	if (!cft || !cft->root) {
@@ -662,24 +769,24 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	metadata = cft->root;
 	if (!(res.cft = dm_config_create()))
-		goto bad;
+		goto nomem_un;
 
 	/* The response field */
 	if (!(res.cft->root = n = dm_config_create_node(res.cft, "response")))
-		goto bad;
+		goto nomem_un;
 
 	if (!(n->v = dm_config_create_value(cft)))
-		goto bad;
+		goto nomem_un;
 
 	n->parent = res.cft->root;
 	n->v->type = DM_CFG_STRING;
 	n->v->v.str = "OK";
 
 	if (!(n = n->sib = dm_config_create_node(res.cft, "name")))
-		goto bad;
+		goto nomem_un;
 
 	if (!(n->v = dm_config_create_value(res.cft)))
-		goto bad;
+		goto nomem_un;
 
 	n->parent = res.cft->root;
 	n->v->type = DM_CFG_STRING;
@@ -687,27 +794,32 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	/* The metadata section */
 	if (!(n = n->sib = dm_config_clone_node(res.cft, metadata, 1)))
-		goto bad;
+		goto nomem_un;
 	n->parent = res.cft->root;
 	unlock_vg(s, uuid);
 
-	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
+	if (!update_pv_status(s, res.cft, n))
+		goto nomem;
 	chain_outdated_pvs(s, uuid, res.cft, n);
 
-        if (s->flags & GLFL_INVALID)
-                add_last_node(res.cft, "global_invalid");
+	if (s->flags & GLFL_INVALID)
+		add_last_node(res.cft, "global_invalid");
 
 	info = dm_hash_lookup(s->vgid_to_info, uuid);
 	if (info && (info->flags & VGFL_INVALID)) {
-		n = add_last_node(res.cft, "vg_invalid");
-		if (!n)
-			goto bad;
+		if (!add_last_node(res.cft, "vg_invalid"))
+			goto nomem;
 	}
 
 	return res;
-bad:
+
+nomem_un:
 	unlock_vg(s, uuid);
-	return reply_fail("out of memory");
+nomem:
+	reply_fail("out of memory");
+	ERROR(s, "vg_lookup vgid %s name %s out of memory.", uuid ?: "none", name ?: "none");
+	ERROR(s, "lvmetad could not be updated and is aborting.");
+	exit(EXIT_FAILURE);
 }
 
 static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_pvids);
@@ -722,7 +834,8 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 	struct dm_hash_table *to_check;
 	struct dm_hash_node *n;
 	const char *pvid;
-	const char *vgid_old;
+	char *vgid_old;
+	char *vgid_dup;
 	const char *check_vgid;
 	int r = 0;
 
@@ -730,22 +843,39 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 		return 0;
 
 	if (!(to_check = dm_hash_create(32)))
-		return 0;
+		goto abort_daemon;
 
 	for (pv = pvs(vg->root); pv; pv = pv->sib) {
-		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
+		if (!(pvid = dm_config_find_str(pv->child, "id", NULL))) {
+			ERROR(s, "PV has no id for update_pvid_to_vgid");
 			continue;
+		}
 
-		if (mode == REMOVE_EMPTY &&
-		    (vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid)) &&
-		    !dm_hash_insert(to_check, vgid_old, (void*) 1))
-			goto out;
+		vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid);
+
+		if ((mode == REMOVE_EMPTY) && vgid_old) {
+			/* This copies the vgid_old string, doesn't reference it. */
+			if (!dm_hash_insert(to_check, vgid_old, (void*) 1)) {
+				ERROR(s, "update_pvid_to_vgid out of memory for hash insert vgid_old %s", vgid_old);
+				goto abort_daemon;
+			}
+		}
 
 		if (mode == MARK_OUTDATED)
 			mark_outdated_pv(s, vgid, pvid);
 
-		if (!dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid))
-			goto out;
+		if (!(vgid_dup = dm_strdup(vgid))) {
+			ERROR(s, "update_pvid_to_vgid out of memory for vgid %s", vgid);
+			goto abort_daemon;
+		}
+
+		if (!dm_hash_insert(s->pvid_to_vgid, pvid, vgid_dup)) {
+			ERROR(s, "update_pvid_to_vgid out of memory for hash insert vgid %s", vgid_dup);
+			goto abort_daemon;
+		}
+
+		/* pvid_to_vgid no longer references vgid_old */
+		dm_free(vgid_old);
 
 		DEBUGLOG(s, "moving PV %s to VG %s", pvid, vgid);
 	}
@@ -758,42 +888,62 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 	}
 
 	r = 1;
-    out:
 	dm_hash_destroy(to_check);
 
 	return r;
+
+abort_daemon:
+	ERROR(s, "lvmetad could not be updated and is aborting.");
+	exit(EXIT_FAILURE);
 }
 
 /* A pvid map lock needs to be held if update_pvids = 1. */
 static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 {
-	struct dm_config_tree *old, *outdated_pvs;
-	const char *oldname;
+	struct dm_config_tree *meta_lookup;
+	struct dm_config_tree *outdated_pvs_lookup;
+	struct vg_info *info_lookup;
+	char *name_lookup = NULL;
+	char *vgid_lookup = NULL;
+
 	lock_vgid_to_metadata(s);
-	old = dm_hash_lookup(s->vgid_to_metadata, vgid);
-	outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
-	oldname = dm_hash_lookup(s->vgid_to_vgname, vgid);
 
-	if (!old) {
-		unlock_vgid_to_metadata(s);
-		return 0;
-	}
+	/* get data pointers from hash table so they can be freed */
+
+	info_lookup = dm_hash_lookup(s->vgid_to_info, vgid);
+	meta_lookup = dm_hash_lookup(s->vgid_to_metadata, vgid);
+	name_lookup = dm_hash_lookup(s->vgid_to_vgname, vgid);
+	outdated_pvs_lookup = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
+	if (name_lookup)
+		vgid_lookup = dm_hash_lookup(s->vgname_to_vgid, name_lookup);
 
-	assert(oldname);
+	/* remove hash table mappings */
 
-	/* need to update what we have since we found a newer version */
+	dm_hash_remove(s->vgid_to_info, vgid);
 	dm_hash_remove(s->vgid_to_metadata, vgid);
 	dm_hash_remove(s->vgid_to_vgname, vgid);
-	dm_hash_remove(s->vgname_to_vgid, oldname);
 	dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
+	if (name_lookup)
+		dm_hash_remove(s->vgname_to_vgid, name_lookup);
+
 	unlock_vgid_to_metadata(s);
 
+	/* update_pvid_to_vgid will clear/free the pvid_to_vgid hash */
 	if (update_pvids)
-		/* FIXME: What should happen when update fails */
-		update_pvid_to_vgid(s, old, "#orphan", 0);
-	dm_config_destroy(old);
-	if (outdated_pvs)
-		dm_config_destroy(outdated_pvs);
+		update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
+
+	/* free the unmapped data */
+
+	if (info_lookup)
+		dm_free(info_lookup);
+	if (meta_lookup)
+		dm_config_destroy(meta_lookup);
+	if (name_lookup)
+		dm_free(name_lookup);
+	if (outdated_pvs_lookup)
+		dm_config_destroy(outdated_pvs_lookup);
+	if (vgid_lookup)
+		dm_free(vgid_lookup);
 	return 1;
 }
 
@@ -833,118 +983,853 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_p
 	return 1;
 }
 
-/* No locks need to be held. The pointers are never used outside of the scope of
- * this function, so they can be safely destroyed after update_metadata returns
- * (anything that might have been retained is copied). */
-static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid,
-			   struct dm_config_node *metadata, int64_t *oldseq, const char *pvid)
+/*
+ * Remove all hash table references to arg_name and arg_vgid
+ * so that new metadata using this name and/or vgid can be added
+ * without interference previous data.
+ *
+ * This is used if a command updates metadata in the cache,
+ * but update_metadata finds that what's in the cache is not
+ * consistent with a normal transition between old and new
+ * metadata.  If this happens, it assumes that the command
+ * is providing the correct metadata, so it first calls this
+ * function to purge all records of the old metadata so the
+ * new metadata can be added.
+ */
+
+static void _purge_metadata(lvmetad_state *s, const char *arg_name, const char *arg_vgid)
+{
+	char *rem_vgid;
+
+	lock_pvid_to_vgid(s);
+	remove_metadata(s, arg_vgid, 1);
+
+	if ((rem_vgid = dm_hash_lookup(s->vgname_to_vgid, arg_name))) {
+		dm_hash_remove(s->vgname_to_vgid, arg_name);
+		dm_free(rem_vgid);
+	}
+	unlock_pvid_to_vgid(s);
+}
+
+/*
+ * Updates for new vgid and new metadata.
+ *
+ * Remove any existing vg_info struct since it will be
+ * recreated by lvmlockd if/when needed.
+ *
+ * Remove any existing outdated pvs since their metadata
+ * will no longer be associated with this VG.
+ */
+
+static int _update_metadata_new_vgid(lvmetad_state *s,
+				     const char *arg_name,
+				     const char *old_vgid,
+				     const char *new_vgid,
+				     struct dm_config_tree *old_meta,
+				     struct dm_config_tree *new_meta)
 {
-	struct dm_config_tree *cft = NULL;
-	struct dm_config_tree *old;
+	struct vg_info *rem_info;
+	struct dm_config_tree *rem_outdated;
+	char *new_vgid_dup = NULL;
+	char *arg_name_dup = NULL;
+	int abort_daemon = 0;
 	int retval = 0;
-	int seq;
-	int haveseq = -1;
-	const char *oldname = NULL;
-	const char *vgid;
-	char *cfgname;
 
+	if (!(new_vgid_dup = dm_strdup(new_vgid)))
+		goto ret;
+
+	if (!(arg_name_dup = dm_strdup(arg_name)))
+		goto ret;
+
+	lock_vg(s, new_vgid);
+	lock_pvid_to_vgid(s);
 	lock_vgid_to_metadata(s);
-	old = dm_hash_lookup(s->vgid_to_metadata, _vgid);
-	oldname = dm_hash_lookup(s->vgid_to_vgname, _vgid);
+
+	/*
+	 * Temporarily orphan the PVs in the old metadata.
+	 */
+	if (!update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
+		ERROR(s, "update_metadata_new_vgid failed to move PVs for %s old_vgid %s", arg_name, old_vgid);
+		abort_daemon = 1;
+		goto ret;
+	}
+
+	/*
+	 * Remove things related to the old vgid. (like remove_metadata)
+	 */
+
+	if ((rem_info = dm_hash_lookup(s->vgid_to_info, old_vgid))) {
+		dm_hash_remove(s->vgid_to_info, old_vgid);
+		dm_free(rem_info);
+	}
+
+	if ((rem_outdated = dm_hash_lookup(s->vgid_to_outdated_pvs, old_vgid))) {
+		dm_hash_remove(s->vgid_to_outdated_pvs, old_vgid);
+		dm_config_destroy(rem_outdated);
+	}
+
+	dm_hash_remove(s->vgid_to_metadata, old_vgid);
+	dm_config_destroy(old_meta);
+	old_meta = NULL;
+
+	dm_hash_remove(s->vgname_to_vgid, arg_name);
+	dm_hash_remove(s->vgid_to_vgname, old_vgid);
+	dm_free((char *)old_vgid);
+	old_vgid = NULL;
+
+	/*
+	 * Insert things with the new vgid.
+	 */
+
+	if (!dm_hash_insert(s->vgid_to_metadata, new_vgid, new_meta)) {
+		ERROR(s, "update_metadata_new_vgid out of memory for meta hash insert for %s %s", arg_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	if (!dm_hash_insert(s->vgid_to_vgname, new_vgid, arg_name_dup)) {
+		ERROR(s, "update_metadata_new_vgid out of memory for name hash insert for %s %s", arg_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	if (!dm_hash_insert(s->vgname_to_vgid, arg_name, new_vgid_dup)) {
+		ERROR(s, "update_metadata_new_vgid out of memory for vgid hash insert for %s %s", arg_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	/*
+	 * Reassign PVs based on the new metadata.
+	 */
+	if (!update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
+		ERROR(s, "update_metadata_new_name failed to update PVs for %s %s", arg_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	DEBUGLOG(s, "update_metadata_new_vgid is done for %s %s", arg_name, new_vgid);
+	retval = 1;
+out:
 	unlock_vgid_to_metadata(s);
-	lock_vg(s, _vgid);
+	unlock_pvid_to_vgid(s);
+	unlock_vg(s, new_vgid);
+ret:
+	if (!new_vgid_dup || !arg_name_dup || abort_daemon) {
+		ERROR(s, "lvmetad could not be updated and is aborting.");
+		exit(EXIT_FAILURE);
+	}
 
-	seq = dm_config_find_int(metadata, "metadata/seqno", -1);
+	if (!retval && new_meta)
+		dm_config_destroy(new_meta);
+	return retval;
+}
+
+/*
+ * Updates for new name and new metadata.
+ *
+ * Remove any existing vg_info struct since it will be
+ * recreated by lvmlockd if/when needed.
+ *
+ * Remove any existing outdated pvs since their metadata
+ * will no longer be associated with this VG.
+ */
+
+static int _update_metadata_new_name(lvmetad_state *s,
+				     const char *arg_vgid,
+				     const char *old_name,
+				     const char *new_name,
+				     struct dm_config_tree *old_meta,
+				     struct dm_config_tree *new_meta)
+{
+	struct vg_info *rem_info;
+	struct dm_config_tree *rem_outdated;
+	char *new_name_dup = NULL;
+	char *arg_vgid_dup = NULL;
+	int abort_daemon = 0;
+	int retval = 0;
+
+	if (!(new_name_dup = dm_strdup(new_name)))
+		goto ret;
+
+	if (!(arg_vgid_dup = dm_strdup(arg_vgid)))
+		goto ret;
+
+	lock_vg(s, arg_vgid);
+	lock_pvid_to_vgid(s);
+	lock_vgid_to_metadata(s);
+
+	/*
+	 * Temporarily orphan the PVs in the old metadata.
+	 */
+	if (!update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
+		ERROR(s, "update_metadata_new_name failed to move PVs for old_name %s %s", old_name, arg_vgid);
+		abort_daemon = 1;
+		goto ret;
+	}
+
+	/*
+	 * Remove things related to the old name.
+	 */
+
+	if ((rem_info = dm_hash_lookup(s->vgid_to_info, arg_vgid))) {
+		dm_hash_remove(s->vgid_to_info, arg_vgid);
+		dm_free(rem_info);
+	}
+
+	if ((rem_outdated = dm_hash_lookup(s->vgid_to_outdated_pvs, arg_vgid))) {
+		dm_hash_remove(s->vgid_to_outdated_pvs, arg_vgid);
+		dm_config_destroy(rem_outdated);
+	}
+
+	dm_hash_remove(s->vgid_to_metadata, arg_vgid);
+	dm_config_destroy(old_meta);
+	old_meta = NULL;
+
+	dm_hash_remove(s->vgid_to_vgname, arg_vgid);
+	dm_hash_remove(s->vgname_to_vgid, old_name);
+	dm_free((char *)old_name);
+	old_name = NULL;
+
+	/*
+	 * Insert things with the new name.
+	 */
 
-	if (old)
-		haveseq = dm_config_find_int(old->root, "metadata/seqno", -1);
+	if (!dm_hash_insert(s->vgid_to_metadata, arg_vgid, new_meta)) {
+		ERROR(s, "update_metadata_new_name out of memory for meta hash insert for %s %s", new_name, arg_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
 
-	if (seq < 0)
+	if (!dm_hash_insert(s->vgid_to_vgname, arg_vgid, new_name_dup)) {
+		ERROR(s, "update_metadata_new_name out of memory for name hash insert for %s %s", new_name, arg_vgid);
+		abort_daemon = 1;
 		goto out;
+	}
 
-	filter_metadata(metadata); /* sanitize */
+	if (!dm_hash_insert(s->vgname_to_vgid, new_name, arg_vgid_dup)) {
+		ERROR(s, "update_metadata_new_name out of memory for vgid hash insert for %s %s", new_name, arg_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
 
-	if (oldseq) {
-		if (old)
-			*oldseq = haveseq;
-		else
-			*oldseq = seq;
+	/*
+	 * Reassign PVs based on the new metadata.
+	 */
+	if (!update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
+		ERROR(s, "update_metadata_new_name failed to update PVs for %s %s", new_name, arg_vgid);
+		abort_daemon = 1;
+		goto out;
 	}
 
-	if (seq == haveseq) {
-		retval = 1;
-		if (compare_config(metadata, old->root))
+	DEBUGLOG(s, "update_metadata_new_name is done for %s %s", new_name, arg_vgid);
+	retval = 1;
+out:
+	unlock_vgid_to_metadata(s);
+	unlock_pvid_to_vgid(s);
+	unlock_vg(s, arg_vgid);
+ret:
+	if (!new_name_dup || !arg_vgid_dup || abort_daemon) {
+		ERROR(s, "lvmetad could not be updated and is aborting.");
+		exit(EXIT_FAILURE);
+	}
+
+	if (!retval && new_meta)
+		dm_config_destroy(new_meta);
+	return retval;
+}
+
+
+/*
+ * Add new entries to all hash tables.
+ */
+
+static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, const char *new_vgid,
+				    struct dm_config_tree *new_meta)
+{
+	char *new_name_dup = NULL;
+	char *new_vgid_dup = NULL;
+	int abort_daemon = 0;
+	int retval = 0;
+
+	DEBUGLOG(s, "update_metadata_add_new for %s %s", new_name, new_vgid);
+
+	if (!(new_name_dup = dm_strdup(new_name)))
+		goto out_free;
+
+	if (!(new_vgid_dup = dm_strdup(new_vgid)))
+		goto out_free;
+
+	lock_vg(s, new_vgid);
+	lock_pvid_to_vgid(s);
+	lock_vgid_to_metadata(s);
+
+	if (!dm_hash_insert(s->vgid_to_metadata, new_vgid, new_meta)) {
+		ERROR(s, "update_metadata_add_new out of memory for meta hash insert for %s %s", new_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	if (!dm_hash_insert(s->vgid_to_vgname, new_vgid, new_name_dup)) {
+		ERROR(s, "update_metadata_add_new out of memory for name hash insert for %s %s", new_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	if (!dm_hash_insert(s->vgname_to_vgid, new_name, new_vgid_dup)) {
+		ERROR(s, "update_metadata_add_new out of memory for vgid hash insert for %s %s", new_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	if (!update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
+		ERROR(s, "update_metadata_add_new failed to update PVs for %s %s", new_name, new_vgid);
+		abort_daemon = 1;
+		goto out;
+	}
+
+	DEBUGLOG(s, "update_metadata_add_new is done for %s %s", new_name, new_vgid);
+	retval = 1;
+out:
+	unlock_vgid_to_metadata(s);
+	unlock_pvid_to_vgid(s);
+	unlock_vg(s, new_vgid);
+
+out_free:
+	if (!new_name_dup || !new_vgid_dup || abort_daemon) {
+		ERROR(s, "lvmetad could not be updated and is aborting.");
+		exit(EXIT_FAILURE);
+	}
+
+	if (!retval && new_meta)
+		dm_config_destroy(new_meta);
+	return retval;
+}
+
+/*
+ * No locks need to be held. The pointers are never used outside of the scope of
+ * this function, so they can be safely destroyed after update_metadata returns
+ * (anything that might have been retained is copied).
+ *
+ * When this is called from pv_found, the metadata was read from a single
+ * PV specified by the pvid arg and ret_old_seq is not NULL.  The metadata
+ * should match the existing metadata (matching seqno).  If the metadata
+ * from pv_found has a smaller seqno, it means that the PV is outdated
+ * (was previously used in the VG and now reappeared after changes to the VG).
+ * The next command to access the VG will erase the outdated PV and then clear
+ * the outdated pv record here.  If the metadata from pv_found has a larger
+ * seqno than the existing metadata, it means ... (existing pvs are outdated?)
+ *
+ * When this is caleld from vg_update, the metadata is from a command that
+ * has new metadata that should replace the existing metadata.
+ * pvid and ret_old_seq are both NULL.
+ */
+
+static int update_metadata(lvmetad_state *s, const char *arg_name, const char *arg_vgid,
+			   struct dm_config_node *new_metadata, int64_t *ret_old_seq,
+			   const char *pvid)
+{
+	struct dm_config_tree *old_meta = NULL;
+	struct dm_config_tree *new_meta = NULL;
+	const char *arg_name_lookup; /* name lookup result from arg_vgid */
+	const char *arg_vgid_lookup; /* vgid lookup result from arg_name */
+	const char *old_name = NULL;
+	const char *new_name = NULL;
+	const char *old_vgid = NULL;
+	const char *new_vgid = NULL;
+	const char *new_metadata_vgid;
+	int old_seq = -1;
+	int new_seq = -1;
+	int needs_repair = 0;
+	int abort_daemon = 0;
+	int retval = 0;
+
+	DEBUGLOG(s, "update_metadata begin arg_vgid %s arg_name %s pvid %s",
+		 arg_vgid, arg_name, pvid ?: "none");
+
+	/*
+	 * Begin by figuring out what has changed:
+	 * . the VG could be new - found no existing record of the vgid or name.
+	 * . the VG could have a new vgid - found an existing record of the name.
+	 * . the VG could have a new name - found an existing record of the vgid.
+	 * . the VG could have unchanged vgid and name - found existing record of both.
+	 */
+
+	lock_vgid_to_metadata(s);
+	arg_name_lookup = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
+	arg_vgid_lookup = dm_hash_lookup(s->vgname_to_vgid, arg_name);
+
+	/*
+	 * A new VG when there is no existing record of the name or vgid args.
+	 */
+	if (!arg_name_lookup && !arg_vgid_lookup) {
+		new_vgid = arg_vgid;
+		new_name = arg_name;
+
+		DEBUGLOG(s, "update_metadata new name %s and new vgid %s",
+			 new_name, new_vgid);
+		goto update;
+	}
+
+	/*
+	 * An existing name has a new vgid (new_vgid = arg_vgid).
+	 * A lookup of the name arg was successful in finding arg_vgid_lookup,
+	 * but that resulting vgid doesn't match the arg_vgid.
+	 */
+	if (arg_vgid_lookup && arg_vgid && strcmp(arg_vgid_lookup, arg_vgid)) {
+		if (arg_name_lookup) {
+			/*
+			 * This shouldn't happen.
+			 * arg_vgid should be new and should not map to any name.
+			 */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s unexpected arg_name_lookup %s",
+			      arg_vgid, arg_name, arg_name_lookup);
+			needs_repair = 1;
+			goto update;
+		}
+
+		new_vgid = arg_vgid;
+		old_vgid = dm_hash_lookup(s->vgname_to_vgid, arg_name);
+
+		if (!old_vgid) {
+			/* This shouldn't happen. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s no old_vgid",
+			      arg_vgid, arg_name);
+			needs_repair = 1;
+			goto update;
+		}
+
+		if (!(old_meta = dm_hash_lookup(s->vgid_to_metadata, old_vgid))) {
+			/* This shouldn't happen. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s old_vgid %s no old_meta",
+			      arg_vgid, arg_name, old_vgid);
+			needs_repair = 1;
+			goto update;
+		}
+
+		DEBUGLOG(s, "update_metadata existing name %s has new vgid %s old vgid %s",
+			 arg_name, new_vgid, old_vgid);
+		goto update;
+	}
+
+	/*
+	 * An existing vgid has a new name (new_name = arg_name).
+	 * A lookup of the vgid arg was successful in finding arg_name_lookup,
+	 * but that resulting name doesn't match the arg_name.
+	 */
+	if (arg_name_lookup && arg_name && strcmp(arg_name_lookup, arg_name)) {
+		if (arg_vgid_lookup) {
+			/*
+			 * This shouldn't happen.
+			 * arg_name should be new and should not map to any vgid.
+			 */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s unexpected arg_vgid_lookup %s",
+			      arg_vgid, arg_name, arg_vgid_lookup);
+			needs_repair = 1;
+			goto update;
+		}
+
+		new_name = arg_name;
+		old_name = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
+
+		if (!old_name) {
+			/* This shouldn't happen. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s no old_name",
+			      arg_vgid, arg_name);
+			needs_repair = 1;
+			goto update;
+		}
+
+		if (!(old_meta = dm_hash_lookup(s->vgid_to_metadata, arg_vgid))) {
+			/* This shouldn't happen. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s old_name %s no old_meta",
+			      arg_vgid, arg_name, old_name);
+			needs_repair = 1;
+			goto update;
+		}
+
+		DEBUGLOG(s, "update_metadata existing vgid %s has new name %s old name %s",
+			 arg_vgid, new_name, old_name);
+		goto update;
+	}
+
+	/*
+	 * An existing VG has unchanged name and vgid.
+	 */
+	if (!new_vgid && !new_name) {
+		if (strcmp(arg_name_lookup, arg_name)) {
+			/* This shouldn't happen. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s mismatch arg_name_lookup %s",
+			      arg_vgid, arg_name, arg_name_lookup);
+			needs_repair = 1;
+			goto update;
+		}
+
+		if (strcmp(arg_vgid_lookup, arg_vgid)) {
+			/*
+			 * This shouldn't usually happen, but could when
+			 * disks are moved (or filters are changed?)
+			 *
+			 * FIXME: two different VGs with different uuids, on
+			 * different PVs could have the same name, e.g. disks
+			 * are moved, filters are changed.  Possible solution:
+			 * purge all info for these VGs and return an error
+			 * that causes the command to go to disk.  Would this
+			 * only happen from pv_found?
+			 * Until there's a proper solution, ignore this VG.
+			 */
+			ERROR(s, "update_metadata ignore VG with duplicate name %s vgid %s pvid %s existing vgid %s",
+			      arg_name, arg_vgid, pvid ?: "none", arg_vgid_lookup);
+			unlock_vgid_to_metadata(s);
 			retval = 0;
-		DEBUGLOG(s, "Not updating metadata for %s at %d (%s)", _vgid, haveseq,
-		      retval ? "ok" : "MISMATCH");
-		if (!retval) {
-			DEBUGLOG_cft(s, "OLD: ", old->root);
-			DEBUGLOG_cft(s, "NEW: ", metadata);
+			goto out;
+		}
+
+		/* old_vgid == arg_vgid, and old_name == arg_name */
+
+		if (!(old_meta = dm_hash_lookup(s->vgid_to_metadata, arg_vgid))) {
+			/* This shouldn't happen. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s no old_meta",
+			      arg_vgid, arg_name);
+			needs_repair = 1;
+			goto update;
 		}
+
+		DEBUGLOG(s, "update_metadata existing vgid %s and existing name %s",
+			 arg_vgid, arg_name);
+		goto update;
+	}
+
+ update:
+	unlock_vgid_to_metadata(s);
+
+	filter_metadata(new_metadata); /* sanitize */
+
+	/*
+	 * FIXME: verify that there's at least one PV in common between
+	 * the old and new metadata?
+	 */
+
+	if (!(new_meta = dm_config_create()) ||
+	    !(new_meta->root = dm_config_clone_node(new_meta, new_metadata, 0))) {
+		ERROR(s, "update_metadata out of memory for new metadata for %s %s",
+		      arg_name, arg_vgid);
+		/* FIXME: should we purge the old metadata here? */
+		retval = 0;
 		goto out;
 	}
 
-	if (seq < haveseq) {
-		DEBUGLOG(s, "Refusing to update metadata for %s (at %d) to %d", _vgid, haveseq, seq);
+	/*
+	 * Get the seqno from existing (old) and new metadata and perform
+	 * sanity checks for transitions that generally shouldn't happen.
+	 * Sometimes ignore the new metadata and leave the existing metadata
+	 * alone, and sometimes purge the existing metadata and add the new.
+	 * This often depends on whether the new metadata comes from a single
+	 * PV (via pv_found) that's been scanned, or a vg_update sent from a
+	 * command.
+	 */
 
-		if (pvid)
-			mark_outdated_pv(s, dm_config_find_str(old->root, "metadata/id", NULL), pvid);
+	new_seq = dm_config_find_int(new_metadata, "metadata/seqno", -1);
 
-		/* TODO: notify the client that their metadata is out of date? */
-		retval = 1;
+	if (old_meta)
+		old_seq = dm_config_find_int(old_meta->root, "metadata/seqno", -1);
+
+	if (ret_old_seq)
+		*ret_old_seq = old_meta ? old_seq : new_seq;
+
+	/*
+	 * The new metadata has an invalid seqno.
+	 * This shouldn't happen, but if it does, ignore the new metadata.
+	 */
+	if (new_seq <= 0) {
+		ERROR(s, "update_metadata ignore new metadata because of invalid seqno for %s %s",
+		      arg_vgid, arg_name);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		retval = 0;
+		goto out;
+	}
+
+	/*
+	 * The new metadata is missing an internal vgid.
+	 * This shouldn't happen, but if it does, ignore the new metadata.
+	 */
+	if (!(new_metadata_vgid = dm_config_find_str(new_meta->root, "metadata/id", NULL))) {
+		ERROR(s, "update_metadata has no internal vgid for %s %s",
+		      arg_name, arg_vgid);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		retval = 0;
 		goto out;
 	}
 
-	if (!(cft = dm_config_create()) ||
-	    !(cft->root = dm_config_clone_node(cft, metadata, 0))) {
-		ERROR(s, "Out of memory");
+	/*
+	 * The new metadata internal vgid doesn't match the arg vgid.
+	 * This shouldn't happen, but if it does, ignore the new metadata.
+	 */
+	if (strcmp(new_metadata_vgid, arg_vgid)) {
+		ERROR(s, "update_metadata has bad internal vgid %s for %s %s",
+		      new_metadata_vgid, arg_name, arg_vgid);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		retval = 0;
 		goto out;
 	}
 
-	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
+	/*
+	 * A single PV appears with metadata that's inconsistent with
+	 * existing, ignore the PV.  FIXME: make it outdated?
+	 */
+	if (pvid && needs_repair) {
+		ERROR(s, "update_metadata ignore inconsistent metadata on PV %s seqno %d for %s %s seqno %d",
+		      pvid, new_seq, arg_vgid, arg_name, old_seq);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		retval = 0;
+		goto out;
+	}
 
-	if (!vgid || !name) {
-		DEBUGLOG(s, "Name '%s' or uuid '%s' missing!", name, vgid);
+	/*
+	 * A VG update with metadata that's inconsistent with existing.
+	 */
+	if (!pvid && needs_repair) {
+		ERROR(s, "update_metadata inconsistent with cache for vgid %s and name %s",
+		      arg_vgid, arg_name);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		abort_daemon = 1;
+		retval = 0;
 		goto out;
 	}
 
-	lock_pvid_to_vgid(s);
+	/*
+	 * A single PV appears with metadata that's older than the existing,
+	 * e.g. an PV that had been in the VG has reappeared after the VG changed.
+	 * old PV: the PV that lvmetad was told about first
+	 * new PV: the PV that lvmetad is being told about here, second
+	 * old_seq: the larger seqno on the old PV, for the newer version of the VG
+	 * new_seq: the smaller seqno on the new PV, for the older version of the VG
+	 *
+	 * So, the new PV (by notification order) is "older" (in terms of
+	 * VG seqno) than the old PV.
+	 *
+	 * Make the new PV outdated so it'll be cleared and keep the existing
+	 * metadata from the old PV.
+	 */
+	if (pvid && (old_seq > 0) && (new_seq < old_seq)) {
+		ERROR(s, "update_metadata ignoring outdated metadata on PV %s seqno %d for %s %s seqno %d",
+		      pvid, new_seq, arg_vgid, arg_name, old_seq);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		mark_outdated_pv(s, arg_vgid, pvid);
+		retval = 0;
+		goto out;
+	}
+
+	/*
+	 * A single PV appears with metadata that's newer than the existing,
+	 * e.g. a PV has been found with VG metadata that is newer than the
+	 * VG metdata we know about.  This can happen when scanning PVs after
+	 * an outdated PV (with an older version of the VG metadata) has
+	 * reappeared.  The rescanning may initially scan the outdated PV
+	 * and notify lvmetad about it, and then scan a current PV from
+	 * the VG and notify lvmetad about it.
+	 * old PV: the PV that lvmetad was told about first
+	 * new PV: the PV that lvmetad is being told about here, second
+	 * old_seq: the smaller seqno on the old PV, for the older version of the VG
+	 * new_seq: the larger seqno on the new PV, for the newer version of the VG
+	 *
+	 * Make the existing PVs outdated, and use the new metadata.
+	 */
+	if (pvid && (old_seq > 0) && (new_seq > old_seq)) {
+		ERROR(s, "update_metadata found newer metadata on PV %s seqno %d for %s %s seqno %d",
+		      pvid, new_seq, arg_vgid, arg_name, old_seq);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		lock_pvid_to_vgid(s);
+		update_pvid_to_vgid(s, old_meta, arg_vgid, MARK_OUTDATED);
+		unlock_pvid_to_vgid(s);
+	}
+
+	/*
+	 * The existing/old metadata has an invalid seqno.
+	 * This shouldn't happen, but if it does, purge old and add the new.
+	 */
+	if (old_meta && (old_seq <= 0)) {
+		ERROR(s, "update_metadata bad old seqno %d for %s %s",
+		      old_seq, arg_name, arg_vgid);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		_purge_metadata(s, arg_name, arg_vgid);
+		new_name = arg_name;
+		new_vgid = arg_vgid;
+		old_name = NULL;
+		old_vgid = NULL;
+		old_meta = NULL;
+		old_seq = -1;
+	}
+
+	/*
+	 * A single PV appears with a seqno matching existing metadata,
+	 * but unmatching metadata content.  This shouldn't happen,
+	 * but if it does, ignore the PV.  FIXME: make it outdated?
+	 */
+	if (pvid && (new_seq == old_seq) && compare_config(new_metadata, old_meta->root)) {
+		ERROR(s, "update_metadata from pv %s same seqno %d with unmatching data for %s %s",
+		      pvid, new_seq, arg_name, arg_vgid);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		retval = 0;
+		goto out;
+	}
+
+	/*
+	 * A VG update with metadata matching existing seqno but unmatching content.
+	 * This shouldn't happen, but if it does, purge existing and add the new.
+	 */
+	if (!pvid && (new_seq == old_seq) && compare_config(new_metadata, old_meta->root)) {
+		ERROR(s, "update_metadata same seqno %d with unmatching data for %s %s",
+		      new_seq, arg_name, arg_vgid);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		_purge_metadata(s, arg_name, arg_vgid);
+		new_name = arg_name;
+		new_vgid = arg_vgid;
+		old_name = NULL;
+		old_vgid = NULL;
+		old_meta = NULL;
+		old_seq = -1;
+	}
+
+	/*
+	 * A VG update with metadata older than existing.  VG updates should
+	 * have increasing seqno.  This shouldn't happen, but if it does,
+	 * purge existing and add the new.
+	 */
+	if (!pvid && (new_seq < old_seq)) {
+		ERROR(s, "update_metadata new seqno %d less than old seqno %d for %s %s",
+		      new_seq, old_seq, arg_name, arg_vgid);
+		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		DEBUGLOG_cft(s, "NEW: ", new_metadata);
+		_purge_metadata(s, arg_name, arg_vgid);
+		new_name = arg_name;
+		new_vgid = arg_vgid;
+		old_name = NULL;
+		old_vgid = NULL;
+		old_meta = NULL;
+		old_seq = -1;
+	}
+
+	/*
+	 * All the checks are done, do one of the four possible updates
+	 * outlined above:
+	 */
+
+	/*
+	 * Add metadata for a new VG to the cache.
+	 */
+	if (new_name && new_vgid)
+		return _update_metadata_add_new(s, new_name, new_vgid, new_meta);
 
-	if (haveseq >= 0 && haveseq < seq) {
-		INFO(s, "Updating metadata for %s@%d to %d", _vgid, haveseq, seq);
-		if (oldseq)
-			update_pvid_to_vgid(s, old, vgid, MARK_OUTDATED);
-		/* temporarily orphan all of our PVs */
-		update_pvid_to_vgid(s, old, "#orphan", 0);
+	/*
+	 * Update cached metadata for a VG with a new vgid.
+	 */
+	if (new_vgid)
+		return _update_metadata_new_vgid(s, arg_name, old_vgid, new_vgid, old_meta, new_meta);
+
+	/*
+	 * Update cached metadata for a renamed VG.
+	 */
+	if (new_name)
+		return _update_metadata_new_name(s, arg_vgid, old_name, new_name, old_meta, new_meta);
+
+	/*
+	 * If the old and new seqnos are the same, we've already compared the
+	 * old/new metadata and verified it's the same, so there's no reason
+	 * to replace old meta with new meta.
+	 */
+	if (old_seq == new_seq) {
+		DEBUGLOG(s, "update_metadata skipped for %s %s seqno %d is unchanged",
+			 arg_name, arg_vgid, old_seq);
+		dm_config_destroy(new_meta);
+		new_meta = NULL;
+		retval = 1;
+		goto out;
 	}
 
+	/*
+	 * Update cached metdata for a VG with unchanged name and vgid.
+	 * Replace the old metadata with the new metadata.
+	 * old_meta is the old copy of the metadata from the cache.
+	 * new_meta is the new copy of the metadata from the command.
+	 */
+	DEBUGLOG(s, "update_metadata for %s %s from %d to %d", arg_name, arg_vgid, old_seq, new_seq);
+
+	lock_vg(s, arg_vgid);
+	lock_pvid_to_vgid(s);
 	lock_vgid_to_metadata(s);
-	DEBUGLOG(s, "Mapping %s to %s", vgid, name);
 
-	retval = ((cfgname = dm_pool_strdup(dm_config_memory(cft), name)) &&
-		  dm_hash_insert(s->vgid_to_metadata, vgid, cft) &&
-		  dm_hash_insert(s->vgid_to_vgname, vgid, cfgname) &&
-		  dm_hash_insert(s->vgname_to_vgid, name, (void*) vgid)) ? 1 : 0;
+	/*
+	 * The PVs in the VG may have changed in the new metadata, so
+	 * temporarily orphan all of the PVs in the existing VG.
+	 * The PVs that are still in the VG will be reassigned to this
+	 * VG below by the next call to update_pvid_to_vgid().
+	 */
+	if (!update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
+		ERROR(s, "update_metadata failed to move PVs for %s %s", arg_name, arg_vgid);
+		unlock_vgid_to_metadata(s);
+		unlock_pvid_to_vgid(s);
+		unlock_vg(s, arg_vgid);
+		abort_daemon = 1;
+		retval = 0;
+		goto out;
+	}
+
+	/*
+	 * The only hash table update that is needed is the actual
+	 * metadata config tree in vgid_to_metadata.  The VG name
+	 * and vgid are unchanged.
+	 */
 
-	if (retval && oldname && strcmp(name, oldname)) {
-		const char *vgid_prev = dm_hash_lookup(s->vgname_to_vgid, oldname);
-		if (vgid_prev && !strcmp(vgid_prev, vgid))
-			dm_hash_remove(s->vgname_to_vgid, oldname);
+	dm_hash_remove(s->vgid_to_metadata, arg_vgid);
+	dm_config_destroy(old_meta);
+	old_meta = NULL;
+
+	if (!dm_hash_insert(s->vgid_to_metadata, arg_vgid, new_meta)) {
+		ERROR(s, "update_metadata out of memory for hash insert for %s %s", arg_name, arg_vgid);
+		unlock_vgid_to_metadata(s);
+		unlock_pvid_to_vgid(s);
+		unlock_vg(s, arg_vgid);
+		abort_daemon = 1;
+		retval = 0;
+		goto out;
 	}
 
-	if (haveseq >= 0 && haveseq < seq)
-		dm_config_destroy(old);
+	/*
+	 * Map the PVs in the new metadata to the vgid.
+	 * All pre-existing PVs were temporarily orphaned above.
+	 * Previous PVs that were removed from the VG will not
+	 * be remapped.  New PVs that were added to the VG will
+	 * be newly mapped to this vgid, and previous PVs that
+	 * remain in the VG will be remapped to the VG again.
+	 */
+	if (!update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
+		ERROR(s, "update_metadata failed to update PVs for %s %s", arg_name, arg_vgid);
+		abort_daemon = 1;
+		retval = 0;
+	} else {
+		DEBUGLOG(s, "update_metadata is done for %s %s", arg_name, arg_vgid);
+		retval = 1;
+	}
 
 	unlock_vgid_to_metadata(s);
+	unlock_pvid_to_vgid(s);
+	unlock_vg(s, arg_vgid);
 
-	if (retval)
-		retval = update_pvid_to_vgid(s, cft, vgid, 1);
+out:
+	if (abort_daemon) {
+		ERROR(s, "lvmetad could not be updated is aborting.");
+		exit(EXIT_FAILURE);
+	}
 
-	unlock_pvid_to_vgid(s);
-out: /* FIXME: We should probably abort() on partial failures. */
-	if (!retval && cft)
-		dm_config_destroy(cft);
-	unlock_vg(s, _vgid);
+	if (!retval && new_meta)
+		dm_config_destroy(new_meta);
 	return retval;
 }
 
@@ -983,49 +1868,77 @@ static dev_t device_remove(lvmetad_state *s, struct dm_config_tree *pvmeta, dev_
 
 static response pv_gone(lvmetad_state *s, request r)
 {
-	const char *pvid = daemon_request_str(r, "uuid", NULL);
-	int64_t device = daemon_request_int(r, "device", 0);
+	const char *arg_pvid = NULL;
+	char *old_pvid = NULL;
+	const char *pvid;
+	int64_t device;
 	int64_t alt_device = 0;
 	struct dm_config_tree *pvmeta;
 	char *vgid;
 
-	DEBUGLOG(s, "pv_gone: %s / %" PRIu64, pvid, device);
+	arg_pvid = daemon_request_str(r, "uuid", NULL);
+	device = daemon_request_int(r, "device", 0);
 
 	lock_pvid_to_pvmeta(s);
-	if (!pvid && device > 0)
-		pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
-	if (!pvid) {
+	if (!arg_pvid && device > 0)
+		old_pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
+
+	if (!arg_pvid && !old_pvid) {
 		unlock_pvid_to_pvmeta(s);
+		DEBUGLOG(s, "pv_gone device %" PRIu64 " not found", device);
 		return reply_unknown("device not in cache");
 	}
 
-	DEBUGLOG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
+	pvid = arg_pvid ? arg_pvid : old_pvid;
 
-	if (!(pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid)))
+	DEBUGLOG(s, "pv_gone %s device %" PRIu64, pvid ?: "none", device);
+
+	if (!(pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid))) {
+		DEBUGLOG(s, "pv_gone %s device %" PRIu64 " has no PV metadata",
+			 pvid ?: "none", device);
 		return reply_unknown("PVID does not exist");
+	}
+
 	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 
-	if (!(alt_device = device_remove(s, pvmeta, device)))
-		dm_hash_remove(s->pvid_to_pvmeta, pvid);
+	alt_device = device_remove(s, pvmeta, device);
 
-	DEBUGLOG(s, "pv_gone alt_device = %" PRIu64, alt_device);
+	if (!alt_device) {
+		/* The PV was not a duplicate, so remove it. */
+		dm_hash_remove(s->pvid_to_pvmeta, pvid);
+	} else {
+		/* The PV remains on another device. */
+		DEBUGLOG(s, "pv_gone %s device %" PRIu64 " has alt_device %" PRIu64,
+			 pvid, device, alt_device);
+	}
 
 	unlock_pvid_to_pvmeta(s);
 
 	if (vgid) {
-		if (!(vgid = dm_strdup(vgid)))
+		char *vgid_dup;
+		/*
+		 * vg_remove_if_missing will clear and free the pvid_to_vgid
+		 * mappings for this vg, which will free the "vgid" string that
+		 * was returned above from the pvid_to_vgid lookup.
+		 */
+		if (!(vgid_dup = dm_strdup(vgid)))
 			return reply_fail("out of memory");
 
-		lock_vg(s, vgid);
-		vg_remove_if_missing(s, vgid, 1);
-		unlock_vg(s, vgid);
-		dm_free(vgid);
+		lock_vg(s, vgid_dup);
+		vg_remove_if_missing(s, vgid_dup, 1);
+		unlock_vg(s, vgid_dup);
+		dm_free(vgid_dup);
+		vgid_dup = NULL;
+		vgid = NULL;
 	}
 
-	if (!alt_device)
+	if (!alt_device) {
 		dm_config_destroy(pvmeta);
+		if (old_pvid)
+			dm_free(old_pvid);
+	}
 
 	if (alt_device) {
 		return daemon_reply_simple("OK",
@@ -1053,167 +1966,517 @@ static response pv_clear_all(lvmetad_state *s, request r)
 	return daemon_reply_simple("OK", NULL);
 }
 
+/*
+ * Returns 1 if PV metadata exists for all PVs in a VG.
+ */
+static int _vg_is_complete(lvmetad_state *s, struct dm_config_tree *vgmeta)
+{
+	struct dm_config_node *vg = vgmeta->root;
+	struct dm_config_node *pv;
+	int complete = 1;
+	const char *pvid;
+
+	lock_pvid_to_pvmeta(s);
+
+	for (pv = pvs(vg); pv; pv = pv->sib) {
+		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
+			continue;
+
+		if (!dm_hash_lookup(s->pvid_to_pvmeta, pvid)) {
+			complete = 0;
+			break;
+		}
+	}
+	unlock_pvid_to_pvmeta(s);
+
+	return complete;
+}
+
+/*
+ * pv_found: a PV has appeared and been scanned
+ * It contains PV metadata, and optionally VG metadata.
+ * Both kinds of metadata should be added to the cache
+ * and hash table mappings related to the PV and device
+ * should be updated.
+ *
+ * Input values from request:
+ * . arg_pvmeta:  PV metadata from the found pv
+ * . arg_pvid:    pvid from arg_pvmeta (pvmeta/id)
+ * . arg_device:  device from arg_pvmeta (pvmeta/device)
+ * . arg_vgmeta:  VG metadata from the found pv (optional)
+ * . arg_name:    VG name from found pv (optional)
+ * . arg_vgid:    VG vgid from arg_vgmeta  (optional)
+ *
+ * Search for existing mappings in hash tables:
+ * . pvid_to_pvmeta (which produces pvid to device)
+ * . device_to_pvid
+ * . pvid_to_vgid
+ *
+ * Existing data from cache:
+ * . old_pvmeta:         result of pvid_to_pvmeta(arg_pvid)
+ * . arg_device_lookup:  result of old_pvmeta:pvmeta/device using arg_pvid
+ * . arg_pvid_lookup:    result of device_to_pvid(arg_device)
+ * . arg_vgid_lookup:    result of pvid_to_vgid(arg_pvid)
+ *
+ * When arg_pvid doesn't match arg_pvid_lookup:
+ * . a new PV replaces a previous PV on arg_device
+ * . prev_pvid_on_dev:   set to arg_pvid_lookup, pvid of the prev PV
+ * . prev_pvmeta_on_dev: result pvid_to_pvmeta(prev_pvid_on_dev)
+ * . prev_vgid_on_dev:   result of pvid_to_vgid(prev_pvid_on_dev)
+ *
+ * Old PV on old device
+ * . no PV/device mappings have changed
+ * . arg_pvid_lookup == arg_pvid && arg_device_lookup == arg_device
+ * . arg_device was used to look up a PV and found a PV with
+ *   the same pvid as arg_pvid
+ * . arg_pvid was used to look up a PV and found a PV on the
+ *   same device as arg_device
+ * . new_pvmeta may be more recent than old_pvmeta
+ *
+ * New PV on new device
+ * . add new mappings in hash tables
+ * . !arg_pvid_lookup && !arg_device_lookup
+ * . arg_device was used to look up a PV and found nothing
+ * . arg_pvid was used to look up a PV and found nothing
+ *
+ * New PV on old device
+ * . a new PV replaces a previous PV on a device
+ * . arg_pvid_lookup != arg_pvid
+ * . arg_device was used to look up a PV and found a PV with
+ *   a different pvid than arg_pvid
+ * . replace existing mappings for arg_device and arg_pvid
+ * . replace existing old_pvmeta with new_pvmeta
+ * . remove arg_device association with prev PV (prev_pvid_on_dev)
+ * . possibly remove prev PV (if arg_device was previously a duplicate)
+ *
+ * Old PV on new device
+ * . a duplicate PV
+ * . arg_device_lookup != arg_device
+ * . arg_pvid was used to look up a PV, and found that the PV
+ *   has a different device than arg_device.
+ */
+
 static response pv_found(lvmetad_state *s, request r)
 {
-	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
-	const char *pvid = daemon_request_str(r, "pvmeta/id", NULL);
-	const char *vgname = daemon_request_str(r, "vgname", NULL);
-	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
-	const char *vgid_old = NULL;
-	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta"), *altdev = NULL;
-	struct dm_config_value *altdev_v;
-	uint64_t device, device_old_pvid = 0;
-	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
-	char *old;
-	int complete = 0, orphan = 0;
-	int64_t seqno = -1, seqno_old = -1, changed = 0;
-
-	if (!pvid)
-		return reply_fail("need PV UUID");
-	if (!pvmeta)
-		return reply_fail("need PV metadata");
+	struct dm_config_node *arg_vgmeta = NULL;
+	struct dm_config_node *arg_pvmeta = NULL;
+	struct dm_config_tree *old_pvmeta = NULL;
+	struct dm_config_tree *new_pvmeta = NULL;
+	struct dm_config_tree *prev_pvmeta_on_dev = NULL;
+	struct dm_config_tree *vgmeta = NULL;
+	struct dm_config_node *altdev = NULL;
+	struct dm_config_value *altdev_v = NULL;
+	const char *arg_pvid = NULL;
+	const char *arg_pvid_dup = NULL;
+	const char *arg_pvid_lookup = NULL;
+	const char *new_pvid = NULL;
+	const char *new_pvid_dup = NULL;
+	const char *arg_name = NULL;
+	const char *arg_vgid = NULL;
+	const char *arg_vgid_lookup = NULL;
+	const char *prev_pvid_on_dev = NULL;
+	const char *prev_vgid_on_dev = NULL;
+	const char *vg_status = NULL;
+	uint64_t arg_device = 0;
+	uint64_t arg_device_lookup = 0;
+	uint64_t new_device = 0;
+	uint64_t old_device = 0;
+	int64_t arg_seqno = -1;
+	int64_t old_seqno = -1;
+	int64_t vg_status_seqno = -1;
+	int64_t changed = 0;
 
-	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
-		return reply_fail("need PV device number");
+	/*
+	 * New input values.
+	 */
 
-	if (!(cft = dm_config_create()))
-		return reply_fail("out of memory");
+	if (!(arg_pvmeta = dm_config_find_node(r.cft->root, "pvmeta"))) {
+		ERROR(s, "Ignore PV without PV metadata");
+		return reply_fail("Ignore PV without PV metadata");
+	}
+
+	if (!(arg_pvid = daemon_request_str(r, "pvmeta/id", NULL))) {
+		ERROR(s, "Ignore PV without PV UUID");
+		return reply_fail("Ignore PV without PV UUID");
+	}
+
+	if (!dm_config_get_uint64(arg_pvmeta, "pvmeta/device", &arg_device)) {
+		ERROR(s, "Ignore PV without device pvid %s", arg_pvid);
+		return reply_fail("Ignore PV without device");
+	}
+
+	if ((arg_vgmeta = dm_config_find_node(r.cft->root, "metadata"))) {
+		arg_name = daemon_request_str(r, "vgname", NULL);
+		arg_vgid = daemon_request_str(r, "metadata/id", NULL);
+		arg_seqno = daemon_request_int(r, "metadata/seqno", -1);
+
+		if (!arg_name || !arg_vgid || (arg_seqno < 0))
+			ERROR(s, "Ignore VG metadata from PV %s", arg_pvid);
+		if (!arg_name)
+			return reply_fail("Ignore VG metadata from PV without VG name");
+		if (!arg_vgid)
+			return reply_fail("Ignore VG metadata from PV without VG vgid");
+		if (arg_seqno < 0)
+			return reply_fail("Ignore VG metadata from PV without VG seqno");
+	}
+
+	/* Make a copy of the new pvmeta that can be inserted into cache. */
+	if (!(new_pvmeta = dm_config_create()) ||
+	    !(new_pvmeta->root = dm_config_clone_node(new_pvmeta, arg_pvmeta, 0))) {
+		ERROR(s, "pv_found out of memory for new pvmeta %s", arg_pvid);
+		goto nomem;
+	}
+
+	/*
+	 * Existing (old) cache values.
+	 */
 
 	lock_pvid_to_pvmeta(s);
 
-	if ((pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid)))
-		dm_config_get_uint64(pvmeta_old_pvid->root, "pvmeta/device", &device_old_pvid);
+	old_pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, arg_pvid);
+	if (old_pvmeta)
+		dm_config_get_uint64(old_pvmeta->root, "pvmeta/device", &arg_device_lookup);
+
+	arg_pvid_lookup = dm_hash_lookup_binary(s->device_to_pvid, &arg_device, sizeof(arg_device));
+
+	/*
+	 * Determine which of the four possible changes is happening
+	 * by comparing the existing/old and new values:
+	 * old PV, old device
+	 * new PV, new device
+	 * new PV, old device
+	 * old PV, new device
+	 */
+
+	if (arg_pvid_lookup && arg_device_lookup &&
+	    (arg_device == arg_device_lookup) &&
+	    !strcmp(arg_pvid_lookup, arg_pvid)) {
+		/*
+		 * Old PV on old device (existing values unchanged)
+		 */
+		new_pvid = NULL;
+		new_device = 0;
+
+		DEBUGLOG(s, "pv_found pvid %s on device %" PRIu64 " matches existing",
+			arg_pvid, arg_device);
+
+	} else if (!arg_pvid_lookup && !arg_device_lookup) {
+		/*
+		 * New PV on new device (no existing values)
+		 */
+		new_pvid = arg_pvid;
+		new_device = arg_device;
+
+		DEBUGLOG(s, "pv_found pvid %s on device %" PRIu64 " is new",
+			arg_pvid, arg_device);
+
+	} else if (arg_pvid_lookup && strcmp(arg_pvid_lookup, arg_pvid)) {
+		/*
+		 * New PV on old device (existing device reused for new PV)
+		 */
+		new_pvid = arg_pvid;
+		new_device = 0;
+		prev_pvid_on_dev = arg_pvid_lookup;
+		prev_pvmeta_on_dev = dm_hash_lookup(s->pvid_to_pvmeta, arg_pvid_lookup);
+		prev_vgid_on_dev = dm_hash_lookup(s->pvid_to_vgid, arg_pvid_lookup);
+
+		DEBUGLOG(s, "pv_found pvid %s vgid %s on device %" PRIu64 " previous pvid %s vgid %s",
+			arg_pvid, arg_vgid ?: "none", arg_device,
+			prev_pvid_on_dev, prev_vgid_on_dev ?: "none");
+
+	} else if (arg_device_lookup && (arg_device_lookup != arg_device)) {
+		/*
+		 * Old PV on new device (existing PV on a new device, i.e. duplicate)
+		 */
+		new_device = arg_device;
+		new_pvid = NULL;
+		old_device = arg_device_lookup;
+
+		DEBUGLOG(s, "pv_found pvid %s vgid %s on device %" PRIu64 " duplicate %" PRIu64,
+			arg_pvid, arg_vgid ?: "none", arg_device, arg_device_lookup);
 
-	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
-		pvmeta_old_dev = dm_hash_lookup(s->pvid_to_pvmeta, old);
-		vgid_old = dm_hash_lookup(s->pvid_to_vgid, old);
+	} else {
+		ERROR(s, "pv_found pvid %s vgid %s on device %" PRIu64 " unknown lookup %s %s %" PRIu64,
+		      arg_pvid,
+		      arg_vgid ?: "none",
+		      arg_device,
+		      arg_pvid_lookup ?: "none",
+		      arg_vgid_lookup ?: "none",
+		      arg_device_lookup);
+		unlock_pvid_to_pvmeta(s);
+		return reply_fail("Ignore PV for unknown state");
 	}
 
-	DEBUGLOG(s, "pv_found %s, vgid = %s, device = %" PRIu64 " (previously %" PRIu64 "), old = %s",
-		 pvid, vgid, device, device_old_pvid, old);
+	/*
+	 * Make changes to hashes device_to_pvid and pvid_to_pvmeta for each case.
+	 */
+
+	if (!new_pvid && !new_device) {
+		/*
+		 * Old PV on old device (unchanged)
+		 * . add new_pvmeta, replacing old_pvmeta
+		 */
+		if (compare_config(old_pvmeta->root, new_pvmeta->root))
+			changed |= 1;
+
+		if (!dm_hash_insert(s->pvid_to_pvmeta, arg_pvid, new_pvmeta))
+			goto nomem;
+
+	} else if (new_pvid && new_device) {
+		/*
+		 * New PV on new device (new entry)
+		 * . add new_device/new_pvid mapping
+		 * . add new_pvmeta
+		 */
+		changed |= 1;
 
-	if (!(cft->root = dm_config_clone_node(cft, pvmeta, 0)))
-                goto out_of_mem;
+		DEBUGLOG(s, "pv_found new entry device_to_pvid %" PRIu64 " to %s",
+			 new_device, new_pvid);
+
+		if (!(new_pvid_dup = dm_strdup(new_pvid)))
+			goto nomem;
+
+		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), (char *)new_pvid_dup))
+			goto nomem;
+
+		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
+			goto nomem;
+
+	} else if (new_pvid && !new_device) {
+		/*
+		 * New PV on old device (existing device reused for new PV).
+		 * The previous PV on arg_device may or may not still exist,
+		 * this is determined by device_remove() which checks the
+		 * pvmeta for the previous PV (prev_pvid_on_dev and
+		 * prev_pvmeta_on_dev) to see if arg_device was the only
+		 * device for the PV, or if arg_device was a duplicate for
+		 * the PV.  If arg_device was previously a duplicate, then
+		 * the prev PV should be kept, but with arg_device removed.
+		 * If arg_device was the only device for the prev PV, then
+		 * the prev PV should be removed entirely.
+		 *
+		 * In either case, don't free prev_pvid or prev_vgid
+		 * strings because they are used at the end to check
+		 * the VG metadata.
+		 */
+		changed |= 1;
 
-	pvid = dm_config_find_str(cft->root, "pvmeta/id", NULL);
+		if (prev_pvmeta_on_dev &&
+		    !device_remove(s, prev_pvmeta_on_dev, arg_device)) {
+			/*
+			 * The prev PV has no remaining device after
+			 * removing arg_device, so arg_device was not a
+			 * duplicate; remove the prev PV entirely.
+			 *
+			 * (hash_remove in pvid_to_vgid is done at the
+			 * end after the VG metadata is checked)
+			 *
+			 * FIXME: we could check if the new pvid is a new
+			 * duplicate of another existing PV.  This can happen:
+			 * start with two different pvs A and B,
+			 * dd if=A of=B, pvscan --cache B.  This detects that
+			 * B is removed, but doesn't detect that A is now a
+			 * duplicate.  ('pvscan --cache' does detect the
+			 * dup because all pvs are scanned.)
+			 */
+			DEBUGLOG(s, "pv_found new pvid device_to_pvid %" PRIu64 " to %s removes prev pvid %s",
+				 arg_device, new_pvid, prev_pvid_on_dev);
+
+			dm_hash_remove(s->pvid_to_pvmeta, prev_pvid_on_dev);
+			dm_config_destroy(prev_pvmeta_on_dev);
+			prev_pvmeta_on_dev = NULL;
+
+			/* removes arg_device/prev_pvid_on_dev mapping */
+			dm_hash_remove_binary(s->device_to_pvid, &arg_device, sizeof(arg_device));
+		} else {
+			/*
+			 * The prev PV existing on a remaining alternate
+			 * device after removing arg_device, so arg_device
+			 * was a duplicate; keep the prev PV.
+			 *
+			 * FIXME: if the duplicate devices were path aliases
+			 * to the same underlying device, then keeping the
+			 * prev PV for the remaining alt device isn't nice.
+			 */
+			DEBUGLOG(s, "pv_found new pvid device_to_pvid %" PRIu64 " to %s keeping prev pvid %s",
+				 arg_device, new_pvid, prev_pvid_on_dev);
+
+			/* removes arg_device/prev_pvid_on_dev mapping */
+			dm_hash_remove_binary(s->device_to_pvid, &arg_device, sizeof(arg_device));
+		}
 
-	if (!pvmeta_old_pvid || compare_config(pvmeta_old_pvid->root, cft->root))
+		if (!(new_pvid_dup = dm_strdup(new_pvid)))
+			goto nomem;
+
+		if (!dm_hash_insert_binary(s->device_to_pvid, &arg_device, sizeof(arg_device), (char *)new_pvid_dup))
+			goto nomem;
+
+		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
+			goto nomem;
+
+	} else if (new_device && !new_pvid) {
+		/*
+		 * Old PV on new device (duplicate)
+		 * . add new_device/arg_pvid mapping
+		 * . leave existing old_device/arg_pvid mapping
+		 * . add new_pvmeta, replacing old_pvmeta
+		 * . modify new_pvmeta, adding an alternate device entry for old_device
+		 */
 		changed |= 1;
 
-	if (pvmeta_old_pvid && device != device_old_pvid) {
-		DEBUGLOG(s, "PV %s duplicated on device %" PRIu64, pvid, device_old_pvid);
-		dm_hash_remove_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid));
-		if (!dm_hash_insert_binary(s->device_to_pvid, &device_old_pvid,
-					   sizeof(device_old_pvid), (void*)pvid))
-			goto out_of_mem;
-		if ((altdev = dm_config_find_node(pvmeta_old_pvid->root, "pvmeta/devices_alternate"))) {
-			altdev = dm_config_clone_node(cft, altdev, 0);
-			chain_node(altdev, cft->root, 0);
-		} else
-			if (!(altdev = make_config_node(cft, "devices_alternate", cft->root, 0)))
-				goto out_of_mem;
-                altdev_v = altdev->v;
-                while (1) {
-			if (altdev_v && altdev_v->v.i == device_old_pvid)
+		DEBUGLOG(s, "pv_found new device device_to_pvid %" PRIu64 " to %s also %" PRIu64 " to %s",
+			 new_device, arg_pvid, old_device, arg_pvid);
+
+		if (!(arg_pvid_dup = dm_strdup(arg_pvid)))
+			goto nomem;
+
+		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), (char *)arg_pvid_dup))
+			goto nomem;
+
+		if (!dm_hash_insert(s->pvid_to_pvmeta, arg_pvid, new_pvmeta))
+			goto nomem;
+
+		/* Copy existing altdev info, or create new, and add it to new pvmeta. */
+		if ((altdev = dm_config_find_node(old_pvmeta->root, "pvmeta/devices_alternate"))) {
+			if (!(altdev = dm_config_clone_node(new_pvmeta, altdev, 0)))
+				goto nomem;
+			chain_node(altdev, new_pvmeta->root, 0);
+		} else {
+			if (!(altdev = make_config_node(new_pvmeta, "devices_alternate", new_pvmeta->root, 0)))
+				goto nomem;
+		}
+
+		/* Add an altdev entry for old_device. */
+		altdev_v = altdev->v;
+		while (1) {
+			if (altdev_v && altdev_v->v.i == old_device)
 				break;
 			if (altdev_v)
 				altdev_v = altdev_v->next;
 			if (!altdev_v) {
-				if (!(altdev_v = dm_config_create_value(cft)))
-					goto out_of_mem;
+				if (!(altdev_v = dm_config_create_value(new_pvmeta)))
+					goto nomem;
 				altdev_v->next = altdev->v;
 				altdev->v = altdev_v;
-				altdev->v->v.i = device_old_pvid;
+				altdev->v->v.i = old_device;
 				break;
 			}
 		};
 		altdev_v = altdev->v;
 		while (altdev_v) {
-			if (altdev_v->next && altdev_v->next->v.i == device)
+			if (altdev_v->next && altdev_v->next->v.i == new_device)
 				altdev_v->next = altdev_v->next->next;
 			altdev_v = altdev_v->next;
 		}
-		changed |= 1;
-	}
-
-	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
-	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid)) {
-		dm_hash_remove(s->pvid_to_pvmeta, pvid);
-out_of_mem:
-		unlock_pvid_to_pvmeta(s);
-		dm_config_destroy(cft);
-		dm_free(old);
-		return reply_fail("out of memory");
 	}
 
 	unlock_pvid_to_pvmeta(s);
 
-	if (pvmeta_old_pvid)
-		dm_config_destroy(pvmeta_old_pvid);
-	if (pvmeta_old_dev && pvmeta_old_dev != pvmeta_old_pvid) {
-		dev_t d = dm_config_find_int64(pvmeta_old_dev->root, "pvmeta/device", 0);
-		WARN(s, "pv_found: stray device %"PRId64, d);
-		if (!device_remove(s, pvmeta_old_dev, device)) {
-			dm_hash_remove(s->pvid_to_pvmeta, old);
-			dm_config_destroy(pvmeta_old_dev);
+	if (old_pvmeta)
+		dm_config_destroy(old_pvmeta);
+
+	/*
+	 * Update VG metadata cache with arg_vgmeta from the PV, or
+	 * if the PV holds no VG metadata, then look up the vgid and
+	 * name of the VG so we can check if the VG is complete.
+	 */
+	if (arg_vgmeta) {
+		DEBUGLOG(s, "pv_found pvid %s has VG %s %s seqno %ld", arg_pvid, arg_name, arg_vgid, arg_seqno);
+
+		if (!update_metadata(s, arg_name, arg_vgid, arg_vgmeta, &old_seqno, arg_pvid)) {
+			ERROR(s, "Cannot use VG metadata for %s %s from PV %s on %" PRIu64,
+			      arg_name, arg_vgid, arg_pvid, arg_device);
 		}
-	}
 
-	if (metadata) {
-		if (!vgid)
-			return reply_fail("need VG UUID");
-		DEBUGLOG(s, "obtained vgid = %s, vgname = %s", vgid, vgname);
-		if (!vgname)
-			return reply_fail("need VG name");
-		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
-			return reply_fail("need VG seqno");
-
-		if (!update_metadata(s, vgname, vgid, metadata, &seqno_old, pvid))
-			return reply_fail("metadata update failed");
-		changed |= (seqno_old != dm_config_find_int(metadata, "metadata/seqno", -1));
+		changed |= (old_seqno != arg_seqno);
 	} else {
 		lock_pvid_to_vgid(s);
-		vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
+		arg_vgid = dm_hash_lookup(s->pvid_to_vgid, arg_pvid);
 		unlock_pvid_to_vgid(s);
-	}
 
-	if (vgid) {
-		if ((cft = lock_vg(s, vgid))) {
-			complete = update_pv_status(s, cft, cft->root, 0);
-			seqno = dm_config_find_int(cft->root, "metadata/seqno", -1);
-		} else if (!strcmp(vgid, "#orphan"))
-			orphan = 1;
-		else {
-			unlock_vg(s, vgid);
-			return reply_fail("non-orphan VG without metadata encountered");
+		if (arg_vgid) {
+			lock_vgid_to_metadata(s);
+			arg_name = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
+			unlock_vgid_to_metadata(s);
 		}
-		unlock_vg(s, vgid);
+	}
 
-		// TODO: separate vgid->vgname lock
-		lock_vgid_to_metadata(s);
-		vgname = dm_hash_lookup(s->vgid_to_vgname, vgid);
-		unlock_vgid_to_metadata(s);
+	/*
+	 * Check if the VG is complete (all PVs have been found) because
+	 * the reply indicates if the the VG is complete or partial.
+	 * The "vgmeta" from lock_vg will be a copy of arg_vgmeta that
+	 * was cloned and added to the cache by update_metadata.
+	 */
+	if (!arg_vgid || !strcmp(arg_vgid, "#orphan")) {
+		DEBUGLOG(s, "pv_found pvid %s on %" PRIu64 " not in VG %s",
+			 arg_pvid, arg_device, arg_vgid ?: "");
+		vg_status = "orphan";
+		goto prev_vals;
+	}
+
+	if (!(vgmeta = lock_vg(s, arg_vgid))) {
+		ERROR(s, "pv_found %s on %" PRIu64 " vgid %s no VG metadata found",
+		      arg_pvid, arg_device, arg_vgid);
+	} else {
+		vg_status = _vg_is_complete(s, vgmeta) ? "complete" : "partial";
+		vg_status_seqno = dm_config_find_int(vgmeta->root, "metadata/seqno", -1);
+	}
+	unlock_vg(s, arg_vgid);
+
+ prev_vals:
+	/*
+	 * If the device previously held a different VG (prev_vgid_on_dev),
+	 * then that VG should be removed if no devices are left for it.
+	 *
+	 * The mapping from the device's previous pvid to the previous vgid
+	 * is removed.
+	 */
+
+	if (prev_pvid_on_dev || prev_vgid_on_dev) {
+		DEBUGLOG(s, "pv_found pvid %s on %" PRIu64 " had prev pvid %s prev vgid %s",
+			 arg_pvid, arg_device,
+			 prev_pvid_on_dev ?: "none",
+			 prev_vgid_on_dev ?: "none");
 	}
 
-	if (vgid_old && (!vgid || strcmp(vgid, vgid_old))) {
-		/* make a copy, because vg_remove_if_missing will deallocate the
-		 * storage behind vgid_old */
-		vgid_old = dm_strdup(vgid_old);
-		lock_vg(s, vgid_old);
-		vg_remove_if_missing(s, vgid_old, 1);
-		unlock_vg(s, vgid_old);
-		dm_free((char*)vgid_old);
+	if (prev_vgid_on_dev) {
+		char *tmp_vgid;
+
+	       	if (!arg_vgid || strcmp(arg_vgid, prev_vgid_on_dev)) {
+			tmp_vgid = dm_strdup(prev_vgid_on_dev);
+			/* vg_remove_if_missing will clear and free
+			   the string pointed to by prev_vgid_on_dev. */
+			lock_vg(s, tmp_vgid);
+			vg_remove_if_missing(s, tmp_vgid, 1);
+			unlock_vg(s, tmp_vgid);
+			dm_free(tmp_vgid);
+		}
+
+		/* vg_remove_if_missing may have remapped prev_pvid_on_dev to orphan */
+		if ((tmp_vgid = dm_hash_lookup(s->pvid_to_vgid, prev_pvid_on_dev))) {
+			dm_hash_remove(s->pvid_to_vgid, prev_pvid_on_dev);
+			dm_free(tmp_vgid);
+		}
 	}
 
+	/* This was unhashed from device_to_pvid above. */
+	if (prev_pvid_on_dev)
+		dm_free((void *)prev_pvid_on_dev);
+
 	return daemon_reply_simple("OK",
-				   "status = %s", orphan ? "orphan" :
-				                     (complete ? "complete" : "partial"),
+				   "status = %s", vg_status,
 				   "changed = %d", changed,
-				   "vgid = %s", vgid ? vgid : "#orphan",
-				   "vgname = %s", vgname ? vgname : "#orphan",
-				   "seqno_before = %"PRId64, seqno_old,
-				   "seqno_after = %"PRId64, seqno,
+				   "vgid = %s", arg_vgid ? arg_vgid : "#orphan",
+				   "vgname = %s", arg_name ? arg_name : "#orphan",
+				   "seqno_before = %"PRId64, old_seqno,
+				   "seqno_after = %"PRId64, vg_status_seqno,
 				   NULL);
+
+ nomem:
+	ERROR(s, "pv_found %s is out of memory.", arg_pvid);
+	ERROR(s, "lvmetad could not be updated is aborting.");
+	reply_fail("out of memory");
+	exit(EXIT_FAILURE);
 }
 
 static response vg_clear_outdated_pvs(lvmetad_state *s, request r)
@@ -1224,6 +2487,8 @@ static response vg_clear_outdated_pvs(lvmetad_state *s, request r)
 	if (!vgid)
 		return reply_fail("need VG UUID");
 
+	DEBUGLOG(s, "vg_clear_outdated_pvs vgid %s", vgid);
+
 	if ((outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid))) {
 		dm_config_destroy(outdated_pvs);
 		dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
@@ -1254,22 +2519,42 @@ static response vg_update(lvmetad_state *s, request r)
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 	const char *vgname = daemon_request_str(r, "vgname", NULL);
+
+	DEBUGLOG(s, "vg_update vgid %s name %s", vgid ?: "none", vgname ?: "none");
+
 	if (metadata) {
-		if (!vgid)
-			return reply_fail("need VG UUID");
-		if (!vgname)
-			return reply_fail("need VG name");
-		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
-			return reply_fail("need VG seqno");
+		if (!vgid) {
+			ERROR(s, "vg_update failed: need VG UUID");
+			reply_fail("vg_update: need VG UUID");
+			goto fail;
+		}
+		if (!vgname) {
+			ERROR(s, "vg_update failed: need VG name");
+			reply_fail("vg_update: need VG name");
+			goto fail;
+		}
+		if (daemon_request_int(r, "metadata/seqno", -1) < 0) {
+			ERROR(s, "vg_update failed: need VG seqno");
+			reply_fail("vg_update: need VG seqno");
+			goto fail;
+		}
 
 		/* TODO defer metadata update here; add a separate vg_commit
 		 * call; if client does not commit, die */
-		if (!update_metadata(s, vgname, vgid, metadata, NULL, NULL))
-			return reply_fail("metadata update failed");
+
+		if (!update_metadata(s, vgname, vgid, metadata, NULL, NULL)) {
+			ERROR(s, "vg_update failed: metadata update failed");
+			reply_fail("vg_update: failed metadata update");
+			goto fail;
+		}
 
 		vg_info_update(s, vgid, metadata);
 	}
 	return daemon_reply_simple("OK", NULL);
+
+fail:
+	ERROR(s, "lvmetad could not be updated is aborting.");
+	exit(EXIT_FAILURE);
 }
 
 static response vg_remove(lvmetad_state *s, request r)


