From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Aug 2011 15:44:02 -0000
Subject: LVM2/daemons/lvmetad lvmetad-client.h lvmetad- ...
Message-ID: <20110830154402.30936.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-30 15:44:02

Modified files:
	daemons/lvmetad: lvmetad-client.h lvmetad-core.c 

Log message:
	Adapt LVMetaD to use the new dm_config interfaces.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/daemons/lvmetad/lvmetad-client.h	2011/06/14 02:36:38	1.3
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2011/08/30 15:44:01	1.4
@@ -27,7 +27,7 @@
 
 typedef struct {
 	daemon_reply r;
-	struct config_tree *cft;
+	struct dm_config_tree *cft;
 } lvmetad_vg;
 
 static inline daemon_handle lvmetad_open();
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/25 17:59:50	1.22
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/08/30 15:44:01	1.23
@@ -41,7 +41,7 @@
  * since if we have many "rogue" requests for nonexistent things, we will keep
  * allocating memory that we never release. Not good.
  */
-struct config_tree *lock_vg(lvmetad_state *s, const char *id) {
+struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	lock_vgs(s);
 	pthread_mutex_t *vg = dm_hash_lookup(s->lock.vg, id);
 	if (!vg) {
@@ -53,7 +53,7 @@
 		dm_hash_insert(s->lock.vg, id, vg);
 	}
 	pthread_mutex_lock(vg);
-	struct config_tree *cft = dm_hash_lookup(s->vgs, id);
+	struct dm_config_tree *cft = dm_hash_lookup(s->vgs, id);
 	unlock_vgs(s);
 	return cft;
 }
@@ -65,9 +65,9 @@
 	unlock_vgs(s);
 }
 
-static struct config_node *pvs(struct config_node *vg)
+static struct dm_config_node *pvs(struct dm_config_node *vg)
 {
-	struct config_node *pv = find_config_node(vg, "metadata/physical_volumes");
+	struct dm_config_node *pv = dm_config_find_node(vg, "metadata/physical_volumes");
 	if (pv)
 		pv = pv->child;
 	return pv;
@@ -77,16 +77,16 @@
  * TODO: This set_flag function is pretty generic and might make sense in a
  * library here or there.
  */
-static void set_flag(struct config_tree *cft, struct config_node *parent,
+static void set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
 		     char *field, const char *flag, int want) {
-	struct config_value *value = NULL, *pred = NULL;
-	struct config_node *node = find_config_node(parent->child, field);
+	struct dm_config_value *value = NULL, *pred = NULL;
+	struct dm_config_node *node = dm_config_find_node(parent->child, field);
 	int found = 0;
 
 	if (node)
 		value = node->v;
 
-	while (value && value->type != CFG_EMPTY_ARRAY && strcmp(value->v.str, flag)) {
+	while (value && value->type != DM_CFG_EMPTY_ARRAY && strcmp(value->v.str, flag)) {
 		pred = value;
 		value = value->next;
 	}
@@ -106,15 +106,15 @@
 
 	if (!value && want) {
 		if (!node) {
-			node = create_config_node(cft, field);
+			node = dm_config_create_node(cft, field);
 			node->sib = parent->child;
-			node->v = create_config_value(cft);
-			node->v->type = CFG_EMPTY_ARRAY;
+			node->v = dm_config_create_value(cft);
+			node->v->type = DM_CFG_EMPTY_ARRAY;
 			node->parent = parent;
 			parent->child = node;
 		}
-		struct config_value *new = create_config_value(cft);
-		new->type = CFG_STRING;
+		struct dm_config_value *new = dm_config_create_value(cft);
+		new->type = DM_CFG_STRING;
 		new->v.str = flag;
 		new->next = node->v;
 		node->v = new;
@@ -123,14 +123,16 @@
 
 /* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
  * this function. */
-static int update_pv_status(lvmetad_state *s, struct config_tree *cft, struct config_node *vg, int act)
+static int update_pv_status(lvmetad_state *s,
+			    struct dm_config_tree *cft,
+			    struct dm_config_node *vg, int act)
 {
 	int complete = 1;
 
 	lock_pvs(s);
-	struct config_node *pv = pvs(vg);
+	struct dm_config_node *pv = pvs(vg);
 	while (pv) {
-		const char *uuid = find_config_str(pv->child, "id", NULL);
+		const char *uuid = dm_config_find_str(pv->child, "id", NULL);
 		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
 		if (act)
 			set_flag(cft, pv, "status", "MISSING", !found);
@@ -152,25 +154,25 @@
 {
 	const char *uuid = daemon_request_str(r, "uuid", "NONE");
 	debug("vg_by_uuid: %s (vgs = %p)\n", uuid, s->vgs);
-	struct config_tree *cft = lock_vg(s, uuid);
+	struct dm_config_tree *cft = lock_vg(s, uuid);
 	if (!cft || !cft->root) {
 		unlock_vg(s, uuid);
 		return daemon_reply_simple("failed", "reason = %s", "uuid not found", NULL);
 	}
 
-	struct config_node *metadata = cft->root;
+	struct dm_config_node *metadata = cft->root;
 
 	response res = { .buffer = NULL };
-	struct config_node *n;
-	res.cft = create_config_tree(NULL, 0);
+	struct dm_config_node *n;
+	res.cft = dm_config_create(NULL, 0);
 
 	/* The response field */
-	res.cft->root = n = create_config_node(res.cft, "response");
-	n->v->type = CFG_STRING;
+	res.cft->root = n = dm_config_create_node(res.cft, "response");
+	n->v->type = DM_CFG_STRING;
 	n->v->v.str = "OK";
 
 	/* The metadata section */
-	n = n->sib = clone_config_node(res.cft, metadata, 1);
+	n = n->sib = dm_config_clone_node(res.cft, metadata, 1);
 	n->parent = res.cft->root;
 	res.error = 0;
 	unlock_vg(s, uuid);
@@ -180,7 +182,7 @@
 	return res;
 }
 
-static int compare_value(struct config_value *a, struct config_value *b)
+static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
 {
 	if (a->type > b->type)
 		return 1;
@@ -188,17 +190,17 @@
 		return -1;
 
 	switch (a->type) {
-	case CFG_STRING: return strcmp(a->v.str, b->v.str);
-	case CFG_FLOAT: return a->v.r == b->v.r;
-	case CFG_INT: return a->v.i == b->v.i;
-	case CFG_EMPTY_ARRAY: return 0;
+	case DM_CFG_STRING: return strcmp(a->v.str, b->v.str);
+	case DM_CFG_FLOAT: return a->v.r == b->v.r;
+	case DM_CFG_INT: return a->v.i == b->v.i;
+	case DM_CFG_EMPTY_ARRAY: return 0;
 	}
 
 	if (a->next && b->next)
 		return compare_value(a->next, b->next);
 }
 
-static int compare_config(struct config_node *a, struct config_node *b)
+static int compare_config(struct dm_config_node *a, struct dm_config_node *b)
 {
 	int result = 0;
 	if (a->v && b->v)
@@ -224,15 +226,15 @@
 }
 
 /* You need to be holding the pvid_map lock already to call this. */
-int update_pvid_map(lvmetad_state *s, struct config_tree *vg, const char *vgid)
+int update_pvid_map(lvmetad_state *s, struct dm_config_tree *vg, const char *vgid)
 {
-	struct config_node *pv = pvs(vg);
+	struct dm_config_node *pv = pvs(vg->root);
 
 	if (!vgid)
 		return 0;
 
 	while (pv) {
-		char *pvid = find_config_str(pv->child, "id", NULL);
+		char *pvid = dm_config_find_str(pv->child, "id", NULL);
 		dm_hash_insert(s->pvid_map, pvid, vgid);
 		pv = pv->sib;
 	}
@@ -243,19 +245,19 @@
 /* No locks need to be held. The pointers are never used outside of the scope of
  * this function, so they can be safely destroyed after update_metadata returns
  * (anything that might have been retained is copied). */
-static int update_metadata(lvmetad_state *s, const char *_vgid, struct config_node *metadata)
+static int update_metadata(lvmetad_state *s, const char *_vgid, struct dm_config_node *metadata)
 {
 	int retval = 0;
 	lock_vgs(s);
-	struct config_tree *old = dm_hash_lookup(s->vgs, _vgid);
+	struct dm_config_tree *old = dm_hash_lookup(s->vgs, _vgid);
 	lock_vg(s, _vgid);
 	unlock_vgs(s);
 
-	int seq = find_config_int(metadata, "metadata/seqno", -1);
+	int seq = dm_config_find_int(metadata, "metadata/seqno", -1);
 	int haveseq = -1;
 
 	if (old)
-		haveseq = find_config_int(old->root, "metadata/seqno", -1);
+		haveseq = dm_config_find_int(old->root, "metadata/seqno", -1);
 
 	if (seq < 0)
 		goto out;
@@ -274,9 +276,9 @@
 		goto out;
 	}
 
-	struct config_tree *cft = create_config_tree(NULL, 0);
-	cft->root = clone_config_node(cft, metadata, 0);
-	const char *vgid = find_config_str(cft->root, "metadata/id", NULL);
+	struct dm_config_tree *cft = dm_config_create(NULL, 0);
+	cft->root = dm_config_clone_node(cft, metadata, 0);
+	const char *vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 
 	if (!vgid)
 		goto out;
@@ -287,7 +289,7 @@
 		/* temporarily orphan all of our PVs */
 		update_pvid_map(s, old, "#orphan");
 		/* need to update what we have since we found a newer version */
-		destroy_config_tree(old);
+		dm_config_destroy(old);
 		dm_hash_remove(s->vgs, vgid);
 	}
 
@@ -306,7 +308,7 @@
 
 static response pv_add(lvmetad_state *s, request r)
 {
-	struct config_node *metadata = find_config_node(r.cft->root, "metadata");
+	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 
@@ -336,7 +338,7 @@
 
 	int complete = 0;
 	if (vgid) {
-		struct config_tree *cft = lock_vg(s, vgid);
+		struct dm_config_tree *cft = lock_vg(s, vgid);
 		complete = update_pv_status(s, cft, cft->root, 0);
 		unlock_vg(s, vgid);
 	}
@@ -400,7 +402,7 @@
 	lvmetad_state *ls = s->private;
 	struct dm_hash_node *n = dm_hash_get_first(ls->vgs);
 	while (n) {
-		destroy_config_tree(dm_hash_get_data(ls->vgs, n));
+		dm_config_destroy(dm_hash_get_data(ls->vgs, n));
 		n = dm_hash_get_next(ls->vgs, n);
 	}
 


