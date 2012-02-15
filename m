From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 14:06:49 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120215140649.21656.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 14:06:48

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	In lvmetad, also nuke VGs when all their PVs are stolen by another VG (vgmerge
	& vgsplit do this).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 11:43:06	1.33
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 14:06:48	1.34
@@ -487,26 +487,45 @@
 	return result;
 }
 
+static int vg_remove_if_missing(lvmetad_state *s, const char *vgid);
+
 /* You need to be holding the pvid_to_vgid lock already to call this. */
-static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg, const char *vgid)
+static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
+			       const char *vgid, int nuke_empty)
 {
 	struct dm_config_node *pv = pvs(vg->root);
+	struct dm_hash_table *to_check = dm_hash_create(32);
 
 	if (!vgid)
 		return 0;
 
 	while (pv) {
 		const char *pvid = dm_config_find_str(pv->child, "id", NULL);
+		const char *vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid);
+		if (vgid_old && nuke_empty)
+			dm_hash_insert(to_check, vgid_old, (void*) 1);
 		dm_hash_insert(s->pvid_to_vgid, pvid, (void *) vgid);
 		debug("remap PV %s to VG %s\n", pvid, vgid);
 		pv = pv->sib;
 	}
 
+	struct dm_hash_node *n = dm_hash_get_first(to_check);
+
+	while (n) {
+		const char *check_vgid = dm_hash_get_key(to_check, n);
+		lock_vg(s, check_vgid);
+		vg_remove_if_missing(s, check_vgid);
+		unlock_vg(s, check_vgid);
+		n = dm_hash_get_next(to_check, n);
+	}
+
+	dm_hash_destroy(to_check);
+
 	return 1;
 }
 
-/* A pvid map lock needs to be held. */
-static int remove_metadata(lvmetad_state *s, const char *vgid)
+/* A pvid map lock needs to be held if update_pvids = 1. */
+static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 {
 	struct dm_config_tree *old;
 	const char *oldname;
@@ -518,7 +537,8 @@
 	if (!old)
 		return 0;
 
-	update_pvid_to_vgid(s, old, "#orphan");
+	if (update_pvids)
+		update_pvid_to_vgid(s, old, "#orphan", 0);
 	/* need to update what we have since we found a newer version */
 	dm_hash_remove(s->vgid_to_metadata, vgid);
 	dm_hash_remove(s->vgid_to_vgname, vgid);
@@ -554,7 +574,7 @@
 
 	if (missing) {
 		debug("nuking VG %s\n", vgid);
-		remove_metadata(s, vgid);
+		remove_metadata(s, vgid, 0);
 	}
 
 	unlock_pvid_to_status(s);
@@ -629,7 +649,7 @@
 	if (haveseq >= 0 && haveseq < seq) {
 		debug("Updating metadata for %s@%d to %d\n", _vgid, haveseq, seq);
 		/* temporarily orphan all of our PVs */
-		remove_metadata(s, vgid);
+		remove_metadata(s, vgid, 1);
 	}
 
 	// debug_cft("METADATA", metadata);
@@ -640,7 +660,7 @@
 	dm_hash_insert(s->vgname_to_vgid, name, (void *)vgid);
 	unlock_vgid_to_metadata(s);
 
-	update_pvid_to_vgid(s, cft, vgid);
+	update_pvid_to_vgid(s, cft, vgid, 1);
 
 	unlock_pvid_to_vgid(s);
 	retval = 1;
@@ -773,7 +793,7 @@
 	fprintf(stderr, "vg_remove: %s\n", vgid);
 
 	lock_pvid_to_vgid(s);
-	remove_metadata(s, vgid);
+	remove_metadata(s, vgid, 1);
 	unlock_pvid_to_vgid(s);
 
 	return daemon_reply_simple("OK", NULL);


