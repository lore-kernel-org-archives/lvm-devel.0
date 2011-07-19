From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Jul 2011 19:15:22 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110719191522.12669.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-19 19:15:22

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Towards MISSING (PV) flag management in lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/19 16:48:13	1.8
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/19 19:15:22	1.9
@@ -40,19 +40,61 @@
 	return res;
 }
 
-static void update_pv_status_in_vg(lvmetad_state *s, struct config_node *vg)
+static void set_flag(struct config_tree *cft, struct config_node *parent,
+		     const char *field, const char *flag, int want) {
+	struct config_value *value = NULL, *pred = NULL;
+	struct config_node *node = find_config_node(parent->child, field);
+	int found = 0;
+
+	if (node)
+		value = node->v;
+
+	while (value && strcmp(value->v.str, flag)) {
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
+static void update_pv_status_in_vg(lvmetad_state *s, struct config_tree *vg)
 {
-	struct config_node *pv = find_config_node(vg, "metadata/physical_volumes");
+	struct config_node *pv = find_config_node(vg->root, "metadata/physical_volumes");
 	if (pv)
 		pv = pv->child;
 
 	while (pv) {
 		const char *uuid = find_config_str(pv->child, "id", "N/A");
-		if (dm_hash_lookup(s->pvs, uuid)) {
-			fprintf(stderr, "[D] PV %s found\n", uuid);
-		} else {
-			fprintf(stderr, "[D] PV %s is MISSING\n", uuid);
-		}
+		const char *vgid = find_config_str(vg->root, "metadata/id", "N/A");
+		int found = dm_hash_lookup(s->pvs, uuid) ? 1 : 0;
+		set_flag(vg, pv, "status", "MISSING", !found);
 		pv = pv->sib;
 	}
 }
@@ -75,9 +117,7 @@
 		struct dm_hash_node *n = dm_hash_get_first(s->vgs);
 		while (n) {
 			struct config_tree *vg = dm_hash_get_data(s->vgs, n);
-			fprintf(stderr, "[D] checking VG: %s\n",
-				find_config_str(vg, "metadata/id", "?"));
-			update_pv_status_in_vg(s, vg->root);
+			update_pv_status_in_vg(s, vg);
 			n = dm_hash_get_next(s->vgs, n);
 		}
 	}


