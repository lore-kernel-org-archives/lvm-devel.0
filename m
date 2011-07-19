From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Jul 2011 16:48:14 -0000
Subject: LVM2/daemons/lvmetad Makefile lvmetad-core.c t ...
Message-ID: <20110719164814.22194.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-19 16:48:14

Modified files:
	daemons/lvmetad: Makefile lvmetad-core.c test.sh testclient.c 

Log message:
	Work out some more details in metadata update in lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/test.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/lvmetad/Makefile	2011/06/27 13:44:33	1.2
+++ LVM2/daemons/lvmetad/Makefile	2011/07/19 16:48:13	1.3
@@ -28,3 +28,6 @@
 
 check: testclient lvmetad
 	./test.sh "$(BUILDDIR)/libdm:$(BUILDDIR)/daemons/dmeventd"
+
+clean:
+	rm -f testclient lvmetad
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/19 14:13:59	1.7
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/19 16:48:13	1.8
@@ -18,10 +18,11 @@
 {
 	const char *uuid = daemon_request_str(r, "uuid", "NONE");
 	fprintf(stderr, "[D] vg_by_uuid: %s (vgs = %p)\n", uuid, s->vgs);
-	struct config_node *metadata = dm_hash_lookup(s->vgs, uuid);
-	if (!metadata)
+	struct config_tree *cft = dm_hash_lookup(s->vgs, uuid);
+	if (!cft || !cft->root)
 		return daemon_reply_simple("failed", "reason = %s", "uuid not found", NULL);
-	fprintf(stderr, "[D] metadata: %p\n", metadata);
+
+	struct config_node *metadata = cft->root;
 
 	response res = { .buffer = NULL };
 	struct config_node *n;
@@ -67,16 +68,16 @@
 	if (pvid) {
 		const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 		assert(vgid);
-		struct config_node *vg = dm_hash_lookup(s->vgs, vgid);
+		struct config_tree *vg = dm_hash_lookup(s->vgs, vgid);
 		assert(vg);
-		update_pv_status_in_vg(s, vg);
+		update_pv_status_in_vg(s, vg->root);
 	} else {
 		struct dm_hash_node *n = dm_hash_get_first(s->vgs);
 		while (n) {
-			struct config_node *vg = dm_hash_get_data(s->vgs, n);
+			struct config_tree *vg = dm_hash_get_data(s->vgs, n);
 			fprintf(stderr, "[D] checking VG: %s\n",
 				find_config_str(vg, "metadata/id", "?"));
-			update_pv_status_in_vg(s, vg);
+			update_pv_status_in_vg(s, vg->root);
 			n = dm_hash_get_next(s->vgs, n);
 		}
 	}
@@ -84,11 +85,38 @@
 
 static int update_metadata(lvmetad_state *s, const char *vgid, struct config_node *metadata)
 {
-	struct config_node *metadata_clone =
-		clone_config_node_with_mem(s->mem, metadata, 0);
-	/* TODO: seqno-based comparison with existing metadata version */
-	dm_hash_insert(s->vgs, vgid, (void*) metadata_clone);
-	fprintf(stderr, "[D] metadata stored at %p\n", metadata_clone);
+	struct config_tree *old = dm_hash_lookup(s->vgs, vgid);
+	int seq = find_config_int(metadata, "metadata/seqno", -1);
+	int haveseq = -1;
+
+	if (old)
+		haveseq = find_config_int(old->root, "metadata/seqno", -1);
+
+	if (seq < 0)
+		return 0; /* bad */
+
+	if (seq == haveseq) {
+		// TODO: compare old->root with metadata to ensure equality
+		return 1;
+	}
+
+	if (seq < haveseq) {
+		// TODO: we may want to notify the client that their metadata is
+		// out of date?
+		return 1;
+	}
+
+	if (haveseq >= 0 && haveseq < seq) {
+		/* need to update what we have since we found a newer version */
+		destroy_config_tree(old);
+		dm_hash_remove(s->vgs, vgid);
+	}
+
+	struct config_tree *cft = create_config_tree(NULL, 0);
+	cft->root = clone_config_node(cft, metadata, 0);
+	dm_hash_insert(s->vgs, vgid, cft);
+
+	return 1;
 }
 
 static response pv_add(lvmetad_state *s, request r)
@@ -106,8 +134,12 @@
 		const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 		if (!vgid)
 			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
+			return daemon_reply_simple("failed", "reason = %s", "need VG seqno", NULL);
 
-		update_metadata(s, vgid, metadata);
+		if (!update_metadata(s, vgid, metadata))
+			return daemon_reply_simple("failed", "reason = %s",
+						   "metadata update failed", NULL);
 	}
 
 	update_pv_status(s, NULL);
--- LVM2/daemons/lvmetad/test.sh	2011/06/27 13:44:33	1.1
+++ LVM2/daemons/lvmetad/test.sh	2011/07/19 16:48:13	1.2
@@ -3,9 +3,11 @@
 export LD_LIBRARY_PATH="$1"
 
 test -n "$2" && {
-    ./lvmetad -f &
+    rm -f /var/run/lvmetad.{socket,pid}
+    chmod +rx lvmetad
+    valgrind ./lvmetad -f &
     PID=$!
-    sleep .1
+    sleep 1
     ./testclient
     kill $PID
     exit 0
--- LVM2/daemons/lvmetad/testclient.c	2011/07/18 14:48:30	1.7
+++ LVM2/daemons/lvmetad/testclient.c	2011/07/19 16:48:13	1.8
@@ -17,6 +17,9 @@
 	"    pv1 {\n"
 	"        id = \"bbcd-efgh\"\n"
 	"    }\n"
+	"    pv2 {\n"
+	"        id = \"cbcd-efgh\"\n"
+	"    }\n"
 	"}\n"
 	"}\n";
 


