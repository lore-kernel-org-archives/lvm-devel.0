From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 11:43:07 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120215114307.6042.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 11:43:07

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad server-side update:
	- rename the hashes to be explicit about the mapping
	- add VG/PV listing calls to the protocol
	- cache slightly more of the per-PV state
	- filter cached metadata
	- compare the metadata upon metadata_update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/13 14:25:14	1.32
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 11:43:06	1.33
@@ -7,20 +7,28 @@
 #include <stdint.h>
 #include <unistd.h>
 
+#include "configure.h"
 #include "libdevmapper.h"
 #include "daemon-server.h"
 
 typedef struct {
-	struct dm_hash_table *pvs;
-	struct dm_hash_table *vgs;
-	struct dm_hash_table *vg_names;
-	struct dm_hash_table *vgname_map;
-	struct dm_hash_table *pvid_map;
+	const char *path;
+	dev_t number;
+} device; /* TODO */
+
+typedef struct {
+	struct dm_hash_table *pvid_to_status;
+	struct dm_hash_table *pvid_to_device; /* shares locks with status */
+	struct dm_hash_table *device_to_pvid; /* shares locks with status */
+	struct dm_hash_table *vgid_to_metadata;
+	struct dm_hash_table *vgid_to_vgname;
+	struct dm_hash_table *vgname_to_vgid;
+	struct dm_hash_table *pvid_to_vgid;
 	struct {
 		struct dm_hash_table *vg;
-		pthread_mutex_t pvs;
-		pthread_mutex_t vgs;
-		pthread_mutex_t pvid_map;
+		pthread_mutex_t pvid_to_status;
+		pthread_mutex_t vgid_to_metadata;
+		pthread_mutex_t pvid_to_vgid;
 	} lock;
 } lvmetad_state;
 
@@ -31,16 +39,32 @@
 	fprintf(stderr, "[D %lu] ", pthread_self());
 	vfprintf(stderr, fmt, ap);
 	va_end(ap);
-};
-
-static void lock_pvs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvs); }
-static void unlock_pvs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvs); }
+}
 
-static void lock_vgs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.vgs); }
-static void unlock_vgs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.vgs); }
+static int debug_cft_line(const char *line, void *baton) {
+	fprintf(stderr, "| %s\n", line);
+	return 0;
+}
 
-static void lock_pvid_map(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvid_map); }
-static void unlock_pvid_map(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvid_map); }
+static void debug_cft(const char *id, struct dm_config_node *n) {
+	debug("%s\n", id);
+	dm_config_write_node(n, &debug_cft_line, NULL);
+}
+
+static void lock_pvid_to_status(lvmetad_state *s) {
+	pthread_mutex_lock(&s->lock.pvid_to_status); }
+static void unlock_pvid_to_status(lvmetad_state *s) {
+	pthread_mutex_unlock(&s->lock.pvid_to_status); }
+
+static void lock_vgid_to_metadata(lvmetad_state *s) {
+	pthread_mutex_lock(&s->lock.vgid_to_metadata); }
+static void unlock_vgid_to_metadata(lvmetad_state *s) {
+	pthread_mutex_unlock(&s->lock.vgid_to_metadata); }
+
+static void lock_pvid_to_vgid(lvmetad_state *s) {
+	pthread_mutex_lock(&s->lock.pvid_to_vgid); }
+static void unlock_pvid_to_vgid(lvmetad_state *s) {
+	pthread_mutex_unlock(&s->lock.pvid_to_vgid); }
 
 /*
  * TODO: It may be beneficial to clean up the vg lock hash from time to time,
@@ -51,7 +75,7 @@
 	pthread_mutex_t *vg;
 	struct dm_config_tree *cft;
 
-	lock_vgs(s);
+	lock_vgid_to_metadata(s);
 	vg = dm_hash_lookup(s->lock.vg, id);
 	if (!vg) {
 		pthread_mutexattr_t rec;
@@ -61,19 +85,19 @@
 		pthread_mutex_init(vg, &rec);
 		dm_hash_insert(s->lock.vg, id, vg);
 	}
-	debug("lock VG %s\n", id);
+	// debug("lock VG %s\n", id);
 	pthread_mutex_lock(vg);
-	cft = dm_hash_lookup(s->vgs, id);
-	unlock_vgs(s);
+	cft = dm_hash_lookup(s->vgid_to_metadata, id);
+	unlock_vgid_to_metadata(s);
 	return cft;
 }
 
 static void unlock_vg(lvmetad_state *s, const char *id) {
-	debug("unlock VG %s\n", id);
-	lock_vgs(s); /* someone might be changing the s->lock.vg structure right
-		      * now, so avoid stepping on each other's toes */
+	// debug("unlock VG %s\n", id);
+	lock_vgid_to_metadata(s); /* someone might be changing the s->lock.vg structure right
+				   * now, so avoid stepping on each other's toes */
 	pthread_mutex_unlock(dm_hash_lookup(s->lock.vg, id));
-	unlock_vgs(s);
+	unlock_vgid_to_metadata(s);
 }
 
 static struct dm_config_node *pvs(struct dm_config_node *vg)
@@ -140,6 +164,21 @@
 	return 1;
 }
 
+static void filter_metadata(struct dm_config_node *vg) {
+	struct dm_config_node *pv = pvs(vg);
+	while (pv) {
+		struct dm_config_node *item = pv->child;
+		while (item) {
+			/* Remove the advisory device nodes. */
+			if (item->sib && !strcmp(item->sib->key, "device"))
+				item->sib = item->sib->sib;
+			item = item->sib;
+		}
+		pv = pv->sib;
+	}
+	vg->sib = NULL; /* Drop any trailing garbage. */
+}
+
 /* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
  * this function. */
 static int update_pv_status(lvmetad_state *s,
@@ -149,30 +188,199 @@
 	struct dm_config_node *pv;
 	int complete = 1;
 
-	lock_pvs(s);
+	lock_pvid_to_status(s);
 	pv = pvs(vg);
 	while (pv) {
 		const char *uuid = dm_config_find_str(pv->child, "id", NULL);
-		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
-		if (act &&
-		    !set_flag(cft, pv, "status", "MISSING", !found)) {
-			complete =  0;
-			break;
+		int found = uuid ? (dm_hash_lookup(s->pvid_to_status, uuid) ? 1 : 0) : 0;
+		if (act) {
+			set_flag(cft, pv, "status", "MISSING", !found);
+			const char *devpath = dm_hash_lookup(s->pvid_to_device, uuid);
+			// debug("setting device of %s to %s\n", uuid, devpath);
+			if (devpath) {
+				struct dm_config_node *dev = dm_config_create_node(cft, "device");
+				dev->sib = pv->child;
+				dev->v = dm_config_create_value(cft);
+				dev->v->type = DM_CFG_STRING;
+				dev->v->v.str = dm_hash_lookup(s->pvid_to_device, uuid);
+				dev->parent = pv;
+				pv->child = dev;
+			}
 		}
 		if (!found) {
 			complete = 0;
-			if (!act) { // optimisation
-				unlock_pvs(s);
+			if (!act) { /* optimisation */
+				unlock_pvid_to_status(s);
 				return complete;
 			}
 		}
 		pv = pv->sib;
 	}
-	unlock_pvs(s);
+	unlock_pvid_to_status(s);
 
 	return complete;
 }
 
+static struct dm_config_node *make_config_node(struct dm_config_tree *cft,
+					       const char *key,
+					       struct dm_config_node *parent,
+					       struct dm_config_node *pre_sib)
+{
+	struct dm_config_node *cn = dm_config_create_node(cft, key);
+	cn->parent = parent;
+	cn->sib = NULL;
+	cn->v = NULL;
+	cn->child = NULL;
+
+	if (parent && !parent->child)
+		parent->child = cn;
+	if (pre_sib)
+		pre_sib->sib = cn;
+
+	return cn;
+}
+
+static struct dm_config_node *make_text_node(struct dm_config_tree *cft,
+					     const char *key,
+					     const char *value,
+					     struct dm_config_node *parent,
+					     struct dm_config_node *pre_sib)
+{
+	struct dm_config_node *cn = make_config_node(cft, key, parent, pre_sib);
+	cn->v = dm_config_create_value(cft);
+	cn->v->type = DM_CFG_STRING;
+	cn->v->v.str = value;
+	return cn;
+}
+
+static struct dm_config_node *make_pv_node(lvmetad_state *s, const char *pvid,
+					   struct dm_config_tree *cft,
+					   struct dm_config_node *parent,
+					   struct dm_config_node *pre_sib)
+{
+	const char *path = dm_hash_lookup(s->pvid_to_device, pvid),
+		*vgid = dm_hash_lookup(s->pvid_to_vgid, pvid),
+		*vgname = NULL;
+
+	if (vgid) {
+		lock_vgid_to_metadata(s); // XXX
+		vgname = dm_hash_lookup(s->vgid_to_vgname, vgid);
+		unlock_vgid_to_metadata(s);
+	}
+
+	struct dm_config_node *pv = make_config_node(cft, pvid, parent, pre_sib), *cn = NULL;
+
+	cn = make_text_node(cft, "id", pvid, pv, cn);
+	if (path)
+		cn = make_text_node(cft, "path", path, pv, cn);
+	if (vgid && strcmp(vgid, "#orphan"))
+		cn = make_text_node(cft, "vgid", vgid, pv, cn);
+	if (vgname)
+		cn = make_text_node(cft, "vgname", vgname, pv, cn);
+
+	return pv;
+}
+
+static response pv_list(lvmetad_state *s, request r)
+{
+	struct dm_config_node *cn = NULL, *cn_pvs, *cn_last = NULL;
+	response res = { .buffer = NULL };
+	res.cft = dm_config_create();
+
+	/* The response field */
+	res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL);
+	cn_pvs = make_config_node(res.cft, "physical_volumes", NULL, res.cft->root);
+
+	lock_pvid_to_status(s);
+
+	struct dm_hash_node *n = dm_hash_get_first(s->pvid_to_device);
+	while (n) {
+		const char *id = dm_hash_get_key(s->pvid_to_device, n);
+		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
+		n = dm_hash_get_next(s->pvid_to_device, n);
+	}
+
+	unlock_pvid_to_status(s);
+
+	debug_cft("PV LIST", res.cft->root);
+
+	return res;
+}
+
+static response pv_lookup(lvmetad_state *s, request r)
+{
+	const char *pvid = daemon_request_str(r, "uuid", NULL);
+	if (!pvid)
+		return daemon_reply_simple("failed", "reason = %s", "need PVID", NULL);
+
+	response res = { .buffer = NULL };
+	res.cft = dm_config_create();
+	res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL);
+
+	struct dm_config_node *pv;
+
+	lock_pvid_to_status(s);
+	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
+	pv->key = "physical_volume";
+	unlock_pvid_to_status(s);
+
+	// debug_cft("PV LOOKUP", res.cft->root);
+
+	return res;
+}
+
+static response vg_list(lvmetad_state *s, request r)
+{
+	struct dm_config_node *cn, *cn_vgs, *cn_last = NULL;
+	response res = { .buffer = NULL };
+	res.cft = dm_config_create();
+
+	/* The response field */
+	res.cft->root = cn = dm_config_create_node(res.cft, "response");
+	cn->parent = res.cft->root;
+	cn->v = dm_config_create_value(res.cft);
+	cn->v->type = DM_CFG_STRING;
+	cn->v->v.str = "OK";
+
+	cn_vgs = cn = cn->sib = dm_config_create_node(res.cft, "volume_groups");
+	cn->parent = res.cft->root;
+	cn->v = NULL;
+	cn->child = NULL;
+
+	lock_vgid_to_metadata(s);
+
+	struct dm_hash_node *n = dm_hash_get_first(s->vgid_to_vgname);
+	while (n) {
+		const char *id = dm_hash_get_key(s->vgid_to_vgname, n),
+			 *name = dm_hash_get_data(s->vgid_to_vgname, n);
+
+		cn = dm_config_create_node(res.cft, id);
+		if (cn_last)
+			cn_last->sib = cn;
+
+		cn->parent = cn_vgs;
+		cn->sib = NULL;
+		cn->v = NULL;
+
+		cn->child = dm_config_create_node(res.cft, "name");
+		cn->child->parent = cn;
+		cn->child->sib = 0;
+		cn->child->v = dm_config_create_value(res.cft);
+		cn->child->v->type = DM_CFG_STRING;
+		cn->child->v->v.str = name;
+
+		if (!cn_vgs->child)
+			cn_vgs->child = cn;
+		cn_last = cn;
+
+		n = dm_hash_get_next(s->vgid_to_vgname, n);
+	}
+
+	unlock_vgid_to_metadata(s);
+
+	return res;
+}
+
 static response vg_lookup(lvmetad_state *s, request r)
 {
 	struct dm_config_tree *cft;
@@ -181,15 +389,16 @@
 
 	const char *uuid = daemon_request_str(r, "uuid", NULL),
 		   *name = daemon_request_str(r, "name", NULL);
+
 	debug("vg_lookup: uuid = %s, name = %s\n", uuid, name);
 
 	if (!uuid || !name) {
-		lock_vgs(s);
+		lock_vgid_to_metadata(s);
 		if (name && !uuid)
-			uuid = dm_hash_lookup(s->vgname_map, (void *)name);
+			uuid = dm_hash_lookup(s->vgname_to_vgid, (void *)name);
 		if (uuid && !name)
-			name = dm_hash_lookup(s->vg_names, (void *)uuid);
-		unlock_vgs(s);
+			name = dm_hash_lookup(s->vgid_to_vgname, (void *)uuid);
+		unlock_vgid_to_metadata(s);
 	}
 
 	debug("vg_lookup: updated uuid = %s, name = %s\n", uuid, name);
@@ -223,7 +432,9 @@
 	res.error = 0;
 	unlock_vg(s, uuid);
 
-	update_pv_status(s, cft, n, 1); /* FIXME error reporting */
+	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
+
+	// debug_cft("METADATA", n);
 
 	return res;
 }
@@ -239,8 +450,8 @@
 
 	switch (a->type) {
 	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str); break;
-	case DM_CFG_FLOAT: r = (a->v.f == b->v.f); break;
-	case DM_CFG_INT: r = (a->v.i == b->v.i); break;
+	case DM_CFG_FLOAT: r = (a->v.f == b->v.f) ? 0 : (a->v.f > b->v.f) ? 1 : -1; break;
+	case DM_CFG_INT: r = (a->v.i == b->v.i) ? 0 : (a->v.i > b->v.i) ? 1 : -1; break;
 	case DM_CFG_EMPTY_ARRAY: return 0;
 	}
 
@@ -261,8 +472,10 @@
 	if (a->child && b->child)
 		result = compare_config(a->child, b->child);
 
-	if (result)
+	if (result) {
+		debug("config inequality at %s / %s\n", a->key, b->key);
 		return result;
+	}
 
 	if (a->sib && b->sib)
 		result = compare_config(a->sib, b->sib);
@@ -274,8 +487,8 @@
 	return result;
 }
 
-/* You need to be holding the pvid_map lock already to call this. */
-static int update_pvid_map(lvmetad_state *s, struct dm_config_tree *vg, const char *vgid)
+/* You need to be holding the pvid_to_vgid lock already to call this. */
+static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg, const char *vgid)
 {
 	struct dm_config_node *pv = pvs(vg->root);
 
@@ -284,7 +497,8 @@
 
 	while (pv) {
 		const char *pvid = dm_config_find_str(pv->child, "id", NULL);
-		dm_hash_insert(s->pvid_map, pvid, (void *) vgid);
+		dm_hash_insert(s->pvid_to_vgid, pvid, (void *) vgid);
+		debug("remap PV %s to VG %s\n", pvid, vgid);
 		pv = pv->sib;
 	}
 
@@ -296,23 +510,58 @@
 {
 	struct dm_config_tree *old;
 	const char *oldname;
-	lock_vgs(s);
-	old = dm_hash_lookup(s->vgs, vgid);
-	oldname = dm_hash_lookup(s->vg_names, vgid);
-	unlock_vgs(s);
+	lock_vgid_to_metadata(s);
+	old = dm_hash_lookup(s->vgid_to_metadata, vgid);
+	oldname = dm_hash_lookup(s->vgid_to_vgname, vgid);
+	unlock_vgid_to_metadata(s);
 
 	if (!old)
 		return 0;
 
-	update_pvid_map(s, old, "#orphan");
+	update_pvid_to_vgid(s, old, "#orphan");
 	/* need to update what we have since we found a newer version */
-	dm_hash_remove(s->vgs, vgid);
-	dm_hash_remove(s->vg_names, vgid);
-	dm_hash_remove(s->vgname_map, oldname);
+	dm_hash_remove(s->vgid_to_metadata, vgid);
+	dm_hash_remove(s->vgid_to_vgname, vgid);
+	dm_hash_remove(s->vgname_to_vgid, oldname);
 	dm_config_destroy(old);
 	return 1;
 }
 
+/* The VG must be locked. */
+static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
+{
+	if (!vgid)
+		return 0;
+
+	struct dm_config_tree *vg = dm_hash_lookup(s->vgid_to_metadata, vgid);
+	if (!vg)
+		return 1;
+
+	struct dm_config_node *pv = pvs(vg->root);
+
+	int missing = 1;
+
+	lock_pvid_to_status(s);
+
+	while (pv) {
+		const char *pvid = dm_config_find_str(pv->child, "id", NULL);
+		const char *vgid_check = dm_hash_lookup(s->pvid_to_vgid, pvid);
+		if (dm_hash_lookup(s->pvid_to_status, pvid) &&
+		    vgid_check && !strcmp(vgid, vgid_check))
+			missing = 0; /* at least one PV is around */
+		pv = pv->sib;
+	}
+
+	if (missing) {
+		debug("nuking VG %s\n", vgid);
+		remove_metadata(s, vgid);
+	}
+
+	unlock_pvid_to_status(s);
+
+	return 1;
+}
+
 /* No locks need to be held. The pointers are never used outside of the scope of
  * this function, so they can be safely destroyed after update_metadata returns
  * (anything that might have been retained is copied). */
@@ -327,34 +576,40 @@
 	const char *oldname = NULL;
 	const char *vgid;
 
-	lock_vgs(s);
-	old = dm_hash_lookup(s->vgs, _vgid);
+	lock_vgid_to_metadata(s);
+	old = dm_hash_lookup(s->vgid_to_metadata, _vgid);
 	lock_vg(s, _vgid);
-	unlock_vgs(s);
+	unlock_vgid_to_metadata(s);
 
 	seq = dm_config_find_int(metadata, "metadata/seqno", -1);
 
 	if (old) {
 		haveseq = dm_config_find_int(old->root, "metadata/seqno", -1);
-		oldname = dm_hash_lookup(s->vg_names, _vgid);
+		oldname = dm_hash_lookup(s->vgid_to_vgname, _vgid);
 		assert(oldname);
 	}
 
 	if (seq < 0)
 		goto out;
 
+	filter_metadata(metadata); /* sanitize */
+
 	if (seq == haveseq) {
 		retval = 1;
 		if (compare_config(metadata, old->root))
 			retval = 0;
-		debug("Not updating metadata for %s at %d (equal = %d)\n", _vgid, haveseq, retval);
+		debug("Not updating metadata for %s at %d (%s)\n", _vgid, haveseq,
+		      retval ? "ok" : "MISMATCH");
+		if (!retval) {
+			debug_cft("OLD: ", old->root);
+			debug_cft("NEW: ", metadata);
+		}
 		goto out;
 	}
 
 	if (seq < haveseq) {
 		debug("Refusing to update metadata for %s@%d to %d\n", _vgid, haveseq, seq);
-		// TODO: we may want to notify the client that their metadata is
-		// out of date?
+		/* TODO: notify the client that their metadata is out of date? */
 		retval = 1;
 		goto out;
 	}
@@ -369,7 +624,7 @@
 		goto out;
 	}
 
-	lock_pvid_map(s);
+	lock_pvid_to_vgid(s);
 
 	if (haveseq >= 0 && haveseq < seq) {
 		debug("Updating metadata for %s@%d to %d\n", _vgid, haveseq, seq);
@@ -377,16 +632,17 @@
 		remove_metadata(s, vgid);
 	}
 
-	lock_vgs(s);
-	dm_hash_insert(s->vgs, vgid, cft);
+	// debug_cft("METADATA", metadata);
+	lock_vgid_to_metadata(s);
+	dm_hash_insert(s->vgid_to_metadata, vgid, cft);
 	debug("Mapping %s to %s\n", vgid, name);
-	dm_hash_insert(s->vg_names, vgid, dm_pool_strdup(dm_config_memory(cft), name));
-	dm_hash_insert(s->vgname_map, name, (void *)vgid);
-	unlock_vgs(s);
+	dm_hash_insert(s->vgid_to_vgname, vgid, dm_pool_strdup(dm_config_memory(cft), name));
+	dm_hash_insert(s->vgname_to_vgid, name, (void *)vgid);
+	unlock_vgid_to_metadata(s);
 
-	update_pvid_map(s, cft, vgid);
+	update_pvid_to_vgid(s, cft, vgid);
 
-	unlock_pvid_map(s);
+	unlock_pvid_to_vgid(s);
 	retval = 1;
 out:
 	unlock_vg(s, _vgid);
@@ -396,13 +652,27 @@
 static response pv_gone(lvmetad_state *s, request r)
 {
 	int found = 0;
-	const char *pvid = daemon_request_str(r, "uuid", NULL);
-	debug("pv_gone: %s\n", pvid);
+	const char *pvid = daemon_request_str(r, "uuid", NULL),
+		    *dev = daemon_request_str(r, "device", NULL);
+
+	debug("pv_gone: %s / %s\n", pvid, dev);
+
+	lock_pvid_to_status(s);
+	if (!pvid && dev)
+		pvid = dm_hash_lookup(s->device_to_pvid, dev);
+	if (!pvid) {
+		unlock_pvid_to_status(s);
+		return daemon_reply_simple("failed", "reason = %s", "device not in cache", NULL);
+	}
 
-	lock_pvs(s);
-	found = dm_hash_lookup(s->pvs, pvid) ? 1 : 0;
-	dm_hash_remove(s->pvs, pvid);
-	unlock_pvs(s);
+	debug("pv_gone (updated): %s / %s\n", pvid, dev);
+
+	found = dm_hash_lookup(s->pvid_to_status, pvid) ? 1 : 0;
+	dm_hash_remove(s->pvid_to_status, pvid);
+	dm_hash_remove(s->pvid_to_device, pvid);
+
+	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid));
+	unlock_pvid_to_status(s);
 
 	if (found)
 		return daemon_reply_simple("OK", NULL);
@@ -415,21 +685,27 @@
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	const char *vgname = daemon_request_str(r, "vgname", NULL);
+	const char *devpath = dm_strdup(daemon_request_str(r, "device", NULL));
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
-	int complete = 0;
+	int complete = 0, orphan = 0;
 
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
+	if (!devpath)
+		return daemon_reply_simple("failed", "reason = %s", "need PV device", NULL);
 
-	debug("pv_found %s, vgid = %s\n", pvid, vgid);
+	debug("pv_found %s, vgid = %s, device = %s\n", pvid, vgid, devpath);
 
-	lock_pvs(s);
-	dm_hash_insert(s->pvs, pvid, (void*)1);
-	unlock_pvs(s);
+	lock_pvid_to_status(s);
+	dm_hash_insert(s->pvid_to_status, pvid, (void*)1);
+	dm_hash_insert(s->pvid_to_device, pvid, (void*)devpath);
+	dm_hash_insert(s->device_to_pvid, devpath, (void*)dm_strdup(pvid));
+	unlock_pvid_to_status(s);
 
 	if (metadata) {
 		if (!vgid)
 			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+		debug("obtained vgid = %s, vgname = %s", vgid, vgname);
 		if (!vgname)
 			return daemon_reply_simple("failed", "reason = %s", "need VG name", NULL);
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
@@ -439,23 +715,28 @@
 			return daemon_reply_simple("failed", "reason = %s",
 						   "metadata update failed", NULL);
 	} else {
-		lock_pvid_map(s);
-		vgid = dm_hash_lookup(s->pvid_map, pvid);
-		unlock_pvid_map(s);
+		lock_pvid_to_vgid(s);
+		vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
+		unlock_pvid_to_vgid(s);
 	}
 
 	if (vgid) {
 		struct dm_config_tree *cft = lock_vg(s, vgid);
-		if (!cft) {
+		if (cft) {
+			complete = update_pv_status(s, cft, cft->root, 0);
+		} else if (!strcmp(vgid, "#orphan")) {
+			orphan = 1;
+		} else {
 			unlock_vg(s, vgid);
-			return daemon_reply_simple("failed", "reason = %s", "vg unknown and no PV metadata", NULL);
+			return daemon_reply_simple("failed", "reason = %s",
+						   "internal treason!", NULL);
 		}
-		complete = update_pv_status(s, cft, cft->root, 0);
 		unlock_vg(s, vgid);
 	}
 
 	return daemon_reply_simple("OK",
-				   "status = %s", complete ? "complete" : "partial",
+				   "status = %s", orphan ? "orphan" :
+				                     (complete ? "complete" : "partial"),
 				   "vgid = %s", vgid ? vgid : "#orphan",
 				   NULL);
 }
@@ -473,6 +754,8 @@
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
 			return daemon_reply_simple("failed", "reason = %s", "need VG seqno", NULL);
 
+		/* TODO defer metadata update here; add a separate vg_commit
+		 * call; if client does not commit, die */
 		if (!update_metadata(s, vgname, vgid, metadata))
 			return daemon_reply_simple("failed", "reason = %s",
 						   "metadata update failed", NULL);
@@ -489,9 +772,9 @@
 
 	fprintf(stderr, "vg_remove: %s\n", vgid);
 
-	lock_pvid_map(s);
+	lock_pvid_to_vgid(s);
 	remove_metadata(s, vgid);
-	unlock_pvid_map(s);
+	unlock_pvid_to_vgid(s);
 
 	return daemon_reply_simple("OK", NULL);
 }
@@ -501,13 +784,18 @@
 	lvmetad_state *state = s.private;
 	const char *rq = daemon_request_str(r, "request", "NONE");
 
-	debug("REQUEST: %s\n", rq);
-
+	/*
+	 * TODO Add a stats call, with transaction count/rate, time since last
+	 * update &c.
+	 */
 	if (!strcmp(rq, "pv_found"))
 		return pv_found(state, r);
 
 	if (!strcmp(rq, "pv_gone"))
-		pv_gone(state, r);
+		return pv_gone(state, r);
+
+	if (!strcmp(rq, "pv_lookup"))
+		return pv_lookup(state, r);
 
 	if (!strcmp(rq, "vg_update"))
 		return vg_update(state, r);
@@ -518,6 +806,13 @@
 	if (!strcmp(rq, "vg_lookup"))
 		return vg_lookup(state, r);
 
+	if (!strcmp(rq, "pv_list")) {
+		return pv_list(state, r);
+	}
+
+	if (!strcmp(rq, "vg_list"))
+		return vg_list(state, r);
+
 	return daemon_reply_simple("failed", "reason = %s", "no such request", NULL);
 }
 
@@ -526,20 +821,22 @@
 	pthread_mutexattr_t rec;
 	lvmetad_state *ls = s->private;
 
-	ls->pvs = dm_hash_create(32);
-	ls->vgs = dm_hash_create(32);
-	ls->vg_names = dm_hash_create(32);
-	ls->pvid_map = dm_hash_create(32);
-	ls->vgname_map = dm_hash_create(32);
+	ls->pvid_to_status = dm_hash_create(32);
+	ls->pvid_to_device = dm_hash_create(32);
+	ls->device_to_pvid = dm_hash_create(32);
+	ls->vgid_to_metadata = dm_hash_create(32);
+	ls->vgid_to_vgname = dm_hash_create(32);
+	ls->pvid_to_vgid = dm_hash_create(32);
+	ls->vgname_to_vgid = dm_hash_create(32);
 	ls->lock.vg = dm_hash_create(32);
 	pthread_mutexattr_init(&rec);
 	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
-	pthread_mutex_init(&ls->lock.pvs, NULL);
-	pthread_mutex_init(&ls->lock.vgs, &rec);
-	pthread_mutex_init(&ls->lock.pvid_map, NULL);
+	pthread_mutex_init(&ls->lock.pvid_to_status, &rec);
+	pthread_mutex_init(&ls->lock.vgid_to_metadata, &rec);
+	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
 
-	debug("initialised state: vgs = %p\n", ls->vgs);
-	if (!ls->pvs || !ls->vgs)
+	debug("initialised state: vgid_to_metadata = %p\n", ls->vgid_to_metadata);
+	if (!ls->pvid_to_vgid || !ls->vgid_to_metadata)
 		return 0;
 
 	/* if (ls->initial_registrations)
@@ -551,12 +848,12 @@
 static int fini(daemon_state *s)
 {
 	lvmetad_state *ls = s->private;
-	struct dm_hash_node *n = dm_hash_get_first(ls->vgs);
+	struct dm_hash_node *n = dm_hash_get_first(ls->vgid_to_metadata);
 
 	debug("fini\n");
 	while (n) {
-		dm_config_destroy(dm_hash_get_data(ls->vgs, n));
-		n = dm_hash_get_next(ls->vgs, n);
+		dm_config_destroy(dm_hash_get_data(ls->vgid_to_metadata, n));
+		n = dm_hash_get_next(ls->vgid_to_metadata, n);
 	}
 
 	n = dm_hash_get_first(ls->lock.vg);
@@ -567,9 +864,11 @@
 	}
 
 	dm_hash_destroy(ls->lock.vg);
-	dm_hash_destroy(ls->pvs);
-	dm_hash_destroy(ls->vgs);
-	dm_hash_destroy(ls->pvid_map);
+	dm_hash_destroy(ls->pvid_to_status);
+	dm_hash_destroy(ls->pvid_to_device);
+	dm_hash_destroy(ls->device_to_pvid);
+	dm_hash_destroy(ls->vgid_to_metadata);
+	dm_hash_destroy(ls->pvid_to_vgid);
 	return 1;
 }
 
@@ -596,10 +895,13 @@
 	s.daemon_init = init;
 	s.daemon_fini = fini;
 	s.handler = handler;
-	s.socket_path = "/var/run/lvm/lvmetad.socket";
-	s.pidfile = "/var/run/lvm/lvmetad.pid";
+	s.socket_path = getenv("LVM_LVMETAD_SOCKET");
+	if (!s.socket_path)
+		s.socket_path = DEFAULT_RUN_DIR "/lvmetad.socket";
+	s.pidfile = DEFAULT_RUN_DIR "/lvmetad.pid";
         s.log_level = 0;
 
+	// use getopt_long
 	while ((opt = getopt(argc, argv, "?fhVdRs:")) != EOF) {
 		switch (opt) {
 		case 'h':
@@ -617,7 +919,7 @@
 		case 'd':
 			s.log_level++;
 			break;
-		case 's':
+		case 's': // --socket
 			s.socket_path = optarg;
 			break;
 		case 'V':


