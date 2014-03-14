From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 14 Mar 2014 02:09:14 +0000 (UTC)
Subject: master - lvmetad: Indicate whether pv_found caused the VG to change.
Message-ID: <20140314020914.A30CD6036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=816197aaabbd41dd85d7728a6fd2992c148e124f
Commit:        816197aaabbd41dd85d7728a6fd2992c148e124f
Parent:        5eef269f7719089db2474b3f732f3630467d1bbc
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Mar 14 03:04:09 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Mar 14 03:08:19 2014 +0100

lvmetad: Indicate whether pv_found caused the VG to change.

---
 daemons/lvmetad/lvmetad-core.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 8522c11..93a56c6 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -863,7 +863,7 @@ static response pv_found(lvmetad_state *s, request r)
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
 	char *old;
 	char *pvid_dup;
-	int complete = 0, orphan = 0;
+	int complete = 0, orphan = 0, changed = 0;
 	int64_t seqno = -1, seqno_old = -1;
 
 	if (!pvid)
@@ -898,10 +898,14 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!(cft->root = dm_config_clone_node(cft, pvmeta, 0)))
                 goto out_of_mem;
 
+	if (pvmeta_old_pvid && compare_config(pvmeta_old_pvid->root, cft->root))
+		changed |= 1;
+
 	if (pvmeta_old_pvid && device != device_old_pvid) {
 		DEBUGLOG(s, "pv %s no longer on device %" PRIu64, pvid, device_old_pvid);
 		dm_free(dm_hash_lookup_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid)));
 		dm_hash_remove_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid));
+		changed |= 1;
 	}
 
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
@@ -935,6 +939,7 @@ out_of_mem:
 
 		if (!update_metadata(s, vgname, vgid, metadata, &seqno_old))
 			return reply_fail("metadata update failed");
+		changed |= (seqno_old != dm_config_find_int(metadata, "metadata/seqno", -1));
 	} else {
 		lock_pvid_to_vgid(s);
 		vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
@@ -972,6 +977,7 @@ out_of_mem:
 	return daemon_reply_simple("OK",
 				   "status = %s", orphan ? "orphan" :
 				                     (complete ? "complete" : "partial"),
+				   "changed = %d", changed,
 				   "vgid = %s", vgid ? vgid : "#orphan",
 				   "vgname = %s", vgname ? vgname : "#orphan",
 				   "seqno_before = %"PRId64, seqno_old,


