From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 21:23:44 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720212344.5756.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 21:23:44

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	First stab at making lvmetad-core threadsafe. The current design should allow
	very reasonable amount of parallel access, although the hash tables may become
	a point of contention under heavy loads. Nevertheless, there should be orders
	of magnitude less contention on the hash table locks than we currently have on
	block device scanning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 18:45:32	1.15
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:23:43	1.16
@@ -1,4 +1,5 @@
 #include <assert.h>
+#include <pthread.h>
 
 #include "libdevmapper.h"
 #include <malloc.h>
@@ -10,15 +11,64 @@
 	struct dm_hash_table *pvs;
 	struct dm_hash_table *vgs;
 	struct dm_hash_table *pvid_map;
+	struct {
+		struct dm_hash_table *vg;
+		pthread_mutex_t pvs;
+		pthread_mutex_t vgs;
+		pthread_mutex_t pvid_map;
+	} lock;
 } lvmetad_state;
 
+void debug(const char *fmt, ...) {
+	va_list ap;
+	va_start(ap, fmt);
+	fprintf(stderr, "[D %u] ", pthread_self());
+	vfprintf(stderr, fmt, ap);
+	va_end(ap);
+};
+
+void lock_pvs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvs); }
+void unlock_pvs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvs); }
+
+void lock_vgs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.vgs); }
+void unlock_vgs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.vgs); }
+
+void lock_pvid_map(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvid_map); }
+void unlock_pvid_map(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvid_map); }
+
+struct config_tree *lock_vg(lvmetad_state *s, const char *id) {
+	lock_vgs(s);
+	pthread_mutex_t *vg = dm_hash_lookup(s->lock.vg, id);
+	if (!vg) {
+		pthread_mutexattr_t rec;
+		pthread_mutexattr_init(&rec);
+		pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
+		vg = malloc(sizeof(pthread_mutex_t));
+		pthread_mutex_init(vg, &rec);
+		dm_hash_insert(s->lock.vg, id, vg);
+	}
+	pthread_mutex_lock(vg);
+	struct config_tree *cft = dm_hash_lookup(s->vgs, id);
+	unlock_vgs(s);
+	return cft;
+}
+
+void unlock_vg(lvmetad_state *s, const char *id) {
+	lock_vgs(s); /* someone might be changing the s->lock.vg structure right
+		      * now, so avoid stepping on each other's toes */
+	pthread_mutex_unlock(dm_hash_lookup(s->lock.vg, id));
+	unlock_vgs(s);
+}
+
 static response vg_by_uuid(lvmetad_state *s, request r)
 {
 	const char *uuid = daemon_request_str(r, "uuid", "NONE");
-	fprintf(stderr, "[D] vg_by_uuid: %s (vgs = %p)\n", uuid, s->vgs);
-	struct config_tree *cft = dm_hash_lookup(s->vgs, uuid);
-	if (!cft || !cft->root)
+	debug("vg_by_uuid: %s (vgs = %p)\n", uuid, s->vgs);
+	struct config_tree *cft = lock_vg(s, uuid);
+	if (!cft || !cft->root) {
+		unlock_vg(s, uuid);
 		return daemon_reply_simple("failed", "reason = %s", "uuid not found", NULL);
+	}
 
 	struct config_node *metadata = cft->root;
 
@@ -35,6 +85,8 @@
 	n = n->sib = clone_config_node(res.cft, metadata, 1);
 	n->parent = res.cft->root;
 	res.error = 0;
+	unlock_vg(s, uuid);
+
 	return res;
 }
 
@@ -47,7 +99,7 @@
 	if (node)
 		value = node->v;
 
-	while (value && strcmp(value->v.str, flag)) {
+	while (value && value->type != CFG_EMPTY_ARRAY && strcmp(value->v.str, flag)) {
 		pred = value;
 		value = value->next;
 	}
@@ -90,62 +142,49 @@
 	return pv;
 }
 
-static void update_pv_status_in_vg(lvmetad_state *s, struct config_tree *vg)
+/* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
+ * this function. */
+static void update_pv_status(lvmetad_state *s, struct config_tree *vg)
 {
+	lock_pvs(s);
 	struct config_node *pv = pvs(vg);
 	while (pv) {
 		const char *uuid = find_config_str(pv->child, "id", "N/A");
 		const char *vgid = find_config_str(vg->root, "metadata/id", "N/A");
 		int found = dm_hash_lookup(s->pvs, uuid) ? 1 : 0;
+		// TODO: avoid the override here if MISSING came from the actual
+		// metadata, as opposed from our manipulation...
 		set_flag(vg, pv, "status", "MISSING", !found);
 		pv = pv->sib;
 	}
+	unlock_pvs(s);
 }
 
 static int vg_status(lvmetad_state *s, const char *vgid)
 {
-	struct config_tree *vg = dm_hash_lookup(s->vgs, vgid);
+	struct config_tree *vg = lock_vg(s, vgid);
 	struct config_node *pv = pvs(vg);
 
 	while (pv) {
-		const char *uuid = find_config_str(pv->child, "id", "N/A");
-		const char *vgid = find_config_str(vg->root, "metadata/id", "N/A");
+		const char *uuid = find_config_str(pv->child, "id", NULL);
+		if (!uuid)
+			continue; // FIXME?
+
+		lock_pvs(s);
 		int found = dm_hash_lookup(s->pvs, uuid) ? 1 : 0;
-		if (!found)
+		unlock_pvs(s);
+		if (!found) {
+			unlock_vg(s, vgid);
 			return 0;
+		}
 		pv = pv->sib;
 	}
 
+	unlock_vg(s, vgid);
 	return 1;
 }
 
-/*
- * Walk through metadata cache and update PV flags to reflect our current
- * picture of the PVs in the system. If pvid is non-NULL, this is used as a hint
- * as to which PV has changed state. Otherwise, all flags are recomputed from
- * authoritative data (the s->pvs hash).
- */
-static void update_pv_status(lvmetad_state *s, const char *pvid)
-{
-	if (pvid) {
-		const char *vgid = dm_hash_lookup(s->pvid_map, pvid);
-		if (!vgid)
-			return; /* nothing to update */
-
-		struct config_tree *vg = dm_hash_lookup(s->vgs, vgid);
-		assert(vg);
-
-		update_pv_status_in_vg(s, vg);
-	} else {
-		struct dm_hash_node *n = dm_hash_get_first(s->vgs);
-		while (n) {
-			struct config_tree *vg = dm_hash_get_data(s->vgs, n);
-			update_pv_status_in_vg(s, vg);
-			n = dm_hash_get_next(s->vgs, n);
-		}
-	}
-}
-
+/* You need to be holding the pvid_map lock already to call this. */
 int update_pvid_map(lvmetad_state *s, struct config_tree *vg, const char *vgid)
 {
 	struct config_node *pv = pvs(vg);
@@ -162,9 +201,17 @@
 	return 1;
 }
 
+/* No locks need to be held. The pointers are never used outside of the scope of
+ * this function, so they can be safely destroyed after update_metadata returns
+ * (anything that might have been retained is copied). */
 static int update_metadata(lvmetad_state *s, const char *_vgid, struct config_node *metadata)
 {
+	int retval = 0;
+	lock_vgs(s);
 	struct config_tree *old = dm_hash_lookup(s->vgs, _vgid);
+	lock_vg(s, _vgid);
+	unlock_vgs(s);
+
 	int seq = find_config_int(metadata, "metadata/seqno", -1);
 	int haveseq = -1;
 
@@ -172,17 +219,19 @@
 		haveseq = find_config_int(old->root, "metadata/seqno", -1);
 
 	if (seq < 0)
-		return 0; /* bad */
+		goto out;
 
 	if (seq == haveseq) {
 		// TODO: compare old->root with metadata to ensure equality
-		return 1;
+		retval = 1;
+		goto out;
 	}
 
 	if (seq < haveseq) {
 		// TODO: we may want to notify the client that their metadata is
 		// out of date?
-		return 1;
+		retval = 1;
+		goto out;
 	}
 
 	struct config_tree *cft = create_config_tree(NULL, 0);
@@ -190,7 +239,9 @@
 	const char *vgid = find_config_str(cft->root, "metadata/id", NULL);
 
 	if (!vgid)
-		return 0;
+		goto out;
+
+	lock_pvid_map(s);
 
 	if (haveseq >= 0 && haveseq < seq) {
 		/* temporarily orphan all of our PVs */
@@ -200,10 +251,17 @@
 		dm_hash_remove(s->vgs, vgid);
 	}
 
+	lock_vgs(s);
 	dm_hash_insert(s->vgs, vgid, cft);
+	unlock_vgs(s);
+
 	update_pvid_map(s, cft, vgid);
 
-	return 1;
+	unlock_pvid_map(s);
+	retval = 1;
+out:
+	unlock_vg(s, _vgid);
+	return retval;
 }
 
 static response pv_add(lvmetad_state *s, request r)
@@ -215,7 +273,9 @@
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
 
+	lock_pvs(s);
 	dm_hash_insert(s->pvs, pvid, (void*)1);
+	unlock_pvs(s);
 
 	if (metadata) {
 		if (!vgid)
@@ -226,10 +286,18 @@
 		if (!update_metadata(s, vgid, metadata))
 			return daemon_reply_simple("failed", "reason = %s",
 						   "metadata update failed", NULL);
-	} else
+	} else {
+		lock_pvid_map(s);
 		vgid = dm_hash_lookup(s->pvid_map, pvid);
+		unlock_pvid_map(s);
+	}
+
+	if (vgid) {
+		struct config_tree *cft = lock_vg(s, vgid);
+		update_pv_status(s, cft);
+		unlock_vg(s, vgid);
+	}
 
-	update_pv_status(s, pvid);
 	int complete = vgid ? vg_status(s, vgid) : 0;
 
 	return daemon_reply_simple("OK",
@@ -247,7 +315,7 @@
 	lvmetad_state *state = s.private;
 	const char *rq = daemon_request_str(r, "request", "NONE");
 
-	fprintf(stderr, "[D] REQUEST: %s\n", rq);
+	debug("REQUEST: %s\n", rq);
 
 	if (!strcmp(rq, "pv_add"))
 		return pv_add(state, r);
@@ -266,7 +334,16 @@
 	ls->pvs = dm_hash_create(32);
 	ls->vgs = dm_hash_create(32);
 	ls->pvid_map = dm_hash_create(32);
-	fprintf(stderr, "[D] initialised state: vgs = %p\n", ls->vgs);
+
+	ls->lock.vg = dm_hash_create(32);
+	pthread_mutexattr_t rec;
+	pthread_mutexattr_init(&rec);
+	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
+	pthread_mutex_init(&ls->lock.pvs, NULL);
+	pthread_mutex_init(&ls->lock.vgs, &rec);
+	pthread_mutex_init(&ls->lock.pvid_map, NULL);
+
+	debug("initialised state: vgs = %p\n", ls->vgs);
 	if (!ls->pvs || !ls->vgs)
 		return 0;
 


