From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 11:29:03 +0000 (UTC)
Subject: master - lvmetad: maintain seqno as int
Message-ID: <20151109112903.358356092B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5aae8de7760e321ad1fd6e88128379640df31c29
Commit:        5aae8de7760e321ad1fd6e88128379640df31c29
Parent:        57c2a1ae8c9f59d301ff34068fa893f04f713fe2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 10:36:23 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 12:21:17 2015 +0100

lvmetad: maintain seqno as int

Keep seqno as 32bit value.
Also use '_' prefix for local _update_metadata.
---
 daemons/lvmetad/lvmetad-core.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index eb343ab..69dc961 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1327,9 +1327,9 @@ out_free:
  * pvid and ret_old_seq are both NULL.
  */
 
-static int update_metadata(lvmetad_state *s, const char *arg_name, const char *arg_vgid,
-			   struct dm_config_node *new_metadata, int64_t *ret_old_seq,
-			   const char *pvid)
+static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *arg_vgid,
+			    struct dm_config_node *new_metadata, int *ret_old_seq,
+			    const char *pvid)
 {
 	struct dm_config_tree *old_meta = NULL;
 	struct dm_config_tree *new_meta = NULL;
@@ -2083,10 +2083,10 @@ static response pv_found(lvmetad_state *s, request r)
 	uint64_t arg_device_lookup = 0;
 	uint64_t new_device = 0;
 	uint64_t old_device = 0;
-	int64_t arg_seqno = -1;
-	int64_t old_seqno = -1;
-	int64_t vg_status_seqno = -1;
-	int64_t changed = 0;
+	int arg_seqno = -1;
+	int old_seqno = -1;
+	int vg_status_seqno = -1;
+	int changed = 0;
 
 	/*
 	 * New input values.
@@ -2383,9 +2383,9 @@ static response pv_found(lvmetad_state *s, request r)
 	 * name of the VG so we can check if the VG is complete.
 	 */
 	if (arg_vgmeta) {
-		DEBUGLOG(s, "pv_found pvid %s has VG %s %s seqno %ld", arg_pvid, arg_name, arg_vgid, arg_seqno);
+		DEBUGLOG(s, "pv_found pvid %s has VG %s %s seqno %d", arg_pvid, arg_name, arg_vgid, arg_seqno);
 
-		if (!update_metadata(s, arg_name, arg_vgid, arg_vgmeta, &old_seqno, arg_pvid)) {
+		if (!_update_metadata(s, arg_name, arg_vgid, arg_vgmeta, &old_seqno, arg_pvid)) {
 			ERROR(s, "Cannot use VG metadata for %s %s from PV %s on %" PRIu64,
 			      arg_name, arg_vgid, arg_pvid, arg_device);
 		}
@@ -2470,8 +2470,8 @@ static response pv_found(lvmetad_state *s, request r)
 				   "changed = %d", changed,
 				   "vgid = %s", arg_vgid ? arg_vgid : "#orphan",
 				   "vgname = %s", arg_name ? arg_name : "#orphan",
-				   "seqno_before = %"PRId64, old_seqno,
-				   "seqno_after = %"PRId64, vg_status_seqno,
+				   "seqno_before = %d", old_seqno,
+				   "seqno_after = %d", vg_status_seqno,
 				   NULL);
 
  nomem:
@@ -2544,7 +2544,7 @@ static response vg_update(lvmetad_state *s, request r)
 		/* TODO defer metadata update here; add a separate vg_commit
 		 * call; if client does not commit, die */
 
-		if (!update_metadata(s, vgname, vgid, metadata, NULL, NULL)) {
+		if (!_update_metadata(s, vgname, vgid, metadata, NULL, NULL)) {
 			ERROR(s, "vg_update failed: metadata update failed");
 			reply_fail("vg_update: failed metadata update");
 			goto fail;


