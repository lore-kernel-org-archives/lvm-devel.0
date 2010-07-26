From: Milan Broz <mbroz@redhat.com>
Date: Mon, 26 Jul 2010 10:43:15 +0200
Subject: [PATCH] Fix wrong use of LCK_WRITE
Message-ID: <1280133795-3081-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In all top vg read functions only LCK_VG_READ/WRITE can be used.
All other vg lock definitions are low-level backend machinery.

Moreover, LCK_WRITE cannot be tested through bitmask.
This patche fixes these mistakes.

For _recover_vg() we do not need lock_flags, it can be only
two of above and we always upgrading to LCK_VG_WRITE lock there.
(N.B. that code is racy)

There is no functional change in code (despite wrong masking
it produces correct bits:-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 07222a7..df15a29 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3825,20 +3825,16 @@ int vg_check_status(const struct volume_group *vg, uint64_t status)
 }
 
 static struct volume_group *_recover_vg(struct cmd_context *cmd,
-			 const char *vg_name, const char *vgid,
-			 uint32_t lock_flags)
+			 const char *vg_name, const char *vgid)
 {
 	int consistent = 1;
 	struct volume_group *vg;
 
-	lock_flags &= ~LCK_TYPE_MASK;
-	lock_flags |= LCK_WRITE;
-
 	unlock_vg(cmd, vg_name);
 
 	dev_close_all();
 
-	if (!lock_vol(cmd, vg_name, lock_flags))
+	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE))
 		return_NULL;
 
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
@@ -3873,7 +3869,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	uint32_t failure = 0;
 	int already_locked;
 
-	if (misc_flags & READ_ALLOW_INCONSISTENT || !(lock_flags & LCK_WRITE))
+	if (misc_flags & READ_ALLOW_INCONSISTENT || lock_flags != LCK_VG_WRITE)
 		consistent = 0;
 
 	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
@@ -3918,7 +3914,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
 		vg_release(vg);
-		if (!(vg = _recover_vg(cmd, vg_name, vgid, lock_flags))) {
+		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
@@ -3932,7 +3928,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	 */
 
 	if (!cmd->handles_missing_pvs && vg_missing_pv_count(vg) &&
-	    (lock_flags & LCK_WRITE)) {
+	    lock_flags == LCK_VG_WRITE) {
 		log_error("Cannot change VG %s while PVs are missing.", vg->name);
 		log_error("Consider vgreduce --removemissing.");
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
@@ -3940,7 +3936,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	}
 
 	if (!cmd->handles_unknown_segments && vg_has_unknown_segments(vg) &&
-	    (lock_flags & LCK_WRITE)) {
+	    lock_flags == LCK_VG_WRITE) {
 		log_error("Cannot change VG %s with unknown segments in it!",
 			  vg->name);
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
-- 
1.7.1


