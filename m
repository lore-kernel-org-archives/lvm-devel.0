From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 21:33:41 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720213341.13373.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 21:33:41

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad: Obliterate vg_status by returning the same information from
	update_pv_status, saving a dozen lines of code and execution time of one
	walkthrough of the PV list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:27:28	1.18
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:33:41	1.19
@@ -144,8 +144,10 @@
 
 /* Either the "big" vgs lock, or a per-vg lock needs to be held before entering
  * this function. */
-static void update_pv_status(lvmetad_state *s, struct config_tree *vg)
+static int update_pv_status(lvmetad_state *s, struct config_tree *vg)
 {
+	int complete = 1;
+
 	lock_pvs(s);
 	struct config_node *pv = pvs(vg);
 	while (pv) {
@@ -154,30 +156,13 @@
 		// TODO: avoid the override here if MISSING came from the actual
 		// metadata, as opposed from our manipulation...
 		set_flag(vg, pv, "status", "MISSING", !found);
+		if (!found)
+			complete = 0;
 		pv = pv->sib;
 	}
 	unlock_pvs(s);
-}
-
-static int vg_status(lvmetad_state *s, const char *vgid)
-{
-	struct config_tree *vg = lock_vg(s, vgid);
-	struct config_node *pv = pvs(vg);
 
-	while (pv) {
-		const char *uuid = find_config_str(pv->child, "id", NULL);
-		lock_pvs(s);
-		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
-		unlock_pvs(s);
-		if (!found) {
-			unlock_vg(s, vgid);
-			return 0;
-		}
-		pv = pv->sib;
-	}
-
-	unlock_vg(s, vgid);
-	return 1;
+	return complete;
 }
 
 /* You need to be holding the pvid_map lock already to call this. */
@@ -269,6 +254,8 @@
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
 
+	debug("pv_add %s, vgid = %s\n", pvid, vgid);
+
 	lock_pvs(s);
 	dm_hash_insert(s->pvs, pvid, (void*)1);
 	unlock_pvs(s);
@@ -288,14 +275,13 @@
 		unlock_pvid_map(s);
 	}
 
+	int complete = 0;
 	if (vgid) {
 		struct config_tree *cft = lock_vg(s, vgid);
-		update_pv_status(s, cft);
+		complete = update_pv_status(s, cft);
 		unlock_vg(s, vgid);
 	}
 
-	int complete = vgid ? vg_status(s, vgid) : 0;
-
 	return daemon_reply_simple("OK",
 				   "status = %s", complete ? "complete" : "partial",
 				   "vgid = %s", vgid ? vgid : "#orphan",


