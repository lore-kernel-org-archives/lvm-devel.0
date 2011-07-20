From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 18:34:58 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720183458.7144.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 18:34:57

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Optimise PV -> VG lookups by using a UUID (hash) map.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 18:24:49	1.13
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 18:34:57	1.14
@@ -9,7 +9,7 @@
 typedef struct {
 	struct dm_hash_table *pvs;
 	struct dm_hash_table *vgs;
-	struct dm_hash_table *pvid_to_vgid;
+	struct dm_hash_table *pvid_map;
 } lvmetad_state;
 
 static response vg_by_uuid(lvmetad_state *s, request r)
@@ -39,7 +39,7 @@
 }
 
 static void set_flag(struct config_tree *cft, struct config_node *parent,
-		     const char *field, const char *flag, int want) {
+		     char *field, const char *flag, int want) {
 	struct config_value *value = NULL, *pred = NULL;
 	struct config_node *node = find_config_node(parent->child, field);
 	int found = 0;
@@ -128,11 +128,14 @@
 static void update_pv_status(lvmetad_state *s, const char *pvid)
 {
 	if (pvid) {
-		const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
-		assert(vgid);
+		const char *vgid = dm_hash_lookup(s->pvid_map, pvid);
+		if (!vgid)
+			return; /* nothing to update */
+
 		struct config_tree *vg = dm_hash_lookup(s->vgs, vgid);
 		assert(vg);
-		update_pv_status_in_vg(s, vg->root);
+
+		update_pv_status_in_vg(s, vg);
 	} else {
 		struct dm_hash_node *n = dm_hash_get_first(s->vgs);
 		while (n) {
@@ -143,24 +146,21 @@
 	}
 }
 
-struct config_tree *vg_from_pvid(lvmetad_state *s, const char *pvid)
+int update_pvid_map(lvmetad_state *s, struct config_tree *vg)
 {
-	struct dm_hash_node *n = dm_hash_get_first(s->vgs);
-
-	while (n) {
-		struct config_tree *vg = dm_hash_get_data(s->vgs, n);
-		struct config_node *pv = pvs(vg);
+	struct config_node *pv = pvs(vg);
+	char *vgid = find_config_str(vg->root, "metadata/id", NULL);
 
-		while (pv) {
-			const char *uuid = find_config_str(pv->child, "id", "N/A");
-			if (!strcmp(uuid, pvid))
-				return vg;
-			pv = pv->sib;
-		}
+	if (!vgid)
+		return 0;
 
-		n = dm_hash_get_next(s->vgs, n);
+	while (pv) {
+		char *pvid = find_config_str(pv->child, "id", NULL);
+		dm_hash_insert(s->pvid_map, pvid, vgid);
+		pv = pv->sib;
 	}
-	return NULL;
+
+	return 1;
 }
 
 static int update_metadata(lvmetad_state *s, const char *vgid, struct config_node *metadata)
@@ -195,6 +195,7 @@
 	struct config_tree *cft = create_config_tree(NULL, 0);
 	cft->root = clone_config_node(cft, metadata, 0);
 	dm_hash_insert(s->vgs, vgid, cft);
+	update_pvid_map(s, cft);
 
 	return 1;
 }
@@ -208,7 +209,7 @@
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
 
-	dm_hash_insert(s->pvs, pvid, 1);
+	dm_hash_insert(s->pvs, pvid, (void*)1);
 
 	if (metadata) {
 		if (!vgid)
@@ -219,13 +220,10 @@
 		if (!update_metadata(s, vgid, metadata))
 			return daemon_reply_simple("failed", "reason = %s",
 						   "metadata update failed", NULL);
-	} else {
-		struct config_tree *vg = vg_from_pvid(s, pvid);
-		if (vg)
-			vgid = find_config_str(vg->root, "metadata/id", NULL);
-	}
+	} else
+		vgid = dm_hash_lookup(s->pvid_map, pvid);
 
-	update_pv_status(s, NULL);
+	update_pv_status(s, pvid);
 	int complete = vgid ? vg_status(s, vgid) : 0;
 
 	return daemon_reply_simple("OK",
@@ -261,6 +259,7 @@
 
 	ls->pvs = dm_hash_create(32);
 	ls->vgs = dm_hash_create(32);
+	ls->pvid_map = dm_hash_create(32);
 	fprintf(stderr, "[D] initialised state: vgs = %p\n", ls->vgs);
 	if (!ls->pvs || !ls->vgs)
 		return 0;


