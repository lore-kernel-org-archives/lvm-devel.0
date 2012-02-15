From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 17:30:09 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120215173009.31385.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 17:30:07

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Update lvmetad: use device major/minor pair to track devices. Keep a pvmeta
	config tree per PV which is mostly provided by the client, so it can be used to
	keep track of things like label_sector, PV format, mda count / offsets and so
	on.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 14:15:50	1.35
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 17:30:07	1.36
@@ -12,14 +12,10 @@
 #include "daemon-server.h"
 
 typedef struct {
-	const char *path;
-	dev_t number;
-} device; /* TODO */
-
-typedef struct {
 	struct dm_hash_table *pvid_to_status;
-	struct dm_hash_table *pvid_to_device; /* shares locks with status */
+	struct dm_hash_table *pvid_to_pvmeta; /* shares locks with status */
 	struct dm_hash_table *device_to_pvid; /* shares locks with status */
+
 	struct dm_hash_table *vgid_to_metadata;
 	struct dm_hash_table *vgid_to_vgname;
 	struct dm_hash_table *vgname_to_vgid;
@@ -164,6 +160,56 @@
 	return 1;
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
+	if (parent && parent->child && !pre_sib) { /* find the last one */
+		pre_sib = parent->child;
+		while (pre_sib && pre_sib->sib) pre_sib = pre_sib->sib;
+	}
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
+static struct dm_config_node *make_int_node(struct dm_config_tree *cft,
+					    const char *key,
+					    int64_t value,
+					    struct dm_config_node *parent,
+					    struct dm_config_node *pre_sib)
+{
+	struct dm_config_node *cn = make_config_node(cft, key, parent, pre_sib);
+	cn->v = dm_config_create_value(cft);
+	cn->v->type = DM_CFG_INT;
+	cn->v->v.i = value;
+	return cn;
+}
+
 static void filter_metadata(struct dm_config_node *vg) {
 	struct dm_config_node *pv = pvs(vg);
 	while (pv) {
@@ -195,16 +241,12 @@
 		int found = uuid ? (dm_hash_lookup(s->pvid_to_status, uuid) ? 1 : 0) : 0;
 		if (act) {
 			set_flag(cft, pv, "status", "MISSING", !found);
-			const char *devpath = dm_hash_lookup(s->pvid_to_device, uuid);
-			// debug("setting device of %s to %s\n", uuid, devpath);
-			if (devpath) {
-				struct dm_config_node *dev = dm_config_create_node(cft, "device");
-				dev->sib = pv->child;
-				dev->v = dm_config_create_value(cft);
-				dev->v->type = DM_CFG_STRING;
-				dev->v->v.str = dm_hash_lookup(s->pvid_to_device, uuid);
-				dev->parent = pv;
-				pv->child = dev;
+			struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
+			if (pvmeta) {
+				// debug_cft("PV META", pvmeta->root);
+				make_int_node(cft, "device",
+					      dm_config_find_int(pvmeta->root, "pvmeta/device", 0),
+					      pv, NULL);
 			}
 		}
 		if (!found) {
@@ -221,46 +263,16 @@
 	return complete;
 }
 
-static struct dm_config_node *make_config_node(struct dm_config_tree *cft,
-					       const char *key,
-					       struct dm_config_node *parent,
-					       struct dm_config_node *pre_sib)
-{
-	struct dm_config_node *cn = dm_config_create_node(cft, key);
-	cn->parent = parent;
-	cn->sib = NULL;
-	cn->v = NULL;
-	cn->child = NULL;
-
-	if (parent && !parent->child)
-		parent->child = cn;
-	if (pre_sib)
-		pre_sib->sib = cn;
-
-	return cn;
-}
-
-static struct dm_config_node *make_text_node(struct dm_config_tree *cft,
-					     const char *key,
-					     const char *value,
-					     struct dm_config_node *parent,
-					     struct dm_config_node *pre_sib)
-{
-	struct dm_config_node *cn = make_config_node(cft, key, parent, pre_sib);
-	cn->v = dm_config_create_value(cft);
-	cn->v->type = DM_CFG_STRING;
-	cn->v->v.str = value;
-	return cn;
-}
-
 static struct dm_config_node *make_pv_node(lvmetad_state *s, const char *pvid,
 					   struct dm_config_tree *cft,
 					   struct dm_config_node *parent,
 					   struct dm_config_node *pre_sib)
 {
-	const char *path = dm_hash_lookup(s->pvid_to_device, pvid),
-		*vgid = dm_hash_lookup(s->pvid_to_vgid, pvid),
-		*vgname = NULL;
+	struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
+	const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid), *vgname = NULL;
+
+	if (!pvmeta)
+		return NULL;
 
 	if (vgid) {
 		lock_vgid_to_metadata(s); // XXX
@@ -268,11 +280,17 @@
 		unlock_vgid_to_metadata(s);
 	}
 
-	struct dm_config_node *pv = make_config_node(cft, pvid, parent, pre_sib), *cn = NULL;
+	/* Nick the pvmeta config tree. */
+	struct dm_config_node *pv = dm_config_clone_node(cft, pvmeta->root, 0);
+	if (pre_sib)
+		pre_sib->sib = pv;
+	if (parent && !parent->child)
+		parent->child = pv;
+	pv->parent = parent;
+
+	/* Add the "variable" bits to it. */
+	struct dm_config_node *cn = NULL;
 
-	cn = make_text_node(cft, "id", pvid, pv, cn);
-	if (path)
-		cn = make_text_node(cft, "path", path, pv, cn);
 	if (vgid && strcmp(vgid, "#orphan"))
 		cn = make_text_node(cft, "vgid", vgid, pv, cn);
 	if (vgname)
@@ -293,16 +311,16 @@
 
 	lock_pvid_to_status(s);
 
-	struct dm_hash_node *n = dm_hash_get_first(s->pvid_to_device);
+	struct dm_hash_node *n = dm_hash_get_first(s->pvid_to_pvmeta);
 	while (n) {
-		const char *id = dm_hash_get_key(s->pvid_to_device, n);
+		const char *id = dm_hash_get_key(s->pvid_to_pvmeta, n);
 		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
-		n = dm_hash_get_next(s->pvid_to_device, n);
+		n = dm_hash_get_next(s->pvid_to_pvmeta, n);
 	}
 
 	unlock_pvid_to_status(s);
 
-	debug_cft("PV LIST", res.cft->root);
+	// debug_cft("PV LIST", res.cft->root);
 
 	return res;
 }
@@ -321,6 +339,11 @@
 
 	lock_pvid_to_status(s);
 	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
+	if (!pv) {
+		unlock_pvid_to_status(s);
+		return daemon_reply_simple("failed", "reason = %s", "PV not found", NULL);
+	}
+
 	pv->key = "physical_volume";
 	unlock_pvid_to_status(s);
 
@@ -672,54 +695,70 @@
 static response pv_gone(lvmetad_state *s, request r)
 {
 	int found = 0;
-	const char *pvid = daemon_request_str(r, "uuid", NULL),
-		    *dev = daemon_request_str(r, "device", NULL);
+	const char *pvid = daemon_request_str(r, "uuid", NULL);
+	int64_t device = daemon_request_int(r, "device", 0);
 
-	debug("pv_gone: %s / %s\n", pvid, dev);
+	debug("pv_gone: %s / %lld\n", pvid, device);
+	debug_cft("PV_GONE", r.cft->root);
 
 	lock_pvid_to_status(s);
-	if (!pvid && dev)
-		pvid = dm_hash_lookup(s->device_to_pvid, dev);
+	if (!pvid && device > 0)
+		pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	if (!pvid) {
 		unlock_pvid_to_status(s);
 		return daemon_reply_simple("failed", "reason = %s", "device not in cache", NULL);
 	}
 
-	debug("pv_gone (updated): %s / %s\n", pvid, dev);
+	debug("pv_gone (updated): %s / %lld\n", pvid, device);
 
-	found = dm_hash_lookup(s->pvid_to_status, pvid) ? 1 : 0;
+	struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
+	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
 	dm_hash_remove(s->pvid_to_status, pvid);
-	dm_hash_remove(s->pvid_to_device, pvid);
-
+	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid));
 	unlock_pvid_to_status(s);
 
-	if (found)
+	if (pvmeta) {
+		dm_config_destroy(pvmeta);
 		return daemon_reply_simple("OK", NULL);
-	else
+	} else
 		return daemon_reply_simple("failed", "reason = %s", "PVID does not exist", NULL);
 }
 
 static response pv_found(lvmetad_state *s, request r)
 {
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
-	const char *pvid = daemon_request_str(r, "uuid", NULL);
+	const char *pvid = daemon_request_str(r, "pvmeta/id", NULL);
 	const char *vgname = daemon_request_str(r, "vgname", NULL);
-	const char *devpath = dm_strdup(daemon_request_str(r, "device", NULL));
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
+	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
+	uint64_t device;
+
 	int complete = 0, orphan = 0;
 
+	// debug_cft("INCOMING PV", r.cft->root);
+
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
-	if (!devpath)
-		return daemon_reply_simple("failed", "reason = %s", "need PV device", NULL);
+	if (!pvmeta)
+		return daemon_reply_simple("failed", "reason = %s", "need PV metadata", NULL);
+
+	if (!dm_config_get_uint64(pvmeta, "pvmeta/device", &device))
+		return daemon_reply_simple("failed", "reason = %s", "need PV device number", NULL);
 
-	debug("pv_found %s, vgid = %s, device = %s\n", pvid, vgid, devpath);
+	debug("pv_found %s, vgid = %s, device = %lld\n", pvid, vgid, device);
 
 	lock_pvid_to_status(s);
 	dm_hash_insert(s->pvid_to_status, pvid, (void*)1);
-	dm_hash_insert(s->pvid_to_device, pvid, (void*)devpath);
-	dm_hash_insert(s->device_to_pvid, devpath, (void*)dm_strdup(pvid));
+
+	{
+		struct dm_config_tree *cft = dm_config_create();
+		cft->root = dm_config_clone_node(cft, pvmeta, 0);
+		const char *pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
+		dm_hash_insert(s->pvid_to_pvmeta, pvid, cft);
+		dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup);
+	}
+
 	unlock_pvid_to_status(s);
 
 	if (metadata) {
@@ -842,7 +881,7 @@
 	lvmetad_state *ls = s->private;
 
 	ls->pvid_to_status = dm_hash_create(32);
-	ls->pvid_to_device = dm_hash_create(32);
+	ls->pvid_to_pvmeta = dm_hash_create(32);
 	ls->device_to_pvid = dm_hash_create(32);
 	ls->vgid_to_metadata = dm_hash_create(32);
 	ls->vgid_to_vgname = dm_hash_create(32);
@@ -885,7 +924,7 @@
 
 	dm_hash_destroy(ls->lock.vg);
 	dm_hash_destroy(ls->pvid_to_status);
-	dm_hash_destroy(ls->pvid_to_device);
+	dm_hash_destroy(ls->pvid_to_pvmeta);
 	dm_hash_destroy(ls->device_to_pvid);
 	dm_hash_destroy(ls->vgid_to_metadata);
 	dm_hash_destroy(ls->pvid_to_vgid);


