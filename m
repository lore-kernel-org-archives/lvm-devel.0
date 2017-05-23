From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 22 May 2017 20:39:49 -0400
Subject: master - metadata: Unlock VG on more _vg_make_handle error paths
Message-ID: <201705230039.v4N0dnCf020468@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbe7464df5018d8ab85dd312fae8c13796eca59d
Commit:        fbe7464df5018d8ab85dd312fae8c13796eca59d
Parent:        d1ddfc408535b9c4df432273657f952c59f16232
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 23 01:37:14 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 23 01:38:02 2017 +0100

metadata: Unlock VG on more _vg_make_handle error paths

Internal error: VG lock vg0 must be requested before vg3, not after.
Internal error: 3 device(s) were left open and have been closed.
---
 lib/metadata/metadata.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a95b9e3..36bb0e4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1089,8 +1089,7 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
-	if (vg->read_status != failure)
-		vg->read_status = failure;
+	vg->read_status = failure;
 
 	if (vg->fid && !_vg_update_vg_committed(vg))
 		vg->read_status |= FAILED_ALLOCATION;
@@ -1122,6 +1121,7 @@ int vg_has_unknown_segments(const struct volume_group *vg)
 struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name)
 {
 	uint32_t rc;
+	struct volume_group *vg;
 
 	if (!validate_name(vg_name)) {
 		log_error("Invalid vg name %s", vg_name);
@@ -1134,7 +1134,11 @@ struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_
 		/* NOTE: let caller decide - this may be check for existence */
 		return _vg_make_handle(cmd, NULL, rc);
 
-	return vg_create(cmd, vg_name);
+	vg = vg_create(cmd, vg_name);
+	if (!vg || vg_read_error(vg))
+		unlock_vg(cmd, NULL, vg_name);
+
+	return vg;
 }
 
 /*
@@ -5877,7 +5881,11 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	if (failure)
 		goto_bad;
 
-	return _vg_make_handle(cmd, vg, failure);
+	if (!(vg = _vg_make_handle(cmd, vg, failure)) || vg_read_error(vg))
+		if (!already_locked)
+			unlock_vg(cmd, vg, vg_name);
+
+	return vg;
 
 bad:
 	if (!already_locked)
@@ -5938,7 +5946,12 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 			 const char *vgid, uint32_t read_flags, uint32_t lockd_state)
 {
-	return vg_read(cmd, vg_name, vgid, read_flags | READ_FOR_UPDATE, lockd_state);
+	struct volume_group *vg = vg_read(cmd, vg_name, vgid, read_flags | READ_FOR_UPDATE, lockd_state);
+
+	if (!vg || vg_read_error(vg))
+		stack;
+
+	return vg;
 }
 
 /*
@@ -5967,9 +5980,8 @@ uint32_t vg_read_error(struct volume_group *vg_handle)
  */
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 {
-	if (!lock_vol(cmd, vgname, LCK_VG_WRITE, NULL)) {
+	if (!lock_vol(cmd, vgname, LCK_VG_WRITE, NULL))
 		return FAILED_LOCKING;
-	}
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */


