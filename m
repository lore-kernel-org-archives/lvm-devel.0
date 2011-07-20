From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 16:46:41 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720164641.405.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 16:46:40

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Make lvmetad also report VGID in reply when adding a PV without MDAs (this
	obviously only works for VGs that already had at least some MDA discovered).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 15:14:17	1.10
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 16:46:40	1.11
@@ -83,12 +83,17 @@
 	}
 }
 
-static void update_pv_status_in_vg(lvmetad_state *s, struct config_tree *vg)
+struct config_node *pvs(struct config_tree *vg)
 {
 	struct config_node *pv = find_config_node(vg->root, "metadata/physical_volumes");
 	if (pv)
 		pv = pv->child;
+	return pv;
+}
 
+static void update_pv_status_in_vg(lvmetad_state *s, struct config_tree *vg)
+{
+	struct config_node *pv = pvs(vg);
 	while (pv) {
 		const char *uuid = find_config_str(pv->child, "id", "N/A");
 		const char *vgid = find_config_str(vg->root, "metadata/id", "N/A");
@@ -101,9 +106,7 @@
 static int vg_status(lvmetad_state *s, const char *vgid)
 {
 	struct config_tree *vg = dm_hash_lookup(s->vgs, vgid);
-	struct config_node *pv = find_config_node(vg->root, "metadata/physical_volumes");
-	if (pv)
-		pv = pv->child;
+	struct config_node *pv = pvs(vg);
 
 	while (pv) {
 		const char *uuid = find_config_str(pv->child, "id", "N/A");
@@ -141,6 +144,26 @@
 	}
 }
 
+struct config_tree *vg_from_pvid(lvmetad_state *s, const char *pvid)
+{
+	struct dm_hash_node *n = dm_hash_get_first(s->vgs);
+
+	while (n) {
+		struct config_tree *vg = dm_hash_get_data(s->vgs, n);
+		struct config_node *pv = pvs(vg);
+
+		while (pv) {
+			const char *uuid = find_config_str(pv->child, "id", "N/A");
+			if (!strcmp(uuid, pvid))
+				return vg;
+			pv = pv->sib;
+		}
+
+		n = dm_hash_get_next(s->vgs, n);
+	}
+	return NULL;
+}
+
 static int update_metadata(lvmetad_state *s, const char *vgid, struct config_node *metadata)
 {
 	struct config_tree *old = dm_hash_lookup(s->vgs, vgid);
@@ -198,8 +221,9 @@
 			return daemon_reply_simple("failed", "reason = %s",
 						   "metadata update failed", NULL);
 	} else {
-		// TODO: find the corresponding VGID when available to give to
-		// the caller, and to find out whether the VG is complete
+		struct config_tree *vg = vg_from_pvid(s, pvid);
+		if (vg)
+			vgid = find_config_str(vg->root, "metadata/id", NULL);
 	}
 
 	update_pv_status(s, NULL);
@@ -207,7 +231,7 @@
 
 	return daemon_reply_simple("OK",
 				   "status = %s", complete ? "complete" : "partial",
-				   vgid ? "vgid = %s" : "", vgid,
+				   "vgid = %s", vgid ? vgid : "#orphan",
 				   NULL);
 }
 


