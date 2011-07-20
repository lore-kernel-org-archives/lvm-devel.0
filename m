From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 15:14:17 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720151417.22392.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 15:14:17

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Make lvmetad report the VG ID and status (complete, partial) in reply to pv_add
	requests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/19 19:15:22	1.9
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 15:14:17	1.10
@@ -4,7 +4,6 @@
 #include <malloc.h>
 #include <stdint.h>
 
-#include "metadata-exported.h"
 #include "../common/daemon-server.h"
 
 typedef struct {
@@ -99,6 +98,25 @@
 	}
 }
 
+static int vg_status(lvmetad_state *s, const char *vgid)
+{
+	struct config_tree *vg = dm_hash_lookup(s->vgs, vgid);
+	struct config_node *pv = find_config_node(vg->root, "metadata/physical_volumes");
+	if (pv)
+		pv = pv->child;
+
+	while (pv) {
+		const char *uuid = find_config_str(pv->child, "id", "N/A");
+		const char *vgid = find_config_str(vg->root, "metadata/id", "N/A");
+		int found = dm_hash_lookup(s->pvs, uuid) ? 1 : 0;
+		if (!found)
+			return 0;
+		pv = pv->sib;
+	}
+
+	return 1;
+}
+
 /*
  * Walk through metadata cache and update PV flags to reflect our current
  * picture of the PVs in the system. If pvid is non-NULL, this is used as a hint
@@ -163,7 +181,7 @@
 {
 	struct config_node *metadata = find_config_node(r.cft->root, "metadata");
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
-	fprintf(stderr, "[D] pv_add buffer: %s\n", r.buffer);
+	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
@@ -171,7 +189,6 @@
 	dm_hash_insert(s->pvs, pvid, 1);
 
 	if (metadata) {
-		const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 		if (!vgid)
 			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
@@ -180,11 +197,18 @@
 		if (!update_metadata(s, vgid, metadata))
 			return daemon_reply_simple("failed", "reason = %s",
 						   "metadata update failed", NULL);
+	} else {
+		// TODO: find the corresponding VGID when available to give to
+		// the caller, and to find out whether the VG is complete
 	}
 
 	update_pv_status(s, NULL);
+	int complete = vgid ? vg_status(s, vgid) : 0;
 
-	return daemon_reply_simple("OK", NULL);
+	return daemon_reply_simple("OK",
+				   "status = %s", complete ? "complete" : "partial",
+				   vgid ? "vgid = %s" : "", vgid,
+				   NULL);
 }
 
 static void pv_del(lvmetad_state *s, request r)


