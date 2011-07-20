From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 18:45:33 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720184533.13911.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 18:45:33

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad: Avoid stale PV -> VG mappings on metadata update.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 18:34:57	1.14
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 18:45:32	1.15
@@ -146,10 +146,9 @@
 	}
 }
 
-int update_pvid_map(lvmetad_state *s, struct config_tree *vg)
+int update_pvid_map(lvmetad_state *s, struct config_tree *vg, const char *vgid)
 {
 	struct config_node *pv = pvs(vg);
-	char *vgid = find_config_str(vg->root, "metadata/id", NULL);
 
 	if (!vgid)
 		return 0;
@@ -163,9 +162,9 @@
 	return 1;
 }
 
-static int update_metadata(lvmetad_state *s, const char *vgid, struct config_node *metadata)
+static int update_metadata(lvmetad_state *s, const char *_vgid, struct config_node *metadata)
 {
-	struct config_tree *old = dm_hash_lookup(s->vgs, vgid);
+	struct config_tree *old = dm_hash_lookup(s->vgs, _vgid);
 	int seq = find_config_int(metadata, "metadata/seqno", -1);
 	int haveseq = -1;
 
@@ -186,16 +185,23 @@
 		return 1;
 	}
 
+	struct config_tree *cft = create_config_tree(NULL, 0);
+	cft->root = clone_config_node(cft, metadata, 0);
+	const char *vgid = find_config_str(cft->root, "metadata/id", NULL);
+
+	if (!vgid)
+		return 0;
+
 	if (haveseq >= 0 && haveseq < seq) {
+		/* temporarily orphan all of our PVs */
+		update_pvid_map(s, old, "#orphan");
 		/* need to update what we have since we found a newer version */
 		destroy_config_tree(old);
 		dm_hash_remove(s->vgs, vgid);
 	}
 
-	struct config_tree *cft = create_config_tree(NULL, 0);
-	cft->root = clone_config_node(cft, metadata, 0);
 	dm_hash_insert(s->vgs, vgid, cft);
-	update_pvid_map(s, cft);
+	update_pvid_map(s, cft, vgid);
 
 	return 1;
 }


