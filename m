From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Jan 2012 08:25:35 -0000
Subject: LVM2/daemons/lvmetad lvmetad-client.h lvmetad- ...
Message-ID: <20120116082535.31359.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-01-16 08:25:33

Modified files:
	daemons/lvmetad: lvmetad-client.h lvmetad-core.c 

Log message:
	Beef up the lvmetad code with more functionality and a bunch of bugfixes. There
	used to be a few mis-ordered memory accesses (release and access in the next
	block). Fix that set_flag could have sometimes corrupted the flags being
	modified.
	
	A few issues with metadata tracking are sorted out as well now, and there are
	only a few problems remaining before we can integrate lvmetad, mostly on the
	client side:
	
	- metadata areas need to be tracked in lvmetad (most likely to be addressed
	through an extension of metadata, meaning no special support in lvmetad would
	be needed)
	- non-udev scanning code needs to be taught about telling lvmetad about device
	disappearance (pvscan most importantly)
	- this last item also needs to mesh with metadata inconsistencies and
	suddenly-incomplete volume groups (aux disable_dev in tests); udev-based
	scanning should address this separately and more elegantly

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/daemons/lvmetad/lvmetad-client.h	2011/08/30 15:44:01	1.4
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2012/01/16 08:25:32	1.5
@@ -62,12 +62,12 @@
 
 /* Implementation of inline functions */
 
-static inline daemon_handle lvmetad_open()
+static inline daemon_handle lvmetad_open(const char *socket)
 {
 	/* TODO configurable */
 	daemon_info lvmetad_info = {
 		.path = "lvmetad",
-		.socket = "/var/run/lvm/lvmetad.socket",
+		.socket = socket ?: "/var/run/lvm/lvmetad.socket",
 		.autostart = 1
 	};
 
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/12/18 22:31:10	1.28
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/01/16 08:25:32	1.29
@@ -13,6 +13,8 @@
 typedef struct {
 	struct dm_hash_table *pvs;
 	struct dm_hash_table *vgs;
+	struct dm_hash_table *vg_names;
+	struct dm_hash_table *vgname_map;
 	struct dm_hash_table *pvid_map;
 	struct {
 		struct dm_hash_table *vg;
@@ -59,6 +61,7 @@
 		pthread_mutex_init(vg, &rec);
 		dm_hash_insert(s->lock.vg, id, vg);
 	}
+	debug("lock VG %s\n", id);
 	pthread_mutex_lock(vg);
 	cft = dm_hash_lookup(s->vgs, id);
 	unlock_vgs(s);
@@ -66,6 +69,7 @@
 }
 
 static void unlock_vg(lvmetad_state *s, const char *id) {
+	debug("unlock VG %s\n", id);
 	lock_vgs(s); /* someone might be changing the s->lock.vg structure right
 		      * now, so avoid stepping on each other's toes */
 	pthread_mutex_unlock(dm_hash_lookup(s->lock.vg, id));
@@ -105,10 +109,13 @@
 		return;
 
 	if (value && !want) {
-		if (pred)
+		if (pred) {
 			pred->next = value->next;
-		if (value == node->v)
+		} else if (value == node->v && value->next) {
 			node->v = value->next;
+		} else {
+			node->v->type = DM_CFG_EMPTY_ARRAY;
+		}
 	}
 
 	if (!value && want) {
@@ -158,30 +165,48 @@
 	return complete;
 }
 
-static response vg_by_uuid(lvmetad_state *s, request r)
+static response vg_lookup(lvmetad_state *s, request r)
 {
-	struct dm_config_tree *cft;
-	struct dm_config_node *metadata;
-	struct dm_config_node *n;
-	response res = { .buffer = NULL };
-	const char *uuid = daemon_request_str(r, "uuid", "NONE");
+	const char *uuid = daemon_request_str(r, "uuid", NULL),
+		   *name = daemon_request_str(r, "name", NULL);
+	debug("vg_lookup: uuid = %s, name = %s\n", uuid, name);
 
-	debug("vg_by_uuid: %s (vgs = %p)\n", uuid, s->vgs);
-	cft = lock_vg(s, uuid);
+	if (!uuid || !name) {
+		lock_vgs(s);
+		if (name && !uuid)
+			uuid = dm_hash_lookup(s->vgname_map, (void *)name);
+		if (uuid && !name)
+			name = dm_hash_lookup(s->vg_names, (void *)uuid);
+		unlock_vgs(s);
+	}
+
+	debug("vg_lookup: updated uuid = %s, name = %s\n", uuid, name);
+
+	if (!uuid)
+		return daemon_reply_simple("failed", "reason = %s", "VG not found", NULL);
+
+	struct dm_config_tree *cft = lock_vg(s, uuid);
 	if (!cft || !cft->root) {
 		unlock_vg(s, uuid);
-		return daemon_reply_simple("failed", "reason = %s", "uuid not found", NULL);
+		return daemon_reply_simple("failed", "reason = %s", "UUID not found", NULL);
 	}
 
-	metadata = cft->root;
+	struct dm_config_node *metadata = cft->root, *n;
+	response res = { .buffer = NULL };
 
 	res.cft = dm_config_create();
 
 	/* The response field */
 	res.cft->root = n = dm_config_create_node(res.cft, "response");
+	n->parent = res.cft->root;
 	n->v->type = DM_CFG_STRING;
 	n->v->v.str = "OK";
 
+	n = n->sib = dm_config_create_node(res.cft, "name");
+	n->parent = res.cft->root;
+	n->v->type = DM_CFG_STRING;
+	n->v->v.str = name;
+
 	/* The metadata section */
 	n = n->sib = dm_config_clone_node(res.cft, metadata, 1);
 	n->parent = res.cft->root;
@@ -256,27 +281,50 @@
 	return 1;
 }
 
+/* A pvid map lock needs to be held. */
+static int remove_metadata(lvmetad_state *s, const char *vgid)
+{
+	lock_vgs(s);
+	struct dm_config_tree *old = dm_hash_lookup(s->vgs, vgid);
+	const char *oldname = dm_hash_lookup(s->vg_names, vgid);
+	unlock_vgs(s);
+
+	if (!old)
+		return 0;
+
+	update_pvid_map(s, old, "#orphan");
+	/* need to update what we have since we found a newer version */
+	dm_hash_remove(s->vgs, vgid);
+	dm_hash_remove(s->vg_names, vgid);
+	dm_hash_remove(s->vgname_map, oldname);
+	dm_config_destroy(old);
+	return 1;
+}
+
 /* No locks need to be held. The pointers are never used outside of the scope of
  * this function, so they can be safely destroyed after update_metadata returns
  * (anything that might have been retained is copied). */
-static int update_metadata(lvmetad_state *s, const char *_vgid, struct dm_config_node *metadata)
+static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid,
+			   struct dm_config_node *metadata)
 {
 	struct dm_config_tree *cft;
 	struct dm_config_tree *old;
-	const char *vgid;
 	int retval = 0;
-	int haveseq = -1;
-	int seq;
 
 	lock_vgs(s);
 	old = dm_hash_lookup(s->vgs, _vgid);
 	lock_vg(s, _vgid);
 	unlock_vgs(s);
 
-	seq = dm_config_find_int(metadata, "metadata/seqno", -1);
+	int seq = dm_config_find_int(metadata, "metadata/seqno", -1);
+	int haveseq = -1;
+	const char *oldname = NULL;
 
-	if (old)
+	if (old) {
 		haveseq = dm_config_find_int(old->root, "metadata/seqno", -1);
+		oldname = dm_hash_lookup(s->vg_names, _vgid);
+		assert(oldname);
+	}
 
 	if (seq < 0)
 		goto out;
@@ -285,10 +333,12 @@
 		retval = 1;
 		if (compare_config(metadata, old->root))
 			retval = 0;
+		debug("Not updating metadata for %s at %d (equal = %d)\n", _vgid, haveseq, retval);
 		goto out;
 	}
 
 	if (seq < haveseq) {
+		debug("Refusing to update metadata for %s@%d to %d\n", _vgid, haveseq, seq);
 		// TODO: we may want to notify the client that their metadata is
 		// out of date?
 		retval = 1;
@@ -297,23 +347,27 @@
 
 	cft = dm_config_create();
 	cft->root = dm_config_clone_node(cft, metadata, 0);
-	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 
-	if (!vgid)
+	const char *vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
+
+	if (!vgid || !name) {
+		debug("Name '%s' or uuid '%s' missing!\n", name, vgid);
 		goto out;
+	}
 
 	lock_pvid_map(s);
 
 	if (haveseq >= 0 && haveseq < seq) {
+		debug("Updating metadata for %s@%d to %d\n", _vgid, haveseq, seq);
 		/* temporarily orphan all of our PVs */
-		update_pvid_map(s, old, "#orphan");
-		/* need to update what we have since we found a newer version */
-		dm_config_destroy(old);
-		dm_hash_remove(s->vgs, vgid);
+		remove_metadata(s, vgid);
 	}
 
 	lock_vgs(s);
 	dm_hash_insert(s->vgs, vgid, cft);
+	debug("Mapping %s to %s\n", vgid, name);
+	dm_hash_insert(s->vg_names, vgid, dm_pool_strdup(dm_config_memory(cft), name));
+	dm_hash_insert(s->vgname_map, name, (void *)vgid);
 	unlock_vgs(s);
 
 	update_pvid_map(s, cft, vgid);
@@ -325,17 +379,35 @@
 	return retval;
 }
 
-static response pv_add(lvmetad_state *s, request r)
+static response pv_gone(lvmetad_state *s, request r)
+{
+	int found = 0;
+	const char *pvid = daemon_request_str(r, "uuid", NULL);
+	debug("pv_gone: %s\n", pvid);
+
+	lock_pvs(s);
+	found = dm_hash_lookup(s->pvs, pvid) ? 1 : 0;
+	dm_hash_remove(s->pvs, pvid);
+	unlock_pvs(s);
+
+	if (found)
+		return daemon_reply_simple("OK", NULL);
+	else
+		return daemon_reply_simple("failed", "reason = %s", "PVID does not exist", NULL);
+}
+
+static response pv_found(lvmetad_state *s, request r)
 {
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
+	const char *vgname = daemon_request_str(r, "vgname", NULL);
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 	int complete = 0;
 
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
 
-	debug("pv_add %s, vgid = %s\n", pvid, vgid);
+	debug("pv_found %s, vgid = %s\n", pvid, vgid);
 
 	lock_pvs(s);
 	dm_hash_insert(s->pvs, pvid, (void*)1);
@@ -344,10 +416,12 @@
 	if (metadata) {
 		if (!vgid)
 			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+		if (!vgname)
+			return daemon_reply_simple("failed", "reason = %s", "need VG name", NULL);
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
 			return daemon_reply_simple("failed", "reason = %s", "need VG seqno", NULL);
 
-		if (!update_metadata(s, vgid, metadata))
+		if (!update_metadata(s, vgname, vgid, metadata))
 			return daemon_reply_simple("failed", "reason = %s",
 						   "metadata update failed", NULL);
 	} else {
@@ -358,6 +432,10 @@
 
 	if (vgid) {
 		struct dm_config_tree *cft = lock_vg(s, vgid);
+		if (!cft) {
+			unlock_vg(s, vgid);
+			return daemon_reply_simple("failed", "reason = %s", "vg unknown and no PV metadata", NULL);
+		}
 		complete = update_pv_status(s, cft, cft->root, 0);
 		unlock_vg(s, vgid);
 	}
@@ -368,8 +446,40 @@
 				   NULL);
 }
 
-static void pv_del(lvmetad_state *s, request r)
+static response vg_update(lvmetad_state *s, request r)
 {
+	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
+	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
+	const char *vgname = daemon_request_str(r, "vgname", NULL);
+	if (metadata) {
+		if (!vgid)
+			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+		if (!vgname)
+			return daemon_reply_simple("failed", "reason = %s", "need VG name", NULL);
+		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
+			return daemon_reply_simple("failed", "reason = %s", "need VG seqno", NULL);
+
+		if (!update_metadata(s, vgname, vgid, metadata))
+			return daemon_reply_simple("failed", "reason = %s",
+						   "metadata update failed", NULL);
+	}
+	return daemon_reply_simple("OK", NULL);
+}
+
+static response vg_remove(lvmetad_state *s, request r)
+{
+	const char *vgid = daemon_request_str(r, "uuid", NULL);
+
+	if (!vgid)
+		return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+
+	fprintf(stderr, "vg_remove: %s\n", vgid);
+
+	lock_pvid_map(s);
+	remove_metadata(s, vgid);
+	unlock_pvid_map(s);
+
+	return daemon_reply_simple("OK", NULL);
 }
 
 static response handler(daemon_state s, client_handle h, request r)
@@ -379,14 +489,22 @@
 
 	debug("REQUEST: %s\n", rq);
 
-	if (!strcmp(rq, "pv_add"))
-		return pv_add(state, r);
-	else if (!strcmp(rq, "pv_del"))
-		pv_del(state, r);
-	else if (!strcmp(rq, "vg_by_uuid"))
-		return vg_by_uuid(state, r);
+	if (!strcmp(rq, "pv_found"))
+		return pv_found(state, r);
 
-	return daemon_reply_simple("OK", NULL);
+	if (!strcmp(rq, "pv_gone"))
+		pv_gone(state, r);
+
+	if (!strcmp(rq, "vg_update"))
+		return vg_update(state, r);
+
+	if (!strcmp(rq, "vg_remove"))
+		return vg_remove(state, r);
+
+	if (!strcmp(rq, "vg_lookup"))
+		return vg_lookup(state, r);
+
+	return daemon_reply_simple("failed", "reason = %s", "no such request", NULL);
 }
 
 static int init(daemon_state *s)
@@ -396,7 +514,9 @@
 
 	ls->pvs = dm_hash_create(32);
 	ls->vgs = dm_hash_create(32);
+	ls->vg_names = dm_hash_create(32);
 	ls->pvid_map = dm_hash_create(32);
+	ls->vgname_map = dm_hash_create(32);
 	ls->lock.vg = dm_hash_create(32);
 	pthread_mutexattr_init(&rec);
 	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
@@ -466,7 +586,7 @@
 	s.pidfile = "/var/run/lvm/lvmetad.pid";
         s.log_level = 0;
 
-	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVdRs:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -483,6 +603,9 @@
 		case 'd':
 			s.log_level++;
 			break;
+		case 's':
+			s.socket_path = optarg;
+			break;
 		case 'V':
 			printf("lvmetad version 0\n");
 			exit(1);


