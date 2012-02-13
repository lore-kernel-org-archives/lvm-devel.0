From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 14:25:14 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120213142514.856.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 14:25:14

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Add some FIXME around allocation code
	
	Remove also unreachable break..

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/01/25 21:42:09	1.31
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/13 14:25:14	1.32
@@ -88,7 +88,7 @@
  * TODO: This set_flag function is pretty generic and might make sense in a
  * library here or there.
  */
-static void set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
+static int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
 		     const char *field, const char *flag, int want) {
 	struct dm_config_value *value = NULL, *pred = NULL;
 	struct dm_config_node *node = dm_config_find_node(parent->child, field);
@@ -103,10 +103,10 @@
 	}
 
 	if (value && want)
-		return;
+		return 1;
 
 	if (!value && !want)
-		return;
+		return 1;
 
 	if (value && !want) {
 		if (pred) {
@@ -127,12 +127,17 @@
 			node->parent = parent;
 			parent->child = node;
 		}
-		new = dm_config_create_value(cft);
+		if (!(new = dm_config_create_value(cft))) {
+			/* FIXME error reporting */
+			return 0;
+		}
 		new->type = DM_CFG_STRING;
 		new->v.str = flag;
 		new->next = node->v;
 		node->v = new;
 	}
+
+	return 1;
 }
 
 /* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
@@ -149,8 +154,11 @@
 	while (pv) {
 		const char *uuid = dm_config_find_str(pv->child, "id", NULL);
 		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
-		if (act)
-			set_flag(cft, pv, "status", "MISSING", !found);
+		if (act &&
+		    !set_flag(cft, pv, "status", "MISSING", !found)) {
+			complete =  0;
+			break;
+		}
 		if (!found) {
 			complete = 0;
 			if (!act) { // optimisation
@@ -215,7 +223,7 @@
 	res.error = 0;
 	unlock_vg(s, uuid);
 
-	update_pv_status(s, cft, n, 1);
+	update_pv_status(s, cft, n, 1); /* FIXME error reporting */
 
 	return res;
 }
@@ -615,7 +623,6 @@
 		case 'V':
 			printf("lvmetad version 0\n");
 			exit(1);
-			break;
 		}
 	}
 


