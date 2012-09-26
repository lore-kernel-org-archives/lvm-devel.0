From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:03 +0000 (UTC)
Subject: master - lvmetad: Give inconsistent metadata warnings in pvscan --cache.
Message-ID: <20120926175603.9939BA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ff2245c23247a1d3f9a03be66d3d186c824f03f
Commit:        1ff2245c23247a1d3f9a03be66d3d186c824f03f
Parent:        c731bb1ee13565763cc1ac77ed1a01ccea0337ac
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 19 23:45:51 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lvmetad: Give inconsistent metadata warnings in pvscan --cache.

---
 daemons/lvmetad/lvmetad-core.c |   21 ++++++++++++++++-----
 lib/cache/lvmetad.c            |    5 +++++
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index c6cc3d9..f796e33 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -636,7 +636,7 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
  * this function, so they can be safely destroyed after update_metadata returns
  * (anything that might have been retained is copied). */
 static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid,
-			   struct dm_config_node *metadata)
+			   struct dm_config_node *metadata, int64_t *oldseq)
 {
 	struct dm_config_tree *cft;
 	struct dm_config_tree *old;
@@ -665,6 +665,13 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 
 	filter_metadata(metadata); /* sanitize */
 
+	if (oldseq) {
+		if (old)
+			*oldseq = haveseq;
+		else
+			*oldseq = seq;
+	}
+
 	if (seq == haveseq) {
 		retval = 1;
 		if (compare_config(metadata, old->root))
@@ -786,6 +793,7 @@ static response pv_found(lvmetad_state *s, request r)
 	const char *old;
 	const char *pvid_dup;
 	int complete = 0, orphan = 0;
+	int64_t seqno = -1, seqno_old = -1;
 
 	if (!pvid)
 		return reply_fail("need PV UUID");
@@ -830,7 +838,7 @@ static response pv_found(lvmetad_state *s, request r)
 		if (daemon_request_int(r, "metadata/seqno", -1) < 0)
 			return reply_fail("need VG seqno");
 
-		if (!update_metadata(s, vgname, vgid, metadata))
+		if (!update_metadata(s, vgname, vgid, metadata, &seqno_old))
 			return reply_fail("metadata update failed");
 	} else {
 		lock_pvid_to_vgid(s);
@@ -839,9 +847,10 @@ static response pv_found(lvmetad_state *s, request r)
 	}
 
 	if (vgid) {
-		if ((cft = lock_vg(s, vgid)))
+		if ((cft = lock_vg(s, vgid))) {
 			complete = update_pv_status(s, cft, cft->root, 0);
-		else if (!strcmp(vgid, "#orphan"))
+			seqno = dm_config_find_int(cft->root, "metadata/seqno", -1);
+		} else if (!strcmp(vgid, "#orphan"))
 			orphan = 1;
 		else {
 			unlock_vg(s, vgid);
@@ -854,6 +863,8 @@ static response pv_found(lvmetad_state *s, request r)
 				   "status = %s", orphan ? "orphan" :
 				                     (complete ? "complete" : "partial"),
 				   "vgid = %s", vgid ? vgid : "#orphan",
+				   "seqno_before = %"PRId64, seqno_old,
+				   "seqno_after = %"PRId64, seqno,
 				   NULL);
 }
 
@@ -872,7 +883,7 @@ static response vg_update(lvmetad_state *s, request r)
 
 		/* TODO defer metadata update here; add a separate vg_commit
 		 * call; if client does not commit, die */
-		if (!update_metadata(s, vgname, vgid, metadata))
+		if (!update_metadata(s, vgname, vgid, metadata, NULL))
 			return reply_fail("metadata update failed");
 	}
 	return daemon_reply_simple("OK", NULL);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8ac5732..24a6b16 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -720,6 +720,11 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 
 	result = _lvmetad_handle_reply(reply, "update PV", uuid, NULL);
 
+	if (vg && result &&
+	    (daemon_reply_int(reply, "seqno_after", -1) != vg->seqno ||
+	     daemon_reply_int(reply, "seqno_after", -1) != daemon_reply_int(reply, "seqno_before", -1)))
+		log_warn("WARNING: Inconsistent metadata found for VG %s", vg->name);
+
 	if (result && handler) {
 		status = daemon_reply_str(reply, "status", "<missing>");
 		if (!strcmp(status, "partial"))


