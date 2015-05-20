From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:01 +0000 (UTC)
Subject: master - lvmetad: Maintain info about outdated PVs.
Message-ID: <20150520174801.413B360188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=925268794f4c97091674d99d98e3d73349a75502
Commit:        925268794f4c97091674d99d98e3d73349a75502
Parent:        f3c7bd4004a64b6ce2c9e0f0069eedb050420c62
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 15 13:00:35 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:13 2015 +0200

lvmetad: Maintain info about outdated PVs.

---
 daemons/lvmetad/lvmetad-core.c |   82 +++++++++++++++++++++++++++++++++++++---
 1 files changed, 76 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 398ef38..7e30add 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -40,6 +40,7 @@ typedef struct {
 
 	struct dm_hash_table *vgid_to_metadata;
 	struct dm_hash_table *vgid_to_vgname;
+	struct dm_hash_table *vgid_to_outdated_pvs;
 	struct dm_hash_table *vgname_to_vgid;
 	struct dm_hash_table *pvid_to_vgid;
 	struct {
@@ -66,6 +67,7 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 	dm_hash_destroy(s->pvid_to_pvmeta);
 	dm_hash_destroy(s->vgid_to_metadata);
 	dm_hash_destroy(s->vgid_to_vgname);
+	dm_hash_destroy(s->vgid_to_outdated_pvs);
 	dm_hash_destroy(s->vgname_to_vgid);
 
 	dm_hash_destroy(s->device_to_pvid);
@@ -78,6 +80,7 @@ static void create_metadata_hashes(lvmetad_state *s)
 	s->device_to_pvid = dm_hash_create(32);
 	s->vgid_to_metadata = dm_hash_create(32);
 	s->vgid_to_vgname = dm_hash_create(32);
+	s->vgid_to_outdated_pvs = dm_hash_create(32);
 	s->pvid_to_vgid = dm_hash_create(32);
 	s->vgname_to_vgid = dm_hash_create(32);
 }
@@ -420,6 +423,54 @@ bad:
 	return res;
 }
 
+static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvid)
+{
+	struct dm_config_tree *pvmeta, *outdated_pvs;
+	struct dm_config_node *list, *cft_vgid;
+	struct dm_config_value *v;
+
+	lock_pvid_to_pvmeta(s);
+	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
+	unlock_pvid_to_pvmeta(s);
+
+	/* if the MDA exists and is used, it will have ignore=0 set */
+	if (!pvmeta ||
+	    (dm_config_find_int64(pvmeta->root, "pvmeta/mda0/ignore", 1) &&
+	     dm_config_find_int64(pvmeta->root, "pvmeta/mda1/ignore", 1)))
+		return;
+
+	WARN(s, "PV %s has outdated metadata", pvid);
+
+	outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
+	if (!outdated_pvs) {
+		if (!(outdated_pvs = dm_config_from_string("outdated_pvs/pv_list = []")) ||
+		    !(cft_vgid = make_text_node(outdated_pvs, "vgid", dm_pool_strdup(outdated_pvs->mem, vgid),
+						outdated_pvs->root, NULL)))
+			abort();
+		if(!dm_hash_insert(s->vgid_to_outdated_pvs, cft_vgid->v->v.str, outdated_pvs))
+			abort();
+		DEBUGLOG(s, "created outdated_pvs list for VG %s", vgid);
+	}
+
+	list = dm_config_find_node(outdated_pvs->root, "outdated_pvs/pv_list");
+	v = list->v;
+	while (v) {
+		if (v->type != DM_CFG_EMPTY_ARRAY && !strcmp(v->v.str, pvid))
+			return;
+		v = v->next;
+	}
+	if (!(v = dm_config_create_value(outdated_pvs)))
+		abort();
+	v->type = DM_CFG_STRING;
+	v->v.str = dm_pool_strdup(outdated_pvs->mem, pvid);
+	v->next = list->v;
+	list->v = v;
+}
+
+static void chain_outdated_pvs(lvmetad_state *s, const char *vgid, struct dm_config_tree *metadata)
+{
+}
+
 static response vg_lookup(lvmetad_state *s, request r)
 {
 	struct dm_config_tree *cft;
@@ -486,6 +537,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 	unlock_vg(s, uuid);
 
 	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
+	chain_outdated_pvs(s, uuid, res.cft);
 
 	return res;
 bad:
@@ -549,9 +601,11 @@ static int compare_config(struct dm_config_node *a, struct dm_config_node *b)
 
 static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_pvids);
 
+enum update_pvid_mode { UPDATE_ONLY, REMOVE_EMPTY, MARK_OUTDATED };
+
 /* You need to be holding the pvid_to_vgid lock already to call this. */
 static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
-			       const char *vgid, int nuke_empty)
+			       const char *vgid, int mode)
 {
 	struct dm_config_node *pv;
 	struct dm_hash_table *to_check;
@@ -571,11 +625,14 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
 			continue;
 
-		if (nuke_empty &&
+		if (mode == REMOVE_EMPTY &&
 		    (vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid)) &&
 		    !dm_hash_insert(to_check, vgid_old, (void*) 1))
 			goto out;
 
+		if (mode == MARK_OUTDATED)
+			mark_outdated_pv(s, vgid, pvid);
+
 		if (!dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid))
 			goto out;
 
@@ -599,10 +656,11 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 /* A pvid map lock needs to be held if update_pvids = 1. */
 static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 {
-	struct dm_config_tree *old;
+	struct dm_config_tree *old, *outdated_pvs;
 	const char *oldname;
 	lock_vgid_to_metadata(s);
 	old = dm_hash_lookup(s->vgid_to_metadata, vgid);
+	outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
 	oldname = dm_hash_lookup(s->vgid_to_vgname, vgid);
 
 	if (!old) {
@@ -616,12 +674,15 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	dm_hash_remove(s->vgid_to_metadata, vgid);
 	dm_hash_remove(s->vgid_to_vgname, vgid);
 	dm_hash_remove(s->vgname_to_vgid, oldname);
+	dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
 	unlock_vgid_to_metadata(s);
 
 	if (update_pvids)
 		/* FIXME: What should happen when update fails */
 		update_pvid_to_vgid(s, old, "#orphan", 0);
 	dm_config_destroy(old);
+	if (outdated_pvs)
+		dm_config_destroy(outdated_pvs);
 	return 1;
 }
 
@@ -665,7 +726,7 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_p
  * this function, so they can be safely destroyed after update_metadata returns
  * (anything that might have been retained is copied). */
 static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid,
-			   struct dm_config_node *metadata, int64_t *oldseq)
+			   struct dm_config_node *metadata, int64_t *oldseq, const char *pvid)
 {
 	struct dm_config_tree *cft = NULL;
 	struct dm_config_tree *old;
@@ -714,6 +775,10 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 
 	if (seq < haveseq) {
 		DEBUGLOG(s, "Refusing to update metadata for %s (at %d) to %d", _vgid, haveseq, seq);
+
+		if (pvid)
+			mark_outdated_pv(s, dm_config_find_str(old->root, "metadata/id", NULL), pvid);
+
 		/* TODO: notify the client that their metadata is out of date? */
 		retval = 1;
 		goto out;
@@ -736,6 +801,8 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 
 	if (haveseq >= 0 && haveseq < seq) {
 		INFO(s, "Updating metadata for %s@%d to %d", _vgid, haveseq, seq);
+		if (oldseq)
+			update_pvid_to_vgid(s, old, vgid, MARK_OUTDATED);
 		/* temporarily orphan all of our PVs */
 		update_pvid_to_vgid(s, old, "#orphan", 0);
 	}
@@ -992,7 +1059,7 @@ out_of_mem:
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
 			return reply_fail("need VG seqno");
 
-		if (!update_metadata(s, vgname, vgid, metadata, &seqno_old))
+		if (!update_metadata(s, vgname, vgid, metadata, &seqno_old, pvid))
 			return reply_fail("metadata update failed");
 		changed |= (seqno_old != dm_config_find_int(metadata, "metadata/seqno", -1));
 	} else {
@@ -1055,7 +1122,7 @@ static response vg_update(lvmetad_state *s, request r)
 
 		/* TODO defer metadata update here; add a separate vg_commit
 		 * call; if client does not commit, die */
-		if (!update_metadata(s, vgname, vgid, metadata, NULL))
+		if (!update_metadata(s, vgname, vgid, metadata, NULL, NULL))
 			return reply_fail("metadata update failed");
 	}
 	return daemon_reply_simple("OK", NULL);
@@ -1136,6 +1203,9 @@ static response dump(lvmetad_state *s)
 	buffer_append(b, "\n# VGID to VGNAME mapping\n\n");
 	_dump_pairs(b, s->vgid_to_vgname, "vgid_to_vgname", 0);
 
+	buffer_append(b, "\n# VGID to outdated PVs mapping\n\n");
+	_dump_cft(b, s->vgid_to_outdated_pvs, "outdated_pvs/vgid");
+
 	buffer_append(b, "\n# VGNAME to VGID mapping\n\n");
 	_dump_pairs(b, s->vgname_to_vgid, "vgname_to_vgid", 0);
 


