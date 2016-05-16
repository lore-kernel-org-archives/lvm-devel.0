From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 May 2016 19:40:24 +0000 (UTC)
Subject: master - lvmetad: remove old thread locking
Message-ID: <20160516194024.0A5ED602F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0c22df5c41a8658dab953a413a679ceb5acd663
Commit:        e0c22df5c41a8658dab953a413a679ceb5acd663
Parent:        9f72a52302587fef27d845e218e6a81be6022dca
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 10 14:54:32 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 16 14:38:25 2016 -0500

lvmetad: remove old thread locking

The old thread locking is very fine grained and complex,
and appears to have no concurrency advantage.
---
 daemons/lvmetad/lvmetad-core.c |  214 +---------------------------------------
 1 files changed, 3 insertions(+), 211 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 5ff148b..f9d0d4c 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -222,13 +222,6 @@ typedef struct {
 	struct dm_hash_table *vgid_to_info;
 	struct dm_hash_table *vgname_to_vgid;
 	struct dm_hash_table *pvid_to_vgid;
-	struct {
-		struct dm_hash_table *vg;
-		pthread_mutex_t vg_lock_map;
-		pthread_mutex_t pvid_to_pvmeta;
-		pthread_mutex_t vgid_to_metadata;
-		pthread_mutex_t pvid_to_vgid;
-	} lock;
 	char token[128];
 	uint32_t flags; /* GLFL_ */
 	pthread_mutex_t token_lock;
@@ -272,21 +265,6 @@ static void create_metadata_hashes(lvmetad_state *s)
 	s->vgname_to_vgid = dm_hash_create(32);
 }
 
-static void lock_pvid_to_pvmeta(lvmetad_state *s) {
-	pthread_mutex_lock(&s->lock.pvid_to_pvmeta); }
-static void unlock_pvid_to_pvmeta(lvmetad_state *s) {
-	pthread_mutex_unlock(&s->lock.pvid_to_pvmeta); }
-
-static void lock_vgid_to_metadata(lvmetad_state *s) {
-	pthread_mutex_lock(&s->lock.vgid_to_metadata); }
-static void unlock_vgid_to_metadata(lvmetad_state *s) {
-	pthread_mutex_unlock(&s->lock.vgid_to_metadata); }
-
-static void lock_pvid_to_vgid(lvmetad_state *s) {
-	pthread_mutex_lock(&s->lock.pvid_to_vgid); }
-static void unlock_pvid_to_vgid(lvmetad_state *s) {
-	pthread_mutex_unlock(&s->lock.pvid_to_vgid); }
-
 static response reply_fail(const char *reason)
 {
 	return daemon_reply_simple("failed", "reason = %s", reason, NULL);
@@ -297,57 +275,6 @@ static response reply_unknown(const char *reason)
 	return daemon_reply_simple("unknown", "reason = %s", reason, NULL);
 }
 
-/*
- * TODO: It may be beneficial to clean up the vg lock hash from time to time,
- * since if we have many "rogue" requests for nonexistent things, we will keep
- * allocating memory that we never release. Not good.
- */
-static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
-	pthread_mutex_t *vg;
-	struct dm_config_tree *cft;
-	pthread_mutexattr_t rec;
-
-	pthread_mutex_lock(&s->lock.vg_lock_map);
-	if (!(vg = dm_hash_lookup(s->lock.vg, id))) {
-		if (!(vg = malloc(sizeof(pthread_mutex_t))) ||
-		    pthread_mutexattr_init(&rec) ||
-		    pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP) ||
-		    pthread_mutex_init(vg, &rec))
-			goto bad;
-		if (!dm_hash_insert(s->lock.vg, id, vg)) {
-			pthread_mutex_destroy(vg);
-			goto bad;
-		}
-	}
-	/* We never remove items from s->lock.vg => the pointer remains valid. */
-	pthread_mutex_unlock(&s->lock.vg_lock_map);
-
-	/* DEBUGLOG(s, "locking VG %s", id); */
-	pthread_mutex_lock(vg);
-
-	/* Protect against structure changes of the vgid_to_metadata hash. */
-	lock_vgid_to_metadata(s);
-	cft = dm_hash_lookup(s->vgid_to_metadata, id);
-	unlock_vgid_to_metadata(s);
-	return cft;
-bad:
-	pthread_mutex_unlock(&s->lock.vg_lock_map);
-	free(vg);
-	ERROR(s, "Out of memory");
-	return NULL;
-}
-
-static void unlock_vg(lvmetad_state *s, const char *id) {
-	pthread_mutex_t *vg;
-
-	/* DEBUGLOG(s, "unlocking VG %s", id); */
-	/* Protect the s->lock.vg structure from concurrent access. */
-	pthread_mutex_lock(&s->lock.vg_lock_map);
-	if ((vg = dm_hash_lookup(s->lock.vg, id)))
-		pthread_mutex_unlock(vg);
-	pthread_mutex_unlock(&s->lock.vg_lock_map);
-}
-
 static struct dm_config_node *pvs(struct dm_config_node *vg)
 {
 	struct dm_config_node *pv = dm_config_find_node(vg, "metadata/physical_volumes");
@@ -409,8 +336,6 @@ static int update_pv_status(lvmetad_state *s,
 	struct dm_config_node *pvmeta_cn;
 	int ret = 1;
 
-	lock_pvid_to_pvmeta(s);
-
 	for (pv = pvs(vg); pv; pv = pv->sib) {
 		if (!(uuid = dm_config_find_str(pv->child, "id", NULL))) {
 			ERROR(s, "update_pv_status found no uuid for PV");
@@ -432,7 +357,6 @@ static int update_pv_status(lvmetad_state *s,
 		}
 	}
 out:
-	unlock_pvid_to_pvmeta(s);
 	return ret;
 }
 
@@ -474,9 +398,7 @@ static struct dm_config_node *make_pv_node(lvmetad_state *s, const char *pvid,
 		return NULL;
 
 	if (vgid) {
-		lock_vgid_to_metadata(s); // XXX
 		vgname = dm_hash_lookup(s->vgid_to_vgname, vgid);
-		unlock_vgid_to_metadata(s);
 	}
 
 	/* Nick the pvmeta config tree. */
@@ -520,8 +442,6 @@ static response pv_list(lvmetad_state *s, request r)
 
 	cn_pvs = make_config_node(res.cft, "physical_volumes", NULL, res.cft->root);
 
-	lock_pvid_to_pvmeta(s);
-
 	dm_hash_iterate(n, s->pvid_to_pvmeta) {
 		id = dm_hash_get_key(s->pvid_to_pvmeta, n);
 		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
@@ -530,8 +450,6 @@ static response pv_list(lvmetad_state *s, request r)
 	if (s->flags & GLFL_INVALID)
 		add_last_node(res.cft, "global_invalid");
 
-	unlock_pvid_to_pvmeta(s);
-
 	return res;
 }
 
@@ -555,12 +473,10 @@ static response pv_lookup(lvmetad_state *s, request r)
 	if (!(res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL)))
 		return reply_fail("out of memory");
 
-	lock_pvid_to_pvmeta(s);
 	if (!pvid && devt)
 		pvid = dm_hash_lookup_binary(s->device_to_pvid, &devt, sizeof(devt));
 
 	if (!pvid) {
-		unlock_pvid_to_pvmeta(s);
 		WARN(s, "pv_lookup: could not find device %" PRIu64, devt);
 		dm_config_destroy(res.cft);
 		return reply_unknown("device not found");
@@ -568,13 +484,11 @@ static response pv_lookup(lvmetad_state *s, request r)
 
 	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
 	if (!pv) {
-		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(res.cft);
 		return reply_unknown("PV not found");
 	}
 
 	pv->key = "physical_volume";
-	unlock_pvid_to_pvmeta(s);
 
 	if (s->flags & GLFL_INVALID)
 		add_last_node(res.cft, "global_invalid");
@@ -616,8 +530,6 @@ static response vg_list(lvmetad_state *s, request r)
 	cn->v = NULL;
 	cn->child = NULL;
 
-	lock_vgid_to_metadata(s);
-
 	dm_hash_iterate(n, s->vgid_to_vgname) {
 		id = dm_hash_get_key(s->vgid_to_vgname, n),
 		name = dm_hash_get_data(s->vgid_to_vgname, n);
@@ -648,8 +560,6 @@ static response vg_list(lvmetad_state *s, request r)
 		cn_last = cn;
 	}
 
-	unlock_vgid_to_metadata(s);
-
 	if (s->flags & GLFL_INVALID)
 		add_last_node(res.cft, "global_invalid");
 bad:
@@ -662,9 +572,7 @@ static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvi
 	struct dm_config_node *list, *cft_vgid;
 	struct dm_config_value *v;
 
-	lock_pvid_to_pvmeta(s);
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
-	unlock_pvid_to_pvmeta(s);
 
 	/* if the MDA exists and is used, it will have ignore=0 set */
 	if (!pvmeta ||
@@ -745,12 +653,10 @@ static response vg_lookup(lvmetad_state *s, request r)
 		DEBUGLOG(s, "vg_lookup vgid %s name %s needs lookup",
 			 uuid ?: "none", name ?: "none");
 
-		lock_vgid_to_metadata(s);
 		if (name && !uuid)
 			uuid = dm_hash_lookup_with_count(s->vgname_to_vgid, name, &count);
 		else if (uuid && !name)
 			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
-		unlock_vgid_to_metadata(s);
 
 		if (name && uuid && (count > 1)) {
 			DEBUGLOG(s, "vg_lookup name %s vgid %s found %d vgids",
@@ -780,9 +686,8 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	DEBUGLOG(s, "vg_lookup vgid %s name %s", uuid ?: "none", name ?: "none");
 
-	cft = lock_vg(s, uuid);
+	cft = dm_hash_lookup(s->vgid_to_metadata, uuid);
 	if (!cft || !cft->root) {
-		unlock_vg(s, uuid);
 		return reply_unknown("UUID not found");
 	}
 
@@ -815,7 +720,6 @@ static response vg_lookup(lvmetad_state *s, request r)
 	if (!(n = n->sib = dm_config_clone_node(res.cft, metadata, 1)))
 		goto nomem_un;
 	n->parent = res.cft->root;
-	unlock_vg(s, uuid);
 
 	if (!update_pv_status(s, res.cft, n))
 		goto nomem;
@@ -833,7 +737,6 @@ static response vg_lookup(lvmetad_state *s, request r)
 	return res;
 
 nomem_un:
-	unlock_vg(s, uuid);
 nomem:
 	reply_fail("out of memory");
 	ERROR(s, "vg_lookup vgid %s name %s out of memory.", uuid ?: "none", name ?: "none");
@@ -901,9 +804,7 @@ static int _update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 
 	dm_hash_iterate(n, to_check) {
 		check_vgid = dm_hash_get_key(to_check, n);
-		lock_vg(s, check_vgid);
 		vg_remove_if_missing(s, check_vgid, 0);
-		unlock_vg(s, check_vgid);
 	}
 
 	r = 1;
@@ -925,8 +826,6 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	char *name_lookup = NULL;
 	char *vgid_lookup = NULL;
 
-	lock_vgid_to_metadata(s);
-
 	/* get data pointers from hash table so they can be freed */
 
 	info_lookup = dm_hash_lookup(s->vgid_to_info, vgid);
@@ -945,8 +844,6 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	if (name_lookup)
 		dm_hash_remove_with_val(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
 
-	unlock_vgid_to_metadata(s);
-
 	/* update_pvid_to_vgid will clear/free the pvid_to_vgid hash */
 	if (update_pvids && meta_lookup)
 		_update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
@@ -981,7 +878,6 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_p
 	if (!(vg = dm_hash_lookup(s->vgid_to_metadata, vgid)))
 		return 1;
 
-	lock_pvid_to_pvmeta(s);
 	for (pv = pvs(vg->root); pv; pv = pv->sib) {
 		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
 			continue;
@@ -997,8 +893,6 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_p
 		remove_metadata(s, vgid, update_pvids);
 	}
 
-	unlock_pvid_to_pvmeta(s);
-
 	return 1;
 }
 
@@ -1020,14 +914,12 @@ static void _purge_metadata(lvmetad_state *s, const char *arg_name, const char *
 {
 	char *rem_vgid;
 
-	lock_pvid_to_vgid(s);
 	remove_metadata(s, arg_vgid, 1);
 
 	if ((rem_vgid = dm_hash_lookup_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
 		dm_hash_remove_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
 		dm_free(rem_vgid);
 	}
-	unlock_pvid_to_vgid(s);
 }
 
 /*
@@ -1060,10 +952,6 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	if (!(arg_name_dup = dm_strdup(arg_name)))
 		goto ret;
 
-	lock_vg(s, new_vgid);
-	lock_pvid_to_vgid(s);
-	lock_vgid_to_metadata(s);
-
 	/*
 	 * Temporarily orphan the PVs in the old metadata.
 	 */
@@ -1130,9 +1018,6 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	DEBUGLOG(s, "update_metadata_new_vgid is done for %s %s", arg_name, new_vgid);
 	retval = 1;
 out:
-	unlock_vgid_to_metadata(s);
-	unlock_pvid_to_vgid(s);
-	unlock_vg(s, new_vgid);
 ret:
 	if (!new_vgid_dup || !arg_name_dup || abort_daemon) {
 		ERROR(s, "lvmetad could not be updated and is aborting.");
@@ -1174,10 +1059,6 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	if (!(arg_vgid_dup = dm_strdup(arg_vgid)))
 		goto ret;
 
-	lock_vg(s, arg_vgid);
-	lock_pvid_to_vgid(s);
-	lock_vgid_to_metadata(s);
-
 	/*
 	 * Temporarily orphan the PVs in the old metadata.
 	 */
@@ -1244,9 +1125,6 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	DEBUGLOG(s, "update_metadata_new_name is done for %s %s", new_name, arg_vgid);
 	retval = 1;
 out:
-	unlock_vgid_to_metadata(s);
-	unlock_pvid_to_vgid(s);
-	unlock_vg(s, arg_vgid);
 ret:
 	if (!new_name_dup || !arg_vgid_dup || abort_daemon) {
 		ERROR(s, "lvmetad could not be updated and is aborting.");
@@ -1279,10 +1157,6 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 	if (!(new_vgid_dup = dm_strdup(new_vgid)))
 		goto out_free;
 
-	lock_vg(s, new_vgid);
-	lock_pvid_to_vgid(s);
-	lock_vgid_to_metadata(s);
-
 	if (!dm_hash_insert(s->vgid_to_metadata, new_vgid, new_meta)) {
 		ERROR(s, "update_metadata_add_new out of memory for meta hash insert for %s %s", new_name, new_vgid);
 		abort_daemon = 1;
@@ -1310,10 +1184,6 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 	DEBUGLOG(s, "update_metadata_add_new is done for %s %s", new_name, new_vgid);
 	retval = 1;
 out:
-	unlock_vgid_to_metadata(s);
-	unlock_pvid_to_vgid(s);
-	unlock_vg(s, new_vgid);
-
 out_free:
 	if (!new_name_dup || !new_vgid_dup || abort_daemon) {
 		ERROR(s, "lvmetad could not be updated and is aborting.");
@@ -1381,7 +1251,6 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * . the VG could have unchanged vgid and name - found existing record of both.
 	 */
 
-	lock_vgid_to_metadata(s);
 	arg_name_lookup = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
 	arg_vgid_lookup = dm_hash_lookup_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
 
@@ -1538,8 +1407,6 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	}
 
  update:
-	unlock_vgid_to_metadata(s);
-
 	filter_metadata(new_metadata); /* sanitize */
 
 	/*
@@ -1682,9 +1549,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		      pvid, new_seq, arg_vgid, arg_name, old_seq);
 		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
 		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		lock_pvid_to_vgid(s);
 		_update_pvid_to_vgid(s, old_meta, arg_vgid, MARK_OUTDATED);
-		unlock_pvid_to_vgid(s);
 	}
 
 	/*
@@ -1800,10 +1665,6 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 */
 	DEBUGLOG(s, "update_metadata for %s %s from %d to %d", arg_name, arg_vgid, old_seq, new_seq);
 
-	lock_vg(s, arg_vgid);
-	lock_pvid_to_vgid(s);
-	lock_vgid_to_metadata(s);
-
 	/*
 	 * The PVs in the VG may have changed in the new metadata, so
 	 * temporarily orphan all of the PVs in the existing VG.
@@ -1812,9 +1673,6 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 */
 	if (!_update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
 		ERROR(s, "update_metadata failed to move PVs for %s %s", arg_name, arg_vgid);
-		unlock_vgid_to_metadata(s);
-		unlock_pvid_to_vgid(s);
-		unlock_vg(s, arg_vgid);
 		abort_daemon = 1;
 		retval = 0;
 		goto out;
@@ -1832,9 +1690,6 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 
 	if (!dm_hash_insert(s->vgid_to_metadata, arg_vgid, new_meta)) {
 		ERROR(s, "update_metadata out of memory for hash insert for %s %s", arg_name, arg_vgid);
-		unlock_vgid_to_metadata(s);
-		unlock_pvid_to_vgid(s);
-		unlock_vg(s, arg_vgid);
 		abort_daemon = 1;
 		retval = 0;
 		goto out;
@@ -1857,10 +1712,6 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		retval = 1;
 	}
 
-	unlock_vgid_to_metadata(s);
-	unlock_pvid_to_vgid(s);
-	unlock_vg(s, arg_vgid);
-
 out:
 	if (abort_daemon) {
 		ERROR(s, "lvmetad could not be updated is aborting.");
@@ -1884,12 +1735,10 @@ static response pv_gone(lvmetad_state *s, request r)
 	arg_pvid = daemon_request_str(r, "uuid", NULL);
 	device = daemon_request_int(r, "device", 0);
 
-	lock_pvid_to_pvmeta(s);
 	if (!arg_pvid && device > 0)
 		old_pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 
 	if (!arg_pvid && !old_pvid) {
-		unlock_pvid_to_pvmeta(s);
 		DEBUGLOG(s, "pv_gone device %" PRIu64 " not found", device);
 		return reply_unknown("device not in cache");
 	}
@@ -1909,8 +1758,6 @@ static response pv_gone(lvmetad_state *s, request r)
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 
-	unlock_pvid_to_pvmeta(s);
-
 	if (vgid) {
 		char *vgid_dup;
 		/*
@@ -1921,9 +1768,7 @@ static response pv_gone(lvmetad_state *s, request r)
 		if (!(vgid_dup = dm_strdup(vgid)))
 			return reply_fail("out of memory");
 
-		lock_vg(s, vgid_dup);
 		vg_remove_if_missing(s, vgid_dup, 1);
-		unlock_vg(s, vgid_dup);
 		dm_free(vgid_dup);
 		vgid_dup = NULL;
 		vgid = NULL;
@@ -1940,17 +1785,9 @@ static response pv_clear_all(lvmetad_state *s, request r)
 {
 	DEBUGLOG(s, "pv_clear_all");
 
-	lock_pvid_to_pvmeta(s);
-	lock_pvid_to_vgid(s);
-	lock_vgid_to_metadata(s);
-
 	destroy_metadata_hashes(s);
 	create_metadata_hashes(s);
 
-	unlock_pvid_to_vgid(s);
-	unlock_vgid_to_metadata(s);
-	unlock_pvid_to_pvmeta(s);
-
 	return daemon_reply_simple("OK", NULL);
 }
 
@@ -1964,8 +1801,6 @@ static int _vg_is_complete(lvmetad_state *s, struct dm_config_tree *vgmeta)
 	int complete = 1;
 	const char *pvid;
 
-	lock_pvid_to_pvmeta(s);
-
 	for (pv = pvs(vg); pv; pv = pv->sib) {
 		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
 			continue;
@@ -1975,7 +1810,6 @@ static int _vg_is_complete(lvmetad_state *s, struct dm_config_tree *vgmeta)
 			break;
 		}
 	}
-	unlock_pvid_to_pvmeta(s);
 
 	return complete;
 }
@@ -2116,8 +1950,6 @@ static response pv_found(lvmetad_state *s, request r)
 	 * Existing (old) cache values.
 	 */
 
-	lock_pvid_to_pvmeta(s);
-
 	old_pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, arg_pvid);
 	if (old_pvmeta)
 		dm_config_get_uint64(old_pvmeta->root, "pvmeta/device", &arg_device_lookup);
@@ -2188,7 +2020,6 @@ static response pv_found(lvmetad_state *s, request r)
 		      arg_pvid_lookup ?: "none",
 		      arg_vgid_lookup ?: "none",
 		      arg_device_lookup);
-		unlock_pvid_to_pvmeta(s);
 		return reply_fail("Ignore PV for unknown state");
 	}
 
@@ -2256,7 +2087,6 @@ static response pv_found(lvmetad_state *s, request r)
 			if (dm_hash_lookup(s->pvid_to_pvmeta, new_pvid)) {
 				DEBUGLOG(s, "pv_found ignore duplicate device %" PRIu64 " of existing PV for pvid %s",
 				         arg_device, arg_pvid);
-				unlock_pvid_to_pvmeta(s);
 				dm_config_destroy(new_pvmeta);
 				s->flags |= GLFL_DISABLE;
 				s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
@@ -2281,15 +2111,12 @@ static response pv_found(lvmetad_state *s, request r)
 		 */
 		DEBUGLOG(s, "pv_found ignore duplicate device %" PRIu64 " of existing device %" PRIu64 " for pvid %s",
 			 new_device, old_device, arg_pvid);
-		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(new_pvmeta);
 		s->flags |= GLFL_DISABLE;
 		s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
 		return reply_fail("Ignore duplicate PV");
 	}
 
-	unlock_pvid_to_pvmeta(s);
-
 	if (old_pvmeta)
 		dm_config_destroy(old_pvmeta);
 
@@ -2308,21 +2135,17 @@ static response pv_found(lvmetad_state *s, request r)
 
 		changed |= (old_seqno != arg_seqno);
 	} else {
-		lock_pvid_to_vgid(s);
 		arg_vgid = dm_hash_lookup(s->pvid_to_vgid, arg_pvid);
-		unlock_pvid_to_vgid(s);
 
 		if (arg_vgid) {
-			lock_vgid_to_metadata(s);
 			arg_name = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
-			unlock_vgid_to_metadata(s);
 		}
 	}
 
 	/*
 	 * Check if the VG is complete (all PVs have been found) because
 	 * the reply indicates if the the VG is complete or partial.
-	 * The "vgmeta" from lock_vg will be a copy of arg_vgmeta that
+	 * The "vgmeta" from dm_hash_lookup will be a copy of arg_vgmeta that
 	 * was cloned and added to the cache by update_metadata.
 	 */
 	if (!arg_vgid || !strcmp(arg_vgid, "#orphan")) {
@@ -2332,14 +2155,13 @@ static response pv_found(lvmetad_state *s, request r)
 		goto prev_vals;
 	}
 
-	if (!(vgmeta = lock_vg(s, arg_vgid))) {
+	if (!(vgmeta = dm_hash_lookup(s->vgid_to_metadata, arg_vgid))) {
 		ERROR(s, "pv_found %s on %" PRIu64 " vgid %s no VG metadata found",
 		      arg_pvid, arg_device, arg_vgid);
 	} else {
 		vg_status = _vg_is_complete(s, vgmeta) ? "complete" : "partial";
 		vg_status_seqno = dm_config_find_int(vgmeta->root, "metadata/seqno", -1);
 	}
-	unlock_vg(s, arg_vgid);
 
  prev_vals:
 	/*
@@ -2364,9 +2186,7 @@ static response pv_found(lvmetad_state *s, request r)
 			tmp_vgid = dm_strdup(prev_vgid_on_dev);
 			/* vg_remove_if_missing will clear and free
 			   the string pointed to by prev_vgid_on_dev. */
-			lock_vg(s, tmp_vgid);
 			vg_remove_if_missing(s, tmp_vgid, 1);
-			unlock_vg(s, tmp_vgid);
 			dm_free(tmp_vgid);
 		}
 
@@ -2484,9 +2304,7 @@ static response vg_remove(lvmetad_state *s, request r)
 
 	DEBUGLOG(s, "vg_remove: %s", vgid);
 
-	lock_pvid_to_vgid(s);
 	remove_metadata(s, vgid, 1);
-	unlock_pvid_to_vgid(s);
 
 	return daemon_reply_simple("OK", NULL);
 }
@@ -2745,10 +2563,6 @@ static response dump(lvmetad_state *s)
 
 	/* Lock everything so that we get a consistent dump. */
 
-	lock_vgid_to_metadata(s);
-	lock_pvid_to_pvmeta(s);
-	lock_pvid_to_vgid(s);
-
 	buffer_append(b, "# VG METADATA\n\n");
 	_dump_cft(b, s->vgid_to_metadata, "metadata/id");
 
@@ -2776,10 +2590,6 @@ static response dump(lvmetad_state *s)
 	buffer_append(b, "\n# VGID to INFO flags mapping\n\n");
 	_dump_info_flags(b, s->vgid_to_info, "vgid_to_info", 0);
 
-	unlock_pvid_to_vgid(s);
-	unlock_pvid_to_pvmeta(s);
-	unlock_vgid_to_metadata(s);
-
 	return res;
 }
 
@@ -2905,22 +2715,14 @@ static response handler(daemon_state s, client_handle h, request r)
 
 static int init(daemon_state *s)
 {
-	pthread_mutexattr_t rec;
 	lvmetad_state *ls = s->private;
 	ls->log = s->log;
 
-	pthread_mutexattr_init(&rec);
-	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
-	pthread_mutex_init(&ls->lock.pvid_to_pvmeta, &rec);
-	pthread_mutex_init(&ls->lock.vgid_to_metadata, &rec);
-	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
-	pthread_mutex_init(&ls->lock.vg_lock_map, NULL);
 	pthread_mutex_init(&ls->token_lock, NULL);
 	pthread_mutex_init(&ls->info_lock, NULL);
 	pthread_rwlock_init(&ls->cache_lock, NULL);
 	create_metadata_hashes(ls);
 
-	ls->lock.vg = dm_hash_create(32);
 	ls->token[0] = 0;
 
 	/* Set up stderr logging depending on the -l option. */
@@ -2943,19 +2745,9 @@ static int init(daemon_state *s)
 static int fini(daemon_state *s)
 {
 	lvmetad_state *ls = s->private;
-	struct dm_hash_node *n;
 
 	DEBUGLOG(s, "fini");
-
 	destroy_metadata_hashes(ls);
-
-	/* Destroy the lock hashes now. */
-	dm_hash_iterate(n, ls->lock.vg) {
-		pthread_mutex_destroy(dm_hash_get_data(ls->lock.vg, n));
-		free(dm_hash_get_data(ls->lock.vg, n));
-	}
-
-	dm_hash_destroy(ls->lock.vg);
 	return 1;
 }
 


