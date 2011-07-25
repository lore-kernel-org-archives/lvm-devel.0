From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Jul 2011 17:59:51 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110725175951.14924.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-25 17:59:51

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad: Edit the MISSING_PV flags only after making a "reply" copy of the
	metadata, which is then serialised and discarded. This fixes a couple of
	outstanding TODO items about handling the MISSING flags correctly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/25 15:51:51	1.21
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/25 17:59:50	1.22
@@ -65,6 +65,89 @@
 	unlock_vgs(s);
 }
 
+static struct config_node *pvs(struct config_node *vg)
+{
+	struct config_node *pv = find_config_node(vg, "metadata/physical_volumes");
+	if (pv)
+		pv = pv->child;
+	return pv;
+}
+
+/*
+ * TODO: This set_flag function is pretty generic and might make sense in a
+ * library here or there.
+ */
+static void set_flag(struct config_tree *cft, struct config_node *parent,
+		     char *field, const char *flag, int want) {
+	struct config_value *value = NULL, *pred = NULL;
+	struct config_node *node = find_config_node(parent->child, field);
+	int found = 0;
+
+	if (node)
+		value = node->v;
+
+	while (value && value->type != CFG_EMPTY_ARRAY && strcmp(value->v.str, flag)) {
+		pred = value;
+		value = value->next;
+	}
+
+	if (value && want)
+		return;
+
+	if (!value && !want)
+		return;
+
+	if (value && !want) {
+		if (pred)
+			pred->next = value->next;
+		if (value == node->v)
+			node->v = value->next;
+	}
+
+	if (!value && want) {
+		if (!node) {
+			node = create_config_node(cft, field);
+			node->sib = parent->child;
+			node->v = create_config_value(cft);
+			node->v->type = CFG_EMPTY_ARRAY;
+			node->parent = parent;
+			parent->child = node;
+		}
+		struct config_value *new = create_config_value(cft);
+		new->type = CFG_STRING;
+		new->v.str = flag;
+		new->next = node->v;
+		node->v = new;
+	}
+}
+
+/* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
+ * this function. */
+static int update_pv_status(lvmetad_state *s, struct config_tree *cft, struct config_node *vg, int act)
+{
+	int complete = 1;
+
+	lock_pvs(s);
+	struct config_node *pv = pvs(vg);
+	while (pv) {
+		const char *uuid = find_config_str(pv->child, "id", NULL);
+		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
+		if (act)
+			set_flag(cft, pv, "status", "MISSING", !found);
+		if (!found) {
+			complete = 0;
+			if (!act) { // optimisation
+				unlock_pvs(s);
+				return complete;
+			}
+		}
+		pv = pv->sib;
+	}
+	unlock_pvs(s);
+
+	return complete;
+}
+
 static response vg_by_uuid(lvmetad_state *s, request r)
 {
 	const char *uuid = daemon_request_str(r, "uuid", "NONE");
@@ -92,14 +175,11 @@
 	res.error = 0;
 	unlock_vg(s, uuid);
 
+	update_pv_status(s, cft, n, 1);
+
 	return res;
 }
 
-/*
- * TODO: Accept different flag permutations? Or else, ensure fixed ordering of
- * flags in set_flag below (following the same order as we have in
- * lib/format_text/flags.c).
- */
 static int compare_value(struct config_value *a, struct config_value *b)
 {
 	if (a->type > b->type)
@@ -143,85 +223,6 @@
 	return result;
 }
 
-/*
- * TODO: This set_flag function is pretty generic and might make sense in a
- * library here or there.
- */
-static void set_flag(struct config_tree *cft, struct config_node *parent,
-		     char *field, const char *flag, int want) {
-	struct config_value *value = NULL, *pred = NULL;
-	struct config_node *node = find_config_node(parent->child, field);
-	int found = 0;
-
-	if (node)
-		value = node->v;
-
-	while (value && value->type != CFG_EMPTY_ARRAY && strcmp(value->v.str, flag)) {
-		pred = value;
-		value = value->next;
-	}
-
-	if (value && want)
-		return;
-
-	if (!value && !want)
-		return;
-
-	if (value && !want) {
-		if (pred)
-			pred->next = value->next;
-		if (value == node->v)
-			node->v = value->next;
-	}
-
-	if (!value && want) {
-		if (!node) {
-			node = create_config_node(cft, field);
-			node->sib = parent->child;
-			node->v = create_config_value(cft);
-			node->v->type = CFG_EMPTY_ARRAY;
-			node->parent = parent;
-			parent->child = node;
-		}
-		struct config_value *new = create_config_value(cft);
-		new->type = CFG_STRING;
-		new->v.str = flag;
-		new->next = node->v;
-		node->v = new;
-	}
-}
-
-struct config_node *pvs(struct config_tree *vg)
-{
-	struct config_node *pv = find_config_node(vg->root, "metadata/physical_volumes");
-	if (pv)
-		pv = pv->child;
-	return pv;
-}
-
-/* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
- * this function. */
-static int update_pv_status(lvmetad_state *s, struct config_tree *vg)
-{
-	int complete = 1;
-
-	lock_pvs(s);
-	struct config_node *pv = pvs(vg);
-	while (pv) {
-		const char *uuid = find_config_str(pv->child, "id", NULL);
-		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
-		// TODO: avoid the override here if MISSING came from the actual
-		// metadata, as opposed from our manipulation...
-		set_flag(vg, pv, "status", "MISSING", !found);
-		if (!found)
-			complete = 0;
-		pv = pv->sib;
-	}
-	unlock_pvs(s);
-
-	return complete;
-}
-
 /* You need to be holding the pvid_map lock already to call this. */
 int update_pvid_map(lvmetad_state *s, struct config_tree *vg, const char *vgid)
 {
@@ -261,7 +262,6 @@
 
 	if (seq == haveseq) {
 		retval = 1;
-		// TODO: disregard the MISSING_PV flag status in this comparison
 		if (compare_config(metadata, old->root))
 			retval = 0;
 		goto out;
@@ -337,7 +337,7 @@
 	int complete = 0;
 	if (vgid) {
 		struct config_tree *cft = lock_vg(s, vgid);
-		complete = update_pv_status(s, cft);
+		complete = update_pv_status(s, cft, cft->root, 0);
 		unlock_vg(s, vgid);
 	}
 


