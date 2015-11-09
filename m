From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:05:55 +0000 (UTC)
Subject: master - cleanup: use _ for local function
Message-ID: <20151109160555.0B71E60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2d5cfbdb8529305a7dbde3652b7963fed1e3b59
Commit:        c2d5cfbdb8529305a7dbde3652b7963fed1e3b59
Parent:        3db5ba08b13fd542e725039646123bd8c0c5326a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 16:37:48 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

cleanup: use _ for local function

---
 daemons/lvmetad/lvmetad-core.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index da9a510..c17caa7 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -829,8 +829,8 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_p
 enum update_pvid_mode { UPDATE_ONLY, REMOVE_EMPTY, MARK_OUTDATED };
 
 /* You need to be holding the pvid_to_vgid lock already to call this. */
-static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
-			       const char *vgid, int mode)
+static int _update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
+				const char *vgid, int mode)
 {
 	struct dm_config_node *pv;
 	struct dm_hash_table *to_check;
@@ -932,7 +932,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 
 	/* update_pvid_to_vgid will clear/free the pvid_to_vgid hash */
 	if (update_pvids && meta_lookup)
-		update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
+		(void) _update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
 
 	/* free the unmapped data */
 
@@ -1050,7 +1050,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	/*
 	 * Temporarily orphan the PVs in the old metadata.
 	 */
-	if (!update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
+	if (!_update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
 		ERROR(s, "update_metadata_new_vgid failed to move PVs for %s old_vgid %s", arg_name, old_vgid);
 		abort_daemon = 1;
 		goto ret;
@@ -1104,7 +1104,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	/*
 	 * Reassign PVs based on the new metadata.
 	 */
-	if (!update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
+	if (!_update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
 		ERROR(s, "update_metadata_new_name failed to update PVs for %s %s", arg_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1164,7 +1164,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	/*
 	 * Temporarily orphan the PVs in the old metadata.
 	 */
-	if (!update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
+	if (!_update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
 		ERROR(s, "update_metadata_new_name failed to move PVs for old_name %s %s", old_name, arg_vgid);
 		abort_daemon = 1;
 		goto ret;
@@ -1218,7 +1218,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	/*
 	 * Reassign PVs based on the new metadata.
 	 */
-	if (!update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
+	if (!_update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
 		ERROR(s, "update_metadata_new_name failed to update PVs for %s %s", new_name, arg_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1284,7 +1284,7 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 		goto out;
 	}
 
-	if (!update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
+	if (!_update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
 		ERROR(s, "update_metadata_add_new failed to update PVs for %s %s", new_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1646,7 +1646,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
 		DEBUGLOG_cft(s, "NEW: ", new_metadata);
 		lock_pvid_to_vgid(s);
-		update_pvid_to_vgid(s, old_meta, arg_vgid, MARK_OUTDATED);
+		_update_pvid_to_vgid(s, old_meta, arg_vgid, MARK_OUTDATED);
 		unlock_pvid_to_vgid(s);
 	}
 
@@ -1771,9 +1771,9 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * The PVs in the VG may have changed in the new metadata, so
 	 * temporarily orphan all of the PVs in the existing VG.
 	 * The PVs that are still in the VG will be reassigned to this
-	 * VG below by the next call to update_pvid_to_vgid().
+	 * VG below by the next call to _update_pvid_to_vgid().
 	 */
-	if (!update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
+	if (!_update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
 		ERROR(s, "update_metadata failed to move PVs for %s %s", arg_name, arg_vgid);
 		unlock_vgid_to_metadata(s);
 		unlock_pvid_to_vgid(s);
@@ -1811,7 +1811,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * be newly mapped to this vgid, and previous PVs that
 	 * remain in the VG will be remapped to the VG again.
 	 */
-	if (!update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
+	if (!_update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
 		ERROR(s, "update_metadata failed to update PVs for %s %s", arg_name, arg_vgid);
 		abort_daemon = 1;
 		retval = 0;


