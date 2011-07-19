From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Jul 2011 14:13:59 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110719141359.18003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-19 14:13:59

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	More work on cache maintenance code in lvmetad: keep track of PV status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/18 14:48:30	1.6
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/19 14:13:59	1.7
@@ -9,8 +9,9 @@
 
 typedef struct {
 	struct dm_pool *mem;
-	struct dm_hash_table *pvids;
+	struct dm_hash_table *pvs;
 	struct dm_hash_table *vgs;
+	struct dm_hash_table *pvid_to_vgid;
 } lvmetad_state;
 
 static response vg_by_uuid(lvmetad_state *s, request r)
@@ -32,35 +33,85 @@
 	n->v->v.str = "OK";
 
 	/* The metadata section */
-	n = n->sib = create_config_node(res.cft, "metadata");
-	n->v = NULL;
+	n = n->sib = clone_config_node(res.cft, metadata, 1);
 	n->parent = res.cft->root;
-	n->child = clone_config_node(res.cft, metadata, 1);
 	res.error = 0;
-	fprintf(stderr, "[D] vg_by_uuid signing off\n");
 	return res;
 }
 
+static void update_pv_status_in_vg(lvmetad_state *s, struct config_node *vg)
+{
+	struct config_node *pv = find_config_node(vg, "metadata/physical_volumes");
+	if (pv)
+		pv = pv->child;
+
+	while (pv) {
+		const char *uuid = find_config_str(pv->child, "id", "N/A");
+		if (dm_hash_lookup(s->pvs, uuid)) {
+			fprintf(stderr, "[D] PV %s found\n", uuid);
+		} else {
+			fprintf(stderr, "[D] PV %s is MISSING\n", uuid);
+		}
+		pv = pv->sib;
+	}
+}
+
+/*
+ * Walk through metadata cache and update PV flags to reflect our current
+ * picture of the PVs in the system. If pvid is non-NULL, this is used as a hint
+ * as to which PV has changed state. Otherwise, all flags are recomputed from
+ * authoritative data (the s->pvs hash).
+ */
+static void update_pv_status(lvmetad_state *s, const char *pvid)
+{
+	if (pvid) {
+		const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
+		assert(vgid);
+		struct config_node *vg = dm_hash_lookup(s->vgs, vgid);
+		assert(vg);
+		update_pv_status_in_vg(s, vg);
+	} else {
+		struct dm_hash_node *n = dm_hash_get_first(s->vgs);
+		while (n) {
+			struct config_node *vg = dm_hash_get_data(s->vgs, n);
+			fprintf(stderr, "[D] checking VG: %s\n",
+				find_config_str(vg, "metadata/id", "?"));
+			update_pv_status_in_vg(s, vg);
+			n = dm_hash_get_next(s->vgs, n);
+		}
+	}
+}
+
+static int update_metadata(lvmetad_state *s, const char *vgid, struct config_node *metadata)
+{
+	struct config_node *metadata_clone =
+		clone_config_node_with_mem(s->mem, metadata, 0);
+	/* TODO: seqno-based comparison with existing metadata version */
+	dm_hash_insert(s->vgs, vgid, (void*) metadata_clone);
+	fprintf(stderr, "[D] metadata stored at %p\n", metadata_clone);
+}
+
 static response pv_add(lvmetad_state *s, request r)
 {
-	const struct config_node *metadata = find_config_node(r.cft->root, "metadata");
+	struct config_node *metadata = find_config_node(r.cft->root, "metadata");
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	fprintf(stderr, "[D] pv_add buffer: %s\n", r.buffer);
 
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
 
+	dm_hash_insert(s->pvs, pvid, 1);
+
 	if (metadata) {
 		const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 		if (!vgid)
 			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
-		// TODO
-		const struct config_node *metadata_clone =
-			clone_config_node_with_mem(s->mem, metadata, 0);
-		dm_hash_insert(s->vgs, vgid, (void*) metadata_clone);
-		fprintf(stderr, "[D] metadata stored at %p\n", metadata_clone);
+
+		update_metadata(s, vgid, metadata);
 	}
 
+	update_pv_status(s, NULL);
+
 	return daemon_reply_simple("OK", NULL);
 }
 
@@ -89,11 +140,11 @@
 {
 	lvmetad_state *ls = s->private;
 
-	ls->pvids = dm_hash_create(32);
+	ls->pvs = dm_hash_create(32);
 	ls->vgs = dm_hash_create(32);
 	ls->mem = dm_pool_create("lvmetad", 1024); /* whatever */
 	fprintf(stderr, "[D] initialised state: vgs = %p\n", ls->vgs);
-	if (!ls->pvids || !ls->vgs || !ls->mem)
+	if (!ls->pvs || !ls->vgs || !ls->mem)
 		return 0;
 
 	/* if (ls->initial_registrations)


